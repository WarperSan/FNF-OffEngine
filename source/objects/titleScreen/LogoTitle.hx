package objects.titleScreen;

class LogoTitle extends FlxSprite implements IBeatable implements IScriptable
{
	private var IMAGE(default, null) = "titleScreen/logoBumpin.png";
	private var XML(default, null) = "titleScreen/logoBumpin.xml";

	private var BUMP(default, null) = "bump";

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
				this.animation.addByPrefix(BUMP, "logo bumpin", 24, false);
			});
		});
	}

	public function onBeat()
	{
		this.animation.play(BUMP, true);
	}
}
