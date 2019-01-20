import std.stdio;
import std.datetime;

import src.libs.openchannel_rectangular;

void main(string[] args)
{
  auto t1 = Clock.currTime;

  RectangularOpenChannel roc = new RectangularOpenChannel();
  roc.setBaseWidth = 1;
  roc.setWaterDepth = 0.989;
  roc.setBedSlope = 0.001;
  roc.setManningRoughness = 0.015;

  roc.solveForDischarge();

  auto t2 = Clock.currTime;

  writeln((t2 - t1), " time in s.");

}

