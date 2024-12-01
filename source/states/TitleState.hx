package states;

import core.states.PrimaryState;
import core.states.PrimaryState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import helpers.ResourceHelper;

class TitleState extends PrimaryState
{
	override public function create()
	{
		super.create();

		this.createGF(512, 40);
		this.createLogo(-150, -100);

		// https://docpiper.com/tests/audio/music/SumertimeBlues.ogg
		ResourceHelper.loadMusicAsync("https://docpiper.com/tests/audio/music/SumertimeBlues.ogg").onComplete((music) ->
		{
			FlxG.sound.playMusic(music, 0, true);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		});
	}

	public override function onBeat()
	{
		this.gfBeat();
		this.logoBeat();
	}

	// #region GF Title
	private static inline var GF_DANCE_TITLE_IMAGE = "titleScreen/gfDanceTitle.png";
	private static inline var GF_DANCE_TITLE_XML = "titleScreen/gfDanceTitle.xml";

	private static inline var GF_DANCE_LEFT:String = "danceLeft";
	private static inline var GF_DANCE_RIGHT:String = "danceRight";

	private var gfTitle:FlxSprite;
	private var gfDancingLeft:Bool = false;

	private function createGF(x:Float, y:Float):Void
	{
		gfTitle = new FlxSprite(x, y);
		add(gfTitle);

		var graphicPromise = ResourceHelper.loadGraphicAsync(GF_DANCE_TITLE_IMAGE);

		graphicPromise.onComplete((graphic) ->
		{
			gfTitle.loadGraphic(graphic, true);

			var xmlContent = ResourceHelper.loadTextAsync(GF_DANCE_TITLE_XML);
			xmlContent.onComplete((xml) ->
			{
				gfTitle.frames = FlxAtlasFrames.fromSparrow(graphic, xml);
				gfTitle.animation.addByIndices(GF_DANCE_RIGHT, "gfDance", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gfTitle.animation.addByIndices(GF_DANCE_LEFT, "gfDance", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			});
		});
	}

	private function gfBeat():Void
	{
		gfDancingLeft = !gfDancingLeft;

		if (gfDancingLeft)
			gfTitle.animation.play(GF_DANCE_RIGHT, true);
		else
			gfTitle.animation.play(GF_DANCE_LEFT, true);
	}

	// #endregion
	// #region Logo Title
	private static inline var LOGO_BUMP:String = "bump";

	private var logoTitle:FlxSprite;

	private function createLogo(x:Float, y:Float):Void
	{
		logoTitle = new FlxSprite(x, y);
		add(logoTitle);

		var graphicPromise = ResourceHelper.loadGraphicAsync("titleScreen/logoBumpin.png");

		graphicPromise.onComplete((graphic) ->
		{
			logoTitle.loadGraphic(graphic, true);

			var xmlContent = ResourceHelper.loadTextAsync("titleScreen/logoBumpin.xml");
			xmlContent.onComplete((xml) ->
			{
				logoTitle.frames = FlxAtlasFrames.fromSparrow(graphic, xml);
				logoTitle.animation.addByPrefix(LOGO_BUMP, "logo bumpin", 24, false);
			});
		});
	}

	private function logoBeat():Void
	{
		logoTitle.animation.play(LOGO_BUMP, true);
	}

	// #endregion
}
