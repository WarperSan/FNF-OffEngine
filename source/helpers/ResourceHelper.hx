package helpers;

import haxe.Json;
import core.ModsManager;
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
	private static function findFile(file:String, type:AssetType):String
	{
		// If web resource, skip
		if (StringTools.startsWith(file, "http"))
			return file;

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
		file = Path.join([core.ModsManager.ASSET_PREFIX, folder, file]);

		return ModsManager.getFilePath(file);
	}

	// #region Synchronous

	/** Creates a new object from a file path synchronously. This means that the object will be returned immediately. */
	private static function fromFile(file:String, type:AssetType):Dynamic
	{
		file = findFile(file, type);

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

	/** Loads the given font synchronously */
	public static function loadFont(file:String):Font
	{
		return cast fromFile(file, FONT);
	}

	/** Loads the given music synchronously */
	public static function loadMusic(file:String):Sound
	{
		return cast fromFile(file, MUSIC);
	}

	/** Loads the given sound synchronously */
	public static function loadSound(file:String):Sound
	{
		return cast fromFile(file, SOUND);
	}

	/** Loads the given image synchronously */
	public static function loadImage(file:String):BitmapData
	{
		return cast fromFile(file, IMAGE);
	}

	/** Loads the given graphic synchronously */
	public static function loadGraphic(file:String):FlxGraphic
	{
		var data:BitmapData = loadImage(file);
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(data, false, file);
		return graphic;
	}

	/** Loads the given text synchronously */
	public static function loadText(file:String):String
	{
		return cast fromFile(file, TEXT);
	}

	/** Loads the given JSON synchronously */
	public static function loadJson<T>(file:String):T
	{
		var text = loadText(file);
		return cast Json.parse(text);
	}

	// #endregion
	// #region Asynchronous

	/** Creates a new object from a file path or web address asynchronously. The file load will occur in the background. */
	private static function loadFromFile(file:String, type:AssetType):Future<Dynamic>
	{
		// If web resource
		if (StringTools.startsWith(file, "http"))
		{
			// If not allowed, skip
			#if !ALLOW_WEB_RESOURCES
			LogHelper.error('Tried to load \'$file\', but web requests for resources are disabled.');
			return Future.withError(null);
			#end
		}

		file = findFile(file, type);

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

		resource.onError((e) ->
		{
			LogHelper.error('Error while loading \'$file\': $e');
		});

		return resource;
	}

	/** Loads the given font asynchronously */
	public static function loadFontAsync(file:String):Future<Font>
	{
		return cast loadFromFile(file, FONT);
	}

	/** Loads the given music asynchronously */
	public static function loadMusicAsync(file:String):Future<Sound>
	{
		return cast loadFromFile(file, MUSIC);
	}

	/** Loads the given sound asynchronously */
	public static function loadSoundAsync(file:String):Future<Sound>
	{
		return cast loadFromFile(file, SOUND);
	}

	/** Loads the given image asynchronously */
	public static function loadImageAsync(file:String):Future<BitmapData>
	{
		return cast loadFromFile(file, IMAGE);
	}

	/** Loads the given graphic asynchronously */
	public static function loadGraphicAsync(file:String):Future<FlxGraphic>
	{
		var promise:Future<BitmapData> = loadImageAsync(file);

		return promise.then((data) ->
		{
			var promise:Promise<FlxGraphic> = new Promise<FlxGraphic>();

			var graphic:FlxGraphic = FlxGraphic.fromBitmapData(data, false, file);
			promise.complete(graphic);
			return promise.future;
		});
	}

	/** Loads the given text asynchronously */
	public static function loadTextAsync(file:String):Future<String>
	{
		return cast loadFromFile(file, TEXT);
	}

	/** Loads the given JSON asynchronously */
	public static function loadJsonAsync<T>(file:String):Future<T>
	{
		var promise = loadTextAsync(file);

		return promise.then((text) ->
		{
			var promise:Promise<T> = new Promise<T>();

			var obj:T = cast Json.parse(text);

			promise.complete(obj);
			return promise.future;
		});
	}

	// #endregion
}
