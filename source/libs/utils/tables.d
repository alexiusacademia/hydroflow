module libs.utils.tables;

const float[23][2] HYDRAULIC_JUMP_RATIO = [
    // Froude numbers
    [
        1.6, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.5, 5, 5.5, 6,
         7, 8, 9, 10, 12, 14, 16, 18, 19.2
    ],
    // Length of jump corresponding to the above froude number
    [
        3.77, 4.35, 4.56, 4.77, 4.96, 5.13, 5.28, 5.43, 5.5, 5.6, 5.75, 5.87, 
        5.95, 6.02, 6.09, 6.13, 6.14, 6.13, 6.03, 5.91, 5.75, 5.57, 5.47
    ]
];