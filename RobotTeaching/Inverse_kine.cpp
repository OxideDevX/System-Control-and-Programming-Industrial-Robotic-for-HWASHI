#include "stdafx.h"
#include "Inverse_kine.h"
#include "math.h"
#define PI 3.1415926
#define Deg2Rad PI/180
#define Rad2Deg 180/PI
double a1 = 150;
double a2 = 570;
double a3 = 130;
double d4 = 640;
double Px = 0, Py = 0, Pz = 0;
double ang_S = 0, ang_L = 0, ang_U = 0;

Inverse_kine::Inverse_kine()
{	 
	Px_in = 0;
	Py_in = 0;
	Pz_in = 0;
}

void Inverse_kine::Forward_calculate(double ang_S, double ang_L, double ang_U)
{
	double rad_S = ang_S*Deg2Rad;
	double rad_L = ang_L*Deg2Rad;
	double rad_U = ang_U*Deg2Rad;

	Px = cos(rad_S)*(a3*cos(rad_L+rad_U) - d4*sin(rad_L+rad_U)+a2*cos(rad_L)+a1);//pos X
	Py = sin(rad_S)*(cos(rad_L+rad_U)*a3-d4*sin(rad_L + rad_U)+cos(rad_L)*a2+a1);//pos y
	Pz = -sin(rad_L + rad_U)*a3 - d4*cos(rad_L + rad_U) - sin(rad_L)*a2;//Pos Z
	Px_in = Px;
	Py_in = Py;
	Pz_in = Pz;
}

void Inverse_kine::Inverse_calculate(double x_js,double y_js,double z_js)
{
	double SQ1=0, SQ2=0;
	
	ang_S = Rad2Deg*atan2(y_js, x_js);
	double k21 = ((a1)*(a1)+(a2)*(a2)+(z_js)*(z_js)+k11*k11 - (a3)*(a3)-(d4)*(d4)-2 * (a1)*(k11)) / (2 * (a2));
	double l21 = sqrt(z_js*z_js + (k11 - a1)*(k11 - a1));
	if ((k21 / l21) <= 1)
	{
		SQ1 = sqrt(1 - (k21 / l21)*(k21 / l21));
	}
	else  SQ1 = sqrt((k21 / l21)*(k21 / l21) - 1);
	ang_L = -180 + (atan2((k11 - a1), z_js) + atan2((k21), ((l21)*SQ1)))*Rad2Deg
	double l31 = sqrt((a3*a3) + (d4*d4));
	double k31 = (cos((ang_L)*Deg2Rad))*(x_js*cos(ang_S*Deg2Rad) + y_js*(sin(ang_S*Deg2Rad))) - z_js*(sin((ang_L)*Deg2Rad)) - a1*(cos((ang_L)*Deg2Rad)) - a2;
	if ((k31 / l31) <= 1)
	{
		SQ2 = sqrt(1 - (k31 / l31)*(k31 / l31));
	}
	else SQ2 = sqrt((k31 / l31)*(k31 / l31) - 1);
	ang_U = (atan2(a3, d4) - atan2(k31, ((l31)*SQ2)))*Rad2Deg;

	ang_j_S = ang_S;
	ang_j_L = ang_L;
	ang_j_U = ang_U;
}
