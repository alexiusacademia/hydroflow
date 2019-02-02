import std.stdio;

import hydroflow;

void main()
{
	IrregularSectionOpenChannel isc = new IrregularSectionOpenChannel();
	
	isc.addPoint(new Point(0, 0));
	isc.addPoint(new Point(5, -1.4));

	foreach (Point p ; isc.getPoints())
	{
		writeln(p.x, ", ", p.y);
	}
}
