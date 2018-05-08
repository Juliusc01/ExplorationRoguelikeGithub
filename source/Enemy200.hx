package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
using flixel.util.FlxSpriteUtil;


/**
 * ...
 * @author Julius Christenson
 */
class Enemy200 extends Enemy {
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add("d", [0, 1, 0, 2], 6, false);
        animation.add("lr", [3, 4, 3, 5], 6, false);
        animation.add("u", [6, 7, 6, 8], 6, false);
		drag.x = drag.y = 10;
        width = 8;
        height = 14;
        offset.x = 4;
        offset.y = 2;
		speed = 80;
		damage = 0;
		knockback = 0;
		hp = 1;
		_brain = new FSM(idle);
		updateStats();
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
			FlxVelocity.moveTowardsPoint(this, playerPos, -1*Std.int(speed));
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
		_brain.update();
		super.update(elapsed);
	}
	
	override public function damagePlayer(P:Player):Void {
		return;
	}
	
	override public function kill():Void {
		trace("killing cow at location: " + x + ", " + y);
		alive = false;
		var ps:PlayState = GameData.currentPlayState;
		loadGraphic(AssetPaths.food__png);
		var uiPos:Position = ps.getResourceSpriteLocation(1);
		FlxTween.tween(this, { alpha: 0, x: uiPos.x, y: uiPos.y }, 0.75, { onComplete: finishKill });
		ps.addResource(1, 1, true);
	}
	
	private function finishKill(_):Void {
		exists = false;
	}
}