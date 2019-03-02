# hydroflow

A D-library for hydraulics calculations. This library was created to aide civil engineers and hydraulics engineers in calculation phase of their design or analysis.



#### Major Features

- [x] Open Channel

- [ ] Simple Weirs

- [ ] Diversion Dam Analysis
	- [x] Sharp-crested weir
	- [x] Broad-crested weir
	- [ ] Ogee-shaped weir
- [ ] Reservoir construction and operation studies



### Usage

Only one import is necessary to use the library.

```D
import hydroflow;
```

All submodules will be imported by this module.

### Solutions:

#### 1. Rectangular Open Channel

Say we are given a rectangular channel problem and the unknown is the depth of the water in the channel:

| Given                              |              Value |
| :--------------------------------- | -----------------: |
| Dicharge, Q                        | 1.0  m<sup>3</sup> |
| Bed Slope, S                       |              0.001 |
| Base Width, b                      |              1.0 m |
| Manning's Roughness Coefficient, n |              0.015 |

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

### Using Different Unit

By default, the unit used is in metric. There are two (2) units available, the other is the english system.

To set the unit to english:
```D
RectangularOpenChannel roc = new RectangularOpenChannel();
roc.setUnit = roc.Units.ENGLISH;
```

#### 2. Analysis of Sharp-Crested (Gated) Weirs
Currently, the analysis for sharp-crested weirs only support metric system (meters, meters/second, cubic meters/sec).
```D
SharpCrestedWeir scw = new SharpCrestedWeir();

scw.setDischarge = 100;
scw.setUSApronElev = 50;
scw.setDSApronElev = 49.4;
scw.setCrestLength = 30;
scw.setCrestElev = 52;
scw.setTailwaterElev = 52.5;

if (scw.analysis())
{
	// If the analysis has returned no error during 
	// calculation and error checking.
	writeln("Afflux elevation: ", scw.getAffluxElevation);
} 
else
{
	// Displays the error message.
	writeln(scw.errorMessage);
}
```