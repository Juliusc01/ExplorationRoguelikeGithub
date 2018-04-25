package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
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
	private var _currentRoom:Room;
	private var _currentRoomRow:Int;
	private var _currentRoomCol:Int;
	
	private var _rooms:Array<Array<Room>>;
	
	
	override public function create():Void {
		_rooms = new Array<Array<Room>>();
		var room0 = new Room(0, AssetPaths.tut001a__oel, true);
		var room1 = new Room(1, AssetPaths.tut001b__oel, false);
		_rooms[0] = new Array<Room>();
		_rooms[0][0] = room0;
		_rooms[0][1] = room1;		
		_currentRoom = room0;
		_currentRoomRow = 0;
		_currentRoomCol = 0;
		
		add(_currentRoom);
		_player = new Player(100, 100);
		_HUD = new HUD(60, 1);
		add(_HUD);
		add(_player);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_player, _mWalls);
		FlxG.overlap(_player, _currentRoom.grpResources, playerTouchResource);
		FlxG.overlap(_player, _currentRoom.grpDoors, playerTouchDoor);
	}
	
	/*private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player") {
			_player.x = x;
			_player.y = y;
		} else if (entityName == "resource") {
			_grpResources.add(new Resource(x, y, Std.parseInt(entityData.get("type"))));
		} else if (entityName == "door") {
			_grpDoors.add(new Door(x, y, Std.parseInt(entityData.get("direction"))));
		}
	}*/
	
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
	
	private function playerTouchDoor(P:Player, D:Door):Void {
		if (P.alive && P.exists && D.alive && D.exists) {
			trace ("Triggered door touch!");
			switchToRoom(D.direction);
		}
	}
	
	private function switchToRoom(outGoingDir:Int) {
		remove(_currentRoom);
		//remove(_player);
		switch(outGoingDir) { //TODO: enums
			case 0: // right
				_currentRoomCol++;
			case 1: // down
				_currentRoomRow++;
			case 2: // left
				_currentRoomCol--;
			case 3: // up
				_currentRoomRow--;
		}
		_currentRoom = _rooms[_currentRoomRow][_currentRoomCol];
		trace("switching to room " + _currentRoomRow + ", " + _currentRoomCol + " by moving in direction: " + outGoingDir);
		add(_currentRoom);
		//add(_player);
		_player.x = _player.y = 100; //TODO: use the outgoing direction to determine where to place player
	}
}