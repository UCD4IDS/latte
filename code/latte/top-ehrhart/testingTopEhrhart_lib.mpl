with(linalg):
with(LinearAlgebra):
with(numapprox,laurent):
read("TopEhrhart_lib.mpl"); #load the ehrhart functions

#Input: simplexDim: the amb. dim of the simplex.
#Output: returns a list of simplexDim+1 vectors in R^(simplexDim).
create_random_simplex:=proc(simplexDim)
	local i, j, M, checkRankMatrix:

	do
		M:=randmatrix(simplexDim+1, simplexDim); #default is  rand(-99..99).
		# if you want different matrices, try randmatrix(simplexDim+1, simplexDim, entries=rand(0..10))

		checkRankMatrix:=randmatrix(simplexDim, simplexDim);
		for i from 1 to simplexDim do
			for j from 1 to simplexDim do
				checkRankMatrix[i, j] := M[i, j] - M[simplexDim+1, j];
			od;
		od;
		#print("got here");
		#print(checkRankMatrix, "=checkRandMatrix");

		#print(rank(checkRankMatrix), checkRankMatrix, simplexDim, rank(checkRankMatrix) = simplexDim);
		if rank(checkRankMatrix) = simplexDim then:
			break;
		fi;
	end do;
	#print(M, "=M");

	return(convert(M, listlist));
end:

#Input: n+1 points in R^n
#Output: the facet equations that define the simplex of the n+1 points.
simplex_to_hyperplanes:=proc(simplex)
local i, b_ax, equations, n_points;

	equations:= [];
	for i from 1 to nops(simplex) do:
		n_points:= subsop(i = NULL, simplex);
		b_ax:= facets_equation(n_points, simplex[i]); # 0 < b - a*x
		equations:=[ op(b_ax), op(equations)];
	od;
	return(equations);
end:

#Input:facet equations in maple syntax.
#Output: Writes to file fileName the latte-style facet equations.
write_facets_to_file:=proc(equations, fileName, simplexDim)
	local i, j, filePtr, lcmDenom, M:

	filePtr:=fopen(fileName, WRITE, TEXT);

	#print(equations, "=equations");
	#print(fileName, "=fileName");



	#sorry, I had to do a bunch of converting because I couldn't pull the elements in the original structure.
	M:=convert(equations, Matrix);
	#print(M, "=M1");
	M:=convert(M, list);
	#print(M, "=M3");
	#print(simplexDim, "=simplexDim");
	M:=matrix(simplexDim+1, simplexDim+1, M);
	#print(M, "=M2");
	#print(M[1], "=M2[1,1]");

	#write the latte file.
	fprintf(filePtr,"%d %d\n", simplexDim+1, simplexDim+1);
	for i from 1 to simplexDim+1 do:
		lcmDenom:=1;

		for j from 1 to simplexDim+1 do:
			lcmDenom:=lcm(lcmDenom, denom(M[i, j]));
		od:

		for j from 1 to simplexDim+1 do:
			#print(M[i, j], "M[i, j]");
			fprintf(filePtr, "%d ", M[i, j]*lcmDenom);
		od:
		fprintf(filePtr, "\n");
	od:
	close(filePtr);
end:

#input:filename and list of simplices
#output: writes each simplex to a new line of the file in maple syntax.
write_simplex_to_file:=proc(simplexList, fileName)
	local filePtr, i:
	filePtr:=fopen(fileName,WRITE,TEXT):

	for i from 1 to nops(simplexList) do:
		writeline(filePtr, convert(simplexList[i], string));
	od;
	close(filePtr);
end:

#Input:List of n points of a simplex and the last point.
#Output: the Facet of the equation containing the n points with the sign such that the last point is in the halfspace.
#Description: Feeding the n points of a n-simplex and the 1 point that
# is not in their facet it generates ONE equation of the simplex in LattE format
#for those points.
facets_equation:=proc(L,notinL)
	local x,aux1,aux2,M,i;
	M:=Matrix([op(1,L)]);
	for i from 2 to nops(L) do
		M:=stackmatrix(M,op(i,L));
	od:
	M:=stackmatrix(M,[x[j] $j=1..nops(L)]);
	M:=transpose(M);
	M:=stackmatrix(M,[1 $j=1..nops(L)+1]);
	aux1:=det(M):
	for i from 1 to nops(notinL) do
		aux1:=subs(x[i]=op(i,notinL),aux1):
	od;
	#print(sign(aux1),"hi I am here");
	aux2:=sign(aux1)*det(M);
	for i from 1 to nops(notinL) do
		aux2:=subs(x[i]=0,aux2):
	od;
	return(genmatrix({aux2*x[0]+sign(aux1)*det(M)},[x[j] $j=0..nops(L)]));
