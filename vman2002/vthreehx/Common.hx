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

    /** Sends warning to the console. **/
    public static function warn(t:String) {
        trace(t);
    }

    /** Converts `n` to an `Int` (`1` for `true`, `0` for `false`) **/
	public static inline function boolToInt(n:Bool) {
		return n ? 1 : 0;
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