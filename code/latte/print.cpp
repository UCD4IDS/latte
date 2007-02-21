/* print.cpp -- Print data structures

   Copyright 2002-2004 Jesus A. De Loera, David Haws, Raymond
      Hemmecke, Peter Huggins, Jeremy Tauzer, Ruriko Yoshida
   Copyright 2006 Matthias Koeppe

   This file is part of LattE.
   
   LattE is free software; you can redistribute it and/or modify it
   under the terms of the version 2 of the GNU General Public License
   as published by the Free Software Foundation.

   LattE is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with LattE; if not, write to the Free Software Foundation,
   Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
*/

#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <time.h>
#include <list>
#include <vector>

#include "cone.h"
#include "ramon.h"
#include "print.h"

/* ----------------------------------------------------------------- */
void printVector(vec_ZZ v, int numOfVars) {
  int i;

//    if (v==0) {
//      cout << "[]\n";
//      return ;
//    }
  cout << "[";
  for (i=0; i<(numOfVars-1); i++) {
    cout << v[i] << " ";
  }
  cout << v[i] << "]" << endl;
  return ;
}
/* ----------------------------------------------------------------- */
void printListVector(listVector* basis, int numOfVars) {
  if (basis==0) cout << "[]\n";
  while(basis) {
    printVector(basis->first,numOfVars);
    basis = basis->rest;
  }
/*  printf("\n"); */
  return ;
}
/* ----------------------------------------------------------------- */
void printRationalVector(rationalVector *v, int numOfVars) {
  int i;

//    if (v==0) {
//      cout << "[]\n";
//      return ;
//    }

  cout << "[";
  for (i=0; i<(numOfVars-1); i++) {
    if ((v->denominators())[i]==1)
      cout << (v->numerators())[i] << " ";
    else
      cout << (v->numerators())[i] << "/" << (v->denominators())[i] << " ";
  }

  if ((v->denominators())[i]==1)
    cout << (v->numerators())[i] << "]" << endl;
  else
    cout << (v->numerators())[i] << "/" << (v->denominators())[i] << "]" << endl;
  return ;
}
/* ----------------------------------------------------------------- */
void printCone(listCone* cones, int numOfVars) {
  printConeToFile(cout, cones, numOfVars);
}
/* ----------------------------------------------------------------- */
void printListCone(listCone* cones, int numOfVars) {
  if (cones==0) cout << "No cones in list.\n";
  while(cones) {
    printCone(cones,numOfVars);
    cones = cones->rest;
  }
  cout << endl;
  return ;
}
/* ----------------------------------------------------------------- */
void printVectorToFile(ostream & out, vec_ZZ v, int numOfVars) {
  int i;

//    if (v==0) {
//      out << "[]\n";
//      return ;
//    }
  out << "[";
  for (i=0; i<(numOfVars-1); i++) {
    out << v[i] << " ";
  }
  out << v[i] << "]\n";
  return ;
}
/* ----------------------------------------------------------------- */
void printListVectorToFile(ostream & out, listVector* basis, int numOfVars) {
  if (basis==0) {
    out << "[]\n";
    return;
  }

  while(basis) {
    printVectorToFile(out,basis->first,numOfVars);
    basis = basis->rest;
  }
  return ;
}
/* ----------------------------------------------------------------- */
void printVectorToFileWithoutBrackets(ostream & out, vec_ZZ v, 
				      int numOfVars) {
  int i;

//    if (v==0) return ;

  for (i=0; i<(numOfVars-1); i++) {
    out << v[i] << " ";
  }
  out << v[i] << endl;
  return ;
}
/* ----------------------------------------------------------------- */
void printListVectorToFileWithoutBrackets(ostream & out, listVector* basis, 
					  int numOfVars) {
  if (basis==0) {
    out << numOfVars << " 0\n";
    return;
  }

  while(basis) {
    printVectorToFileWithoutBrackets(out,basis->first,numOfVars);
    basis = basis->rest;
  }
  return ;
}
/* ----------------------------------------------------------------- */
void printRationalVectorToFile(ostream & out, rationalVector *v, 
			       int numOfVars) {
  int i;

  if (v==0) {
    out << "[]\n";
    return ;
  }
  out << "[";
  for (i=0; i<(numOfVars-1); i++) {
    if ((v->denominators())[i]==1)
      out << (v->numerators())[i] << " ";
    else
      out << (v->numerators())[i] << "/" << (v->denominators())[i] << " ";
  }
  
  if ((v->denominators())[i]==1)
    out << (v->numerators())[i] << "]\n";
  else
    out << (v->numerators())[i] << "/" << (v->denominators())[i] << "]\n";
  return ;
}
/* ----------------------------------------------------------------- */
void printRationalVectorToFileWithoutBrackets(ostream & out, 
					      rationalVector *v, 
					      int numOfVars) {
  int i;

  if (v==0) {
    return ;
  }
  for (i=0; i<(numOfVars); i++) {
    if ((v->denominators())[i]==1)
      out << (v->numerators())[i] << " "; 
    else
      out << (v->numerators())[i] << "/" << (v->denominators())[i] << " ";
  }

  out << endl;
  return ;
}
/* ----------------------------------------------------------------- */
void printConeToFile(ostream & out,listCone* cones, int numOfVars) {
  out << "==========\n";
  out << "Cone.\n";

  out << "Coefficient: " << cones->coefficient << endl;

  out << "Vertex: ";
  printRationalVectorToFile(out,cones->vertex->vertex,numOfVars);

  out << "Extreme rays:\n";  
  printListVectorToFile(out,cones->rays,numOfVars);

  out << "Determinant:" << cones->determinant << endl;
  
  out << "Facets:\n";  
  printListVectorToFile(out,cones->facets,numOfVars);

  out << "Dual determinant:" << cones->dual_determinant << endl;
  
  out << "Lattice points in parallelepiped:\n";
  printListVectorToFile(out,cones->latticePoints,numOfVars);
  out << "==========\n\n";

  return ;
}
/* ----------------------------------------------------------------- */
listCone *
readConeFromFile(istream &in)
{
  string s;
  while (in.good()) {
    in >> s;
    if (s == "rays:") break;
  }
  if (!in.good()) {
    return NULL;
  }
  listCone *cone = createListCone();
  while (in.good()) {
    vec_ZZ v;
    while (isspace(in.peek())) {
      char c;
      in.get(c);
    }
    if (in.peek() != '[') break;
    in >> v;
    if (in.good()) {
      cone->rays = appendVectorToListVector(v, cone->rays);
    }
  }
  cone->vertex = new Vertex(new rationalVector(cone->rays->first.length()));
  return cone;
}

