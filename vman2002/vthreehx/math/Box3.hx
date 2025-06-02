package vman2002.vthreehx.math;

import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.core.Object3D;

/**
 * Represents an axis-aligned bounding box (AABB) in 3D space.
 */
class Box3 {

    /**
    * The lower boundary of the box.
    *
    * @type {Vector3}
    */
    public var min:Vector3;

    /**
    * The upper boundary of the box.
    *
    * @type {Vector3}
    */
    public var max:Vector3;

	/**
	 * Constructs a new bounding box.
	 *
	 * @param {Vector3} [min=(Infinity,Infinity,Infinity)] - A vector representing the lower boundary of the box.
	 * @param {Vector3} [max=(-Infinity,-Infinity,-Infinity)] - A vector representing the upper boundary of the box.
	 */
	public function new( ?min:Vector3, ?max:Vector3 ) {

        this.min = min ?? new Vector3( Infinity, Infinity, Infinity );
        this.max = max ?? new Vector3( -Infinity, -Infinity, -Infinity );

	}

	/**
	 * Sets the lower and upper boundaries of this box.
	 * Please note that this method only copies the values from the given objects.
	 *
	 * @param {Vector3} min - The lower boundary of the box.
	 * @param {Vector3} max - The upper boundary of the box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function set( min, max ) {

		this.min.copy( min );
		this.max.copy( max );

		return this;

	}

	/**
	 * Sets the upper and lower bounds of this box so it encloses the position data
	 * in the given array.
	 *
	 * @param {Array<number>} array - An array holding 3D position data.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function setFromArray( array ) {

		this.makeEmpty();

        var i = 0, il = array.length;
		while ( i < il ) {
			this.expandByPoint( _vector.fromArray( array, i ) );
            i += 3;
		}

		return this;

	}

	/**
	 * Sets the upper and lower bounds of this box so it encloses the position data
	 * in the given buffer attribute.
	 *
	 * @param {BufferAttribute} attribute - A buffer attribute holding 3D position data.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function setFromBufferAttribute( attribute ) {

		this.makeEmpty();

		for ( i in 0...attribute.count ) {

			this.expandByPoint( _vector.fromBufferAttribute( attribute, i ) );

		}

		return this;

	}

	/**
	 * Sets the upper and lower bounds of this box so it encloses the position data
	 * in the given array.
	 *
	 * @param {Array<Vector3>} points - An array holding 3D position data as instances of {@link Vector3}.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function setFromPoints( points:Array<Vector3> ) {

		this.makeEmpty();

		for ( i in 0...points.length ) {

			this.expandByPoint( points[ i ] );

		}

		return this;

	}

	/**
	 * Centers this box on the given center vector and sets this box's width, height and
	 * depth to the given size values.
	 *
	 * @param {Vector3} center - The center of the box.
	 * @param {Vector3} size - The x, y and z dimensions of the box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function setFromCenterAndSize( center:Vector3, size:Vector3 ) {

		var halfSize = _vector.copy( size ).multiplyScalar( 0.5 );

		this.min.copy( center ).sub( halfSize );
		this.max.copy( center ).add( halfSize );

		return this;

	}

	/**
	 * Computes the world-axis-aligned bounding box for the given 3D object
	 * (including its children), accounting for the object's, and children's,
	 * world transforms. The function may result in a larger box than strictly necessary.
	 *
	 * @param {Object3D} object - The 3D object to compute the bounding box for.
	 * @param {boolean} [precise=false] - If set to `true`, the method computes the smallest
	 * world-axis-aligned bounding box at the expense of more computation.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function setFromObject( object:Object3D, precise = false ) {

		this.makeEmpty();

		return this.expandByObject( object, precise );

	}

	/**
	 * Returns a new box with copied values from this instance.
	 *
	 * @return {Box3} A clone of this instance.
	 */
	public function clone() {

		return new Box3(this.min.clone(), this.max.clone());

	}

	/**
	 * Copies the values of the given box to this instance.
	 *
	 * @param {Box3} box - The box to copy.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function copy( box ) {

		this.min.copy( box.min );
		this.max.copy( box.max );

		return this;

	}

	/**
	 * Makes this box empty which means in encloses a zero space in 3D.
	 *
	 * @return {Box3} A reference to this bounding box.
	 */
	public function makeEmpty() {

		this.min.x = this.min.y = this.min.z = Infinity;
		this.max.x = this.max.y = this.max.z = - Infinity;

		return this;

	}

