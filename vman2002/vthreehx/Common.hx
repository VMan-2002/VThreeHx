package vman2002.vthreehx;

//TODO: this shouldnt work but i hope it does
typedef Float32Array = Array<Float>;
typedef Uint32Array = Array<Int>;
typedef Uint16Array = Array<Int>;
typedef Uint8Array = Array<Int>;
typedef Int32Array = Array<Int>;
typedef Int16Array = Array<Int>;
typedef Int8Array = Array<Int>;

class Common {
    //Custom common things

    public static final EPSILON:Float = 0.0000001;

    /** Sends warning to the console. **/
    public static function warn(t:String) {
        trace(t);
    }

    /** Converts `n` to an `Int` (`1` for `true`, `0` for `false`) **/
	public static inline function boolToInt(n:Bool) {
		return n ? 1 : 0;
	}

    /** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign **/
    public static function assign(trg:Dynamic, src:Dynamic) {
        for (k in Reflect.fields(src)) {
            Reflect.setField(trg, k, Reflect.field(src, k));
        }
        return trg;
    }

    public static function trunc(n:Float) {
        return n > 0 ? Math.floor(n) : Math.ceil(n);
    }

    /** Copy a field if it exists on both objects **/
    public static function copyField(dst:Dynamic, src:Dynamic, name:String) {
        if (Reflect.hasField(src, name) && Reflect.hasField(dst, name))
            Reflect.setField(dst, name, Reflect.field(src, name));
    }

    /** Whether or not `describe` is enabled **/
    public static var describeEnabled = #if debug true; #else false; #end

    /** Describes the listed variable. Does nothing in non-debug builds. **/
	public static #if !debug inline #end function describe(name:String, val:Dynamic) {
		#if debug
        if (describeEnabled) {
            trace("Name: "+name);
            var typeName = Type.getClassName(Type.getClass(val));
            trace("Type: "+typeName);
            trace("Value: "+Std.string(val));
        }
		#end
	}
}