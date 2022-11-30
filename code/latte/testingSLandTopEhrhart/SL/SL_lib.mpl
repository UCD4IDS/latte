
# PROGRAM FOR COMPUTING THE FUNCTION SL(Polytope,variable); 

# 
with(linalg):with(LinearAlgebra):with(combinat):
kernelopts(assertlevel=1):       ### Enable checking ASSERTions
# General Notations:
#  If we work in R^d:
# 
# 
# A vector: a list of  d rational numbers:
# A Cone : a list of d vectors of length d: (we will only consider simplicial cones)
# when we say Cone in Z^d we mean that the vectors have integral coordinates;
# 
# A Signed cone:  [epsilon, Cone] where epsilon is -1 or 1.
#  
# L represents a linear subspace which is represented by a list of linearly independent vectors.
# 

# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# Programs on lists: addition on lists, complement of a list, sublist,etc...
# 
# 
# In particular we need them in the extreme cases of empty lists...
# 
# 
# 
# Input: a a list of length m , v a list of m vectors  in R^n, n an integer:
# Output: a list of length n; 
# The program check also if  a and v have the same nimber of elements
# Here we deal with the special case where v:=[] where we return the vector with coordinates 0;
# Math: we compute the vector V:= sum_i a_i v[i];
# Example:   special_lincomb_v([1,1],[[1,0],[0,1]],2) ->[1,1]

# 
# 
special_lincomb_v:=proc(a,v,n) local out;
ASSERT(nops(a)=nops(v)," the number of coefficients and vectors do not match");
if v=[]   then out:=[seq(0,i=1..n)];else
out:=[seq(add(a[i]*v[i][j],i=1..nops(v)),j=1..nops(v[1]))];
fi;out;
end:
#special_lincomb_v([1],[[1,0]],2);
# Input: a a list of length n, , v a list of n vectors, n an integer:
# Output: a list of length n;
# 
# Math: we compute the vector V:= sum_i a_i v[i];
# Example:   special_lincomb_v([1,1],[[1,0],[0,1]],2) ->[1,1]
# 
# Same program;
# but we restrict where the list v is not empty.
# 
# 
lincomb_v:=proc(a,v)
ASSERT(nops(a)=nops(v) and nops(v)>=1," the number of coefficients and vectors do not match");

[seq(add(a[i]*v[i][j],i=1..nops(v)),j=1..nops(v[1]))];

end:
#lincomb_v([],[],3);
# Input: two integers N,d:
# Output: a vector of length d:

# Math: the vector is randomly chosen with coordinates between 1 and N:
# 
# 
#  
random_vector:=proc(N,d) local R;
R:=rand(N);
[seq(R()+1,i=1..d)]:
end:

# Input: an integer N and sigma a list of vectors in R^d:
# Output: a vector of length d:

# Math: the vector is  sum_i x_i sigma_i, where the x_i are randomly chosen with coordinates between 1 and N:
# Example:cone_random_vector(10,[[sigma[1],sigma[2]],[nu[1],nu[2]]])->`invalid character in short integer encoding 17 `;
# 
# 
cone_random_vector:=proc(N,sigma) local R,d,randcoeff;
R:=rand(N);
d:=nops(sigma[1]);
randcoeff:=random_vector(N,nops(sigma));
[seq(add(randcoeff[i]*sigma[i][j],i=1..nops(sigma)),j=1..d)]:
end:
#cone_random_vector(10,[[sigma[1],sigma[2]],[nu[1],nu

# Input: K a subset of integers, L a list.The output takes the elements of the list L in the position of the list K
# 
# 
insert:=proc(K,L) local out;
out:=[seq(L[K[i]],i=1..nops(K))];
end:
#The output is the Complement  List, within the list [1,..,d]
ComplementList:=proc(K,d);
RETURN([seq (`if` (member(i,K)=false, i, op({})),i=1..d)]);
end:
#The output is the Complement  List, within the list [a[1],..,a[d]]
GeneralComplementList:=proc(K,L)local d;d:=nops(L);
RETURN([seq (`if` (member(L[i],K)=false, L[i], op({})),i=1..d)]);
end:
#GeneralComplementList([2,3],[1,2,3,7]);
# Miscellanea
# 
# Input: A :a vector with rational coordinates.
# Output: A vector with integral coordinates:
# Math: the primitive vector on the half line R^+A;
# Example: #primitive_vector([0,-1/2])->[0,-1];

# 
primitive_vector:=proc(A) local d,n,g;
d:=nops(A);
n:=ilcm(seq(denom(A[i]),i=1..d));
g:=igcd(seq(n*A[i],i=1..d));if g<>0 then
[seq(n*A[i]/g,i=1..d)];else [seq(n*A[i],i=1..d)];fi;
end:
ortho_basis:=proc(d) local i,v;
for i from 1 to d do
v[i]:=[seq(0,j=1..i-1),1,seq(0,j=i+1..d)]
od;[seq(v[j],j=1..d)];
end:
#  Signed decomposition into unimodular cones
# A "simplicial cone" is a list of  d linearly independent  vectors in Z^d, sometimes assumed primitive. 
# 
# short_vector(A)
# 
# # Input:   A is a list of d linearly independent vectors.
# # Output: sho is a vector of dimension d.
short_vector:=proc(A) local n,base,i,sho;  
n:=nops(A);
base:=IntegerRelations[LLL](A);
sho:=base[1];
i:=1; 
while i<=n-1 do
    if max(seq(abs(sho[j]),j=1..n))<=max(seq(abs(base[i+1][j]),j=1..n))
             then sho:=sho; else sho:=base[i+1];
    fi;
    i:=i+1;
od;
sho;
end:
# # sign_entries_vector(V)
# 
# #  Input : vector V of dimension d.
# # Output:  L=[ Lplus,Lminus,Lzero] is a partition of [1..d] into three sublists,
# #               according to the signs of the entries of the vector V.
sign_entries_vector:=proc(V) local d,i,Lplus,Lminus,Lzero; 
       d:=nops(V); Lplus:=[]; Lminus:=[];Lzero:=[];

       for i from 1 to d do 
          if type(V[i],positive)      then Lplus:=[op(Lplus),i];
          elif type(V[i],negative) then Lminus:=[op(Lminus),i];
                                else Lzero:=[op(Lzero),i];
          fi;
       od;
