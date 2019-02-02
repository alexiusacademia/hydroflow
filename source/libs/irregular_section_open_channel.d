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
        points = new Point[];
        newPoints = new Point[];
    }


}
