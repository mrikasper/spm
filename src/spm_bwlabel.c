/*
 * $Id: spm_bwlabel.c 8183 2021-11-04 15:25:19Z guillaume $
 * Jesper Andersson
 */

/****************************************************************
 **
 ** Set of routines implementing a 2D or 3D connected component
 ** labelling algorithm. Its interface is modelled on bwlabel
 ** (which is a routine in the image processing toolbox) and
 ** takes as input a binary image and (optionally) a connectednes
 ** criterion (6, 18 or 26, in 2D 6 will correspond to 4 and 18
 ** and 26 to 8). It will output an image/volume where each 
 ** connected component will have a unique label.
 **
 ** The implementation is not recursive (i.e. will no crash for
 ** large connected components) and is loosely based on
 ** Thurfjell et al. 1992, A new three-dimensional connected
 ** components labeling algorithm with simultaneous object
 ** feature extraction capability. CVGIP: Graphical Models 
 ** and Image Processing 54(4):357-364.
 **
 ***************************************************************/

#include <math.h>
#include <stdio.h>
#include <limits.h>
#include "mex.h"

/* Macros */

#define index(A,B,C,DIM) ((C)*DIM[0]*DIM[1] + (B)*DIM[0] + (A))

#ifndef MIN
#define MIN(A,B) ((A) > (B) ? (B) : (A))
#endif

#ifndef MAX
#define MAX(A,B) ((A) > (B) ? (A) : (B))
#endif

/* fill_tratab */

void fill_tratab(unsigned int  *tt,     /* Translation table */
                 unsigned int  ttn,     /* Size of translation table */
                 unsigned int  *nabo,   /* Set of neighbours */
                 unsigned int  nr_set)  /* Number of neighbours in nabo */
{
   int           i = 0, j = 0, cntr = 0;
   unsigned int  tn[9];
   unsigned int  ltn = UINT_MAX;

   /*
   Find smallest terminal number in neighbourhood
   */

   for (i=0; i<nr_set; i++)
   {
      j = nabo[i];
      cntr=0;
      while (tt[j-1] != j) 
      {
         j = tt[j-1];
         cntr++;
         if (cntr>100) {printf("\nOoh no!!"); break;}
      }
      tn[i] = j;
      ltn = MIN(ltn,j);
   }
   /*
   Replace all terminal numbers in neighbourhood by the smallest one
   */
   for (i=0; i<nr_set; i++)
   {
      tt[tn[i]-1] = ltn;
   }

   return;
}


/* check_previous_slice */

