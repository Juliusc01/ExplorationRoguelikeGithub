package;

/**
 * Global Constants which may be useful.
 * @author Alex Vrhel
 */
class Const 
{
	public static var TILE_WIDTH(default, never):Int = 16;
	public static var TILE_HEIGHT(default, never):Int = 16;
	public static var GAME_WIDTH(default, never):Int = 352;
	public static var GAME_HEIGHT(default, never):Int = 320;
	public static var HOUSE_WIDTH(default, never):Int = TILE_WIDTH * 3;
	public static var HOUSE_HEIGHT(default, never):Int = TILE_HEIGHT * 3;
	public static var HOUSE_X(default, never):Int = Std.int((GAME_WIDTH - HOUSE_WIDTH) / 2);
	public static var HOUSE_Y(default, never):Int = Std.int((GAME_HEIGHT - HOUSE_HEIGHT) /2);
	
	public static var FIRST_HP_LVL(default, never):Int = 2;
	public static var FIRST_FOOD_LVL(default, never):Int = 4;
	public static var FIRST_GOLD_LVL(default, never):Int = 6;
	public static var FIRST_STONE_LVL(default, never):Int = 8;
}