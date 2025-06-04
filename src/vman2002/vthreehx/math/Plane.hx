package vman2002.vthreehx.math;

import vman2002.vthreehx.math.Matrix3;
import vman2002.vthreehx.math.Vector3;


/**
 * A two dimensional surface that extends infinitely in 3D space, represented
 * in [Hessian normal form]{@link http://mathworld.wolfram.com/HessianNormalForm.html}
 * by a unit length normal vector and a constant.
 */
class Plane {

		/**
		 * A unit length vector defining the normal of the plane.
		 *
		 * @type {Vector3}
		 */
		public var normal:Vector3;

		/**
		 * The signed distance from the origin to the plane.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var constant:Float;

	/**
	 * Constructs a new plane.
	 *
	 * @param {Vector3} [normal=(1,0,0)] - A unit length vector defining the normal of the plane.
	 * @param {number} [constant=0] - The signed distance from the origin to the plane.
	 */
	public function new( ?normal:Vector3, ?constant = 0 ) {
        this.normal = normal ?? new Vector3(1,0,0);
        this.constant = constant;
	}

	/**
	 * Sets the plane components by copying the given values.
	 *
	 * @param {Vector3} normal - The normal.
	 * @param {number} constant - The constant.
	 * @return {Plane} A reference to this plane.
	 */
	public function set( normal, constant ) {

		this.normal.copy( normal );
		this.constant = constant;

		return this;

	}

	/**
	 * Sets the plane components by defining `x`, `y`, `z` as the
	 * plane normal and `w` as the constant.
	 *
	 * @param {number} x - The value for the normal's x component.
	 * @param {number} y - The value for the normal's y component.
	 * @param {number} z - The value for the normal's z component.
	 * @param {number} w - The constant value.
	 * @return {Plane} A reference to this plane.
	 */
	public function setComponents( x, y, z, w ) {

		this.normal.set( x, y, z );
		this.constant = w;

		return this;

	}

	/**
	 * Sets the plane from the given normal and coplanar point (that is a point
	 * that lies onto the plane).
	 *
	 * @param {Vector3} normal - The normal.
	 * @param {Vector3} point - A coplanar point.
	 * @return {Plane} A reference to this plane.
	 */
	public function setFromNormalAndCoplanarPoint( normal:Vector3, point:Vector3 ) {

		this.normal.copy( normal );
		this.constant = - point.dot( this.normal );

		return this;

	}

	/**
	 * Sets the plane from three coplanar points. The winding order is
	 * assumed to be counter-clockwise, and determines the direction of
	 * the plane normal.
	 *
	 * @param {Vector3} a - The first coplanar point.
	 * @param {Vector3} b - The second coplanar point.
	 * @param {Vector3} c - The third coplanar point.
	 * @return {Plane} A reference to this plane.
	 */
	public function setFromCoplanarPoints( a:Vector3, b:Vector3, c:Vector3 ) {

		var normal = _vector1.subVectors( c, b ).cross( _vector2.subVectors( a, b ) ).normalize();

		// Q: should an error be thrown if normal is zero (e.g. degenerate plane)?

		this.setFromNormalAndCoplanarPoint( normal, a );

		return this;

	}

	/**
	 * Copies the values of the given plane to this instance.
	 *
	 * @param {Plane} plane - The plane to copy.
	 * @return {Plane} A reference to this plane.
	 */
	public function copy( plane ) {

		this.normal.copy( plane.normal );
		this.constant = plane.constant;

		return this;

	}

	/**
	 * Normalizes the plane normal and adjusts the constant accordingly.
	 *
	 * @return {Plane} A reference to this plane.
	 */
	public function normalize() {

		// Note: will lead to a divide by zero if the plane is invalid.

		var inverseNormalLength = 1.0 / this.normal.length();
		this.normal.multiplyScalar( inverseNormalLength );
		this.constant *= inverseNormalLength;

		return this;

	}

	/**
	 * Negates both the plane normal and the constant.
	 *
	 * @return {Plane} A reference to this plane.
	 */
	public function negate() {

		this.constant *= - 1;
		this.normal.negate();

		return this;

	}

	/**
	 * Returns the signed distance from the given point to this plane.
	 *
	 * @param {Vector3} point - The point to compute the distance for.
	 * @return {number} The signed distance.
	 */
	public function distanceToPoint( point ) {

		return this.normal.dot( point ) + this.constant;

	}

	/**
	 * Returns the signed distance from the given sphere to this plane.
	 *
	 * @param {Sphere} sphere - The sphere to compute the distance for.
	 * @return {number} The signed distance.
	 */
	public function distanceToSphere( sphere ) {

		return this.distanceToPoint( sphere.center ) - sphere.radius;

	}

