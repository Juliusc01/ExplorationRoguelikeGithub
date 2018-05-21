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
	public static var HOUSE_X_WITH_ANVIL(default, never):Int = Std.int((GAME_WIDTH - HOUSE_WIDTH) / 2 - (TILE_WIDTH * 1.5));
	public static var HOUSE_X_NO_ANVIL(default, never):Int = Std.int((GAME_WIDTH - HOUSE_WIDTH) / 2);
	public static var HOUSE_Y(default, never):Int = Std.int((GAME_HEIGHT - HOUSE_HEIGHT) / 2);
	
	public static var ANVIL_WIDTH(default, never):Int = 32;
	public static var ANVIL_HEIGHT(default, never):Int = 17;
	public static var ANVIL_X(default, never):Int = HOUSE_X_WITH_ANVIL + HOUSE_WIDTH + 16;
	public static var ANVIL_Y(default, never):Int = HOUSE_Y + HOUSE_HEIGHT - ANVIL_HEIGHT;
	
	public static var DOOR_X_WITH_ANVIL(default, never):Float = HOUSE_X_WITH_ANVIL + (HOUSE_WIDTH / 2) + 5;
	public static var DOOR_X_NO_ANVIL(default, never):Float = HOUSE_X_NO_ANVIL + (HOUSE_WIDTH / 2) + 5;
	public static var DOOR_Y(default, never):Float = HOUSE_Y + HOUSE_HEIGHT + (TILE_HEIGHT / 2);

	public static var FIRST_HP_LVL(default, never):Int = 1;
	public static var LAST_INSTRUCTION_LVL(default, never):Int = 1;
	
	public static var CRAFT_COSTS(default, never):Array<Array<Array<Int>>> = 
			[[[2, 2], [4, 2], [6, 3], [9, 3]],
			[[2, 1], [4, 1], [6, 2], [9, 2]],
			[[2, 1], [4, 1], [6, 2], [9, 2]]];
			
	public static var CRAFT_DMG_UP(default, never):Int = 5;
	public static var CRAFT_HP_UP(default, never):Int = 50;
	public static var CRAFT_SPEED_UP(default, never):Int = 12;

}