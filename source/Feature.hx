package;

import flixel.FlxSprite;

/**
 * ...
 * @author Alex Vrhel
 */
class Feature extends FlxSprite 
{	
	public function new(X:Float=0, Y:Float=0, w:Int, h:Int, assetPath:String) {
		super(X, Y);
		loadGraphic(assetPath, false, w, h);
		setSize(w, h);
		centerOffsets();
		set_immovable(true);
	}
	
	// Override this with the behavior of the feature.
	public function touchBySword():Void {
		trace("error, touchBySword not implemented for this feature!");
	}
}