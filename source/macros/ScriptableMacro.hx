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
		// Classes
		var cls = Context.getLocalClass().get();

		if (cls.interfaces.findIndex(i -> i.t.get().name == "IScriptable") == -1)
			return null;

		var superCls = cls.superClass.t.get();

		// Constructor arguments
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

		// Fields
		var utils = buildScriptedClassUtils(cls, superCls);
		var init = buildScriptedClassInit(cls, superCls, args);
		var createNew = buildCreateNew(cls, args);

		var fields:Array<Field> = Context.getBuildFields();
		fields = fields.concat(utils);
		fields.push(init);
		fields.push(createNew);

		return fields;
	}

	private static function buildScriptedClassUtils(cls:ClassType, superCls:ClassType):Array<Field>
	{
		if (cls == null || superCls == null)
			return [];

		var fields = @:privateAccess polymod.hscript._internal.HScriptedClassMacro.buildScriptedClassUtils(cls, superCls);

		// Remove extra fields
		fields = fields.filter(f -> f.name != "scriptSet");
		fields = fields.filter(f -> f.name != "scriptGet");
		fields = fields.filter(f -> f.name != "scriptCall");

		// Add "base" to the list of classes
		var listScriptClasses = fields.find(f -> f.name == "listScriptClasses");

		switch (listScriptClasses.kind)
		{
			case FFun(f):
				var superClsTypeName:String = superCls.pack.join('.') != '' ? '${superCls.pack.join('.')}.${superCls.name}' : superCls.name;
				f.expr = macro
					{
						var classes = polymod.hscript._internal.PolymodScriptClass.listScriptClassesExtending($v{superClsTypeName});
						classes.push("base");
						return classes;
					};
			default:
		}

		return fields;
	}

	private static function buildScriptedClassInit(cls:ClassType, superCls:ClassType, args:Array<FunctionArg>):Field
	{
		var init = @:privateAccess polymod.hscript._internal.HScriptedClassMacro.buildScriptedClassInit(cls, superCls, args);

		switch (init.kind)
		{
			case FFun(f):
				var prevExpr = f.expr;
				var className = cls.pack.join(".") + "." + cls.name;
				var constArgs = [for (arg in args) macro $i{arg.name}];

				f.expr = macro
					{
						if (clsName == "base")
						{
							var classType = Type.resolveClass($v{className});
							return Type.createInstance(classType, $a{constArgs});
						}

						return $e{prevExpr};
					};
			default:
		}

		return init;
	}

	private static function buildCreateNew(cls:ClassType, args:Array<FunctionArg>)
	{
		var clsTypeName:String = cls.pack.join('.') != '' ? '${cls.pack.join('.')}.${cls.name}' : cls.name;
		var constArgs = [for (arg in args) macro $i{arg.name}];

		return {
			name: "createNew",
			doc: "Creates the first scripted class instance of this class.",
			access: [APublic, AStatic],
			meta: null,
			pos: cls.pos,
			kind: FFun({
				args: args,
				params: null,
				ret: Context.toComplexType(Context.getType(clsTypeName)),
				expr: macro
				{
					var type = Type.resolveClass($v{clsTypeName});
					var names:Array<String> = Reflect.callMethod(type, Reflect.field(type, "listScriptClasses"), []);

					var arguments:Array<Dynamic> = $a{constArgs};
					arguments.insert(0, names[0]);

					return Reflect.callMethod(type, Reflect.field(type, "init"), arguments);
				}
			}),
		};
	}
}
#end
