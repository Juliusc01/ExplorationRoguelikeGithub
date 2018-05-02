package;

import flixel.FlxSprite;

/**
 * ...
 * @author Julius Christenson
 */
class PowerUp extends FlxSprite 
{
	public var powerUpID:String;
	public var name:String;
	public var effect:String;
	public var imagePath:String;
	public var isActive:Bool;
	
	public function new(powerUpID:String, name:String, effect:String, imagePath:String) 
	{
		super(0, 0);
		this.powerUpID = powerUpID;
		this.name = name;
		this.effect = effect;
		this.imagePath = "assets/images/items/" + imagePath;
		this.isActive = false;
		
		var w:Int = Const.TILE_WIDTH;
		var h:Int = Const.TILE_HEIGHT;
		
		loadGraphic(this.imagePath, false, w, h);
		setSize(w, h);
		trace("item size is: " + width + ", " + height);

	}
	
	public function changeXY(X:Float, Y:Float) {
		trace("changing x and y to be " + X + Y);
		this.x = X;
		this.y = Y;
	}
	
}
