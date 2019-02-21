module libs.utils.hydraulics;

import std.math : pow;

import libs.utils.constants;
import libs.utils.tables;
import libs.utils.geometry_calculators;

/**
    Calculates the velocity head.
    Params:
        v = Velocity
*/
double velocityHead(double v)
{
    return pow(v, 2) / (2 * GRAVITY);
}

/**
    Calculates the length of hydraulic jump.
    Params:
        f = Froude number
    Returns:
        Length of jump
*/
float hydraulicJump(float f)
{
    double length = 0;

    // Get the first and second row of the table
    float[23] froudeNumbers = HYDRAULIC_JUMP_RATIO[0];
    float[23] hydraulicJumps = HYDRAULIC_JUMP_RATIO[1];

    for (int i = 0; i < (froudeNumbers.length - 1); i++)
    {
        if (f >= froudeNumbers[i] && f < froudeNumbers[i+1])
        {
            length = interpolate(hydraulicJumps[i],
                                hydraulicJumps[i + 1],
                                froudeNumbers[i],
                                f,
                                froudeNumbers[i + 1]);
        }
    }

    return length;
}