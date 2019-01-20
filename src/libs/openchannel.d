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
    const double DEPTH_TRIAL_INCREMENT = 0.00001;
    const double SLOPE_TRIAL_INCREMENT = 0.0000001;

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
        BASE_WIDTH
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

    protected FlowType flowType;

    protected double hydraulicDepth;
    protected double dischargeIntensity;
    protected double criticalDepth;
    protected double criticalSlope;

    protected bool isCalculationSuccess;
    protected string errorMessage;

    /** ****************************************
    * Getters
    ***************************************** */

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

    /** ***************************************
    * Setters
    **************************************** */
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

    /**
    * Methods
    */
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

    protected bool isValidManning()
    {
        /**
        * Manning's roughness error checking
        */
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

        errorMessage = "Calculation successful.";
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

        if (bedSlope <= 0.0)
        {
            errorMessage = "Bed slope must be set greater than zero.";
            return false;
        }

        errorMessage = "Calculation successful.";
        return true;
    }

    protected bool isValidWaterDepth(Unknown u) {
        if (isNaN(waterDepth) && u != Unknown.WATER_DEPTH) {
            errorMessage = "Water depth must be set to numeric.";
            return false;
        }

        if (waterDepth < 0.0)
        {
            errorMessage = "Water depth must be set greater than zero.";
            return false;
        }

        errorMessage = "Calculation successful.";
        return true;
    }

    protected bool isValidInputs(A...) (A a) {
        bool res;
        foreach(b; a) {
            res = res && b;
        }

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
