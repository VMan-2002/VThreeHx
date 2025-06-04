package vman2002.vthreehx.math;

import vman2002.vthreehx.math.Quaternion;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.MathUtils.clamp in clamp;

/**
 * A class representing Euler angles.
 *
 * Euler angles describe a rotational transformation by rotating an object on
 * its various axes in specified amounts per axis, and a specified axis
 * order.
 *
 * Iterating through an instance will yield its components (x, y, z,
 * order) in the corresponding order.
 *
 * ```js
 * const a = new THREE.Euler( 0, 1, 1.57, 'XYZ' );
 * const b = new THREE.Vector3( 1, 0, 1 );
 * b.applyEuler(a);
 * ```
 */
class Euler {
    /** The default Euler angle order. */
    public static var DEFAULT_ORDER = 'XYZ';

	/** The angle of the x axis in radians. **/
    public var x(get, set):Float;

	/** The angle of the y axis in radians. **/
    public var y(get, set):Float;

	/** The angle of the z axis in radians. **/
    public var z(get, set):Float;

	/** A string representing the order that the rotations are applied. **/
    public var order(get, set):String;

	/**
	 * Constructs a new euler instance.
	 *
	 * @param x The angle of the x axis in radians.
	 * @param y The angle of the y axis in radians.
	 * @param z The angle of the z axis in radians.
	 * @param order A string representing the order that the rotations are applied.
	 */
	public function new( x:Float = 0, y:Float = 0, z:Float = 0, ?order:String ) {
		this._x = x;
		this._y = y;
		this._z = z;
		this._order = order ?? DEFAULT_ORDER;
	}

	/**
	 * Sets the Euler components.
	 *
	 * @param x The angle of the x axis in radians.
	 * @param y The angle of the y axis in radians.
	 * @param z The angle of the z axis in radians.
	 * @param order - A string representing the order that the rotations are applied.
	 * @return A reference to this Euler instance.
	 */
	public inline function set( x, y, z, ?order ) {
		this._x = x;
		this._y = y;
		this._z = z;
		if (order != null)
			this._order = order;
		this._onChangeCallback();

		return this;
	}

	/**
	 * Returns a new Euler instance with copied values from this instance.
	 *
	 * @return A clone of this instance.
	 */
	public inline function clone() {
		return new Euler( this._x, this._y, this._z, this._order );
	}

	/**
	 * Copies the values of the given Euler instance to this instance.
	 *
	 * @param euler The Euler instance to copy.
	 * @return A reference to this Euler instance.
	 */
	public function copy( euler:Euler ) {
		this._x = euler._x;
		this._y = euler._y;
		this._z = euler._z;
		this._order = euler._order;

		this._onChangeCallback();

		return this;
	}

	/**
	 * Sets the angles of this Euler instance from a pure rotation matrix.
	 *
	 * @param m A 4x4 matrix of which the upper 3x3 of matrix is a pure rotation matrix (i.e. unscaled).
	 * @param order A string representing the order that the rotations are applied.
	 * @param update Whether the internal `onChange` callback should be executed or not.
	 * @return A reference to this Euler instance.
	 */
	public function setFromRotationMatrix( m:Matrix4, ?order:String, update:Bool = true ) {
		var te = m.elements;
		var m11 = te[ 0 ], m12 = te[ 4 ], m13 = te[ 8 ];
		var m21 = te[ 1 ], m22 = te[ 5 ], m23 = te[ 9 ];
		var m31 = te[ 2 ], m32 = te[ 6 ], m33 = te[ 10 ];

		if (order == null)
			order = this._order;

		switch ( order ) {

			case 'XYZ':

				this._y = Math.asin( clamp( m13, - 1, 1 ) );

				if ( Math.abs( m13 ) < 0.9999999 ) {

					this._x = Math.atan2( - m23, m33 );
					this._z = Math.atan2( - m12, m11 );

				} else {

					this._x = Math.atan2( m32, m22 );
					this._z = 0;

				}

			case 'YXZ':

				this._x = Math.asin( - clamp( m23, - 1, 1 ) );

				if ( Math.abs( m23 ) < 0.9999999 ) {

					this._y = Math.atan2( m13, m33 );
					this._z = Math.atan2( m21, m22 );

				} else {

					this._y = Math.atan2( - m31, m11 );
					this._z = 0;

				}

			case 'ZXY':

				this._x = Math.asin( clamp( m32, - 1, 1 ) );

				if ( Math.abs( m32 ) < 0.9999999 ) {

					this._y = Math.atan2( - m31, m33 );
					this._z = Math.atan2( - m12, m22 );

				} else {

					this._y = 0;
					this._z = Math.atan2( m21, m11 );

				}

			case 'ZYX':

				this._y = Math.asin( - clamp( m31, - 1, 1 ) );

				if ( Math.abs( m31 ) < 0.9999999 ) {

					this._x = Math.atan2( m32, m33 );
					this._z = Math.atan2( m21, m11 );

				} else {

					this._x = 0;
					this._z = Math.atan2( - m12, m22 );

				}

			case 'YZX':

				this._z = Math.asin( clamp( m21, - 1, 1 ) );

				if ( Math.abs( m21 ) < 0.9999999 ) {

					this._x = Math.atan2( - m23, m22 );
					this._y = Math.atan2( - m31, m11 );

				} else {

					this._x = 0;
					this._y = Math.atan2( m13, m33 );

				}

			case 'XZY':

				this._z = Math.asin( - clamp( m12, - 1, 1 ) );

				if ( Math.abs( m12 ) < 0.9999999 ) {

					this._x = Math.atan2( m32, m22 );
					this._y = Math.atan2( m13, m11 );

				} else {

					this._x = Math.atan2( - m23, m33 );
					this._y = 0;

				}

			default:
				Common.warn( 'THREE.Euler: .setFromRotationMatrix() encountered an unknown order: ' + order );
		}

		this._order = order;

		if ( update == true ) this._onChangeCallback();

		return this;
	}