	/**
	 * Returns true if this box includes zero points within its bounds.
	 * Note that a box with equal lower and upper bounds still includes one
	 * point, the one both bounds share.
	 *
	 * @return {boolean} Whether this box is empty or not.
	 */
	public function isEmpty() {

		// this is a more robust check for empty than ( volume <= 0 ) because volume can get positive with two negative axes

		return ( this.max.x < this.min.x ) || ( this.max.y < this.min.y ) || ( this.max.z < this.min.z );

	}

	/**
	 * Returns the center point of this box.
	 *
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} The center point.
	 */
	public function getCenter( target ) {

		return this.isEmpty() ? target.set( 0, 0, 0 ) : target.addVectors( this.min, this.max ).multiplyScalar( 0.5 );

	}

	/**
	 * Returns the dimensions of this box.
	 *
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} The size.
	 */
	public function getSize( target ) {

		return this.isEmpty() ? target.set( 0, 0, 0 ) : target.subVectors( this.max, this.min );

	}

	/**
	 * Expands the boundaries of this box to include the given point.
	 *
	 * @param {Vector3} point - The point that should be included by the bounding box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function expandByPoint( point ) {

		this.min.min( point );
		this.max.max( point );

		return this;

	}

	/**
	 * Expands this box equilaterally by the given vector. The width of this
	 * box will be expanded by the x component of the vector in both
	 * directions. The height of this box will be expanded by the y component of
	 * the vector in both directions. The depth of this box will be
	 * expanded by the z component of the vector in both directions.
	 *
	 * @param {Vector3} vector - The vector that should expand the bounding box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function expandByVector( vector ) {

		this.min.sub( vector );
		this.max.add( vector );

		return this;

	}

	/**
	 * Expands each dimension of the box by the given scalar. If negative, the
	 * dimensions of the box will be contracted.
	 *
	 * @param {number} scalar - The scalar value that should expand the bounding box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function expandByScalar( scalar ) {

		this.min.addScalar( - scalar );
		this.max.addScalar( scalar );

		return this;

	}

	/**
	 * Expands the boundaries of this box to include the given 3D object and
	 * its children, accounting for the object's, and children's, world
	 * transforms. The function may result in a larger box than strictly
	 * necessary (unless the precise parameter is set to true).
	 *
	 * @param {Object3D} object - The 3D object that should expand the bounding box.
	 * @param {boolean} precise - If set to `true`, the method expands the bounding box
	 * as little as necessary at the expense of more computation.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function expandByObject( object:Object3D, precise = false ) {

		// Computes the world-axis-aligned bounding box of an object (including its children),
		// accounting for both the object's, and children's, world transforms

		object.updateWorldMatrix( false, false );

		if ( Reflect.hasField(object, "geometry") ) { //TODO: mesh handling
            var geometry = Reflect.field(object, "geometry");

			var positionAttribute = geometry.getAttribute( 'position' );

			// precise AABB computation based on vertex data requires at least a position attribute.
			// instancing isn't supported so far and uses the normal (conservative) code path.

			if ( precise && positionAttribute != null ) { //TODO: ensure object isn't InstancedMesh

				for ( i in 0...positionAttribute.count ) {

					if ( Std.downcast(object, Mesh) != null  ) {//TODO: isMesh

						object.getVertexPosition( i, _vector );

					} else {

						_vector.fromBufferAttribute( positionAttribute, i );

					}

					_vector.applyMatrix4( object.matrixWorld );
					this.expandByPoint( _vector );

				}

			} else {

				if ( object.boundingBox != null ) {

					// object-level bounding box

					if ( object.boundingBox == null ) {

						object.computeBoundingBox();

					}

					_box.copy( object.boundingBox );


				} else {

					// geometry-level bounding box

					if ( geometry.boundingBox == null ) {

						geometry.computeBoundingBox();

					}

					_box.copy( geometry.boundingBox );

				}

				_box.applyMatrix4( object.matrixWorld );

				this.union( _box );

			}

		}

		var children = object.children;

		for ( i in 0...children.length ) {

			this.expandByObject( children[ i ], precise );

		}

		return this;

	}

	/**
	 * Returns `true` if the given point lies within or on the boundaries of this box.
	 *
	 * @param {Vector3} point - The point to test.
	 * @return {boolean} Whether the bounding box contains the given point or not.
	 */
	public function containsPoint( point ) {

		return point.x >= this.min.x && point.x <= this.max.x &&
			point.y >= this.min.y && point.y <= this.max.y &&
			point.z >= this.min.z && point.z <= this.max.z;

	}

