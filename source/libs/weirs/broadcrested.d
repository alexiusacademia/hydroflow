/**
    libs.weirs.sharpcrested module
    Module for hydraulic analysis of sharp crested weirs used in diversion dams.
*/
module libs.weirs.broadcrested;

import libs.weirs.weir;
import libs.utils.constants;
import libs.utils.hydraulics;

import std.math: abs, pow, sqrt, isNaN;
import std.stdio;

/**
    SharpCrestedWeir class.
    Contains fields and methods for hydraulic calculations
    of sharp crested weirs.
*/
class BroadCrestedWeir : Weir
{
    ///////////////////////////////////////
    //  Properties                       //
    ///////////////////////////////////////

    double dA,              // Depth at approach
            vA,             // Velocity at approach
            hA,             // Height at approach
            eE,             // Energy elevation
            ho,             
            h1,
            h2,
            h2_h1,
            co,
            correction,
            cs;
    
    /**
        Empty constructor.
    */
    this()
    {

    }

    //++++++++++++++++++++++++++++++++++++++++++++++
    //                  Methods                    +
    //+++++++++++++++++++++++++++++++++++++++++++++/

    /**
        Performs the hydraulic analysis for sharp-crested (gated) weirs/diversion dams.
    */
    bool analysis()
    {
        
    }

    private bool isValidInputs()
    {
        // Check for each input
        if (isNaN(discharge))
        {
            errorMessage = "Discharge must be set.";
            return false;
        }

        if (isNaN(crestElev))
        {
            errorMessage = "Crest elevation must be set.";
            return false;
        }

        if (isNaN(crestLength))
        {
            errorMessage = "Crest length must be set.";
            return false;
        }

        if (isNaN(usApronElev))
        {
            errorMessage = "Elevation of upstream apron must be set.";
            return false;
        }

        if (isNaN(dsApronElev))
        {
            errorMessage = "Elevation of downstream apron must be set.";
            return false;
        }

        if (isNaN(tailwaterElev))
        {
            errorMessage = "Elevation of tail water must be set.";
            return false;
        }

        // Check if tailwater if lower than downstream apron
        if (tailwaterElev < dsApronElev) 
        {
            errorMessage = "Tailwater elevation must be set higher or the same as downstream apron.";
            return false;
        }

        // Check crest is lower than upstream apron
        if (crestElev < usApronElev)
        {
            errorMessage = "Crest elevation must be the same or higher then upstream apron.";
            return false;
        }

        return true;
    }
}