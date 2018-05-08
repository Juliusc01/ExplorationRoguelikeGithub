package;
import flixel.FlxG;
import flixel.math.FlxMath;

// Simple type to hold a position and direction.
typedef PosCandidate = {
	var x:Int;
	var y:Int;
	var fromDir:Direction;
}

/**
 * The Layout class is responsible for both generating
 * and maintaining the map for each level. It is given
 * a number of rooms on initialization, which it uses
 * to randomly generate a floorplan involving that exact
 * number of rooms. It also exposes the API for which
 * room the player is currently in.
 * @author Alex Vrhel
 */	
class Layout 
{
	// Map of position string -> layout cell object
	// used in generating the layout. Needed to use String
	// because custom types (like Position) use pointer equality,
	// so we serialize them as strings to store in the map.
	private var _map:Map<String, LayoutCell>;
	
	// Array of all spots being considered for the next room
	// to be added to the layout during generation. Includes
	// which direction they would be added "from", so we know
	// how to connect that new tile to the rest of the
	// generated layout.
	private var _nextRoomPossibilities:Array<PosCandidate>;
	
	// Width and Height of the generated layout
	private var _width:Int;
	private var _height:Int;
	
	// Offset of the home tile within the generated layout
	private var _currentRoomCol:Int;
	private var _currentRoomRow:Int;
	
	// Array of rooms, will be filled out by the
	// end of the constructor call.
	private var _rooms:Array<Array<Room>>;
	
	public function new(numRooms:Int) 
	{
		// TODO: enable this once implemented
		if (GameData.currentLevel.levelNum <= 2) {
			trace("generating level for number: " + GameData.currentLevel.levelNum);
			_rooms = generateSpecialRooms(GameData.currentLevel.levelNum);
			var result = distributeEntities();
			trace(result);
			return;
		}
		var finished:Bool = false;
		while (!finished) {
			// Generate layout by doing the following:
			// Maintain a map of (x,y) -> LayoutCell
			_map = new Map<String, LayoutCell>();
			_nextRoomPossibilities = new Array<PosCandidate>();
			var roomsLeft:Int = numRooms;

			
			// Add starting room to the final map, ensuring it exists.
			var startingRoom = new LayoutCell(0, 0);
			startingRoom.exists = true;
			roomsLeft--;
			
			_map.set(new Position(0,0).toString(), startingRoom);
			addPositionsToConsider(startingRoom);
			while (roomsLeft > 0) {
				var nextRoom:PosCandidate = chooseNextRoom();
				addLocationToFinalMap(nextRoom);
				roomsLeft--;
			}
			
			// Array of room shapes, where a room shape
			// is given by the string "WSEN" or some subset
			// of those characters, indicating the exits of the room.
			var roomShapes:Array<Array<String>> = fillRoomShapesArray();
			
			_rooms = generateRooms(roomShapes);
			// Attempt to distribute entities. It is possible we have
			// chosen a layout with insufficient space for resources,
			// so we check whether the layout is valid, and retry if not.
			finished = distributeEntities();
		}
			
			// Free up the memory of the data structures only used during
			// layout generation.
			_map = null;
			_nextRoomPossibilities = null;
	}
	
	public function getCurrentRoom():Room {
		return _rooms[_currentRoomRow][_currentRoomCol];
	}
	
	/**
	 * Change the current room by shifting in the direction
	 * given, returning the new room that was set to be
	 * the current room.
	 */
	public function changeRoom(dir:Direction):Room {
		_rooms[_currentRoomRow][_currentRoomCol].resetRoom();
		switch (dir) {
			case Direction.EAST:
				_currentRoomCol++;
			case Direction.SOUTH:
				_currentRoomRow++;
			case Direction.WEST:
				_currentRoomCol--;
			case Direction.NORTH:
				_currentRoomRow--;
		}
		return getCurrentRoom();
	}
	