	/**
	 * Sets the angles of this Euler instance from a normalized quaternion.
	 *
	 * @param {Quaternion} q - A normalized Quaternion.
	 * @param {string} [order] - A string representing the order that the rotations are applied.
	 * @param {boolean} [update=true] - Whether the internal `onChange` callback should be executed or not.
	 * @return {Euler} A reference to this Euler instance.
	 */
	public function setFromQuaternion( q:Quaternion, order:String, update:Bool = true ) {
		_matrix.makeRotationFromQuaternion( q );

		return this.setFromRotationMatrix( _matrix, order, update );
	}

	/**
	 * Sets the angles of this Euler instance from the given vector.
	 *
	 * @param {Vector3} v - The vector.
	 * @param {string} [order] - A string representing the order that the rotations are applied.
	 * @return {Euler} A reference to this Euler instance.
	 */
	public inline function setFromVector3( v:Vector3, ?order ) {
		return this.set( v.x, v.y, v.z, order ?? this._order );
	}

	/**
	 * Resets the euler angle with a new order by creating a quaternion from this
	 * euler angle and then setting this euler angle with the quaternion and the
	 * new order.
	 *
	 * Warning: This discards revolution information.
	 *
	 * @param {string} [newOrder] - A string representing the new order that the rotations are applied.
	 * @return {Euler} A reference to this Euler instance.
	 */
	public function reorder( newOrder:String ) {
		_quaternion.setFromEuler( this );

		return this.setFromQuaternion( _quaternion, newOrder );
	}

	/**
	 * Returns `true` if this Euler instance is equal with the given one.
	 *
	 * @param {Euler} euler - The Euler instance to test for equality.
	 * @return {boolean} Whether this Euler instance is equal with the given one.
	 */
	public function equals( euler:Euler ) {
		return ( euler._x == this._x ) && ( euler._y == this._y ) && ( euler._z == this._z ) && ( euler._order == this._order );
	}

	/**
	 * Sets this Euler instance's components to values from the given array. The first three
	 * entries of the array are assign to the x,y and z components. An optional fourth entry
	 * defines the Euler order.
	 *
	 * @param {Array<number,number,number,?string>} array - An array holding the Euler component values.
	 * @return {Euler} A reference to this Euler instance.
	 */
	public function fromArray(array:Array<Dynamic>) {
		this._x = array[ 0 ];
		this._y = array[ 1 ];
		this._z = array[ 2 ];
		if ( array.length > 3 ) this._order = array[ 3 ];

		this._onChangeCallback();

		return this;
	}

	/**
	 * Writes the components of this Euler instance to the given array. If no array is provided,
	 * the method returns a new instance.
	 *
	 * @param {Array<number,number,number,string>} [array=[]] - The target array holding the Euler components.
	 * @param {number} [offset=0] - Index of the first element in the array.
	 * @return {Array<number,number,number,string>} The Euler components.
	 */
	public function toArray( ?array:Array<Dynamic>, offset = 0 ) {
		if (array == null)
			array = [];
		array[ offset ] = this._x;
		array[ offset + 1 ] = this._y;
		array[ offset + 2 ] = this._z;
		array[ offset + 3 ] = this._order;

		return array;
	}

	public function _onChange( callback ) {
		this._onChangeCallback = callback;

		return this;
	}

	public dynamic function _onChangeCallback() {}

    public function iterator() {
		var a:Array<Dynamic> = [this._x, this._y, this._z, this._order];
        return a.iterator();
    }

	function get_x()
		return this._x;
	function get_y()
		return this._y;
	function get_z()
		return this._z;
	function get_order()
		return this._order;
	function set_x( value ) {
		this._x = value;
		this._onChangeCallback();
		return value;
	}
	function set_y( value ) {
		this._y = value;
		this._onChangeCallback();
		return value;
	}
	function set_z( value ) {
		this._z = value;
		this._onChangeCallback();
		return value;
	}
	function set_order( value ) {
		this._order = value;
		this._onChangeCallback();
		return value;
	}

    var _x:Float;
    var _y:Float;
    var _z:Float;
    var _order:String;

    static var _matrix = /*@__PURE__*/ new Matrix4();
    static var _quaternion = /*@__PURE__*/ new Quaternion();
}