#include "ConvexHull.h"

int main(){
    
    int n;
    pair<float, float> p;
    vector< pair<float, float> > points;
    ConvexHull Conv;

    cin >> n;

    for(int i=0; i<n; i++){
        cin >> p.first >> p.second;
        points.push_back(p);
    }

    Conv.setConvexHull(points);

    cout << "OK, I prepared an convexHull using your points!!" << endl;
    cout << "Please input the point that you want!!" << endl;

    cin >> p.first >> p.second;

    if(Conv.determineInConv(p)){
        cout << "Yes! There is your point in my convexHull!!" << endl;
    }else{
        cout << "No...I couldn't find your point in my convexHull..." << endl;
    }
}