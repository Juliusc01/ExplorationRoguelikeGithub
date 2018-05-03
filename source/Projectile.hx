package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
using flixel.util.FlxSpriteUtil;


/**
 * ...
 * @author Julius Christenson
 */
class Projectile extends FlxSprite {
    public var speed:Float;
	public var damage:Int;
	public var knockback:Int;
	public var angleToShoot:Float;
	public var myVector:FlxVector;
	
    public function new(X:Float = 0, Y:Float = 0, playerPos:FlxPoint, startPos:FlxPoint, damage:Int, speed:Int, knockback:Int) {
        super(X, Y);
		this.speed = speed;
		this.damage = damage;
		this.knockback = knockback;
		angleToShoot = FlxAngle.angleBetweenPoint(this, playerPos, true);
		this.angle = angleToShoot;
		loadGraphic("assets/images/projectile.png", true, 6, 16);
	}

	override public function update(elapsed:Float):Void {
		this.velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), angleToShoot);
		super.update(elapsed);
	}
	
	public function damagePlayer(P:Player):Void {
		P.hp -= this.damage;
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), -1*this.knockback);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = 20;
	}
	
}