	/**
	 * Randomly select a (position, direction to position) value
	 * from the set of options.
	 */
	private function chooseNextRoom():PosCandidate {
		var foundNewLocation:Bool = false;
		trace ("considering: " + _nextRoomPossibilities);
		var retVal:PosCandidate = null;
		while (!foundNewLocation) {
			var index:Int = FlxG.random.int(0, _nextRoomPossibilities.length - 1);
			var vals:Array<PosCandidate> = _nextRoomPossibilities.splice(index, 1);
			trace("vals are: " + vals);
			retVal = vals[0];
			var cell:LayoutCell = getWithoutNull(new Position(retVal.x, retVal.y));
			if (!cell.exists) {
				trace("Found a new cell to add!");
				foundNewLocation = true;
			} else {
				trace("Found duplicate location, continuing");
			}
		}
		return retVal;
	}
	
	/**
	 * Main work of the loop for generating rooms. Takes the position
	 * that was randomly chosen and performs all the work of adding it
	 * to the layout that is being generated.
	 */
	private function addLocationToFinalMap(newLocation:PosCandidate):Void {
		// Get the layout cell corresponding to the new tile.
		var nextCell:LayoutCell = getWithoutNull(new Position(newLocation.x, newLocation.y));
		
		// Ensure the newly selected location will exist in the final map.
		nextCell.exists = true;
		
		// Add a path to and from the new tile.
		connectNewTile(nextCell, newLocation);
		
		// Add position candidates of new map locations reachable from newly added tile.
		addPositionsToConsider(nextCell);
		
		// Update the neighbors that may already exist around this new room.
		updateNeighborCells(nextCell, newLocation.x, newLocation.y);
		trace("added room:" + newLocation);
	}
	
	/**
	 * Gets the value from the corresponding key in the map,
	 * adding a newly constructed value to the map if no
	 * entry existed for that key previously. Then, returns that value.
	 */
	private function getWithoutNull(position:Position):LayoutCell {
		var cell:LayoutCell = _map.get(position.toString());
		if (cell == null) {
			cell = new LayoutCell(position.x, position.y);
			_map.set(position.toString(), cell);
		}
		return cell;
	}
	
	/**
	 * Use information about the new tile we are adding and which
	 * direction we are adding it from to ensure there is a path between the tile
	 * and the rest of the map.
	 */
	private function connectNewTile(nextCell:LayoutCell, newLocation:PosCandidate):Void {
		var fromDir:Direction = newLocation.fromDir;
		// Calculate the position of the previous tile which caused us to add
		// the new tile.
		var fromPosition:Position;
		switch (fromDir) {
			case Direction.WEST:
				fromPosition = new Position(newLocation.x + 1, newLocation.y);
			case Direction.EAST:
				fromPosition = new Position(newLocation.x - 1, newLocation.y);
			case Direction.SOUTH:
				fromPosition = new Position(newLocation.x, newLocation.y - 1);
			case Direction.NORTH:
				fromPosition = new Position(newLocation.x, newLocation.y + 1);
		}
		
		// Connect the tiles by toggling the values in their layoutCells.
		var fromCell:LayoutCell = _map.get(fromPosition.toString());
		switch (fromDir) {
			case Direction.WEST:
				fromCell.hasW = true;
				nextCell.hasE = true;
			case Direction.EAST:
				fromCell.hasE = true;
				nextCell.hasW = true;
			case Direction.SOUTH:
				fromCell.hasS = true;
				nextCell.hasN = true;
			case Direction.NORTH:
				fromCell.hasN = true;
				nextCell.hasS = true;
		}
	}
	
	/**
	 * To be called after a new tile is confirmed to be a part of the map.
	 * Looks at the positions the newly added tile exposes, and adds them to the list
	 * of positions that may be added next.
	 */
	private function addPositionsToConsider(cell:LayoutCell):Void {
		if (!cell.hasE) {
			_nextRoomPossibilities.push({x: cell.x + 1, y: cell.y, fromDir: Direction.EAST});
		}
		if (!cell.hasW) {
			_nextRoomPossibilities.push({x: cell.x - 1, y: cell.y, fromDir: Direction.WEST});
		}
		if (!cell.hasS) {
			_nextRoomPossibilities.push({x: cell.x, y: cell.y + 1, fromDir: Direction.SOUTH});
		}
		if (!cell.hasN) {
			_nextRoomPossibilities.push({x: cell.x, y: cell.y - 1, fromDir: Direction.NORTH});
		}
	}
	
	/**
	 * Given the position of a newly added tile, randomly choose whether to
	 * connect the new tile to its existing neighbor tiles with some small
	 * probability (to prevent the structure of the map from simply being 4 structures
	 * that branch out from the home tile).
	 */
	private function updateNeighborCells(newTile:LayoutCell, x:Int, y:Int):Void {
		// TODO: refactor this, it is redundant and awful
		var neighborX;
		var neighborY;
		var neighbor:LayoutCell = null;
		// Chance to connect new tile to its east neighbor
		if (!(newTile.hasE)) {
			neighborX = x + 1;
			neighborY = y;
			neighbor = _map.get(new Position(neighborX, neighborY).toString());
			// If the neighbor tile exists, connect it with 25% chance.
			if (neighbor != null) {
				if (FlxG.random.bool(25)) {
					newTile.hasE = true;
					neighbor.hasW = true;
				}
			}
		}
		// Chance to connect new tile to its west neighbor
		if (!(newTile.hasW)) {
			neighborX = x - 1;
			neighborY = y;
			neighbor = _map.get(new Position(neighborX, neighborY).toString());
			// If the neighbor tile exists, connect it with 25% chance.
			if (neighbor != null) {
				if (FlxG.random.bool(25)) {
					newTile.hasW = true;
					neighbor.hasE = true;
				}
			}
		}
		// Chance to connect new tile to its south neighbor
		if (!(newTile.hasS)) {
			neighborX = x;
			neighborY = y + 1;
			neighbor = _map.get(new Position(neighborX, neighborY).toString());
			// If the neighbor tile exists, connect it with 25% chance.
			if (neighbor != null) {
				if (FlxG.random.bool(25)) {
					newTile.hasS = true;
					neighbor.hasN = true;
				}
			}
		}
		// Chance to connect new tile to its north neighbor
		if (!(newTile.hasN)) {
			neighborX = x;
			neighborY = y - 1;
			neighbor = _map.get(new Position(neighborX, neighborY).toString());
			// If the neighbor tile exists, connect it with 25% chance.
			if (neighbor != null) {
				if (FlxG.random.bool(25)) {
					newTile.hasN = true;
					neighbor.hasS = true;
				}
			}
		}
	}
		
	private function fillRoomShapesArray():Array<Array<String>> {
		var minX:Int = FlxMath.MAX_VALUE_INT;
		var maxX:Int = FlxMath.MIN_VALUE_INT;
		var minY = FlxMath.MAX_VALUE_INT;
		var maxY:Int = FlxMath.MIN_VALUE_INT;
		
		var keys:Iterator<String> = _map.keys();
		while (keys.hasNext()) {
			var posStr:String = keys.next();
			var pos:Position = Position.asPosition(posStr);
			minX = FlxMath.minInt(minX, pos.x);
			minY = FlxMath.minInt(minY, pos.y);
			maxX = FlxMath.maxInt(maxX, pos.x);
			maxY = FlxMath.maxInt(maxY, pos.y);
			if (!_map.get(posStr).exists) {
				trace("ERROR THIS ROOM DOESNT EXIST!!!!");
			}
			
		}
		trace(_map);
		
		var xAdjust = 0 - minX;
		var yAdjust = 0 - minY;
		_currentRoomCol = xAdjust;
		_currentRoomRow = yAdjust;
		_width = maxX + xAdjust + 1;
		_height = maxY + yAdjust + 1;
		
		trace("Layout size is: " + _width + ", " + _height);
		trace("x adjust: " + xAdjust + ", yAdjust: " + yAdjust);
		trace("max x is: " + maxX + ", max y is: " + maxY);
		var roomShapes = new Array<Array<String>>();
		// Iterate through the layout cells again, this time adding them to arrays
		for (i in 0..._height) {
			roomShapes[i] = new Array<String>();
			for (j in 0..._width) {
				roomShapes[i].push("");
			}
		}
		
		trace(roomShapes);
		keys = _map.keys();
		while (keys.hasNext()) {
			var posStr:String = keys.next();
			var pos:Position = Position.asPosition(posStr);
			var cell:LayoutCell = _map.get(posStr);
			trace("placing: " + (pos.y + yAdjust) + " y and " + (pos.x + xAdjust) + " x...");
			roomShapes[pos.y + yAdjust][pos.x + xAdjust] = cell.getShape(); 
		}
		
		trace("finished shaping layout:");
		for (i in 0..._height) {
			trace(roomShapes[i]);
		}
		return roomShapes;
	}
	
	private function generateRooms(roomShapes:Array<Array<String>>):Array<Array<Room>> {
		// Init the 2d array of rooms to be the proper size.
		var rooms:Array<Array<Room>> = new Array<Array<Room>>();
		for (i in 0..._height) {
			rooms[i] = new Array<Room>();
			for (j in 0..._width) {
				rooms[i].push(null);
			}
		}
		
		// Fill in each spot of the room array
		// with a room of the corresponding shape if a room
		// should exist in that location.
		for (i in 0..._height) {
			for (j in 0..._width) {
				var shape:String = roomShapes[i][j];
				if (shape != "") {
					var distance = FlxMath.absInt(i - _currentRoomRow) +
							FlxMath.absInt(j - _currentRoomCol);
					var roomPath:String = chooseRoomForShape(shape, distance);
					var currRoom:Room = new Room(roomPath, distance);
					rooms[i][j] = currRoom;
				}
			}
		}
		return rooms;
	}
	
	private function chooseRoomForShape(shape:String, distFromHome:Int):String {
		var roomNum = 0;
		if (distFromHome > 0) {
			// TODO: randomly select a number to append to the file path
			// so we can choose a room of the correct shape at random.
			// only do this for the case where the current room is NOT the home room.
			roomNum = FlxG.random.int(0, GameData.roomOptions.get(shape));
		}
		return "assets/data/finalizedLevels/roomf_" + shape + "_" + roomNum + ".oel";
	}
	
	private function distributeEntities():Bool {
		var resourceRooms:Array<Room> = new Array<Room>();
		var powerUpRooms:Array<Room> = new Array<Room>();
		var shopRooms:Array<Room> = new Array<Room>();
		var numResourceSpots = 0;
		// Algorithm for adding the entities to rooms.
		// TODO: this might need tweaking depending on design decisions
		for (i in 0..._height) {
			for (j in 0..._width) {
				var currRoom:Room = _rooms[i][j];
				// Only process non-null rooms.
				if (currRoom != null) {
					numResourceSpots += currRoom.numResources;
					if (currRoom.numResources > 0) {
						resourceRooms.push(currRoom);
					}
					if (currRoom.hasPowerUp) {
						powerUpRooms.push(currRoom);
					}
					if (currRoom.hasShop) {
						shopRooms.push(currRoom);
					}
				}
			}
		}
		trace ("numResourceSpots: " + numResourceSpots);
		trace ("numResourceRooms: " + resourceRooms.length);
		trace ("numPowerUpRooms: " + powerUpRooms.length);
		trace ("numShopRooms: " + shopRooms.length);
		var minSpotsAllowed = GameData.currentLevel.woodReq + GameData.currentLevel.foodReq + GameData.currentLevel.stoneReq;
		minSpotsAllowed = Std.int(minSpotsAllowed * 1.2);
		if (numResourceSpots < minSpotsAllowed ) {
			trace("Needed to repick layout, not enough resource spots");
			return false;
		}
		
		distributeResources(resourceRooms, numResourceSpots);
		distributePowerUps(powerUpRooms);
		distributeShop(shopRooms);
		
		for (i in 0..._height) {
			for (j in 0..._width) {
				var currRoom:Room = _rooms[i][j];
				if (currRoom != null) {
					currRoom.finalizeRoom();
				}
			}
		}
		return true;
	}
	
	private function distributeResources(rooms:Array<Room>, numSpots:Int):Void {
		// Sort the rooms in ascecnding order of distance from
		// home, so the furthest rooms are at the end.
		rooms.sort(function(a, b):Int {
			var dist1:Int = cast(a, Room).distFromHome;
			var dist2:Int = cast(b, Room).distFromHome;
			
			if (dist1 < dist2) {
				return -1;
			} else if (dist2 < dist1) {
				return 1;
			}
			return 0;
		});
		
		// Budget the required resources. Store the number
		// of each needed, and store the original ratio
		// of resources needed for use once we have generated
		// all needed resources and are populating extras.
		var neededRes:Array<Int> = new Array<Int>();
		neededRes.push(GameData.currentLevel.woodReq);
		neededRes.push(GameData.currentLevel.foodReq);
		neededRes.push(GameData.currentLevel.stoneReq);
		var totalNeeded:Int = 0;
		for (i in 0...neededRes.length) {
			totalNeeded += neededRes[i];
		}
		
		var origRatios:Array<Float> = new Array<Float>();
		for (i in 0...neededRes.length) {
			origRatios.push(neededRes[i] / (totalNeeded * 1.0));
		}
		
		//var blankChance:Float = 0.05;
		var blankChance:Float = 0.00;
		trace("Needed resources: " + neededRes);
		trace("Original ratios: " + origRatios);
		while (rooms.length > 0) {
			var currRoom:Room = rooms.pop();
			trace("Current room num resources: " + currRoom.numResources);
			for (i in 0...currRoom.numResources) {
				if (totalNeeded > 0) {
					var chosen:Int = selectResource(neededRes, totalNeeded, numSpots);
					currRoom.addResource(chosen);
					trace("resource chosen: " + chosen);
					if (chosen != -1) {
						neededRes[chosen]--;
						totalNeeded--;
					}
				} else {
					currRoom.addResource(selectExtraResource(origRatios, blankChance));
					//blankChance += 0.05;
				}
				numSpots--;
			}
		}
		
		
	}
	
	private function selectResource(needed:Array<Int>, totalNeeded:Int, numSpots:Int):Int {
		var woodRange:Float = needed[0] / (totalNeeded * 1.0);
		var foodRange:Float = (needed[1] / (totalNeeded * 1.0));
		var numExtraSpots:Float = (1.0) * numSpots - totalNeeded;
		var blankChance:Float = numExtraSpots / (numSpots);
		trace("generating with totalNeeded: " + totalNeeded + ", numSpots: " + numSpots + ", blank chance: " + blankChance);
		return selectExtraResource([woodRange, foodRange], blankChance);
	}
	
	private function selectExtraResource(needed:Array<Float>, blank:Float):Int {
		var choice:Float = FlxG.random.float(0, 1);
		if (choice <= blank) {
			return -1;
		}
		trace ("choice is: " + choice + ", needed array is: " + needed);
		if (choice <= needed[0]) {
			return 0;
		} else if (choice <= needed[0] + needed[1]) {
			return 1;
		} else {
			return 2;
		}
	}
	
	/**
	 * Randomly select one power up room to keep the power up,
	 * remove all others. TODO: this algorithm may change.
	 */
	private function distributePowerUps(rooms:Array<Room>) {
		var chosenIndex:Int = FlxG.random.int(0, rooms.length - 1);
		for (i in 0...rooms.length) {
			if (i != chosenIndex) {
				rooms[i].hasPowerUp = false;
			}
		}
	}
	
	private function distributeShop(rooms:Array<Room>) {
		// TODO: implement this once we are using shops
	}
	
	/**
	 * Generate a special layout for the given level number.
	 * Used for the first few levels which have pre-fabricated layouts.
	 */
	private function generateSpecialRooms(levelNum:Int):Array<Array<Room>> {
		var array:Array<Array<Room>>;
		switch(levelNum) {
			case -1:
				_width = _height = 1;
				_currentRoomRow = _currentRoomCol = 0;
				//Test out a room here:
				array = [[new Room(GameData.roomToTest, 0)]];
				return array;
			case 0:
				_width = _height = 1;
				_currentRoomRow = _currentRoomCol = 0;
				array = [[new Room(AssetPaths.level_0__oel, 0)]];
				return array;
			case 1:
				_width = 1;
				_height = 2;
				_currentRoomRow = _currentRoomCol = 0;
				array = new Array<Array<Room>>();
				array[0] = [new Room(AssetPaths.level_1A__oel, 0)];
				array[1] = [new Room(AssetPaths.level_1B__oel, 1)];
				return array;
			case 2:
				_width = 2;
				_height = 1;
				_currentRoomRow = _currentRoomCol = 0;
				array = new Array<Array<Room>>();
				array[0] = [new Room(AssetPaths.level_2A__oel, 0), new Room(AssetPaths.level_2B__oel, 1)];
				return array;
		}
		return null;
	}
}