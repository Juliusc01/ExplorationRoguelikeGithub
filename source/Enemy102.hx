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
class Enemy102 extends Enemy {
	private var prevX:Float;
	private var prevY:Float;
	private var direction:Direction;
	
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		healthbarDisabled = true;
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/SphereB.png", true, 16, 16);
		animation.add("lr", [0,1,2,3,4,5], 6, true);
		drag.x = drag.y = 10;
        width = 14;
        height = 14;
		speed = 80;
		damage = 10;
		knockback = 400;
		prevX = this.x;
		prevY = this.y;
		this.direction = Direction.SOUTH;
		hp = 1000000;
		updateStats();

	}
	public function chase():Void {
		if (Math.abs(prevX - this.x) < .1 && Math.abs(prevY - this.y) < .1) {
			switch(direction) {
				case Direction.EAST:
					direction = Direction.NORTH;
				case Direction.WEST:
					direction = Direction.SOUTH;
				case Direction.NORTH:
					direction = Direction.SOUTH;
				case Direction.SOUTH:
					direction = Direction.NORTH;
			}
		}
		var newX = this.x;
		var newY = this.y;
		switch(direction) {
			case Direction.EAST:
				newX = this.x;
			case Direction.SOUTH:
				newY = 5000;
			case Direction.WEST:
				newX = this.x;
			case Direction.NORTH:
				newY = -5000;
		}
		prevX = this.x;
		prevY = this.y;
		FlxVelocity.moveTowardsPoint(this, new FlxPoint(newX, newY), Std.int(speed));
	}
	

	override public function update(elapsed:Float):Void {
		chase();
		super.update(elapsed);
	}
	
	override public function hurtByPlayer(P:Player):Void {
		return;
	}
}