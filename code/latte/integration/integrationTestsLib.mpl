with(linalg):with(LinearAlgebra):
with(numapprox,laurent):



#	This is mostly just a copy of decomposeTest.mpl.
#
#
#
#


#
# The test is done by comparing against known-good Maple code.
#
# Test limits:
maxDim := 3:
maxDegree := 2:

read("integration/createLinear.mpl"):

# Integral of a  power of a linear form over a simplex.
# Our Notations;

# 
# 

# The  integer d is the dimension;
# A vector in Q^d is a list of d rational numbers.
# A vertex is a vector in Q^d;
# The simplex  S is the convex hull of its vertices s_i. 
# Thus S is encoded as a list of vectors
# in Q^d.
# If the simplex is of full dimension, we have (d+1) vertices.  

#  A linear forms is called alpha, it is  represented by  a vector in Q^d.
# A monomial m is a list of d integers
#  A polynomial represented  in a sparse way;
#  Example x*y^2+2*x^2 with be given as a list of lists [[1,[1,2]],[2,[2,0]]. Each list represents a monomial with his coefficients. 
# Thus a sparse polynomial is represented as a list of lists.
# 
# .
# 
# Simplex and multiplicities.
# 
# INPUT: d an integer, S  list of d+1 lists of length d, alpha: list of length d . 
# OUTPUT: set of lists {[a_S], [m_S]} 
# MATH: S a simplex of dimension d+1, alpha a linear form, m_S is the list of the number of vertices S where <\alpha,S> = a_S.
# 
#    
multiplicity_alpha_simplex:=proc(S,d,alpha) local i,n,VS,m,Mult,j,c;
n:=nops(S);
VS:={seq(add(alpha[s]*S[i][s],s=1..d),i=1..nops(S))};
Mult:={};
for i from 1 to nops(VS) do 
m:=0; 
for j from 1 to nops(S) do 
c[j]:=add(alpha[s]*S[j][s],s=1..d);
if c[j]=VS[i] then m:=m+1;
else m:=m;
fi;
od;
Mult:={op(Mult),[VS[i],m]};
od;
Mult:
end:
# Computation of a coefficient
# 
# 
# 
# 
# M an integer, d an integer,  starting is a list of two elements  [v1,order1], where v1 is a rational number and order1 is an integer ;
#      L is a sequence of elements [ai,mi] where mi are integers and ai are numbers.  The output is 
# coeff((epsilon+v1)^(M+d)*1
# /(epsilon+a1)^m1*1/(epsilon+a2)^m2*...*1/(epsilon +aK)^mK; epsilon,order1-1)
prototype_residue:=proc(M,d,starting,L) local f,m,LL;
f:=(epsilon+starting[1])^(M+d); #print(f);
for m from 1 to nops(L) do
f:=f*1/(L[m][1])^(L[m][2])*1/(1+epsilon/L[m][1])^(L[m][2]);
od; 
f;
LL:=convert(laurent(f,epsilon,starting[2]),polynom);
coeff(LL,epsilon,starting[2]-1);
end:
# INPUT: S a simplex, alpha a linear form, d an integer, M an integer 
# OUTPUT: a number int_S alpha^M
# MATH:;
# See the manual for the formula.  
# 
integral_power_linear_form:=proc(S,d,M,alpha) local int,Mult,output,v,i,L,B,R,m,starting;
v:=abs(Determinant(Matrix([seq(S[j]-S[1],j=2..d+1)])));
if v=0 then int:=0;
else 
 Mult:=multiplicity_alpha_simplex(S,d,alpha); 
int:=0;
for  i from 1 to nops(Mult) do 
starting:=Mult[i];
 L:=
[seq([Mult[i][1]-Mult[j][1],Mult[j][2]],j=1..(i-1)),
seq([Mult[i][1]-Mult[j][1],Mult[j][2]],j=(i+1)..nops(Mult))];
R:=prototype_residue(M,d,starting,L);
int:=int+R;   
od;
fi;
M!/(M+d)!*int*v:
end:

