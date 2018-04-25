package;

import flixel.group.FlxGroup;

/**
 * ...
 * @author Alex Vrhel
 */
class Room extends FlxGroup 
{

	public function new(roomId:Int, path:String) 
	{
		super(0);
		trace("creating room from: " + path);
		
	}
	
}