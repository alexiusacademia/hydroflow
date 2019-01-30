module src.libs.openchannel_circular;

/// Standard modules
import std.math;
import std.stdio;

// Custom modules
import src.libs.openchannel;

class CircularOpenChannel : OpenChannel
{
    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                 Properties                   +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Sideslope
    double diameter;

    /* Calculated properties */
    // Wetted properties
    private double wettedArea, wettedPerimeter;
    // More than half full
    private bool almostFull;
    // Percentage full
    private double percentFull;
    // Area of central triangle
    private double triangleArea;

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                Constructors                  +
    +++++++++++++++++++++++++++++++++++++++++++++++/
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

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Setters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /++ Sets the pipe diameter. +/
    void setDiameter(double d)
    {
        diameter = d;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Getters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/

    /++ Returns the diameter of the pipe. +/
    double getDiameter()
    {
        return diameter;
    }

    /++ Shows if the pipe is more than half full. +/
    bool isAlmostFull()
    {
        return almostFull;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                   Methods                    +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Solution summary.
    /// To be called in the application API
    bool solve()
    {
        switch (this.unknown)
        {
        case Unknown.DISCHARGE:
            if (solveForDischarge)
            {
                return true;
            }
            break;
        case Unknown.WATER_DEPTH:
            if (solveForWaterDepth)
            {
                return true;
            }
            break;
        case Unknown.BASE_WIDTH:
            if (solveForBaseWidth)
            {
                return true;
            }
            break;
        case Unknown.BED_SLOPE:
            if (solveForBedSlope)
            {
                return true;
            }
            break;
        default:
            break;
        }

        return false;
    }

    /// Solve for the unknown discharge.
    private bool solveForDischarge()
    {
        float theta;
        float aTri; // Area of central triangle
        float aSec; // Area of sector
        if (isValidInputs(isValidDiameter(Unknown.DISCHARGE), isValidBedSlope(Unknown.DISCHARGE),
                isValidWaterDepth(Unknown.DISCHARGE), isValidManning))
        {
            almostFull = (waterDepth >= (diameter / 2.0));

            // Calculate theta
            if (almostFull)
            {
                theta = 2 * acos((2 * waterDepth - diameter) / diameter) * 180 / PI;
            }
            else
            {
                theta = 2 * acos((diameter - 2 * waterDepth) / diameter) * 180 / PI;
            }

            // Calculate the area of central triangle
            aTri = pow(diameter, 2) * sin(theta * PI / 180) / 8;

            // Calculate area of sector
            if (almostFull)
            {
                aSec = PI * pow(d, 2) * (360 - theta) / 1440;
                wettedArea = aSec + aTri;
                wettedPerimeter = PI * diameter * (360 - theta) / 360;
            }
            else
            {
                aSec = theta * PI * pow(diameter, 2) / 1440;
                wettedArea = aSec - aTri;
                wettedPerimeter = PI * diameter * theta / 360;
            }

            // Check if wetted perimeter is zero.
            // Cancel the calculation is so, which will yield infinity in calculation
            // of hydraulic radius, R.
            if (wettedPerimeter == 0.0)
            {
                errorMessage = "Perimeter shall be non-zero positive result. Please check your dimensions";
                return false;
            }

            hydraulicRadius = wettedArea / wettedPerimeter;
            averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius,
                    (2.0 / 3));
            discharge = averageVelocity * wettedArea;

            return true;
        }
        else
        {
            return false;
        }
    }

    /// Solve for the unknown water depth
    private bool solveForWaterDepth()
    {
        if (isValidInputs(isValidDiameter(Unknown.WATER_DEPTH), isValidBedSlope(Unknown.WATER_DEPTH),
                isValidDischarge(Unknown.WATER_DEPTH), isValidManning))
        {

            double trialDischarge = 0, increment = 0.0001;
            waterDepth = 0;

            const allowedDiff = discharge * ERROR;

            // Start of trial and error
            while (abs(discharge - trialDischarge) > allowedDiff)
            {
                waterDepth += increment;
                wettedArea = (baseWidth + waterDepth * sideSlope) * waterDepth;
                wettedPerimeter = 2 * waterDepth * sqrt(pow(sideSlope, 2) + 1) + baseWidth;

                // Check if both base width and water depth are zero.
                // Cancel the calculation is so, which will yield infinity in calculation
                // of hydraulic radius, R.
                if (wettedPerimeter == 0.0)
                {
                    errorMessage = "Both water depth and base width cannot be set to zero.";
                    return false;
                }

                hydraulicRadius = wettedArea / wettedPerimeter;
                averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius,
                        (2.0 / 3));
                trialDischarge = averageVelocity * wettedArea;

                /+
                + My root finding algorithm
                +/
                if (trialDischarge < discharge)
                {
                    increment *= 2.1;
                }

                if (trialDischarge > discharge)
                {
                    waterDepth -= increment;
                    increment *= .75;
                }
                /+
                + End of root finding algorithm
                +/
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    /// Solve for the unknown base width
    private bool solveForBaseWidth()
    {
        if (isValidInputs(isValidWaterDepth(Unknown.BASE_WIDTH), isValidBedSlope(Unknown.BASE_WIDTH),
                isValidDischarge(Unknown.BASE_WIDTH),
                isValidSideslope(Unknown.BASE_WIDTH), isValidManning))
        {

            double trialDischarge = 0, increment = 0.0001;
            baseWidth = 0;

            const allowedDiff = discharge * ERROR;

            // Start of trial and error
            while (abs(discharge - trialDischarge) > allowedDiff)
            {
                baseWidth += increment;
                wettedArea = (baseWidth + waterDepth * sideSlope) * waterDepth;
                wettedPerimeter = 2 * waterDepth * sqrt(pow(sideSlope, 2) + 1) + baseWidth;

                // Check if both base width and water depth are zero.
                // Cancel the calculation is so, which will yield infinity in calculation
                // of hydraulic radius, R.
                if (wettedPerimeter == 0.0)
                {
                    errorMessage = "Both water depth and base width cannot be set to zero.";
                    return false;
                }

                hydraulicRadius = wettedArea / wettedPerimeter;
                averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius,
                        (2.0 / 3));
                trialDischarge = averageVelocity * wettedArea;

                /+
                + My root finding algorithm
                +/
                if (trialDischarge < discharge)
                {
                    increment *= 2.1;
                }

                if (trialDischarge > discharge)
                {
                    baseWidth -= increment;
                    increment *= .75;
                }
                /+
                + End of root finding algorithm
                +/
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    /// Solve for the unknown bed slope
    private bool solveForBedSlope()
    {
        if (isValidInputs(isValidWaterDepth(Unknown.BED_SLOPE), isValidBaseWidth(Unknown.BED_SLOPE),
                isValidDischarge(Unknown.BED_SLOPE),
                isValidSideslope(Unknown.BED_SLOPE), isValidManning))
        {

            double trialDischarge = 0, increment = 0.0000001;
            bedSlope = 0;

            const allowedDiff = discharge * ERROR;

            // Start of trial and error
            while (abs(discharge - trialDischarge) > allowedDiff)
            {
                bedSlope += increment;
                wettedArea = (baseWidth + waterDepth * sideSlope) * waterDepth;
                wettedPerimeter = 2 * waterDepth * sqrt(pow(sideSlope, 2) + 1) + baseWidth;

                // Check if both base width and water depth are zero.
                // Cancel the calculation is so, which will yield infinity in calculation
                // of hydraulic radius, R.
                if (wettedPerimeter == 0.0)
                {
                    errorMessage = "Both water depth and base width cannot be set to zero.";
                    return false;
                }

                hydraulicRadius = wettedArea / wettedPerimeter;
                averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius,
                        (2.0 / 3));
                trialDischarge = averageVelocity * wettedArea;

                /+
                + My root finding algorithm
                +/
                if (trialDischarge < discharge)
                {
                    increment *= 2.1;
                }

                if (trialDischarge > discharge)
                {
                    bedSlope -= increment;
                    increment *= .75;
                }
                /+
                + End of root finding algorithm
                +/
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +               Error handling                 +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Base width error checking.
    private bool isValidDiameter(Unknown u)
    {
        if (isNaN(diameter) && (u != Unknown.PIPE_DIAMETER))
        {
            errorMessage = "Diameter must be numeric.";
            return false;
        }

        if (diameter < 0.0 && u != Unknown.PIPE_DIAMETER)
        {
            errorMessage = "Diameter must be greater than zero.";
            return false;
        }

        errorMessage = "Calculation successful.";
        return true;
    }
}
