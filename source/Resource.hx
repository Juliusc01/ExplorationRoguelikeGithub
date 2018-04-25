package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */
class Resource extends FlxSprite {
	public var type(default, null):Int;
	private var _player:Player;
	
	public function new(?X:Float=0, ?Y:Float=0, RType:Int) {
		super(X, Y);
		type = RType;
		loadGraphic("assets/images/resource" + type + ".png", false, 0, 0);
		width = 16;
		height = 16;
		offset.x = 0;
		offset.y = 0;
		set_immovable(true);
	}
	
	public function killByPlayer(player:Player)
	{
		// Tree is knocked over, then the image of the wood updates
		alive = false;
		_player = player;
		//var _gathered = new FlxSprite(player.x, player.y, AssetPaths.wood__png);
		this.origin.set(this.origin.x, this.origin.y + 8);
		FlxTween.angle(this, 0, 90, 0.4, { onComplete: finishKill });
	}
	
	public function finishKill(_):Void
	{
		// Second part of the resource killing animation:
		// Wood symbol pops up over the player's character
		loadGraphic(AssetPaths.wood__png);
		this.angle = 0;
		this.x = _player.x;
		this.y = _player.y - 5;
		FlxTween.tween(this, { alpha: 0, y: y - 15 }, 0.75);
		
	}
}