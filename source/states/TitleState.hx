package states;

import core.states.PrimaryState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import helpers.ResourceHelper;
import objects.Metronome.IBeatable;
import objects.titleScreen.GFTitle;

class TitleState extends PrimaryState implements IScriptable
{
	override public function create()
	{
		super.create();

		// var gfTitle:GFTitle = GFTitle.init()

		this.createGF(512, 40);
		this.createLogo(-150, -100);

		// https://docpiper.com/tests/audio/music/SumertimeBlues.ogg
		// ResourceHelper.loadMusicAsync("https://docpiper.com/tests/audio/music/SumertimeBlues.ogg").onComplete((music) ->
		// {
		// 	FlxG.sound.playMusic(music, 0, true);
		// 	FlxG.sound.music.fadeIn(4, 0, 0.7);
		// });
	}

	public override function onBeat()
	{
		gfTitle.onBeat();
		this.logoBeat();
	}

	// #region GF Title
	private var gfTitle:GFTitle;

	private function createGF(x:Float, y:Float):Void
	{
		gfTitle = GFTitle.createNew(x, y);
		add(gfTitle);
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
