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
	public var isAffectedByTerrain:Bool = true;
	public var isInSwing:Bool = false;
	//public var isActive:Bool = true;
	public var framesTillMovement:Int = 0;
	public var framesSwung:Int = 0;
	public var hp:Int;
	public var maxHp:Int;
	public var damage:Int;
	public var knockback:Int;
	public var swingNumber:Int;
	public var invulnFrames:Float;
	public var kills:Int;
	private var _framesTillHeal:Int;
	private var _sword:Sword;
	private var relativeSwordPosition:Array<Int> = [0, 0];
	
	public static var X_OFF(default, never):Float = 4;
	public static var WIDTH(default, never):Float = 8;
	public static var Y_OFF(default, never):Float = 4;
	public static var HEIGHT(default, never):Float = 10;
	
	public function new(?X:Float=0, ?Y:Float=0, S:Sword) {
		super(X, Y);
		hp = maxHp = 100;
		knockback = 200;
		damage = 10;
		invulnFrames = 80;
		swingNumber = 0;
		kills = 0;
		_sword = S;
		loadGraphic(AssetPaths.player__png, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		setSize(WIDTH, HEIGHT);
		offset.set(X_OFF, Y_OFF);
	}
	
	override public function update(elapsed:Float):Void {
		_sword.setPosition(this.x + relativeSwordPosition[0], this.y + relativeSwordPosition[1]);
		if (framesTillMovement > 0) {
			framesTillMovement--;
		}
		if (!isInSwing) {
			isInSwing = swing();
			swingNumber++;
			if (!isInSwing && framesTillMovement == 0) {
				movement(true);
			}
		} else {
			movement(false);
			framesSwung--;
			if (framesSwung <= 0) {
				_sword.kill();
				//loadGraphic(AssetPaths.player__png, true, 16, 16);
				//setSize(WIDTH, HEIGHT);
				//animation.add("lr", [3, 4, 3, 5], 6, false);
				//animation.add("u", [6, 7, 6, 8], 6, false);
				//animation.add("d", [0, 1, 0, 2], 6, false);
				isInSwing = false;
			}
		}
		
		// Heal once every second if we have the regen item
		if (PowerUp.isActiveById("009")) {
			if (_framesTillHeal > 0) {
				_framesTillHeal--;
			} else {
				hp += 1;
				if (hp > maxHp) {
					hp = maxHp;
				}
				_framesTillHeal = 60;
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
			var xMin = Const.TILE_WIDTH * 1.25;
			var xMax = FlxG.width - width - Const.TILE_WIDTH * 1.25;
			var yMin = Const.TILE_HEIGHT * 3.25;
			var yMax = FlxG.height - height - 3.25 * Const.TILE_HEIGHT;
			if (x > xMin && x < xMax && y > yMin && y < yMax) {
				canUseDoors = true;
			}
		}
		if (x < 0) {
			x = 0;
		} else if (x > FlxG.width - width) {
			x = FlxG.width - width;
		}
		
		if (y < 0) {
			y = 0;
		} else if (y > FlxG.height - height - 2 * Const.TILE_HEIGHT) {
			y = FlxG.height - height - 2 * Const.TILE_HEIGHT;
		}
	}
	
	public function hurtByEnemy(E:Enemy) {
		if(!isFlickering() && Enemy.hurtsOnContactByType(E.etype)) {
			GameData.myLogger.logLevelAction(LoggingActions.PLAYER_HURT, {enemyType: E.etype});
			if(!GameData.currentPlayState.hasShieldForNextHit) {
				GameData.currentPlayState.flashHealth();
			}
			E.damagePlayer(this);
			
		}
	}
	
	public function hurtByProjectile(P:Projectile) {
		if (!isFlickering()) {
			GameData.myLogger.logLevelAction(LoggingActions.PLAYER_HURT, {projectile: true});
			if(!GameData.currentPlayState.hasShieldForNextHit) {
				GameData.currentPlayState.flashHealth();
			}
			P.damagePlayer(this);
		}
	}
	
	public function increaseKills():Void {
		kills++;
		if (PowerUp.isActiveById("008")) {
			speed += 7;
		}
	}
	
	private function swing():Bool {
		var _space:Bool = FlxG.keys.anyJustPressed([SPACE]);
		if (_space) {
			framesSwung = 24;
			this.isInSwing = true;
			switch (facing) {
				case FlxObject.LEFT:
					relativeSwordPosition = [ -20, -2];
					_sword.setSize(20, 20);
					_sword.loadGraphic(AssetPaths.sword_l__png, true, 16, 16);
					_sword.animation.add("lsword", [2,1,0], 8, false);
					_sword.animation.play("lsword");
				case FlxObject.RIGHT:
					relativeSwordPosition = [Std.int(WIDTH)+Std.int(X_OFF), -2];
					_sword.setSize(20, 20);
					_sword.loadGraphic(AssetPaths.sword_r__png, true, 16, 16);
					_sword.animation.add("rsword", [2,1,0], 8, false);
					_sword.animation.play("rsword");
				case FlxObject.UP:
					relativeSwordPosition = [ -2, -20];
					_sword.setSize(20, 20);
					_sword.loadGraphic(AssetPaths.sword_u__png, true, 16, 16);
					_sword.animation.add("usword", [2,1,0], 8, false);
					_sword.animation.play("usword");
				case FlxObject.DOWN:
					relativeSwordPosition = [ -2, Std.int(HEIGHT)+Std.int(Y_OFF)];
					_sword.setSize(20, 20);
					_sword.loadGraphic(AssetPaths.sword_d__png, true, 16, 16);
					_sword.animation.add("dsword", [0,1,2], 8, false);
					_sword.animation.play("dsword");
			}
			_sword.setPosition(this.x + relativeSwordPosition[0], this.y + relativeSwordPosition[1]);
			trace(this.x, this.y, _sword.x, _sword.y);
			_sword.revive();
		}
		return _space;
	}
	
	private function movement(canMove:Bool):Void {
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
			if (canMove) {
				if (isInSwamp && isAffectedByTerrain) {
				velocity.set(speed / 2, 0);
				} else {
					velocity.set(speed, 0);
				}
				velocity.rotate(FlxPoint.weak(0, 0), mA);
			}
			
			//if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
				switch (facing) {
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			//}
		}
	}
}