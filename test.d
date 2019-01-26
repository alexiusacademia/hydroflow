import std.stdio;
import std.datetime;
import std.math;

import src.hydroflow;

void main()
{
  auto t1 = Clock.currTime;

  RectangularOpenChannel roc = new RectangularOpenChannel();
  
  roc.setUnknown = roc.Unknown.BED_SLOPE;

  roc.setBaseWidth = 1;
  roc.setWaterDepth = 0.989;
  roc.setManningRoughness = 0.015;
  roc.setDischarge = 1;

  const success = roc.solve;

  auto t2 = Clock.currTime;

  writeln((t2 - t1), " calculation time.");
  if (success) {
    writeln("Bed Slope: ", round(roc.getBedSlope * 100_000) / 100_000);
  } else {
    writeln(roc.errorMessage);
  }
}

