/**
* rectangular_open_channel module.
* Contans class for the analysis of rectangular sections.
* Authors:
*   Alexius Academia
* License:
*   MIT
* Copyright:
*   2019
*/
module libs.rectangular_open_channel;

// Standard modules
import std.math : pow, sqrt, abs, isNaN;
import std.algorithm : canFind;

// Custom modules
import libs.openchannel;

/**
* Class for the analysis of rectangular sections.
*/
class RectangularOpenChannel : OpenChannel
{
  //++++++++++++++++++++++++++++++++++++++++++++++
  //                Properties                   +
  //+++++++++++++++++++++++++++++++++++++++++++++/
  /// Base width or the channel width for rectangular sections.
  protected double baseWidth;
  /// Available unknowns for this class.
  protected Unknown[] availableUnknowns = [
    Unknown.DISCHARGE, Unknown.WATER_DEPTH, Unknown.BED_SLOPE, Unknown.BASE_WIDTH
  ];

  /**
  * Initialize the RectangularOpenChannel with the unknown as given
  * Params:
  *   u = Unknown
  */
  this(Unknown u)
  {
    this.unknown = u;
  }

  //++++++++++++++++++++++++++++++++++++++++++++++ 
  //                 Setters                     +
  //+++++++++++++++++++++++++++++++++++++++++++++/
  /** 
  * Sets the width of the base of the channel.
  * Params:
  *   b = Width of the channel.
  */
  void setBaseWidth(double b)
  {
    baseWidth = b;
  }

  //++++++++++++++++++++++++++++++++++++++++++++++ 
  //                 Getters                     +
  //+++++++++++++++++++++++++++++++++++++++++++++/
  /// Returns the width of the channel.
  double getBaseWidth()
  {
    return baseWidth;
  }

  //++++++++++++++++++++++++++++++++++++++++++++++
  //                  Methods                    +
  //+++++++++++++++++++++++++++++++++++++++++++++/
  // Solution summary.
  // To be called in the application API
  /// Method to be called for the analysis regardless of the unknown.
  bool solve()
  {
    if (!canFind(availableUnknowns, unknown))
    {
      errorMessage = "The specified unknown is not included in the available unknowns.";
      return false;
    }

    switch (this.unknown)
    {
    case Unknown.DISCHARGE:
      if (solveForDischarge)
      {
        solveForCriticalFlow();
        return true;
      }
      break;
    case Unknown.WATER_DEPTH:
      if (solveForWaterDepth)
      {
        solveForCriticalFlow();
        return true;
      }
      break;
    case Unknown.BASE_WIDTH:
      if (solveForBaseWidth)
      {
        solveForCriticalFlow();
        return true;
      }
      break;
    case Unknown.BED_SLOPE:
      if (solveForBedSlope)
      {
        solveForCriticalFlow();
        return true;
      }
      break;
    default:
      break;
    }

    return false;
  }

  /** 
  * Solve for the unknown discharge.
  * Returns:
  *   True if the calculation is successful.
  */
  protected bool solveForDischarge()
  {
    if (isValidInputs(isValidBaseWidth(Unknown.DISCHARGE), isValidBedSlope(Unknown.DISCHARGE),
        isValidWaterDepth(Unknown.DISCHARGE), isValidManning))
    {
      wettedArea = baseWidth * waterDepth;
      wettedPerimeter = baseWidth + 2 * waterDepth;

      // Check if both base width and water depth are zero.
      // Cancel the calculation is so, which will yield infinity in calculation
      // of hydraulic radius, R.
      if (wettedPerimeter == 0.0)
      {
        errorMessage = "Both water depth and base width cannot be set to zero.";
        return false;
      }

      hydraulicRadius = wettedArea / wettedPerimeter;
      averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
      discharge = averageVelocity * wettedArea;

      return true;
    }
    else
    {
      return false;
    }
  }

  /**
  * Solve for the unknown water depth
  * Returns:
  *   True if the calculation is successful. 
  */
  protected bool solveForWaterDepth()
  {
    if (isValidInputs(isValidBaseWidth(Unknown.WATER_DEPTH),
        isValidBedSlope(Unknown.WATER_DEPTH), isValidDischarge(Unknown.WATER_DEPTH), isValidManning))
    {

      double trialDischarge = 0, increment = 0.0001;
      waterDepth = 0;

      const allowedDiff = discharge * ERROR;

      // Start of trial and error
      while (abs(discharge - trialDischarge) > allowedDiff)
      {
        waterDepth += increment;
        wettedArea = baseWidth * waterDepth;
        wettedPerimeter = baseWidth + 2 * waterDepth;

        // Check if both base width and water depth are zero.
        // Cancel the calculation is so, which will yield infinity in calculation
        // of hydraulic radius, R.
        if (wettedPerimeter == 0.0)
        {
          errorMessage = "Both water depth and base width cannot be set to zero.";
          return false;
        }

        hydraulicRadius = wettedArea / wettedPerimeter;
        averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
        trialDischarge = averageVelocity * wettedArea;

        // My root finding algorithm
        if (trialDischarge < discharge)
        {
          increment *= 2.1;
        }

        if (trialDischarge > discharge)
        {
          waterDepth -= increment;
          increment *= .75;
        }
        // End of root finding algorithm
      }
      return true;
    }
    else
    {
      return false;
    }
  }