[Lplus,Lminus,Lzero];
end:
# # good_vector(G)
# #
# # Input   G  is a  "simplicial cone"
# # Output consists of 2 elements: 
# #              V is a vector in Z^d. 
# #               L=[ Lplus,Lminus,Lzero] is a partition of [1..d] into three sublists,
# #               according to the signs of the entries of the vector V. in the basis G. 
good_vector:=proc(G) local n,A,Ainverse,B,sho,V,L;
          n:=nops(G);  
          A:=Transpose(Matrix(G));      
          Ainverse:=MatrixInverse(A);
          B:=[seq(convert(Ainverse[1..n,i],list),i=1..n)]; 
          sho:=short_vector(B); 
          V :=[seq(add(G[j][i]*sho[j],j=1..n),i=1..n)];
          L:= sign_entries_vector(sho);
[V,L];
end:
# # signed_decomp(eps,G,v,L)
# 
# # Input :  eps = 1 or -1
# #             G  is a  "simplicial cone"
# #              V is a vector of dim d
# #              L= [ Lplus,Lminus,Lzero] is a partition of [1..d] into three sublists,
# #
# # Output : [Nonuni,Uni] 
# #              Nonuni and Uni are  lists of terms  [eps,detG,G],  where
# #               eps=1 or -1, 
# #               detG is an integer,  
# #               G  is a  list of  d linearly independent primitive  vectors in Z^d. 

signed_decomp:=proc(eps,G,v,L) local Nonuni,Uni,Lplus,Lminus,Lzero,kplus,kminus,kzero,i,j, C,M, detC, Csigned ; 
Nonuni:=[]; Uni:=[];
Lplus:=L[1]; Lminus:=L[2]; Lzero:=L[3];
 kplus:=nops(Lplus); kminus:=nops(Lminus); kzero:=nops(Lzero);
if kplus>0 then
    for i from 1 to kplus do
        C:=[seq(G[Lplus[j]],j=1..i-1),seq(-G[Lplus[j]],j=i+1..kplus),v,seq(G[Lminus[j]],j=1..kminus),seq(G[Lzero[j]],j=1..kzero)];

        detC := Determinant(Matrix(C));        
        Csigned:=[eps*(-1)^(i+kplus),detC,C];       
 
       if abs(detC)>1 then
          Nonuni:=[op(Nonuni),Csigned] else Uni:=[op(Uni),Csigned];
        fi;
   od;
 fi;

if kminus>0 then
   for i from 1 to kminus do
         C:=[seq(G[Lplus[j]],j=1..kplus),-v,seq(-G[Lminus[j]],j=1..i-1),seq(G[Lminus[j]],j=i+1..kminus),seq(G[Lzero[j]],j=1..kzero)]; 
        
         detC := Determinant(Matrix(C));
         Csigned:=[eps*(-1)^(i+1),detC,C];      
       
         if abs(detC)>1 then
            Nonuni:=[op(Nonuni),Csigned] else Uni:=[op(Uni), Csigned];
         fi;
    od;
 end if;
 [Nonuni,Uni];
 end:
# 
# 
# # good_cone_dec(eps,G)
# #  Input: eps = 1 or -1
# #             G  is a  simplicial cone
# #
# #  Output:  two lists [Nonuni,Uni] as in procedure signed_decomp: 
# #
good_cone_dec:=proc(eps,G) local n,A,R,Output;
n:=nops(G);  A:=Matrix([seq(G[i],i=1..n)]);   
   if abs(Determinant(A))=1 then  Output:=[[],[[eps,Determinant(A),G]]];
     else R:=good_vector(G);
          Output:=signed_decomp(eps,G,R[1],R[2]);
   fi;
end:
# # more_decomposition_in_cones(cones)
# 
# # Input:  cones =[cones[1],cones[2]] as in procedure signed_decomp
# # Output: [Newnonuni,Newuni] as in procedure signed_decomp
# 
# 
more_decomposition_in_cones:=proc(cones) local i,Newuni,Newnonuni,newcones:
Newnonuni:=[]; 
Newuni:=cones[2];
   for i from 1 to nops(cones[1]) do
    newcones:=good_cone_dec(cones[1][i][1],cones[1][i][3]);
   Newnonuni:=[op(Newnonuni),op(newcones[1])];
   Newuni:=[op(Newuni),op(newcones[2])];
 od;
[Newnonuni,Newuni];
end:  
          
# # cone_dec(G)
# #
# # Input:  G is a "simplicial cone"
# # Output: A list of  terms [eps,detG,G] where
# "               eps =1 or -1, 
# #               detG is an integer ( hopefully 1 or -1),  
# #               G  is a  "simplicial cone", (hopefully unimodular)
# #
cone_dec:=proc(G) local seed, i,ok;
if G=[] then RETURN([[1,1,[]]]);fi:
seed:=good_cone_dec(1,G);
 ok:=0;
i:=1; while ok=0  do
seed:=more_decomposition_in_cones(seed); 
if seed[1]=[] then
       ok:=1;else ok:=0;i:=i+1;
     fi;
od;
    RETURN(seed[2]);
end:
# Input: A signed list of cones;
# Output: a set of vectors;

collectgene:=proc(signedcones) local i,j,gene,newgen1,newgen2,gene1,gene2,cc;
gene:={}; 
for i from 1 to nops(signedcones) do 
cc:=signedcones[i][2];
for j from 1 to nops(cc) do
newgen1:=cc[j]; 
newgen2:=[seq(-cc[j][q],q=1..nops(cc[j]))];
gene1:={op(gene),newgen1}; 
gene2:={op(gene),newgen2};
if nops(gene1)<=nops(gene2) then
gene:=gene1;
else gene:=gene2; fi;
od;
od;
gene;
end:
# 
# Signed decomposition into  cones with faces parallel to L;
# 
# Here I have replaced welleda unique long procedure by  many smaller procedures that I understand better.
# 
# 

