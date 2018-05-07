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
class Enemy3 extends Enemy {
	
	public var projectileTimer:Int;
	public var arrowDamage:Int;
	public var arrowSpeed:Int;
	public var arrowKnockback:Int;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		drag.x = drag.y = 10;
        width = 8;
        height = 14;
        offset.x = 4;
        offset.y = 2;
		speed = 30;
		damage = 10;
		knockback = 200;
		arrowDamage = 15;
		arrowSpeed = 120;
		arrowKnockback = 100;
		hp = 20;
		projectileTimer = 100;
		updateStats();
	}
	


	override public function update(elapsed:Float):Void {
		if (framesTillMovement == 0) {
			this.velocity.set(0, 0);
			framesTillMovement--;
		}
		if (projectileTimer == 0) {
			var P1:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P1.angleToShoot = -90;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P1);
			var P2:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P2.angleToShoot = 90;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P2);
			var P3:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P3.angleToShoot = 0;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P3);
			var P4:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P4.angleToShoot = 180;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P4);
			projectileTimer = 100;
		}
		if (projectileTimer == 100) {
			wander();
		}
		projectileTimer--;
		super.update(elapsed);
	}
	
	public function wander():Void {
		trace("wandering");
		var newPos:FlxPoint = new FlxPoint(this.x + FlxG.random.float(-50, 50), this.y + FlxG.random.float(-50, 50));
		FlxVelocity.moveTowardsPoint(this, newPos, Std.int(speed));
	}
	
	override public function damagePlayer(P:Player):Void {
		P.hp -= this.damage;
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), -1*this.knockback);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = 20;
	}
	
	override public function hurtByPlayer(P:Player):Void {
		lastPlayerSwingNumber = P.swingNumber;
		framesTillMovement = 20;
		FlxVelocity.moveTowardsPoint(this, P.getMidpoint(), -1*P.knockback);
		this.hp -= P.damage;
		if (this.hp <= 0) {
			this.kill();
		}
	}
}