package helpers;

import flixel.graphics.FlxGraphic;
import haxe.ds.StringMap;
import haxe.io.Path;
import lime.app.Promise;
import lime.tools.AssetType;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.Future;
import sys.io.File;

class ResourceHelper
{
	private static function loadAsync(file:String, type:AssetType):Future<Dynamic>
	{
		LogHelper.verbose('Loading asynchronously the resource of type \'$type\' at \'$file\'.');

		var future:Future<Dynamic> = null;
		var isWebResource = StringTools.startsWith(file, "http");

		// If web resource
		if (isWebResource)
			future = loadWebAsync(file, type);
		else
			future = loadLocalAsync(file, type);

		// Add listeners
		future.onError(e ->
		{
			if (e == null)
				e = "Resource Not Found";

			LogHelper.error('Error while loading \'$file\': $e');
		});

		return future;
	}

	private static function loadFromFile(file:String, type:AssetType):Future<Dynamic>
	{
		// If web resource
		if (StringTools.startsWith(file, "http"))
		{
			// If not allowed, skip
			#if !ENABLE_WEB_RESOURCES
			LogHelper.error('Tried to load \'$file\', but web requests for resources are disabled.');
			return Future.withError(null);
			#end
		}

		var resource:Future<Dynamic> = null;

		switch (type)
		{
			case FONT:
				resource = Font.loadFromFile(file);
			case MUSIC, SOUND:
				resource = Sound.loadFromFile(file);
			case IMAGE:
				resource = BitmapData.loadFromFile(file);
			case TEXT:
				var request = new lime.net.HTTPRequest<String>();
				resource = request.load(file).then(function(text)
				{
					var extension = Path.extension(file);

					// Parse JSON
					if (extension == "json")
						return Future.withValue(haxe.Json.parse(file));

					// Just return the string
					return Future.withValue(text);
				});
			default:
				LogHelper.error('Tried to load \'$file\', but the type \'$type\' is not supported.');
				resource = Future.withError(null);
		}

		return resource;
	}

	private static function fromFile(file:String, type:AssetType):Dynamic
	{
		var resource:Dynamic = null;

		switch (type)
		{
			case FONT:
				resource = Font.fromFile(file);
			case MUSIC, SOUND:
				resource = Sound.fromFile(file);
			case IMAGE:
				resource = BitmapData.fromFile(file);
			case TEXT:
				resource = File.getContent(file);
			default:
				LogHelper.error('Tried to load \'$file\', but the type \'$type\' is not supported.');
				return null;
		}

		if (resource == null)
		{
			LogHelper.error('Failed to load \'${file}\'.');
			return null;
		}

		return resource;
	}

	// #region Loadings

	/** Loads the file at the given URL asynchronously */
	private static function loadWebAsync(file:String, type:AssetType):Future<Dynamic>
	{
		#if !ALLOW_WEB_RESOURCES
		LogHelper.error('Tried to load \'$file\', but web resources are not allowed.');
		return Future.withError(null);
		#end
		return loadFileAsync(file, type);
	}

	/** Loads the file at the given ID asynchronously */
	private static function loadLocalAsync(file:String, type:AssetType):Future<Dynamic>
	{
		// Fetch folder
		var folder:String;

		switch (type)
		{
			case FONT:
				folder = "fonts";
			case MUSIC:
				folder = "music";
			case SOUND:
				folder = "sounds";
			case IMAGE:
				folder = "images";
			case TEXT:
				folder = Path.extension(file);
			default:
				folder = "";
		}

		// Build path
		var path = Path.join([core.ModsManager.ASSET_PREFIX, folder, file]);

		/* MANAGE ASSET TOGGLE HERE */

		return loadFileAsync(polymod.backends.PolymodAssets.getPath(path), type);
	}

	private static function loadFileAsync(file:String, type:AssetType):Future<Dynamic>
	{
		switch (type)
		{
			case FONT:
				return Font.loadFromFile(file);
			case MUSIC, SOUND:
				return Sound.loadFromFile(file);
			case IMAGE:
				return BitmapData.loadFromFile(file);
			case TEXT:
				var request = new lime.net.HTTPRequest<String>();
				return request.load(file).then(function(text)
				{
					var extension = Path.extension(file);

					// Parse JSON
					if (extension == "json")
						return Future.withValue(haxe.Json.parse(file));

					// Just return the string
					return Future.withValue(text);
				});
			default:
				LogHelper.error('Tried to load \'$file\', but the type \'$type\' is not supported.');
				return Future.withError(null);
		}
	}

	// #endregion
	// #region Load Assets

	/** Loads the given font asynchronously */
	public static function loadFontAsync(file:String):Future<Font>
	{
		var promise:Future<openfl.text.Font> = cast loadAsync(file, FONT);
		return promise;
	}

	/** Loads the given music asynchronously */
	public static function loadMusicAsync(file:String):Future<Sound>
	{
		var promise:Future<Sound> = cast loadAsync(file, MUSIC);
		return promise;
	}

	/** Loads the given sound asynchronously */
	public static function loadSoundAsync(file:String):Future<Sound>
	{
		var promise:Future<Sound> = cast loadAsync(file, SOUND);
		return promise;
	}

	/** Loads the given image asynchronously */
	public static function loadImageAsync(file:String):Future<BitmapData>
	{
		var promise:Future<BitmapData> = cast loadAsync(file, IMAGE);
		return promise;
	}

	/** Loads the given graphic asynchronously */
	public static function loadGraphicAsync(file:String):Future<FlxGraphic>
	{
		var promise:Future<BitmapData> = loadImageAsync(file);

		return promise.then((bmd) ->
		{
			var promise:Promise<FlxGraphic> = new Promise<FlxGraphic>();

			var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bmd, false, file);
			promise.complete(graphic);
			return promise.future;
		});
	}

	/** Loads the given text asynchronously */
	public static function loadTextAsync(file:String):Future<String>
	{
		var promise:Future<String> = cast loadAsync(file, TEXT);
		return promise;
	}

	// #endregion
}