/* ----------------------------------------------------------------- */
void printListConeToFile(const char *fileName, listCone* cones, int numOfVars) {
  ofstream out(fileName);
  if (!out) {
    printf("Error opening output file for writing in printListConeToFile!");
    exit(1);
  }

  if (cones==0) out << "No cones in list.\n";

  while (cones) {
    printConeToFile(out,cones,numOfVars);
    cones = cones->rest;
  }
  out << endl;

  out.close();
  return ;
}
/* ----------------------------------------------------------------- */
listCone *
readListConeFromFile(istream &in)
{
  listCone *result = NULL;
  listCone **tail_p = &result;
  while ((*tail_p = readConeFromFile(in)) != NULL) {
    tail_p = &(*tail_p)->rest;
  }
  return result;
}
/* ----------------------------------------------------------------- */
void printResidueFile(const char* fileName, listCone* cones, int numOfVars) {
  int numOfTerms;
  char outFileName[127];
  listVector *tmp;
  listCone *C;

  strcpy(outFileName,fileName);
  strcat(outFileName,".residue");

  ofstream out(outFileName);
  if (!out) {
    printf("Error opening output file for writing in printResidueFile!");
    exit(1);
  }
  if (cones==0) out << "No cones in list.\n";

  numOfTerms=0;

  C=cones;
  while (C) {
    numOfTerms=numOfTerms+lengthListVector(C->latticePoints);
    C=C->rest;
  }


  out << numOfVars << " " << lengthListVector(cones->rays) << " " <<
    numOfTerms << "\n\n";

  while (cones) {
    tmp=cones->latticePoints;
    while (tmp) {
      out << cones->coefficient << endl;
      printVectorToFileWithoutBrackets(out,tmp->first,numOfVars);
      printListVectorToFileWithoutBrackets(out,cones->rays,numOfVars);
      out << endl;
      tmp=tmp->rest;
    }
    cones = cones->rest;
  }
  out << endl;

  out.close();
  return ;
}

void
print_debug_vector(const vec_ZZ & v) {
   int len = v.length(); 

   cout << "Begin vector: ["; 
   for (int i = 0; i < len; i++) {
      cout << v[i] << ","; 
   }
   cout << "]: End vector\n"; 
}

void
print_debug_matrix(const mat_ZZ & m) {
   int rows = m.NumRows(); 
   int cols = m.NumCols(); 

   cout << "Begin matrix:\n"; 
   for (int i = 0; i < rows; i++) {
      cout << "["; 
      for (int j = 0; j < cols; j++) {
         cout << m[i][j] << ","; 
      }
      cout << "]\n"; 
   }
   cout << ":End matrix\n"; 
}
