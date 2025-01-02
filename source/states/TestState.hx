package states;

import openfl.display.BitmapData;
import core.objects.Controller;
import flixel.text.FlxText;
import flixel.FlxState;
import core.objects.Note;

class TestState extends FlxState
{
	var text:FlxText;
	var controller:Controller;

	var circleSkin:NoteSkin; 
	var majinSkin:NoteSkin; 

	var leftNote:Note;
	var rightNote:Note;
	var upNote:Note;
	var downNote:Note;

	var c:Bool;

	override function create()
	{
		super.create();

		controller = new Controller();

		text = new FlxText(0, 0);
		text.size = 32;
		add(text);

		circleSkin = Note.createSkin("mods/BossRush/notes/Circles/data.json");
		majinSkin = Note.createSkin("mods/BossRush/notes/Majin/data.json");

		leftNote = new Note(0, 200);
		leftNote.loadSkin(circleSkin);
		leftNote.direction = NoteDirection.LEFT;
		add(leftNote);

		downNote = new Note(120 * 1, 200);
		downNote.loadSkin(majinSkin);
		downNote.direction = NoteDirection.DOWN;
		add(downNote);

		upNote = new Note(120 * 2, 200);
		upNote.loadSkin(circleSkin);
		upNote.direction = NoteDirection.UP;
		add(upNote);

		rightNote = new Note(120 * 3, 200);
		rightNote.loadSkin(majinSkin);
		rightNote.direction = NoteDirection.RIGHT;
		add(rightNote);

		c = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var t = [];

		if (controller.up)
			t.push("UP");

		if (controller.down)
			t.push("DOWN");

		if (controller.left)
			t.push("LEFT");

		if (controller.right)
			t.push("RIGHT");

		if (t.length == 0)
			t.push("NONE");

		text.text = t.join(", ");

		if (controller.just_left)
			leftNote.playPressed();
		else if (!controller.left)
			leftNote.playIdle();

		if (controller.just_right)
			rightNote.playPressed();
		else if (!controller.right)
			rightNote.playIdle();

		if (controller.just_up)
			upNote.playPressed();
		else if (!controller.up)
			upNote.playIdle();

		if (controller.just_down)
			downNote.playPressed();
		else if (!controller.down)
			downNote.playIdle();

		if (controller.r)
		{
			c = !c;

			leftNote.loadSkin(c ? circleSkin : majinSkin);
			downNote.loadSkin(c ? majinSkin : circleSkin);
			upNote.loadSkin(c ? circleSkin : majinSkin);
			rightNote.loadSkin(c ? majinSkin : circleSkin);
		}
	}
}
