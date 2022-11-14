/* SpecialSimplex.cpp -- Check for a special simplex using CPLEX
	       
   Copyright 2007 Matthias Koeppe

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

#include <fstream>
#include <iostream>
#include <cstdlib>
#include <cassert>

#include <cplex.h>

#include "latte_gmp.h"
#include "latte_random.h"
#include "SpecialSimplex.h"
#include "triangulation/TriangulationWithTOPCOM.h"
#include "triangulation/RegularTriangulationWith4ti2.h"
#include "triangulation/RegularTriangulationWithCddlib.h"
#include "dual.h"
#include "print.h"

using namespace std;

static double
convert_ZZ_to_double(const ZZ &zz)
{
  mpz_class mpz = convert_ZZ_to_mpz(zz);
  return mpz.get_d();
}

listCone *
FindSpecialSimplex(listCone *cone, int numOfVars)
{
  CPXENVptr env;
  int status;
  env = CPXopenCPLEX(&status);
  if (status != 0) {
    cerr << "Failed to obtain CPLEX environment." << endl;
    abort();
  }

  int num_rays = lengthListVector(cone->rays);

  CPXLPptr lp = CPXcreateprob(env, &status, "repr");
  if (status != 0) abort();
  
  status = CPXchgprobtype(env, lp, CPXPROB_MILP);
  if (status != 0) abort();

  /* Fill equations that express that e_n is a linear combination of
     the rays, using variables x_i as multipliers. */
  status = CPXnewrows(env, lp, numOfVars, /*rhs:*/ NULL, /*sense:*/ NULL,
		      /*rngval:*/ NULL, /*rownames:*/ NULL);
  if (status != 0) abort();

  status = CPXnewcols(env, lp, num_rays, /*obj:*/ NULL,
		      /*lb:*/ NULL, /*ub:*/ NULL,
		      /*ctype:*/ NULL, /*colname:*/NULL);
  if (status != 0) abort();

  listVector *ray;
  int j;
  for (ray = cone->rays, j = 0; ray!=NULL; ray = ray->rest, j++) {
    int i;
    for (i = 0; i<numOfVars; i++) {
      status = CPXchgcoef(env, lp, i, j, convert_ZZ_to_double(ray->first[i]));
      if (status != 0) abort();
    }
    /* Add constraints x_i <= y_i <= M x_i */
    double M = 1000;
    int beg[2];
    int ind[4];
    double val[4];
    char sense[2];
    beg[0] = 0;  ind[0] = j; val[0] = +1; ind[1] = num_rays + j; val[1] = -M; sense[0] = 'L';
    beg[1] = 2;  ind[2] = j; val[2] = -1; ind[3] = num_rays + j; val[3] = +1; sense[1] = 'L';
    status = CPXaddrows(env, lp, 1, 2, 4, /* rhs: */ NULL, sense, beg, ind, val,
			/* colname: */ NULL, /* rowname: */ NULL);
    if (status != 0) abort();
    int index = num_rays + j;
    char ctype = 'B';
    status = CPXchgctype(env, lp, 1, &index, &ctype);
    if (status != 0) abort();
    /* We minimize the number of used rays. */
    status = CPXchgcoef(env, lp, -1, index, 1.0);
    if (status != 0) abort();
  }
  { /* Enter -10 * e_n as a right-hand side.
       Later we try + 10 * e_n too. */
    int index = numOfVars - 1;
    double value = +10.0;
    status = CPXchgrhs(env, lp, 1, &index, &value);
    if (status != 0) abort();
  }
#if 0
  /* Add a cardinality constraint. */
  {
    int beg = 0;
    int *ind = new int[num_rays];
    double *val = new double[num_rays];
    double rhs = numOfVars;
    char sense = 'E';
    int i;
    for (i = 0; i<num_rays; i++) {
      ind[i] = num_rays + i;
      val[i] = 1.0;
    }
    status = CPXaddrows(env, lp, 0, 1, num_rays, &rhs, &sense, &beg, ind, val,
			/* colname: */ NULL, /* rowname: */ NULL);
    delete[] ind;
    delete[] val;
    if (status != 0) abort();
  }
