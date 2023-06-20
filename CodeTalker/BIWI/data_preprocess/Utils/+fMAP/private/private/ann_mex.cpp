/////////////////////////////////////////////////////////////////////
//
//  ann_mex.h
//
//  The core mex file as wrapper of the ANN C++ Library
//  (based on version 1.1.1)
//
//  Created by Dahua Lin, on Jul 5, 2007
//
/////////////////////////////////////////////////////////////////////

#ifndef ANNMWRAP_H
#define ANNMWRAP_H

#include <stdio.h>
#include <string.h>

#include "mex.h"
#include "ANN/ANN.h"
#include "string.h"

/**
 * Creates an ANN Point array from a memory block (d x n doubles)
 */
ANNpointArray createAnnPointArray(const double *data, int d, int n)
{
    // allocate the ANN point array
    ANNpointArray pts = annAllocPts(n, d);
    
    // copy the points
    //
    // In the annAllocPts implementation all point coordinates are
    // continuous in the memory,
    // so all points can be copied in a batch
    //
    if (n > 0)
    {
        memcpy(pts[0], data, sizeof(double) * d * n);
    }    
    
    return pts;   
}


// The functions for option parsing

/**
 * parse use_bdtree
 */
inline bool getopt_use_bdtree(const mxArray* mxUseBdTree)
{
    return mxIsLogicalScalarTrue(mxUseBdTree);
}

/**
 * parse bucket_size
 */
inline int getopt_bucket_size(const mxArray* mxBucketSize)
{
    return *((const int*)mxGetData(mxBucketSize));
}

/**
 * parse split rule
 */
inline ANNsplitRule getopt_split_rule(const mxArray* mxSplitRule)
{
    return (ANNsplitRule)(*((const int*)mxGetData(mxSplitRule)));        
}

/**
 * parse shrink rule
 */
inline ANNshrinkRule getopt_shrink_rule(const mxArray* mxShrinkRule)
{
    return (ANNshrinkRule)(*((const int*)mxGetData(mxShrinkRule)));
}


enum ESearchScheme
{
    ANNK_STANDARD_SEARCH = 0,
    ANNK_PRIORITY_SEARCH = 1,
    ANNK_FIXEDRAD_SEARCH = 2
};

/**
 * parse search option
 */
inline ESearchScheme getopt_search_scheme(const mxArray* mxSearchWay)
{
    return (ESearchScheme)(*((const int*)mxGetData(mxSearchWay)));
}


/**
 * parse k (the number of neighbors)
 */ 
inline int getopt_k(const mxArray* mxK)
{
    return *((const int*)mxGetData(mxK));
}

/**
 * parse err_bound
 */
inline double getopt_err_bound(const mxArray* mxErrBound)
{
    return *mxGetPr(mxErrBound);
}

/**
 * parse search radius
 */ 
inline double getopt_search_radius(const mxArray* mxSearchRadius)
{
    return *mxGetPr(mxSearchRadius);
}


// The options for building kd-tree
struct AnnBuildOptions
{
    bool            use_bdtree;
    int             bucket_size;
    ANNsplitRule    split_rule;
    ANNshrinkRule   shrink_rule;
    
    void mexdump()
    {
        mexPrintf("use_bdtree = %s\n", use_bdtree ? "true" : "false");
        mexPrintf("bucket_size = %d\n", bucket_size);
        mexPrintf("split_rule = %d\n", split_rule);
        mexPrintf("shrink_rule = %d\n", shrink_rule);
    }
};


// The options for performing search
struct AnnSearchOptions
{
    ESearchScheme   search_sch;
    int             knn;
    double          err_bound;
    double          search_radius;    
    
    void mexdump()
    {
        mexPrintf("search_sch = %d\n", search_sch);
        mexPrintf("knn = %d\n", knn);
        mexPrintf("err_bound = %g\n", err_bound);
        mexPrintf("search_radius = %g\n", search_radius);
    }
};


/**
 * Parse tree-building options from MATLAB option struct
 */
void parse_tree_building_options(const mxArray* mxOpts, AnnBuildOptions& opts)
{
    opts.use_bdtree = getopt_use_bdtree(mxGetField(mxOpts, 0, "use_bdtree"));
    opts.bucket_size = getopt_bucket_size(mxGetField(mxOpts, 0, "bucket_size"));
    opts.split_rule = getopt_split_rule(mxGetField(mxOpts, 0, "split"));
    opts.shrink_rule = opts.use_bdtree ? 
        getopt_shrink_rule(mxGetField(mxOpts, 0, "shrink")) : ANN_BD_NONE;
}

void parse_search_options(const mxArray* mxOpts, AnnSearchOptions& opts)
{
    opts.search_sch = getopt_search_scheme(mxGetField(mxOpts, 0, "search_sch"));
    opts.knn = getopt_k(mxGetField(mxOpts, 0, "knn"));
    opts.err_bound = getopt_err_bound(mxGetField(mxOpts, 0, "err_bound"));        
    opts.search_radius = (opts.search_sch == ANNK_FIXEDRAD_SEARCH) ? 
        getopt_search_radius(mxGetField(mxOpts, 0, "search_radius")) : 0;
}


