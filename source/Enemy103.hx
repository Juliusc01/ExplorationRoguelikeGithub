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
class Enemy103 extends Enemy {
	
	public var projectileTimer:Int;
	public var arrowDamage:Int;
	public var arrowSpeed:Int;
	public var arrowKnockback:Int;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		drag.x = drag.y = 10;
        width = 16;
        height = 16;
		speed = 0;
		damage = 0;
		knockback = 0;
		arrowDamage = 10;
		arrowSpeed = 100;
		arrowKnockback = 100;
		hp = 100000000;
		projectileTimer = 100;
		set_immovable(true);
		updateStats();
	}
	


	override public function update(elapsed:Float):Void {
		this.velocity.set(0, 0);
		if (projectileTimer == 0) {
			var P:Projectile = new Projectile(this.x, this.y, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P.angleToShoot = 0;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P);
			projectileTimer = 100;
		} else {
			projectileTimer--;
		}
		super.update(elapsed);
	}
	
	override public function damagePlayer(P:Player):Void {
		return;
	}
	
	override public function hurtByPlayer(P:Player):Void {
		return;
	}
}