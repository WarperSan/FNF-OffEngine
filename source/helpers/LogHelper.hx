package helpers;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;

/** Handles logging given values */
class LogHelper
{
	private static var VERBOSE:LogStyle = new LogStyle("[VERBOSE] ", "AAAAAA");

	/**
	 * Logs the given value with the given level
	 * @param value Value to log
	 * @param level Level to log at
	 */
	private static function log(value:Dynamic, level:LogStyle):Void
	{
		// If logging not allowed, skip
		#if !ENABLE_LOGGING
		return;
		#end

		// If verbose not allowed, skip
		#if !LOG_VERBOSE
		if (level == VERBOSE)
			return;
		#end

		value = Std.string(value);

		// If not a verbose, output
		if (level != VERBOSE && FlxG.game != null && FlxG.game.debugger != null)
			FlxG.log.advanced(value, level);

		var message:String = buildMessage(value, level);

		Sys.println(message);
	}

	private static function buildMessage(value:Dynamic, level:LogStyle):String
	{
		// Colors
		var preColor = "";
		var postColor = "";

		// Extra text
		var prefix = "";
		var postfix = "";

		// Build string depending on level
		if (level == VERBOSE)
		{
			prefix = "[VERBOSE]";
			postColor = preColor = "\u001b[1;32m";
		}
		else if (level == LogStyle.NOTICE)
		{
			prefix = "[INFO]";
			postColor = preColor = "\u001b[1;36m";
		}
		else if (level == LogStyle.WARNING)
		{
			prefix = "[WARN]";
			postColor = preColor = "\u001b[1;33m";
		}
		else if (level == LogStyle.ERROR)
		{
			prefix = "[ERROR]";
			postColor = preColor = "\u001b[1;31m";
		}

		var message = "";

		#if COLORED_LOG
		message += preColor;
		#end

		message += prefix;

		#if COLORED_LOG
		message += postColor;
		#end

		message += ' $value';

		#if TIMED_LOG
		var now = Date.now();
		var hours = StringTools.lpad(Std.string(now.getHours()), "0", 2);
		var minutes = StringTools.lpad(Std.string(now.getMinutes()), "0", 2);
		var seconds = StringTools.lpad(Std.string(now.getSeconds()), "0", 2);
		var milliseconds = StringTools.lpad(Std.string(Math.floor(now.getTime() % 1000)), "0", 3);

		message += ' ($hours:$minutes:$seconds.$milliseconds)';
		#end

		#if COLORED_LOG
		// Color reset
		message += "\u001b[0m";
		#end

		return message;
	}

	// #region Logging

	/** Logs detailed debugging info for development */
	public static function verbose(value:Dynamic):Void
	{
		log(value, VERBOSE);
	}

	/** Logs info that could be useful for the user */
	public static function info(value:Dynamic):Void
	{
		log(value, LogStyle.NOTICE);
	}

	/** Logs potential issues that aren't critical */
	public static function warn(value:Dynamic):Void
	{
		log(value, LogStyle.WARNING);
	}

	/** Logs errors that impact functionality */
	public static function error(value:Dynamic):Void
	{
		log(value, LogStyle.ERROR);
	}

	// #endregion
}
