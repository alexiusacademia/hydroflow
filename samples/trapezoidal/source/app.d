import std.stdio;
import std.datetime;
import std.math;

import hydroflow;

void main()
{
	TrapezoidalOpenChannel toc = new TrapezoidalOpenChannel();
	toc.setUnknown = toc.Unknown.DISCHARGE;
	toc.setUnit = toc.Units.ENGLISH;

	toc.setBaseWidth = 1;
	toc.setDischarge = 1;
	toc.setBedSlope = 0.001;
	toc.setSideSlope = 0;
	toc.setManningRoughness = 0.015;
	toc.setWaterDepth = 0.989;

	if (toc.solve)
	{
		writeln("Base width = ", toc.getBaseWidth);
		writeln("Wet area = ", toc.getWettedArea);
		writeln("Discharge = ", toc.getDischarge);
	} 
	else 
	{
		writeln(toc.errorMessage);
	}
}
