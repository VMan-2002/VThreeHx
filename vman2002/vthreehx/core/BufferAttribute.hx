package vman2002.vthreehx.core;

import vman2002.vthreehx.Common;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.math.MathUtils.denormalize;
import vman2002.vthreehx.math.MathUtils.normalize;
import vman2002.vthreehx.Constants.StaticDrawUsage;
import vman2002.vthreehx.Constants.FloatType;
import vman2002.vthreehx.extras.DataUtils.fromHalfFloat;
import vman2002.vthreehx.extras.DataUtils.toHalfFloat;
import vman2002.vthreehx.math.Matrix3;

typedef UpdateRange = {
    start:Int,
    count:Int
}

/**
 * This class stores data for an attribute (such as vertex positions, face
 * indices, normals, colors, UVs, and any custom attributes ) associated with
 * a geometry, which allows for more efficient passing of data to the GPU.
 *
 * When working with vector-like data, the `fromBufferAttribute( attribute, index )`
 * helper methods on vector and color class might be helpful. E.g. {@link Vector3#fromBufferAttribute}.
 */
class BufferAttribute<BufferArray:(TypedArray<Dynamic>) = Dynamic, BufferNumber:(Dynamic) = Dynamic> {
    public static var _id:Int = 0;

    /**
    * The ID of the buffer attribute.
    *
    * @name BufferAttribute#id
    * @type {number}
    * @readonly
    */
    public var id:Int;

    /**
    * The name of the buffer attribute.
    *
    * @type {string}
    */
    public var name = '';

    /**
    * The array holding the attribute data. It should have `itemSize * numVertices`
    * elements, where `numVertices` is the number of vertices in the associated geometry.
    *
    * @type {TypedArray}
    */
    public var array:Dynamic;

    /**
    * The number of values of the array that should be associated with a particular vertex.
    * For instance, if this attribute is storing a 3-component vector (such as a position,
    * normal, or color), then the value should be `3`.
    *
    * @type {number}
    */
    public var itemSize = 0;

    /**
    * Represents the number of items this buffer attribute stores. It is internally computed
    * by dividing the `array` length by the `itemSize`.
    *
    * @type {number}
    * @readonly
    */
    public var count:Int;

    /**
    * Applies to integer data only. Indicates how the underlying data in the buffer maps to
    * the values in the GLSL code. For instance, if `array` is an instance of `UInt16Array`,
    * and `normalized` is `true`, the values `0 -+65535` in the array data will be mapped to
    * `0.0f - +1.0f` in the GLSL attribute. If `normalized` is `false`, the values will be converted
    * to floats unmodified, i.e. `65535` becomes `65535.0f`.
    *
    * @type {boolean}
    */
    public var normalized:Bool;

    /**
    * Defines the intended usage pattern of the data store for optimization purposes.
    *
    * Note: After the initial use of a buffer, its usage cannot be changed. Instead,
    * instantiate a new one and set the desired usage before the next render.
    *
    * @type {(StaticDrawUsage|DynamicDrawUsage|StreamDrawUsage|StaticReadUsage|DynamicReadUsage|StreamReadUsage|StaticCopyUsage|DynamicCopyUsage|StreamCopyUsage)}
    * @default StaticDrawUsage
    */
    public var usage = StaticDrawUsage;

    /**
    * This can be used to only update some components of stored vectors (for example, just the
    * component related to color). Use the `addUpdateRange()` function to add ranges to this array.
    *
    * @type {Array<Object>}
    */
    public var updateRanges:Array<UpdateRange> = [];

    /**
    * Configures the bound GPU type for use in shaders.
    *
    * Note: this only has an effect for integer arrays and is not configurable for float arrays.
    * For lower precision float types, use `Float16BufferAttribute`.
    *
    * @type {(FloatType|IntType)}
    * @default FloatType
    */
    public var gpuType = FloatType;

    /**
    * A version number, incremented every time the `needsUpdate` is set to `true`.
    *
    * @type {number}
    */
    public var version = 0;

