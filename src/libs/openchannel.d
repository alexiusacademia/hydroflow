module src.libs.openchannel;

import std.math;

/++ +++++++++++++++++++++
+   Open Channel class
++++++++++++++++++++++ +/
class OpenChannel
{
    /** ****************************************
    * Constants
    ***************************************** */
    const double GRAVITY_METRIC = 9.81;
    // const double DEPTH_TRIAL_INCREMENT = 0.00001;
    // const double SLOPE_TRIAL_INCREMENT = 0.0000001;
    // const TRIAL_INCREMENT = 0.00001;
    const ERROR = 0.0001;            // Trial error max to 1%

    /** ****************************************
    * Properties
    ***************************************** */
    public enum FlowType
    {
        CRITICAL,
        SUBCRITICAL,
        SUPERCRITICAL
    }

    /// Unknowns
    public enum Unknown
    {
        DISCHARGE,
        BED_SLOPE,
        WATER_DEPTH,
        BASE_WIDTH,
        PIPE_DIAMETER
    }

    /// Discharge / Flow Rate
    double discharge;

    double bedSlope;

    double waterDepth;

    float manningRoughness;

    double wettedPerimeter;

    double wettedArea;

    double hydraulicRadius;

    double averageVelocity;

    float froudeNumber;

    Unknown unknown;

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

    public double getDischarge()
    {
        return discharge;
    }

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