# Decomposing  a monomial in powers of linear forms.
# INPUT:L list of integers, m a list of integers,M an integer
# OUTPUT: a nonnegative number
# MATH: The list $m$ represents the monomial x^m=x_1^{m[1]}x_2^{m[2]}\cdots x_d^{m[d], 
# the list L represents the linear form L=L[1]x[1]+..L[d]x_d. 
# The output is the coefficient of L^M,  M=M:=add(m[i],i=1..nops(m)), in the expansion of x^m in linear form using the formula in userguide. 
# CAUTION: The algorithm works only if we take "primitive" linear form as in the formula. 
coeff_linear_form_expansion:=proc(L,m) local p,j,c,s,M,out;
p:=[];
M:=add(m[i],i=1..nops(m));
    if igcd(seq(L[i],i=1..nops(L)))<>1 then print(trouble); 
    else
        for j from 1 to nops(L) do #print("j",j);
           if L[j]<>0 then
           p:=[op(p),iquo(m[j],L[j])];
           else p:=p;
           fi;
         od;

    c:=min(seq(p[i],i=1..nops(p)));
    s:=add(L[i],i=1..nops(L));#print("s,m,c",s,m,c);
    out:=1/M!*add((-1)^(M-k*s)*product(binomial(m[i],k*L[i]),i=1..nops(L))*k^M,k=1..c);
    fi;
out;
end:
# The input is a monomial.
# The output is the list of  elements [p1,....,pn] where$pi<=mi$ and mutually prime.
list_for_simplex_integral:=proc(m) local j,F,L,i,f,newL;newL:=[];
i:=1; 
if m[1]=0 then L:=[[0]]; else
L:=[seq([j],j=0..m[1])];fi;

     for i from 2 to nops(m) do #print(i,nops(L));
     L:=[seq(seq([op(L[s]),j],j=0..m[i]),s=1..nops(L))];
     od;
#print(L);
     for j from 1 to nops(L) 
     do F:=L[j];

       if
       igcd(seq(F[i],i=1..nops(F)))<>1
       then newL:=newL; 
       else newL:=[op(newL),F];
       fi;
     newL:
     od;
newL;
end:
# INPUT: m a list of integers, coe a number
# OUTPUT: a list of lists of length nops(m)
# MATH:  The list $m$ represents the monomial x^m=x_1^{m[1]}x_2^{m[2]}\cdots x_d^{m[d].
# The output is a list of lists. Each element in the list represents a linear form ([1,2]=x+2y). The output exausts all the linear form with exponents M=m[1]+..+m[d] which appear when  expressing   x^m as  linear combinations of linear form with exponent M. The first element is the coefficient multiplied by coe;
list_and_coeff_for_monome:=proc(m,coe) local M,L,out:
M:=add(m[i],i=1..nops(m));
L:=list_for_simplex_integral(m);#print(L);
out:=[ seq([coe*coeff_linear_form_expansion(L[j],m),[M,L[j]]],j=1..nops(L))];
end:
#  The input: S is  a simplex, d a number, m a monomial. The output is  a number, the integral of x^m over S.
integral_monome_via_waring:=proc(S,d,m) local out,M,L,i;
out:=0;
M:=add(m[i],i=1..nops(m));
L:=list_and_coeff_for_monome(m,1);
for i from 1 to nops(L) do
   out:=out
+L[i][1]*integral_power_linear_form(S,d,M,L[i][2][2]);
   od;
out;
end:
##integral_monome_via_waring([[0,0],[0,1],[1,0]],2,[9,2]);
# Integral of a polynomial via Waring.
# We give a polynomial in a sparse way; Example x*y^2+2*x^2 with be given as a list of lists [[1,[1,2]],[2,[2,0]]. Each list represents a monomial with his coefficients. 
#  We start by cleaning the sets for example we replace [[1,[1,2]],[1,[1,2]] by [2,[1,2]];
# Input  L; a list of lists [[a,alpha],[b,beta],...]. here a is a number, alpha is a list. The output is
# a set of lists.
# If alpha=beta, we replace by [a+b,alpha]; if a=0 we skip;
# The input is a list  L of lists [a,\alpha] where a is a number. The output is of the same kind.
cleaned_set:=proc(L) local newL,subL,X,i;
newL:=[]; 
for i from 1 to nops(L) do 
if L[i][1]<>0 then
newL:=[op(newL),L[i]];
fi;
od;
subL:={seq(newL[s][2],s=1..nops(newL))};
X:=add(newL[s][1]*x[newL[s][2]],s=1..nops(newL));
{seq([coeff(X,x[subL[i]],1),subL[i]],i=1..nops(subL))};
end:
# The input is  a sparse polynomial represented as a lists [c,m] of monomials with coefficients. The output is a list of lists [coe,[M,L]], coe a number, M an integer, L a linear form. It represents coe*L^M. 
list_integral_via_waring:=proc(sparse_poly) 
local Y, new_sparse_poly,n,i,Z;
new_sparse_poly:=cleaned_set(sparse_poly);
n:=nops(new_sparse_poly);
Y:=list_and_coeff_for_monome(new_sparse_poly[1][2],new_sparse_poly[1][1]); 
 for i from 2 to n do 
