/***********************************************************************
  Author: Ruriko Yoshida
  July 24th, 2002
  Update: Febrary 3rd, 2003
  This is a program for Barvinok's decomposition of cones.
  This is a class file.

************************************************************************/
#ifndef CONEDECOM__H
#define CONEDECOM__H
#include <NTL/vec_ZZ.h>
#include <NTL/mat_ZZ.h>
#include <NTL/mat_RR.h>
#include <NTL/vec_RR.h>
#include <NTL/config.h>
#include <NTL/LLL.h>
#include <NTL/HNF.h>
#include <NTL/ZZ.h>
#include "../PolyTree.h"
#include "../myheader.h"
#include "../RudyResNTL.h"

listCone* barvinokDecomposition(mat_ZZ, int, int, int&, char *File_Name, unsigned int Flags, int Cone_Index);
listVector* transformArrayBigVectorToListVector(mat_ZZ A, int numOfVectors,
						int numOfVars);

int barvinokDecomposition_Single (const mat_ZZ, int Number_of_Rays, int &Number_of_Uni_Cones, rationalVector *Cone_Vertex, Single_Cone_Parameters *, Node_Controller *Controller, char *File_Name, int Cone_Index);

#endif






