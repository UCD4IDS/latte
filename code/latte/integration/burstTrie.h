/*
Defines the BurstTrie class, used for storing monomials and powers of linear forms, as well as iterators over them
*/

#ifndef BURSTTRIE_H
#define BURSTTRIE_H

#define BURST_MAX 2
#include <NTL/ZZ.h>
#include <NTL/vec_ZZ.h>
#include <stdio.h>
#include <sstream>
#include <assert.h>

#define BT_DEBUG 1

NTL_CLIENT

template <class T, class S> class BurstTrie;
template <class T, class S> class BTrieIterator;

//Generic struct used by base iterator
template <class T, class S>
struct term
{
	T coef;
	S* exps;
	int length;
	int degree;
};

//abstraction used in burst tries to allow tries to contain either tries or terms as children
struct trieElem
{
    bool isTrie;
    void* myVal;
    
    trieElem* next;
};

template <class T, class S>
class BurstTerm
{
public:
    BurstTerm(int myLength)
    {
        length = myLength;
	exps = new S[length];
    }
    
    BurstTerm(const T& newCoef, S* newExps, int start, int myLength, int myDegree)
    {
        degree = myDegree;
        length = myLength - start;
        exps = new S[length];
        for (int i = start; i < myLength; i++)
	{ exps[i - start] = newExps[i]; }
        coef = newCoef;
        next = NULL;
    }
    
    ~BurstTerm()
    {
	//cout << "Destroying term" << endl;
        if (length > 0 && exps)
        { delete [] exps; }
    }
    
    bool lessThan(BurstTerm<T, S>* other, bool &equal)
    {
        equal = false;
	if (degree < other->degree) { return true; }
	if (degree > other->degree) { return false; }
        for (int i = 0; i < length && i < other->length; i++)
        {
	    //cout << "Comparing " << exps[i] << " v. " << other->exps[i] << endl;
            if (exps[i] < other->exps[i]) { return true; }
            if (exps[i] > other->exps[i]) { return false; }
        }
	assert (length == other->length);
	/*
	 * too general, shouldn't be encountered
        if (length < other->length) { return true; }
        if (length > other->length) { return false; }
	*/
        equal = true;
        return false;
    }
    
    BurstTerm<T, S>* next;
    
    T coef;
    S* exps;
    int length;
    int degree;
};

template <class T, class S>
class BurstContainer
{
public:
    BurstContainer()
    {
	//cout << "New container" << endl;
        firstTerm = NULL;
        termCount = 0;
    }
    
    ~BurstContainer()
    {
	//cout << "Destroying container (" << termCount << " terms) ..." << endl;
        BurstTerm<T, S> *temp, *old;
        temp = firstTerm;
        for (int i = 0; i < termCount; i++)
        {
            old = temp->next;
            delete temp;
            temp = old;
        }
    }
    
    void insertTerm(const T& newCoef, S* newExps, int start, int myLength, int myDegree)
    {
	//cout << "Inserting term into container" << endl;
        if (firstTerm == NULL)
        {
            firstTerm = new BurstTerm<T, S>(newCoef, newExps, start, myLength, myDegree);
            termCount++;
            return;
        }
        
	bool equal;
        BurstTerm<T, S>* newTerm = new BurstTerm<T, S>(newCoef, newExps, start, myLength, myDegree);
        if (newTerm->lessThan(firstTerm, equal))
        {
            newTerm->next = firstTerm;
            firstTerm = newTerm;
            termCount++;
            return;
        }
	if (equal)
        {
            firstTerm->coef += newTerm->coef;
            delete newTerm;
            return;
        }
        
        BurstTerm<T, S> *curTerm = firstTerm;
        BurstTerm<T, S> *oldTerm;
        
        while(curTerm && curTerm->lessThan(newTerm, equal))
        {
            oldTerm = curTerm;
            curTerm = curTerm->next;
        }
	if (equal)
        {
            curTerm->coef += newTerm->coef;
            delete newTerm;
            return;
        }
        
        if (curTerm == NULL) 
        {
            oldTerm->next = newTerm;
        }
        else //oldTerm < newTerm < curTerm
        {
            oldTerm->next = newTerm;
            newTerm->next = curTerm;
        }
        termCount++;        
    }
    
