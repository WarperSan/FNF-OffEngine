package;

import core.ModsManager;
import core.scripted.ScriptedPrimaryState;
import core.scripted.ScriptedTitleState.ScriptedTilteState;
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

		ModsManager.LoadAllMods();

		var stageClassNames:Array<String> = ScriptedTilteState.listScriptClasses();
		trace("Loaded primary states: " + stageClassNames);

		var state:PrimaryState = ScriptedTilteState.init(stageClassNames[0]);

		addChild(new FlxGame(0, 0, () -> state));

		FlxG.updateFramerate = 250;
		FlxG.drawFramerate = 250;
	}
}
