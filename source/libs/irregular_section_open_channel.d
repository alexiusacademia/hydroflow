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

    /// Empty constructor
    this()
    {
        unknown = Unknown.DISCHARGE;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Setters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    void setPoints(Point[] pts)
    {
        points = pts;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Getters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /** Returns the list of points */
    Point[] getPoints()
    {
        return points;
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
