package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
using flixel.util.FlxSpriteUtil;


/**
 * ...
 * @author Julius Christenson
 */
class Enemy1 extends Enemy {
	private var idleTimer:Int;
	private var framesTillCharge:Int;
	private var willCharge:Bool;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/MonolithE.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add("lr", [1, 2, 3, 4], 6, false);
		animation.add("still", [0], 6, false);
		drag.x = drag.y = 10;
        width = 8;
        height = 14;
        offset.x = 4;
        offset.y = 2;
		speed = 100;
		damage = 20;
		knockback = 400;
		hp = maxHp = 20;
		idleTimer = 0;
		willCharge = false;
		framesTillCharge = 0;
		_brain = new FSM(idle);
		updateStats();
	}
	
	
	public function idle():Void {
		if (seesPlayer) {
			_brain.activeState = chase;
		} else {
			if (!willCharge && idleTimer == 0) {
				wander();
			}
		}
	}
	
	override public function draw():Void {
        if (velocity.x != 0 || velocity.y != 0 ) {
            if (velocity.x < 0) {
                facing = FlxObject.LEFT;
			} else {
                facing = FlxObject.RIGHT;
            }
            animation.play("lr");
        } else {
			animation.play("still");
		}
        super.draw();
    }
	
	public function wander():Void {
		var newPos:FlxPoint = new FlxPoint(this.x + FlxG.random.float(-50, 50), this.y + FlxG.random.float(-50, 50));
		FlxVelocity.moveTowardsPoint(this, newPos, Std.int(speed / 4));
		idleTimer = 50;
	}

	public function chase():Void {
		if (!seesPlayer) {
			_brain.activeState = idle;
		} else {
			willCharge = true;
		}
	}

	override public function update(elapsed:Float):Void {
		if (framesTillMovement > 0) {
			framesTillMovement--;
		} else {
			if (willCharge) {
				var angleToShoot = FlxAngle.angleBetweenPoint(this, playerPos, true);
				if (framesTillCharge == 0) {
					framesTillCharge = 150;
				} else if (framesTillCharge == 1) {
					this.velocity.set(speed, 0);
					velocity.rotate(FlxPoint.weak(0, 0), angleToShoot);
					willCharge = false;
				}
				if (framesTillCharge > 0) {
					framesTillCharge--;
				}
				idleTimer = 50;
			}
			if (idleTimer > 0) {
				idleTimer--;
			}
		}
		//Reset if about to move after taking damage
		if (framesTillMovement == 1) {
			this.velocity.set(0, 0);
			idleTimer = 0;
			_brain.activeState = idle;
			willCharge = false;
			idleTimer = 0;
			framesTillCharge = 0;
		}
		
		
			
		
		_brain.update();
		super.update(elapsed);
	}
	
}