	/**
	 * Constructs a new buffer attribute.
	 *
	 * @param {TypedArray} array - The array holding the attribute data.
	 * @param {number} itemSize - The item size.
	 * @param {boolean} [normalized=false] - Whether the data are normalized or not.
	 */
	public function new( array:BufferArray, ?itemSize:Int = 1, normalized = false ) {
		/*if ( Array.isArray( array ) )
			throw( 'THREE.BufferAttribute: array should be a Typed Array.' );*/
        //if we get a Haxe array
        if (Std.isOfType(array, Array))
            array = cast ArrayUtil.fromArray(new Float64Array(), cast array);

        this.id = _id;
        _id += 1;

        this.itemSize = itemSize;
        this.array = array;
        /*Common.describe("array", array);
        Common.describe("array.length", array.length);
        Common.describe("itemSize", itemSize);*/
        this.count = array != null ? Std.int(array.length / itemSize) : 0;
        this.normalized = normalized;
	}

	/**
	 * Flag to indicate that this attribute has changed and should be re-sent to
	 * the GPU. Set this to `true` when you modify the value of the array.
	 *
	 * @type {number}
	 * @default false
	 * @param {boolean} value
	 */
    public var needsUpdate(default, set) = false;

	/**
	 * A callback function that is executed after the renderer has transferred the attribute
	 * array data to the GPU.
	 */
	dynamic function onUploadCallback() {}

	function set_needsUpdate( value ) {
		if ( value ) this.version ++;
        return needsUpdate = value;
	}

	/**
	 * Sets the usage of this buffer attribute.
	 *
	 * @param {(StaticDrawUsage|DynamicDrawUsage|StreamDrawUsage|StaticReadUsage|DynamicReadUsage|StreamReadUsage|StaticCopyUsage|DynamicCopyUsage|StreamCopyUsage)} value - The usage to set.
	 * @return {BufferAttribute} A reference to this buffer attribute.
	 */
	public function setUsage( value ) {

		this.usage = value;

		return this;

	}

	/**
	 * Adds a range of data in the data array to be updated on the GPU.
	 *
	 * @param {number} start - Position at which to start update.
	 * @param {number} count - The number of components to update.
	 */
	public function addUpdateRange( start, count ) {

		this.updateRanges.push( { start: start, count: count } );

	}

	/**
	 * Clears the update ranges.
	 */
	public function clearUpdateRanges() {

		this.updateRanges.resize(0);

	}

