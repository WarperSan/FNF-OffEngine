package objects.titleScreen;

class GFTitle extends FlxSprite implements IBeatable implements IScriptable
{
	private var IMAGE(default, null) = "titleScreen/gfDanceTitle.png";
	private var XML(default, null) = "titleScreen/gfDanceTitle.xml";

	private var DANCE_LEFT(default, null) = "danceLeft";
	private var DANCE_RIGHT(default, null) = "danceRight";

	private var gfDancingLeft:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		var graphicPromise = ResourceHelper.loadGraphicAsync(IMAGE);

		graphicPromise.onComplete((graphic) ->
		{
			this.loadGraphic(graphic, true);

			var xmlPromise = ResourceHelper.loadTextAsync(XML);
			xmlPromise.onComplete((xml) ->
			{
				this.frames = FlxAtlasFrames.fromSparrow(graphic, xml);
				this.animation.addByIndices(DANCE_RIGHT, "gfDance", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				this.animation.addByIndices(DANCE_LEFT, "gfDance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			});
		});
	}

	public function onBeat():Void
	{
		gfDancingLeft = !gfDancingLeft;

		if (gfDancingLeft)
			this.animation.play(DANCE_RIGHT, true);
		else
			this.animation.play(DANCE_LEFT, true);
	}
}
