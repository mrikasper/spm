/*
 * $Id: hist2.c 7783 2020-02-13 12:57:30Z john $
 * John Ashburner
 */

#include <math.h>
#include "spm_mex.h"

static float samp(const mwSize d[3], unsigned char f[], float x, float y, float z)
{
    int ix, iy, iz;
    float dx1, dy1, dz1, dx2, dy2, dz2;
    int k111,k112,k121,k122,k211,k212,k221,k222;
    float vf;
    unsigned char *ff;

    ix = floor(x); dx1=x-ix; dx2=1.0-dx1;
    iy = floor(y); dy1=y-iy; dy2=1.0-dy1;
    iz = floor(z); dz1=z-iz; dz2=1.0-dz1;

    ff   = f + ix-1+d[0]*(iy-1+d[1]*(iz-1));
    k222 = ff[   0]; k122 = ff[     1];
    k212 = ff[d[0]]; k112 = ff[d[0]+1];
    if (iz < d[2]-1)
    {
        ff  += d[0]*d[1];
        k221 = ff[   0]; k121 = ff[     1];
        k211 = ff[d[0]]; k111 = ff[d[0]+1];

        vf = (((k222*dx2+k122*dx1)*dy2       +
               (k212*dx2+k112*dx1)*dy1))*dz2 +
             (((k221*dx2+k121*dx1)*dy2       +
               (k211*dx2+k111*dx1)*dy1))*dz1;
    }
    else
    {
        vf = (((k222*dx2+k122*dx1)*dy2       +
               (k212*dx2+k112*dx1)*dy1));
    }
    return(vf);
}


void hist2(double M[16], unsigned char g[], unsigned char f[], const mwSize dg[3], const mwSize df[3], 
double H[65536], float s0[3])
{
    /* This is for dithering the sampling of the images.  The procedure seems to be similar to that
       used by Th\'evenaz, Bierlaire and Unser. "Halton Sampling for Image Registration Based on Mutual
       Information". Sampling Theory in Signal and Image Processing 7(2):141--171 (2008).
    */
    static float ran[] = {0.656619,0.891183,0.488144,0.992646,0.373326,0.531378,0.181316,0.501944,0.422195,
                          0.660427,0.673653,0.95733,0.191866,0.111216,0.565054,0.969166,0.0237439,0.870216,
                          0.0268766,0.519529,0.192291,0.715689,0.250673,0.933865,0.137189,0.521622,0.895202,
                          0.942387,0.335083,0.437364,0.471156,0.14931,0.135864,0.532498,0.725789,0.398703,
                          0.358419,0.285279,0.868635,0.626413,0.241172,0.978082,0.640501,0.229849,0.681335,
                          0.665823,0.134718,0.0224933,0.262199,0.116515,0.0693182,0.85293,0.180331,0.0324186,
                          0.733926,0.536517,0.27603,0.368458,0.0128863,0.889206,0.866021,0.254247,0.569481,
                          0.159265,0.594364,0.3311,0.658613,0.863634,0.567623,0.980481,0.791832,0.152594,
                          0.833027,0.191863,0.638987,0.669,0.772088,0.379818,0.441585,0.48306,0.608106,
                          0.175996,0.00202556,0.790224,0.513609,0.213229,0.10345,0.157337,0.407515,0.407757,
                          0.0526927,0.941815,0.149972,0.384374,0.311059,0.168534,0.896648};
    int iran=0, i;
    float z;
    float s[3];
    for(i=0; i<3; i++)
    {
        if (dg[i]>1)
            s[i] = s0[i];
        else
            s[i] = 0.0;
    }
    for(z=1.0; z<=dg[2]-s[2]; z+=s0[2])
    {
        float y;
        for(y=1.0; y<dg[1]-s[1]; y+=s0[1])
        {
            float x;
            for(x=1.0; x<dg[0]-s[0]; x+=s0[0])
            {
                float rx, ry, rz, xp, yp, zp;

                rx  = x + ran[iran = (iran+1)%97]*s[0];
                ry  = y + ran[iran = (iran+1)%97]*s[1];
                rz  = z + ran[iran = (iran+1)%97]*s[2];

                xp  = M[0]*rx + M[4]*ry + M[ 8]*rz + M[12];
                yp  = M[1]*rx + M[5]*ry + M[ 9]*rz + M[13];
                zp  = M[2]*rx + M[6]*ry + M[10]*rz + M[14];

                if (zp>=1.0 && zp<=df[2] && yp>=1.0 && yp<df[1] && xp>=1.0 && xp<df[0])
                {
                    float vf;
                    int   ivf, ivg;
                    vf  = samp(df, f, xp,yp,zp);
                    ivf = floor(vf);
                    ivg = floor(samp(dg, g, rx,ry,rz)+0.5);
                    H[ivf+ivg*256] += (1-(vf-ivf));
                    if (ivf<255)
                        H[ivf+1+ivg*256] += (vf-ivf);

                    /*
                    float vf, vg;
                    int ivf, ivg;
                    vg  = samp(dg, g, rx,ry,rz);
                    vf  = samp(df, f, xp,yp,zp);
                    ivg = floor(vg);
                    ivf = floor(vf);
                    H[ivf+ivg*256] += (1-(vf-ivf))*(1-(vg-ivg));
                    if (ivf<255)
                        H[ivf+1+ivg*256] += (vf-ivf)*(1-(vg-ivg));
                    if (ivg<255)
                    {
                        H[ivf+(ivg+1)*256] += (1-(vf-ivf))*(vg-ivg);
                        if (ivf<255)
                            H[ivf+1+(ivg+1)*256] += (vf-ivf)*(vg-ivg);
                    }
                    */
                }
            }
        }
    }
}