unsigned int check_previous_slice(unsigned int  *il,     /* Initial labelling map */
                                  unsigned int  r,       /* row */
                                  unsigned int  c,       /* column */
                                  unsigned int  sl,      /* slice */
                                  mwSize        dim[3],  /* dimensions of il */
                                  unsigned int  conn,    /* Connectivity criterion */
                                  unsigned int  *tt,     /* Translation table */
                                  unsigned int  ttn)     /* Size of translation table */
{
   unsigned int l=0;
   unsigned int nabo[9];
   unsigned int nr_set = 0;

   if (!sl) return(0);
  
   if (conn >= 6)
   {
      if ((l = il[index(r,c,sl-1,dim)])) {nabo[nr_set++] = l;}
   }
   if (conn >= 18)
   {
      if (r) {if ((l = il[index(r-1,c,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if (c) {if ((l = il[index(r,c-1,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if (r < dim[0]-1) {if ((l = il[index(r+1,c,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if (c < dim[1]-1) {if ((l = il[index(r,c+1,sl-1,dim)])) {nabo[nr_set++] = l;}}
   }
   if (conn == 26)
   {
      if (r && c) {if ((l = il[index(r-1,c-1,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if ((r < dim[0]-1) && c) {if ((l = il[index(r+1,c-1,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if (r && (c < dim[1]-1)) {if ((l = il[index(r-1,c+1,sl-1,dim)])) {nabo[nr_set++] = l;}}
      if ((r < dim[0]-1) && (c < dim[1]-1)) {if ((l = il[index(r+1,c+1,sl-1,dim)])) {nabo[nr_set++] = l;}}
   }

   if (nr_set) 
   {
      fill_tratab(tt,ttn,nabo,nr_set);
      return(nabo[0]);
   }
   else {return(0);}
}


/* do_initial_labelling */

unsigned int do_initial_labelling(double        *bw,   /* Binary map */
                                  mwSize        *dim,  /* Dimensions of bw */
                                  unsigned int  conn,  /* Connectivity criterion */
                                  unsigned int  *il,   /* Initially labelled map */
                                  unsigned int  **tt)  /* Translation table */
{
   unsigned int  i = 0, j = 0;
   unsigned int  nabo[8];
   unsigned int  label = 1;
   unsigned int  nr_set = 0;
   unsigned int  l = 0;
   mwIndex       sl, r, c;
   unsigned int  ttn = 1000;

   *tt = (unsigned int *) mxCalloc(ttn,sizeof(unsigned int));

   for (sl=0; sl<dim[2]; sl++)
   {
      for (c=0; c<dim[1]; c++)
      {
         for (r=0; r<dim[0]; r++)
         {
            nr_set = 0;
            if (bw[index(r,c,sl,dim)])
            {
               nabo[0] = check_previous_slice(il,r,c,sl,dim,conn,*tt,ttn);
               if (nabo[0]) {nr_set += 1;}
               /*
                  For six(surface)-connectivity
               */
               if (conn >= 6)
               {
                  if (r)
                  {
                     if ((l = il[index(r-1,c,sl,dim)])) {nabo[nr_set++] = l;}
                  }
                  if (c)
                  {
                     if ((l = il[index(r,c-1,sl,dim)])) {nabo[nr_set++] = l;}
                  }
               }
               /*
                  For 18(edge)-connectivity
                  N.B. In current slice no difference to 26.
               */
               if (conn >= 18)
               {
                  if (c && r)
                  {
                     if ((l = il[index(r-1,c-1,sl,dim)])) {nabo[nr_set++] = l;}
                  }
                  if (c && (r < dim[0]-1))
                  {
                     if ((l = il[index(r+1,c-1,sl,dim)])) {nabo[nr_set++] = l;}
                  }
               }
               if (nr_set)
               {
                  il[index(r,c,sl,dim)] = nabo[0];
                  fill_tratab(*tt,ttn,nabo,nr_set);
               }
               else
               {
                  il[index(r,c,sl,dim)] = label;
                  if (label >= ttn) {ttn += 1000; *tt = mxRealloc(*tt,ttn*sizeof(unsigned int));}
                  (*tt)[label-1] = label;
                  label++;
               }
            }
         }
      }
   }

   /*
      Finalise translation table
   */

   for (i=0; i<(label-1); i++)
   {
      j = i;
      while ((*tt)[j] != j+1)
      {
         j = (*tt)[j]-1;
      }
      (*tt)[i] = j+1;
   }
 
   
   return(label-1);
}


/* translate_labels */

double translate_labels(unsigned int  *il,     /* Map of initial labels. */
                        mwSize        dim[3],  /* Dimensions of il. */
                        unsigned int  *tt,     /* Translation table. */
                        unsigned int  ttn,     /* Size of translation table. */
                        double        *l)      /* Final map of labels. */
{
   int            n=0;
   int            i=0;
   unsigned int   ml=0;
   double         cl = 0.0;
   double         *fl = NULL;

   n = dim[0]*dim[1]*dim[2];

   for (i=0; i<ttn; i++) {ml = MAX(ml,tt[i]);}

   fl = (double *) mxCalloc(ml,sizeof(double)); 

   for (i=0; i<n; i++)
   {
      if (il[i])
      {
         if (!fl[tt[il[i]-1]-1]) 
         {
            cl += 1.0; 
            fl[tt[il[i]-1]-1] = cl;
         }
         l[i] = fl[tt[il[i]-1]-1];
      }
   }

   mxFree(fl);

   return(cl);
}


/* Gateway function */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   mwSize        ndim;
   int           n, i;
   mwSize        dim[3];
   const mwSize  *cdim = NULL;
   unsigned int  conn;
   unsigned int  ttn = 0;
   unsigned int  *il = NULL;
   unsigned int  *tt = NULL;
   double        *bw = NULL;
   double        *l = NULL;
   double        nl = 0.0;

   if (nrhs < 1) mexErrMsgTxt("Not enough input arguments.");
   if (nrhs > 2) mexErrMsgTxt("Too many input arguments.");
   if (nlhs > 2) mexErrMsgTxt("Too many output arguments.");

   /* Get binary map */

   if (!mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0]) || mxIsSparse(prhs[0]) || !mxIsDouble(prhs[0]))
   {
      mexErrMsgTxt("spm_bwlabel: BW must be numeric, real, full and double");
   }
   ndim = mxGetNumberOfDimensions(prhs[0]);
   if ((ndim < 2) || (ndim > 3))
   {
      mexErrMsgTxt("spm_bwlabel: BW must be 2 or 3-dimensional");
   }
   cdim = mxGetDimensions(prhs[0]);
   dim[0]=cdim[0]; dim[1]=cdim[1];
   if (ndim==2) {dim[2]=1; ndim=3;} else {dim[2]=cdim[2];} 
   for (i=0, n=1; i<ndim; i++)
   {
      n *= dim[i];
   }
   bw = mxGetPr(prhs[0]);

   /* Get connectivity criterion */
   
   if (nrhs==1)
   {
       conn = 18;
   }
   else
   {
       if (!mxIsNumeric(prhs[1]) || mxGetNumberOfElements(prhs[1])!=1)
       {
           mexErrMsgTxt("Input 'n' must be a scalar.");
       }
       conn = (unsigned int)(mxGetScalar(prhs[1]) + 0.1);
   }
   if ((conn!=6) && (conn!=18) && (conn!=26))
   {
       mexErrMsgTxt("Input 'n' must be 6, 18 or 26.");
   }

   /* Allocate memory for output and initialise to 0 */

   plhs[0] = mxCreateNumericArray(ndim,dim,mxDOUBLE_CLASS,mxREAL);
   l = mxGetPr(plhs[0]);

   /* Allocate memory for initial labelling map */

   il = (unsigned int *) mxCalloc(n,sizeof(unsigned int));

   /* Do initial labelling and create translation table */

   ttn = do_initial_labelling(bw,dim,conn,il,&tt);

   /* Translate labels to terminal numbers */

   nl = translate_labels(il,dim,tt,ttn,l);

   if (nlhs > 1)
   {
       plhs[1] = mxCreateDoubleScalar(nl);
   }

   /* Clean up a bit */

   mxFree(il);
   mxFree(tt);
   
}
