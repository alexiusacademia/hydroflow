/**
    libs.weirs.weir module
*/
module libs.weirs.weir;

/**
    Base class for weirs
*/
class Weir 
{
    ///////////////////////////////////////
    //  Constants                        //
    ///////////////////////////////////////
    protected const double ERROR = 0.0001;             // Allowed accuracy in iteration
    
    ///////////////////////////////////////
    //  Properties                       //
    ///////////////////////////////////////
    protected double TRIAL_INCREMENT = 0.0001;
    /// Total discharge that will flow over a weir.
    double discharge;
    
    /// Length of the topmost of the crest
    double crestLength;

    /// Elevation of crest.
    double crestElev;

    /// Elevation of upstream apron.
    double usApronElev;
    
    /// Elevation of downstream apron.
    double dsApronElev;

    /// Water elevation if there will be no weir.
    double tailwaterElev;

    /// Discharge intensity. Discharge per unit width.
    double dischargeIntensity;

    /// Discharge intensity used for trial and error.
    double calculatedDischargeIntensity;

    /// Elevation of the highest water elevation after weir construction.
    double affluxElevation;

    /// Length of hydraulic jump. Downstream apron length can be designed
    /// based on this.
    double lengthOfHydraulicJump;

    /// Elevation of pre-jump
    double preJumpElev;

    /// Elevation of hydraulic jump.
    double jumpElev;

    /// Info about calculation error.
    string errorMessage;
}