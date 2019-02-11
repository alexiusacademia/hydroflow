/**
* hydroflow module.
* Does all the initializations of the library including
* public and private imports.
*
* Authors:
*   [Alexius Academia]
* License:
*   Boost
* Copyright:
*   (c) 2019
*/

module hydroflow;

public {
    import libs.irregular_section_open_channel;
    import libs.rectangular_open_channel;
    import libs.trapezoidal_open_channel;
    import libs.circular_open_channel;

    import libs.utils.point;
}