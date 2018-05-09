package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
using flixel.util.FlxSpriteUtil;


/**
 * ...
 * @author Julius Christenson
 */
class Enemy0 extends Enemy {
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/BatJ.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add("lr", [0, 1, 2, 1, 0], 6, false);
		drag.x = drag.y = 10;
        width = 8;
        height = 14;
        offset.x = 4;
        offset.y = 2;
		speed = 80;
		damage = 10;
		knockback = 400;
		hp = maxHp = 20;
		_brain = new FSM(idle);
		updateStats();

	}
	
	public function idle():Void {
		if (seesPlayer) {
			_brain.activeState = chase;
		}
	}

	public function chase():Void {
		if (!seesPlayer) {
			_brain.activeState = idle;
		} else {
			if (framesTillMovement == 0) {
				FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));				
			}
		}
	}

	override public function update(elapsed:Float):Void {
		_brain.update();
		super.update(elapsed);
	}
	
}