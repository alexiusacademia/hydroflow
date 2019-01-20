module src.libs.openchannel_rectangular;

import std.math;
import src.libs.openchannel;
import std.stdio;

class RectangularOpenChannel : OpenChannel
{

  /// Base width or the channel width for rectangular sections.
  double baseWidth;

  /// Unknown, to be calculated
  Unknown unknown;

  /// Calculated properties
  double wettedArea, wettedPerimeter;

  /// Empty Constructor
  this()
  {
    this.unknown = Unknown.DISCHARGE;
  }

  /// Initialize the RectangularOpenChannel with the unknown as given
  this(Unknown u)
  {
    this.unknown = u;
  }

  /++ 
  + Solve for the unknown discharge.
  +/
  void solveForDischarge()
  {
    if (!isValidInputs(isValidBaseWidth(Unknown.DISCHARGE),
                      isValidBedSlope(Unknown.DISCHARGE),
                      isValidManning()))
    {
      wettedArea = baseWidth * waterDepth;
      wettedPerimeter = baseWidth + 2 * waterDepth;

      if (wettedPerimeter == 0.0) {
        return;
      }

      hydraulicRadius = wettedArea / wettedPerimeter;
      averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
      discharge = averageVelocity * wettedArea;

      writeln(errorMessage);
    }
  }

  /++ 
  + Setters
  +/
  void setBaseWidth(double b)
  {
    baseWidth = b;
  }

  private bool isValidBaseWidth(Unknown u)
  {
    /**
    * Base width error checking.
    */
    if (isNaN(baseWidth) && (u != Unknown.BASE_WIDTH))
    {
      errorMessage = "Base width must be numeric.";
      return false;
    }

    if (baseWidth < 0.0 && u != Unknown.BASE_WIDTH)
    {
      errorMessage = "Base width must be greater than zero.";
      return false;
    }

    errorMessage = "Calculation successful.";
    return true;
  }
}
