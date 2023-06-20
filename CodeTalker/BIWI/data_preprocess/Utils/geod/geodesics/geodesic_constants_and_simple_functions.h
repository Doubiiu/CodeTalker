//Copyright (C) 2008 Danil Kirsanov, MIT License
#ifndef GEODESIC_CONSTANTS_20071231
#define GEODESIC_CONSTANTS_20071231

// some constants and simple math functions

#include <assert.h>
#include <math.h>
#include <limits>
#include <fstream>
#include <string>
#include <sstream>

namespace geodesic{

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

//double const GEODESIC_INF = std::numeric_limits<double>::max();
double const GEODESIC_INF = 1e100;

//in order to avoid numerical problems with "infinitely small" intervals,
//we drop all the intervals smaller than SMALLEST_INTERVAL_RATIO*edge_length
double const SMALLEST_INTERVAL_RATIO = 1e-6;		
//double const SMALL_EPSILON = 1e-10;


inline double cos_from_edges(double const a,			//compute the cosine of the angle given the lengths of the edges
							 double const b,
							 double const c)
{
	assert(a>1e-50);
	assert(b>1e-50);
	assert(c>1e-50);

	double result = (b*b + c*c - a*a)/(2.0*b*c);
	result = std::max(result, -1.0);
	return std::min(result, 1.0);
}

inline double angle_from_edges(double const a,			//compute the cosine of the angle given the lengths of the edges
							   double const b,
							   double const c)
{
	return acos(cos_from_edges(a,b,c));
}

template<class Points, class Faces>
inline bool read_mesh_from_file(char* filename,
								Points& points,
								Faces& faces)
{
	std::ifstream file(filename);
	assert(file.is_open());
	if(!file.is_open()) return false;
	
	unsigned num_points;
	file >> num_points;
	assert(num_points>=3);

	unsigned num_faces;
	file >> num_faces;

	points.resize(num_points*3);
	for(typename Points::iterator i=points.begin(); i!=points.end(); ++i)
	{
		file >> *i;
	}

	faces.resize(num_faces*3);
	for(typename Faces::iterator i=faces.begin(); i!=faces.end(); ++i)
	{
		file >> *i;
	}
	file.close();

	return true;
}
    

template<class Points, class Faces>
inline bool read_mesh_from_off(char* filename,
                               Points& points,
                               Faces& faces)
{
    std::ifstream file(filename);
    assert(file.is_open());
    if(!file.is_open()) return false;
    
    std::string temp;
    file >> temp;
    
    unsigned num_points;
    file >> num_points;
    assert(num_points>=3);
    
    unsigned num_faces;
    file >> num_faces;

    std::getline(file, temp, '\n');

    points.resize(num_points*3);
    for(typename Points::iterator i=points.begin(); i!=points.end(); )
    {
        std::getline(file, temp, '\n');
        std::stringstream ss(temp);
        for(int k=0; k < 3; k++) {
            ss >> *i;
            i++;
        }
    }
    
    faces.resize(num_faces*3);
    for(typename Faces::iterator i=faces.begin(); i!=faces.end(); )
    {
        std::getline(file, temp, '\n');
        std::stringstream ss(temp);
        int dump;
        ss >> dump;
        for(int k=0; k < 3; k++) {
            ss >> *i;
            i++;
        }
    }
    file.close();
        
    return true;
}


} //geodesic

#endif	//GEODESIC_CONSTANTS_20071231