#endif
  /* Add variables and constraints that ensure we can linearly
     represent all other unit vectors too (linear span property). */
  int k;
  double *lb = new double[num_rays];
  double *ub = new double[num_rays];
  {
    int i;
    for (i = 0; i<num_rays; i++) {
      lb[i] = -CPX_INFBOUND;
      ub[i] = CPX_INFBOUND;
    }
  }
  for (k = 0; k<numOfVars - 1; k++) {
    int row_offset = CPXgetnumrows(env, lp);
    int col_offset = CPXgetnumcols(env, lp);
    status = CPXnewrows(env, lp, numOfVars, /*rhs:*/ NULL, /*sense:*/ NULL,
			/*rngval:*/ NULL, /*rownames:*/ NULL);
    if (status != 0) abort();
    { /* Enter 10 * e_k as a right-hand side. */
      int index = row_offset + k;
      double value = 10.0;
      status = CPXchgrhs(env, lp, 1, &index, &value);
      if (status != 0) abort();
    }
    /* New variables z_k */
    status = CPXnewcols(env, lp, num_rays, NULL,
			lb, ub,
			/*ctype:*/ NULL, /*colname:*/NULL);
    if (status != 0) abort();
    
    for (ray = cone->rays, j = 0; ray!=NULL; ray = ray->rest, j++) {
      int i;
      for (i = 0; i<numOfVars; i++) {
	status = CPXchgcoef(env, lp, i + row_offset, j + col_offset,
			    convert_ZZ_to_double(ray->first[i]));
	if (status != 0) abort();
      }
      /* Add constraints -M x_i <= z_{ki} <= M x_i */
      double M = 1000;
      int beg[2];
      int ind[4];
      double val[4];
      char sense[2];
      beg[0] = 0;  ind[0] = j + col_offset; val[0] = +1; ind[1] = num_rays + j; val[1] = -M; sense[0] = 'L';
      beg[1] = 2;  ind[2] = j + col_offset; val[2] = -1; ind[3] = num_rays + j; val[3] = -M; sense[1] = 'L';
      status = CPXaddrows(env, lp, 0, 2, 4, /* rhs: */ NULL, sense, beg, ind, val,
			  /* colname: */ NULL, /* rowname: */ NULL);
      if (status != 0) abort();
    }
  }
  status = CPXwriteprob(env, lp, "special-simplex.lp", "LP");
  if (status != 0) abort();

  status = CPXsetintparam(env, CPX_PARAM_SCRIND, CPX_ON);
  if (status != 0) abort();
  
  status = CPXmipopt(env, lp);
  if (status != 0) abort();
  
  int stat = CPXgetstat(env, lp);
  if (stat != CPXMIP_OPTIMAL) {
    cerr << "No solution for + e_n (CPLEX solution status "
	   << stat << ")." << endl;
    
    int index = numOfVars - 1;
    double value = -10.0;
    status = CPXchgrhs(env, lp, 1, &index, &value);
    if (status != 0) abort();

    status = CPXmipopt(env, lp);
    if (status != 0) abort();

    int stat = CPXgetstat(env, lp);
    if (stat != CPXMIP_OPTIMAL) {
      cerr << "No solution for -e_n (CPLEX solution status "
	   << stat << ")." << endl;
      cerr << "Did not find special simplex." << endl;
      exit(1);
    }
  }

  /* Inspect which rays form the special simplex. */

  cerr << "Vertical line is generated as follows by the rays: " << endl;
  listCone *special = createListCone();
  special->vertex = new Vertex(*cone->vertex);
  {
    double *x = new double[num_rays];
    double *y = new double[num_rays];
    status = CPXgetmipx(env, lp, y, 0, num_rays - 1);
    if (status != 0) abort();
    status = CPXgetmipx(env, lp, x, num_rays, 2 * num_rays - 1);
    if (status != 0) abort();
    int i;
    listVector *ray;
    for (ray = cone->rays, i = 0; i<num_rays; ray = ray->rest, i++) {
      if (fabs(x[i] - 1.0) < 0.1) {
	cerr << "+ " << y[i] << " * " << ray->first << endl;
	special->rays = new listVector(ray->first, special->rays);
      }
    }
    delete[] x;
  }

  if (lengthListVector(special->rays) == numOfVars) {
    cerr << "Found simplicial special cone (good)." << endl;
  }
  else {
    cerr << "Smallest special cone is non-simplicial; it has " << lengthListVector(special->rays)
	 << " generators." << endl;
  }
  return special;
}