# In this subsection,  we solve the following problem:
# Given a cone Cone(W), and a subspace L,
#   we express the characteristic function of Cone(W) as a  signed sum of cones C_a
# where the cones C_a have the following property:
# If d=k+dim(L) these cones C_a  have d-k generators in L and k other generators in W. 
#  Example: L_cone_dec([[1,0],[0,1]],[[1,1]])-> 202, "unexpected end of statement";;

# 

# 
# 
# 
# 
# 
# 
# 
#  Input:  L a subspace: list of  s v ectors in R^d; The codimension 
# Output: a list  of
#   k=d-s vectors   in R^d ;
# Math: A basis  H_1,H_2,...,H_k of the space L^{perp};

# Example:basis_L_perp([[1,1,1]])->[[-1, 0, 1], [-1, 1, 0]];



basis_L_perp:=proc(L) local d,s,ML,VV;
d:=nops(L[1]); s:=nops(L);
ML:=Matrix(L): VV:=NullSpace(ML);
[seq(convert(VV[i],list),i=1..d-s)];
end:

# Input: W a list of vectors in R^d;
# L a list of vectors  in R^d of length s;
# Oputput: a list of vectors in R^k; with k=d-s;
# 
# Math: we project the vectors in X in Lperp; with  basis H1,H2,...,Hk;
# Our list  is the list of the projections of the elements of W written in the basis Hk (computed by basis_L_perp(L) as a list):
# 
# Example: Oursmallmatrix([[1,0,0],[0,1,0],[0,0,1]],[[1,1,1]])-> `invalid character in short integer encoding 203 Ë`;;
# 
# 

Oursmallmatrix:=proc(W,L) local s,d,HH,i,C,M,wbars,j,VV,cW;
d:=nops(W[1]); s:=nops(L);
C:=[];
HH:=basis_L_perp(L);
for i from 1 to d-s do 
C:=[op(C),[seq(add(HH[i][k]*HH[j][k],k=1..d),j=1..(d-s))]];
od;
M:=Transpose(Matrix(C));
wbars:=[];
for j from 1 to nops(W) do
VV:=Vector([seq(add(W[j][k]*HH[i][k],k=1..d),i=1..(d-s))]);
cW:=convert(LinearSolve(M,VV),list); 
wbars:=[op(wbars),cW];
od;
wbars;
end:



 
#Oursmallmatrix([[1,0,0],[0,1,0],[0,0,1]],[[1,1,1]]);basis_L_perp([[1,1,1]]);


#  Input: a list of N vectors in R^k;
# output; a list . Each element of the list is  [B,B_c,D,edges].
# Here B is a subset of [1,...,N]; B_c is the complement subset in [1,...,N];
# and D is a Matrix, edges is a list of vectors in R^k.
# Maths; 
# The list is [a_1,a_2,..., a_N]; 
# B is a subset of   B is a subset of [1,...,N] such that a_i, i in B are linearly independent.
# Then we express w_j with j in B_c as a vector with respect to the basis (w_i,i in B). 
# D is the matrix, edges is the list of columns of this matrix; This is a redundant information, but I kept this because I had problems in converting in lists  using only D in the next procedure after.
# # This procedure should be done using reverse search.
# 
# 
# AllDictionaries([[1,0],[1,0],[1,1]])-> `invalid character in short integer encoding 212 Ô`;;
# 
# 
# 
# 
# 
#  
AllDictionaries:=proc(Listvectors) local LL, N,k,K,h,MM,Kc,bandc,Matrix2,Dict,edges,newbc;
LL:=Listvectors;
N:=nops(LL); 
k:=nops(LL[1]);
K:=choose(N,k); 
bandc:=[];
for h from 1 to nops(K) do
MM:=Matrix([seq(LL[K[h][i]],i=1..k)]);
if Rank(MM)=k then 
Kc:=ComplementList(K[h],N); 
Matrix2:=Transpose(Matrix([seq(LL[Kc[i]],i=1..nops(Kc))]));
Dict:=MatrixMatrixMultiply(MatrixInverse(Transpose(MM)),Matrix2);
edges:=[seq(convert(Column(Dict,u),list),u=1..N-k)];
newbc:=[K[h],Kc,Dict,edges];
bandc:=[op(bandc),newbc];
else bandc:=bandc;
fi;
od;
bandc;
end:






#DDD:=AllDictionaries([[1,0],[0,1],[1,1]]);
# Input:= a list of N vectors in R^k
# Output:  a vector in R^k;
# Math: we compute a  vector a which is not on any hyperplane generated by some of the vectors in the list.
# Furthermore, we choose it to be in the cone generated by the list of vectors.
# 
# I did not do the choice of the "deterministic" regular vector.
# Example: randomRegularpositivevector([[1,0],[0,1],[1,1]])->[5,10];
randomRegularpositivevector:=proc(Listvectors) local LL,t,ok,w,K,f,MM,N,k,indexsigma,sigma;
LL:=Listvectors;
N:=nops(LL);
k:=nops(LL[1]);
indexsigma:=AllDictionaries(Listvectors)[1][1];
sigma:=[seq(LL[indexsigma[i]],i=1..k)]; ###print("sigma",sigma); 
K:=choose(N,k-1);
t:=1; ok:=0;
 while t<=10 do 
 w:=cone_random_vector(10*t,sigma);
f:=1; 
while f<=nops(K) do
MM:=Matrix([seq(LL[K[f][i]],i=1..k-1),w]);
if Determinant(MM)<>0 
then 
f:=f+1;
ok:=ok:
 ##print('ok,f',ok);
 else f:=nops(K)+1;
 ok:=ok+1;
 fi:od;
if ok=0 then t:=11;
else
t:=t+1;ok:=0;
fi;
od:
w;
end:


#randomRegularpositivevector([[0,0],[0,-1],[-1,-1]]);
# 
# 
# 
# Input:= a list of N vectors in R^k
# Output:  a list of lists: each list  is of the form [[sigma,epsilon, listsigns], [complementofsigma,A]];
# sigma is a subset of  [1,2,...,N], epsilon is a sign, listsigns is a sequence of k elements epsilon_i
# with epsilon_i a sign. complement of sigma is a subset of [1...N] (the complement of sigma),
# A is a list of N-k vectors in R^k.
# Math; sigma, epsilon will lead to generators epsilon_i w_i (i in sigma), the complement of sigma will lead to the generators 
# w_j-a_j^i w_i with j not in sigma. 
# 
# Example: coeff_cone_dec([[1,0],[0,1],[1,1]])->[op1,op2,op3]`invalid character in short integer encoding 212 Ô`;
# 
# 
# 

