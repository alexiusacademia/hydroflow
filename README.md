# hydroflow

### v1.0.0

A D-library for hydraulics calculations. This library was created to aide civil engineers and hydraulics engineers in calculation phase of their design or analysis.



#### Major Features

- [x] Open Channel

- [ ] Simple Weirs

- [ ] Diversion Dam Analysis

- [ ] Reservoir construction and operation studies



### Usage

Only one import is necessary to use the library.

```D
import hydroflow;
```

All submodules will be imported automatically.



#### 1. Rectangular Open Channel

Say we are given a rectangular channel problem and the unknown is the depth of the water in the channel:

| Given                              | Value      |
| ---------------------------------- | ---------- |
| Dicharge, Q                        | $1.0  m^3$ |
| Bed Slope, S                       | $0.001$    |
| Base Width, b                      | $1.0m$     |
| Manning's Roughness Coefficient, n | 0.015      |

To solve this, you may refer to the code below:

```D
import hydroflow;
import std.stdio;

void main()
{
    RectangularOpenChannel roc = new RectangularOpenChannel();

	roc.setUnknown = roc.Unknown.WATER_DEPTH;

	// Set the given values
	roc.setBedSlope = 0.001;
	roc.setDischarge = 1;
	roc.setBaseWidth = 1;
	roc.setManningRoughness = 0.015;
    
    // Now test if the calculation will be successful
    if (roc.solve())
    {
        writeln(roc.getWaterDepth);
    }
}
```

