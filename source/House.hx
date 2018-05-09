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
		var w:Int = Const.HOUSE_WIDTH;
		var h:Int = Const.HOUSE_HEIGHT;
		loadGraphic(AssetPaths.house__png, false, w, h);
		setSize(w, h);
		centerOffsets();
		set_immovable(true);

	}
	
}
