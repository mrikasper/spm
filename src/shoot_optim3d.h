/* $Id: shoot_optim3d.h 7960 2020-09-24 19:34:30Z john $ */
/* (c) John Ashburner (2011) */
extern void   fmg3(mwSize n0[], float *a0, float *b0, double param[], int c, int nit,
                   float *u0, float *scratch);
extern void   cgs3(mwSize dm[], float A[], float b[], double param[], double tol, int nit,
                   float x[], float r[], float p[], float Ap[]);
extern void   resize_vol(mwSize na[], float *a, mwSize nc[], float *c, float *b);
extern void   restrict_vol(mwSize na[], float *a, mwSize nc[], float *c, float *b);
extern double norm(mwSize m, float a[]);
extern mwSize fmg3_scratchsize(mwSize n0[], int use_hessian);

