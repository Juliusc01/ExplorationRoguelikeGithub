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
class Enemy extends FlxSprite {
    public var speed:Float;
    public var etype(default, null):Int;
	private var _brain:FSM;
	public var seesPlayer:Bool = false;
	public var playerPos(default, null):FlxPoint;
	public var damage:Int;
	public var knockback:Int;
	public var hp:Int;
	public var lastPlayerSwingNumber:Int;
	public var framesTillMovement:Int;
	
    public function new(X:Float=0, Y:Float=0, EType:Int) {
        super(X, Y);
		framesTillMovement = 0;
        etype = EType;
		lastPlayerSwingNumber = -1;
		//loadGraphic("assets/images/enemy-" + etype + ".png", true, 16, 16);
        animation.add("lr", [0], 6, false);
		playerPos = FlxPoint.get();
	}
	
	public function updateStats() {
		this.damage = this.damage * GameData.currentLevel.difficulty;
		this.hp = this.hp * GameData.currentLevel.difficulty;
	}

	override public function update(elapsed:Float):Void {
		if (framesTillMovement > 0) {
			framesTillMovement--;
		}
		super.update(elapsed);
	}
	
	public function damagePlayer(P:Player):Void {
		P.hp -= this.damage;
		FlxVelocity.moveTowardsPoint(P, this.getMidpoint(), -1*this.knockback);
		P.flicker(P.invulnFrames/60);
		P.framesTillMovement = 20;
	}
	
	public function hurtByPlayer(P:Player):Void {
		lastPlayerSwingNumber = P.swingNumber;
		framesTillMovement = 20;
		FlxVelocity.moveTowardsPoint(this, P.getMidpoint(), -1*P.knockback);
		this.hp -= P.damage;
		if (this.hp <= 0) {
			this.kill();
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
	
}