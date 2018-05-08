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
class Enemy104 extends Enemy {
	
	public var projectileTimer:Int;
	public var arrowDamage:Int;
	public var arrowSpeed:Int;
	public var arrowKnockback:Int;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/OrbB.png", true, 16, 16);
		animation.add("shoot", [6,5,5], 2, true);
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
		projectileTimer = 96;
		set_immovable(true);
		updateStats();
	}
	
	override public function draw():Void {
        animation.play("shoot");
        super.draw();
    }

	override public function update(elapsed:Float):Void {
		this.velocity.set(0, 0);
		if (projectileTimer == 0) {
			var P:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			P.angleToShoot = 90;
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P);
			projectileTimer = 90;
		}
		projectileTimer--;
		super.update(elapsed);
	}
	
	override public function damagePlayer(P:Player):Void {
		return;
	}
	
	override public function hurtByPlayer(P:Player):Void {
		return;
	}
}