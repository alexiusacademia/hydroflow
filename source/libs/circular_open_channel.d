/**
* Module for analysis of circular shaped open channels.
* 
* Note: Careful for the flowing full channel as this module
*   calculates even if the channel is full, even though that case
*   falls on closed conduits.
* 
*/
module libs.circular_open_channel;

/// Standard modules
import std.math : sqrt, abs, pow, isNaN, PI, sin, acos;
import std.algorithm : canFind;

/// Custom modules
import libs.openchannel;

/**
* Subclass of OpenChannel for the calculation and 
* analysis of circular sections.
*/
class CircularOpenChannel : OpenChannel
{
    //++++++++++++++++++++++++++++++++++++++++++++++
    //                Properties                   +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /// Pipe diameter
    protected double diameter;
    /// More than half full
    private bool almostFull;
    /// Percentage full
    private double percentFull;
    /// Area of central triangle
    private double triangleArea;
    /// Trial discharge
    private double trialDischarge;
    /// Initial increment for trial and error
    private double increment;
    /// Available unknowns for this section.
    private Unknown[] availableUnknowns = [
        Unknown.DISCHARGE, Unknown.WATER_DEPTH, Unknown.BED_SLOPE
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
    this(Unknown u)
    {
        unknown = u;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Setters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /**
    * Sets the pipe diameter.
    * Params:
    *   d = Diameter given.
    */
    void setDiameter(double d)
    {
        diameter = d;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Getters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /**
    * Gets the diameter of the pipe. 
    * Returns:
    *   The pipe diameter.
    */
    double getDiameter()
    {
        return diameter;
    }

    /** 
    * Shows if the pipe is more than half full. 
    * Returns:
    *   True if the water depth if greater than the radius of the pipe.
    */
    bool isAlmostFull()
    {
        return almostFull;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++
    //                  Methods                    +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    /**
    * Solution summary.
    * To be called in the application API.
    */

    bool solve()
    {
        // Reset variables
        trialDischarge = 0;
        increment = 0.000001;

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
                solveForPercentFull();
                return true;
            }
            break;
        case Unknown.WATER_DEPTH:
            if (solveForWaterDepth)
            {
                solveForCriticalFlow();
                solveForPercentFull();
                return true;
            }
            break;
        case Unknown.BED_SLOPE:
            if (solveForBedSlope)
            {
                solveForCriticalFlow();
                solveForPercentFull();
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
    *   True if the calculation for discharge is successful.
    */
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

    /**
    * Solve for the unknown water depth.
    * Returns:
    *   True if the calculation for water depth is successful.
    */
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

    /**
    * Solve for the unknown bed slope.
    * Returns:
    *   True if the calculation is successful.
    */
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

    //++++++++++++++++++++++++++++++++++++++++++++++
    //              Error handling                 +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    
    /**
    * Base width error checking.
    * Params:
    *   u = The unknown for the channel.
    * Returns:
    *   True if the diameter given is valid.
    */
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

    //++++++++++++++++++++++++++++++++++++++++++++++
    //              Helper Functions                +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /**
    * Calculates properties such as wetted area and wetted perimeter.
    */
    private void calculateWettedProperties()
    {
        float theta;
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
        triangleArea = pow(diameter, 2) * sin(theta * PI / 180) / 8;

        // Calculate area of sector
        if (almostFull)
        {
            aSec = PI * pow(diameter, 2) * (360 - theta) / 1440;
            wettedArea = aSec + triangleArea;
            wettedPerimeter = PI * diameter * (360 - theta) / 360;
        }
        else
        {
            aSec = theta * PI * pow(diameter, 2) / 1440;
            wettedArea = aSec - triangleArea;
            wettedPerimeter = PI * diameter * theta / 360;
        }
    }

    /**
    * Calculates discharge for the trial and error loop.
    */
    private void calculateTrialDischarge()
    {
        hydraulicRadius = wettedArea / wettedPerimeter;
        averageVelocity = (1.0 / manningRoughness) * sqrt(bedSlope) * pow(hydraulicRadius, (2.0 / 3));
        trialDischarge = averageVelocity * wettedArea;
    }

    /**
    * Solves the top width of the water in a circular section for a 
    * given water depth.
    * Params:
    *   y = Height of the water.\
    *   triangleArea = Area of triangle consisting of water intersection with the pipe and center point.\
    *   almostFull = A boolean indicating if y is more than half of the pipe diameter.
    * Returns:
    *   The top width of the water.
    */
    private double solveForTopWidth(double y, double triangleArea, bool almostFull)
    {
        double topWidth;
        double triangleHeight;

        if (almostFull)
        {
            triangleHeight = y - this.diameter / 2;
        }
        else
        {
            triangleHeight = this.diameter / 2 - y;
        }
        topWidth = 2 * triangleArea / triangleHeight;

        return topWidth;
    }

    /**
    * Solve for the percentage of height of water over pipe diameter.
    * 100% means the pipe is flowing full, in this case, the problem no longer
    * behaves as open channel.
    */
    private void solveForPercentFull()
    {
        percentFull = this.waterDepth / this.diameter * 100;
    }

    /**
    * Analyzes the criticality of the flow.
    */
    private void solveForCriticalFlow()
    {
        // Q^2 / g
        double Q2g = pow(discharge, 2) / GRAVITY_METRIC;

        // Other side of equation
        double tester = 0;

        // Critical depth
        double yc = 0.0;

        // Critical area, perimeter, hydraulic radius, critical slope
        double Ac = 0, Pc = 0, Rc, Sc;

        // Top width
        double T = 0;

        // Angle of water edges from the center
        double thetaC = 0;

        // Triangle at critical flow
        double aTriC = 0;

        // Sector at critical flow
        double aSecC;

        while (tester < Q2g)
        {
            yc += 0.0001;

            // Calculate theta
            if (yc > (diameter / 2))
            {
                // Almost full
                thetaC = 2 * acos((2 * yc - diameter) / diameter) * 180 / PI;
            }
            else
            {
                // Less than half full
                thetaC = 2 * acos((diameter - 2 * yc) / diameter) * 180 / PI;
            }

            // Calculate area of triangle
            aTriC = pow(diameter, 2) * sin(thetaC * PI / 180) / 8;
            T = solveForTopWidth(yc, aTriC, (yc > (diameter / 2)));
            // Calculate area of sector
            if (yc > (diameter / 2))
            {
                aSecC = PI * pow(diameter, 2) * (360 - thetaC) / 1440;
                Ac = aSecC + aTriC;
                Pc = PI * diameter * (360 - thetaC) / 360;
            }
            else
            {
                aSecC = thetaC * PI * pow(diameter, 2) / 1440;
                Ac = aSecC - aTriC;
                Pc = PI * diameter * thetaC / 360;
            }

            // Compare the equation for equality  
            tester = pow(Ac, 3) / T;
        }

        // Pass to global variable
        criticalDepth = yc;

        // Hydraulic radius at critical flow
        Rc = Ac / Pc;

        Sc = pow((discharge / (Ac * pow(Rc, (2.0 / 3.0))) * manningRoughness), 2);
        criticalSlope = Sc;

        // Solve for froude number
        hydraulicDepth = wettedArea / solveForTopWidth(waterDepth, triangleArea, almostFull);
        froudeNumber = averageVelocity / sqrt(GRAVITY_METRIC * hydraulicDepth);

        // Select the flow type
        calculateFlowType();
    }
}
