package;

import flixel.FlxSprite;

/**
 * ...
 * @author Alex Vrhel
 */
class House extends FlxSprite 
{
	public var direction:Direction;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		var w:Int = Constants.TILE_WIDTH * 3;
		var h:Int = Constants.TILE_HEIGHT * 3;
		loadGraphic(AssetPaths.house__png, false, w, h);
		setSize(w, h);
		trace("house size is: " + width + ", " + height);
		centerOffsets();
		set_immovable(true);

	}
	
}