/**
 * Creates the reference point array
 *
 * The MATLAB matrix should be a d x n real double matrix
 */
ANNpointArray createPointArray(const mxArray* mxPts, int& d, int& n)
{
    // get the size information
    d = (int)mxGetM(mxPts);
    n = (int)mxGetN(mxPts);
    
    // create point array
    ANNpointArray pts = createAnnPointArray(mxGetPr(mxPts), d, n);
    
    // return
    return pts;
}


/**
 * Creates ANN Kd-tree from a MATLAB matrix representing a point array
 *
 * The MATLAB matrix should be a d x n real double matrix
 */
ANNkd_tree* createKdTree(int d, int n, ANNpointArray pts, const AnnBuildOptions& op)
{                    
    // create tree
    ANNkd_tree *kdtree = 0;
    if (!op.use_bdtree)    // normal kd-tree
    {
        kdtree = new ANNkd_tree(pts, n, d, op.bucket_size, op.split_rule);
    }
    else                // bd-tree
    {
        kdtree = new ANNbd_tree(pts, n, d, op.bucket_size, op.split_rule, op.shrink_rule);
    }
    
    // return
    return kdtree;
}

/**
 * Performs KD-tree based search
 * 
 * Return the k x n matlab array od 
 */
void performAnnkSearch(ANNkd_tree *kdtree, const mxArray* mxQuery, const AnnSearchOptions& op, 
                       mxArray*& mxInds, mxArray*& mxDists)
{
    // get the size information
    int d = (int)mxGetM(mxQuery);
    int n = (int)mxGetN(mxQuery);
    int k = op.knn;
    
    // prepare array data
    mxInds = mxCreateNumericMatrix(k, n, mxINT32_CLASS, mxREAL);
    mxDists = mxCreateDoubleMatrix(k, n, mxREAL);
        
    ANNpoint     q      = (ANNpoint)mxGetPr(mxQuery);        
    ANNidxArray  nn_idx = (ANNidxArray)mxGetData(mxInds);
    ANNdistArray dists  = (ANNdistArray)mxGetPr(mxDists);
    
    switch (op.search_sch)
    {
        case ANNK_STANDARD_SEARCH:
            for (int i = 0; i < n; ++i)
            {
                kdtree->annkSearch(q, k, nn_idx, dists, op.err_bound);
                
                q += d;
                nn_idx += k;
                dists += k;
            }            
            break;
            
        case ANNK_PRIORITY_SEARCH:
            for (int i = 0; i < n; ++i)
            {
                kdtree->annkPriSearch(q, k, nn_idx, dists, op.err_bound);
                
                q += d;
                nn_idx += k;
                dists += k;
            }
            break;
            
        case ANNK_FIXEDRAD_SEARCH:
            for (int i = 0; i < n; ++i)
            {
                kdtree->annkFRSearch(q, op.search_radius, k, nn_idx, dists, op.err_bound);
                
                q += d;
                nn_idx += k;
                dists += k;
            }
            break;
    }       
}


/**
 * main entry
 *
 * Input
 *      1:  the reference points to construct the kd-tree (d x n double matrix)
 *      2:  the query points (d x nq double matrix)
 *      3:  the option struct
 * Output
 *      1:  the nearest neighbor index matrix (k x nq int32 matrix)
 *      2:  the distance matrix (k x nq double matrix)
 * Here,
 *      d  - the point dimension
 *      n  - the number of reference points
 *      nq - the number of query points
 *      k  - the number of maximum neighbors for each point
 * Note,
 *      The responsibility of checking the validity of the input arguments
 *      is with the invoker. The annsearch.m does the checking.
 *      The mex-function in itself does not conduct the checking again.
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // take inputs
    const mxArray *mxRefPts = prhs[0];
    const mxArray *mxQuery = prhs[1];
    const mxArray *mxOpts = prhs[2];
    
    // parse options    
    AnnBuildOptions opts_build;
    AnnSearchOptions opts_search;
    
    parse_tree_building_options(mxOpts, opts_build);
    parse_search_options(mxOpts, opts_search);
            
    // construct the tree
    int d = 0;
    int n = 0;
    ANNpointArray pts = createPointArray(mxRefPts, d, n);
    ANNkd_tree *kd_tree = createKdTree(d, n, pts, opts_build);
    
    // perform the search
    mxArray *mxInds = NULL;
    mxArray *mxDists = NULL;
    performAnnkSearch(kd_tree, mxQuery, opts_search, mxInds, mxDists);
    
    // release the kd-tree
    delete kd_tree;
    annDeallocPts(pts);
    annClose();
    
    // set outputs
    plhs[0] = mxInds;
    plhs[1] = mxDists;
}


#endif