	/**
	 * Copies the values of the given buffer attribute to this instance.
	 *
	 * @param {BufferAttribute} source - The buffer attribute to copy.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function copy( source ) {
		this.name = source.name;
        this.array = source.array.copy();
		this.itemSize = source.itemSize;
		this.count = source.count;
		this.normalized = source.normalized;

		this.usage = source.usage;
		this.gpuType = source.gpuType;

		return this;
	}

	/**
	 * Copies a vector from the given buffer attribute to this one. The start
	 * and destination position in the attribute buffers are represented by the
	 * given indices.
	 *
	 * @param {number} index1 - The destination index into this buffer attribute.
	 * @param {BufferAttribute} attribute - The buffer attribute to copy from.
	 * @param {number} index2 - The source index into the given buffer attribute.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function copyAt( index1:Int, attribute:BufferAttribute, index2:Int ) {

		index1 *= this.itemSize;
		index2 *= attribute.itemSize;

		for ( i in 0...this.itemSize ) {

			this.array[ index1 + i ] = attribute.array[ index2 + i ];

		}

		return this;

	}

	/**
	 * Copies the given array data into this buffer attribute.
	 *
	 * @param {(TypedArray|Array)} array - The array to copy.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function copyArray( array ) {

		this.array.set( array );

		return this;

	}

	/**
	 * Applies the given 3x3 matrix to the given attribute. Works with
	 * item size `2` and `3`.
	 *
	 * @param {Matrix3} m - The matrix to apply.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function applyMatrix3( m:Matrix3 ) {

		if ( this.itemSize == 2 ) {

			for ( i in 0...this.count ) {

				_vector2.fromBufferAttribute( this, i );
				_vector2.applyMatrix3( m );

				this.setXY( i, _vector2.x, _vector2.y );

			}

		} else if ( this.itemSize == 3 ) {

			for ( i in 0...this.count ) {

				_vector.fromBufferAttribute( this, i );
				_vector.applyMatrix3( m );

				this.setXYZ( i, _vector.x, _vector.y, _vector.z );

			}

		}

		return this;

	}

	/**
	 * Applies the given 4x4 matrix to the given attribute. Only works with
	 * item size `3`.
	 *
	 * @param {Matrix4} m - The matrix to apply.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function applyMatrix4( m ) {

		for ( i in 0...this.count ) {

			_vector.fromBufferAttribute( this, i );

			_vector.applyMatrix4( m );

			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

		return this;

	}

	/**
	 * Applies the given 3x3 normal matrix to the given attribute. Only works with
	 * item size `3`.
	 *
	 * @param {Matrix3} m - The normal matrix to apply.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function applyNormalMatrix( m ) {

		for ( i in 0...this.count ) {

			_vector.fromBufferAttribute( this, i );

			_vector.applyNormalMatrix( m );

			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

		return this;

	}

	/**
	 * Applies the given 4x4 matrix to the given attribute. Only works with
	 * item size `3` and with direction vectors.
	 *
	 * @param {Matrix4} m - The matrix to apply.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function transformDirection( m ) {

		for ( i in 0...this.count ) {

			_vector.fromBufferAttribute( this, i );

			_vector.transformDirection( m );

			this.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

		return this;

	}

	/**
	 * Sets the given array data in the buffer attribute.
	 *
	 * @param {(TypedArray|Array)} value - The array data to set.
	 * @param {number} [offset=0] - The offset in this buffer attribute's array.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function set( value, offset = 0 ) {

		// Matching BufferAttribute constructor, do not normalize the array.
		this.array.set( value, offset );

		return this;

	}

	/**
	 * Returns the given component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} component - The component index.
	 * @return {number} The returned value.
	 */
	public function getComponent( index:Int, component:Int ) {

		var value = this.array[ index * this.itemSize + component ];

		if ( this.normalized ) value = denormalize( value, this.array );

		return value;

	}

	/**
	 * Sets the given value to the given component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} component - The component index.
	 * @param {number} value - The value to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setComponent( index:Int, component:Int, value:Dynamic ) {

		if ( this.normalized ) value = normalize( value, this.array );

		this.array[ index * this.itemSize + component ] = value;

		return this;

	}

	/**
	 * Returns the x component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @return {number} The x component.
	 */
	public function getX( index:Int ) {

		var x = this.array[ index * this.itemSize ];

		if ( this.normalized ) x = denormalize( x, this.array );

		return x;

	}

	/**
	 * Sets the x component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} x - The value to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setX( index:Int, x:Dynamic ) {

		if ( this.normalized ) x = normalize( x, this.array );

		this.array[ index * this.itemSize ] = x;

		return this;

	}

	/**
	 * Returns the y component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @return {number} The y component.
	 */
	public function getY( index:Int ) {

		var y = this.array[ index * this.itemSize + 1 ];

		if ( this.normalized ) y = denormalize( y, this.array );

		return y;

	}

	/**
	 * Sets the y component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} y - The value to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setY( index:Int, y:Dynamic ) {

		if ( this.normalized ) y = normalize( y, this.array );

		this.array[ index * this.itemSize + 1 ] = y;

		return this;

	}

	/**
	 * Returns the z component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @return {number} The z component.
	 */
	public function getZ( index:Int ) {

		var z = this.array[ index * this.itemSize + 2 ];

		if ( this.normalized ) z = denormalize( z, this.array );

		return z;

	}

