/**
* trapezoidal_open_channel module.
* Contains class for the analysis of trapezoidal and triangular channels.
*/
module libs.trapezoidal_open_channel;

// Standard modules
import std.math : pow, sqrt, pow, isNaN, abs;
import std.algorithm : canFind;

// Custom modules
import libs.openchannel;

/**
* Class for the analysis of trapezoidal and triangular channels.
*/
class TrapezoidalOpenChannel : OpenChannel
{
    //++++++++++++++++++++++++++++++++++++++++++++++
    //                Properties                   +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Base width or the channel width for rectangular sections.
    protected double baseWidth;

    /// Sideslope
    protected float sideSlope;

    /// Available unknowns for this class.
    protected Unknown[] availableUnknowns = [
        Unknown.DISCHARGE, Unknown.WATER_DEPTH, Unknown.BED_SLOPE, Unknown.BASE_WIDTH
    ];

    //++++++++++++++++++++++++++++++++++++++++++++++
    //               Constructors                  +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Empty Constructor
    this()
    {
        this.unknown = Unknown.DISCHARGE;
    }

    /// Initialize the RectangularOpenChannel with the unknown as given
    /// Params:
    ///     u = Unknown
    this(Unknown u)
    {
        this.unknown = u;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Setters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /**
    * Sets the width at the smaller base of the channel.
    * Params:
    *   b = Base width
    */
    void setBaseWidth(double b)
    {
        baseWidth = b;
    }

    /**
    * Sets the side slope of the channel. Assumming symmetrical section.
    * Params:
    *   ss = Side slope
    */
    void setSideSlope(float ss)
    {
        sideSlope = ss;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Getters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Returns the base width of the channel.
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

    /// Solve for the unknown discharge.
    private bool solveForDischarge()
    {
        if (isValidInputs(isValidBaseWidth(Unknown.DISCHARGE), isValidBedSlope(Unknown.DISCHARGE),
                isValidWaterDepth(Unknown.DISCHARGE),
                isValidSideslope(Unknown.DISCHARGE), isValidManning))
        {
            wettedArea = (baseWidth + waterDepth * sideSlope) * waterDepth;
            wettedPerimeter = 2 * waterDepth * sqrt(pow(sideSlope, 2) + 1) + baseWidth;

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
        if (isValidInputs(isValidBaseWidth(Unknown.WATER_DEPTH), isValidBedSlope(Unknown.WATER_DEPTH),
                isValidDischarge(Unknown.WATER_DEPTH),
                isValidSideslope(Unknown.WATER_DEPTH), isValidManning))
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

    //++++++++++++++++++++++++++++++++++++++++++++++
    //              Error handling                 +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Base width error checking.
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

    /// Sideslope error checking
    private bool isValidSideslope(Unknown u)
    {
        if (isNaN(sideSlope))
        {
            errorMessage = "Sideslope must be numeric.";
            return false;
        }

        if (sideSlope < 0)
        {
            errorMessage = "Sideslope must be greater than zero.";
            return false;
        }

        errorMessage = "Calculation successful.";
        return true;
    }

    private void solveForCriticalFlow()
    {
        const Q2g = pow(discharge, 2) / GRAVITY_METRIC;

        double tester = 0;

        // Critical depth
        double yc = 0;

        // Critical area, perimeter, hydraulic radius, critical slope
        double Ac = 0, Pc, Rc, Sc;

        // Top width
        double T = 0;

        while (tester < Q2g)
        {
            yc += 0.00001;
            T = baseWidth + 2 * sideSlope * yc;
            Ac = (T + baseWidth) / 2 * yc;
            tester = pow(Ac, 3) / T;
        }

        criticalDepth = yc;

        Pc = 2 * yc * sqrt(pow(this.sideSlope, 2) + 1) + this.baseWidth;
        Rc = Ac / Pc;
        Sc = pow(this.discharge / (Ac * pow(Rc, (2.0 / 3.0))) * this.manningRoughness, 2);
        this.criticalSlope = Sc;

        // Solve for froude number
        const topWidth = this.baseWidth + 2 * this.sideSlope * this.waterDepth;
        this.hydraulicDepth = this.wettedArea / topWidth;
        this.froudeNumber = this.averageVelocity / sqrt(
                this.GRAVITY_METRIC * this.hydraulicDepth);

        // Select the flow type
        calculateFlowType();
    }
}
