package objects.titleScreen;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import objects.Metronome.IBeatable;

class GFTitle extends FlxSprite implements IBeatable implements IScriptable
{
	private static inline var GF_DANCE_TITLE_IMAGE = "titleScreen/gfDanceTitle.png";
	private static inline var GF_DANCE_TITLE_XML = "titleScreen/gfDanceTitle.xml";

	private static inline var GF_DANCE_LEFT:String = "danceLeft";
	private static inline var GF_DANCE_RIGHT:String = "danceRight";

	private var gfDancingLeft:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		var graphicPromise = ResourceHelper.loadGraphicAsync(GF_DANCE_TITLE_IMAGE);

		graphicPromise.onComplete((graphic) ->
		{
			this.loadGraphic(graphic, true);

			var xmlContent = ResourceHelper.loadTextAsync(GF_DANCE_TITLE_XML);
			xmlContent.onComplete((xml) ->
			{
				this.frames = FlxAtlasFrames.fromSparrow(graphic, xml);
				this.animation.addByIndices(GF_DANCE_RIGHT, "gfDance", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				this.animation.addByIndices(GF_DANCE_LEFT, "gfDance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			});
		});
	}

	public function onBeat():Void
	{
		gfDancingLeft = !gfDancingLeft;

		if (gfDancingLeft)
			this.animation.play(GF_DANCE_RIGHT, true);
		else
			this.animation.play(GF_DANCE_LEFT, true);
	}
}
