read("valuation/valuationTestsLib.mpl"):


#	integrateHyperrectangle.mpl
#   Created on: July 22, 2010
#      Author: Brandon Dutra and Gregory Pinto
$
# This maple scripts is a driver for test_hyperrectangle_integtation
# many times, which is defined in valuationTestsLib.mpl.
#
# test_hyperrectangle_integtation() makes a n-dim hyper-rectangle,
# and a random polynomial. We compute the integral of the
# polynomial over the polytope in maple and in the PolytopeValuation
# class, and compare for any differences. 
#
# Note that we assume polynomial dimension = dimension of the polytope.

printf("Testing integration of hyper-rectangles...\n"):

myDim, myDegree, fileName, totalErrors, returnStatus, seed:

totalErrors:= 0:
 
seed := randomize():
printf("random seed = %d \n", seed):


fileName:="valuation/hyerrectangleIntegrationTest.latte":
for myDim from 2 to 8 do
	for myDegree from 2 to 20 do
	
		printf("Testing polynomials of dimension %d, and at most degree %d\n", myDim, myDegree);
  
#                   the parameters are:  polyMaxDegree, polytopeDimension, maxNumberOfTermsPerDegree, integrationLimit, fileName)    
    	returnStatus:=test_hyperrectangle_integtation(myDegree, myDim, 10, 30000, fileName):
   
		if ( not(returnStatus = 0)) then 
			totalErrors:= totalErrors + 1; 
		end if:
	
		#this if could be commented out if you want.
		if (totalErrors > 0) then
			printf("Total Errors: %d", totalErrors):
    		quit:
    	end if:
	od:
od:
 

printf("%d total errors.\n", totalErrors):
printf("random seed = %d \n", seed):
 
