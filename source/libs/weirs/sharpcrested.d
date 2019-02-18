/**
    libs.weirs.sharpcrested module
    Module for hydraulic analysis of sharp crested weirs used in diversion dams.
*/
module libs.weirs.sharpcrested;

import libs.weirs.weir;

import std.math: abs;

/**
    SharpCrestedWeir class.
    Contains fields and methods for hydraulic calculations
    of sharp crested weirs.
*/
class SharpCrestedWeir : Weir
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
            correction;

    /**
        Empty constructor.
    */
    this()
    {

    }

    //++++++++++++++++++++++++++++++++++++++++++++++
    //                  Methods                    +
    //+++++++++++++++++++++++++++++++++++++++++++++/
    void analysis()
    {
        double trialDischarge = 0;

        dischargeIntensity = discharge / crestLength;
        affluxElevation += TRIAL_INCREMENT;

        while (abs(discharge - trialDischarge)) 
        {
            affluxElevation += TRIAL_INCREMENT;
            dA = affluxElevation - usApronElev;
            vA = dischargeIntensity / dA;
        }
    }
}