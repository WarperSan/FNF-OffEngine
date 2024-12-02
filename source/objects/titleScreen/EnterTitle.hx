package objects.titleScreen;

class EnterTitle extends FlxSprite implements IScriptable
{
	private var IMAGE(default, null) = "titleScreen/titleEnter.png";
	private var XML(default, null) = "titleScreen/titleEnter.xml";

	private var IDLE(default, null) = "idle";
	private var PRESSED(default, null) = "press";

	private var ALPHA_MIN(default, null) = 1.0;
	private var ALPHA_MAX(default, null) = 0.64;

	private var COLOR_MIN(default, null) = 0xFF33FFFF;
	private var COLOR_MAX(default, null) = 0xFF3333CC;

	private var CYCLE_DELAY_SECONDS(default, null) = 2.0;

	private var timer:Float = 0;

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
				this.animation.addByPrefix(IDLE, "ENTER IDLE", 24, true);
				this.animation.addByPrefix(PRESSED, "ENTER PRESSED", 24, true);
				this.animation.play(IDLE, true);
			});
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Increase timer
		timer += elapsed;

		if (timer > CYCLE_DELAY_SECONDS)
			timer -= CYCLE_DELAY_SECONDS;

		updateTitle(timer);
	}

	private function updateTitle(value:Float)
	{
		if (value >= CYCLE_DELAY_SECONDS / 2)
			value = CYCLE_DELAY_SECONDS - value;

		value = value * 2 / CYCLE_DELAY_SECONDS;

		// Ease the value
		value = FlxEase.quadInOut(value);

		// Set alpha
		this.alpha = FlxMath.lerp(ALPHA_MIN, ALPHA_MAX, value);

		// Set value
		this.color = FlxColor.interpolate(COLOR_MIN, COLOR_MAX, value);
	}
}
