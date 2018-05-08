package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import Player;
import Enemy0;
import Enemy1;
import Enemy2;
import Enemy3;
import Enemy4;
import Enemy100;
import Enemy101;
import Enemy102;
import Enemy103;
import Enemy104;
import Enemy105;
import Enemy106;
import Enemy200;

/**
 * A room encapsulates all of the data that is specific to one room of the map.
 * This includes all entities (resources, doors) and tilemaps for this room.
 * 
 * The room is a FlxGroup, much like a gamestate. We can add all of the needed elements
 * to the room, then add the correct room to the playstate in order to switch to that room.
 * @author Alex Vrhel
 */
class Room extends FlxGroup 
{

	public var tilemap:FlxTilemap;
	public var grpResources:FlxTypedGroup<Resource>;
	public var grpDoors:FlxTypedGroup<Door>;
	public var grpEnemies:FlxTypedGroup<Enemy>;
	public var grpProjectiles:FlxTypedGroup<Projectile>;
	private var myEnemies:List<Array<Int>>;
	public var myHouse:House;
	public var myPowerUp:PowerUp;
	public var isHome:Bool = false;
	public var distFromHome:Int;
	
	public var isKnown:Bool;
	
	public var numResources:Int;
	public var hasPowerUp:Bool;
	public var hasShop:Bool;
	
	// Array and index of what resources
	// to place, set one at a time randomly
	// by the Layout class.
	private var _resList:Array<Int>;
	
	private var _map:FlxOgmoLoader;
	
	public function new(path:String, distanceFromHome:Int) 
	{
		super(0);
		trace("creating room from: " + path);
		if (distanceFromHome == 0) {
			this.isHome = true;
		}
		this.distFromHome = distanceFromHome;
		
		_map = new FlxOgmoLoader(path);
		tilemap = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		//tilemap.follow();
		tilemap.setTileProperties(1, FlxObject.NONE);
		tilemap.setTileProperties(3, FlxObject.NONE);
		tilemap.setTileProperties(4, FlxObject.NONE, swampCollide);
		tilemap.setTileProperties(2, FlxObject.ANY);
		add(tilemap);
		
		this.hasPowerUp = false;
		this.numResources = 0;
		this.hasShop = false;
		
		grpResources = new FlxTypedGroup<Resource>();
		grpDoors = new FlxTypedGroup<Door>();
		grpEnemies = new FlxTypedGroup<Enemy>();
		grpProjectiles = new FlxTypedGroup<Projectile>();
		myEnemies = new List<Array<Int>>();
		myPowerUp = null;
		myHouse = null;
		
		_map.loadEntities(placeEntities, "entities");
		
		add(grpDoors);
		
		myHouse = null;
		//Only generate house if not testing a level
		if (GameData.levels.length == 1 && GameData.testingHome == false) {
			this.isHome = false;
		}
		if (isHome) {
			addInstructionText();
			myHouse = new House(Const.HOUSE_X, Const.HOUSE_Y);
			trace("House location is: " + Const.HOUSE_X + ", " + Const.HOUSE_Y);
			add(myHouse);
		} else {
			_map.loadEntities(placeEnemies, "entities");
		}
		add(grpEnemies);
	}

	/**
	 * To be called after all of the room-generation
	 * code is finished. Inits the room with its currently
	 * added contents.
	 */
	public function finalizeRoom():Void {
		trace("resource list for room is: " + _resList);
		_map.loadEntities(finalizeEntities, "entities");
		
		if (myPowerUp != null) {
			trace("powerupadded");
			trace(""+myPowerUp.imagePath);
			add(myPowerUp);
		}
		add(grpResources);
		//TODO: add shop here as well.
	}
	
	public function addResource(resType:Int):Void {
		if (_resList == null) {
			_resList = new Array<Int>();
		}
		_resList.push(resType);
	}

	public function resetRoom():Void {
		remove(grpProjectiles);
		grpProjectiles.clear();
		add(grpProjectiles);
		trace("grpEnemies: " + grpEnemies);
		if (grpEnemies.getFirstExisting() != null) {
			remove(grpEnemies);
			grpEnemies.clear();
			var myItr = myEnemies.iterator();
			while (myItr.hasNext()) {
				var enemyVar = myItr.next();
				var realEnemy = Type.createInstance(Type.resolveClass("Enemy"+enemyVar[2]), [enemyVar[0], enemyVar[1], enemyVar[2]]);
				grpEnemies.add(realEnemy);
				if (realEnemy.healthbar != null) {
					add(realEnemy.healthbar);
				}
			}
			add(grpEnemies);
		}
	}
	
	public function enemyShootProjectile(P:Projectile):Void {
		grpProjectiles.add(P);
		add(grpProjectiles);
	}
	
