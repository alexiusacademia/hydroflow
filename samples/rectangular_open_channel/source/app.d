import std.stdio;
import std.datetime;
import std.math;

import hydroflow;

void main()
{
	const auto t1 = Clock.currTime;

	RectangularOpenChannel roc = new RectangularOpenChannel();

	roc.setUnknown = roc.Unknown.WATER_DEPTH;

	// Set the given values
	roc.setBedSlope = 0.001;
	roc.setDischarge = 1;
	roc.setBaseWidth = 1;
	roc.setManningRoughness = 0.015;

	const success = roc.solve();

	const auto t2 = Clock.currTime;

	writeln("Time: ", t2 - t1);

	if (success)
	{
		writeln("Water depth = ", roc.getWaterDepth);
	}
	else
	{
		writeln(roc.errorMessage);
	}
}
