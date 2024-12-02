package states;

import core.states.PrimaryState;
import objects.titleScreen.EnterTitle;
import objects.titleScreen.GFTitle;
import objects.titleScreen.LogoTitle;

typedef TitleData =
{
	var titleX:Float;
	var titleY:Float;

	var enterX:Float;
	var enterY:Float;
	
	var gfX:Float;
	var gfY:Float;
	
	var bpm:UInt;
};

class TitleState extends PrimaryState implements IScriptable
{
	private var titleData:TitleData;

	private var gfTitle:GFTitle;
	private var logoTitle:LogoTitle;
	private var enterTitle:EnterTitle;

	public function new()
	{
		titleData = ResourceHelper.loadJson("titleScreen.json");

		super(titleData.bpm);
	}

	override public function create()
	{
		super.create();

		gfTitle = GFTitle.createNew(titleData.gfX, titleData.gfY);
		add(gfTitle);

		logoTitle = LogoTitle.createNew(titleData.titleX, titleData.titleY);
		add(logoTitle);

		enterTitle = EnterTitle.createNew(titleData.enterX, titleData.enterY);
		add(enterTitle);

		// https://docpiper.com/tests/audio/music/SumertimeBlues.ogg
		ResourceHelper.loadMusicAsync("https://docpiper.com/tests/audio/music/SumertimeBlues.ogg").onComplete((music) ->
		{
			FlxG.sound.playMusic(music, 0, true);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		});
	}
}
