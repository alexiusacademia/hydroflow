import std.stdio;
import src.libs.openchannel;

void main(string[] args) 
{
    OpenChannel oc = new OpenChannel();

    oc.setWaterDepth(9);

    writeln(oc.getWaterDepth);
}


