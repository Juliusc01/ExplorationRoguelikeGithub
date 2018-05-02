package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */
class Resource extends FlxSprite {
	public var type:Int;
	//private var _player:Player;
	
	public function new(?X:Float=0, ?Y:Float=0, resType:Int) {
		super(X, Y);
		type = resType;
		loadGraphic("assets/images/resource" + resType + ".png");
		width = 32;
		height = 32;
		offset.x = 0;
		offset.y = 0;
		set_immovable(true);
	}
	
	/**
	 * Fn to call when the resource is killed by the player.
	 */
	public function killByPlayer():Void {
		alive = false;
		//_player = player;
		this.origin.set(this.origin.x, this.origin.y + 8);
		if (type == 0) {
			FlxTween.angle(this, 0, 90, 0.3, { onComplete: animateGetResource });
		} else {
			FlxTween.tween(this, { alpha: 0}, 0.3, { onComplete: animateGetResource });
		}
	}
	
	/**
	 * Reset the graphic of this resource to be the icon of the
	 * gathered resource, and have it appear briefly over the player.
	 */
	public function animateGetResource(_):Void {
		switch (type) {
			case 0:
				loadGraphic(AssetPaths.wood__png);
			case 1:
				loadGraphic(AssetPaths.food__png);
			case 2:
				loadGraphic(AssetPaths.stone__png);
		}
		this.angle = 0;
		this.alpha = 1;
		//this.x = _player.x;
		//this.y = _player.y - 5;
		FlxTween.tween(this, { alpha: 0, y: y - 15 }, 0.5, { onComplete: finishKill });
	}
	
	/**
	 * Finish killing the resource by setting exists to false.
	 */
	public function finishKill(_):Void {
		exists = false;
	}
}