#include <mex.h>
#include <math.h>
#include <vector>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <assert.h>

#include "comp_geodesics.h"

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	
	/*  check for proper number of arguments */
	/* NOTE: You do not need an else statement when using mexErrMsgTxt
	 *       within an if statement, because it will never get to the else
	 *       statement if mexErrMsgTxt is executed. (mexErrMsgTxt breaks you out of
	 *       the MEX-file) 
	*/
	if(nrhs != 5 && nrhs != 6){
		mexErrMsgTxt("Five or six inputs required.");
	}
	if(nlhs != 1){
		mexErrMsgTxt("One output required.");
	}

    if( mxGetClassID(prhs[0]) != mxDOUBLE_CLASS){
		mexErrMsgTxt("Input 1 must be an array.");
	}
    if( mxGetClassID(prhs[1]) != mxDOUBLE_CLASS){
		mexErrMsgTxt("Input 2 must be an array.");
	}
    if( mxGetClassID(prhs[2]) != mxDOUBLE_CLASS){
		mexErrMsgTxt("Input 3 must be an array.");
	}
    if( mxGetClassID(prhs[3]) != mxDOUBLE_CLASS){
		mexErrMsgTxt("Input 4 must be an array.");
	}

    if( mxGetClassID(prhs[4]) != mxDOUBLE_CLASS){
		mexErrMsgTxt("Input 5 must be an array.");
	}
    
    double   *prX, *prY, *prZ;

    prX = (double *)mxGetPr(prhs[0]);
    prY = (double *)mxGetPr(prhs[1]);
    prZ = (double *)mxGetPr(prhs[2]);
    mwSize total_num_of_elements, index;
    
    total_num_of_elements = mxGetNumberOfElements(prhs[0]);
    
    if (total_num_of_elements != mxGetNumberOfElements(prhs[1]) ||
        total_num_of_elements != mxGetNumberOfElements(prhs[2])) {
        mexErrMsgTxt("First three arrays must have the same size.");
    }
	geodesic::Mesh mesh;
  
    std::vector<double> points;
	std::vector<unsigned> faces;
    
    for (index=0; index<total_num_of_elements; index++)  {
        points.push_back(*prX++);
        points.push_back(*prY++);
        points.push_back(*prZ++);
    }

    double *prT;
    
    prT = (double *)mxGetPr(prhs[3]);
    total_num_of_elements = mxGetNumberOfElements(prhs[3]);

    for (index=0; index<total_num_of_elements; index++)  {
        unsigned int vid = (unsigned int)*prT;
        prT++;
        faces.push_back(vid-1);
    }

    //create internal mesh data structure including edges
    mesh.initialize_mesh_data(points, faces);

    double   *pr;
    pr = (double *)mxGetPr(prhs[4]);
    total_num_of_elements = mxGetNumberOfElements(prhs[4]);
    
    std::vector<unsigned int> source_vids;
    for (index=0; index<total_num_of_elements; index++)  {
        unsigned int vid = (unsigned int)*pr;
        pr++;
        source_vids.push_back(vid-1);
    }

    vector<double> dists;
    if (nrhs == 5) {
        comp_geodesics_to_all<geodesic::GeodesicAlgorithmExact>(mesh,
                                                                source_vids, dists);
    } else if (nrhs == 6) {
        comp_geodesics_to_all<geodesic::GeodesicAlgorithmDijkstra>(mesh,
                                                                  source_vids, dists);

    }
    
    unsigned int nelem = dists.size();
	plhs[0] = mxCreateDoubleMatrix(nelem, 1, mxREAL);
	
    double *II;
	II = mxGetPr(plhs[0]);

	for(mwSize i = 0; i < nelem; i ++){
		II[i] = dists[i];
	}
}


