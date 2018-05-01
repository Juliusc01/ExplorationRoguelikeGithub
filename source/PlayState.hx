package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class PlayState extends FlxState {
	private var _player:Player;
	private var _grpResources:FlxTypedGroup<Resource>;
	private var _grpDoors:FlxTypedGroup<Door>;
	private var _HUD:HUD;
	
	private var _currentRoom:Room;
	private var _layout:Layout;
	
	
	public var sword:Sword;
	// State of the current level, can be referenced
	// by other components such as the HUD that need access.
	public var currentWood:Int;
	public var currentFood:Int;
	public var currentStone:Int;
	public var timer:Float;
	public var isEnding:Bool;
	public var hasWon:Bool;
	public var hasEnoughResources:Bool;
	
	/*
	public var currentCoins:Int;
	public var currentGems:Int;
	public var currentDust:Int;
	*/
	
	override public function create():Void {
		trace(GameData.currentLevel);
		
		timer = GameData.currentLevel.timeLimit;
		currentWood = 0;
		currentFood = 0;
		currentStone = 0;
		
		_layout = new Layout(GameData.currentLevel.numRooms);		
		_currentRoom = _layout.getCurrentRoom();
		
		add(_currentRoom);
		sword = new Sword(0, 0);
		_player = new Player(FlxG.width / 2, FlxG.height / 2, sword);
		_HUD = new HUD(this);
		sword.kill();
		add(_HUD);
		add(_player);
		add(sword);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_player, _currentRoom.tilemap);
		timer -= elapsed;
		if (timer <= 0 || _player.hp <= 0) {
			loseLevel();
		}
		_currentRoom.grpEnemies.forEachAlive(checkEnemyVision);
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.tilemap);
		
		FlxG.overlap(_player, _currentRoom.grpResources, playerTouchResource);
		FlxG.overlap(_player, _currentRoom.grpDoors, playerTouchDoor);
		FlxG.overlap(_player, _currentRoom.myPowerUp, playerTouchPowerUp);
		FlxG.collide(_player, _currentRoom.grpEnemies, playerTouchEnemy);
		FlxG.overlap(sword, _currentRoom.grpEnemies, swordTouchEnemy);
		if (_currentRoom.isHome) {
			FlxG.collide(_player, _currentRoom.myHouse);
			if (FlxMath.isDistanceWithin(_player, _currentRoom.myHouse, 48, true)) {
				if (FlxG.keys.pressed.SPACE && currentFood >= GameData.currentLevel.foodReq
					&& currentWood >= GameData.currentLevel.woodReq && currentStone >= GameData.currentLevel.stoneReq) {
					winLevel();
				}
			}
		}

	}
	
	//Test end level function

	private function loseLevel():Void {
		FlxG.switchState(new LoseState());
	}
	
	private function winLevel():Void {
		GameData.currentMenuState = 1;
		if (GameData.currentLevel == GameData.levels[GameData.levels.length - 1]) {
			GameData.currentMenuState = 2;
		}
		FlxG.switchState(new MenuState());
	}
	
	private function playerTouchPowerUp(P:Player, PU:PowerUp):Void {
		if (P.alive && P.exists && PU.alive && PU.exists) {
			trace("powerupwalkedon");
			for (currPowerUp in GameData.powerUps) {
				if (currPowerUp.powerUpID == PU.powerUpID) {
					currPowerUp.isActive = true;
				}
			}
			PU.kill();
		}
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void {
		if (P.alive && P.exists && E.alive && E.exists) {
			P.hurtByEnemy(E);
		}
	}
	
	private function swordTouchEnemy(S:Sword , E:Enemy):Void {
		if (S.alive && S.exists && E.alive && E.exists) {
			E.kill();
			_currentRoom.hasKilledAllEnemies();
		}
	}
	
	private function playerTouchResource(P:Player, R:Resource):Void {
		if (P.alive && P.exists && R.alive && R.exists && FlxG.keys.pressed.SPACE) {
			R.killByPlayer(P);
			addResource(R, 1);
		}
	}
	
	private function addResource(res:Resource, amount:Int):Void {
		switch (res.type) {
			case 0: // Wood, TODO: use Enums here
				currentWood += amount;
			case 1: // Food
				currentFood += amount;
			case 2: // Stone
				currentStone += amount;
			default:
				trace("resource type was: " + res.type);
		}
	}
	
	private function playerTouchDoor(P:Player, D:Door):Void {
		if (P.alive && P.exists && P.canUseDoors && D.alive && D.exists) {
			trace ("Triggered door touch!");
			_player.canUseDoors = false;
			trace ("can't use doors");
			switchToRoom(D.direction);
		}
	}
	
	private function checkEnemyVision(e:Enemy):Void {
		if (_currentRoom.tilemap.ray(e.getMidpoint(), _player.getMidpoint())) { //&& _player.framesInvuln == 0) {
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		} else {
			e.seesPlayer = false;
		}
	}
	
	private function switchToRoom(outgoingDir:Direction) {
		FlxG.camera.fade(FlxColor.BLACK, 0.25, true, true); //TODO: this doesn't work right now?
		remove(_currentRoom);
		switch(outgoingDir) { 
			case Direction.EAST: 
				_player.x = 0;
			case Direction.SOUTH: 
				_player.y = Const.TILE_HEIGHT * 3;
			case Direction.WEST: // left
				_player.x = FlxG.width - Const.TILE_WIDTH;
			case Direction.NORTH: // up
				_player.y = FlxG.height - 3 * Const.TILE_WIDTH;
		}
		_currentRoom = _layout.changeRoom(outgoingDir);
		add(_currentRoom);
	}
}