import std.stdio;
import std.datetime;

import hydroflow;

void main()
{
	auto start = Clock.currTime;

	SharpCrestedWeir scw = new SharpCrestedWeir();

	scw.setDischarge = 100;
	scw.setUSApronElev = 50;
	scw.setDSApronElev = 49.4;
	scw.setCrestLength = 30;
	scw.setCrestElev = 52;
	scw.setTailwaterElev = 52.5;

	if (scw.analysis())
	{
		writeln("Afflux elevation: ", scw.getAffluxElevation);
		writeln("Hydraulic jump: ", scw.getLengthOfHydraulicJump);
		auto diff = Clock.currTime - start;
		writeln(diff);
	} 
	else
	{
		writeln(scw.errorMessage);
	}
}
