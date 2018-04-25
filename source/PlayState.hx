package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class PlayState extends FlxState {
	private var _player:Player;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _grpResources:FlxTypedGroup<Resource>;
	private var _grpDoors:FlxTypedGroup<Door>;
	private var _HUD:HUD;
	
	//private var _rooms:FlxTypedGroup<Room>;
	
	
	override public function create():Void {
		//_rooms = new FlxTypedGroup<Room>();
		//var room0 = new Room(0, AssetPaths.tut001a__oel);
		//_rooms.add(room0);
		//add(room0);
		//add(_HUD);
		_map = new FlxOgmoLoader(AssetPaths.tut001a__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		_mWalls.follow();
		_mWalls.setTileProperties(1, FlxObject.NONE);
		//_mWalls.setTileProperties(3, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		_grpResources = new FlxTypedGroup<Resource>();
		_player = new Player();
		_map.loadEntities(placeEntities, "entities");
		add(_grpResources);
		add(_player);
		_HUD = new HUD(60, 1);
		add(_HUD);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_player, _mWalls);
		FlxG.overlap(_player, _grpResources, playerTouchResource);
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player") {
			_player.x = x;
			_player.y = y;
		} else if (entityName == "resource") {
			_grpResources.add(new Resource(x, y, Std.parseInt(entityData.get("type"))));
		} else if (entityName == "door") {
			//_grpDoors.add(new Door(x, y, Std.parseInt(entityData.get("direction"))));
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
				_HUD.addWood(amount);
			default:
				trace("resource type was: " + res.type);
		}
	}
}