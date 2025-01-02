package;

import core.ModsManager;
import flixel.FlxG;
import flixel.FlxGame;
import helpers.LogHelper;
import openfl.display.Sprite;

// https://github.com/larsiusprime/polymod/blob/master/samples/openfl_hscript_class/src/Demo.hx
class Main extends Sprite
{
	public function new()
	{
		super();

		haxe.Log.trace = function(value:Dynamic, ?infos:Null<haxe.PosInfos>)
		{
			LogHelper.info(value);
		};

		ModsManager.init("mods", "assets/");
		ModsManager.loadAllMods();

		//var state:TitleState = TitleState.createNew();

		//addChild(new FlxGame(0, 0, () -> state));
		addChild(new FlxGame(0, 0, states.TestState));

		FlxG.mouse.visible = false;
		FlxG.updateFramerate = 240;
		FlxG.drawFramerate = 240;
	}
}
