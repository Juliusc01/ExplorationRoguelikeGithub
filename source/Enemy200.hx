package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
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
		loadGraphic("assets/images/Mob/HareA.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [0, 1, 2, 3, 4, 5, 6], 6, true);
		drag.x = drag.y = 10;
        width = 16;
        height = 16;
		speed = 80;
		damage = 0;
		knockback = 0;
		hp = maxHp = 3;
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
			if (PowerUp.isActiveById("102")) {
				if (FlxMath.distanceToPoint(this, playerPos) > 48) {
					FlxVelocity.moveTowardsPoint(this, playerPos, 1 * Std.int(speed));
				}
			} else {
				FlxVelocity.moveTowardsPoint(this, playerPos, -1 * Std.int(speed));
			}
		}
	}
	
	override public function draw():Void {
		if (alive) {
			if(playerPos.x <= this.x) {
				facing = FlxObject.RIGHT;
			} else {
				facing = FlxObject.LEFT;
			}
			animation.play("lr");
			super.draw();
		}
    }

	override public function update(elapsed:Float):Void {
		_brain.update();
		super.update(elapsed);
	}
	
	override public function damagePlayer(P:Player):Void {
		return;
	}
	
	override public function kill():Void {
		var ps:PlayState = GameData.currentPlayState;
		loadGraphic(AssetPaths.food__png);
		animation.add("lr", [0], 6, true); // to prevent warning since we still draw the animation on this sprite
		var uiPos:Position = ps.getResourceSpriteLocation(1);
		FlxTween.tween(this, { alpha: 0, x: uiPos.x, y: uiPos.y }, 0.75, { onComplete: finishKill });
		ps.addResource(1, 1, true);
	}
	
	private function finishKill(_):Void {
		alive = false;
		exists = false;
	}
}