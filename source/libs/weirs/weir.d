/**
    libs.weirs.weir module
*/
module libs.weirs.weir;

import std.math : pow;

/**
    Base class for weirs
*/
class Weir 
{
    enum Units
    {
        METRIC,
        ENGLISH
    }

    ///////////////////////////////////////
    //  Constants                        //
    ///////////////////////////////////////
    protected const double ERROR = 0.0001;             // Allowed accuracy in iteration
    
    ///////////////////////////////////////
    //  Properties                       //
    ///////////////////////////////////////
    protected double TRIAL_INCREMENT = 0.0001;
    /// Total discharge that will flow over a weir.
    protected double discharge;
    
    /// Length of the topmost of the crest
    protected double crestLength;

    /// Elevation of crest.
    protected double crestElev;

    /// Elevation of upstream apron.
    protected double usApronElev;
    
    /// Elevation of downstream apron.
    protected double dsApronElev;

    /// Water elevation if there will be no weir.
    protected double tailwaterElev;

    /// Discharge intensity. Discharge per unit width.
    protected double dischargeIntensity;

    /// Discharge intensity used for trial and error.
    protected double calculatedDischargeIntensity;

    /// Elevation of the highest water elevation after weir construction.
    protected double affluxElevation;

    /// Length of hydraulic jump. Downstream apron length can be designed
    /// based on this.
    protected double lengthOfHydraulicJump;

    /// Elevation of pre-jump
    protected double preJumpElev;

    /// Elevation of hydraulic jump.
    protected double jumpElev;

    /// Info about calculation error.
    string errorMessage;

    protected Units unit = Units.METRIC;

    ///////////////////////////////////////
    //  Setters                          //
    ///////////////////////////////////////
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
            discharge = pDischarge * pow(1 / 3.28, 3);
        } 
        else 
        {
            discharge = pDischarge;
        }
    }

    public void setUSApronElev(double elev)
    {
        if (unit == Units.ENGLISH)
        {
            usApronElev = elev / 3.28;
        } 
        else 
        {
            usApronElev = elev;
        }
    }

    public void setDSApronElev(double elev)
    {
        if (unit == Units.ENGLISH)
        {
            dsApronElev = elev / 3.28;
        } 
        else 
        {
            dsApronElev = elev;
        }
    }

    public void setCrestLength(double l)
    {
        if (unit == Units.ENGLISH)
        {
            crestLength = l / 3.28;
        } 
        else 
        {
            crestLength = l;
        }
    }

    public void setCrestElev(double elev)
    {
        if (unit == Units.ENGLISH)
        {
            crestElev = elev / 3.28;
        } 
        else 
        {
            crestElev = elev;
        }
    }

    public void setTailwaterElev(double elev)
    {
        if (unit == Units.ENGLISH)
        {
            tailwaterElev = elev / 3.28;
        } 
        else 
        {
            tailwaterElev = elev;
        }
    }

    ///////////////////////////////////////
    //  Getters                          //
    ///////////////////////////////////////
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
            return discharge;        }
    }

    public double getAffluxElevation()
    {
        if (unit == Units.ENGLISH)
        {
            return affluxElevation * 3.25;
        }
        else
        {
            return affluxElevation;
        }
    }

    public double getLengthOfHydraulicJump()
    {
        if (unit == Units.ENGLISH)
        {
            return lengthOfHydraulicJump * 3.28;
        }
        else
        {
            return lengthOfHydraulicJump;
        }
    }
}