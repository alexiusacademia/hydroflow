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
    protected const double ERROR = 0.002;             // Allowed accuracy in iteration
    
    ///////////////////////////////////////
    //  Properties                       //
    ///////////////////////////////////////
    protected double TRIAL_INCREMENT = 0.0001;
    /// Total discharge that will flow over a weir.
    double discharge;
    /// Length of the topmost of the crest
    double crestLength;

    double crestElev;

    double usApronElev;
    
    double dsApronElev;

    double tailwaterElev;

    double dischargeIntensity;

    double calculatedDischargeIntensity;

    protected double affluxElevation;
}