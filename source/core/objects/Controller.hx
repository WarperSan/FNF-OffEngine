package core.objects;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.FlxBasic;

class Controller extends FlxBasic
{
	public var up(get, never):Bool;
	public var just_up(get, never):Bool;
	public var down(get, never):Bool;
	public var just_down(get, never):Bool;
	public var left(get, never):Bool;
	public var just_left(get, never):Bool;
	public var right(get, never):Bool;
	public var just_right(get, never):Bool;

	public var r(get, never):Bool;

	inline function get_r()
		return wasKeyJustPressed(FlxKey.R);

	// #region Getters

	inline function get_up()
		return isKeyPressed(FlxKey.UP);

	inline function get_just_up()
		return wasKeyJustPressed(FlxKey.UP);

	inline function get_down()
		return isKeyPressed(FlxKey.DOWN);

	inline function get_just_down()
		return wasKeyJustPressed(FlxKey.DOWN);

	inline function get_left()
		return isKeyPressed(FlxKey.LEFT);

	inline function get_just_left()
		return wasKeyJustPressed(FlxKey.LEFT);

	inline function get_right()
		return isKeyPressed(FlxKey.RIGHT);

	inline function get_just_right()
		return wasKeyJustPressed(FlxKey.RIGHT);

	// #endregion

	// #region Utils

	/** Checks if the given key is pressed */
	private inline function isKeyPressed(key:FlxKey)
		return FlxG.keys.checkStatus(key, FlxInputState.PRESSED);

	/** Checks if the given key was just pressed */
	private inline function wasKeyJustPressed(key:FlxKey)
		return FlxG.keys.checkStatus(key, FlxInputState.JUST_PRESSED);

	/** Checks if the given key is released */
	private inline function isKeyReleased(key:FlxKey)
		return FlxG.keys.checkStatus(key, FlxInputState.RELEASED);

	/** Checks if the given key was just released */
	private inline function wasKeyJustReleased(key:FlxKey)
		return FlxG.keys.checkStatus(key, FlxInputState.JUST_RELEASED);

	// #endregion
}