struct special_height_data {
  listCone *special_cone;
  vec_ZZ c;
};

static bool
has_ray(listCone *cone, const vec_ZZ &ray_vector)
{
  listVector *ray;
  for (ray = cone->rays; ray != NULL; ray = ray->rest)
    if (ray->first == ray_vector) return true;
  return false;
}

void
special_height(mpq_t height, const vec_ZZ &ray, void *data)
{
  special_height_data *shd = (special_height_data *) data;

  /* Compute nominal height. */
  ZZ alpha;
  alpha = 100000;
  ZZ h;
  InnerProduct(h, shd->c, ray);
  h = alpha-h;
  
  int max_height = 100000;

  /* Increase height of all non-special rays */
  if (!has_ray(shd->special_cone, ray)) {
    h += 1000 * uniform_random_number(1000, max_height);
  }
      
  mpz_class hz = convert_ZZ_to_mpz(h);
  mpq_set_z(height, hz.get_mpz_t());
}


static bool
facets_ok(listCone *cone, int numOfVars)
{
  listVector *facet;
  for (facet = cone->facets; facet!=NULL; facet=facet->rest) {
    if (facet->first[numOfVars - 1] == 0)
      return false;
  }
  return true;
}

class FacetCheckingConeTransducer : public ConeTransducer {
  BarvinokParameters *params;
  bool have_bad_facets;
public:
  FacetCheckingConeTransducer(BarvinokParameters *a_params) :
    params(a_params), have_bad_facets(false) {}
  int ConsumeCone(listCone *cone);
  virtual ~FacetCheckingConeTransducer();
};

int FacetCheckingConeTransducer::ConsumeCone(listCone *cone)
{
  int numOfVars = cone->rays->first.length();
  if (cone->facets == NULL) {
      dualizeCone(cone, params->Number_of_Variables, params);
      dualizeCone(cone, params->Number_of_Variables, params);
  }
  if (!facets_ok(cone, numOfVars)) {
    cerr << "This cone has bad facets." << endl;
    printCone(cone, numOfVars);
    have_bad_facets = true;
  }
  return consumer->ConsumeCone(cone);
}

FacetCheckingConeTransducer::~FacetCheckingConeTransducer()
{
  if (have_bad_facets) {
    cerr << "There are cones with bad facets." << endl;
  }
}



class ExistenceCheckingConeTransducer : public ConeTransducer {
  bool found_special;
  listCone *special;
public:
  ExistenceCheckingConeTransducer(listCone *a_special) :
    found_special(false),
    special(a_special) {}
  int ConsumeCone(listCone *cone);
  virtual ~ExistenceCheckingConeTransducer();
};

static bool
cone_equal(listCone *a, listCone *b)
{
  if (lengthListVector(a->rays) != lengthListVector(b->rays))
    return false;
  listVector *a_ray;
  for (a_ray = a->rays; a_ray != NULL; a_ray = a_ray->rest) {
    if (!has_ray(b, a_ray->first)) return false;
  }
  return true;
}