	/**
	 * Sets the z component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} z - The value to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setZ( index:Int, z:Dynamic ) {

		if ( this.normalized ) z = normalize( z, this.array );

		this.array[ index * this.itemSize + 2 ] = z;

		return this;

	}

	/**
	 * Returns the w component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @return {number} The w component.
	 */
	public function getW( index:Int ) {

		var w = this.array[ index * this.itemSize + 3 ];

		if ( this.normalized ) w = denormalize( w, this.array );

		return w;

	}

	/**
	 * Sets the w component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} w - The value to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setW( index:Int, w:Dynamic ) {

		if ( this.normalized ) w = normalize( w, this.array );

		this.array[ index * this.itemSize + 3 ] = w;

		return this;

	}

	/**
	 * Sets the x and y component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} x - The value for the x component to set.
	 * @param {number} y - The value for the y component to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setXY( index:Int, x:Dynamic, y:Dynamic ) {

		index *= this.itemSize;

		if ( this.normalized ) {
			x = normalize( x, this.array );
			y = normalize( y, this.array );
		}

		this.array[ index + 0 ] = x;
		this.array[ index + 1 ] = y;

		return this;

	}

	/**
	 * Sets the x, y and z component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} x - The value for the x component to set.
	 * @param {number} y - The value for the y component to set.
	 * @param {number} z - The value for the z component to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setXYZ( index:Int, x:Dynamic, y:Dynamic, z:Dynamic ) {

		index *= this.itemSize;

		if ( this.normalized ) {

			x = normalize( x, this.array );
			y = normalize( y, this.array );
			z = normalize( z, this.array );

		}

		this.array[ index + 0 ] = x;
		this.array[ index + 1 ] = y;
		this.array[ index + 2 ] = z;

		return this;

	}

	/**
	 * Sets the x, y, z and w component of the vector at the given index.
	 *
	 * @param {number} index - The index into the buffer attribute.
	 * @param {number} x - The value for the x component to set.
	 * @param {number} y - The value for the y component to set.
	 * @param {number} z - The value for the z component to set.
	 * @param {number} w - The value for the w component to set.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function setXYZW( index:Int, x:Dynamic, y:Dynamic, z:Dynamic, w:Dynamic ) {

		index *= this.itemSize;

		if ( this.normalized ) {

			x = normalize( x, this.array );
			y = normalize( y, this.array );
			z = normalize( z, this.array );
			w = normalize( w, this.array );

		}

		this.array[ index + 0 ] = x;
		this.array[ index + 1 ] = y;
		this.array[ index + 2 ] = z;
		this.array[ index + 3 ] = w;

		return this;

	}

	/**
	 * Sets the given callback function that is executed after the Renderer has transferred
	 * the attribute array data to the GPU. Can be used to perform clean-up operations after
	 * the upload when attribute data are not needed anymore on the CPU side.
	 *
	 * @param {Function} callback - The `onUpload()` callback.
	 * @return {BufferAttribute} A reference to this instance.
	 */
	public function onUpload( callback ) {

		this.onUploadCallback = callback;

		return this;

	}

	/**
	 * Returns a new buffer attribute with copied values from this instance.
	 *
	 * @return {BufferAttribute} A clone of this instance.
	 */
	public function clone() {

		return Common.reconstruct(this, [this.array, this.itemSize] ).copy( this );

	}

	/**
	 * Serializes the buffer attribute into JSON.
	 *
	 * @return {Object} A JSON object representing the serialized buffer attribute.
	 */
	public function toJSON() {

		var data:Dynamic = {
			itemSize: this.itemSize,
			type: this.array.constructor.name,
			array: cast( this.array, Array<Dynamic>),
			normalized: this.normalized
		};

		if ( this.name != '' ) data.name = this.name;
		if ( this.usage != StaticDrawUsage ) data.usage = this.usage;

		return data;

	}


    var _vector = /*@__PURE__*/ new Vector3();
    var _vector2 = /*@__PURE__*/ new Vector2();
}

typedef Float32BufferAttribute = BufferAttribute<Float32Array, Float>;
typedef Uint16BufferAttribute = BufferAttribute<Uint16Array, Int>;
typedef Uint32BufferAttribute = BufferAttribute<Uint32Array, Int>;