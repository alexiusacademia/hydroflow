/**
* point module.
* Contains the definition of the Point class.
*/
module libs.utils.point;

/**
*   Used for point objects with x & y coordinates.
*/
class Point 
{
    /// Abscissa
    double x;
    /// Ordinate
    double y;

    /**
    * Constructor.
    * Params:
    *   a = abscissa or x
    *   b = ordinate or y
    */
    this(float a, float b) {
        x = a;
        y = b;
    }
}