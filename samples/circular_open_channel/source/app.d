import std.stdio;
import std.datetime;
import std.math;

import hydroflow;

void main()
{
	const auto t1 = Clock.currTime;

	CircularOpenChannel coc = new CircularOpenChannel();

	coc.setUnknown = coc.Unknown.DISCHARGE;

	// Set the given values
	coc.setBedSlope = 0.001;
	coc.setDischarge = 1.5;
	coc.setManningRoughness = 0.015;
	coc.setDiameter = 2;
	coc.setWaterDepth = 0.8;

	const success = coc.solve();

	const auto t2 = Clock.currTime;

	writeln("Time: ", t2 - t1);

	if (success)
	{
		writeln("Discharge = ", coc.getDischarge);
		writeln(coc.errorMessage);
	}
	else
	{
		writeln("An error has occurred.");
		writeln(coc.errorMessage);
	}
}
