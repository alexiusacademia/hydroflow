import std.stdio;

import src.libs.openchannel_rectangular;

void main(string[] args)
{
  RectangularOpenChannel roc = new RectangularOpenChannel();
  roc.setWaterDepth = 2;
  writeln(roc.getWaterDepth());
  writeln(cast(int) roc.FlowType.SUPERCRITICAL);
}
