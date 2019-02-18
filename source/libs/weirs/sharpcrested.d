/**
    libs.weirs.sharpcrested module
    Module for hydraulic analysis of sharp crested weirs used in diversion dams.
*/
module libs.weirs.sharpcrested;

import libs.weirs.weir;
import libs.utils.constants;
import libs.utils.hydraulics;

import std.math: abs, pow, sqrt;

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
    void analysis()
    {
        double trialDischarge = 0;

        // Reset increment to default
        TRIAL_INCREMENT = 0.0001;

        dischargeIntensity = discharge / crestLength;
        affluxElevation += TRIAL_INCREMENT;
        const allowedDiff = discharge * ERROR;

        // Calculation for the afflux elevation
        while (abs(dischargeIntensity - calculatedDischargeIntensity) > allowedDiff) 
        {
            affluxElevation += TRIAL_INCREMENT;
            dA = affluxElevation - usApronElev;
            vA = dischargeIntensity / dA;
            hA = pow(vA, 2) / (2 * GRAVITY);
            eE = affluxElevation + hA;
            ho = eE - crestElev;
            co = 3.33 * (1 + 0.259 * pow(ho, 2) / pow(dA, 2));
            h1 = affluxElevation - crestElev;
            h2 = tailwaterElev - crestElev;
            h2_h1 = h2 / h1;
            if (h2 <= 0)
            {
                correction = 1;
            }
            else
            {
                correction = pow((1 - pow(h2_h1, (3.0/2.0))), 0.385);
            }
            cs = co * correction;
            calculatedDischargeIntensity = cs / 1.811 * pow(ho, (3.0 / 2.0));

            // My root-finding acceleration
            if (calculatedDischargeIntensity < dischargeIntensity)
            {
                TRIAL_INCREMENT *= 2.1;
            }
            else
            {
                affluxElevation -= TRIAL_INCREMENT;
                TRIAL_INCREMENT *= 0.75;
            }
            // End of root finding acceleration
        }

        // Calculation for the hydraulic jump
        double d1,                      // Pre-jump height
                d2,                     // Hydraulic jump height
                he,
                he2 = 0,                // Pre-jump height to energy grade elevation
                v1,
                hv1,
                f;                      // Froude number
        
        TRIAL_INCREMENT = 0.0001;       // Reset
        d1 = 0;

        while (abs(he - he2) > ERROR)
        {
            d1 += TRIAL_INCREMENT;
            v1 = dischargeIntensity / d1;
            hv1 = velocityHead(v1);
            he2 = d1 + hv1;
            d2 = (-1 * d1 / 2) + sqrt((pow(d1, 2) / 4.0) + (2 * pow(v1, 2) * d1 / GRAVITY));
            f = v1 / sqrt(d1 * GRAVITY);
        }
    }
}