	private function placeEnemies(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "enemy") {
			var myEnemyEtype;
			var realEnemy;
			if (Std.parseInt(entityData.get("Etype")) == -1) {
				var myRandom = new FlxRandom();
				myEnemyEtype = GameData.enemiesRandom[myRandom.int(0, GameData.enemiesRandom.length - 1)];
			} else {
				myEnemyEtype = Std.parseInt(entityData.get("Etype"));
			}
			realEnemy = Type.createInstance(Type.resolveClass("Enemy" + myEnemyEtype), [x, y, myEnemyEtype]);
			grpEnemies.add(realEnemy);
			if (realEnemy.healthbar != null) {
				add(realEnemy.healthbar);
			}
			myEnemies.push([x, y, myEnemyEtype]);
		}
	}

	/**
	 * First pass of entity placement. Place the entities
	 * that we know will exist in the room, and set fields
	 * for the room according to entities that need to be
	 * managed by the Layout class.
	 */
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "resource") {
			this.numResources++;
		} else if (StringTools.endsWith(entityName, "door")) {
			grpDoors.add(new Door(x, y, convertDoorTypeToEnum(entityName)));
		} else if (entityName == "powerup") {
			this.hasPowerUp = true;
		}
	}
	
	private function finalizeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "resource") {
			var resType:Int = _resList.pop();
			if (resType != -1) {
				if (resType == 1) {
					if (FlxG.random.bool(50)) {
						var rabbit = new Enemy200(x, y, 200);
						grpEnemies.add(rabbit);
						add(rabbit.healthbar);
						myEnemies.push([x, y, 200]);
					} else {
						grpResources.add(new Resource(x, y, resType));
					}
				} else {
					grpResources.add(new Resource(x, y, resType));
				}
			}
		} else if (entityName == "powerup") {
			if (this.hasPowerUp) {
				if (entityData.get("itemID") != "-1") {
					for (currPowerUp in GameData.powerUps) {
						if (currPowerUp.powerUpID == entityData.get("itemID")) {
							myPowerUp = currPowerUp;
						}
					}
				} else {
					var myRandom = new FlxRandom();
					myPowerUp = GameData.powerUps[myRandom.int(0, GameData.powerUps.length - 1)];
					while (myPowerUp.isActive || !myPowerUp.isAllowedOnLevel()) { //Reroll if you get something you already have
						myPowerUp = GameData.powerUps[myRandom.int(0, GameData.powerUps.length - 1)];
					}
				}
				myPowerUp.changeXY(x, y);
				trace(myPowerUp.toString() +"");
			}
		}
	}
	
	/**
	 * Simple function to take in the entity name of a door and return
	 * an enum of the direction. Simpler to use different entity types
	 * for each direction of door (more clear in level editor, can more
	 * easily prevent placing doors incorrectly).
	 */
	private function convertDoorTypeToEnum(doorName:String):Direction {
		if (doorName == "w_door") {
			return Direction.WEST;
		} else if (doorName == "s_door") {
			return Direction.SOUTH;
		} else if (doorName == "e_door") {
			return Direction.EAST;
		} else if (doorName == "n_door") {
			return Direction.NORTH;
		} else {
			FlxG.log.error("Found door entity name of: " + doorName);
			return null;
		}
	}
	
	/**
	 * Callback fn assigned to when the player collides with any
	 * tile of type 4 (swamp). Simply sets a flag in the player
	 * to remember they are currently in the swamp.
	 */
	private function swampCollide(tile:FlxObject, player:FlxObject):Void {
		if (player == GameData.currentPlayState.player) {
			cast (player, Player).isInSwamp = true;
		}	
	}
	
	private function addInstructionText():Void {
		// Each part is 50 wide, 8 px padding between them.
		var x1 = Const.HOUSE_X + (Const.HOUSE_WIDTH / 2) - 50;
		var x2 = x1 + 58;
		var y1 = Const.HOUSE_Y + Const.HOUSE_HEIGHT + Const.TILE_HEIGHT; 
		var y2 = y1 + 20;
		var picOffset = (50 - 35) / 2;
		add(new FlxSprite(x1 + picOffset, y1, AssetPaths.instruction_move__png));
		add(new FlxSprite(x2 + picOffset - 1, y1, AssetPaths.instruction_interact__png));
		var text1 = new FlxText(x1, y2, 50, "Move");
		text1.setFormat(HUD.FONT, 14, FlxColor.GRAY, CENTER);
		var text2 = new FlxText(x2, y2 - 16, 50, "Interact/ Attack");
		text2.setFormat(HUD.FONT, 12, FlxColor.GRAY, CENTER);
		trace(text2.size);
		trace(text1.size);
		add(text1);
		add(text2);
	}
}