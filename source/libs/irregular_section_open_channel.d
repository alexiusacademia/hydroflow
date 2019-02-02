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
    /** Add a single point */
    void addPoint(Point p)
    {
        ulong lastIndex = points.length;
        points.length = points.length + 1;
        points[lastIndex] = p;
    }

}
