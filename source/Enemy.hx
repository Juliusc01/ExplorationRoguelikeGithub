package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
using flixel.util.FlxSpriteUtil;


/**
 * ...
 * @author Julius Christenson
 */
class Enemy extends FlxSprite {
    public var speed:Float;
    public var etype(default, null):Int;
	private var _brain:FSM;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	public var damage:Int;
	public var arrowDamage:Int;
	public var knockback:Int;
	public var hp:Int;
	public var maxHp:Int;
	public var lastPlayerSwingNumber:Int;
	public var framesTillMovement:Int;
	public var healthbar:FlxBar;
	public var healthbarDisabled:Bool;
	public var drop:FlxSprite;
	
    public function new(X:Float=0, Y:Float=0, EType:Int) {
        super(X, Y);
		framesTillMovement = 0;
        etype = EType;
		lastPlayerSwingNumber = -1;
		//loadGraphic("assets/images/enemy-" + etype + ".png", true, 16, 16);
        animation.add("lr", [0], 6, false);
		playerPos = FlxPoint.get();
		if (!healthbarDisabled) {
			createHealthBar();
		}
	}
	
	public function updateStats() {
		this.damage = Std.int(this.damage * GameData.currentLevel.difficulty);
		this.arrowDamage = Std.int(this.arrowDamage * GameData.currentLevel.difficulty);
		this.hp = Std.int(this.hp * GameData.currentLevel.difficulty);
		this.maxHp = Std.int(this.maxHp * GameData.currentLevel.difficulty);
	}
	
	public function createHealthBar():Void {
		healthbar = new FlxBar(0, 0, 16, 4);
		healthbar.setParent(this, "hp", true, 0, -10);
		healthbar.killOnEmpty = true;
	}

	override public function update(elapsed:Float):Void {
		if (framesTillMovement > 0) {
			framesTillMovement--;
		}
		if (!healthbarDisabled) {
			healthbar.value = (hp / maxHp) * 100;
		}
		super.update(elapsed);
	}
	
	public function damagePlayer(P:Player):Void {
		if (GameData.currentPlayState.hasShieldForNextHit) {
			GameData.currentPlayState.hasShieldForNextHit = false;
		} else {
			P.hp -= this.damage;
		}
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), -1*this.knockback);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = 20;
		if (PowerUp.isActiveById("003")) { // check for reflective shield
			this.hp -= Std.int(this.damage / 4);
			if (this.hp <= 0) {
				this.kill();
				GameData.myLogger.logLevelAction(LoggingActions.PLAYER_KILL_ENEMEY, {enemyType: this.etype});
			}
		}
	}
	
	public function hurtByPlayer(P:Player):Void {
		lastPlayerSwingNumber = P.swingNumber;
		framesTillMovement = 20;
		FlxVelocity.moveTowardsPoint(this, P.getMidpoint(), -1*P.knockback);
		this.hp -= P.damage;
		if (this.hp <= 0) {
			this.kill();
			P.increaseKills();
			GameData.myLogger.logLevelAction(LoggingActions.PLAYER_KILL_ENEMEY, {enemyType: this.etype});
		}
	}
	
	override public function draw():Void {
        if (velocity.x != 0 || velocity.y != 0 ) {
            if (velocity.x < 0) {
                facing = FlxObject.LEFT;
			} else {
                facing = FlxObject.RIGHT;
            }
            animation.play("lr");
        }
        super.draw();
    }

	
	override public function kill():Void {
		var ps:PlayState = GameData.currentPlayState;
		this.healthbar.kill();
		alive = false;
		exists = false;
		if (FlxG.random.bool(45) || GameData.currentLevel.levelNum == 1) {
			// Drop and animate the crafting supplies from the enemy
			var drop = new FlxSprite(x, y, AssetPaths.craft__png);
			GameData.currentPlayState.add(drop);
			var uiPos:Position = ps.getResourceSpriteLocation(3);
			FlxTween.tween(drop, { alpha: 0, x: uiPos.x, y: uiPos.y }, 0.75);
			ps.addResource(3, 1, false);
		}
	}
	
	// Reserve all enemy types 100-199, inclusive, for obstacle enemies.
	public static function isObstacleByType(checkType:Int):Bool {
		return checkType >= 100 && checkType < 200;
	}
	
	// All enemies 103 and up do not hurt player on contact.
	public static function hurtsOnContactByType(checkType:Int):Bool {
		return checkType < 103;
	}
	
}