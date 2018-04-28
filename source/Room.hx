package;

import flixel.FlxBasic;
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
	public var myHouse:House;
	public var myPowerUp:PowerUp;
	public var isHome:Bool = false;
	
	private var _map:FlxOgmoLoader;
	
	public function new(path:String, isHome:Bool) 
	{
		super(0);
		trace("creating room from: " + path);
		
		_map = new FlxOgmoLoader(path);
		tilemap = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		//tilemap.follow();
		tilemap.setTileProperties(1, FlxObject.NONE);
		tilemap.setTileProperties(3, FlxObject.NONE);
		tilemap.setTileProperties(4, FlxObject.NONE, swampCollide);
		tilemap.setTileProperties(2, FlxObject.ANY);
		add(tilemap);
		grpResources = new FlxTypedGroup<Resource>();
		grpDoors = new FlxTypedGroup<Door>();
		myPowerUp = null;
		_map.loadEntities(placeEntities, "entities");
		myHouse = null;
		if (myPowerUp != null) {
			trace("powerupadded");
			trace(""+myPowerUp.imagePath);
			add(myPowerUp);
		}
		add(grpResources);
		add(grpDoors);
		
		if (isHome) {
			this.isHome = isHome;
			// TODO: Add instruction text embedded on floor for home tile
			add(new FlxText(150, 150, 100, "Instructions here"));
			myHouse = new House(50, 50);
			add(myHouse);
		}
		
		
		

	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "resource") {
			grpResources.add(new Resource(x, y, Std.parseInt(entityData.get("type"))));
		} else if (StringTools.endsWith(entityName, "door")) {
			grpDoors.add(new Door(x, y, convertDoorTypeToEnum(entityName)));
		} else if (entityName == "powerup") {
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