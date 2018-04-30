package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */
class Player extends FlxSprite {

	public var speed:Float = 150;
	public var canUseDoors:Bool = true;
	public var isInSwamp:Bool = false;
	public var isInSwing:Bool = false;
	public var framesTillMovement:Int = 0;
	public var framesSwung:Int = 0;
	public var hp:Int;
	private var _sword:Sword;
	private var relativeSwordPosition:Array<Int> = [0, 0];
	
	public function new(?X:Float=0, ?Y:Float=0, S:Sword) {
		super(X, Y);
		hp = 100;
		_sword = S;
		loadGraphic(AssetPaths.player__png, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		setSize(16, 16);
		//setSize(8, 10);
		//offset.set(4, 4);
	}
	
	override public function update(elapsed:Float):Void {
		_sword.setPosition(this.x + relativeSwordPosition[0], this.y + relativeSwordPosition[1]);
		if (framesTillMovement > 0) {
			framesTillMovement--;
		}
		if (!isInSwing) {
			isInSwing = swing();
			speed = 150;
			if (!isInSwing && framesTillMovement == 0) {
				movement();
			}
		} else {
			framesSwung--;
			if (framesSwung <= 0) {
				_sword.kill();
				loadGraphic(AssetPaths.player__png, true, 16, 16);
				animation.add("lr", [3, 4, 3, 5], 6, false);
				animation.add("u", [6, 7, 6, 8], 6, false);
				animation.add("d", [0, 1, 0, 2], 6, false);
				isInSwing = false;
			}
		}
		
		// After moving, set swamp to be false, this will
		// be updated back to true by the collision callback
		// if they are still in the swamp during next update.
		isInSwamp = false;
		super.update(elapsed);
		
		// Check if we are in a non-door range, if so, ensure
		// door use is turned back on. Using .25 tiles of padding so they must move at
		// least 4 pixels away from the door before it re-activates.
		if (!canUseDoors) {
			// TODO: add these as constants for the room bounds?
			var xMin = Constants.TILE_WIDTH * 1.25;
			var xMax = FlxG.width - width - Constants.TILE_WIDTH * 1.25;
			var yMin = Constants.TILE_HEIGHT * 3.25;
			var yMax = FlxG.height - height - 3.25 * Constants.TILE_HEIGHT;
			if (x > xMin && x < xMax && y > yMin && y < yMax) {
				canUseDoors = true;
				trace("can use doors:" + x + ", " + y);
			}
		}
		if (x < 0) {
			x = 0;
		} else if (x > FlxG.width - width) {
			x = FlxG.width - width;
		}
		
		if (y < 0) {
			y = 0;
		} else if (y > FlxG.height - height - 2 * Constants.TILE_HEIGHT) {
			y = FlxG.height - height - 2 * Constants.TILE_HEIGHT;
		}
	}
	
	public function hurtByEnemy(E:Enemy) {
		if(!isFlickering()) {
			var enemyDamage = E.damage;
			hp -= enemyDamage;
			FlxVelocity.moveTowardsPoint(this, E.getMidpoint(), -400);
			flicker(1.33333333333);
			framesTillMovement = 20;
		}
	}
	
	private function swing():Bool {
		var _space:Bool = FlxG.keys.anyJustPressed([SPACE]);
		if (_space) {
			framesSwung = 40;
			this.isInSwing = true;
			switch (facing) {
				case FlxObject.LEFT:
					relativeSwordPosition = [-16, 0];
					/*loadGraphic(AssetPaths.player_sword_lr__png, true, 32, 16);
					animation.add("lsword", [0,1,0], 6, false);
					animation.play("lsword");*/
				case FlxObject.RIGHT:
					relativeSwordPosition = [16, 0];
					/*loadGraphic(AssetPaths.player_sword_lr__png, true, 32, 16);
					animation.add("rsword", [0,1,0], 6, false);
					animation.play("rsword");*/
				case FlxObject.UP:
					relativeSwordPosition = [0, -16];
					/*loadGraphic(AssetPaths.player_sword_ud__png, true, 16, 32);
					animation.add("usword", [0,1,0], 6, false);
					animation.play("usword");*/
				case FlxObject.DOWN:
					relativeSwordPosition = [0, 16];
					/*loadGraphic(AssetPaths.player_sword_ud__png, true, 16, 32);
					animation.add("dsword", [2,3,2], 6, false);
					animation.play("dsword");*/
			}
			_sword.setPosition(this.x + relativeSwordPosition[0], this.y + relativeSwordPosition[1]);
			_sword.revive();
		}
		return _space;
	}
	
	private function movement():Void {
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		var _swing:Bool = false;
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
		_swing = FlxG.keys.anyPressed([SPACE]);
		if (_up && _down) {
			_up = _down = false;
		}
		if (_left && _right) {
			_left = _right = false;
		}
		if (_up || _down || _left || _right) {
			var mA:Float = 0;
			if (_up) {
				mA = -90;
				if (_left) {
					mA -= 45;
				} else if (_right) {
					mA += 45;
				}
				facing = FlxObject.UP;
			} else if (_down) {
				mA = 90;
				if (_left) {
					mA += 45;
				} else if (_right) {
					mA -= 45;
				}
				facing = FlxObject.DOWN;
			} else if (_left) {
				mA = 180;
				facing = FlxObject.LEFT;
			} else if (_right) {
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			if (isInSwamp) {
				velocity.set(speed / 2, 0);
			} else {
				velocity.set(speed, 0);
			}
			velocity.rotate(FlxPoint.weak(0, 0), mA);
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
				switch (facing) {
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
	}
}