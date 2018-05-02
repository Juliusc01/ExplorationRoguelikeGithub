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
		super(X, Y, EType);
		trace("made spike");
		
		drag.x = drag.y = 10;
        width = 16;
        height = 16;
		speed = 80;
		damage = 10;
		knockback = 400;
		prevX = this.x;
		prevY = this.y;
		this.direction = Direction.SOUTH;
		hp = 1000000;

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
		trace("" + this.x + ", " + this.y);
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