package vman2002.vthreehx.math;

import vman2002.vthreehx.core.BufferAttribute;
import vman2002.vthreehx.math.MathUtils;
import vman2002.vthreehx.math.Quaternion;

/**
 * Class representing a 3D vector. A 3D vector is an ordered triplet of numbers
 * (labeled x, y and z), which can be used to represent a number of things, such as:
 *
 * - A point in 3D space.
 * - A direction and length in 3D space. In three.js the length will
 * always be the Euclidean distance(straight-line distance) from `(0, 0, 0)` to `(x, y, z)`
 * and the direction is also measured from `(0, 0, 0)` towards `(x, y, z)`.
 * - Any arbitrary ordered triplet of numbers.
 *
 * There are other things a 3D vector can be used to represent, such as
 * momentum vectors and so on, however these are the most
 * common uses in three.js.
 *
 * Iterating through a vector instance will yield its components `(x, y, z)` in
 * the corresponding order.
 */
class Vector3 {
	/** The x value of this vector. **/
	public var x:Float = 0;

	/** The y value of this vector. **/
	public var y:Float = 0;

	/** The z value of this vector. **/
	public var z:Float = 0;

	/**
	 * Constructs a new 3D vector.
	 *
	 * @param x The x value of this vector.
	 * @param y The y value of this vector.
	 * @param z The z value of this vector.
	 */
	public function new( ?x:Float = 0, ?y:Float = 0, ?z:Float = 0 ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	/**
	 * Sets the vector components.
	 *
	 * @param x The value of the x component.
	 * @param y The value of the y component.
	 * @param z The value of the z component.
	 * @return A reference to this vector.
	 */
	public function set( x:Float, y:Float, ?z:Float = null ) {
		this.x = x;
		this.y = y;
		this.z = z ?? this.z;

		return this;
	}

	/**
	 * Sets the vector components to the same value.
	 *
	 * @param scalar The value to set for all vector components.
	 * @return A reference to this vector.
	 */
	public function setScalar( scalar ) {
		this.x = this.y = this.z = scalar;

		return this;
	}

	/**
	 * Sets the vector's x component to the given value
	 *
	 * @param x The value to set.
	 * @return A reference to this vector.
	 */
	public function setX( x:Float ) {
		this.x = x;

		return this;
	}

	/**
	 * Sets the vector's y component to the given value
	 *
	 * @param y The value to set.
	 * @return A reference to this vector.
	 */
	public function setY( y:Float ) {
		this.y = y;

		return this;
	}

	/**
	 * Sets the vector's z component to the given value
	 *
	 * @param z The value to set.
	 * @return A reference to this vector.
	 */
	public function setZ( z:Float ) {
		this.z = z;

		return this;
	}

	/**
	 * Allows to set a vector component with an index.
	 *
	 * @param index The component index. `0` equals to x, `1` equals to y, `2` equals to z.
	 * @param value The value to set.
	 * @return A reference to this vector.
	 */
	@:arrayAccess
	public function setComponent( index:Int, value:Float ) {
		switch ( index ) {
			case 0: this.x = value;
			case 1: this.y = value;
			case 2: this.z = value;
			default: throw( 'index is out of range: ' + index );
		}

		return this;
	}

	/**
	 * Returns the value of the vector component which matches the given index.
	 *
	 * @param index The component index. `0` equals to x, `1` equals to y, `2` equals to z.
	 * @return A vector component value.
	 */
	@:arrayAccess
	public function getComponent( index:Int ) {
		switch ( index ) {
			case 0: return this.x;
			case 1: return this.y;
			case 2: return this.z;
			default: throw( 'index is out of range: ' + index );
		}
	}

	/**
	 * Returns a new vector with copied values from this instance.
	 *
	 * @return A clone of this instance.
	 */
	public function clone() {
		return new Vector3( this.x, this.y, this.z );
	}

	/**
	 * Copies the values of the given vector to this instance.
	 *
	 * @param v The vector to copy.
	 * @return A reference to this vector.
	 */
	public function copy( v:Vector3 ) {
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;

		return this;
	}

	/**
	 * Adds the given vector to this instance.
	 *
	 * @param v The vector to add.
	 * @return A reference to this vector.
	 */
	public function add( v:Vector3 ) {
		this.x += v.x;
		this.y += v.y;
		this.z += v.z;

		return this;
	}

	/**
	 * Adds the given scalar value to all components of this instance.
	 *
	 * @param s The scalar to add.
	 * @return A reference to this vector.
	 */
	public function addScalar( s:Float ) {
		this.x += s;
		this.y += s;
		this.z += s;

		return this;
	}

	/**
	 * Adds the given vectors and stores the result in this instance.
	 *
	 * @param a The first vector.
	 * @param b The second vector.
	 * @return A reference to this vector.
	 */
	public function addVectors( a:Vector3, b:Vector3 ) {
		this.x = a.x + b.x;
		this.y = a.y + b.y;
		this.z = a.z + b.z;

		return this;
	}

	/**
	 * Adds the given vector scaled by the given factor to this instance.
	 *
	 * @param v The vector.
	 * @param s The factor that scales `v`.
	 * @return A reference to this vector.
	 */
	public function addScaledVector( v:Vector3, s:Float ) {
		this.x += v.x * s;
		this.y += v.y * s;
		this.z += v.z * s;

		return this;
	}

	/**
	 * Subtracts the given vector from this instance.
	 *
	 * @param v The vector to subtract.
	 * @return A reference to this vector.
	 */
	public function sub( v:Vector3 ) {
		this.x -= v.x;
		this.y -= v.y;
		this.z -= v.z;

		return this;
	}

	/**
	 * Subtracts the given scalar value from all components of this instance.
	 *
	 * @param s The scalar to subtract.
	 * @return A reference to this vector.
	 */
	public function subScalar( s:Float ) {
		this.x -= s;
		this.y -= s;
		this.z -= s;

		return this;
	}

	/**
	 * Subtracts the given vectors and stores the result in this instance.
	 *
	 * @param a The first vector.
	 * @param b The second vector.
	 * @return A reference to this vector.
	 */
	public function subVectors( a:Vector3, b:Vector3 ) {
		this.x = a.x - b.x;
		this.y = a.y - b.y;
		this.z = a.z - b.z;

		return this;
	}

	/**
	 * Multiplies the given vector with this instance.
	 *
	 * @param v The vector to multiply.
	 * @return A reference to this vector.
	 */
	public function multiply( v:Vector3 ) {
		this.x *= v.x;
		this.y *= v.y;
		this.z *= v.z;

		return this;
	}

	/**
	 * Multiplies the given scalar value with all components of this instance.
	 *
	 * @param scalar The scalar to multiply.
	 * @return A reference to this vector.
	 */
	public function multiplyScalar( scalar:Float ) {
		this.x *= scalar;
		this.y *= scalar;
		this.z *= scalar;

		return this;
	}

	/**
	 * Multiplies the given vectors and stores the result in this instance.
	 *
	 * @param a The first vector.
	 * @param b The second vector.
	 * @return A reference to this vector.
	 */
	public function multiplyVectors( a:Vector3, b:Vector3 ) {
		this.x = a.x * b.x;
		this.y = a.y * b.y;
		this.z = a.z * b.z;

		return this;
	}

	/**
	 * Applies the given Euler rotation to this vector.
	 *
	 * @param {Euler} euler - The Euler angles.
	 * @return {Vector3} A reference to this vector.
	 */
	public function applyEuler( euler:Euler ) {
		return this.applyQuaternion( _quaternion.setFromEuler( euler ) );
	}

	/**
	 * Applies a rotation specified by an axis and an angle to this vector.
	 *
	 * @param axis A normalized vector representing the rotation axis.
	 * @param angle The angle in radians.
	 * @return A reference to this vector.
	 */
	public function applyAxisAngle( axis:Vector3, angle:Float ) {
		return this.applyQuaternion( _quaternion.setFromAxisAngle( axis, angle ) );
	}

	/**
	 * Multiplies this vector with the given 3x3 matrix.
	 *
	 * @param m The 3x3 matrix.
	 * @return A reference to this vector.
	 */
	public function applyMatrix3( m:Matrix3 ) {
		var x = this.x, y = this.y, z = this.z;
		var e = m.elements;

		this.x = e[ 0 ] * x + e[ 3 ] * y + e[ 6 ] * z;
		this.y = e[ 1 ] * x + e[ 4 ] * y + e[ 7 ] * z;
		this.z = e[ 2 ] * x + e[ 5 ] * y + e[ 8 ] * z;

		return this;
	}

	/**
	 * Multiplies this vector by the given normal matrix and normalizes
	 * the result.
	 *
	 * @param m The normal matrix.
	 * @return A reference to this vector.
	 */
	public inline function applyNormalMatrix( m:Matrix3 ) {
		return this.applyMatrix3( m ).normalize();
	}

	/**
	 * Multiplies this vector (with an implicit 1 in the 4th dimension) by m, and
	 * divides by perspective.
	 *
	 * @param m The matrix to apply.
	 * @return A reference to this vector.
	 */
	public function applyMatrix4( m:Matrix4 ) {
		var x = this.x, y = this.y, z = this.z;
		var e = m.elements;

		var w = 1 / ( e[ 3 ] * x + e[ 7 ] * y + e[ 11 ] * z + e[ 15 ] );

		this.x = ( e[ 0 ] * x + e[ 4 ] * y + e[ 8 ] * z + e[ 12 ] ) * w;
		this.y = ( e[ 1 ] * x + e[ 5 ] * y + e[ 9 ] * z + e[ 13 ] ) * w;
		this.z = ( e[ 2 ] * x + e[ 6 ] * y + e[ 10 ] * z + e[ 14 ] ) * w;

		return this;
	}

	/**
	 * Applies the given Quaternion to this vector.
	 *
	 * @param q The Quaternion.
	 * @return A reference to this vector.
	 */
	public function applyQuaternion( q:Quaternion ) {
		// quaternion q is assumed to have unit length

		var vx = this.x, vy = this.y, vz = this.z;
		var qx = q.x, qy = q.y, qz = q.z, qw = q.w;

		// t = 2 * cross( q.xyz, v );
		var tx = 2 * ( qy * vz - qz * vy );
		var ty = 2 * ( qz * vx - qx * vz );
		var tz = 2 * ( qx * vy - qy * vx );

		// v + q.w * t + cross( q.xyz, t );
		this.x = vx + qw * tx + qy * tz - qz * ty;
		this.y = vy + qw * ty + qz * tx - qx * tz;
		this.z = vz + qw * tz + qx * ty - qy * tx;

		return this;
	}

	/**
	 * Projects this vector from world space into the camera's normalized
	 * device coordinate (NDC) space.
	 *
	 * @param {Camera} camera - The camera.
	 * @return {Vector3} A reference to this vector.
	 */
	public function project( camera ) {
		return this.applyMatrix4( camera.matrixWorldInverse ).applyMatrix4( camera.projectionMatrix );
	}

	/**
	 * Unprojects this vector from the camera's normalized device coordinate (NDC)
	 * space into world space.
	 *
	 * @param {Camera} camera - The camera.
	 * @return {Vector3} A reference to this vector.
	 */
	public function unproject( camera ) {
		return this.applyMatrix4( camera.projectionMatrixInverse ).applyMatrix4( camera.matrixWorld );
	}

	/**
	 * Transforms the direction of this vector by a matrix (the upper left 3 x 3
	 * subset of the given 4x4 matrix and then normalizes the result.
	 *
	 * @param {Matrix4} m - The matrix.
	 * @return {Vector3} A reference to this vector.
	 */
	public function transformDirection( m:Matrix4 ) {
		// input: THREE.Matrix4 affine matrix
		// vector interpreted as a direction

		var x = this.x, y = this.y, z = this.z;
		var e = m.elements;

		this.x = e[ 0 ] * x + e[ 4 ] * y + e[ 8 ] * z;
		this.y = e[ 1 ] * x + e[ 5 ] * y + e[ 9 ] * z;
		this.z = e[ 2 ] * x + e[ 6 ] * y + e[ 10 ] * z;

		return this.normalize();
	}

	/**
	 * Divides this instance by the given vector.
	 *
	 * @param {Vector3} v - The vector to divide.
	 * @return {Vector3} A reference to this vector.
	 */
	public function divide( v ) {
		this.x /= v.x;
		this.y /= v.y;
		this.z /= v.z;

		return this;
	}

	/**
	 * Divides this vector by the given scalar.
	 *
	 * @param {number} scalar - The scalar to divide.
	 * @return {Vector3} A reference to this vector.
	 */
	public function divideScalar( scalar:Float ) {
		return this.multiplyScalar( 1 / scalar );
	}

	/**
	 * If this vector's x, y or z value is greater than the given vector's x, y or z
	 * value, replace that value with the corresponding min value.
	 *
	 * @param {Vector3} v - The vector.
	 * @return {Vector3} A reference to this vector.
	 */
	public function min( v ) {
		this.x = Math.min( this.x, v.x );
		this.y = Math.min( this.y, v.y );
		this.z = Math.min( this.z, v.z );

		return this;
	}

	/**
	 * If this vector's x, y or z value is less than the given vector's x, y or z
	 * value, replace that value with the corresponding max value.
	 *
	 * @param {Vector3} v - The vector.
	 * @return {Vector3} A reference to this vector.
	 */
	public function max( v ) {
		this.x = Math.max( this.x, v.x );
		this.y = Math.max( this.y, v.y );
		this.z = Math.max( this.z, v.z );

		return this;
	}

	/**
	 * If this vector's x, y or z value is greater than the max vector's x, y or z
	 * value, it is replaced by the corresponding value.
	 * If this vector's x, y or z value is less than the min vector's x, y or z value,
	 * it is replaced by the corresponding value.
	 *
	 * @param {Vector3} min - The minimum x, y and z values.
	 * @param {Vector3} max - The maximum x, y and z values in the desired range.
	 * @return {Vector3} A reference to this vector.
	 */
	public function clamp( min:Vector3, max:Vector3 ) {
		// assumes min < max, componentwise

		this.x = MathUtils.clamp( this.x, min.x, max.x );
		this.y = MathUtils.clamp( this.y, min.y, max.y );
		this.z = MathUtils.clamp( this.z, min.z, max.z );

		return this;
	}

	/**
	 * If this vector's x, y or z values are greater than the max value, they are
	 * replaced by the max value.
	 * If this vector's x, y or z values are less than the min value, they are
	 * replaced by the min value.
	 *
	 * @param {number} minVal - The minimum value the components will be clamped to.
	 * @param {number} maxVal - The maximum value the components will be clamped to.
	 * @return {Vector3} A reference to this vector.
	 */
	public function clampScalar( minVal, maxVal ) {
		this.x = MathUtils.clamp( this.x, minVal, maxVal );
		this.y = MathUtils.clamp( this.y, minVal, maxVal );
		this.z = MathUtils.clamp( this.z, minVal, maxVal );

		return this;
	}

	/**
	 * If this vector's length is greater than the max value, it is replaced by
	 * the max value.
	 * If this vector's length is less than the min value, it is replaced by the
	 * min value.
	 *
	 * @param {number} min - The minimum value the vector length will be clamped to.
	 * @param {number} max - The maximum value the vector length will be clamped to.
	 * @return {Vector3} A reference to this vector.
	 */
	public function clampLength( min, max ) {
		var length = this.length();

		return this.divideScalar( length != 0 ? length : 1 ).multiplyScalar( MathUtils.clamp( length, min, max ) );
	}

	/**
	 * The components of this vector are rounded down to the nearest integer value.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function floor() {
		this.x = Math.floor( this.x );
		this.y = Math.floor( this.y );
		this.z = Math.floor( this.z );

		return this;
	}

	/**
	 * The components of this vector are rounded up to the nearest integer value.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function ceil() {
		this.x = Math.ceil( this.x );
		this.y = Math.ceil( this.y );
		this.z = Math.ceil( this.z );

		return this;
	}

	/**
	 * The components of this vector are rounded to the nearest integer value
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function round() {
		this.x = Math.round( this.x );
		this.y = Math.round( this.y );
		this.z = Math.round( this.z );

		return this;
	}

	/**
	 * The components of this vector are rounded towards zero (up if negative,
	 * down if positive) to an integer value.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function roundToZero() {
		this.x = Common.trunc( this.x );
		this.y = Common.trunc( this.y );
		this.z = Common.trunc( this.z );

		return this;
	}

	/**
	 * Inverts this vector - i.e. sets x = -x, y = -y and z = -z.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function negate() {
		this.x = -this.x;
		this.y = -this.y;
		this.z = -this.z;

		return this;
	}

	/**
	 * Calculates the dot product of the given vector with this instance.
	 *
	 * @param {Vector3} v - The vector to compute the dot product with.
	 * @return {number} The result of the dot product.
	 */
	public function dot( v:Vector3 ) {
		return this.x * v.x + this.y * v.y + this.z * v.z;
	}

	// TODO lengthSquared?

	/**
	 * Computes the square of the Euclidean length (straight-line length) from
	 * (0, 0, 0) to (x, y, z). If you are comparing the lengths of vectors, you should
	 * compare the length squared instead as it is slightly more efficient to calculate.
	 *
	 * @return {number} The square length of this vector.
	 */
	public function lengthSq() {
		return this.x * this.x + this.y * this.y + this.z * this.z;
	}

	/**
	 * Computes the  Euclidean length (straight-line length) from (0, 0, 0) to (x, y, z).
	 *
	 * @return {number} The length of this vector.
	 */
	public function length() {
		return Math.sqrt( this.x * this.x + this.y * this.y + this.z * this.z );
	}

	/**
	 * Computes the Manhattan length of this vector.
	 *
	 * @return {number} The length of this vector.
	 */
	public inline function manhattanLength() {
		return Math.abs( this.x ) + Math.abs( this.y ) + Math.abs( this.z );
	}

	/**
	 * Converts this vector to a unit vector - that is, sets it equal to a vector
	 * with the same direction as this one, but with a vector length of `1`.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public inline function normalize() {
		return this.divideScalar( this.length() ?? 1 );
	}

	/**
	 * Sets this vector to a vector with the same direction as this one, but
	 * with the specified length.
	 *
	 * @param {number} length - The new length of this vector.
	 * @return {Vector3} A reference to this vector.
	 */
	public inline function setLength( length ) {
		return this.normalize().multiplyScalar( length );
	}

	/**
	 * Linearly interpolates between the given vector and this instance, where
	 * alpha is the percent distance along the line - alpha = 0 will be this
	 * vector, and alpha = 1 will be the given one.
	 *
	 * @param {Vector3} v - The vector to interpolate towards.
	 * @param {number} alpha - The interpolation factor, typically in the closed interval `[0, 1]`.
	 * @return {Vector3} A reference to this vector.
	 */
	public function lerp( v, alpha ) {
		this.x += ( v.x - this.x ) * alpha;
		this.y += ( v.y - this.y ) * alpha;
		this.z += ( v.z - this.z ) * alpha;

		return this;
	}

	/**
	 * Linearly interpolates between the given vectors, where alpha is the percent
	 * distance along the line - alpha = 0 will be first vector, and alpha = 1 will
	 * be the second one. The result is stored in this instance.
	 *
	 * @param {Vector3} v1 - The first vector.
	 * @param {Vector3} v2 - The second vector.
	 * @param {number} alpha - The interpolation factor, typically in the closed interval `[0, 1]`.
	 * @return {Vector3} A reference to this vector.
	 */
	public function lerpVectors( v1, v2, alpha ) {
		this.x = v1.x + ( v2.x - v1.x ) * alpha;
		this.y = v1.y + ( v2.y - v1.y ) * alpha;
		this.z = v1.z + ( v2.z - v1.z ) * alpha;

		return this;
	}

	/**
	 * Calculates the cross product of the given vector with this instance.
	 *
	 * @param {Vector3} v - The vector to compute the cross product with.
	 * @return {Vector3} The result of the cross product.
	 */
	public inline function cross( v:Vector3 ) {
		return this.crossVectors( this, v );
	}

	/**
	 * Calculates the cross product of the given vectors and stores the result
	 * in this instance.
	 *
	 * @param {Vector3} a - The first vector.
	 * @param {Vector3} b - The second vector.
	 * @return {Vector3} A reference to this vector.
	 */
	public function crossVectors( a:Vector3, b:Vector3 ) {
		var ax = a.x, ay = a.y, az = a.z;
		var bx = b.x, by = b.y, bz = b.z;

		this.x = ay * bz - az * by;
		this.y = az * bx - ax * bz;
		this.z = ax * by - ay * bx;

		return this;
	}

	/**
	 * Projects this vector onto the given one.
	 *
	 * @param {Vector3} v - The vector to project to.
	 * @return {Vector3} A reference to this vector.
	 */
	public function projectOnVector( v:Vector3 ) {
		var denominator = v.lengthSq();

		if ( denominator == 0 ) return this.set( 0, 0, 0 );

		var scalar = v.dot( this ) / denominator;

		return this.copy( v ).multiplyScalar( scalar );
	}

	/**
	 * Projects this vector onto a plane by subtracting this
	 * vector projected onto the plane's normal from this vector.
	 *
	 * @param {Vector3} planeNormal - The plane normal.
	 * @return {Vector3} A reference to this vector.
	 */
	public function projectOnPlane( planeNormal:Vector3 ) {
		_vector.copy( this ).projectOnVector( planeNormal );

		return this.sub( _vector );
	}

	/**
	 * Reflects this vector off a plane orthogonal to the given normal vector.
	 *
	 * @param {Vector3} normal - The (normalized) normal vector.
	 * @return {Vector3} A reference to this vector.
	 */
	public function reflect( normal:Vector3 ) {
		return this.sub( _vector.copy( normal ).multiplyScalar( 2 * this.dot( normal ) ) );
	}
	/**
	 * Returns the angle between the given vector and this instance in radians.
	 *
	 * @param {Vector3} v - The vector to compute the angle with.
	 * @return {number} The angle in radians.
	 */
	public function angleTo( v:Vector3 ) {
		var denominator = Math.sqrt( this.lengthSq() * v.lengthSq() );

		if ( denominator == 0 ) return Math.PI / 2;

		var theta = this.dot( v ) / denominator;

		// clamp, to handle numerical problems

		return Math.acos( MathUtils.clamp( theta, - 1, 1 ) );
	}

	/**
	 * Computes the distance from the given vector to this instance.
	 *
	 * @param {Vector3} v - The vector to compute the distance to.
	 * @return {number} The distance.
	 */
	public inline function distanceTo( v:Vector3 ) {
		return Math.sqrt( this.distanceToSquared( v ) );
	}

	/**
	 * Computes the squared distance from the given vector to this instance.
	 * If you are just comparing the distance with another distance, you should compare
	 * the distance squared instead as it is slightly more efficient to calculate.
	 *
	 * @param {Vector3} v - The vector to compute the squared distance to.
	 * @return {number} The squared distance.
	 */
	public function distanceToSquared( v:Vector3 ):Float {
		var dx = this.x - v.x, dy = this.y - v.y, dz = this.z - v.z;

		return dx * dx + dy * dy + dz * dz;
	}

	/**
	 * Computes the Manhattan distance from the given vector to this instance.
	 *
	 * @param {Vector3} v - The vector to compute the Manhattan distance to.
	 * @return {number} The Manhattan distance.
	 */
	public inline function manhattanDistanceTo( v:Vector3 ) {
		return Math.abs( this.x - v.x ) + Math.abs( this.y - v.y ) + Math.abs( this.z - v.z );
	}

	/**
	 * Sets the vector components from the given spherical coordinates.
	 *
	 * @param {Spherical} s - The spherical coordinates.
	 * @return {Vector3} A reference to this vector.
	 */
	public inline function setFromSpherical( s ) {
		return this.setFromSphericalCoords( s.radius, s.phi, s.theta );
	}

	/**
	 * Sets the vector components from the given spherical coordinates.
	 *
	 * @param {number} radius - The radius.
	 * @param {number} phi - The phi angle in radians.
	 * @param {number} theta - The theta angle in radians.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromSphericalCoords( radius:Float, phi:Float, theta:Float ) {
		var sinPhiRadius = Math.sin( phi ) * radius;

		this.x = sinPhiRadius * Math.sin( theta );
		this.y = Math.cos( phi ) * radius;
		this.z = sinPhiRadius * Math.cos( theta );

		return this;
	}

	/**
	 * Sets the vector components from the given cylindrical coordinates.
	 *
	 * @param {Cylindrical} c - The cylindrical coordinates.
	 * @return {Vector3} A reference to this vector.
	 */
	public inline function setFromCylindrical( c ) {
		return this.setFromCylindricalCoords( c.radius, c.theta, c.y );
	}

	/**
	 * Sets the vector components from the given cylindrical coordinates.
	 *
	 * @param {number} radius - The radius.
	 * @param {number} theta - The theta angle in radians.
	 * @param {number} y - The y value.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromCylindricalCoords( radius:Float, theta:Float, y:Float ) {
		this.x = radius * Math.sin( theta );
		this.y = y;
		this.z = radius * Math.cos( theta );

		return this;
	}

	/**
	 * Sets the vector components to the position elements of the
	 * given transformation matrix.
	 *
	 * @param {Matrix4} m - The 4x4 matrix.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromMatrixPosition( m:Matrix4 ) {
		return set(m.elements[12], m.elements[13], m.elements[14]);
	}

	/**
	 * Sets the vector components to the scale elements of the
	 * given transformation matrix.
	 *
	 * @param {Matrix4} m - The 4x4 matrix.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromMatrixScale( m ) {
		var sx = this.setFromMatrixColumn( m, 0 ).length();
		var sy = this.setFromMatrixColumn( m, 1 ).length();
		var sz = this.setFromMatrixColumn( m, 2 ).length();

		this.x = sx;
		this.y = sy;
		this.z = sz;

		return this;
	}

	/**
	 * Sets the vector components from the specified matrix column.
	 *
	 * @param {Matrix4} m - The 4x4 matrix.
	 * @param {number} index - The column index.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromMatrixColumn( m, index ) {

		return this.fromArray( m.elements, index * 4 );

	}

	/**
	 * Sets the vector components from the specified matrix column.
	 *
	 * @param {Matrix3} m - The 3x3 matrix.
	 * @param {number} index - The column index.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromMatrix3Column( m, index ) {
		return this.fromArray( m.elements, index * 3 );
	}

	/**
	 * Sets the vector components from the given Euler angles.
	 *
	 * @param {Euler} e - The Euler angles to set.
	 * @return {Vector3} A reference to this vector.
	 */
	public inline function setFromEuler( e ) {
        return set(e._x, e._y, e._z);
	}

	/**
	 * Sets the vector components from the RGB components of the
	 * given color.
	 *
	 * @param {Color} c - The color to set.
	 * @return {Vector3} A reference to this vector.
	 */
	public function setFromColor( c ) {
		this.x = c.r;
		this.y = c.g;
		this.z = c.b;

		return this;
	}

	/**
	 * Returns `true` if this vector is equal with the given one.
	 *
	 * @param {Vector3} v - The vector to test for equality.
	 * @return {boolean} Whether this vector is equal with the given one.
	 */
	public inline function equals( v ) {
		return ( ( v.x == this.x ) && ( v.y == this.y ) && ( v.z == this.z ) );
	}

	/**
	 * Sets this vector's x value to be `array[ offset ]`, y value to be `array[ offset + 1 ]`
	 * and z value to be `array[ offset + 2 ]`.
	 *
	 * @param {Array<number>} array - An array holding the vector component values.
	 * @param {number} [offset=0] - The offset into the array.
	 * @return {Vector3} A reference to this vector.
	 */
	public function fromArray( array, offset = 0 ) {
		this.x = array[ offset ];
		this.y = array[ offset + 1 ];
		this.z = array[ offset + 2 ];

		return this;
	}

	/**
	 * Writes the components of this vector to the given array. If no array is provided,
	 * the method returns a new instance.
	 *
	 * @param {Array<number>} [array=[]] - The target array holding the vector components.
	 * @param {number} [offset=0] - Index of the first element in the array.
	 * @return {Array<number>} The vector components.
	 */
	public function toArray( ?array, offset = 0 ) {
		if (array == null)
			array = [];
		array[ offset ] = this.x;
		array[ offset + 1 ] = this.y;
		array[ offset + 2 ] = this.z;

		return array;
	}

	/**
	 * Sets the components of this vector from the given buffer attribute.
	 *
	 * @param {BufferAttribute} attribute - The buffer attribute holding vector data.
	 * @param {number} index - The index into the attribute.
	 * @return {Vector3} A reference to this vector.
	 */
	public function fromBufferAttribute( attribute:BufferAttribute, index:Int ) {
		this.x = attribute.getX( index );
		this.y = attribute.getY( index );
		this.z = attribute.getZ( index );

		return this;
	}

	/**
	 * Sets each component of this vector to a pseudo-random value between `0` and
	 * `1`, excluding `1`.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function random() {
		this.x = Math.random();
		this.y = Math.random();
		this.z = Math.random();

		return this;
	}

	/**
	 * Sets this vector to a uniformly random point on a unit sphere.
	 *
	 * @return {Vector3} A reference to this vector.
	 */
	public function randomDirection() {
		// https://mathworld.wolfram.com/SpherePointPicking.html

		var theta = Math.random() * Math.PI * 2;
		var u = Math.random() * 2 - 1;
		var c = Math.sqrt( 1 - u * u );

		this.x = c * Math.cos( theta );
		this.y = u;
		this.z = c * Math.sin( theta );

		return this;
	}

    public function iterator() {
        return [this.x, this.y, this.z].iterator();
    }

    static var _vector = new Vector3();
    static var _quaternion = new Quaternion();
}