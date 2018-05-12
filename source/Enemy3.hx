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
	public var arrowSpeed:Int;
	public var arrowKnockback:Int;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/SlimeSquareSmallB.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [3, 4, 0, 1, 2], 7, true);
		drag.x = drag.y = 10;
        width = 16;
        height = 16;
		speed = 30;
		damage = 10;
		knockback = 200;
		arrowDamage = 15;
		arrowSpeed = 120;
		arrowKnockback = 100;
		hp = maxHp = 20;
		projectileTimer = 84;
		updateStats();
	}
	


	override public function update(elapsed:Float):Void {
		if (framesTillMovement == 0) {
			this.velocity.set(0, 0);
			framesTillMovement--;
		}
		if (projectileTimer == 0) {
			var P1:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P1.angleToShoot = -90;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P1);
			var P2:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P2.angleToShoot = 90;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P2);
			var P3:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P3.angleToShoot = 0;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P3);
			var P4:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P4.angleToShoot = 180;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P4);
			projectileTimer = 84;
		}
		if (projectileTimer == 84) {
			wander();
		}
		projectileTimer--;
		super.update(elapsed);
	}
	
	public function wander():Void {
		var newPos:FlxPoint = new FlxPoint(this.x + FlxG.random.float(-50, 50), this.y + FlxG.random.float(-50, 50));
		FlxVelocity.moveTowardsPoint(this, newPos, Std.int(speed));
	}
}