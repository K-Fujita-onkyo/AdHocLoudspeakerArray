#ifndef CONVEXHULL_H
#define CONVEXHULL_H

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

#define INF 99999

class ConvexHull{
    
private:
    vector< pair<float, float> > convexHullPoints;

    vector< pair<float, float> > computeConvexHull(vector< pair<float, float> > points);
    vector< pair<float, float> > mergeConvexHull(vector< pair<float, float> > convL, vector< pair<float, float> > convR);

    float crossProduct(pair<float, float> p1, pair<float, float> p2, pair<float, float> p3);

    void clockwiseMergeSort(vector< pair<float, float> >& points, int L, int R);
    void clockwiseMerge(vector< pair<float, float> >& points, int left, int mid, int right);
    float calcSlope(pair<float, float> p1, pair<float, float>p2);

    pair<int, int> jugheCrossLine(vector< pair<float, float> > convL, vector< pair<float, float> > convR, int flag);
    int nextID(int i, int size, int direction);
    int vectorMaxXID(vector< pair<float, float> > points);

public:
    ConvexHull();
    void setConvexHull(vector< pair<float, float> > points);
    bool determineInConv(pair<float, float> point);
};

#endif