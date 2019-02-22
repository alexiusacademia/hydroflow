/**
    libs.weirs.sharpcrested module
    Module for hydraulic analysis of sharp crested weirs used in diversion dams.
*/
module libs.weirs.sharpcrested;

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

    /**
        Performs the hydraulic analysis for sharp-crested (gated) weirs/diversion dams.
    */
    bool analysis()
    {
        if (!isValidInputs) 
        {
            return false;
        }

        // Reset values
        TRIAL_INCREMENT = 0.0001;
        calculatedDischargeIntensity = 0;

        dischargeIntensity = discharge / crestLength;

        // Afflux elevation initial assumption
        affluxElevation = crestElev > tailwaterElev ? crestElev : tailwaterElev;

        // Accuracy closure
        const allowedDiff = discharge * ERROR;

        // Calculation for the afflux elevation
        while (abs(dischargeIntensity - calculatedDischargeIntensity) > allowedDiff) 
        {
            affluxElevation += TRIAL_INCREMENT;
            dA = affluxElevation - usApronElev;
            vA = dischargeIntensity / dA;
            hA = velocityHead(vA);
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
                hv1;
        float f;                        // Froude number
        
        TRIAL_INCREMENT = 0.0001;       // Reset
        d1 = 0;
        he = eE - dsApronElev;

        // Froude number calculation
        // Hydraulic jump calculation
        while (abs(he - he2) > ERROR)
        {
            d1 += TRIAL_INCREMENT;
            v1 = dischargeIntensity / d1;
            hv1 = velocityHead(v1);
            he2 = d1 + hv1;
            d2 = (-1 * d1 / 2) + sqrt((pow(d1, 2) / 4.0) + (2 * pow(v1, 2) * d1 / GRAVITY));
            f = v1 / sqrt(d1 * GRAVITY);
        }

        // Length of hydraulic jump
        if (f < 1.6)
        {
            lengthOfHydraulicJump = 4 * d2;
        } else {
            lengthOfHydraulicJump = hydraulicJump(f);
        }

        preJumpElev = dsApronElev + d1;
        jumpElev = dsApronElev + d2;

        errorMessage = "Calculation successful.";
        return true;
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