package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
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
	private var _currentRoomRow:Int;
	private var _currentRoomCol:Int;
	private var _rooms:Array<Array<Room>>;
	
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
		
		var layout = new Layout(25);
		_rooms = layout.generateRooms();
		
		/*var room0 = new Room(0, AssetPaths.tut001a__oel, true);
		var room1 = new Room(1, AssetPaths.tut001b__oel, false);
		var room2 = new Room(2, AssetPaths.tut001c__oel, false);
		_rooms[0] = new Array<Room>();
		_rooms[0][0] = room0;
		_rooms[0][1] = room1;
		_rooms[1] = new Array<Room>();
		_rooms[1][0] = room2;
		_currentRoom = room0;*/
		_currentRoomRow = layout.getStartY();
		_currentRoomCol = layout.getStartX();
		_currentRoom = _rooms[_currentRoomRow][_currentRoomCol];
		
		add(_currentRoom);
		_player = new Player(FlxG.width / 2, FlxG.height / 2);
		_HUD = new HUD(this);
		add(_HUD);
		add(_player);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_player, _currentRoom.tilemap);
		timer -= elapsed;
		//Dummy level ending code
		if (timer <= 50) {
			endLevel();
		}
		//FlxG.collide(_player, _currentRoom.grpResources);
		FlxG.overlap(_player, _currentRoom.grpResources, playerTouchResource);
		FlxG.overlap(_player, _currentRoom.grpDoors, playerTouchDoor);
	}
	
	//Test end level function
	private function endLevel():Void {
		timer = 60;
		remove(_currentRoom);
		_currentRoomCol++;
		_currentRoom = _rooms[_currentRoomRow][_currentRoomCol];
		//trace("switching to room " + _currentRoomRow + ", " + _currentRoomCol + " by moving in direction: " + outgoingDir);
		add(_currentRoom);
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
				addWood(amount);
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
	
	private function switchToRoom(outgoingDir:Direction) {
		FlxG.camera.fade(FlxColor.BLACK, 0.25, true, true); //TODO: this doesn't work right now?
		remove(_currentRoom);
		switch(outgoingDir) { 
			case Direction.EAST: 
				_currentRoomCol++;
				_player.x = 0;
			case Direction.SOUTH: 
				_currentRoomRow++;
				_player.y = Constants.TILE_HEIGHT * 3;
			case Direction.WEST: // left
				_currentRoomCol--;
				_player.x = FlxG.width - Constants.TILE_WIDTH;
			case Direction.NORTH: // up
				_currentRoomRow--;
				_player.y = FlxG.height - 3 * Constants.TILE_WIDTH;
		}
		_currentRoom = _rooms[_currentRoomRow][_currentRoomCol];
		trace("switching to room " + _currentRoomRow + ", " + _currentRoomCol + " by moving in direction: " + outgoingDir);
		add(_currentRoom);
	}
	
	private function addWood(amount:Int):Void {
		currentWood += amount;
		trace("Added " + amount + ", now have : " + currentWood);
	}
}