    BurstTrie<T, S>* burst()
    {
        BurstTrie<T, S>* myTrie = new BurstTrie<T, S>();
        BurstTerm<T, S>* curTerm = firstTerm;
        BurstTerm<T, S>* oldTerm;
        for (int i = 0; i < termCount; i++)
        {
            myTrie->insertTerm(curTerm->coef, curTerm->exps, 0, curTerm->length, curTerm->degree);
            oldTerm = curTerm->next;
            curTerm = oldTerm;
        }
        return myTrie;
    }
    
    BurstTerm<T, S>* getTerm(int index)
    {
        assert(index < termCount);
        BurstTerm<T, S>* myTerm = firstTerm;
        for (int i = 0; i < index; i++)
        {  myTerm = myTerm->next; }
        return myTerm;
    }
    
    int termCount;
    friend class BTrieIterator<T, S>;
private:
    BurstTerm<T, S>* firstTerm;
};

template <class T, class S>
class BurstTrie
{
public:
    BurstTrie()
    {
        //curIndex = -1;
        range = NULL;
        firstElem = NULL;
    }
    
    ~BurstTrie()
    {
	//cout << "Destroying trie" << endl;
        if (range)
        {
            trieElem *temp = firstElem;
            trieElem *old;
	     while (temp != NULL)
            {
		//cout << "Destroying trie element.." << endl;
                //destroy element container or trie
                if (temp->isTrie)
                {
                    delete (BurstTrie<T, S>*)temp->myVal;
                }
                else
                {
                    delete (BurstContainer<T, S>*)temp->myVal;
                }
                old = temp->next;
                //destroy trieElem
                free(temp); 
                temp = old;
            }
            delete [] range;
        }
    }
    
    void insertTerm(const T& newCoef, S* newExps, int start, int myLength, int myDegree)
    {
        assert(myLength > 0);
	/*cout << "Inserting term into trie: " << newCoef;
	for (int i = start; i < myLength; i++)
	{
	    cout << ", " << newExps[i];
	}
	cout << endl;*/
        if (range == NULL)
        {
            range = new S[2];
            range[0] = range[1] = newExps[0];
            firstElem = (trieElem*)malloc(sizeof(trieElem));
            firstElem->next = NULL;
            firstElem->myVal = new BurstContainer<T, S>();
            firstElem->isTrie = false;
        }
        else
        {
            checkRange(newExps[start]);
        }
        
        trieElem *curElem = firstElem;
        for (S i = range[0]; i < newExps[start]; i++)
        { curElem = curElem->next; }
        
        if (curElem->isTrie)
        {
            ((BurstTrie<T, S>*)curElem->myVal)->insertTerm(newCoef, newExps, start + 1, myLength, myDegree);
        }
        else
        {
	    BurstContainer<T, S>* temp = (BurstContainer<T, S>*)curElem->myVal;
	    //cout << "Trie element is a container (" << temp->termCount << " elements)" << endl;
            if (temp->termCount == BURST_MAX && myLength > 1)
            {
		//cout << "Bursting container..." << endl;
                BurstTrie<T, S>* newTrie = temp->burst();
		//cout << "Burst trie created, deleting container" << endl;
                delete temp;
                curElem->isTrie = true;
                curElem->myVal = newTrie;
                newTrie->insertTerm(newCoef, newExps, start + 1, myLength, myDegree);
            }
            else
            {
                temp->insertTerm(newCoef, newExps, start + 1,  myLength, myDegree);
            }
        }
    }
    
    void checkRange(const S& myVal)
    {
        if (myVal < range[0]) //new minimum
        {
	    trieElem *temp = (trieElem*)malloc(sizeof(trieElem)); //new first element for myVal
	    trieElem *old = temp;
            temp->next = NULL;
            temp->myVal = new BurstContainer<T, S>();
	    temp->isTrie = false;
            for (S i = myVal + 1; i < range[0]; i++)
            {
                //create new element
                temp->next = (trieElem*)malloc(sizeof(trieElem));
                //advance to it
                temp = temp->next;
                //set pointer
                temp->next = NULL;
                //allocate container
                temp->myVal = new BurstContainer<T, S>();
                temp->isTrie = false;
            }
            temp->next = firstElem;
            //set new first element
            firstElem = old;
            range[0] = myVal;
        }
        else if (myVal > range[1]) //new maximum
        {
            trieElem *temp = firstElem;
            for (S i = range[0]; i < range[1]; i++)
            { temp = temp->next; }
            for (S i = range[1]; i < myVal; i++)
            {
                temp->next = (trieElem*)malloc(sizeof(trieElem));
                temp = temp->next;
                temp->next = NULL;
                temp->myVal = new BurstContainer<T, S>();
                temp->isTrie = false;
            }
            range[1] = myVal;
        }
    }

