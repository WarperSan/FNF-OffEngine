package core.objects;

import json2object.writer.DataBuilder;
import flixel.graphics.FlxGraphic;
import haxe.ds.StringMap;
import haxe.io.Path;

using extenders.AnnonymousExtender;
using extenders.AnimationExtender;

enum NoteDirection
{
	NONE;
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

typedef NoteData =
{
	var image:String;
	var xml:String;
	var scaleFactor:Float;
	var animations:Dynamic;
}

/** Data used to load a skin on a note */
typedef NoteSkin =
{
	var data:NoteData;
	var graphic:FlxGraphic;
	var frames:Null<FlxAtlasFrames>;
}

class Note extends FlxSprite
{

	public var direction(default, set):NoteDirection = NONE;

	function set_direction(value:NoteDirection)
	{
		if (direction == value)
			return value;

		direction = value;

		// Reload animations
		loadAnimations();

		return value;
	}

	// override function update(elapsed:Float)
	// {
	// 	if (resetAnim > 0)
	// 	{
	// 		resetAnim -= elapsed;
	// 		if (resetAnim <= 0)
	// 		{
	// 			playAnim('static');
	// 			resetAnim = 0;
	// 		}
	// 	}
	// 	super.update(elapsed);
	// }
	// #region Skin

	private var noteData:NoteData;

	/** Loads the given skin on this note */
	public function loadSkin(skin:NoteSkin)
	{
		noteData = skin.data;

		// Graphic
		loadGraphic(skin.graphic);
		antialiasing = true;

		// Animation
		this.frames = skin.frames;
		isAnimated = this.frames != null;

		// Size
		setGraphicSize(Std.int(width * skin.data.scaleFactor));
		updateHitbox();

		// Reload animations
		loadAnimations();
	}

	/** Creates a note skin from the given file */
	public static function createSkin(skinFile:String):NoteSkin
	{
		// Load data
		var data = loadNoteData(skinFile);

		// Visual
		var dir = Path.directory(skinFile);
		var imageFile = Path.join([dir, data.image]);

		var graphic = ResourceHelper.loadGraphic(imageFile, true);

		// Animation
		var frames;
		var isAnimated = data.animations != null && Reflect.fields(data.animations).length > 0;

		if (isAnimated)
		{
			var xmlFile = Path.join([dir, data.xml]);
			var xml = ResourceHelper.loadText(xmlFile, true);
			frames = FlxAtlasFrames.fromSparrow(graphic, xml);
		}
		else
			frames = null;

		// Return results
		return {
			data: data,
			graphic: graphic,
			frames: frames
		};
	}

	/** Loads the note data at the given file */
	private static function loadNoteData(file:String):NoteData
	{
		var parsed:NoteData = ResourceHelper.loadJson(file, true);

		var data = {};

		// Default values
		data.setDefault(parsed, "image", "notes.png");
		data.setDefault(parsed, "xml", "notes.xml");
		data.setDefault(parsed, "scaleFactor", 0.7);

		Reflect.setField(data, "animations", Reflect.field(parsed, "animations"));

		return cast data;
	}

	// #endregion
	// #region Animations
	private static final IDLE = "idle";
	private static final PRESS = "press";
	private static final CONFIRM = "confirm";

	private var isAnimated:Bool;

	public var animationResetTime:Float;

	private var lastAnimation:Null<String>;

	public inline function playIdle()
		playAnimation(IDLE, false);

	public inline function playPressed()
		playAnimation(PRESS, false);

	public inline function playConfirm()
		playAnimation(CONFIRM, false);

	/** Plays the given animation */
	private function playAnimation(name:String, forced:Bool)
	{
		animation.play(name, forced);

		lastAnimation = name;

		// If animation didn't load, skip
		if (animation.curAnim == null)
			return;

		// Fix sprite
		centerOffsets();
		centerOrigin();
	}

	/** Loads the animations for this note */
	private function loadAnimations()
	{
		// If not animated, skip
		if (!isAnimated)
			return;

		if (direction == NONE)
			return;

		// Clear all animations
		animation.destroyAnimations();

		var dirPrefix = getDirectionPrefix(direction);

		var animations = Reflect.field(noteData.animations, dirPrefix);

		animation.addByFramePrefix(IDLE, Reflect.field(animations, IDLE), this, 24, true);
		animation.addByFramePrefix(PRESS, Reflect.field(animations, PRESS), this, 24, false);
		animation.addByFramePrefix(CONFIRM, Reflect.field(animations, CONFIRM), this, 24, false);

		// Play last animation
		if (lastAnimation != null)
			playAnimation(lastAnimation, true);
	}

	/** Finds the prefix of the given direction */
	private static function getDirectionPrefix(direction:NoteDirection)
	{
		var dirPrefix = "";

		switch (direction)
		{
			case NoteDirection.UP:
				dirPrefix = "up";
			case NoteDirection.DOWN:
				dirPrefix = "down";
			case NoteDirection.LEFT:
				dirPrefix = "left";
			case NoteDirection.RIGHT:
				dirPrefix = "right";
			default:
				dirPrefix = "none";
		}

		return dirPrefix;
	}

	// #endregion
}