coeff_cone_dec:=proc(Listvectors) local N,k,w,out,LL,sigma,M1,cw,signswonsigma,edges,coeffs,i;
LL:=Listvectors; 
N:=nops(LL);
k:=nops(LL[1]);
coeffs:=[];
w:=randomRegularpositivevector(LL); ##print("randvector",w);
out:= AllDictionaries(LL);
for i from 1 to nops(out) do
sigma:=out[i][1]; ##print(sigma);
M1:=Matrix([seq(LL[sigma[u]],u=1..nops(sigma))]);
cw:=convert(LinearSolve(Transpose(M1),Vector(w)),list);
signswonsigma:=[sigma, mul(sign(cw[j]),j=1..k),[seq(sign(cw[j]),j=1..k)]];
coeffs:=[op(coeffs),[signswonsigma,[out[i][2],out[i][4]]]];
od;
coeffs;
end:



#op(1,coeff_cone_dec([[1,0],[0,1],[1,1]]));
# FINALLY: 
# 
# Input: W a list of d vectors in R^d; L a list of vectors in R^d;
# Output: a list of  signed cones in R^d
# 
# 
#  ;
# 
# Math: W represents a cone, we express the characteristic function of C as a  signed sum of cones C_a
# where the cones C_a have the following property:
# If d=k+dim(L) these cones C_a  have d-k generators in L and k other generators in W. 
#  Example: L_cone_dec([[1,0],[0,1]],[[1,1]])-> 202, "unexpected end of statement";;

# 
# 
# 
# 
# 
L_cone_dec:=proc(W,L) local d,LL,coeffs,conedec,i,generatorsonL,coe1,coe2,generatorssigma,u,a,vL,g,conesigma;
if L=[] 
or nops(W)=Rank(Matrix(L)) then
RETURN([[1,W]]);
fi;
d:=nops(W[1]);
LL:=Oursmallmatrix(W,L); ##print(LL); 
coeffs:=coeff_cone_dec(LL);
conedec:=[];
for i from 1  to nops(coeffs) do
generatorsonL:=[];  
  coe1:=coeffs[i][1];
  coe2:=coeffs[i][2]; 
  generatorssigma:=[seq(coe1[3][i]*primitive_vector(W[coe1[1][i]]),i=1..nops(coe1[1]))];
 for u from 1 to nops(coe2[2]) do 
 a:=[1,op(coe2[2][u])];
vL:=[W[coe2[1][u]],seq(-W[coe1[1][i]],i=1..nops(coe1[1]))];
g:=special_lincomb_v(a,vL,d);  
generatorsonL:=[op(generatorsonL),primitive_vector(g)];
od;
conesigma:=[coe1[2],[op(generatorssigma),op(generatorsonL)]]; 
conedec:=[op(conedec),conesigma];
od;
end:







  
#L_cone_dec([[1,0],[0,1]],[[1,0],[1,1]]);

# Projections:  

# Input: W is a list of vectors  of V , [v[1],..v[d]], of length d. 
# II =[i[1]..,i[s]], is a list of integers, b is a vector of length d.
# Output: a vector of length d,.
# 
# Math:  
# We decompose the space V in lin(II)+lin(IIc) where lin(II) of the vectors v[i], i in II, and lin(II_c) of the vectors in the complement indices. We project a vector b on lin(II)
# Thus we write b=b_II+b_II_c; 
# Our output is b_II; 
# Example: projectedvector([[1,0,0],[0,1,2],[0,1,0]],[3],[0,0,1])->[0,-1/2,0]; 
projectedvector:=proc(W,II,b) local M,S,j,v,V,m; 
M:=transpose(matrix([seq(W[i],i=1..nops(W))])); 
S:=linsolve(M,b); 
m:=det(M);
for j from 1 to nops(W) do 
   v[j]:=add(S[II[i]]*W[II[i]][j],i=1..nops(II));
od: 
V:=[seq(v[j],j=1..nops(W))]; 
end:
# Projected lattice
# # Input:  W=[v1,v2,.., vd];  a "Cone"  in  R^d;
# BE CAREFUl: The vectors in W must hage integral coordinates.
#  II a subset of [1,2..d] of cardinal k; 

# # Output a list [H1,H2,...,Hk] of vectors in R^d with k terms.
# 
#  
# projectedlattice: 
# Math: we
# decompose V in lin(II)+lin(II_c);
#  we project the standard lattice (that is Ze[1]+..+Ze[d], that is  Z[1,0,0..0]+... Z.[0,0,0..,1]]) 
# on lin[II] which is a  subspace of dimension k  of a space of dim d.
# output: (using ihermite) a basis of k elements (of length d) of the projected lattice  on lin(II).
# We will use over and over again this list H1,H2,..., Hk, so that we will work in Z^k  (embedded in R^d via H1,H2,..Hk).
# EXAMPLE: 
#projectedlattice([[1,3,0],[0,1,0],[0,0,2]],[1,3])-># [[0, 1/2, 0]];
# 
# 
# 
# 
# 
# 
projectedlattice:=proc(W,II) local m,B, d,k,i,r,S,IS,List;
d:=nops(W);
B:=ortho_basis(d); 
k:=nops(II);
m:=abs(Determinant(Transpose(Matrix([seq(W[i],i=1..nops(W))]))));
for i from 1 to d do 
 r[i]:=[seq(m*projectedvector(W,II,B[i])[j],j=1..nops(W))];
od;
 S:=Matrix([seq(r[i],i=1..d)]);;
 IS:=ihermite(S);
 List:=[seq(1/m*convert(row(IS,j),list),j=1..k)];
List;
end:
# Projected cone and projected vertex (expressed in the lattice basis) 
# Input: W is a Cone in Z^d and II is a subset of [1,..,d] of cardinal k;
#  Output: A "Cone" in Z^k;