end:

#input:filename and list of simplices
#output: writes each simplex to a new line of the file in maple syntax.
write_simplex_to_file:=proc(simplexList, fileName)
	local filePtr, i:
	filePtr:=fopen(fileName,WRITE,TEXT):

	for i from 1 to nops(simplexList) do:
		writeline(filePtr, convert(simplexList[i], string));
	od;
	close(filePtr);
end:


#Makes a random simplex, saves it to a file, and calls both top ehrhart functions.
#This function is useful if you want to make sure both functions are returning the same answers.
test_top_ehrhart_compare_v1_v2:=proc(mydim, myfilename)
	local myi, myCC:=[], mysimplex, myfileName, startTime, totalTime, version1, version2:
	randomize():
	mysimplex:=create_random_simplex(mydim):
	myfileName:=myfilename:
	write_simplex_to_file(mysimplex,cat(myfileName,".simp")):
	write_facets_to_file(simplex_to_hyperplanes(mysimplex),cat(myfileName,".latte"),mydim):

	version1:= test_top_ehrhart_given_simplex_v1(mysimplex);
	version2:= test_top_ehrhart_given_simplex_v2(mysimplex);
	return [version1, version2];
end:

#Makes a random simplex, saves it to a file, and calls the original (version 1) TopEhrhart functions.
test_top_ehrhart_v1:=proc(mydim, myfilename)
	local myi, myCC:=[], mysimplex, myfileName, startTime, totalTime, version1:
	randomize():
	mysimplex:=create_random_simplex(mydim):
	myfileName:=myfilename:
	write_simplex_to_file(mysimplex,cat(myfileName,".simp")):
	write_facets_to_file(simplex_to_hyperplanes(mysimplex),cat(myfileName,".latte"),mydim):

	version1:= test_top_ehrhart_given_simplex_v1(mysimplex);
	return version1;

	#CheckSou(5);
end:


#Makes a random simplex, saves it to a file, and calls the new (version 1) TopEhrhart functions.
test_top_ehrhart_v2:=proc(mydim, myfilename)
	local myi, myCC:=[], mysimplex, myfileName, startTime, totalTime, version2:
	randomize():
	mysimplex:=create_random_simplex(mydim):
	myfileName:=myfilename:
	write_simplex_to_file(mysimplex,cat(myfileName,".simp")):
	write_facets_to_file(simplex_to_hyperplanes(mysimplex),cat(myfileName,".latte"),mydim):

	version2:= test_top_ehrhart_given_simplex_v2(mysimplex);
	return version2;
end:

#Makes a random simplex, saves it to a file, and calls the new (version 1) TopEhrhart functions.
test_top_ehrhart_v3:=proc(mydim, myfilename)
	local myi, myCC:=[], mysimplex, myfileName, startTime, totalTime, version3:
	randomize():
	mysimplex:=create_random_simplex(mydim):
	myfileName:=myfilename:
	write_simplex_to_file(mysimplex,cat(myfileName,".simp")):
	write_facets_to_file(simplex_to_hyperplanes(mysimplex),cat(myfileName,".latte"),mydim):

	version3:= test_top_ehrhart_given_simplex_v3(mysimplex);
	return version3;
end:



#Tests top-ehrhart functions
#These are the original functions we received before Oct 2010.
test_top_ehrhart_given_simplex_v1:=proc(mysimplex)
	local myi, myCC:=[], startTime, totalTime:

	startTime:=time();


	for myi from 0 to 2 do:
		myCC:=[op(myCC),[coeff_dminusk_Eh(mysimplex,myi)]]:
	od:

	totalTime:= time() - startTime;
	return([totalTime, myCC]);
	#CheckSou(5);
end:

#Tests top-ehrhart functions
#These are the new functions we received on Oct 2010.
test_top_ehrhart_given_simplex_v2:=proc(mysimplex)
	local startTime, myCC, totalTime;

	startTime:=time();
	myCC:=Topk_Eh(mysimplex,2,t);
	totalTime:= time() - startTime;
	return([totalTime, myCC]);
end:

### This is for the "Conebyconeapproximations_08_11_2010" version
test_top_ehrhart_given_simplex_v3:=proc(mysimplex)
	local startTime, myCC, totalTime, dim;

	startTime:=time();
    dim := nops(mysimplex)-1;
	myCC:=TopEhrhartweightedPoly(n, mysimplex, [seq(0,i=1..dim)], 0, 2);
	totalTime:= time() - startTime;
	return([totalTime, myCC]);
end:



print("testSLEhrhar.file ok");
