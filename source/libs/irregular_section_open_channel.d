module libs.irregular_section_open_channel;

/// Standard modules
import std.math;
import std.stdio;
import std.algorithm;

// Custom modules
import libs.openchannel;
import libs.utils.point;
import libs.utils.geometry_calculators;

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

    Unknown[] getAvailableUnknowns()
    {
        return availableUnknowns;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                Constructors                  +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Empty constructor
    this()
    {
        unknown = Unknown.DISCHARGE;
    }

    /// Constructor specifying the unknown.
    this(Unknown u)
    {
        if (canFind(availableUnknowns, u))
        {
            unknown = u;
        }
        else
        {
            writeln("The specified unknown is not included in the available unknowns.");
            errorMessage = "The specified unknown is not included in the available unknowns.";
            unknown = Unknown.DISCHARGE;
        }
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
        newPoints = null; // Reset newPoints array
        newPoints.length = 1; // Set length to 1 to give room for the first element of points array

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
            int leftIntersection = 0, rightIntersection = 0;

            float x1, y1, x2, y2, x3;

            // Collect all points including original ones
            // and the intersection between section and waterElevation.

            newPoints[0] = points[0];

            for (int i = 1; i < points.length; i++)
            {
                // Look for the intersection at the left side of the channel
                if (leftIntersection == 0)
                {
                    if (points[i].y <= waterElevation && i > 0)
                    {
                        leftIntersection++;
                        // Solve for the intersection point using interpolation
                        x1 = points[i - 1].x;
                        y1 = points[i - 1].y;
                        x2 = points[i].x;
                        y2 = points[i].y;
                        x3 = (waterElevation - y1) * (x2 - x1) / (y2 - y1) + x1;
                        newPoints.length = newPoints.length + 1;
                        newPoints[cast(int) newPoints.length - 1] = new Point(x3,
                                this.waterElevation);
                    }
                }

                // Get the water intersection at right bank
                if (rightIntersection == 0)
                {
                    if (points[i].y >= waterElevation && i > 0)
                    {
                        rightIntersection++;
                        // Solve for the intersection point using interpolation
                        x1 = points[i - 1].x;
                        y1 = points[i - 1].y;
                        x2 = points[i].x;
                        y2 = points[i].y;
                        x3 = (waterElevation - y1) * (x2 - x1) / (y2 - y1) + x1;
                        newPoints.length = newPoints.length + 1;
                        newPoints[cast(int) newPoints.length - 1] = new Point(x3,
                                this.waterElevation);
                    }
                }

                newPoints.length = newPoints.length + 1;
                newPoints[cast(int) newPoints.length - 1] = points[i];
            }

            // Now, remove all points above waterElevation
            for (int i = 0; i < newPoints.length; i++)
            {
                if (newPoints[i].y > waterElevation)
                {
                    // Using remove from std.algorithm
                    newPoints = newPoints.remove(i);
                }
            }

            // Hydraulic elements
            wettedArea = polygonArea(newPoints);
            wettedPerimeter = polygonPerimeter(newPoints);
            hydraulicRadius = wettedArea / wettedPerimeter;

            averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius,
                    (2.0 / 3));
            discharge = averageVelocity * wettedArea;

            return true;

        }

        return false;
    }

    /// Finds the elevation of the lowest point from the cross section.
    private float calculateLowestElevation()
    {
        float[] elevations;
        float lowest = points[0].y;

        // Collect all elevations
        foreach (Point p; points)
        {
            elevations.length = elevations.length + 1;
            elevations[cast(int) elevations.length - 1] = p.y;
        }

        // Compare each elevation
        foreach (float el; elevations)
        {
            if (lowest > el)
            {
                lowest = el;
            }
        }
        return lowest;
    }

}