# Be careful: our input must have integral coordinates.
# The output then will have integral coordinates.
# 
# 
# Here W is the cone and we are projecting W over lin( II) and expressing it in term of the standard projectedlattice(W,II). 
#  Example: projectedconeinbasislattice([[1,1,0],[0,1,0],[0,0,2]],[1,3])→[[1,0],[0,1]]
projectedconeinbasislattice:=proc(W,II) local P,M,output,i,F; 
P:=projectedlattice(W,II); ##print(P);
M:=Transpose(Matrix([seq(P[i],i=1..nops(P))]));
output:=[]; 
for i from 1 to nops(II) do 
F:=convert(LinearSolve(M,Vector(W[II[i]])),list); 
output:=[op(output),primitive_vector(F)];
 od;
output;
end:

# 
# #Input; W a Cone in Z^d;
# II a subset of [1,2,..d] of cardinal k;
# s a vector in R^d with rational coordinates (or symbolic coordinates); 
# #Output: a vector in R^k with rational coordinates;

# Math: Here W is the cone and we are projecting V over lin( II)  using  V:=lin(II) oplus
#  lin(II_c). We express the projection of s 
# with respect to the basis of the projected lattice. If the output is [a1,a2], this means that our 
# projected vertex is s_II=a1*H1+a2*H2 where H1,H2 is the basis of the projected lattice computed before.
# 
# 
# Example: projectedvertexinbasislattice([[1,0,0],[0,2,1],[0,1,1]],[1,3],[s1,s2,s3]) ->[s1, 2*s3-s2];; 
# 
projectedvertexinbasislattice:=proc(W,II,s) local m,P,M,output,i,F; P:=projectedlattice(W,II);##print(P);
if II=[] then RETURN([]);fi;
M:=Transpose(Matrix([seq(P[i],i=1..nops(P))])); 
F:=convert(LinearSolve(M,Vector(projectedvector(W,II,s))),list); 
output:=F;
end:
# Input: s a vector in R^d with rational coordinates (or symbolic).
# W a cone in Z^d
# Output:  a vector in R^d
# 
# Math: We decompose V in lin(II) oplus lin (II_c), and here we write s=s_II+s_(II_c): Here the output is s_(II_c);
# Example:s_IIc([s1,s2],[[1,0],[0,1]],[1])-> [0,s2];

s_IIc:=proc(s,W,II) local DD,IIc,M,s_in_cone_coord,s_IIc;
DD:=[seq(i,i=1..nops(W))];
IIc:=GeneralComplementList(II,DD);
M:=Matrix([seq(Vector([W[i]]),i=1..nops(W))]);

s_in_cone_coord:=convert(LinearSolve(M,Vector(s)),list);

s_IIc:=[seq(s_in_cone_coord[IIc[k]],k=1..nops(IIc))];
special_lincomb_v(s_IIc,[seq(W[IIc[k]],k=1..nops(IIc))],nops(W));
end:
# Basic functions
#  
# 
# 
# Todd(z,x):  the function (e^(zx)*x/(1-exp(x))); 
Todd:=proc(z,x);
exp(z*x)*x/(1-exp(x));
end:
# Relative volume
# 
# 
# 
# Input: W is a Cone in R^d and II is a subset of [1,..,d] of cardinal k;
# Output: a number;
# 
# Math; the volume of the Box(v[i], i not in II), with respect to the intersected lattice.
# Example: relativevolumeoffaceIIc([[1,1],[0,1]],[1])->1;  
# 
relativevolumeoffaceIIc:=proc(W,II) local DD,IIc,P,M,H,MM,output;
DD:=[seq(i,i=1..nops(W))]; 
IIc:=GeneralComplementList(II,DD);
if IIc=[] then output:=1; 
else P:=matrix([seq(W[IIc[i]],i=1..nops(IIc))]);
  M:=transpose(matrix(P));
   H:=ihermite(M); 
   MM:=matrix([seq(row(H,i),i=1..nops(IIc))]);
 output:=det(MM);
fi;
 output;
end:
#relativevolumeoffaceIIc([[1,0],[0,1]],[1]); 
# The 2 functions to compute S_L
# Input: s a vector in R^d;  W a "Cone" in R^d; II a subset of [1, 2,...,d];
# x a variable:

# Output: a list of two functions of x;
# Math: #We compute integral over the cone IIc of 
# exp^(csi,x) ; the answer is given as [exp (<q,x>, product of linear forms]
# Representing separately the numerator and the denominator.
# Furthermore, we enter exp as a "black box" EXP(x); later on we might want to replace it.
# Example functionI([1/2,1/2],[[1,0],[0,1]],[],x) `invalid character in short integer encoding 17 `;;
# 
# 
functionI:=proc(s,W,II,x)
local s_on_IIc,DD,IIc,d,T,i,y,r,out;
d:=nops(W);
DD:=[seq(i,i=1..d)]; 
s_on_IIc:=s_IIc(s,W,II);
if nops(II)=nops(W) 
then out:=[1,1]; 
else
IIc:=GeneralComplementList(II,DD);
r:=relativevolumeoffaceIIc(W,II);
T:=1;
for i from 1 to nops(IIc) do 
y:=add(W[IIc[i]][j]*x[j],j=1..d);
T:=T*y;
od;
T:=(-1)^(nops(IIc))*T;
out:=[r*EXP(add(s_on_IIc[m]*x[m],m=1..d)),T];
fi; 
out;
end: 
# Input: z =[z1,...,zd], x=[x1,x2,..,xd];  two lists of symbolic expressions, W a cone in R^d.
# Output: a symbolic expression.
# Math: Our cone has generator w1,w2,...,wd. 
# We replace x by <x,w_i> and we compute  the product of Todd(z_i,<x,w_i>); 
# Example: prod_Todd([z1,z2],[x1,x2],[[1,1],[1,0]])->`invalid character in short integer encoding 17 `;;

# 
# 
prod_Todd:=proc(z,x,W) local d,E,i,T,y;
d:=nops(W);
ASSERT(d = nops(z) and d = nops(x),
       "z, x, W need to be of the same length");
