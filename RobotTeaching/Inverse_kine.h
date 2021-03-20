#ifndef Inverse_kineH
#define Inverse_kineH


#include <Windows.h>

class Inverse_kine
{
public:
	double Px_in,Py_in,Pz_in;
	double ang_j_S,ang_j_L,ang_j_U;
	void Inverse_calculate(double x_in,double y_in,double z_in);
	void Forward_calculate(double ang_S, double ang_L, double ang_U);
	Inverse_kine();//must add
	~Inverse_kine();
private:

};

#endif