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
class Enemy4 extends Enemy {
	
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
		speed = 75;
		damage = 10;
		knockback = 200;
		arrowDamage = 15;
		arrowSpeed = 60;
		arrowKnockback = 100;
		hp = 20;
		projectileTimer = 100;
		updateStats();
	}
	


	override public function update(elapsed:Float):Void {
		if (framesTillMovement == 0) {
			this.velocity.set(0, 0);
			framesTillMovement = -1;
		}
		if (projectileTimer == 0 && framesTillMovement < 1) {
			var P:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P);
			projectileTimer = 100;
		} else if (framesTillMovement < 1) {
			projectileTimer--;
			if (Math.abs(this.x -playerPos.x) < 40 && Math.abs(this.y - playerPos.y) < 40) {
				FlxVelocity.moveTowardsPoint(this, playerPos, 1 * Std.int(speed/2));
			} else if (seesPlayer) {
				FlxVelocity.moveTowardsPoint(this, playerPos, -1 * Std.int(speed));
			}
		}
		super.update(elapsed);
	}
	
	override public function damagePlayer(P:Player):Void {
		P.hp -= this.damage;
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), -1*this.knockback);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = 20;
	}
	
	override public function hurtByPlayer(P:Player):Void {
		lastPlayerSwingNumber = P.swingNumber;
		framesTillMovement = 50;
		FlxVelocity.moveTowardsPoint(this, P.getMidpoint(), -1*P.knockback);
		this.hp -= P.damage;
		if (this.hp <= 0) {
			this.kill();
		}
	}
}