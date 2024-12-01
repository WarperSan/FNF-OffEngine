package objects;

import flixel.FlxSprite;
import flixel.util.FlxSignal;

/** Event that holds information about a BPM change */
typedef BPMChangeEvent =
{
	var bpm:UInt;
	var semiquaver:Float; // Not needed because can be calculated

	var songTime:Float;
	var stepTime:Float;
};

/** Defines objects that can respond to the beat of a metronome */
interface IBeatable
{
	function onBeat():Void;
}

/** Object that tracks time based on a given BPM */
class Metronome extends FlxSprite
{
	public function new(bpm:UInt = 100, updateSelf:Bool = true)
	{
		super();
		this.visible = false;

		this.BPM = bpm;
		this.updateSelf = updateSelf;
		beatSignal = new FlxSignal();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// If not update self, skip
		if (!updateSelf)
			return;

		SONG_POSITION += elapsed * 1000;
		updateCrotchet(SONG_POSITION);
	}

	// #region Properties

	/** Current beats per minute */
	public var BPM(default, set):UInt;

	/** A quarter of the length of a measure (in milliseconds) */
	public var CROTCHET_MS(default, null):Float;

	/** A sixteenth of the length of a measure (in milliseconds) */
	public var SEMIQUAVER_MS(default, null):Float;

	function set_BPM(value:UInt):UInt
	{
		// Prevent division by 0
		if (value == 0)
			value = 1;

		this.CROTCHET_MS = 60.0 / value * 1000;
		this.SEMIQUAVER_MS = this.CROTCHET_MS / 4;

		return this.BPM = value;
	}

	public var SONG_POSITION(default, set):Float;

	private function set_SONG_POSITION(value:Float):Float
	{
		return this.SONG_POSITION = Math.max(value, 0);
	}

	// #endregion
	// #region IBeatable
	private var beatSignal:FlxSignal;
	private var updateSelf:Bool;
	private var currentCrotchet:Float = 0.0;

	public function addListener(beatable:IBeatable):Void
	{
		beatSignal.add(() -> beatable.onBeat());
	}

	public function removeListener(beatable:IBeatable):Void
	{
		beatSignal.remove(() -> beatable.onBeat());
	}

	/**
	 * Updates the internal state to check for a new beat
	 * @return This call caused a new beat
	 */
	public function updateCrotchet(songPosition:Float):Bool
	{
		var oldCrotchet:Float = this.currentCrotchet;

		// Update crotchet
		var event:BPMChangeEvent = this.getChangeEvent(songPosition);
		this.currentCrotchet = event.stepTime + Math.floor((songPosition - event.songTime) / event.semiquaver);

		// If same crotchet
		if (this.currentCrotchet == oldCrotchet)
			return false;

		// If crotchet invalid
		if (this.currentCrotchet <= 0)
			return false;

		if (this.currentCrotchet % 4 != 0)
			return false;

		beatSignal.dispatch();
		return true;
	}

	// #endregion
	// #region Events
	private var bpmChangeEvents:Array<BPMChangeEvent> = [];

	public function getChangeEvent(time:Float):BPMChangeEvent
	{
		var event:BPMChangeEvent = {
			bpm: this.BPM,
			semiquaver: this.SEMIQUAVER_MS,

			songTime: 0,
			stepTime: 0
		};

		for (i in 0...this.bpmChangeEvents.length)
		{
			if (this.bpmChangeEvents[i].stepTime > time)
				continue;

			event = this.bpmChangeEvents[i];
			break;
		}

		return event;
	}

	// #endregion
}
