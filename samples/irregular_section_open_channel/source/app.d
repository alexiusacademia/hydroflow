import std.stdio;

import hydroflow;

void main()
{
	IrregularSectionOpenChannel isc = new IrregularSectionOpenChannel();
	
	isc.setUnknown = isc.Unknown.DISCHARGE;

	isc.addPoint(new Point(0, 0));
	isc.addPoint(new Point(0, -1));
	isc.addPoint(new Point(1, -1));
	isc.addPoint(new Point(1, 0));

	isc.setManningRoughness = 0.015;
	isc.setBedSlope = 0.001;

	if (isc.solve)
	{
		writeln("Discharge: ", isc.getDischarge);
	} else  {
		writeln(isc.errorMessage);
	}
}