	/**
	 * Returns `true` if this bounding box includes the entirety of the given bounding box.
	 * If this box and the given one are identical, this function also returns `true`.
	 *
	 * @param {Box3} box - The bounding box to test.
	 * @return {boolean} Whether the bounding box contains the given bounding box or not.
	 */
	public function containsBox( box ) {

		return this.min.x <= box.min.x && box.max.x <= this.max.x &&
			this.min.y <= box.min.y && box.max.y <= this.max.y &&
			this.min.z <= box.min.z && box.max.z <= this.max.z;

	}

	/**
	 * Returns a point as a proportion of this box's width, height and depth.
	 *
	 * @param {Vector3} point - A point in 3D space.
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} A point as a proportion of this box's width, height and depth.
	 */
	public function getParameter( point, target ) {

		// This can potentially have a divide by zero if the box
		// has a size dimension of 0.

		return target.set(
			( point.x - this.min.x ) / ( this.max.x - this.min.x ),
			( point.y - this.min.y ) / ( this.max.y - this.min.y ),
			( point.z - this.min.z ) / ( this.max.z - this.min.z )
		);

	}

	/**
	 * Returns `true` if the given bounding box intersects with this bounding box.
	 *
	 * @param {Box3} box - The bounding box to test.
	 * @return {boolean} Whether the given bounding box intersects with this bounding box.
	 */
	public function intersectsBox( box ) {

		// using 6 splitting planes to rule out intersections.
		return box.max.x >= this.min.x && box.min.x <= this.max.x &&
			box.max.y >= this.min.y && box.min.y <= this.max.y &&
			box.max.z >= this.min.z && box.min.z <= this.max.z;

	}

	/**
	 * Returns `true` if the given bounding sphere intersects with this bounding box.
	 *
	 * @param {Sphere} sphere - The bounding sphere to test.
	 * @return {boolean} Whether the given bounding sphere intersects with this bounding box.
	 */
	public function intersectsSphere( sphere ) {

		// Find the point on the AABB closest to the sphere center.
		this.clampPoint( sphere.center, _vector );

		// If that point is inside the sphere, the AABB and sphere intersect.
		return _vector.distanceToSquared( sphere.center ) <= ( sphere.radius * sphere.radius );

	}

	/**
	 * Returns `true` if the given plane intersects with this bounding box.
	 *
	 * @param {Plane} plane - The plane to test.
	 * @return {boolean} Whether the given plane intersects with this bounding box.
	 */
	public function intersectsPlane( plane ) {

		// We compute the minimum and maximum dot product values. If those values
		// are on the same side (back or front) of the plane, then there is no intersection.

		var min, max;

		if ( plane.normal.x > 0 ) {

			min = plane.normal.x * this.min.x;
			max = plane.normal.x * this.max.x;

		} else {

			min = plane.normal.x * this.max.x;
			max = plane.normal.x * this.min.x;

		}

		if ( plane.normal.y > 0 ) {

			min += plane.normal.y * this.min.y;
			max += plane.normal.y * this.max.y;

		} else {

			min += plane.normal.y * this.max.y;
			max += plane.normal.y * this.min.y;

		}

		if ( plane.normal.z > 0 ) {

			min += plane.normal.z * this.min.z;
			max += plane.normal.z * this.max.z;

		} else {

			min += plane.normal.z * this.max.z;
			max += plane.normal.z * this.min.z;

		}

		return ( min <= - plane.constant && max >= - plane.constant );

	}

