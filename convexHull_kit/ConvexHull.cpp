#include "ConvexHull.h"



/***    public    ***/



ConvexHull::ConvexHull(){
}

void ConvexHull::setConvexHull(vector< pair<float, float> > points){
    sort(points.begin(), points.end());
    convexHullPoints = computeConvexHull(points);
}

bool ConvexHull::determineInConv(pair<float, float> point){
    return find(convexHullPoints.begin(), convexHullPoints.end(), point) != convexHullPoints.end();
}



/***    private    ***/



//Compute the convex hull from the array of points.
vector< pair<float, float> > ConvexHull::computeConvexHull(vector< pair<float, float> > points){

    int halfID; //ID which splits the array in half
    vector< pair<float, float> > lineSegment; //lineSegment of 3 points are on the same line
    vector< pair<float, float> > convL; //left convex hull
    vector< pair<float, float> > convR; //right convex hull

    //If the number of points is less than 3, points are returned as is.
    if(points.size()<3) {

        return points;
    
    //If the number of points is equal to 3
    }else if(points.size()==3){

        // If 3 points on the same line
        if( crossProduct(points[0], points[1], points[2])==0 ){
            lineSegment.push_back(points[0]);
            lineSegment.push_back(points[2]);
            return lineSegment;
        }else{
            clockwiseMerge(points, 2, 3, points.size());
            return points;
        }

    }else{

        halfID = points.size()/2;

        //split the array with respect to halfID.
        for(int i=0; i<halfID; i++){
            convL.push_back(points[i]);
        }

        for(int i=halfID; i<points.size(); i++){
            convR.push_back(points[i]);
        }

        return mergeConvexHull(computeConvexHull(convL), computeConvexHull(convR));
    }
}

//Combine two convex hulls.
vector< pair<float, float> > ConvexHull::mergeConvexHull(vector< pair<float, float> > convL, vector< pair<float, float> > convR){

    pair<int, int> lineTop; //lineTop holds two ID of the points joining two convex hull tops.
    pair<int, int> lineBottom; //lineBottom holds two ID of the points joining two convex hull bottoms.
    vector< pair<float, float> > convexHull; //Array containing the concatenation of two convexHulls.

    //Sort each convex hull in clockwise order
    clockwiseMergeSort(convL, 1, convL.size());
    clockwiseMergeSort(convR, 1, convR.size());

    //Sort each convex hull in clockwise order
    lineTop = jugheCrossLine(convL, convR, 1);
    lineBottom = jugheCrossLine(convL, convR, -1);

    convexHull.push_back(convL[0]);

    for(int i=convL.size()-1; i>=lineTop.first && lineTop.first>0; i--){
        convexHull.push_back(convL[i]);
    }

    if(lineTop.second==0){
        convexHull.push_back(convR[0]);
        for(int i=convR.size()-1; i>=lineBottom.second; i--){
        convexHull.push_back(convR[i]);
        }
    }else{

        for(int i=lineTop.second; i>=lineBottom.second; i--){
        convexHull.push_back(convR[i]);
        }

    }

     for(int i=lineBottom.first; i > 0; i--){
        convexHull.push_back(convL[i]);
    }

    sort(convexHull.begin(), convexHull.end());
    return convexHull;

}



 //Compute the cross product of vectors p1p2 and p1p3 (x1*y2 - y1*x2).
float ConvexHull::crossProduct(pair<float, float> p1, pair<float, float> p2, pair<float, float> p3){
    return (p2.first - p1.first) * (p3.second - p1.second) - (p2.second - p1.second) * (p3.first - p1.first);
}



//Sort in counterclockwise angular order with respect to P0.
void ConvexHull::clockwiseMergeSort(vector< pair<float, float> >& points, int L, int R){

    if(L+1 < R){
        int M = (L+R)/2;
        clockwiseMergeSort(points, L, M);
        clockwiseMergeSort(points, M, R);
        clockwiseMerge(points, L, M, R);
    }
}

//Attach the divided arrays together.
void ConvexHull::clockwiseMerge(vector< pair<float, float> >& points, int left, int mid, int right){

    int l_id=0; //ID of pointsL
    int r_id=0; //ID of pointsR
    pair<float, float> pointsL[mid-left + 1]; //left array of points
    pair<float, float> pointsR[right-mid + 1]; //right array of points

    //Substitute the left and right values of points into their respective arrays
    for(int i=0; i<mid-left; i++){
        pointsL[i] = points[left+i];
    }

    for(int i=0; i<right-mid; i++){
        pointsR[i] = points[mid+i];
    }

    //Create the point that angle is nearly max.
    pointsL[mid-left].first = points[0].first + 1;
    pointsL[mid-left].second = INF;
    pointsR[right-mid].first = points[0].first + 1;
    pointsR[right-mid].second = INF;
    
    //Insert point to array in ascending order
    for(int i=left; i<right; i++){

        if(calcSlope(points[0], pointsL[l_id]) <= calcSlope(points[0], pointsR[r_id])){
            points[i] = pointsL[l_id];
            l_id++;
        }else{
            points[i] = pointsR[r_id];
            r_id++;
        }
    }
}

//Calculate the slope of p1p2.
float ConvexHull::calcSlope(pair<float, float> p1, pair<float, float>p2){
    return (p2.second - p1.second)/(p2.first - p1.first);
}




pair<int, int> ConvexHull::jugheCrossLine(vector< pair<float, float> > convL, vector< pair<float, float> > convR, int flag){

    pair<int,int> ids; //ids pairing convL and convR

    //Current id for each convex hull
    int l_id; 
    int r_id; 

    //Whether there is a point above or below the line segment
    bool jugheL;
    bool jugheR; 
    
    //Initialization
    l_id=vectorMaxXID(convL);
    r_id=0;

    //The first jughe whether there is a point above or below the line
    jugheL=(flag*crossProduct(convR[r_id], convL[l_id], convL[nextID(l_id, convL.size(), 1*flag)]) <= 0);
    jugheR=(flag*crossProduct(convL[l_id], convR[nextID(r_id, convR.size(), -1*flag)], convR[r_id]) <= 0);

    int i=0;
    
    //Jughe loop
    while((jugheL || jugheR)){
        
        //If there is a point above or below the line, current IDs moves to the next.
        if(jugheL) l_id = nextID(l_id, convL.size(), 1*flag);
        else if(jugheR) r_id = nextID(r_id, convR.size(), -1*flag);

        //Jughe
        jugheL=(flag*crossProduct(convR[r_id], convL[l_id], convL[nextID(l_id, convL.size(), 1*flag)]) <= 0);
        jugheR=(flag*crossProduct(convL[l_id], convR[nextID(r_id, convR.size(), -1*flag)], convR[r_id]) <= 0);
    }

    //Put the ID of each line segment in id.
    ids.first =l_id;
    ids.second = r_id;

    return ids;
}

//Move to next ID
int ConvexHull::nextID(int i, int size, int direction){
    
    if((i+direction)%size<0)return size-1;
    else return (i+direction)%size;
}

//Find the ID where x is maximal
int ConvexHull::vectorMaxXID(vector< pair<float, float> > points){

    int Max = -INF;
    int MaxXID;
    
    for(int i=0; i<points.size(); i++){
        if(points[i].first > Max){
            MaxXID=i;
            Max = points[i].first;
        }
    }

    return MaxXID;
}