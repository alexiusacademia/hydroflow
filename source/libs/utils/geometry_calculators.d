module libs.utils.geometry_calculators;

import std.math;

import libs.utils.point;

/// Calculates the area of given polygon
/// using the Shoelace formula.
double polygonArea(Point[] pts)
{
    // Number of vertices of the polygon
    const n = cast(int) pts.length;

    // Initialize area
    double area = 0;
    int j;

    for (int k = 0; k < n; k++)
    {
        j = (k + 1) % n;
        area += pts[k].x * pts[j].y;
        area -= pts[j].x * pts[k].y;
    }

    area = abs(area) / 2;

    return area;
}

/// Calculates the total perimeter of a given polygon
double polygonPerimeter(Point[] pts)
{
    // Initialize perimeter
    double perimeter = 0;

    // Number of vertices of the polygon
    int n = cast(int) pts.length;

    Point p1, p2;

    for (int i = 0; i < (n - 1); i++)
    {
        p1 = pts[i];
        p2 = pts[i + 1];
        perimeter += distanceBetweenTwoPoints(p1, p2);
    }

    return perimeter;
}

/// Implementation of distance between 2 points.
double distanceBetweenTwoPoints(Point p1, Point p2)
{
    float x1, y1, x2, y2;
    x1 = p1.x;
    y1 = p1.y;
    x2 = p2.x;
    y2 = p2.y;
    return sqrt(pow((y2 - y1), 2) + pow((x2 - x1), 2));
}

float interpolate(float x1, float x3, float y1, float y2, float y3)
{
    float x2 = x1;

    x2 = (y2 - y3) / (y1 - y3) * (x1 - x3) + x3;

    return x2;
}