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
		trace("enemy made?");
		super(X, Y, EType);
		trace("enemy made");

		speed = 80;
		damage = 10;
		_brain = new FSM(idle);

	}
	
	
	public function idle():Void {
		trace("idle");
		if (seesPlayer) {
			trace("enemy sees player");
			_brain.activeState = chase;
		}
	}

	public function chase():Void {
		if (!seesPlayer) {
			_brain.activeState = idle;
		} else {
			FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
		}
	}
	
	override public function draw():Void {
        if ((velocity.x != 0 || velocity.y != 0 ) && touching == FlxObject.NONE) {
            if (Math.abs(velocity.x) > Math.abs(velocity.y)) {
                if (velocity.x < 0)
                    facing = FlxObject.LEFT;
                else
                    facing = FlxObject.RIGHT;
            } else {
                if (velocity.y < 0)
                    facing = FlxObject.UP;
                else
                    facing = FlxObject.DOWN;
            }

            switch (facing) {
                case FlxObject.LEFT, FlxObject.RIGHT:
                    animation.play("lr");

                case FlxObject.UP:
                    animation.play("u");

                case FlxObject.DOWN:
                    animation.play("d");
            }
        }
        super.draw();
    }

	override public function update(elapsed:Float):Void {
		trace("enemy updating");
		_brain.update();
		super.update(elapsed);
	}
	
}