import std.stdio;
import std.datetime;
import std.math;

import src.hydroflow;

void main()
{
  auto t1 = Clock.currTime;

  TrapezoidalOpenChannel toc = new TrapezoidalOpenChannel;
  
  toc.setUnknown = toc.Unknown.DISCHARGE;

  toc.setBedSlope = 0.001;
  toc.setBaseWidth = 1;
  toc.setWaterDepth = 0.989;
  toc.setManningRoughness = 0.015;
  toc.setSideSlope = 0;

  const success = toc.solve;

  auto t2 = Clock.currTime;

  writeln((t2 - t1), " calculation time.");
  if (success) {
    writeln("Discharge: ", toc.getDischarge);
  } else {
    writeln(toc.errorMessage);
  }
}

