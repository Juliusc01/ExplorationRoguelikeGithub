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
	
	public function new(X:Float=0, Y:Float=0, powerUpID:String, name:String, effect:String, imagePath:String) 
	{
		super(X, Y);
		this.powerUpID = powerUpID;
		this.name = name;
		this.effect = effect;
		this.imagePath = imagePath;
		this.isActive = false;
		
		var w:Int = Constants.TILE_WIDTH;
		var h:Int = Constants.TILE_HEIGHT;
		
		loadGraphic("assets/images/" + imagePath, false, w, h);
		setSize(w, h);
		trace("item size is: " + width + ", " + height);

	}
	
}
