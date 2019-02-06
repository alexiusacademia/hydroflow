module libs.openchannel;

import std.math;

/++
    Open Channel

    The base class for all open channels.
+/
class OpenChannel
{
    /** ****************************************
    * Constants
    ***************************************** */
    protected const double GRAVITY_METRIC = 9.81;
    protected const ERROR = 0.0001;            // Trial error max to 1%

    /** ****************************************
    * Properties
    ***************************************** */
    /**
        Flow types. These are the categories in which the calculated froude number
        is compared to.
    */
    public enum FlowType
    {
        CRITICAL,
        SUBCRITICAL,
        SUPERCRITICAL
    }

    /// General available unknowns for open channel.
    public enum Unknown
    {
        DISCHARGE,
        BED_SLOPE,
        WATER_DEPTH,
        BASE_WIDTH,
        PIPE_DIAMETER
    }

    /// Discharge / Flow Rate
    protected double discharge;

    /// Rise over run of the channel.
    protected double bedSlope;

    /// Depth of water measured from the deepest point of the
    /// channel.
    protected double waterDepth;

    /// Manning's roughness coefficient.
    protected float manningRoughness;

    /// Total length of the channel section covered with water.
    protected double wettedPerimeter;

    /// Total area of the channel section covered with water.
    protected double wettedArea;

    /// wettedArea / wettedPerimeter
    protected double hydraulicRadius;

    /// Average velocity over the whole cross section of the channel.
    protected double averageVelocity;

    /// Froude number.
    protected float froudeNumber;

    /// Enum type. (e.g. DISCHARGE, WATER_DEPTH, etc.)
    protected Unknown unknown;

    protected FlowType flowType;

    protected double hydraulicDepth;
    protected double dischargeIntensity;
    protected double criticalDepth;
    protected double criticalSlope;

    protected bool isCalculationSuccess;
    public string errorMessage;

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Getters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    
    /** Returns the rate of flow. */
    public double getDischarge()
    {
        return discharge;
    }

    /** Returns the average velocity in the channel. */
    public double getAverageVelocity()
    {
        return averageVelocity;
    }

    public double getBedSlope()
    {
        return bedSlope;
    }

    public double getWaterDepth()
    {
        return waterDepth;
    }

    public double getWettedPerimeter()
    {
        return wettedPerimeter;
    }

    public double getWettedArea()
    {
        return wettedArea;
    }

    public double getHydraulicRadius()
    {
        return hydraulicRadius;
    }

    public double getFroudeNumber()
    {
        return froudeNumber;
    }

    public double getManningRoughness()
    {
        return manningRoughness;
    }

    public FlowType getFlowType()
    {
        return flowType;
    }

    public double getHydraulicDepth()
    {
        return hydraulicDepth;
    }

    public double getDischargeIntensity()
    {
        return dischargeIntensity;
    }

    public double getCriticalDepth()
    {
        return criticalDepth;
    }

    public double getCriticalSlope()
    {
        return criticalSlope;
    }

    /**
    * Check if an error has occurred.
    * @return isError
    */
    public bool isCalculationSuccessful()
    {
        return isCalculationSuccessful;
    }

    /**
    * Gets the error message.
    * @return errMessage
    */
    public string getErrMessage()
    {
        return errorMessage;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++ 
    +                  Setters                     +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    public void setBedSlope(double pBedSlope)
    {
        bedSlope = pBedSlope;
    }

    public void setDischarge(double pDischarge)
    {
        discharge = pDischarge;
    }

    public void setWaterDepth(double pWaterDepth)
    {
        waterDepth = pWaterDepth;
    }

    public void setManningRoughness(double pManningRoughness)
    {
        manningRoughness = pManningRoughness;
    }

    public void setUnknown(Unknown u) {
        this.unknown = u;
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +                   Methods                    +
    +++++++++++++++++++++++++++++++++++++++++++++++/
    protected void calculateFlowType()
    {
        // Flow type
        if (this.froudeNumber == 1)
        {
            flowType = FlowType.CRITICAL;
        }
        else if (this.froudeNumber < 1)
        {
            flowType = FlowType.SUBCRITICAL;
        }
        else
        {
            flowType = FlowType.SUPERCRITICAL;
        }
    }

    /+++++++++++++++++++++++++++++++++++++++++++++++
    +               Error handling                 +
    +++++++++++++++++++++++++++++++++++++++++++++++/

    /**
    * Manning's roughness error checking
    */
    protected bool isValidManning()
    {
        if (manningRoughness <= 0.0)
        {
            errorMessage = "Manning\'s roughness must be set greater than zero.";
            return false;
        }

        if (isNaN(manningRoughness))
        {
            errorMessage = "Manning\'s roughness must be numeric.";
            return false;
        }

        // errorMessage = "Valid manning's rougness. Calculation successful.";
        return true;
    }

    /**
    * Bed slope error checking
    */
    protected bool isValidBedSlope(Unknown u)
    {
        if (isNaN(bedSlope) && u != Unknown.BED_SLOPE)
        {
            errorMessage = "Bed slope must be numeric.";
            return false;
        }

        if (bedSlope <= 0.0 && u != Unknown.BED_SLOPE)
        {
            errorMessage = "Bed slope must be set greater than zero.";
            return false;
        }

        // errorMessage = "Valid bed slope. Calculation successful.";
        return true;
    }

    /**
    *   Water depth error checking
    */
    protected bool isValidWaterDepth(Unknown u)
    {
        if (isNaN(waterDepth) && u != Unknown.WATER_DEPTH)
        {
            errorMessage = "Water depth must be set to numeric.";
            return false;
        }

        if (waterDepth <= 0.0 && u != Unknown.WATER_DEPTH)
        {
            errorMessage = "Water depth must be set greater than or equal to zero.";
            return false;
        }

        // errorMessage = "Valid water depth. Calculation successful.";
        return true;
    }

    protected bool isValidDischarge(Unknown u) {
        if (isNaN(discharge) && u != Unknown.DISCHARGE) {
            errorMessage = "Discharge must be numeric.";
            return false;
        }

        if (discharge < 0 && u != Unknown.DISCHARGE) {
            errorMessage = "Discharge must be set greater than zero.";
            return false;
        }

        // errorMessage = "Valid discharge. Calculation successful.";
        return true;
    }

    /// Check if all conditions are true
    protected bool isValidInputs(A...)(A a)
    {
        bool res = true;
        foreach (b; a)
        {
            res = res && b;
        }

        if (res) errorMessage = "Calculation successful.";
        return res;
    }

}

class InvalidInputException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}
