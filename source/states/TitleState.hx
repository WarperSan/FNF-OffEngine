package states;

import core.interfaces.IScriptable;
import core.states.PrimaryState;
import flixel.FlxG;
import helpers.ResourceHelper;
import objects.titleScreen.GFTitle;
import objects.titleScreen.LogoTitle;

class TitleState extends PrimaryState implements IScriptable
{
	private var gfTitle:GFTitle;
	private var logoTitle:LogoTitle;

	override public function create()
	{
		super.create();

		gfTitle = GFTitle.createNew(512, 40);
		add(gfTitle);

		logoTitle = LogoTitle.createNew(-150, -100);
		add(logoTitle);

		// https://docpiper.com/tests/audio/music/SumertimeBlues.ogg
		ResourceHelper.loadMusicAsync("https://docpiper.com/tests/audio/music/SumertimeBlues.ogg").onComplete((music) ->
		{
			FlxG.sound.playMusic(music, 0, true);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		});
	}

	public override function onBeat()
	{
		gfTitle.onBeat();
		logoTitle.onBeat();
	}
}
