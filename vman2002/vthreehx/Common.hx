package vman2002.vthreehx;

#if lime
typedef Float32Array = lime.utils.Float32Array;
typedef Uint32Array = lime.utils.UInt32Array;
typedef Uint16Array = lime.utils.UInt16Array;
typedef Uint8Array = lime.utils.UInt8Array;
typedef Int32Array = lime.utils.Int32Array;
typedef Int16Array = lime.utils.Int16Array;
typedef Int8Array = lime.utils.Int8Array;
#elseif js
typedef Float32Array = js.lib.Float32Array;
typedef Uint32Array = js.lib.UInt32Array;
typedef Uint16Array = js.lib.UInt16Array;
typedef Uint8Array = js.lib.UInt8Array;
typedef Int32Array = js.lib.Int32Array;
typedef Int16Array = js.lib.Int16Array;
typedef Int8Array = js.lib.Int8Array;
#else
typedef Float32Array = Array<Float>;
typedef Uint32Array = Array<Int>;
typedef Uint16Array = Array<Int>;
typedef Uint8Array = Array<Int>;
typedef Int32Array = Array<Int>;
typedef Int16Array = Array<Int>;
typedef Int8Array = Array<Int>;
#end

class Common {
    //Custom common things

    public static final EPSILON:Float = 0.0000001;

    /** Sends warning to the console. **/
    public static function warn(...t:Dynamic) {
        trace("[WARN] " + t.toArray().join(" "));
    }

    /** Sends no-halt error to the console. **/
    public static function error(...t:Dynamic) {
        trace("[ERROR] " + t.toArray().join(" "));
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

    /**
     * Imitates JavaScript's Math.imul in Haxe.
     * Multiplies two 32-bit signed integers and returns the result as a 32-bit signed integer.
     * Thanks copilot
     * 
     * @param a First integer
     * @param b Second integer
     * @return Product as 32-bit signed integer
     */
    public static function imul(a:Int, b:Int):Int {
        var ah = (a >> 16) & 0xffff;
        var al = a & 0xffff;
        var bh = (b >> 16) & 0xffff;
        var bl = b & 0xffff;
        // The result needs to be kept within 32 bits.
        return ((al * bl) + (((ah * bl + al * bh) << 16) >>> 0)) | 0;
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