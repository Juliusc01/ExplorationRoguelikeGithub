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
	public var allEnemiesDead:Bool;
	public var myHouse:House;
	public var myPowerUp:PowerUp;
	public var isHome:Bool = false;
	public var distFromHome:Int;
	
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
		allEnemiesDead = false;
		myPowerUp = null;
		myHouse = null;
		
		_map.loadEntities(placeEntities, "entities");

		add(grpEnemies);
		add(grpDoors);
		
		myHouse = null;
		if (isHome) {
			// TODO: Add instruction text embedded on floor for home tile
			add(new FlxSprite(Const.HOUSE_X - 24, Const.HOUSE_Y + Const.HOUSE_HEIGHT + Const.TILE_HEIGHT, AssetPaths.instruction_move__png));
			myHouse = new House(Const.HOUSE_X, Const.HOUSE_Y);
			trace("House location is: " + Const.HOUSE_X + ", " + Const.HOUSE_Y);
			add(myHouse);
		}
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
	
	public function hasKilledAllEnemies() {
		if (grpEnemies.getFirstExisting() == null) {
			this.allEnemiesDead = true;
			trace("all enemies dead");
		}
	}

	public function resetRoom():Void {
		if (!allEnemiesDead) {
			remove(grpEnemies);
			grpEnemies = new FlxTypedGroup<Enemy>();
			_map.loadEntities(placeEnemies, "entities");
			add(grpEnemies);
		}
	}
	
	private function placeEnemies(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "enemy") {
			grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("Etype"))));
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
			// TODO: check for overlap on home here and prevent the resource from counting/being generated
			// if it does.
			this.numResources++;
			//grpResources.add(new Resource(x, y, Std.parseInt(entityData.get("type"))));
		} else if (StringTools.endsWith(entityName, "door")) {
			grpDoors.add(new Door(x, y, convertDoorTypeToEnum(entityName)));
		} else if (entityName == "enemy") {
			grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("Etype"))));
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
				grpResources.add(new Resource(x, y, resType));
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
					while (myPowerUp.isActive) { //Reroll if you get something you already have
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
		trace("collided with swamp");
		cast (player, Player).isInSwamp = true;
	}
}