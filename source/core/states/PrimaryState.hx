package core.states;

import flixel.FlxBasic;
import flixel.FlxState;
import objects.Metronome;

/** Class that represents core states in the application */
class PrimaryState extends FlxState implements IBeatable
{
	public function new(bpm:UInt = 100)
	{
		super();

		metronome = new Metronome(bpm);
	}

	override function create()
	{
		super.create();

		metronome.addListener(this);
		add(metronome);
	}

	override function onMemberAdd(member:FlxBasic)
	{
		super.onMemberAdd(member);
		this.addToBeat(member);
	}

	override function onMemberRemove(member:FlxBasic)
	{
		super.onMemberRemove(member);
		this.removeFromBeat(member);
	}

	public function onBeat() {}

	// #region Metronome
	private var metronome:Metronome;

	private function addToBeat(member:FlxBasic)
	{
		// If not beatable, skip
		if (!(member is IBeatable))
			return;

		metronome.addListener(cast member);
	}

	private function removeFromBeat(member:FlxBasic)
	{
		// If not beatable, skip
		if (!(member is IBeatable))
			return;

		metronome.removeListener(cast member);
	}

	// #endregion
}
