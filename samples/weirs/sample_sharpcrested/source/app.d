import std.stdio;
import hydroflow;

void main()
{
	SharpCrestedWeir scw = new SharpCrestedWeir();

	scw.discharge = 100;
	scw.usApronElev = 50;
	scw.dsApronElev = 49.4;
	scw.crestLength = 30;
	scw.crestElev = 52;
	scw.tailwaterElev = 52.5;

	scw.analysis();

	writeln("Afflux elevation: ", scw.affluxElevation);
}
