module libs.irregular_section_open_channel;

/// Standard modules
import std.math;
import std.stdio;

// Custom modules
import libs.openchannel;
import libs.utils.point;

class IrregularSectionOpenChannel : OpenChannel
{
    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                 Properties                   +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    private Point[] points;
    private Point[] newPoints;
    private float maxWaterElevation;
    private float waterElevation;
    private double trialDischarge;
    private int i; // Iterator

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Setters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /**
    *   Set the points with an array of Point object.
    */
    void setPoints(Point[] pts)
    {
        points = pts;
    }

    /**
    *   Sets the water elevation.
    */
    void setWaterElevation(float we)
    {
        waterElevation = we;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Getters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/

    /** Returns the list of points */
    Point[] getPoints()
    {
        return points;
    }

    /** Returns the adjusted points. */
    Point[] getNewPoints()
    {
        return newPoints;
    }

    float getMaxWaterElevation()
    {
        return maxWaterElevation;
    }

    float getWaterElevation()
    {
        return waterElevation;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                Constructors                  +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Empty constructor
    this()
    {
        unknown = Unknown.DISCHARGE;
    }

    this(Unknown u)
    {
        unknown = u;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                   Methods                    +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Add a single point
    void addPoint(Point p)
    {
        int lastIndex = cast(int) points.length;
        points.length = points.length + 1;
        points[lastIndex] = p;
    }

    /// Solution summary.
    /// To be called in the application API
    bool solve()
    {
        switch (unknown)
        {
        case Unknown.DISCHARGE:
            if (solveForDischarge)
                return true;
            break;
        default:
            break;
        }
        return false;
    }

    /// Solve for the unknown discharge
    private bool solveForDischarge()
    {
        if (isValidInputs(isValidBedSlope(Unknown.DISCHARGE)))
        {
            // Number of intersections
            int leftIntersection, rightIntersection;

            // Remove points above the intersection points
            float x1, y1, x2, y2, x3;

            // Temp variable for y
            float y;

            i = 0;

            newPoints = null;

            foreach (Point p; points)
            {
                i++;

                // Get the ordinate of the current point
                y = p.y;

                // Find the intersection at the ledt bank
                if (leftIntersection == 0)
                {
                    if (y <= waterElevation && i > 0)
                    {
                        leftIntersection++;
                        // Solve for intersection point using interpolation
                        x1 = points[i - 1].x;
                        y1 = points[i - 1].y;
                        x2 = points[i].x;
                        y2 = points[i].y;
                        x3 = (waterElevation - y1) * (x2 - x1) / (y2 - y1) + x1;
                        newPoints.length = newPoints.length + 1;
                        newPoints[cast(int) newPoints.length - 1] = new Point(x3, waterElevation);
                    }
                }

                // Find the intersection at the right bank
                if (rightIntersection == 0)
                {
                    if (y >= waterElevation && i > 0)
                    {
                        rightIntersection++;
                        // Solve for the intersection point
                        x1 = points[i - 1].x;
                        y1 = points[i - 1].y;
                        x2 = points[i].x;
                        y2 = points[i].y;
                        x3 = (waterElevation - y1) * (x2 - x1) / (y2 - y1) + x1;
                        newPoints.length = newPoints.length + 1;
                        newPoints[cast(int) newPoints.length - 1] = new Point(x3, waterElevation);
                    }
                }

                if (leftIntersection == 1)
                {
                    if (rightIntersection == 0)
                    {
                        newPoints.length = newPoints.length + 1;
                        newPoints[cast(int) newPoints.length - 1] = points[i];
                    }
                }
            }

            return true;
        }
        else
        {
            return false;
        }
    }

    /// Calculates the area of given polygon
    /// using the Shoelace formula.
    private double polygonArea(Point[] pts)
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
    private double polygonPerimeter(Point[] pts)
    {
        // Initialize perimeter
        double perimeter = 0;

        // Number of vertices of the polygon
        int n = cast(int) pts.length;

        Point p1, p2;

        for (int k = 0; i < (n - 1); i++)
        {
            p1 = pts[k];
            p2 = pts[k + 1];
            perimeter += distanceBetweenTwoPoints(p1, p2);
        }

        return perimeter;
    }

    /// Implementation of distance between 2 points.
    private double distanceBetweenTwoPoints(Point p1, Point p2)
    {
        float x1, y1, x2, y2;
        x1 = p1.x;
        y1 = p1.y;
        x2 = p2.x;
        y2 = p2.y;
        return sqrt(pow((y2 - y1), 2) + pow((x2 - x1), 2));
    }

    /// Finds the elevation of the lowest point from the cross section.
    private float calculateLowestElevation()
    {
        float[] elevations;
        float lowest = points[0].y;

        foreach (Point p ; points)
        {
            elevations.length = elevations.length + 1;
            elevations[cast(int)elevations.length - 1] = p.y;
        }

        foreach(float el ; elevations)
        {
            if (lowest > el)
            {
                lowest = el;
            }
        }
        return lowest;
    }

}