Z:=list_and_coeff_for_monome(new_sparse_poly[i][2],new_sparse_poly[i][1]); 
Y:=cleaned_set([op(Y),op(Z)]);
od; 
Y;
end:
# The input is a simplex S, d the dimension, sparse_poly a sparse polynomial. 
# The output is a number; the integral over S of the polynomial.
integral_via_waring:=proc(S,d,sparse_poly) local output,i, L ;output:=0;
L:=list_integral_via_waring(sparse_poly);
for i from 1 to nops(L) do 
output:=output+L[i][1]*
integral_power_linear_form(S,d,L[i][2][1],L[i][2][2]);
   od;
end:

#

with(combinat):

lattice_random_simplex:=proc(d,N) local R,U;
  R := rand(N):
  U:=proc()[seq(R(),i=1..d)] end proc:
  [ seq(U(), i=1..d+1) ];
end:

## Converting from Maple polynomials to our sparse format

polynomial_to_sparsepoly := proc(p, dimension)
  local variables,coefficients, monomials, exponents, theZip; 
  variables := [ seq(x[i], i=1..dimension) ];     
  #print (variables);     
  coefficients := coeffs(p, variables, 'monomials');
  #print (coefficients);
  #print (monomials);
  exponents := map( monomial -> map( variable -> degree(monomial, variable),
                            variables),
                     [monomials]);
  #print(exponents);
  zip((c,m) -> [c,m],
      [coefficients], 
      exponents);
end:

#                         bigConstant, dimension, myDegree, numTerms);
#Makes a random polynomial. Each polynomial contains at most r monomilas of degree between [1, M].
#Then converts the polynomial to our list syntax: [ [coeff., [exps]]+ ] 
random_sparse_homogeneous_polynomial_with_degree:=proc(N,d,M,r, rationalCoeff) 
  local poly;
  poly:=random_sparse_homogeneous_polynomial_with_degree_mapleEncoded(N,d,M,r, rationalCoeff): 
  polynomial_to_sparsepoly(poly, d);
end:


#Makes a random homogeneous polynomial. Each polynomial contains at most r monomilas of degree between [1, M].
random_sparse_homogeneous_polynomial_with_degree_mapleEncoded:=proc(N,d,M,r, rationalCoeff) 
  local p, R, currentDegree, negative, R_denom;
  ## Give up if too large polynomials requested
  if (r > 500000) then
    error "Too large a polynomial requested"
  fi;
  R := rand(N);
  R_denom:=rand(100);
  negative:= rand(2); #negative() = 0 or 1
  
  if ( rationalCoeff = 0) then #make integer coeff. polynomials.
    p := randpoly([ seq(x[i], i=1..d) ], 
                  homogeneous, degree = 1, terms = rand(r)() + 1, coeffs = proc()(-1)^(negative())*( R() + 1); end);
    for currentDegree from 2 to M do
      p := p + randpoly([ seq(x[i], i=1..d) ], 
                  homogeneous, degree = currentDegree, terms = rand(r)(), coeffs = proc()(-1)^(negative())*( R() + 1); end);
    od:
  else #make rational coeff. polynomials.
    p := randpoly([ seq(x[i], i=1..d) ], 
                  homogeneous, degree = 1, terms = rand(r)() + 1, coeffs = proc()(-1)^(negative())*( R() / (R_denom() + 1)); end);
    for currentDegree from 2 to M do
      p := p + randpoly([ seq(x[i], i=1..d) ], 
                  homogeneous, degree = currentDegree, terms = rand(r)(), coeffs = proc()(-1)^(negative())*( R() / (R_denom() + 1)); end);
    od:               
   fi:            
  
  #printf("Random polynomial:\n\n");              
  #print(p);
  #printf("degree=%f, terms=%f", M, r);
  #error "stop the script";
  p;
