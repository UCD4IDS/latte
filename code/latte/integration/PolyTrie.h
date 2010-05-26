//will define multivariate polynomial representation, as well as input and output functions
#ifndef POLYTRIE_H
#define POLYTRIE_H

#include "iterators.h"
#include "consumers.h"
#include "burstTrie.h"
#include <NTL/ZZ.h>
#include <NTL/vec_ZZ.h>

NTL_CLIENT

void loadMonomials(monomialSum&, const string&);
//string parsing
void parseMonomials(MonomialConsumer<ZZ>*, const string&);
//data structure operations
void insertMonomial(const ZZ&, int*, monomialSum&);
string printMonomials(const monomialSum&);
void destroyMonomials(monomialSum&);

void loadLinForms(linFormSum&, const string);
//string parsing
void parseLinForms(FormSumConsumer<ZZ>*, const string&);
//data structure operations
void insertLinForm(const ZZ& coef, int degree, const vec_ZZ& coeffs, linFormSum&);
string printLinForms(const linFormSum&);
void destroyLinForms(linFormSum&);

void decompose(term<ZZ, int>*, linFormSum&);
void decompose(BTrieIterator<ZZ, int>* it, linFormSum&);
#endif
