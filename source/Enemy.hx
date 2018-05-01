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
class Enemy extends FlxSprite {
    public var speed:Float = 80;
    public var etype(default, null):Int;
	private var _brain:FSM;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	public var damage:Int;
	
    public function new(X:Float=0, Y:Float=0, EType:Int) {
        super(X, Y);
        etype = EType;
		damage = 10;
        loadGraphic("assets/images/enemy-" + etype + ".png", true, 16, 16);
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
		_brain = new FSM(idle);
		playerPos = FlxPoint.get();
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
	
	public function idle():Void {
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

	override public function update(elapsed:Float):Void {
		_brain.update();
		super.update(elapsed);
	}
	
}