end:

#Makes a random non-homogeneous polynomial. Each polynomial contains at most r monomilas of degree between [1, M].
random_sparse_nonhomogeneous_polynomial_with_degree_mapleEncoded:=proc(N,d,M,r, rationalCoeff)
  local R, R_denom, negative;
  R := rand(N);
  R_denom:=rand(100);
  negative:= rand(2); #negative() = 0 or 1


	return random_sparse_homogeneous_polynomial_with_degree_mapleEncoded(N,d,M,r, rationalCoeff)  + (R()*(-1)^(negative()))/(R_denom() + 1);
end:

test_integration:=proc(polyCount, bigConstant, numTerms, dimension, myDegree, decomposing, randomGen, rationalCoeff)
  global filename:
  local errors, wrong:
  local myMonomials, mySimplices, myLinForms, mapleLinForms, myResults, mapleResults:
  local curForms, curTerm, curSet:
  local myIndex, formIndex, i, j:
  local myTime, temp, intTime, L:
  local inputFile, outputFile, errorFile:
  
  printf("decomposing = %d\n\n", decomposing);
  
  #print(randomGen(bigConstant, dimension, myDegree, numTerms)):
  #get polynomials
  myTime:=0:
  intTime:=0:
  for myIndex from 1 to polyCount do
    mySimplices[myIndex]:=lattice_random_simplex(dimension, bigConstant);
    if decomposing = 1 then
      myMonomials[myIndex]:=randomGen(bigConstant, dimension, myDegree, numTerms, rationalCoeff);
    else
      #print(myDegree, dimension, bigConstant, bigConstant, numTerms);
      mapleLinForms[myIndex]:=randomGen(myDegree, dimension, bigConstant, bigConstant, numTerms, rationalCoeff):
      #print(random_linearform_given_degree_dimension_maxcoef_componentmax_maxterm(myDegree, dimension, bigConstant, bigConstant, numTerms));
    end if:
  od:

  #write to file
  if decomposing = 1 then
    inputFile:=fopen("integration/check_in.tmp",WRITE,TEXT):
    for i from 1 to polyCount do
      writeline(inputFile, convert(myMonomials[i], string));
      writeline(inputFile, StringTools[DeleteSpace](convert(mySimplices[i], string)));
      mapleLinForms[i]:=list_integral_via_waring(myMonomials[i]):
    od:
    close(inputFile):

    #run the integrate program
