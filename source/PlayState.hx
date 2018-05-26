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
	private var _doorX:Float;

	
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
	public var winning:Bool;
	public var hasShieldForNextHit:Bool;
	
	// Variables for resetting the level on loss
	private var _gotPowerUp:Bool;
	private var _startingCraftAmt:Int;
	private var _startingCraftLvls:Array<Int>;
	
	//Logging variables
	private var playerStartingHealth:Int;
	private var enemyIDsToDamageDone:Map<String, Int>;
	private var enemiesKilled:Map<String, Int>;
	private var enemyIDsToDamageDoneTotal:Map<String, Int>;
	private var enemiesKilledTotal:Map<String, Int>;
	public var grpEnemiesTotal:FlxTypedGroup<Enemy>;
	private var startTimer:Float;
	
	private var _inMenu:Bool;
	private var _craftingMenu:CraftingMenu;
	
	private var _inCameraFade:Bool;
	private var _cameraAlpha:Float;
	
	override public function create():Void {
		if (GameData.isGoodAtGame && GameData.currentLevel.levelNum > 2 && !GameData.inControlGroup) {
			GameData.currentLevel.difficulty *= GameData.difficultyModifier;
			trace("Making game harder");
		} else if (GameData.isBadAtGame && GameData.currentLevel.levelNum > 2 && !GameData.inControlGroup) {
			GameData.currentLevel.difficulty *= GameData.difficultyModifier;
			trace("Making game easier");
		} else if (GameData.inControlGroup) {
			trace("In control group");
		}
		FlxG.mouse.visible = false;
		GameData.currentPlayState = this;
		grpEnemiesTotal = new FlxTypedGroup<Enemy>();
		sword = new Sword(0, 0);
		_doorX = Const.DOOR_X_WITH_ANVIL;
		if (!GameData.currentLevel.hasCrafting) {
			_doorX = Const.DOOR_X_NO_ANVIL;
		}
		var playerX = _doorX - 9;
		player = new Player(playerX, Const.HOUSE_Y + Const.HOUSE_HEIGHT + 4, sword);
		playerStartingHealth = player.hp;
		timer = GameData.currentLevel.timeLimit;
		startTimer = timer;
		currentWood = 0;
		currentFood = 0;
		currentStone = 0;
		winning = true;
		
		_layout = new Layout(GameData.currentLevel.numRooms);		
		_currentRoom = _layout.getCurrentRoom();
		_cameraAlpha = 1;
		
		enemyIDsToDamageDone = new Map<String,Int>();
		enemiesKilled = new Map<String, Int>();
		enemyIDsToDamageDoneTotal = new Map<String,Int>();
		enemiesKilledTotal = new Map<String, Int>();
		add(_currentRoom);
		_HUD = new HUD(this);
		add(_HUD);
		sword.kill();
		add(player);
		add(sword);
		
		_craftingMenu = new CraftingMenu();
		add(_craftingMenu);
		applyStartingCraft();
		applyActivePowerUps();
		super.create();
	}

	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (_inMenu) {
			return;
		}
		
		FlxG.collide(player, _currentRoom.tilemap);
		timer -= elapsed;
		
		
		//TODO: remove this after testing health loss
		if (FlxG.keys.pressed.X) {
			winLevel();
		}
		//TODO: remove this after testing health loss
		if (FlxG.keys.pressed.Z) {
			player.speed += .1;
			trace("speed: " + player.speed);
		}
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
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.grpDoors);
		FlxG.collide(_currentRoom.grpAnimals, _currentRoom.grpDoors);
		
		FlxG.collide(player, _currentRoom.grpResources);
		hasEnoughWood = currentWood >= GameData.currentLevel.woodReq;
		hasEnoughFood = currentFood >= GameData.currentLevel.foodReq;
		hasEnoughStone = currentStone >= GameData.currentLevel.stoneReq;
		FlxG.overlap(player, _currentRoom.grpDoors, playerTouchDoor);
		FlxG.overlap(player, _currentRoom.myPowerUp, playerTouchPowerUp);
		
		FlxG.collide(player, _currentRoom.grpEnemies, playerTouchEnemy);
		FlxG.overlap(player, _currentRoom.grpObstacles, playerTouchEnemy);
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
		FlxG.collide(_currentRoom.grpEnemies, _currentRoom.grpEnemies);
		
		FlxG.overlap(sword, _currentRoom.grpFeatures, swordTouchFeature);
		FlxG.collide(player, _currentRoom.grpFeatures);
		FlxG.collide(_currentRoom.grpAnimals, _currentRoom.grpFeatures);
		
		// Check for winning by entering the door.
		if (_currentRoom.isHome) {
			if (FlxMath.distanceToPoint(player, new FlxPoint(_doorX, Const.DOOR_Y)) < 8 
					&& (player.facing == FlxObject.UP)) {
				checkForWin();
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
	
	public function checkForWin():Void {
		var canWin = hasEnoughWood && hasEnoughFood && hasEnoughStone && winning;
		if (canWin) {
			winning = false;
			winLevel();
		} else {
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
	
	public function showCraftingMenu():Void {
		trace("showing it now!");
		_inMenu = true;
		player.active = false;
		_currentRoom.grpEnemies.active = false;
		_currentRoom.grpObstacles.active = false;
		_currentRoom.grpAnimals.active = false;
		_craftingMenu.show();
	}
	
	public function hideCraftingMenu():Void {
		_inMenu = false;
		player.active = true;
		_currentRoom.grpEnemies.active = true;
		_currentRoom.grpObstacles.active = true;
		_currentRoom.grpAnimals.active = true;
		_craftingMenu.hide();
	}
	
	private function applyStartingCraft():Void {
		_startingCraftAmt = GameData.currentCraft;
		_startingCraftLvls = new Array<Int>();
		for (i in 0...GameData.currentCraftLvls.length) {
			_startingCraftLvls.push(GameData.currentCraftLvls[i]);
		}
	
		player.damage += (Const.CRAFT_DMG_UP * GameData.currentCraftLvls[0]);
		player.hp += (Const.CRAFT_HP_UP * GameData.currentCraftLvls[1]);
		player.maxHp += (Const.CRAFT_HP_UP * GameData.currentCraftLvls[1]);
		player.speed += (Const.CRAFT_SPEED_UP * GameData.currentCraftLvls[2]);
	}
	
	public function addCraftingLvl(which:Int):Void {
		var currLvl = GameData.currentCraftLvls[which];
		var costs = Const.CRAFT_COSTS[currLvl]; // idx 0 is craft, 1 is resource cost
		if (currLvl < Const.CRAFT_COSTS.length) {
			if (GameData.currentCraft >= costs[0]) {
				switch (which) {
					case 0:
						if (currentWood - GameData.currentLevel.woodReq >= costs[1]) {
							// LEVEL UP WITH WOOD
							currentWood -= costs[1];
							if (currentWood < GameData.currentLevel.woodReq) {
								_HUD.forceWoodColorReset();
							}
							GameData.currentCraft -= costs[0];
							GameData.currentCraftLvls[0]++;
							player.damage += Const.CRAFT_DMG_UP;
							GameData.myLogger.logLevelAction(LoggingActions.USE_CRAFTING, { skill: which, toLevel: currLvl + 1, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame });
						} else {
							_craftingMenu.flashAvailable(which + 1);
						}
					case 1:
						if (currentFood - GameData.currentLevel.foodReq >= costs[1]) {
							// LEVEL UP WITH FOOD
							currentFood -= costs[1];
							if (currentFood < GameData.currentLevel.foodReq) {
								_HUD.forceFoodColorReset();
							}
							GameData.currentCraft -= costs[0];
							GameData.currentCraftLvls[1]++;
							player.maxHp += Const.CRAFT_HP_UP;
							player.hp += Const.CRAFT_HP_UP;
							GameData.myLogger.logLevelAction(LoggingActions.USE_CRAFTING, { skill: which, toLevel: currLvl + 1, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame });
						} else {
							_craftingMenu.flashAvailable(which + 1);
						}
					case 2:
						if (currentStone - GameData.currentLevel.stoneReq >= costs[1]) {
							// LEVEL UP WITH STONE
							currentStone -= costs[1];
							if (currentStone < GameData.currentLevel.stoneReq) {
								_HUD.forceStoneColorReset();
							}
							GameData.currentCraft -= costs[0];
							GameData.currentCraftLvls[2]++;
							player.speed += Const.CRAFT_SPEED_UP;
							GameData.myLogger.logLevelAction(LoggingActions.USE_CRAFTING, { skill: which, toLevel: currLvl + 1, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame });
						} else {
							_craftingMenu.flashAvailable(which + 1);
						}
				}
			} else {
				_craftingMenu.flashAvailable(0);
			}
		}
	}
	
	//Test end level function

	private function loseLevel():Void {
		// If they got a powerup this level, then they lose it when they lose the level.
		// It will always be the last one in the array.
		trace("losing level");
		if (GameData.currentLevel.levelNum < 3) {
			GameData.isBadAtGame = true;
			GameData.isGoodAtGame = false;
		}
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
		GameData.currentCraft = _startingCraftAmt;
		GameData.currentCraftLvls = _startingCraftLvls;
		analyzeLevel(true);
		GameData.lostToHp = player.hp <= 0;
		FlxG.switchState(new LoseState());
	}
	
	private function winLevel():Void {
		if (GameData.currentLevel.levelNum < 3) {
			GameData.totalDamageTaken += (100 - player.hp);
			GameData.totalTimeLeft += timer;
		}
		if (GameData.currentLevel.levelNum == 2) {
			if (!GameData.isBadAtGame && GameData.totalDamageTaken <= 20 && GameData.totalTimeLeft >= 155) {
				GameData.isGoodAtGame = true;
			} else if (GameData.totalDamageTaken >= 40 || GameData.totalTimeLeft <= 130) {
				GameData.isBadAtGame = true;
			}
			trace("time extra: " + GameData.totalTimeLeft);
			trace("damage taken: " + GameData.totalDamageTaken);
			trace("isGood?: " + GameData.isGoodAtGame);
			trace("isBad?: " + GameData.isBadAtGame);
		}
		GameData.currentMenuState = 1;
		if (GameData.currentLevel == GameData.levels[GameData.levels.length - 1]) {
			GameData.currentMenuState = 2;
		}
		analyzeLevel(false);
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
					GameData.myLogger.logLevelAction(LoggingActions.POWERUP, { pu: currPowerUp.powerUpID, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame });
				}
			}
			PU.kill();
		}
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void {
		if (P.alive && P.exists && E.alive && E.exists) {
			var currHealth:Int = P.hp;
			P.hurtByEnemy(E);
			var endHealth:Int = P.hp;
			if (currHealth - endHealth > 0) {
				var damageDoneByEnemy:Null<Int> = enemyIDsToDamageDone.get("" + E.etype);
				if (damageDoneByEnemy == null) {
					enemyIDsToDamageDone.set("" + E.etype, currHealth - endHealth);
				} else {
					enemyIDsToDamageDone.set("" + E.etype, damageDoneByEnemy + (currHealth - endHealth));
				}
				var damageDoneByEnemyTotal:Null<Int> = enemyIDsToDamageDoneTotal.get("" + E.etype);
				if (damageDoneByEnemyTotal == null) {
					enemyIDsToDamageDoneTotal.set("" + E.etype, currHealth - endHealth);
				} else {
					enemyIDsToDamageDoneTotal.set("" + E.etype, damageDoneByEnemyTotal + (currHealth - endHealth));
				}
			}
		}
	}
	
	private function playerTouchProjectile(P:Player, Pro:Projectile):Void {
		if (P.alive && P.exists && Pro.alive && Pro.exists) {
			var currHealth:Int = P.hp;
			P.hurtByProjectile(Pro);
			var endHealth:Int = P.hp;
			if (currHealth - endHealth > 0) {
				var damageDoneByEnemy:Null<Int> = enemyIDsToDamageDone.get("" + Pro.myEnemy.etype + "P");
				if (damageDoneByEnemy == null) {
					enemyIDsToDamageDone.set("" + Pro.myEnemy.etype + "P", currHealth - endHealth);
				} else {
					enemyIDsToDamageDone.set("" + Pro.myEnemy.etype + "P", damageDoneByEnemy + (currHealth - endHealth));
				}
				var damageDoneByEnemyTotal:Null<Int> = enemyIDsToDamageDoneTotal.get("" + Pro.myEnemy.etype + "P");
				if (damageDoneByEnemyTotal == null) {
					enemyIDsToDamageDoneTotal.set("" + Pro.myEnemy.etype + "P", currHealth - endHealth);
				} else {
					enemyIDsToDamageDoneTotal.set("" + Pro.myEnemy.etype + "P", damageDoneByEnemyTotal + (currHealth - endHealth));
				}
			}
		_currentRoom.grpProjectiles.remove(Pro);
		}
	}
	
	private function killProjectile(P:Projectile, W:FlxTilemap) {
		_currentRoom.grpProjectiles.remove(P);
	}
	
	private function swordTouchEnemy(S:Sword , E:Enemy):Void {
		if (S.alive && S.exists && E.alive && E.exists && player.swingNumber != E.lastPlayerSwingNumber) {
			var currKills:Int = player.kills;
			E.hurtByPlayer(player);
			var endKills:Int = player.kills;
			if (endKills > currKills) {
				var numEnemiesKilledOfType:Null<Int> = enemiesKilled.get("" + E.etype);
				if (numEnemiesKilledOfType == null) {
					enemiesKilled.set("" + E.etype,1);
				} else {
					enemiesKilled.set("" + E.etype, numEnemiesKilledOfType+1);
				}
				var numEnemiesKilledOfTypeTotal:Null<Int> = enemiesKilledTotal.get("" + E.etype);
				if (numEnemiesKilledOfTypeTotal == null) {
					enemiesKilledTotal.set("" + E.etype,1);
				} else {
					enemiesKilledTotal.set("" + E.etype, numEnemiesKilledOfTypeTotal+1);
				}
			}
			
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
	
	private function swordTouchFeature(S: Sword, F:Feature):Void {
		if (S.alive && S.exists && F.alive && F.exists && FlxG.keys.justPressed.SPACE) {
			F.touchBySword();
			trace("touched feature: " + F);
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
			case 3: // Craft
				amount = possiblyAddBonus(amount, "300");
				GameData.currentCraft += amount;
				_HUD.flashCraft(FlxColor.GREEN);
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
		analyzeRoom();
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
		trace("switched to new room position");
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
	
	private function analyzeLevel(lost:Bool):Void {
		var enemyMapIteratorKeys = enemyIDsToDamageDoneTotal.keys();
		var stringOfMap:String = "";
		// Gets enemy damage map into printable form
		while (enemyMapIteratorKeys.hasNext()) {
			var currEnemyMapKey = enemyMapIteratorKeys.next();
			stringOfMap += currEnemyMapKey.toString() + ": ";
			stringOfMap += enemyIDsToDamageDoneTotal.get(currEnemyMapKey) + ", ";
		}
		stringOfMap = stringOfMap.substring(0, stringOfMap.length - 2);
		
		/////
		//Counts of number of enemies
		var stringOfMapKilled:String = "";

		//Gets enemies killed into printable form
		var enemiesKilledIteratorKeys = enemiesKilledTotal.keys();
		while (enemiesKilledIteratorKeys.hasNext()) {
			var currEnemyMapKey = enemiesKilledIteratorKeys.next();
			stringOfMapKilled += currEnemyMapKey.toString() + ": ";
			stringOfMapKilled += enemiesKilledTotal.get(currEnemyMapKey) + ", ";
		}
		stringOfMapKilled = stringOfMapKilled.substring(0, stringOfMapKilled.length - 2);
		GameData.myLogger.logLevelEnd({won: !lost, hp: player.hp, time: this.timer, visited: _layout.getNumKnownRooms(),
										rooms: _layout.numRooms, powerups:PowerUp.powerUpIDS(), enemiesHurtingPlayer:stringOfMap,
										enemiesKilledByPlayer:stringOfMapKilled, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, 
										isBad: GameData.isBadAtGame});
		enemyIDsToDamageDoneTotal = new Map<String,Int>();
		enemiesKilledTotal = new Map<String, Int>();
	}
	
	private function analyzeRoom():Void {
		var enemyMapIteratorKeys = enemyIDsToDamageDone.keys();
		var stringOfMap:String = "";
		//Gets enemy damage map into printable form
		while (enemyMapIteratorKeys.hasNext()) {
			var currEnemyMapKey = enemyMapIteratorKeys.next();
			stringOfMap += currEnemyMapKey.toString() + ": ";
			stringOfMap += enemyIDsToDamageDone.get(currEnemyMapKey) + ", ";
		}
		stringOfMap = stringOfMap.substring(0, stringOfMap.length - 2);
		//Counts of number of enemies
		var enemiesTotalItr = _currentRoom.grpEnemies.iterator();
		var mapEnemyTypeToNumOf = new Map<String, Int>();
		while (enemiesTotalItr.hasNext()) {
			var currEnemy = enemiesTotalItr.next();
			if (mapEnemyTypeToNumOf.get("" + currEnemy.etype) == null) {
				mapEnemyTypeToNumOf.set("" + currEnemy.etype, 1);
			} else {
				mapEnemyTypeToNumOf.set("" + currEnemy.etype, mapEnemyTypeToNumOf.get("" + currEnemy.etype) + 1);
			}
			
		}
		var stringOfMapKilled:String = "";

		//Gets enemies killed into printable form
		var enemiesTotalIteratorKeys = mapEnemyTypeToNumOf.keys();
		while (enemiesTotalIteratorKeys.hasNext()) {
			var currEnemyMapKey = enemiesTotalIteratorKeys.next();
			if(Std.parseInt(currEnemyMapKey.toString()) < 99) {
				stringOfMapKilled += currEnemyMapKey.toString() + ": ";
				var amountKilled:Int = 0;
				if (enemiesKilled.get(currEnemyMapKey.toString()) != null) {
					amountKilled = enemiesKilled.get(currEnemyMapKey.toString());
				}
				stringOfMapKilled += amountKilled + " out of " + mapEnemyTypeToNumOf.get(currEnemyMapKey.toString()) + ", ";
			}
		}
		stringOfMapKilled = stringOfMapKilled.substring(0, stringOfMapKilled.length - 2);
		GameData.myLogger.logLevelAction(LoggingActions.CHANGE_ROOM, 
											{roomID: _currentRoom.roomID, hpLost: playerStartingHealth - player.hp, 
											playerEndHealth: player.hp, timeElapsed:startTimer-timer , timeLeft:timer,
											enemiesHurtingPlayer:stringOfMap, enemiesKilledByPlayer:stringOfMapKilled, 
											inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame});
		//Resets logging fields
		playerStartingHealth = player.hp;
		startTimer = timer;
		enemyIDsToDamageDone = new Map<String,Int>();
		enemiesKilled = new Map<String, Int>();
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
				player.speed *= 1.15;
			case "008":
				trace("applying 008: SPEED STACKING");
			case "009":
				trace("applying 009: GIFT OF LIFE");
			case "010":
				trace("applying 010: AMULET OF SHIELDING");
				hasShieldForNextHit = true;
			case "100":
				trace("applying 100: GLOVES");
			case "101":
				trace("applying 101: KNIFE");
			case "300":
				trace("applying 300: RING");
			case "301":
				trace("applying 301: PURSE");
				GameData.currentCraft++;
		}
	}
}