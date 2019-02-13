/**
* openchannel module.
*/
module libs.openchannel;

import std.math;
import std.algorithm;

/++
+ The base class for all open channels.
+/
class OpenChannel
{
    //******************************************
    // Constants
    //*************************************** */
    /// Gravitational acceleration in metric.
    protected const GRAVITY_METRIC = 9.81;
    /// Trial error max to 0.01%
    protected const ERROR = 0.0001;

    // ****************************************
    // Properties
    //*************************************** */
    /**
    * Units options
    */
    enum Units
    {
        METRIC,
        ENGLISH
    }
    /**
    * Flow types. These are the categories in which the calculated froude number
    * is compared to.
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
    /** Unit of measurement.\
     All calculations will be done in metric but both 
     metric and imperial system are supported.
    */
    protected Units unit;

    /// Discharge (Flow Rate)
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

    /// Flow type reconned from the Enum type FlowType
    protected FlowType flowType;
    /// Hydraulic depth
    protected double hydraulicDepth;
    /// Discharge intensity. Discharge divided by the top channel width.
    protected double dischargeIntensity;
    /// Depth of flow that will give critical flow.
    protected double criticalDepth;
    /// Bed slope that will give critical flow.
    protected double criticalSlope;
    /// Available unknowns
    protected Unknown[] availableUnknowns = [Unknown.DISCHARGE];
    /// Variable that tells if the calculation has no error.
    protected bool isCalculationSuccess;
    /// The error or warning message that helps debug or give
    /// information about the calculation results.
    public string errorMessage;

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //               Constructors                  +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    
    /**
    * Empty constructor.
    * The unit is automatically set to S.I. (Metric).
    */
    this()
    {
        unit = Units.METRIC;
    }

    /**
    * Constructor that specifies the unit to be used.
    */
    this(Units u)
    {
        unit = u;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Getters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /** 
    Returns the rate of flow in either cubic meter per second (metric)
    or cubic feet per second (english). 
    */
    public double getDischarge()
    {
        if (unit == Units.ENGLISH)
        {
            return discharge * pow(3.28, 3);
        } else {
            return discharge;
        }
    }

    /** 
     Returns the average velocity in the channel in either  meter per second (metric)
     or feet per second (english). 
    */
    public double getAverageVelocity()
    {
        if (unit == Units.ENGLISH)
        {
            return averageVelocity * 3.28;
        }
        return averageVelocity;
    }

    /**
     Returns the bed (bottom) slope of the channel.
    */
    public double getBedSlope()
    {
        return bedSlope;
    }

    /**
     Returns the water depth in either meter
     or feet.
     */
    public double getWaterDepth()
    {
        if (unit == Units.ENGLISH)
        {
            return waterDepth * 3.28;
        }
        return waterDepth;
    }

    /**
     Returns the wet perimeter in either meter of feet.
    */
    public double getWettedPerimeter()
    {
        if (unit == Units.ENGLISH)
        {
            return wettedPerimeter * 3.28;
        }
        return wettedPerimeter;
    }

    /**
     Returns the wet area in either square meter or
     square foot.
    */
    public double getWettedArea()
    {
        if (unit == Units.ENGLISH)
        {
            return wettedArea * pow(3.28, 2);
        }
        return wettedArea;
    }

    /**
     Returns the hydraulic radius in either meters
     or feet.
    */
    public double getHydraulicRadius()
    {
        if (unit == Units.ENGLISH)
        {
            return hydraulicRadius * 3.28;
        }
        return hydraulicRadius;
    }

    /**
     Returns the froude number
    */
    public double getFroudeNumber()
    {
        return froudeNumber;
    }

    /**
     Retuens the manning's roughness coefficient.
    */
    public double getManningRoughness()
    {
        return manningRoughness;
    }

    /**
     Returns the string representation of type of flow.
    */
    public FlowType getFlowType()
    {
        return flowType;
    }

    /**
     Returns the hydraulic depth in either meter
     or foot.
    */
    public double getHydraulicDepth()
    {   
        if (unit == Units.ENGLISH)
        {
            return hydraulicDepth * 3.28;
        }
        return hydraulicDepth;
    }

    /**
     Returns discharge intensity in either cubic meter per second per meter
     or cubic foot per second per foot.
    */
    public double getDischargeIntensity()
    {
        if (unit == Units.ENGLISH)
        {
            return dischargeIntensity * pow(3.28, 2);
        }
        return dischargeIntensity;
    }

    /**
     Returns critical depth in either meters or feet.
    */
    public double getCriticalDepth()
    {
        if (unit == Units.ENGLISH)
        {
            return criticalDepth * 3.28;
        }
        return criticalDepth;
    }

    /**
     Returns the slope of the critical flow for the channel.
    */
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

    //++++++++++++++++++++++++++++++++++++++++++++++ 
    //                 Setters                     +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /**
     Set the bed slope of the channel.
     Params:
        pBedSlope = Bed or bottom slope of the channel.
    */
    public void setBedSlope(double pBedSlope)
    {
        bedSlope = pBedSlope;
    }

    /**
     Sets the discharge.
     Params:
        pDeischarge = discharge in either cubic meter per second or
     cubic foot per second.
    */
    public void setDischarge(double pDischarge)
    {
        if (unit == Units.ENGLISH)
        {
            discharge = pDischarge / pow(3.28, 3);
        } 
        else 
        {
            discharge = pDischarge;
        }
    }

    /**
     Sets the water depth.
     Params:
        pWaterDepth = Water depth in either meter or foot.
    */
    public void setWaterDepth(double pWaterDepth)
    {
        waterDepth = pWaterDepth;
    }

    /**
     Sets the manning roughness coefficient.
     Params:
        pManningRoughness = Manning's roughness coefficient.
    */
    public void setManningRoughness(double pManningRoughness)
    {
        manningRoughness = pManningRoughness;
    }

    /**
     Sets the unknown based on the available unknowns of a specific channel type.
     Params:
        u = Unknown.
    */
    public void setUnknown(Unknown u)
    {
        unknown = u;
    }

    //++++++++++++++++++++++++++++++++++++++++++++++
    //                  Methods                    +
    //+++++++++++++++++++++++++++++++++++++++++++++/
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

    protected bool isValidDischarge(Unknown u)
    {
        if (isNaN(discharge) && u != Unknown.DISCHARGE)
        {
            errorMessage = "Discharge must be numeric.";
            return false;
        }

        if (discharge < 0 && u != Unknown.DISCHARGE)
        {
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

        if (res)
            errorMessage = "Calculation successful.";
        return res;
    }

}
