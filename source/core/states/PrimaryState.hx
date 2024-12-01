package core.states;

import flixel.FlxState;
import objects.Metronome;

/** Class that represents core states in the application */
class PrimaryState extends FlxState implements IBeatable
{
	private var metronome:Metronome;

	public function new()
	{
		super();

		metronome = new Metronome();
		metronome.addListener(this);
		add(metronome);
	}

	public function onBeat() {}
}
