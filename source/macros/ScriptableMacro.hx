package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using Lambda;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

class ScriptableMacro
{
	macro static public function build():Array<Field>
	{
		var localClass = Context.getLocalClass().get();

		// If local class not directly scriptable, skip
		if (localClass.interfaces.findIndex(i -> i.t.get().name == "IScriptable") == -1)
			return null;

		var scriptedClass = createScriptedClass(localClass);

		var fields = Context.getBuildFields();
		fields.push(function_init(localClass, scriptedClass));
		fields.push(function_list(localClass, scriptedClass));
		fields.push(function_createNew(localClass, scriptedClass));

		return fields;
	}

	// === FIELDS ===
	private static function function_list(localClass:ClassType, scriptedClass:TypeDefinition):Field
	{
		var scriptedTypeName = getTypeFullname(scriptedClass);

		return {
			name: "list",
			doc: "Returns a list of all the scripted classes which extend this class.",
			access: [APublic, AStatic],
			meta: null,
			pos: localClass.pos,
			kind: FFun({
				args: [],
				params: null,
				ret: @:privateAccess polymod.hscript._internal.HScriptedClassMacro.toComplexTypeArray(Context.toComplexType(Context.getType('String'))),
				expr: macro
				{
					var type = Type.resolveClass($v{scriptedTypeName});
					var names:Array<String> = Reflect.callMethod(type, Reflect.field(type, "listScriptClasses"), []);
					names.push("base");
					return names;
				}
			}),
		};
	}

	private static function function_init(localClass:ClassType, scriptedClass:TypeDefinition)
	{
		var localTypeName = getClassFullname(localClass);
		var scriptedTypeName = getTypeFullname(scriptedClass);

		var args = getConstructorArguments();
		var constArgs = [for (arg in args) macro $i{arg.name}];

		return {
			name: "init",
			doc: "Initializes a scripted class instance using the given scripted class name and constructor arguments.",
			access: [APublic, AStatic],
			meta: null,
			pos: localClass.pos,
			kind: FFun({
				args: [{name: 'clsName', type: Context.toComplexType(Context.getType('String'))},].concat(args),
				params: null,
				ret: Context.toComplexType(Context.getType(localTypeName)),
				expr: macro
				{
					var scriptedType = Type.resolveClass($v{scriptedTypeName});

					var arguments:Array<Dynamic> = $a{constArgs};

					if (clsName == "base")
						return Type.createInstance(scriptedType, arguments);

					arguments.insert(0, clsName);

					return Reflect.callMethod(scriptedType, Reflect.field(scriptedType, "init"), arguments);
				}
			}),
		};
	}

	private static function function_createNew(localClass:ClassType, scriptedClass:TypeDefinition):Field
	{
		var localTypeName = getClassFullname(localClass);

		var args = getConstructorArguments();
		var constArgs = [for (arg in args) macro $i{arg.name}];

		return {
			name: "createNew",
			doc: "Creates the first scripted class instance of this class.",
			access: [APublic, AStatic],
			meta: null,
			pos: localClass.pos,
			kind: FFun({
				args: args,
				params: null,
				ret: Context.toComplexType(Context.getType(localTypeName)),
				expr: macro
				{
					var type = Type.resolveClass($v{localTypeName});
					var names:Array<String> = Reflect.callMethod(type, Reflect.field(type, "list"), []);

					var arguments:Array<Dynamic> = $a{constArgs};
					arguments.insert(0, core.ModsManager.chooseScriptable(names));

					return Reflect.callMethod(type, Reflect.field(type, "init"), arguments);
				}
			}),
		};
	}
	// === UTILS ===

	/** Creates a new scripted type from the given class */
	private static function createScriptedClass(superClass:ClassType):TypeDefinition
	{
		var superTypePath:haxe.macro.TypePath = {
			pack: superClass.pack,
			name: superClass.name
		};
		var scriptedClassName = "Scripted" + superClass.name;
		var scriptedClass = macro class $scriptedClassName extends $superTypePath implements polymod.hscript.HScriptedClass {};
		scriptedClass.meta.push({
			name: ":hscriptClass",
			pos: scriptedClass.pos
		});

		Context.defineType(scriptedClass);

		return scriptedClass;
	}

	/** Fetches the arguments of the constructor in the local class */
	private static function getConstructorArguments():Array<FunctionArg>
	{
		var args:Array<FunctionArg> = [];
		var constructor = Context.getBuildFields().find(function(field) return field.name == 'new');

		if (constructor != null)
		{
			switch (constructor.kind)
			{
				case FFun(f):
					args = f.args;
				default:
			}
		}

		return args;
	}

	/** Fetches the full name of the given class */
	private static function getClassFullname(cls:ClassType)
	{
		return cls.pack.join('.') != '' ? '${cls.pack.join('.')}.${cls.name}' : cls.name;
	}

	/** Fetches the full name of the given type */
	private static function getTypeFullname(type:TypeDefinition)
	{
		return type.pack.join('.') != '' ? '${type.pack.join('.')}.${type.name}' : type.name;
	}
}
#end