	/**
	 * Projects a the given point onto the plane.
	 *
	 * @param {Vector3} point - The point to project.
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} The projected point on the plane.
	 */
	public function projectPoint( point, target ) {

		return target.copy( point ).addScaledVector( this.normal, - this.distanceToPoint( point ) );

	}

	/**
	 * Returns the intersection point of the passed line and the plane. Returns
	 * `null` if the line does not intersect. Returns the line's starting point if
	 * the line is coplanar with the plane.
	 *
	 * @param {Line3} line - The line to compute the intersection for.
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {?Vector3} The intersection point.
	 */
	public function intersectLine( line, target:Vector3 ):Null<Vector3> {

		var direction = line.delta( _vector1 );

		var denominator = this.normal.dot( direction );

		if ( denominator == 0 ) {

			// line is coplanar, return origin
			if ( this.distanceToPoint( line.start ) == 0 ) {

				return target.copy( line.start );

			}

			// Unsure if this is the correct method to handle this case.
			return null;

		}

		var t = - ( line.start.dot( this.normal ) + this.constant ) / denominator;

		if ( t < 0 || t > 1 ) {

			return null;

		}

		return target.copy( line.start ).addScaledVector( direction, t );

	}

	/**
	 * Returns `true` if the given line segment intersects with (passes through) the plane.
	 *
	 * @param {Line3} line - The line to test.
	 * @return {boolean} Whether the given line segment intersects with the plane or not.
	 */
	public function intersectsLine( line ) {

		// Note: this tests if a line intersects the plane, not whether it (or its end-points) are coplanar with it.

		var startSign = this.distanceToPoint( line.start );
		var endSign = this.distanceToPoint( line.end );

		return ( startSign < 0 && endSign > 0 ) || ( endSign < 0 && startSign > 0 );

	}

	/**
	 * Returns `true` if the given bounding box intersects with the plane.
	 *
	 * @param {Box3} box - The bounding box to test.
	 * @return {boolean} Whether the given bounding box intersects with the plane or not.
	 */
	public function intersectsBox( box ) {

		return box.intersectsPlane( this );

	}

	/**
	 * Returns `true` if the given bounding sphere intersects with the plane.
	 *
	 * @param {Sphere} sphere - The bounding sphere to test.
	 * @return {boolean} Whether the given bounding sphere intersects with the plane or not.
	 */
	public function intersectsSphere( sphere ) {

		return sphere.intersectsPlane( this );

	}

	/**
	 * Returns a coplanar vector to the plane, by calculating the
	 * projection of the normal at the origin onto the plane.
	 *
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} The coplanar point.
	 */
	public function coplanarPoint( target ) {

		return target.copy( this.normal ).multiplyScalar( - this.constant );

	}

	/**
	 * Apply a 4x4 matrix to the plane. The matrix must be an affine, homogeneous transform.
	 *
	 * The optional normal matrix can be pre-computed like so:
	 * ```js
	 * var optionalNormalMatrix = new THREE.Matrix3().getNormalMatrix( matrix );
	 * ```
	 *
	 * @param {Matrix4} matrix - The transformation matrix.
	 * @param {Matrix3} [optionalNormalMatrix] - A pre-computed normal matrix.
	 * @return {Plane} A reference to this plane.
	 */
	public function applyMatrix4( matrix:Matrix4, optionalNormalMatrix:Matrix3 ) {

		var normalMatrix = optionalNormalMatrix ?? _normalMatrix.getNormalMatrix( matrix );

		var referencePoint = this.coplanarPoint( _vector1 ).applyMatrix4( matrix );

		var normal = this.normal.applyMatrix3( normalMatrix ).normalize();

		this.constant = -referencePoint.dot( normal );

		return this;

	}

	/**
	 * Translates the plane by the distance defined by the given offset vector.
	 * Note that this only affects the plane constant and will not affect the normal vector.
	 *
	 * @param {Vector3} offset - The offset vector.
	 * @return {Plane} A reference to this plane.
	 */
	public function translate( offset ) {

		this.constant -= offset.dot( this.normal );

		return this;

	}

	/**
	 * Returns `true` if this plane is equal with the given one.
	 *
	 * @param {Plane} plane - The plane to test for equality.
	 * @return {boolean} Whether this plane is equal with the given one.
	 */
	public function equals( plane ) {

		return plane.normal.equals( this.normal ) && ( plane.constant == this.constant );

	}

	/**
	 * Returns a new plane with copied values from this instance.
	 *
	 * @return {Plane} A clone of this instance.
	 */
	public function clone() {

		return new Plane().copy( this );

	}

static var _vector1 = /*@__PURE__*/ new Vector3();
static var _vector2 = /*@__PURE__*/ new Vector3();
static var _normalMatrix = /*@__PURE__*/ new Matrix3();
}