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
	public var myEnemy:Enemy;
	
    public function new(X:Float = 0, Y:Float = 0, playerPos:FlxPoint, startPos:FlxPoint, damage:Int, speed:Int, knockback:Int, myEnemy:Enemy) {
        super(X, Y);
		this.myEnemy = myEnemy;
		this.speed = speed;
		this.damage = damage;
		this.knockback = knockback;
		angleToShoot = FlxAngle.angleBetweenPoint(this, playerPos, true);
		this.angle = angleToShoot;
		loadGraphic("assets/images/projectile.png", true, 6, 6);
		setSize(6, 6);
	}

	override public function update(elapsed:Float):Void {
		this.velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), angleToShoot);
		super.update(elapsed);
	}
	
	public function damagePlayer(P:Player):Void {
		if (GameData.currentPlayState.hasShieldForNextHit) {
			GameData.currentPlayState.hasShieldForNextHit = false;
		} else {
			P.hp -= this.damage;
		}
		var knockbackSpeed:Float = -1 * this.knockback;
		var knockbackFrames:Float = 20;
		if (PowerUp.isActiveById("005")) { // check for heavy boots
			knockbackSpeed = knockbackSpeed / 2;
			knockbackFrames = knockbackFrames / 2;
		}
		if (PowerUp.isActiveById("003")) { // check for reflective shield
			myEnemy.hp -= Std.int(this.damage / 4);
			if (myEnemy.hp <= 0) {
				myEnemy.kill();
				GameData.myLogger.logLevelAction(LoggingActions.PLAYER_KILL_ENEMEY, {enemyType: myEnemy.etype});
			}
		}
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), knockbackSpeed);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = Std.int(knockbackFrames);
	}
	
}