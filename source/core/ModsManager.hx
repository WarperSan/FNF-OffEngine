package core;

import helpers.LogHelper;
import polymod.Polymod;
import sys.FileSystem;

// Fetch mod page: api.gamebanana.com/Core/List/New?gameid=8694&itemtype=Mod&format=json_min&page=1
// Get fields options: api.gamebanana.com/Core/Item/Data/AllowedFields?itemtype=Mod

class ModsManager
{
	public static var MOD_ROOT(default, null):String;
	public static var ASSET_PREFIX(default, null):String;

	// #region Init
	public static function init(modRoot:String, assetPrefix:String):Void
	{
		LogHelper.verbose("Initializing Polymod...");

		Polymod.init({
			modRoot: modRoot,
			dirs: [],
			errorCallback: onModError,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			framework: Framework.FLIXEL,
			assetPrefix: assetPrefix,
			useScriptedClasses: true
		});

		LogHelper.verbose("Polymod initialized!");

		MOD_ROOT = modRoot;
		ASSET_PREFIX = assetPrefix;
	}

	private static function onModError(error:PolymodError):Void
	{
		var code:String = Std.string(error.code).toUpperCase();

		if (error.severity == PolymodErrorType.NOTICE)
		{
			LogHelper.verbose('($code): ${error.message}');
			return;
		}

		if (error.severity == PolymodErrorType.WARNING)
		{
			LogHelper.warn('($code): ${error.message}');
			return;
		}

		LogHelper.error('($code): ${error.message}');
	}

	// #endregion
	// #region Load Mods

	public static function LoadAllMods():Void
	{
		LogHelper.verbose("Loading all mods...");

		var results = Polymod.loadMods(FileSystem.readDirectory(MOD_ROOT));

		LogHelper.verbose('${results.length} mods loaded!');
	}

	// #endregion
}