T:=1;
for i from 1 to d do 
ASSERT(nops(W[i])=nops(x),"W[i], x need to be of the same length");
y:=add(W[i][j]*x[j],j=1..nops(W[i]));
T:=T*TODD(z[i],y);
od;
T;
end: 
# 
# Input: z =[z1,...,zd], x=[x1,x2,..,xd];  two lists of symbolic expression, W a cone in R^d.
# Output: a list of two symbolic expressions [P1,Q1].
# Math: P1 is the   product of Todd(z_i,<x,w_i>), while Q1 is  the product of the (<x,wi>) 
# Example: functionS([z[1],z[2],z[3]],[x[1],x[2],x[3]],[[1,1,0],[0,1,0],[0,0,1]]) ->
# `invalid character in short integer encoding 209 Ñ`;
# 
functionS:=proc(z,x,W) local P,Q,y,i;
P:=prod_Todd(z,x,W);
Q:=1;
for i from 1 to nops(W) do
ASSERT(nops(W[i])=nops(x),"W[i], x need to be of the same length");
 y:=add(W[i][j]*x[j],j=1..nops(W[i]));
 Q:=Q*y;
od;
[P,Q];
end: 
# 
# 
# Input: a Cone W;  II a subset of [1..d] of cardinal k; x a list [x1,x2,...,xd]:
# Output: a list of  k linear forms
#  Math: 
# We write R^d=V(II)+V(II_c). We computed a basis H1,H2n...H_k of the projection of the lattice Z^d in V(II).
# Thus the output is the list is <x,h_i> where H_i are the basis of the projected lattice  
# 
# Example: changeofcoordinates([[1,0,0],[0,1,0],[1,2,3]],[1,2],[x1,x2,x3])-> 202, "unexpected end of statement";;
# 
# 
# 

changeofcoordinates:=proc(W,II,x) local H,newx,i; 
H:=projectedlattice(W,II);
newx:=[];
for i from 1 to nops(H) do 
newx:=[op(newx),innerprod(x,H[i])];
od; 
newx;
end:
# THE FUNCTION S_L for a cone.
# THIS IS THE MAIN PROCEDURE. thue output is a function, and a product of linear forms;
function_SL:=proc(s,W,L,x) local DD,i,parallel_cones,uni_cones,function_on_II,function_on_IIc,WW_projected,WW,WWW,signuni,signL,j,II,IIc,out1,out2,s_in_cone_coord,s_II_in_cone_coord,s_prime_II,M,newx,dimL,g,testrank,newP,
s_II_in_lattice_coord,news;
DD:=[seq(i,i=1..nops(W))];
#I added this
if L=W then RETURN(functionI(s,W,[],x)[1]/functionI(s,W,[],x)[2]);fi;
#up to here
parallel_cones:=L_cone_dec(W,L);
out2:=0;
for i from 1 to nops(parallel_cones) do
WW:=parallel_cones[i][2];
signL:=parallel_cones[i][1];
IIc:=[];
II:=[];
dimL:=Rank(Matrix(L));
for g from 1 to nops(WW) do 
testrank:=Rank(Matrix([op(L),WW[g]])); 
if testrank=dimL 
  then IIc:=[op(IIc),g];
 else II:=[op(II),g];
fi:

od; 
ASSERT(nops(IIc)=dimL,"decompositioninL_parallel is wrong");
M:=Matrix([seq(Vector(WW[h]),h=1..nops(WW))]);
s_II_in_lattice_coord:=projectedvertexinbasislattice(WW,II,s);  
function_on_IIc:=functionI(s,WW,II,x);
#from here express in terms of the basis lattice for projected cone.

WW_projected:=projectedconeinbasislattice(WW,II):

if WW_projected=[] then 
out1:=1 else
newx:=changeofcoordinates(WW,II,x);
uni_cones:=cone_dec(WW_projected):
out1:=0;
for j from 1 to nops(uni_cones) do 
WWW:=uni_cones[j][3];
signuni:=uni_cones[j][1];
ASSERT(abs(uni_cones[j][2])=1, "decomposition not unimodular");
newP:=MatrixInverse(Transpose(Matrix(WWW))):
news:=convert(Multiply(newP,Vector(s_II_in_lattice_coord)),list);
s_prime_II:=[seq(ceil(news[f]),f=1..nops(news))];
function_on_II:=functionS(s_prime_II,newx,WWW);
out1:=out1+
signuni*function_on_II[1]/function_on_II[2];
od:
fi;
out2:=out2+out1*function_on_IIc[1]/function_on_IIc[2]*signL;
od:
out2;
end:


#function_SL([1/2,0,0],[[-1,0,1],[-1,2,0],[0,0,1]],[[-1,2,0]],[x1,x2,x3]);
# Input: W a cone, L a linear space,x a variable.
# Output: a list of linear forms.
#  Math: this is  the forms in denominator of the big func.
linindenom:=proc(W,L,x) local YY,i,
parallel_cones,VDD,IIc,II,dimL,g,testrank,WW,newx,d,a,z,cc,
WW_projected,uni_cones,t,cleanYY,r;
VDD:=[seq(i,i=1..nops(W))];
d:=nops(W);
parallel_cones:=L_cone_dec(W,L);
 YY:={};
for i from 1 to nops(parallel_cones) do
WW:=parallel_cones[i][2];# We should know I, II
IIc:=[];
II:=[];
dimL:=Rank(Matrix(L));
for g from 1 to nops(WW) do 
testrank:=Rank(Matrix([op(L),WW[g]])); 
if testrank=dimL 
  then IIc:=[op(IIc),g];
 else II:=[op(II),g];
fi:
od; 
ASSERT(nops(IIc)=dimL,"decompositioninL_parallel is wrong");
for a from 1 to nops(IIc) do
YY:={op(YY),add(WW[IIc[a]][j]*x[j],j=1..d)};
od;
 WW_projected:=projectedconeinbasislattice(WW,II):
newx:=changeofcoordinates(WW,II,x); 
##print("newx,WW_projected",newx,WW_projected);
uni_cones:=cone_dec(WW_projected):
##print("i,unicones,newx",i,uni_cones,newx,YY);
for z from 1 to nops(uni_cones) do
cc:=uni_cones[z][3]; 
for t from 1 to nops(cc) do
YY:={op(YY), add(cc[t][s]*newx[s],s=1..nops(newx))}
od;
od;
od;
##print(YY);
cleanYY:={};
for r from 1 to nops(YY) do
if member(-YY[r],cleanYY)=false then
cleanYY:={op(cleanYY),YY[r]}
fi;
od;
cleanYY;
end:


