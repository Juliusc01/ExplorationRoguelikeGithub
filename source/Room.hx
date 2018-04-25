package;

import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
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
	
	private var _map:FlxOgmoLoader;
	
	public function new(roomId:Int, path:String, isHome:Bool) 
	{
		super(0);
		trace("creating room from: " + path);
		
		_map = new FlxOgmoLoader(path);
		tilemap = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		//tilemap.follow();
		tilemap.setTileProperties(1, FlxObject.NONE);
		tilemap.setTileProperties(2, FlxObject.ANY);
		add(tilemap);
		grpResources = new FlxTypedGroup<Resource>();
		grpDoors = new FlxTypedGroup<Door>();
		_map.loadEntities(placeEntities, "entities");
		
		add(grpResources);
		add(grpDoors);
		
		if (isHome) {
			// TODO: Add instruction text embedded on floor for home tile
			add(new FlxText(150, 150, 100, "Instructions here"));
		}
		

	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "resource") {
			grpResources.add(new Resource(x, y, Std.parseInt(entityData.get("type"))));
		} else if (entityName == "door") {
			grpDoors.add(new Door(x, y, Std.parseInt(entityData.get("direction"))));
		}
	}
	
}