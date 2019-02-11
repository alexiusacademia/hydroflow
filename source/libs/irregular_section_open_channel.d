/**
* irregular_section_open_channel module.
* Contains class for the analysis of irregular shaped sections
* of open channel.
* Authors:
*   Alexius Academia
* License:
*   MIT
* Copyright:
*   2019
*/
module libs.irregular_section_open_channel;

/// Standard modules
import std.math;
import std.stdio;
import std.algorithm;

// Custom modules
import libs.openchannel;
import libs.utils.point;
import libs.utils.geometry_calculators;

/**
* Class for the analysis of irregular shaped sections
* of open channel.
*/
class IrregularSectionOpenChannel : OpenChannel
{
    //++++++++++++++++++++++++++++++++++++++++++++++
    //                Properties                   +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /** 
    * List of points that defines the channel shape.
    */
    protected Point[] points;
    /// Part of the <b>points</b> variable that is used and
    /// manipulated during the calculation.
    protected Point[] newPoints;
    /// Maximum allowed water elevation based on the lowest bank.
    protected float maxWaterElevation;
    /// Water elevation.
    protected float waterElevation;
    private double trialDischarge;
    /// Available unknowns for this class.
    protected Unknown[] availableUnknowns = [Unknown.DISCHARGE];

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Setters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /**
    * Set the points with an array of Point objects.
    * Params:
    *   pts = List of Point objects that defines the shape of the channel.
    */
    void setPoints(Point[] pts)
    {
        points = pts;
    }

    /**
    * Sets the water elevation.
    * Params:
    *   we = Water elevation.
    */
    void setWaterElevation(float we)
    {
        waterElevation = we;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Getters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /** 
    * Returns the list of points 
    * Returns:
    *   List of Point objects that defines the shape of the channel.
    */
    Point[] getPoints()
    {
        return points;
    }

    /** Returns the adjusted points. */
    Point[] getNewPoints()
    {
        return newPoints;
    }

    /**
    * Get the elevation of the lower bank. Either from left or right.
    * Returns: 
    *   maxWaterElevation
    */
    float getMaxWaterElevation()
    {
        return maxWaterElevation;
    }

    /**
    * Returns the water elevation.
    */
    float getWaterElevation()
    {
        return waterElevation;
    }

    /// Returns all the available unknowns for this class.
    Unknown[] getAvailableUnknowns()
    {
        return availableUnknowns;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //               Constructors                  +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Empty constructor
    this()
    {
        unknown = Unknown.DISCHARGE;
    }

    /// Constructor specifying the unknown.
    this(Unknown u)
    {
        unknown = u;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                   Methods                    +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Add a single point
    /// Params:
    ///     p = Point to be added to the end of shape definition.
    void addPoint(Point p)
    {
        int lastIndex = cast(int) points.length;
        points.length = points.length + 1;
        points[lastIndex] = p;
    }

    // Solution summary.
    // To be called in the application API
    /// Method to be called for the analysis regardless of the unknown.
    bool solve()
    {
        newPoints = null; // Reset newPoints array
        newPoints.length = 1; // Set length to 1 to give room for the first element of points array

        if (!canFind(availableUnknowns, unknown))
        {
            errorMessage = "The specified unknown is not included in the available unknowns.";
            return false;
        }

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

    /**
    * Critical flow analysis.
    */ 
    private void solveForCriticalFlow()
    {
        // Top width
        double T;

        T = distanceBetweenTwoPoints(newPoints[0],
                newPoints[cast(int)newPoints.length - 1]);

        hydraulicDepth = wettedArea / T;
        froudeNumber = averageVelocity / sqrt(
                GRAVITY_METRIC * hydraulicDepth);

        // Select the flow type
        calculateFlowType();
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

    /**
    * Calculates the distance between two given coordinates.
    * Params:
    *   p1 = object Point, x and y coordinate
    *   p2 = another point
    * Returns:
    *   The distance between p1 and p2.
    */
    private double distanceBetweenTwoPoints(Point p1, Point p2)
    {
        float x1, y1, x2, y2;
        x1 = p1.x;
        y1 = p1.y;
        x2 = p2.x;
        y2 = p2.y;
        return sqrt(pow((y2 - y1), 2) + pow((x2 - x1), 2));
    }
}
