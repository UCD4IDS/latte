#ifndef INTEGRATIONDB_H
#define INTEGRATIONDB_H

/**
 * This database class assumes there is a database with the schema defined
 * as in the "createScript.sqlite" file in the current directory.
 */


#include "SqliteDB.h"
#include "../rational.h"
#include "ValuationDBStatistics.h"

using namespace std;
//A B C D E F G H I J K L M N O P Q R S T U V W X Y Z


#define LAWRECE_INTEGRATE_VERSION 1

class IntegrationDB: public SqliteDB
{
private:
	void makeMoreIntegrationTests(int dim, int degree, int vertexCount, bool useDual, int requestedCount, int existingCount);
	void makeMoreIntegrationTests(int polytopeID, int dim, int degree, int requestedCount, int existingCount);
	vector<vector<string> > getUnusedPolynomials(int dim, int degree, int vertexCount, bool useDual);
	vector<vector<string> > getUnusedPolynomials(int dim, int degree, int polytopeID);
	vector<vector<string> > getUnusedPolytopes(int dim, int degree, int vertexCount, bool useDual);

	void getStatistics(const vector<double> &data, double &avg, double &min, double &max, double &sd, int &totalFinished, int &totalExist, bool &manuallyLimited); //given an array of double's, computes the average, min, max, etc.

public:
	enum AlgorithemUsed {Lawrence, Triangulate};
	IntegrationDB();

	bool canTestFinish(AlgorithemUsed alg, int dim, int vertex, int degree, bool useDual, int seconds);
	bool canSpecficFileFinish(AlgorithemUsed alg, const char *polymakeFile, int degree, int useDual, int secondsLimit);

	void deletePolynomial(int id);
	int doesPolynomialExist(const char * p);
	int doesPolytopeExist(const char *polymake);

	vector<vector<string> > getAllPolymakeFiles();
	bool getLimit(AlgorithemUsed alg, int dim, int vertexCount, int degree, bool useDual);
	bool getLimitByFile(AlgorithemUsed alg, const string &polymakeFile, int degree, bool useDual);
	int getNumberPolynomials(int dim, int degree);
	int getNumberPolytopes(int dim, int vertexCount, bool useDuals);
	int getNumberIntegrationTest(int dim, int vertexCount, int degree, bool useDuals);
	int getNumberIntegrationTest(int polytopeID, int degree);
	int getNumberIntegrationTest(const string &polymakeFile, int degree, bool useDual);


	vector<vector<string> > getRowsToIntegrate(int dim, int vertex, int degree, bool useDual, int limit);
	vector<vector<string> > getRowsToIntegrateGivenSpecficFile(char *polymakeFile, int degree, bool useDual, int limit);

	vector<vector<ValuationDBStatistics> > getStatisticsByDim(int dim, bool useDual);
	vector<vector<ValuationDBStatistics> > getStatisticsByFile(const vector<vector<string> > &polymakeFile, bool useDual);
	ValuationDBStatistics getStatisticsByDimVertexDegree(int dim, int vertexCount, int degree, bool useDual);
	ValuationDBStatistics getStatisticsByFileDegree(const string & polymakeFile, int degree, bool useDual);
	vector<double> getStatisticsAvgMinMaxCount(AlgorithemUsed alg, int dim, int vertexCount, int degree, bool useDual);
	double getStdDeviation(AlgorithemUsed alg, int dim, int vertexCount, int degree, bool useDual); //gets the standard deviation (sqlite does not have this function build in).
	vector<double> getStatisticsAvgMinMaxCount(AlgorithemUsed alg, const string &polymakeFile, int degree, bool useDual);

	void insertEmptyIntegrationTest(const char* polynomialPath, int dim, int degree,
											const char* polytopePath, const char* polymakePath, int vertexCount, int simple,
											const char* dualPolytopePath, const char* dualPolymakePath, int dualVertexCount, int dualSimple);

	int insertIntegrationTest(int polynomialID, int polytopeID);
	void insertIntegrationTest(int dim, int degree, int vertexCount, int count);
	void insertSpecficPolytopeIntegrationTest(string polymakeFile, int degree, int count);
        int insertPolynomial(int dim, int degree, const char*filePath);

	int insertPolytope(int dim, int vertexCount, int simple, int dualRowID, const char* latteFilePath, const char* polymakeFilePath);

	//Here, we pick the polynomial to test on from what is in the database.
	int insertPolytopeAndPickIntegrationTest(int dim, int vertexCount,     int simple    , const char * latteFile    , const char * polymakeFile
													, int dualVertexCount, int dualSimple, const char * dualLatteFile, const char * dualPolymakeFile);

	int testCasesCompleted(AlgorithemUsed alg, int dim, int vertexCount, int degree, bool useDual);

	void updateIntegrationTimeAndValue(AlgorithemUsed alg, double time, RationalNTL currentValue, string previousValueStr,  string rowid);

};









#endif