static bool
is_subcone(listCone *a, listCone *b)
{
  listVector *a_ray;
  for (a_ray = a->rays; a_ray != NULL; a_ray = a_ray->rest) {
    if (!has_ray(b, a_ray->first)) return false;
  }
  return true;
}

int ExistenceCheckingConeTransducer::ConsumeCone(listCone *cone)
{
  int numOfVars = cone->rays->first.length();
  if (/* cone_equal(cone, special) */ is_subcone(special, cone)) {
    if (!cone_equal(special, cone)) {
      cerr << "Warning: Special cone only appeared as a subcone." << endl;
    }
    cerr << "Cone found: " << endl;
    printCone(cone, numOfVars);
    found_special = true;
  }
  return consumer->ConsumeCone(cone);
}

ExistenceCheckingConeTransducer::~ExistenceCheckingConeTransducer()
{
  if (!found_special) {
    cerr << "WARNING: Special cone did not appear in the triangulation." << endl;
  }
  else {
    cerr << "Special cone appears in the triangulation. Good."  << endl;
  }
}


void
special_triangulation_with_subspace_avoiding_facets
(listCone *cone, BarvinokParameters *Parameters, ConeConsumer &consumer)
{
  int numOfVars = Parameters->Number_of_Variables;
  listCone *special_cone;
  if (Parameters->triangulation_special_cone) {
    cerr << "Using the provided special cone..." << endl;
    special_cone = Parameters->triangulation_special_cone;
  }
  else {
    cerr << "Looking for a special cone using CPLEX..." << endl;
    special_cone = FindSpecialSimplex(cone, numOfVars);
    cerr << "Found special cone: " << endl;
    if (special_cone->facets == NULL) {
      dualizeCone(special_cone, numOfVars, Parameters);
      dualizeCone(special_cone, numOfVars, Parameters);
    }
    printListCone(special_cone, numOfVars);
  }
  ConeConsumer *effective_consumer = &consumer;
  /* Install check for singularity-avoiding facet normals. */
#if 1
  FacetCheckingConeTransducer checking_transducer(Parameters);
  checking_transducer.SetConsumer(effective_consumer);
  effective_consumer = &checking_transducer;
#endif
  /* Install check for special simplex. */
  ExistenceCheckingConeTransducer existence_transducer(special_cone);
  existence_transducer.SetConsumer(effective_consumer);
  effective_consumer = &existence_transducer;
#ifdef TRY_WITH_TOPCOM
  listCone *sorted_cone = createListCone();
  sorted_cone->vertex = new Vertex(*cone->vertex);
  listVector *ray;
  for (ray = cone->rays; ray != NULL; ray = ray->rest) {
    if (!has_ray(special_cone, ray->first))
      sorted_cone->rays = appendVectorToListVector(ray->first, sorted_cone->rays);
  }
  for (ray = cone->rays; ray != NULL; ray = ray->rest) {
    if (has_ray(special_cone, ray->first))
      sorted_cone->rays = appendVectorToListVector(ray->first, sorted_cone->rays);
  }
  cerr << "Sorted cone: " << endl;
  printCone(sorted_cone, numOfVars);
  triangulate_cone_with_TOPCOM(sorted_cone,
			       numOfVars, *effective_consumer);
#else
  special_height_data shd;
  shd.special_cone = special_cone;
  {
    /* Choose a generic facet normal (c,1) for the special cone */
    shd.c.SetLength(numOfVars);
    int i;
    for (i = 0; i<numOfVars; i++)
      shd.c[i] = uniform_random_number(1, 100000);
  }
  /*FIXME: */ Parameters->nonsimplicial_subdivision = true;
#if 1
  triangulate_cone_with_cddlib(cone, Parameters,
			       special_height, &shd,
			       numOfVars, *effective_consumer);
#else
  triangulate_cone_with_4ti2(cone, Parameters,
			     special_height, &shd,
			     *effective_consumer);
#endif
#endif
}