    friend class BTrieIterator<T, S>;
private:
    S* range; //S can be a class or a primitve
    trieElem *firstElem; //first element in the trie
};

template <class T, class S>
class PolyIterator
{
public:
	virtual void begin() = 0;
	virtual term<T, S>* nextTerm() = 0;
	virtual term<T, S>* getTerm() = 0;
};

template <class T, class S>
class BTrieIterator : public PolyIterator<T, S>
{
public:
	BTrieIterator()
	{

	}
	
	void setTrie(BurstTrie<T, S>* trie, int myDim)
	{
		assert (myDim > 0);
		myTrie = trie;
		dimension = myDim;
		triePath = new trieElem*[dimension];
		curTerm.exps = new S[dimension];
		curTerm.length = dimension;
	}
	
	void begin()
	{
		//cout << "Starting iteration" << endl;
		curDepth = -1;
		storedTerm = NULL;
	}
	
	BurstContainer<T, S>* nextContainer()
	{
		//cout << "Next container at depth " << curDepth << endl;
		trieElem* nextElem;
		if (curDepth < 0)
		{
			curDepth++;
			nextElem = triePath[0] = myTrie->firstElem;
			curTerm.exps[0] = myTrie->range[0];
			//cout << "!exp 0: " << curTerm.exps[0] << endl;
		}
		else
		{
			nextElem = triePath[curDepth]->next;
			curTerm.exps[curDepth]++;
			while (nextElem)
			{
				//cout << "exp " << curDepth << ": " << curTerm.exps[curDepth] << endl;
				if (nextElem->isTrie)
				{
					
					//cout << "trie found" << endl;
					break;
				}
				if (((BurstContainer<T, S>*)nextElem->myVal)->termCount > 0)
				{
					//cout << "container found - " << ((BurstContainer<T, S>*)nextElem->myVal)->termCount << endl;
					break;
				}
				//cout << "Skipping trie element " << curTerm.exps[curDepth] << endl;
				nextElem = nextElem->next;
				curTerm.exps[curDepth]++;
			}
			triePath[curDepth] = nextElem;
		}
		
		if (!nextElem) //end of trie, move back up
		{
			//cout << "end of trie at depth " << curDepth << endl;
			if (curDepth == 0) { return NULL; }
			curDepth--;
			return nextContainer();
		}
		
		return firstContainer(nextElem);
	}
	
	BurstContainer<T, S>* firstContainer(trieElem* myElem)
	{
		//cout << "Looking for container at depth " << curDepth << endl;
		if (myElem->isTrie)
		{
			curDepth++;
			triePath[curDepth] = ((BurstTrie<T, S>*)myElem->myVal)->firstElem;
			curTerm.exps[curDepth] = ((BurstTrie<T, S>*)myElem->myVal)->range[0];
			return firstContainer( ((BurstTrie<T, S>*)myElem->myVal)->firstElem );
		}
		else
		{
			//cout << "Container found." << endl;
			return ((BurstContainer<T, S>*)myElem->myVal);
		}
	}
	
	term<T, S>* nextTerm()
	{
		//cout << "Next term at depth " << curDepth << endl;
		if (!storedTerm) //end of container
		{
			//cout << "Advancing container" << endl;
			BurstContainer<T, S>* curContainer = nextContainer();
			if (curContainer)
			{ storedTerm = curContainer->firstTerm; }
			else
			{ return NULL; }
			
		}

		for (int i = curDepth + 1; i < dimension; i++)
		{
			curTerm.exps[i] = storedTerm->exps[i - curDepth - 1];
		}
		curTerm.coef = storedTerm->coef;
		curTerm.degree = storedTerm->degree;
		storedTerm = storedTerm->next;
		//cout << "got term w/coef " << curTerm->coef << endl;
		return &curTerm;
	}

	term<T, S>* getTerm()
	{
		return &curTerm;
	}
	
	~BTrieIterator()
	{
		delete [] triePath;
		delete [] curTerm.exps;
	}
	
private:
	BurstTrie<T, S>* myTrie; //trie to iterate over
	term<T, S> curTerm; //shared buffer to store values
	int dimension;
	
	BurstTerm<T, S>* storedTerm; //pointer to next stored term in current container
	trieElem** triePath;
	int curDepth;
};

#endif
