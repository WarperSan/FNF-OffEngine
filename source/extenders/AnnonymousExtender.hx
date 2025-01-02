package extenders;

class AnnonymousExtender
{
	/** Sets the field of `b` from `o` or `defaultValue` if the object doesn't have a value */
	public static inline function setDefault(b:Dynamic, o:Dynamic, name:String, defaultValue:Dynamic)
		Reflect.setField(b, name, Reflect.field(o, name) ?? defaultValue);
}