#print(StringTools[Join](["./integrate_test", filename, "-t 600 integration/check_in.tmp integration/check_out.tmp"):
    system("./integrate_test -m -t 600 integration/check_in.tmp integration/check_out.tmp"):

    outputFile:=fopen("integration/check_out.tmp",READ,TEXT):
    myLinForms[1]:=readline(outputFile):
    if (myLinForms[1] = "Error") then
      print("Integration timed out."):
      close(outputFile):
      return:
    end if:
    myResults[1]:=readline(outputFile):
    i:=1:
    while (myLinForms[i] <> 0) do
      i:=i+1:
      myLinForms[i]:=readline(outputFile): #decomposition into linear forms
      myResults[i]:=readline(outputFile): #integral result (skipping for now)
    od:
    close(outputFile):
  else
    inputFile:=fopen("integration/check_in.tmp",WRITE,TEXT):
    for i from 1 to polyCount do
      writeline(inputFile, convert(mapleLinForms[i], string));
      writeline(inputFile, StringTools[DeleteSpace](convert(mySimplices[i], string)));
    od:
    close(inputFile):
    
    #run the integrate program
    system("./integrate_test -t 600 integration/check_in.tmp integration/check_out.tmp"):
    
    outputFile:=fopen("integration/check_out.tmp",READ,TEXT):
    myResults[1]:=readline(outputFile):
    if (myResults[1] = "Error") then
      print("Integration timed out.");
      close(outputFile):
      return:
    end if:
    i:=1:
    while (myResults[i] <> 0) do
      i:=i+1:
      myResults[i]:=readline(outputFile): #integral result
    od:
    close(outputFile):
  end if:

  ###not doing the maple side to save time, comment lines below back in when integration works
  for myIndex from 1 to polyCount do
    mapleResults[myIndex]:=0:
    temp:=time():
    for formIndex from 1 to nops(mapleLinForms[myIndex]) do
      mapleResults[myIndex]:=mapleResults[myIndex]+mapleLinForms[myIndex][formIndex][1]*integral_power_linear_form(mySimplices[myIndex],dimension,mapleLinForms[myIndex][formIndex][2][1],mapleLinForms[myIndex][formIndex][2][2]):
    od:
    intTime:=intTime + time() - temp:
    #####print(StringTools[Join](["Integrating", convert(intTime,string)], ":"));
  od:
  
  intTime:=intTime / polyCount:
  #####print(StringTools[Join]([convert(intTime,string),"s. avg. spent on Maple integration."], " "));
  
  #compare the forms
  errors:=0:
  errorFile:=fopen("integration/errors.log",APPEND,TEXT):
  for i from 1 to polyCount do
    ##### print(myLinForms[i]);
    if decomposing = 1 then
      curForms:=Array(parse(myLinForms[i])):
    end if:
    ##### print("curForms", curForms):
    
    ##### print(mapleLinForms[i]);
    myResults[i]:=parse(myResults[i]):
    wrong:=0: #prevents double counting errors, hopefully
    if decomposing = 1 then #check that decomposition is correct
      if nops(parse(myLinForms[i])) <> nops(mapleLinForms[i]) then
        print("Different number of powers of linear forms.");
        printf("Polynomial number i=%d\n", i);
        printf("nop maple forms = %d\n", nops(mapleLinForms[i]));
        printf("nop our forms = %d\n\n", nops(parse(myLinForms[i])));
        print("myLinForms", myLinForms[i]);
        print("mapleLinForms", mapleLinForms[i]);
        print(mapleResults[i]);
        print(myResults[i]);
        errors:= errors + 1;
        wrong:=1:
      else
        mapleLinForms[i]:=convert(mapleLinForms[i], 'set');
        curTerm:={};
        for j from 1 to nops(parse(myLinForms[i])) do
          #print(curForms[j][1], curForms[j][2][1]);
          curTerm:=curTerm union {[curForms[j][1] / factorial(curForms[j][2][1]), curForms[j][2]]};
          #print({[curForms[j][1] / factorial(curForms[j][2][1]), curForms[j][2]]});
        od:
        if curTerm <> mapleLinForms[i] then
          print("Powers of linear forms don't match.");
          #print(curTerm);
          #print(mapleLinForms[i]);
          print("myLinForms", myLinForms[i]);
          print("mapleLinForms", mapleLinForms[i]);
          
          printf("curtTerm minus mapleLinForms[%d]: = \n\n", i);
          print(curTerm minus mapleLinForms[i]);
          
          printf("mapleLinForms[%d] minus curTerm: = \n\n", i);
          print(mapleLinForms[i] minus  curTerm );
          
          
          errors:=errors + 1;
          wrong:=1:
        end if:
      end if:
    end if:
    #below compares maple results to the ones read in from the c++ output
    if wrong = 0 then
      if mapleResults[i] <> simplify(myResults[i][1] / myResults[i][2]) then
        writeline(errorFile, "Integral calculation mismatch.");
        writeline(errorFile, "Forms:");
        writeline(errorFile, convert(mapleLinForms[i], string));
        writeline(errorFile, "Simplex:");
        writeline(errorFile, convert(mySimplices[i], string));
        writeline(errorFile, "Maple result:");
        writeline(errorFile, convert(mapleResults[i], string));
        writeline(errorFile, "C++ result:");
        writeline(errorFile, convert(simplify(myResults[i][1] / myResults[i][2]), string));
        errors:=errors + 1;
      end if:
    end if;  
  od:
  close(errorFile):
  

  if errors > 0 then 
    printf("%d tests failed.\n", errors):
  end if;
  errors
end:
