package;
import flixel.FlxG;
import flixel.math.FlxMath;
import haxe.ds.IntMap;
import js.html.ProcessingInstruction;

/**
 * ...
 * @author Alex Vrhel
 */

typedef PosCandidate = {
	var x:Int;
	var y:Int;
	var fromDir:Direction;
}
	
class Layout 
{
	private var _map:Map<String, LayoutCell>;
	private var _nextRoomPossibilities:Array<PosCandidate>;
	
	// Width and Height of the generated layout
	private var _width:Int;
	private var _height:Int;
	
	// Offset of the home tile within the generated layout
	private var _xAdjust:Int;
	private var _yAdjust:Int;
	private var _roomShapes:Array<Array<String>>;
	
	public function new(rooms:Int) 
	{
		// Generate layout by doing the following:
		// Maintain a map of (x,y) -> LayoutCell
		_map = new Map<String, LayoutCell>();
		_nextRoomPossibilities = new Array<PosCandidate>();
		var roomsLeft:Int = rooms;

		
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
		// At this point, we have made a map with the correct number
		// of rooms. Now, we need to normalize the x/y values so they all end
		// up non-negative and put them into arrays accordingly.
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
		
		_xAdjust = 0 - minX;
		_yAdjust = 0 - minY;
		_width = maxX + _xAdjust + 1;
		_height = maxY + _yAdjust + 1;
		
		trace("Layout size is: " + _width + ", " + _height);
		trace("x adjust: " + _xAdjust + ", yAdjust: " + _yAdjust);
		trace("max x is: " + maxX + ", max y is: " + maxY);
		_roomShapes = new Array<Array<String>>();
		// Iterate through the layout cells again, this time adding them to arrays
		for (i in 0..._height) {
			_roomShapes[i] = new Array<String>();
			for (j in 0..._width) {
				_roomShapes[i].push("");
			}
		}
		
		trace(_roomShapes);
		keys = _map.keys();
		while (keys.hasNext()) {
			var posStr:String = keys.next();
			var pos:Position = Position.asPosition(posStr);
			var cell:LayoutCell = _map.get(posStr);
			trace("placing: " + (pos.y + _yAdjust) + " y and " + (pos.x + _xAdjust) + " x...");
			_roomShapes[pos.y + _yAdjust][pos.x + _xAdjust] = cell.getShape(); 
		}
		
		trace("finished shaping layout:");
		for (i in 0..._height) {
			trace(_roomShapes[i]);
		}
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
	
	private function addLocationToFinalMap(newLocation:PosCandidate):Void {
		// Get the layout cell corresponding to the new tile.
		var nextCell:LayoutCell = getWithoutNull(new Position(newLocation.x, newLocation.y));
		
		// Ensure the newly selected location will exist in the final map.
		nextCell.exists = true;
		
		// Add a path to and from the new tile.
		connectNewTile(nextCell, newLocation);
		
		// Add position candidates of new map locations reachable from newly added tile.
		addPositionsToConsider(nextCell);
		
		updateNeighborCells(newLocation.x, newLocation.y);
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
			trace("cell at: " + cell.x + ", " + cell.y + " was null when adding");
		} else {
			trace("cell at: " + cell.x + ", " + cell.y + " was NOT NULL");
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
	
	private function updateNeighborCells(x:Int, y:Int) {
		//TODO: possibly connect to other cells already on map
	}
}