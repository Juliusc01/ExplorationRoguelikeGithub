package;

/**
 * ...
 * @author Alex Vrhel
 */
class Anvil extends Feature 
{
	public var lastSwordSwing:Int;
	public function new(X:Float=0, Y:Float=0) 
	{
		var w = Const.ANVIL_WIDTH;
		var h = Const.ANVIL_HEIGHT;
		super(X, Y, w, h, AssetPaths.anvil__png);
		lastSwordSwing = -1;
	}
	
	override public function touchBySword():Void {
		trace("touched anvil!");
		trace("last swing, this swing: " + lastSwordSwing + ", " + GameData.currentPlayState.player.swingNumber);
		var thisSwordSwingNum = GameData.currentPlayState.player.swingNumber;
		if (thisSwordSwingNum > lastSwordSwing) {
			lastSwordSwing = thisSwordSwingNum;
			trace("about to show it");
			GameData.currentPlayState.showCraftingMenu();
		} else {
			trace("nope!");
		}
	}
}