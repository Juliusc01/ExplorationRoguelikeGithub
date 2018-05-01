package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */
class Sword extends FlxSprite {
	public var type(default, null):Int;
	private var _player:Player;
	
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		loadGraphic(AssetPaths.item_00__png, true, 16, 16);
		width = 16;
		height = 16;
		offset.x = 0;
		offset.y = 0;
	}
}