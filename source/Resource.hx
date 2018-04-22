package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */
class Resource extends FlxSprite {
	public var type(default, null):Int;
	public function new(?X:Float=0, ?Y:Float=0, Type:Int) {
		super(X, Y);
		type = Type;
		loadGraphic("assets/images/resource" + type + ".png", false, 0, 0);
		width = 16;
		height = 16;
		offset.x = 0;
		offset.y = 0;
	}
	
}