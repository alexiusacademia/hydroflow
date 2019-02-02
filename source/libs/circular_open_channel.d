module libs.circular_open_channel;

/// Standard modules
import std.math;
import std.stdio;

// Custom modules
import libs.openchannel;

class CircularOpenChannel : OpenChannel
{
    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                 Properties                   +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    /// Diameter
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
    // Trial discharge
    private double trialDischarge;
    // Initial increment for trial and error
    private double increment;

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
        // Reset variables
        trialDischarge = 0;
        increment = 0.000001;

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
        if (isValidInputs(isValidDiameter(Unknown.DISCHARGE), isValidBedSlope(Unknown.DISCHARGE),
                isValidWaterDepth(Unknown.DISCHARGE), isValidManning))
        {
            calculateWettedProperties();

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
            waterDepth = 0;

            const allowedDiff = discharge * ERROR;

            // Start of trial and error
            while (abs(discharge - trialDischarge) > allowedDiff)
            {
                waterDepth += increment;

                // Check to make sure water depth is not greater than diameter
                if (waterDepth > diameter)
                {
                    errorMessage = "Diameter of the pipe is insufficient to hold the discharge.";
                    return false;
                }

                calculateWettedProperties();

                // Check if wetted perimeter is zero.
                // Cancel the calculation is so, which will yield infinity in calculation
                // of hydraulic radius, R.
                if (wettedPerimeter == 0.0)
                {
                    errorMessage = "Perimeter shall be non-zero positive result. Please check your dimensions";
                    return false;
                }

                calculateTrialDischarge();

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

    /// Solve for the unknown bed slope
    private bool solveForBedSlope()
    {
        if (isValidInputs(isValidDiameter(Unknown.BED_SLOPE), isValidWaterDepth(Unknown.BED_SLOPE),
                isValidDischarge(Unknown.BED_SLOPE), isValidManning))
        {
            bedSlope = increment;

            const allowedDiff = discharge * ERROR;

            // Start of trial and error
            while (trialDischarge < discharge)
            {
                bedSlope += increment;
                writeln(bedSlope);

                calculateWettedProperties();

                // Check if wetted perimeter is zero.
                // Cancel the calculation is so, which will yield infinity in calculation
                // of hydraulic radius, R.
                if (wettedPerimeter == 0.0)
                {
                    errorMessage = "Perimeter shall be non-zero positive result. Please check your dimensions";
                    return false;
                }

                calculateTrialDischarge();
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

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +              Helper Functions                +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    private void calculateWettedProperties()
    {
        float theta;
        float aTri; // Area of central triangle
        float aSec; // Area of sector

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
            aSec = PI * pow(diameter, 2) * (360 - theta) / 1440;
            wettedArea = aSec + aTri;
            wettedPerimeter = PI * diameter * (360 - theta) / 360;
        }
        else
        {
            aSec = theta * PI * pow(diameter, 2) / 1440;
            wettedArea = aSec - aTri;
            wettedPerimeter = PI * diameter * theta / 360;
        }
    }

    private void calculateTrialDischarge()
    {
        hydraulicRadius = wettedArea / wettedPerimeter;
        averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
        trialDischarge = averageVelocity * wettedArea;
    }
}