  /**
  * Solve for the unknown base width
  * Returns:
  *   True if the calculation is successful. 
  */
  protected bool solveForBaseWidth()
  {
    if (isValidInputs(isValidWaterDepth(Unknown.BASE_WIDTH),
        isValidBedSlope(Unknown.BASE_WIDTH), isValidDischarge(Unknown.BASE_WIDTH), isValidManning))
    {

      double trialDischarge = 0, increment = 0.0001;
      baseWidth = 0;

      const allowedDiff = discharge * ERROR;

      // Start of trial and error
      while (abs(discharge - trialDischarge) > allowedDiff)
      {
        baseWidth += increment;
        wettedArea = baseWidth * waterDepth;
        wettedPerimeter = baseWidth + 2 * waterDepth;

        // Check if both base width and water depth are zero.
        // Cancel the calculation is so, which will yield infinity in calculation
        // of hydraulic radius, R.
        if (wettedPerimeter == 0.0)
        {
          errorMessage = "Both water depth and base width cannot be set to zero.";
          return false;
        }

        hydraulicRadius = wettedArea / wettedPerimeter;
        averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
        trialDischarge = averageVelocity * wettedArea;

        // Start of my root finding algorithm
        if (trialDischarge < discharge)
        {
          increment *= 2.1;
        }

        if (trialDischarge > discharge)
        {
          baseWidth -= increment;
          increment *= .75;
        }
        // End of root finding algorithm
        
      }
      return true;
    }
    else
    {
      return false;
    }
  }

  /**
  * Solve for the unknown bed slope
  * Returns:
  *   True if the calculation is successful. 
  */
  protected bool solveForBedSlope()
  {
    if (isValidInputs(isValidWaterDepth(Unknown.BED_SLOPE),
        isValidBaseWidth(Unknown.BED_SLOPE), isValidDischarge(Unknown.BED_SLOPE), isValidManning))
    {

      double trialDischarge = 0, increment = 0.0000001;
      bedSlope = 0;

      const allowedDiff = discharge * ERROR;

      // Start of trial and error
      while (abs(discharge - trialDischarge) > allowedDiff)
      {
        bedSlope += increment;
        wettedArea = baseWidth * waterDepth;
        wettedPerimeter = baseWidth + 2 * waterDepth;

        // Check if both base width and water depth are zero.
        // Cancel the calculation is so, which will yield infinity in calculation
        // of hydraulic radius, R.
        if (wettedPerimeter == 0.0)
        {
          errorMessage = "Both water depth and base width cannot be set to zero.";
          return false;
        }

        hydraulicRadius = wettedArea / wettedPerimeter;
        averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
        trialDischarge = averageVelocity * wettedArea;

        
        // Start of my root finding algorithm
        if (trialDischarge < discharge)
        {
          increment *= 2.1;
        }

        if (trialDischarge > discharge)
        {
          bedSlope -= increment;
          increment *= .75;
        }
        // End of root finding algorithm
        
      }
      return true;
    }
    else
    {
      return false;
    }
  }

  /**
  * Analysis of critical flow.
  */
  protected void solveForCriticalFlow()
  {
    // Hydraulic depth
    hydraulicDepth = wettedArea / baseWidth;

    // Froude number
    froudeNumber = averageVelocity / sqrt(GRAVITY_METRIC * hydraulicDepth);

    // Select the flow type
    calculateFlowType();

    // Discharge intensity
    dischargeIntensity = discharge / baseWidth;

    // Critical depth
    criticalDepth = pow(pow(dischargeIntensity,
        2) / GRAVITY_METRIC, (1.0 / 3.0));
  }

  //++++++++++++++++++++++++++++++++++++++++++++++
  //              Error handling                 +
  //+++++++++++++++++++++++++++++++++++++++++++++/
  /** 
  * Base width error checking.
  * Params:
  *   u = Unknown
  * Returns:
  *   True if base width is valid.
  */
  private bool isValidBaseWidth(Unknown u)
  {
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
