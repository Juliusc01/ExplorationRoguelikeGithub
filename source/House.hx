package;

/**
 * ...
 * @author Alex Vrhel
 */
class House extends Feature 
{	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y, Const.HOUSE_WIDTH, Const.HOUSE_HEIGHT, AssetPaths.house__png);
	}
	
	override public function touchBySword():Void {
		GameData.currentPlayState.checkForWin();
	}
	
}
