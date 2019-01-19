module src.libs.openchannel_rectangular;

import std.math;
import src.libs.openchannel;
import std.stdio;

class RectangularOpenChannel : OpenChannel
{
  /// Unknowns
  public enum Unknown {
    DISCHARGE,
    BED_SLOPE,
    WATER_DEPTH,
    BASE_WIDTH
  }

  /// Base width or the channel width for rectangular sections.
  double baseWidth;
  Unknown unknown;

  /// Calculated properties
  double wettedArea, wettedPerimeter;


  /// Constructor
  this() {
    this.unknown = Unknown.DISCHARGE;
  }

  /// Initialize the RectangularOpenChannel with the unknown as given
  this(Unknown u) {
    this.unknown = u;
  }

  /++ 
  + Solve for the unknown discharge.
  +/
  void solveForDischarge() {
    wettedArea = baseWidth * waterDepth;
    wettedPerimeter = baseWidth + 2 * waterDepth;
    hydraulicRadius = wettedArea / wettedPerimeter;
    averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0/3));
    discharge = averageVelocity * wettedArea;
  }

  /++ 
  + Setters
  +/
  void setBaseWidth(double b) {
    baseWidth = b;
  }
}