	/**
	 * Returns `true` if the given triangle intersects with this bounding box.
	 *
	 * @param {Triangle} triangle - The triangle to test.
	 * @return {boolean} Whether the given triangle intersects with this bounding box.
	 */
	public function intersectsTriangle( triangle ) {

		if ( this.isEmpty() ) {

			return false;

		}

		// compute box center and extents
		this.getCenter( _center );
		_extents.subVectors( this.max, _center );

		// translate triangle to aabb origin
		_v0.subVectors( triangle.a, _center );
		_v1.subVectors( triangle.b, _center );
		_v2.subVectors( triangle.c, _center );

		// compute edge vectors for triangle
		_f0.subVectors( _v1, _v0 );
		_f1.subVectors( _v2, _v1 );
		_f2.subVectors( _v0, _v2 );

		// test against axes that are given by cross product combinations of the edges of the triangle and the edges of the aabb
		// make an axis testing of each of the 3 sides of the aabb against each of the 3 sides of the triangle = 9 axis of separation
		// axis_ij = u_i x f_j (u0, u1, u2 = face normals of aabb = x,y,z axes vectors since aabb is axis aligned)
		var axes = [
			0, - _f0.z, _f0.y, 0, - _f1.z, _f1.y, 0, - _f2.z, _f2.y,
			_f0.z, 0, - _f0.x, _f1.z, 0, - _f1.x, _f2.z, 0, - _f2.x,
			- _f0.y, _f0.x, 0, - _f1.y, _f1.x, 0, - _f2.y, _f2.x, 0
		];
		if ( ! satForAxes( axes, _v0, _v1, _v2, _extents ) ) {

			return false;

		}

		// test 3 face normals from the aabb
		axes = [ 1, 0, 0, 0, 1, 0, 0, 0, 1 ];
		if ( ! satForAxes( axes, _v0, _v1, _v2, _extents ) ) {

			return false;

		}

		// finally testing the face normal of the triangle
		// use already existing triangle edge vectors here
		_triangleNormal.crossVectors( _f0, _f1 );
		axes = [ _triangleNormal.x, _triangleNormal.y, _triangleNormal.z ];

		return satForAxes( axes, _v0, _v1, _v2, _extents );

	}

	/**
	 * Clamps the given point within the bounds of this box.
	 *
	 * @param {Vector3} point - The point to clamp.
	 * @param {Vector3} target - The target vector that is used to store the method's result.
	 * @return {Vector3} The clamped point.
	 */
	public function clampPoint( point, target ) {

		return target.copy( point ).clamp( this.min, this.max );

	}

	/**
	 * Returns the euclidean distance from any edge of this box to the specified point. If
	 * the given point lies inside of this box, the distance will be `0`.
	 *
	 * @param {Vector3} point - The point to compute the distance to.
	 * @return {number} The euclidean distance.
	 */
	public function distanceToPoint( point ) {

		return this.clampPoint( point, _vector ).distanceTo( point );

	}

	/**
	 * Returns a bounding sphere that encloses this bounding box.
	 *
	 * @param {Sphere} target - The target sphere that is used to store the method's result.
	 * @return {Sphere} The bounding sphere that encloses this bounding box.
	 */
	public function getBoundingSphere( target ) {

		if ( this.isEmpty() ) {

			target.makeEmpty();

		} else {

			this.getCenter( target.center );

			target.radius = this.getSize( _vector ).length() * 0.5;

		}

		return target;

	}

