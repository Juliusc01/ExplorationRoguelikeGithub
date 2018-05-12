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
class Enemy2 extends Enemy {
	
	public var projectileTimer:Int;
	public var arrowSpeed:Int;
	public var arrowKnockback:Int;
    public function new(X:Float = 0, Y:Float = 0, EType:Int) {
		super(X, Y, EType);
		loadGraphic("assets/images/Mob/SkullSmallA.png", true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [3, 4, 0, 1, 2], 7, true);
		drag.x = drag.y = 10;
        width = 16;
		height = 16;
		speed = 0;
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
		}
		if (projectileTimer == 0) {
			var P:Projectile = new Projectile(this.x+5, this.y+5, GameData.currentPlayState.player.getPosition(), this.getPosition(), arrowDamage, arrowSpeed, arrowSpeed);
			GameData.currentPlayState._currentRoom.enemyShootProjectile(P);
			projectileTimer = 84;
		} 
		projectileTimer--;
		super.update(elapsed);
	}
	
	override public function draw():Void {
		if(playerPos.x <= this.x) {
            facing = FlxObject.LEFT;
		} else {
            facing = FlxObject.RIGHT;
        }
        animation.play("lr");
        super.draw();	
	}
}