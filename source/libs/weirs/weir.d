/**
    libs.weirs.weir module
*/
module libs.weirs.weir;

/**
    Base class for weirs
*/
class Weir 
{
    /// Total discharge that will flow over a weir.
    double discharge;

    double crestLength;

    double crestElev;

    double usApronElev;
    
    double dsApronElev;

    double tailwaterElev;

    double dischargeIntensity;

    double calculatedDischargeIntensity;
}