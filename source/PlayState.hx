package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class PlayState extends FlxState {
	public var player:Player;
	private var _grpResources:FlxTypedGroup<Resource>;
	private var _grpDoors:FlxTypedGroup<Door>;
	private var _HUD:HUD;
	
	public var _currentRoom:Room;
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
	public var hasEnoughWood:Bool;
	public var hasEnoughFood:Bool;
	public var hasEnoughStone:Bool;
	
	private var _gotPowerUp:Bool;
	
	private var _inStart:Bool;
	private var _levelStartScreen:LevelStartScreen;
	
	private var _inCameraFade:Bool;
	private var _cameraAlpha:Float;
	
	/*
	public var currentCoins:Int;
	public var currentGems:Int;
	public var currentDust:Int;
	*/
	
	override public function create():Void {
		FlxG.mouse.visible = false;
		GameData.currentPlayState = this;
		sword = new Sword(0, 0);
		player = new Player(Const.HOUSE_X + (Const.HOUSE_WIDTH / 2) - 8, Const.HOUSE_Y + (Const.HOUSE_HEIGHT) + 4, sword);
		timer = GameData.currentLevel.timeLimit;
		currentWood = 0;
		currentFood = 0;
		currentStone = 0;
		
		_layout = new Layout(GameData.currentLevel.numRooms);		
		_currentRoom = _layout.getCurrentRoom();
		_cameraAlpha = 1;
			
		add(_currentRoom);
		_HUD = new HUD(this);
		add(_HUD);
		sword.kill();
		add(player);
		add(sword);
		if (GameData.currentLevel.levelNum == 0) {
			addLevelStartScreen();
		}
		applyActivePowerUps();
		super.create();
	}

	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (_inStart) {
			if (FlxG.keys.justPressed.SPACE) {
				removeLevelStartScreen();
			}
			return;
		}
		
		FlxG.collide(player, _currentRoom.tilemap);
		timer -= elapsed;
		
		
		//TODO: remove this after testing health loss
		if (FlxG.keys.pressed.X) {
			winLevel();
		}
		//TODO: remove this after testing health loss
		if (FlxG.keys.pressed.C) {
			player.hp --;
		}
		
		if (timer <= 0 || player.hp <= 0) {
			loseLevel();
		}
		_currentRoom.grpEnemies.forEachAlive(checkEnemyVision);
		_currentRoom.grpAnimals.forEachAlive(checkEnemyVision);
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.tilemap);
		FlxG.collide(_currentRoom.grpAnimals, _currentRoom.tilemap);
		FlxG.collide(_currentRoom.grpObstacles, _currentRoom.tilemap);
		
		FlxG.collide(player, _currentRoom.grpResources);
		hasEnoughWood = currentWood >= GameData.currentLevel.woodReq;
		hasEnoughFood = currentFood >= GameData.currentLevel.foodReq;
		hasEnoughStone = currentStone >= GameData.currentLevel.stoneReq;
		FlxG.overlap(player, _currentRoom.grpDoors, playerTouchDoor);
		FlxG.overlap(player, _currentRoom.myPowerUp, playerTouchPowerUp);
		
		FlxG.collide(player, _currentRoom.grpEnemies, playerTouchEnemy);
		FlxG.collide(player, _currentRoom.grpObstacles, playerTouchEnemy);
		FlxG.collide(player, _currentRoom.grpAnimals);
		FlxG.overlap(sword, _currentRoom.grpEnemies, swordTouchEnemy);
		FlxG.overlap(sword, _currentRoom.grpAnimals, swordTouchEnemy);
		FlxG.overlap(player, _currentRoom.grpEnemies);
		FlxG.overlap(player, _currentRoom.grpObstacles);
		FlxG.overlap(player, _currentRoom.grpAnimals);
		
		FlxG.overlap(sword, _currentRoom.grpProjectiles, swordTouchProjectile);
		FlxG.overlap(sword, _currentRoom.grpResources, swordTouchResource);
		FlxG.collide(_currentRoom.grpProjectiles, _currentRoom.tilemap, killProjectile);
		FlxG.collide(player, _currentRoom.grpProjectiles, playerTouchProjectile);
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.grpDoors);
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.grpEnemies);
		if (_currentRoom.isHome) {
			FlxG.collide(player, _currentRoom.myHouse);
			FlxG.collide(_currentRoom.myHouse, _currentRoom.grpAnimals);
			// Win level case 1: pressing space on house
			if (FlxMath.isDistanceWithin(player, _currentRoom.myHouse, 48, true)) {
				// Win the level if has enough resources && either pressing space near house or at door
				var canWin:Bool = hasEnoughWood && hasEnoughFood && hasEnoughStone;
				var atDoor:Bool = FlxMath.distanceToPoint(player, new FlxPoint(Const.DOOR_X, Const.DOOR_Y)) < 8 && (player.facing == FlxObject.UP);
				if ( canWin && (FlxG.keys.pressed.SPACE ||atDoor) ) {
					winLevel();
				} else if (FlxG.keys.pressed.SPACE || atDoor) {
					if (!hasEnoughWood) {
						_HUD.flashWood(FlxColor.RED);
					}
					if (!hasEnoughStone) {
						_HUD.flashStone(FlxColor.RED);
					}
					if (!hasEnoughFood) {
						_HUD.flashFood(FlxColor.RED);
					}
				}
			}
		}
		if (!_inCameraFade) {
			// Fade the camera to simulate nightfall.
			// Scale with the remaining time, beginning to darken once half
			// of the time limit has passed, eventually reaching a darkness of 0.5.
			_cameraAlpha =  0.5 + (timer / GameData.currentLevel.timeLimit);
			if (_cameraAlpha > 1) {
				_cameraAlpha = 1;
			}
			FlxG.camera.alpha = _cameraAlpha;
		}
	}
	
		
	public function flashHealth():Void {
		_HUD.flashHealth(FlxColor.RED);
	}
	
	private function addLevelStartScreen():Void {
		_levelStartScreen = new LevelStartScreen();
		_inStart = true;
		player.isActive = false;
		add(_levelStartScreen);
	}
	
	private function removeLevelStartScreen():Void {
		_inStart = false;
		player.isActive = true;
		_levelStartScreen.kill();
	}
	
	//Test end level function

	private function loseLevel():Void {
		// If they got a powerup this level, then they lose it when they lose the level.
		// It will always be the last one in the array.
		trace("losing level");
		if (_gotPowerUp) {
			trace("losing powerup now");
			trace("before: " + GameData.activePowerUps.length);
			GameData.activePowerUps.pop();
			trace(GameData.activePowerUps);
			trace("after: " +  GameData.activePowerUps.length);
			trace(GameData.powerUps[0].exists);
			trace(GameData.powerUps[0].alive);
			trace(GameData.powerUps[0]);
		}
		GameData.myLogger.logLevelEnd({won: false, hp: player.hp, time: this.timer, visited: _layout.getNumKnownRooms(), rooms: _layout.numRooms, powerups:PowerUp.powerUpIDS()});
		FlxG.switchState(new LoseState());
	}
	
	private function winLevel():Void {
		GameData.myLogger.logLevelEnd({won: true, hp: player.hp, time: this.timer, visited: _layout.getNumKnownRooms(), rooms: _layout.numRooms, powerups:PowerUp.powerUpIDS()});
		GameData.currentMenuState = 1;
		if (GameData.currentLevel == GameData.levels[GameData.levels.length - 1]) {
			GameData.currentMenuState = 2;
		}
		FlxG.switchState(new MenuState());
	}
	
	private function playerTouchPowerUp(P:Player, PU:PowerUp):Void {
		if (P.alive && P.exists && PU.alive && PU.exists) {
			for (currPowerUp in GameData.powerUps) {
				if (currPowerUp.powerUpID == PU.powerUpID) {
					currPowerUp.isActive = true;
					_HUD.showPowerUp(PU);
					GameData.activePowerUps.push(PU);
					applyPowerUp(PU);
					_gotPowerUp = true;
					GameData.myLogger.logLevelAction(LoggingActions.POWERUP, { pu: currPowerUp.powerUpID });
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
	
	private function playerTouchProjectile(P:Player, Pro:Projectile):Void {
		if (P.alive && P.exists && Pro.alive && Pro.exists) {
			P.hurtByProjectile(Pro);
			_currentRoom.grpProjectiles.remove(Pro);
		}
	}
	
	private function killProjectile(P:Projectile, W:FlxTilemap) {
		_currentRoom.grpProjectiles.remove(P);
	}
	
	private function swordTouchEnemy(S:Sword , E:Enemy):Void {
		if (S.alive && S.exists && E.alive && E.exists && player.swingNumber != E.lastPlayerSwingNumber) {
			E.hurtByPlayer(player);
		}
	}
	
	private function swordTouchProjectile(S:Sword , P:Projectile):Void {
		if (S.alive && S.exists && P.alive && P.exists) {
			_currentRoom.grpProjectiles.remove(P);
		}
	}
	
	private function swordTouchResource(S:Sword, R:Resource):Void {
		if (S.alive && S.exists && R.alive && R.exists && FlxG.keys.pressed.SPACE) {
			R.killByPlayer(_HUD.getResourceSpriteLocation(R.type));
			addResource(R.type, 1, false);
		}
	}
	
	public function getResourceSpriteLocation(rType:Int):Position {
		return _HUD.getResourceSpriteLocation(rType);
	}
	
	public function addResource(resType:Int, amount:Int, fromCow:Bool):Void {
		switch (resType) {
			case 0: // Wood
				amount = possiblyAddBonus(amount, "002");
				currentWood += amount;
				_HUD.flashWood(FlxColor.GREEN);
			case 1: // Food
				if (!fromCow) {
					amount = possiblyAddBonus(amount, "100");
				} else {
					amount = possiblyAddBonus(amount, "101");
				}
				currentFood += amount;
				_HUD.flashFood(FlxColor.GREEN);
			case 2: // Stone
				amount = possiblyAddBonus(amount, "200");
				currentStone += amount;
				_HUD.flashStone(FlxColor.GREEN);
		}
	}
	
	private function possiblyAddBonus(amount:Int, powerUp:String): Int {
		if (PowerUp.isActiveById(powerUp)) {
			if (FlxG.random.bool(25)) {
				return amount + 1;
			}
		}
		return amount;
	}
	
	private function playerTouchDoor(P:Player, D:Door):Void {
		if (P.alive && P.exists && P.canUseDoors && D.alive && D.exists) {
			player.canUseDoors = false;
			switchToRoom(D.direction);
		}
	}
	
	private function checkEnemyVision(e:Enemy):Void {
		if (_currentRoom.tilemap.ray(e.getMidpoint(), player.getMidpoint())) { //&& _player.framesInvuln == 0) {
			e.seesPlayer = true;
			e.playerPos.copyFrom(player.getMidpoint());
		} else {
			e.seesPlayer = false;
		}
	}
	
	private function switchToRoom(outgoingDir:Direction) {
		fadeIn();
		remove(_currentRoom);
		switch(outgoingDir) { 
			case Direction.EAST: 
				player.x = 0;
			case Direction.SOUTH: 
				player.y = Const.TILE_HEIGHT * 3;
			case Direction.WEST: // left
				player.x = FlxG.width - Const.TILE_WIDTH;
			case Direction.NORTH: // up
				player.y = FlxG.height - 3 * Const.TILE_WIDTH;
		}
		_currentRoom = _layout.changeRoom(outgoingDir);
		add(_currentRoom);
	}
	
	private function fadeIn():Void {
		FlxG.camera.alpha = 0;
		_inCameraFade = true;
		FlxTween.tween(FlxG.camera, {alpha: _cameraAlpha}, 0.2, { ease:FlxEase.quadInOut, onComplete: endCameraFade });
	}
	
	private function endCameraFade(_):Void {
		_inCameraFade = false;
	}
	
	private function applyActivePowerUps():Void {
		// TODO: apply powerups here.
		for (i in 0...GameData.activePowerUps.length) {
			applyPowerUp(GameData.activePowerUps[i]);
		}
	}
	
	private function applyPowerUp(pu:PowerUp):Void {
		switch (pu.powerUpID) {
			case "000":
				trace("applying 000: ARMOR");
				player.invulnFrames *= 1.5;
			case "001":
				trace("applying 001: SWORD");
				//TODO: decide on this and implement it.
			case "002":
				trace("applying 002: AXE");
			case "003":
				trace("applying 003: SHIELD");				
			case "004":
				trace("applying 004: CANDLE");
				timer += 20;
				GameData.currentLevel.timeLimit += 20;
			case "005":
				trace("applying 005: HEAVY BOOTS");
			case "006":
				trace("applying 006: WINGS");
				player.isAffectedByTerrain = false;
			case "007":
				trace("applying 007: SPEED BOOTS");
				player.speed *= 1.25;
			case "100":
				trace("applying 100: GLOVES");
			case "101":
				trace("applying 101: KNIFE");
			case "300":
				trace("applying 300: PICKAXE");
		}
	}
}