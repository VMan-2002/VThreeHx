package vman2002.vthreehx;

import vman2002.vthreehx.math.MathUtils;
import UInt;

class ArrayUtil {
    public static inline function toStdFloatArray(buf:Array<Float>) {
        return buf;
    }
    public static inline function toStdIntArray(buf:Array<Int>) {
        return buf;
    }
    public static function fromArray<T>(a:TypedArray<T>, arr:Array<T>) {
        for (k => v in arr.keyValueIterator()) {
            a.set(k, v);
        }
        return a;
    }
}

class TypedArray<T:(Dynamic) = Dynamic> {
    @:arrayAccess
    public function get(n:Int):T {return null;};

    @:arrayAccess
    public function set(n:Int, v:T):T {return null;};

    public var length(get, never):Int;
    public function get_length()
        return 0;

    public function push(v:T):T
        return set(length, v);
}

//TODO: that's a lot of copypasting. can this be made better using macro?
//TODO: really sucks that we can't use haxe.io.*Array (even tho api reference says it exists)
class Float32Array extends TypedArray<Float> {
    public var buf:Array<Float>;

    public function new(?length:Int) {
        buf = new Array<Float>();
    }

    @:arrayAccess
    public override function get(n:Int):Float {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:Int, v:Float):Float {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<Float>
        return ArrayUtil.toStdFloatArray(buf);
}
class Uint32Array extends TypedArray<UInt> {
    public var buf:Array<UInt>;

    public function new(?length:UInt) {
        buf = new Array<UInt>();
    }

    @:arrayAccess
    public override function get(n:UInt):UInt {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:UInt, v:UInt):UInt {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<UInt>
        return ArrayUtil.toStdIntArray(buf);
}
class Uint16Array extends TypedArray<UInt> {
    public var buf:Array<UInt>;

    public function new(?length:UInt) {
        buf = new Array<UInt>();
    }

    @:arrayAccess
    public override function get(n:UInt):UInt {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:UInt, v:UInt):UInt {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<UInt>
        return ArrayUtil.toStdIntArray(buf);
}
class Uint8Array extends TypedArray<UInt> {
    public var buf:Array<UInt>;

    public function new(?length:UInt) {
        buf = new Array<UInt>();
    }

    @:arrayAccess
    public override function get(n:UInt):UInt {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:UInt, v:UInt):UInt {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<UInt>
        return ArrayUtil.toStdIntArray(buf);
}
class Int32Array extends TypedArray<Int> {
    public var buf:Array<Int>;

    public function new(?length:Int) {
        buf = new Array<Int>();
    }

    @:arrayAccess
    public override function get(n:Int):Int {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:Int, v:Int):Int {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<Int>
        return ArrayUtil.toStdIntArray(buf);
}
class Int16Array extends TypedArray<Int> {
    public var buf:Array<Int>;

    public function new(?length:Int) {
        buf = new Array<Int>();
    }

    @:arrayAccess
    public override function get(n:Int):Int {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:Int, v:Int):Int {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<Int>
        return ArrayUtil.toStdIntArray(buf);
}
class Int8Array extends TypedArray<Int> {
    public var buf:Array<Int>;

    public function new(?length:Int) {
        buf = new Array<Int>();
    }

    @:arrayAccess
    public override function get(n:Int):Int {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:Int, v:Int):Int {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<Int>
        return ArrayUtil.toStdIntArray(buf);
}
class Uint8ClampedArray extends Uint8Array {
    @:arrayAccess
    public override function set(n:UInt, v:UInt):UInt {
        return super.set(n, if (v >= 255) 255 else if (v <= 0) 0 else v);
    }
}
class Float64Array extends TypedArray<Float> {
    public var buf:Array<Float>;

    public function new(?length:Int) {
        buf = new Array<Float>();
    }

    @:arrayAccess
    public override function get(n:Int):Float {
        return buf[n];
    }

    @:arrayAccess
    public override function set(n:Int, v:Float):Float {
        return buf[n] = v;
    }

    public override function get_length()
        return buf.length;

    @:to
    public function toArray():Array<Float>
        return ArrayUtil.toStdFloatArray(buf);
}