	/**
	 * Computes the intersection of this bounding box and the given one, setting the upper
	 * bound of this box to the lesser of the two boxes' upper bounds and the
	 * lower bound of this box to the greater of the two boxes' lower bounds. If
	 * there's no overlap, makes this box empty.
	 *
	 * @param {Box3} box - The bounding box to intersect with.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function intersect( box ) {

		this.min.max( box.min );
		this.max.min( box.max );

		// ensure that if there is no overlap, the result is fully empty, not slightly empty with non-inf/+inf values that will cause subsequence intersects to erroneously return valid values.
		if ( this.isEmpty() ) this.makeEmpty();

		return this;

	}

	/**
	 * Computes the union of this box and another and the given one, setting the upper
	 * bound of this box to the greater of the two boxes' upper bounds and the
	 * lower bound of this box to the lesser of the two boxes' lower bounds.
	 *
	 * @param {Box3} box - The bounding box that will be unioned with this instance.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function union( box ) {

		this.min.min( box.min );
		this.max.max( box.max );

		return this;

	}

	/**
	 * Transforms this bounding box by the given 4x4 transformation matrix.
	 *
	 * @param {Matrix4} matrix - The transformation matrix.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function applyMatrix4( matrix ) {

		// transform of empty box is an empty box.
		if ( this.isEmpty() ) return this;

		// NOTE: I am using a binary pattern to specify all 2^3 combinations below
		_points[ 0 ].set( this.min.x, this.min.y, this.min.z ).applyMatrix4( matrix ); // 000
		_points[ 1 ].set( this.min.x, this.min.y, this.max.z ).applyMatrix4( matrix ); // 001
		_points[ 2 ].set( this.min.x, this.max.y, this.min.z ).applyMatrix4( matrix ); // 010
		_points[ 3 ].set( this.min.x, this.max.y, this.max.z ).applyMatrix4( matrix ); // 011
		_points[ 4 ].set( this.max.x, this.min.y, this.min.z ).applyMatrix4( matrix ); // 100
		_points[ 5 ].set( this.max.x, this.min.y, this.max.z ).applyMatrix4( matrix ); // 101
		_points[ 6 ].set( this.max.x, this.max.y, this.min.z ).applyMatrix4( matrix ); // 110
		_points[ 7 ].set( this.max.x, this.max.y, this.max.z ).applyMatrix4( matrix ); // 111

		this.setFromPoints( _points );

		return this;

	}

	/**
	 * Adds the given offset to both the upper and lower bounds of this bounding box,
	 * effectively moving it in 3D space.
	 *
	 * @param {Vector3} offset - The offset that should be used to translate the bounding box.
	 * @return {Box3} A reference to this bounding box.
	 */
	public function translate( offset ) {

		this.min.add( offset );
		this.max.add( offset );

		return this;

	}

	/**
	 * Returns `true` if this bounding box is equal with the given one.
	 *
	 * @param {Box3} box - The box to test for equality.
	 * @return {boolean} Whether this bounding box is equal with the given one.
	 */
	public function equals( box ) {

		return box.min.equals( this.min ) && box.max.equals( this.max );

	}

    static var _points = [
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3(),
        /*@__PURE__*/ new Vector3()
    ];

    static var _vector = /*@__PURE__*/ new Vector3();

    static var _box = /*@__PURE__*/ new Box3();

    // triangle centered vertices

    static var _v0 = /*@__PURE__*/ new Vector3();
    static var _v1 = /*@__PURE__*/ new Vector3();
    static var _v2 = /*@__PURE__*/ new Vector3();

    // triangle edge vectors

    static var _f0 = /*@__PURE__*/ new Vector3();
    static var _f1 = /*@__PURE__*/ new Vector3();
    static var _f2 = /*@__PURE__*/ new Vector3();

    static var _center = /*@__PURE__*/ new Vector3();
    static var _extents = /*@__PURE__*/ new Vector3();
    static var _triangleNormal = /*@__PURE__*/ new Vector3();
    static var _testAxis = /*@__PURE__*/ new Vector3();

    static function satForAxes( axes:Array<Float>, v0:Vector3, v1:Vector3, v2:Vector3, extents:Vector3 ) {

        var i = 0, j = axes.length - 3;
        while ( i <= j ) {

            _testAxis.fromArray( axes, i );
            // project the aabb onto the separating axis
            var r = extents.x * Math.abs( _testAxis.x ) + extents.y * Math.abs( _testAxis.y ) + extents.z * Math.abs( _testAxis.z );
            // project all 3 vertices of the triangle onto the separating axis
            var p0 = v0.dot( _testAxis );
            var p1 = v1.dot( _testAxis );
            var p2 = v2.dot( _testAxis );
            // actual test, basically see if either of the most extreme of the triangle points intersects r
            if ( Math.max( - Math.max( Math.max(p0, p1), p2 ), Math.min( Math.max(p0, p1), p2 ) ) > r ) {

                // points of the projected triangle are outside the projected half-length of the aabb
                // the axis is separating and we can exit
                return false;

            }
            i += 3;
        }

        return true;

    }

}