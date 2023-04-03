#ifndef __COMP_GEODESICS_H__
#define __COMP_GEODESICS_H__

#include <vector>
#include "geodesic_algorithm_exact.h"
#include "geodesic_algorithm_dijkstra.h"

using namespace std;

// Compute the geodesic distances from the source vertices to all other vertices
// on the mesh. Store output in the distances vector, which will have the same
// size as the number of vertices on the mesh.
template <class Algorithm>
void comp_geodesics_to_all(geodesic::Mesh &geod_mesh,
                           const vector<unsigned> &vid_sources,
                           vector<double >& distances) {
    //create exact algorithm for the mesh
	Algorithm algorithm(&geod_mesh);
    
    vector<geodesic::SurfacePoint> all_sources;
    for (int i=0; i< vid_sources.size(); i++) {
        //create source
        geodesic::SurfacePoint source(&geod_mesh.vertices()[vid_sources[i]]);
        all_sources.push_back(source);
    }
	
    double const distance_limit = geodesic::GEODESIC_INF;
    algorithm.propagate(all_sources, distance_limit);   //cover the whole mesh
    
    distances.clear();
    
	double distance;
	for(unsigned int i = 0; i < geod_mesh.vertices().size(); ++ i){
        geodesic::SurfacePoint p(&geod_mesh.vertices()[i]);
        //for a given surface point, find closets source and distance to this source
		unsigned int best_source = algorithm.best_source(p, distance);
		distances.push_back( distance );
	}
}

// Compute the geodesic distances between a set of pairs. Store output in the
// distances vector which will have the same size as the input vector of pairs.
template <class Algorithm>
void comp_geodesics_pairs(geodesic::Mesh &geod_mesh,
                          const vector<pair<unsigned, unsigned> > &vid_pairs,
                          vector<double>& distances) {
    //create exact algorithm for the mesh
	Algorithm algorithm(&geod_mesh);
    
    distances.clear();
    
    double distance;
    for (int i=0; i < vid_pairs.size(); ++i) {
        unsigned source_vertex_index = vid_pairs[i].first;
        unsigned target_vertex_index = vid_pairs[i].second;
        
        double const distance_limit = geodesic::GEODESIC_INF;
        geodesic::SurfacePoint source(&geod_mesh.
                                      vertices()[source_vertex_index]);
        std::vector<geodesic::SurfacePoint> all_sources(1,source);
        
        geodesic::SurfacePoint target(&geod_mesh.
                                      vertices()[target_vertex_index]);
        std::vector<geodesic::SurfacePoint> stop_points(1, target);
        
        algorithm.propagate(all_sources, distance_limit, &stop_points);
        
        unsigned int best_source = algorithm.best_source(target, distance);
        
        distances.push_back(distance);
    }
}

//// Compute the geodesic distances from the source vertices to all other vertices
//// on the mesh read in an off file. Store output in the distances vector,
//// which will have the samesize as the number of vertices on the mesh.
//template <class Algorithm>
//void comp_geodesics_to_all_off(char *filename,
//                               const vector<unsigned> &vid_sources,
//                               vector<double >& distances) {
//    geodesic::Mesh geod_mesh;
//    initialize_mesh_off(filename, geod_mesh);
//    
//    comp_geodesics_to_all<Algorithm>(geod_mesh, vid_sources, distances);
//}
//
//
//// Compute the geodesic distances from the source vertices to all other vertices
//// on the mesh read in an off file. Store output in the distances vector,
//// which will have the samesize as the number of vertices on the mesh.
//template <class Algorithm>
//void comp_geodesics_pairs_off(char *filename,
//                              const vector<pair<unsigned, unsigned> > &vid_pairs,
//                              vector<double>& distances) {
//    geodesic::Mesh geod_mesh;
//    initialize_mesh_off(filename, geod_mesh);
//    
//    comp_geodesics_pairs<Algorithm>(geod_mesh, vid_pairs, distances);
//}
//
//// Initialize the geodesic::Mesh data structure from an off file.
//void initialize_mesh_off(char *filename, geodesic::Mesh &geod_mesh) {
//    std::vector<double> points;
//	std::vector<unsigned> faces;
//    
//	bool success = geodesic::read_mesh_from_off(filename, points, faces);
//	if(!success)
//	{
//		std::cout << "something is wrong with the input file" << std::endl;
//		return;
//	}
//    
//	geod_mesh.initialize_mesh_data(points, faces);
//}

//// Compute the geodesic distances between a set of pairs. Store output in the
//// distances vector which will have the same size as the input vector of pairs.
//template <class Algorithm>
//void comp_geodesics_pairs(geodesic::Mesh &geod_mesh,
//                          const vector<pair<unsigned, unsigned> > &vid_pairs,
//                          vector<double>& distances);
//
//// Compute the geodesic distances from the source vertices to all other vertices
//// on the mesh read in an off file. Store output in the distances vector, 
//// which will have the samesize as the number of vertices on the mesh.
//template <class Algorithm>
//void comp_geodesics_to_all_off(char *filename,
//                               const vector<unsigned> &vid_sources,
//                               vector<double >& distances);
//
//// Compute the geodesic distances between a set of pairs. Store output in the
//// distances vector which will have the same size as the input vector of pairs.
//template <class Algorithm>
//void comp_geodesics_pairs_off(char* filename,
//                              const vector<pair<unsigned, unsigned> > &vid_pairs,
//                              vector<double>& distances);
//
//// Initialize the geodesic::Mesh data structure from an off file.
//void initialize_mesh_off(char *filename, geodesic::Mesh &geod_mesh);
//
#endif //__COMP_GEODESICS_H__
