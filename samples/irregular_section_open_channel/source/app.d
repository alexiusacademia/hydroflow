import std.stdio;

import hydroflow;

void main()
{
	IrregularSectionOpenChannel isc = new IrregularSectionOpenChannel();
	Point[] pts;

	pts.length = pts.length + 1;
	pts[0] = new Point(0, 20.5);

	isc.setPoints(pts);

	writeln(isc.getPoints[0].x, ", ", isc.getPoints[0].y);
}