#function_SL([0,0,0],[[1,0,0],[0,2,1],[0,0,1]],[[1,1,1]],[x1,x2,x3]);
# The Valuation S_L for a simplex.
function_SL_simplex:=proc(S,L,x) local F,W,i;
F:=0;
for i from 1 to nops(S) do 
W:=[seq(primitive_vector(S[j]-S[i]),j=1..i-1),seq(primitive_vector(S[j]-S[i]),j=i+1..nops(S))];
F:=F+function_SL(S[i],W,L,x);
od:
F:
end:
# 
#betedim1:=subs({TODD=Todd,EXP=exp},function_SL_simplex([[0],[1]],[],[x1]));
#Sbete2:=[[0,0+2/10],[1,2/10],[0,2+2/10]]; 
#check2:=subs({TODD=Todd,EXP=exp},function_SL_simplex(Sbete2,[[1,0]],[x1,x2]));
#series(subs({x1=t,x2=2*t},check2),t=0);
#SA:=[[0,0],[0,4/10],[1,1]]; SB:=[[0,4/10],[1,1],[1,1+4/10]];

#check3:=subs({TODD=Todd,EXP=exp},function_SL_simplex([[0,0,0],[2,0,0],[0,2,0],[0,0,2]],[[1,0,0],[0,1,0]],[x1,x2,x3]));
#SERT:=subs({x1=t,x2=5*t,x3=17*t},check3);
#series(SERT,t=0,20);
# Regular vector

# Input, t a variable, alpha= a list of length k of  linear forms l_i of  x1,x2,...,x_n,
#   n a number ; 
# The output is a vector v such that  l_i(v) is not zero for all i
# 

# 
regular:=proc(t,alpha,n) local ok,p,i,pp,v,j,s,deg,newP,P,PP,out:
ok:=0;
P:=1;
for i from 1 to nops(alpha) do
P:=P*alpha[i];
od;

v:=[seq(t^i,i=0..n-1)];
for j from 1 to n
do P:=subs(x[j]=t^(j-1),P);
od:
deg:=degree(P);
s:=1; while ok=0 and s<=deg+1 do
newP:=subs(t=s,P); ##print(newP);
if newP<>0 
then out:=[v,s,subs(t=s,v)];
ok:=1;
else s:=s+1;
fi;
od:
out[3];
end:
regular(t,{-x[1],-x[1]+x[2]},2);


denomWL:=proc(W,L) local xx,alpha;
xx:=[seq(x[i],i=1..nops(W))];
alpha:=linindenom(W,L,xx); #print("alpha",alpha);
 end:

#denomWL([[1,-1,0],[0,2,1],[0,0,1]],[[1,1,1]]);

#Sbete2:=[[0,0],[1,0],[0,1]];
# DEFORMATION OF FUNCTION S_L
# 

# The input is a  s a vertex,W a cone, L a linear space , ell a list with numeric coefficients.
# The output is a function of delta, epsilon;
defSLell:=proc(s,W,L,ell,reg) local xx,defell,ff;
#reg:=regularWL(W,L); #print("reg",reg);
xx:=[seq(x[i],i=1..nops(W))];
defell:=[seq(delta*(ell[j]+epsilon*reg[j]),j=1..nops(W))];
ff:=function_SL(s,W,L,defell);
##print(ff,defell);
ff:=eval(subs({TODD=Todd,EXP=exp},ff));
ff;
end:
#series(SLell([1/2,1/2],[[1,0],[1,2]],[[1,1]], [1,-1]),delta=0,3);
#function_SL([1/2,1/2],[[1,0],[0,1]],[[1,-1]], [x1,x2]);
deftruncatedSL:=proc(s,W,L,ell,reg,M) local SS,cc;
#SS:=subs({epsilon=0},SLell(s,W,L,ell,reg)); #print(SLell(s,W,L,ell));
##print("SS",SS);
##print(series(SS,delta=0,M+nops(W)+2));
cc:=convert(series(defSLell(s,W,L,ell,reg),delta=0,M+nops(W)+2),polynom);
coeff(series(cc,epsilon=0,nops(W)+2),epsilon,0);
 
end:

#deftruncatedSL([1/2,1/2],[[1,0],[1,2]],[[1,1]],[1,1],[3,7],4);
# The function S_L for a simplex.
# 
regularSL:=proc(S,L) local i,W,reg,xx,alpha;
xx:=[seq(x[i],i=1..nops(S)-1)];
alpha:={};
for i from 1 to nops(S) do 
W:=[seq(primitive_vector(S[j]-S[i]),j=1..i-1),seq(primitive_vector(S[j]-S[i]),j=i+1..nops(S))];
alpha:={op(alpha),op(denomWL(W,L,xx))};
od:

reg:=regular(t,alpha,nops(S)-1);
end:
function_SL_simplex_ell:=proc(S,L,ell,M) local reg,F,W,i;
F:=0;
reg:=regularSL(S,L);
for i from 1 to nops(S) do 
W:=[seq(primitive_vector(S[j]-S[i]),j=1..i-1),seq(primitive_vector(S[j]-S[i]),j=i+1..nops(S))];
F:=F+deftruncatedSL(S[i],W,L,ell,reg,M);
od:
coeff(F,delta,M):
end:
#function_SL_simplex_ell(Sbete2,[[1,0]],[0,0],0);Sbete2;
Sbetedilated:=proc(n,t) local ze, S,j,zej; ze:=[seq(0,i=1..n)];
S:=[ze];
for j from 1 to n do zej:=subsop(j=t,ze);;
 S:=[op(S),zej];
od;
end:
#Sbetedilated(3,2);
#function_SL_simplex_ell(Sbetedilated(2,2),[[1,2]],[0,0],0);
#S1:=[[0,0],[1,0],[1,2]];
#function_SL_simplex_ell(S1,[[1,0]],[1,1],1);

#  Dilated polytope
# 
# 
# We have to compute S_L(t,s,W,L,x); 

