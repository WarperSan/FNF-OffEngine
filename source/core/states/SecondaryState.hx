package core.states;

import flixel.FlxSubState;
import polymod.hscript.HScriptedClass;

/** Class that represents states that can be opened on top of primary states */
class SecondaryState extends FlxSubState {}

/** Class that represents scripted secondary states */
@:hscriptClass
class ScriptedSecondaryState extends SecondaryState implements HScriptedClass {}
