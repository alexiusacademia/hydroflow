module libs.utils.hydraulics;

import std.math : pow;

import libs.utils.constants;

double velocityHead(double v)
{
    return pow(v, 2) / (2 * GRAVITY);
}