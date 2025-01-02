package extenders;

class AnimationExtender
{
	/** Finds all the frames with the given name */
	private static function findFramesByName(name:String, sprite:FlxSprite)
	{
		var names = [];
		var ereg = new EReg(name + "\\d+", "i");

		for (f in sprite.frames.frames)
		{
			if (ereg.match(f.name))
				names.push(f.name);
		}

		return names;
	}

	/** Adds a new animation to the sprite with all the frames with the given prefix */
	public static function addByFramePrefix(animation:FlxAnimationController, name:String, prefix:String, sprite:FlxSprite, framerate:Int, looped:Bool)
	{
        var frames = findFramesByName(prefix, sprite);
        animation.addByNames(name, frames, framerate, looped);
    }
}