# 
fmod:=proc(p,q,t) local u: 
u:=modp(p,q);
#print(u);
ModP(u*t,q);
end:
ourmod:=proc(p,q,t) local our,T;
if q=1 then our:=0;
elif type(t,integer) then our:=modp(t*p,q);
else our:=fmod(p,q,t);
fi;
RETURN(our);
end:
ourfloor:=proc(t,x)local our,p,q;
p:=numer(x);
q:=denom(x);
our:=t*x-ourmod(p,q,t)/q;
end:
formal_ceil:=proc(t,x);
-ourfloor(t,-x);
end:
#formal_ceil(t,3/2);
tfunction_SL:=proc(t,s,W,L,x) local st,DD,i,parallel_cones,uni_cones,function_on_II,function_on_IIc,WW_projected,WW,WWW,signuni,signL,j,II,IIc,out1,out2,s_in_cone_coord,s_II_in_cone_coord,s_prime_II,M,newx,dimL,g,testrank,newP,
s_II_in_lattice_coord,news;
DD:=[seq(i,i=1..nops(W))];
parallel_cones:=L_cone_dec(W,L):
##print("parallel_cones",parallel_cones);
out2:=0; #listgene:={};
for i from 1 to nops(parallel_cones) do
WW:=parallel_cones[i][2];
signL:=parallel_cones[i][1];
IIc:=[];
II:=[];
dimL:=Rank(Matrix(L));
for g from 1 to nops(WW) do 
testrank:=Rank(Matrix([op(L),WW[g]])); 
if testrank=dimL 
  then IIc:=[op(IIc),g];
 else II:=[op(II),g];
fi:

od; 
ASSERT(nops(IIc)=dimL,"decompositioninL_parallel is wrong");
M:=Matrix([seq(Vector(WW[h]),h=1..nops(WW))]);
s_II_in_lattice_coord:=projectedvertexinbasislattice(WW,II,s);
st:=[seq(t*s[i],i=1..nops(s))];  
function_on_IIc:=functionI(st,WW,II,x);
#print("functionInt",function_on_IIc);
#from here express in terms of the basis lattice for projected cone.

WW_projected:=projectedconeinbasislattice(WW,II):

if WW_projected=[] then 
out1:=1 else
newx:=changeofcoordinates(WW,II,x); 
##print("newx",newx);
uni_cones:=cone_dec(WW_projected):
##print("unicones",WW,uni_cones);
out1:=0;
for j from 1 to nops(uni_cones) do 
WWW:=uni_cones[j][3];
signuni:=uni_cones[j][1];
ASSERT(abs(uni_cones[j][2])=1, "decomposition not unimodular");
newP:=MatrixInverse(Transpose(Matrix(WWW))):
news:=convert(Multiply(newP,Vector(s_II_in_lattice_coord)),list);
s_prime_II:=[seq(formal_ceil(t,news[f]),f=1..nops(news))];
function_on_II:=functionS(s_prime_II,newx,WWW):
##print("function_on_II",function_on_II);
out1:=out1+
signuni*function_on_II[1]/function_on_II[2];
od:
fi;
out2:=out2+out1*function_on_IIc[1]/function_on_IIc[2]*signL;
od:
out2;
end:


#tfunction_SL(t,[1/2,1,1],[[-1,0,1],[-1,2,0],[0,0,1]],[[-1,2,0]],[x1,x2,x3]);
# Input: W a cone, L a linear space,x a variable.
# Output: a list of linear forms.
tfunction_SL(t,[1/2,1/2],[[0,1],[1,0]],[[1,0]],[x1,x2]);
tSLell:=proc(t,s,W,L,ell,reg) local xx,defell,ff;
#reg:=regularWL(W,L); #print("reg",reg);
xx:=[seq(x[i],i=1..nops(W))];
defell:=[seq(delta*(ell[j]+epsilon*reg[j]),j=1..nops(W))];
ff:=tfunction_SL(t,s,W,L,defell);
##print(ff,defell);
ff:=eval(subs({TODD=Todd,EXP=exp},ff));
ff;
end:
#series(SLell([1/2,1/2],[[1,0],[1,2]],[[1,1]], [1,-1]),delta=0,3);
#function_SL([1/2,1/2],[[1,0],[0,1]],[[1,-1]], [x1,x2]);
ttruncatedSL:=proc(t,s,W,L,ell,reg,M) local SS,cc;
#SS:=subs({epsilon=0},tSLell(t,s,W,L,ell)); #print(SLell(s,W,L,ell));
##print("SS",SS);
##print(series(SS,delta=0,M+nops(W)+2));
cc:=convert(series(tSLell(t,s,W,L,ell,reg),delta=0,M+nops(W)+2),polynom);
coeff(series(cc,epsilon=0,nops(W)+2),epsilon,0);
 
end:
#truncatedSL([1/2,1/2],[[1,0],[1,2]],[[1,1]],[1,1],4);

#simplify(ttruncatedSL(t,[1/2,1/2],[[1,0],[0,1]],[[1,0]],[1,1],0));
tfunction_SL_simplex_ell:=proc(t,S,L,ell,M) local F,W,i,reg;
F:=0;
reg:=regularSL(S,L);
for i from 1 to nops(S) do 
W:=[seq(primitive_vector(S[j]-S[i]),j=1..i-1),seq(primitive_vector(S[j]-S[i]),j=i+1..nops(S))];
F:=F+ttruncatedSL(t,S[i],W,L,ell,reg,M);
od:
simplify(coeff(F,delta,M)):
end:
#tfunction_SL_simplex_ell(t,S1,[[1,0]],[0,0],0);
checks:=proc(u);
[function_SL_simplex_ell([[0, 0], [u, 0], [u, 2*u]],[[1,0]],[1,1],1),
subs(t=u,tfunction_SL_simplex_ell(t,S1,[[1,0]],[1,1],1))];end:


dilS1:=proc(r); [[0, 0], [r, 0], [r, 2*r]];end:

# Above is the special sum of a 
#Srat2:=[[0, 0], [1/7*5/4, 0], [1/7*5/4, 1/7*5/2]];
checksrat:=proc(u);
[function_SL_simplex_ell([[0, 0], [u*5/28, 0], [u*5/28, 5/14*u]],[[1,0]],[1,1],1),
subs(t=u,tfunction_SL_simplex_ell(t,Srat2,[[1,0]],[1,1],1))];end:





# rho function and approximations

