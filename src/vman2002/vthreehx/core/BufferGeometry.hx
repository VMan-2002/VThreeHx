package vman2002.vthreehx.core;

import vman2002.vthreehx.interfaces.GetType;
import haxe.Json;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.math.Box3;
import vman2002.vthreehx.core.EventDispatcher;
import vman2002.vthreehx.core.BufferAttribute;
import vman2002.vthreehx.core.BufferAttribute.Float32BufferAttribute;
import vman2002.vthreehx.core.BufferAttribute.Uint16BufferAttribute;
import vman2002.vthreehx.core.BufferAttribute.Uint32BufferAttribute;
import vman2002.vthreehx.math.Sphere;
import vman2002.vthreehx.core.Object3D;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.Matrix3;
import vman2002.vthreehx.math.MathUtils.generateUUID;
import vman2002.vthreehx.Utils.arrayNeedsUint32;

/**
 * A representation of mesh, line, or point geometry. Includes vertex
 * positions, face indices, normals, colors, UVs, and custom attributes
 * within buffers, reducing the cost of passing all this data to the GPU.
 *
 * ```js
 * const geometry = new THREE.BufferGeometry();
 * // create a simple square shape. We duplicate the top left and bottom right
 * // vertices because each vertex needs to appear once per triangle.
 * const vertices = new Float32Array( [
 * 	-1.0, -1.0,  1.0, // v0
 * 	 1.0, -1.0,  1.0, // v1
 * 	 1.0,  1.0,  1.0, // v2
 *
 * 	 1.0,  1.0,  1.0, // v3
 * 	-1.0,  1.0,  1.0, // v4
 * 	-1.0, -1.0,  1.0  // v5
 * ] );
 * // itemSize = 3 because there are 3 values (components) per vertex
 * geometry.setAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) );
 * const material = new THREE.MeshBasicMaterial( { color: 0xff0000 } );
 * const mesh = new THREE.Mesh( geometry, material );
 * ```
 *
 * @augments EventDispatcher
 */
class BufferGeometry extends EventDispatcher implements GetType {
    static var _id = 0;

    /**
    * The ID of the geometry.
    *
    * @name BufferGeometry#id
    * @type {number}
    * @readonly
    */
    public var id:Int = 0;

    /**
    * The UUID of the geometry.
    *
    * @type {string}
    * @readonly
    */
    public var uuid = generateUUID();

    /**
    * The name of the geometry.
    *
    * @type {string}
    */
    public var name = '';

    /**
    * Allows for vertices to be re-used across multiple triangles; this is
    * called using "indexed triangles". Each triangle is associated with the
    * indices of three vertices. This attribute therefore stores the index of
    * each vertex for each triangular face. If this attribute is not set, the
    * renderer assumes that each three contiguous positions represent a single triangle.
    *
    * @type {?BufferAttribute}
    * @default null
    */
    public var index:BufferAttribute = null;

    /**
    * A (storage) buffer attribute which was generated with a compute shader and
    * now defines indirect draw calls.
    *
    * Can only be used with {@link WebGPURenderer} and a WebGPU backend.
    *
    * @type {?BufferAttribute}
    * @default null
    */
    public var indirect = null;

    /**
    * This dictionary has as id the name of the attribute to be set and as value
    * the buffer attribute to set it to. Rather than accessing this property directly,
    * use `setAttribute()` and `getAttribute()` to access attributes of this geometry.
    *
    * @type {Object<string,(BufferAttribute|InterleavedBufferAttribute)>}
    */
    public var attributes:Dynamic = {};

    /**
    * This dictionary holds the morph targets of the geometry.
    *
    * Note: Once the geometry has been rendered, the morph attribute data cannot
    * be changed. You will have to call `dispose()?, and create a new geometry instance.
    *
    * @type {Object}
    */
    public var morphAttributes:Dynamic = {};

    /**
    * Used to control the morph target behavior; when set to `true`, the morph
    * target data is treated as relative offsets, rather than as absolute
    * positions/normals.
    *
    * @type {boolean}
    * @default false
    */
    public var morphTargetsRelative = false;

    /**
    * Split the geometry into groups, each of which will be rendered in a
    * separate draw call. This allows an array of materials to be used with the geometry.
    *
    * Use `addGroup()` and `clearGroups()` to edit groups, rather than modifying this array directly.
    *
    * Every vertex and index must belong to exactly one group — groups must not share vertices or
    * indices, and must not leave vertices or indices unused.
    *
    * @type {Array<Object>}
    */
    public var groups:Array<Dynamic> = [];

    /**
    * Bounding box for the geometry which can be calculated with `computeBoundingBox()`.
    *
    * @type {Box3}
    * @default null
    */
    public var boundingBox:Box3 = null;

    /**
    * Bounding sphere for the geometry which can be calculated with `computeBoundingSphere()`.
    *
    * @type {Sphere}
    * @default null
    */
    public var boundingSphere:Sphere = null;

    /**
    * Determines the part of the geometry to render. This should not be set directly,
    * instead use `setDrawRange()`.
    *
    * @type {{start:number,count:number}}
    */
    public var drawRange = { start: 0, count: Infinity };

    /**
    * An object that can be used to store custom data about the geometry.
    * It should not hold references to functions as these will not be cloned.
    *
    * @type {Object}
    */
    public var userData = {};
    
    /**
        * Holds the constructor parameters that have been
        * used to generate the geometry. Any modification
        * after instantiation does not change the geometry.
        *
        * @type {Object}
        */
    public var parameters:Dynamic;

	/**
	 * Constructs a new geometry.
	 */
	public function new() {
		super();

	}

	/**
	 * Returns the index of this geometry.
	 *
	 * @return {?BufferAttribute} The index. Returns `null` if no index is defined.
	 */
	public function getIndex() {

		return this.index;

	}

	/**
	 * Sets the given index to this geometry.
	 *
	 * @param {Array<number>|BufferAttribute} index - The index to set.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function setIndex( index:Dynamic ) {

        if (Std.isOfType(index, BufferAttribute)) {
            this.index = index;
        } else {

            this.index = arrayNeedsUint32(index) ? new Uint32BufferAttribute(index, 1) : new Uint16BufferAttribute(index, 1);

		}

		return this;

	}

	/**
	 * Sets the given indirect attribute to this geometry.
	 *
	 * @param {BufferAttribute} indirect - The attribute holding indirect draw calls.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function setIndirect( indirect ) {

		this.indirect = indirect;

		return this;

	}

	/**
	 * Returns the indirect attribute of this geometry.
	 *
	 * @return {?BufferAttribute} The indirect attribute. Returns `null` if no indirect attribute is defined.
	 */
	public function getIndirect() {

		return this.indirect;

	}

	/**
	 * Returns the buffer attribute for the given name.
	 *
	 * @param {string} name - The attribute name.
	 * @return {BufferAttribute|InterleavedBufferAttribute|null} The buffer attribute.
	 * Returns `null` if not attribute has been found.
	 */
	public function getAttribute( name ):Dynamic {

		return Reflect.field(this.attributes, name);

	}

	/**
	 * Sets the given attribute for the given name.
	 *
	 * @param {string} name - The attribute name.
	 * @param {BufferAttribute|InterleavedBufferAttribute} attribute - The attribute to set.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function setAttribute( name, attribute:BufferAttribute ) {

		Reflect.setField(this.attributes, name, attribute);

		return this;

	}

	/**
	 * Deletes the attribute for the given name.
	 *
	 * @param {string} name - The attribute name to delete.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function deleteAttribute( name ) {

		Reflect.deleteField(this.attributes, name);

		return this;

	}

	/**
	 * Returns `true` if this geometry has an attribute for the given name.
	 *
	 * @param {string} name - The attribute name.
	 * @return {boolean} Whether this geometry has an attribute for the given name or not.
	 */
	public function hasAttribute( name ) {

		return Reflect.hasField(this.attributes, name);

	}

	/**
	 * Adds a group to this geometry.
	 *
	 * @param {number} start - The first element in this draw call. That is the first
	 * vertex for non-indexed geometry, otherwise the first triangle index.
	 * @param {number} count - Specifies how many vertices (or indices) are part of this group.
	 * @param {number} [materialIndex=0] - The material array index to use.
	 */
	public function addGroup( start, count, materialIndex = 0 ) {

		this.groups.push( {

			start: start,
			count: count,
			materialIndex: materialIndex

		} );

	}

	/**
	 * Clears all groups.
	 */
	public function clearGroups() {

		this.groups = [];

	}

	/**
	 * Sets the draw range for this geometry.
	 *
	 * @param {number} start - The first vertex for non-indexed geometry, otherwise the first triangle index.
	 * @param {number} count - For non-indexed BufferGeometry, `count` is the number of vertices to render.
	 * For indexed BufferGeometry, `count` is the number of indices to render.
	 */
	public function setDrawRange( start, count ) {

		this.drawRange.start = start;
		this.drawRange.count = count;

	}

	/**
	 * Applies the given 4x4 transformation matrix to the geometry.
	 *
	 * @param {Matrix4} matrix - The matrix to apply.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function applyMatrix4( matrix ) {

		var position = this.attributes.position;

		if ( position != null ) {

			position.applyMatrix4( matrix );

			position.needsUpdate = true;

		}

		var normal = this.attributes.normal;

		if ( normal != null ) {

			var normalMatrix = new Matrix3().getNormalMatrix( matrix );

			normal.applyNormalMatrix( normalMatrix );

			normal.needsUpdate = true;

		}

		var tangent = this.attributes.tangent;

		if ( tangent != null ) {

			tangent.transformDirection( matrix );

			tangent.needsUpdate = true;

		}

		if ( this.boundingBox != null ) {

			this.computeBoundingBox();

		}

		if ( this.boundingSphere != null ) {

			this.computeBoundingSphere();

		}

		return this;

	}

	/**
	 * Applies the rotation represented by the Quaternion to the geometry.
	 *
	 * @param {Quaternion} q - The Quaternion to apply.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function applyQuaternion( q ) {

		_m1.makeRotationFromQuaternion( q );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Rotates the geometry about the X axis. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#rotation} for typical
	 * real-time mesh rotation.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function rotateX( angle ) {

		// rotate geometry around world x-axis

		_m1.makeRotationX( angle );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Rotates the geometry about the Y axis. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#rotation} for typical
	 * real-time mesh rotation.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function rotateY( angle ) {

		// rotate geometry around world y-axis

		_m1.makeRotationY( angle );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Rotates the geometry about the Z axis. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#rotation} for typical
	 * real-time mesh rotation.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function rotateZ( angle ) {

		// rotate geometry around world z-axis

		_m1.makeRotationZ( angle );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Translates the geometry. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#position} for typical
	 * real-time mesh rotation.
	 *
	 * @param {number} x - The x offset.
	 * @param {number} y - The y offset.
	 * @param {number} z - The z offset.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function translate( x, y, z ) {

		// translate geometry

		_m1.makeTranslation( x, y, z );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Scales the geometry. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#scale} for typical
	 * real-time mesh rotation.
	 *
	 * @param {number} x - The x scale.
	 * @param {number} y - The y scale.
	 * @param {number} z - The z scale.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function scale( x, y, z ) {

		// scale geometry

		_m1.makeScale( x, y, z );

		this.applyMatrix4( _m1 );

		return this;

	}

	/**
	 * Rotates the geometry to face a point in 3D space. This is typically done as a one time
	 * operation, and not during a loop. Use {@link Object3D#lookAt} for typical
	 * real-time mesh rotation.
	 *
	 * @param {Vector3} vector - The target point.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function lookAt( vector ) {

		_obj.lookAt( vector );

		_obj.updateMatrix();

		this.applyMatrix4( _obj.matrix );

		return this;

	}

	/**
	 * Center the geometry based on its bounding box.
	 *
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function center() {

		this.computeBoundingBox();

		this.boundingBox.getCenter( _offset ).negate();

		this.translate( _offset.x, _offset.y, _offset.z );

		return this;

	}

	/**
	 * Defines a geometry by creating a `position` attribute based on the given array of points. The array
	 * can hold 2D or 3D vectors. When using two-dimensional data, the `z` coordinate for all vertices is
	 * set to `0`.
	 *
	 * If the method is used with an existing `position` attribute, the vertex data are overwritten with the
	 * data from the array. The length of the array must match the vertex count.
	 *
	 * @param {Array<Vector2>|Array<Vector3>} points - The points.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function setFromPoints( points ) {

		var positionAttribute:BufferAttribute = this.getAttribute( 'position' );

		if ( positionAttribute == null ) {

			var position = new Float32Array();

			for ( i in 0...points.length ) {

				var point = points[ i ];
				position.push( point.x);
				position.push( point.y);
				position.push( point.z ?? 0 );

			}

			this.setAttribute( 'position', new Float32BufferAttribute( position, 3 ) );

		} else {

			var l = points.length > positionAttribute.count ? points.length : positionAttribute.count; // make sure data do not exceed buffer size

			for ( i in 0...l ) {

				var point = points[ i ];
				positionAttribute.setXYZ( i, point.x, point.y, point.z ?? 0 );

			}

			if ( points.length > positionAttribute.count ) {

				Common.warn( 'THREE.BufferGeometry: Buffer size too small for points data. Use .dispose() and create a new geometry.' );

			}

			positionAttribute.needsUpdate = true;

		}

		return this;

	}

	/**
	 * Computes the bounding box of the geometry, and updates the `boundingBox` member.
	 * The bounding box is not computed by the engine; it must be computed by your app.
	 * You may need to recompute the bounding box if the geometry vertices are modified.
	 */
	public function computeBoundingBox() {

		if ( this.boundingBox == null ) {

			this.boundingBox = new Box3();

		}

		var position = this.attributes.position;
		var morphAttributesPosition:Array<Float32BufferAttribute> = this.morphAttributes.position;

		if ( position != null && Std.isOfType(position, BufferAttribute) ) {

			Common.error( 'THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box.', this );

			this.boundingBox.set(
				new Vector3( -Infinity, -Infinity, -Infinity ),
				new Vector3( Infinity, Infinity, Infinity )
			);

			return;

		}

		if ( position != null ) {

			this.boundingBox.setFromBufferAttribute( position );

			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( i in 0...morphAttributesPosition.length ) {

					var morphAttribute = morphAttributesPosition[ i ];
					_box.setFromBufferAttribute( morphAttribute );

					if ( this.morphTargetsRelative ) {

						_vector.addVectors( this.boundingBox.min, _box.min );
						this.boundingBox.expandByPoint( _vector );

						_vector.addVectors( this.boundingBox.max, _box.max );
						this.boundingBox.expandByPoint( _vector );

					} else {

						this.boundingBox.expandByPoint( _box.min );
						this.boundingBox.expandByPoint( _box.max );

					}

				}

			}

		} else {

			this.boundingBox.makeEmpty();

		}

		if ( isNaN( this.boundingBox.min.x ) || isNaN( this.boundingBox.min.y ) || isNaN( this.boundingBox.min.z ) ) {

			Common.error( 'THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.', this );

		}

	}

	/**
	 * Computes the bounding sphere of the geometry, and updates the `boundingSphere` member.
	 * The engine automatically computes the bounding sphere when it is needed, e.g., for ray casting or view frustum culling.
	 * You may need to recompute the bounding sphere if the geometry vertices are modified.
	 */
	public function computeBoundingSphere() {

		if ( this.boundingSphere == null ) {
			this.boundingSphere = new Sphere();
		}

		var position = this.attributes.position;
		var morphAttributesPosition:Array<Float32BufferAttribute> = this.morphAttributes.position;

		if ( position != null && Std.isOfType(position, BufferAttribute) ) {
			Common.error( 'THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere.', this );

			this.boundingSphere.set( new Vector3(), Infinity );

			return;
		}

		if ( position != null ) {

			// first, find the center of the bounding sphere

			var center = this.boundingSphere.center;

			_box.setFromBufferAttribute( position );

			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( i in 0...morphAttributesPosition.length ) {

					var morphAttribute = morphAttributesPosition[ i ];
					_boxMorphTargets.setFromBufferAttribute( morphAttribute );

					if ( this.morphTargetsRelative ) {

						_vector.addVectors( _box.min, _boxMorphTargets.min );
						_box.expandByPoint( _vector );

						_vector.addVectors( _box.max, _boxMorphTargets.max );
						_box.expandByPoint( _vector );

					} else {

						_box.expandByPoint( _boxMorphTargets.min );
						_box.expandByPoint( _boxMorphTargets.max );

					}

				}

			}

			_box.getCenter( center );

			// second, try to find a boundingSphere with a radius smaller than the
			// boundingSphere of the boundingBox: sqrt(3) smaller in the best case

			var maxRadiusSq:Float = 0;

			for ( i in 0...position.count ) {

				_vector.fromBufferAttribute( position, i );

				maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( _vector ) );

			}

			// process morph attributes if present

			if ( morphAttributesPosition != null ) {

				for ( i in 0...morphAttributesPosition.length ) {

					var morphAttribute = morphAttributesPosition[ i ];
					var morphTargetsRelative = this.morphTargetsRelative;

					for ( j in 0...morphAttribute.count ) {

						_vector.fromBufferAttribute( morphAttribute, j );

						if ( morphTargetsRelative ) {

							_offset.fromBufferAttribute( position, j );
							_vector.add( _offset );

						}

						maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( _vector ) );

					}

				}

			}

			this.boundingSphere.radius = Math.sqrt( maxRadiusSq );

			if ( isNaN( this.boundingSphere.radius ) ) {

				Common.error( 'THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.', this );

			}

		}

	}

	/**
	 * Calculates and adds a tangent attribute to this geometry.
	 *
	 * The computation is only supported for indexed geometries and if position, normal, and uv attributes
	 * are defined. When using a tangent space normal map, prefer the MikkTSpace algorithm provided by
	 * {@link BufferGeometryUtils#computeMikkTSpaceTangents} instead.
	 */
	public function computeTangents() {

		var index:BufferAttribute<Dynamic, Int> = cast this.index;
		var attributes = this.attributes;

		// based on http://www.terathon.com/code/tangent.html
		// (per vertex tangents)

		if ( index == null ||
			 !Reflect.hasField(attributes, "position") ||
			 !Reflect.hasField(attributes, "normal") ||
			 !Reflect.hasField(attributes, "uv") ) {

			Common.error( 'THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)' );
			return;

		}

		var positionAttribute = attributes.position;
		var normalAttribute = attributes.normal;
		var uvAttribute = attributes.uv;

		if ( this.hasAttribute( 'tangent' ) == false ) {

			this.setAttribute( 'tangent', new BufferAttribute( new Float32Array( 4 * positionAttribute.count ), 4 ) );

		}

		var tangentAttribute = this.getAttribute( 'tangent' );

		var tan1 = [], tan2 = [];

		for ( i in 0...positionAttribute.count ) {

			tan1[ i ] = new Vector3();
			tan2[ i ] = new Vector3();

		}

		var vA = new Vector3(),
			vB = new Vector3(),
			vC = new Vector3(),

			uvA = new Vector2(),
			uvB = new Vector2(),
			uvC = new Vector2(),

			sdir = new Vector3(),
			tdir = new Vector3();

		function handleTriangle( a, b, c ) {

			vA.fromBufferAttribute( positionAttribute, a );
			vB.fromBufferAttribute( positionAttribute, b );
			vC.fromBufferAttribute( positionAttribute, c );

			uvA.fromBufferAttribute( uvAttribute, a );
			uvB.fromBufferAttribute( uvAttribute, b );
			uvC.fromBufferAttribute( uvAttribute, c );

			vB.sub( vA );
			vC.sub( vA );

			uvB.sub( uvA );
			uvC.sub( uvA );

			var r = 1.0 / ( uvB.x * uvC.y - uvC.x * uvB.y );

			// silently ignore degenerate uv triangles having coincident or colinear vertices

			if ( ! isFinite( r ) ) return;

			sdir.copy( vB ).multiplyScalar( uvC.y ).addScaledVector( vC, - uvB.y ).multiplyScalar( r );
			tdir.copy( vC ).multiplyScalar( uvB.x ).addScaledVector( vB, - uvC.x ).multiplyScalar( r );

			tan1[ a ].add( sdir );
			tan1[ b ].add( sdir );
			tan1[ c ].add( sdir );

			tan2[ a ].add( tdir );
			tan2[ b ].add( tdir );
			tan2[ c ].add( tdir );

		}

		var groups = this.groups;

		if ( groups.length == 0 ) {

			groups = [ {
				start: 0,
				count: index.count
			} ];

		}

		for ( i in 0...groups.length ) {

			var group:{start:Int, count:Int} = groups[ i ];

			var start = group.start;
			var count = group.count;

            var j:Int = start, jl:Int = start + count;
			while ( j < jl ) {
				handleTriangle(
					Common.numberAsInt(index.getX( j )),
					Common.numberAsInt(index.getX( j + 1 )),
					Common.numberAsInt(index.getX( j + 2 ))
				);

                j += 3;
			}

		}

		var tmp = new Vector3(), tmp2 = new Vector3();
		var n = new Vector3(), n2 = new Vector3();

		function handleVertex( vin:Dynamic ) {
            var v = Common.numberAsInt(vin);

			n.fromBufferAttribute( normalAttribute, v );
			n2.copy( n );

			var t = tan1[ v ];

			// Gram-Schmidt orthogonalize

			tmp.copy( t );
			tmp.sub( n.multiplyScalar( n.dot( t ) ) ).normalize();

			// Calculate handedness

			tmp2.crossVectors( n2, t );
			var test = tmp2.dot( tan2[ v ] );
			var w = ( test < 0.0 ) ? - 1.0 : 1.0;

			tangentAttribute.setXYZW( v, tmp.x, tmp.y, tmp.z, w );

		}

		for ( i in 0...groups.length ) {
			var group = groups[ i ];

			var start = group.start;
			var count = group.count;

            var j = start, jl = start + count;
			while ( j < jl ) {
				handleVertex( index.getX( j + 0 ) );
				handleVertex( index.getX( j + 1 ) );
				handleVertex( index.getX( j + 2 ) );

                j += 3;
			}
		}
	}

	/**
	 * Computes vertex normals for the given vertex data. For indexed geometries, the method sets
	 * each vertex normal to be the average of the face normals of the faces that share that vertex.
	 * For non-indexed geometries, vertices are not shared, and the method sets each vertex normal
	 * to be the same as the face normal.
	 */
	public function computeVertexNormals() {

		var index = this.index;
		var positionAttribute:BufferAttribute = this.getAttribute( 'position' );

		if ( positionAttribute != null ) {

			var normalAttribute:BufferAttribute = this.getAttribute( 'normal' );

			if ( normalAttribute == null ) {

				normalAttribute = new BufferAttribute( new Float32Array( positionAttribute.count * 3 ), 3 );
				this.setAttribute( 'normal', normalAttribute );

			} else {

				// reset existing normals to zero

				for ( i in 0...normalAttribute.count ) {

					normalAttribute.setXYZ( i, 0, 0, 0 );

				}

			}

			var pA = new Vector3(), pB = new Vector3(), pC = new Vector3();
			var nA = new Vector3(), nB = new Vector3(), nC = new Vector3();
			var cb = new Vector3(), ab = new Vector3();

			// indexed elements

			if ( index != null) {
                var i = 0, il = index.count;
				while ( i < il ) {

					var vA:Int = Common.numberAsInt(index.getX( i + 0 ));
					var vB:Int = Common.numberAsInt(index.getX( i + 1 ));
					var vC:Int = Common.numberAsInt(index.getX( i + 2 ));

					pA.fromBufferAttribute( positionAttribute, vA );
					pB.fromBufferAttribute( positionAttribute, vB );
					pC.fromBufferAttribute( positionAttribute, vC );

					cb.subVectors( pC, pB );
					ab.subVectors( pA, pB );
					cb.cross( ab );

					nA.fromBufferAttribute( normalAttribute, vA );
					nB.fromBufferAttribute( normalAttribute, vB );
					nC.fromBufferAttribute( normalAttribute, vC );

					nA.add( cb );
					nB.add( cb );
					nC.add( cb );

					normalAttribute.setXYZ( vA, nA.x, nA.y, nA.z );
					normalAttribute.setXYZ( vB, nB.x, nB.y, nB.z );
					normalAttribute.setXYZ( vC, nC.x, nC.y, nC.z );

                    i += 3;
				}

			} else {

				// non-indexed elements (unconnected triangle soup)

                var i = 0, il = positionAttribute.count;
				while ( i < il ) {

					pA.fromBufferAttribute( positionAttribute, i + 0 );
					pB.fromBufferAttribute( positionAttribute, i + 1 );
					pC.fromBufferAttribute( positionAttribute, i + 2 );

					cb.subVectors( pC, pB );
					ab.subVectors( pA, pB );
					cb.cross( ab );

					normalAttribute.setXYZ( i + 0, cb.x, cb.y, cb.z );
					normalAttribute.setXYZ( i + 1, cb.x, cb.y, cb.z );
					normalAttribute.setXYZ( i + 2, cb.x, cb.y, cb.z );

				}

			}

			this.normalizeNormals();

			normalAttribute.needsUpdate = true;

		}

	}

	/**
	 * Ensures every normal vector in a geometry will have a magnitude of `1`. This will
	 * correct lighting on the geometry surfaces.
	 */
	public function normalizeNormals() {

		var normals:BufferAttribute = this.attributes.normal;

		for ( i in 0...normals.count ) {

			_vector.fromBufferAttribute( normals, i );

			_vector.normalize();

			normals.setXYZ( i, _vector.x, _vector.y, _vector.z );

		}

	}

	/**
	 * Return a new non-index version of this indexed geometry. If the geometry
	 * is already non-indexed, the method is a NOOP.
	 *
	 * @return {BufferGeometry} The non-indexed version of this indexed geometry.
	 */
     //TODO:
	/*public function toNonIndexed() {

		function convertBufferAttribute( attribute, indices ) {

			var array = attribute.array;
			var itemSize = attribute.itemSize;
			var normalized = attribute.normalized;

			var array2 = new array.constructor( indices.length * itemSize );

			var index = 0, index2 = 0;

			for ( let i = 0, l = indices.length; i < l; i ++ ) {

				if ( attribute.isInterleavedBufferAttribute ) {

					index = indices[ i ] * attribute.data.stride + attribute.offset;

				} else {

					index = indices[ i ] * itemSize;

				}

				for ( let j = 0; j < itemSize; j ++ ) {

					array2[ index2 ++ ] = array[ index ++ ];

				}

			}

			return new BufferAttribute( array2, itemSize, normalized );

		}

		//

		if ( this.index == null ) {

			console.warn( 'THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed.' );
			return this;

		}

		const geometry2 = new BufferGeometry();

		const indices = this.index.array;
		const attributes = this.attributes;

		// attributes

		for ( const name in attributes ) {

			const attribute = attributes[ name ];

			const newAttribute = convertBufferAttribute( attribute, indices );

			geometry2.setAttribute( name, newAttribute );

		}

		// morph attributes

		const morphAttributes = this.morphAttributes;

		for ( const name in morphAttributes ) {

			const morphArray = [];
			const morphAttribute = morphAttributes[ name ]; // morphAttribute: array of Float32BufferAttributes

			for ( let i = 0, il = morphAttribute.length; i < il; i ++ ) {

				const attribute = morphAttribute[ i ];

				const newAttribute = convertBufferAttribute( attribute, indices );

				morphArray.push( newAttribute );

			}

			geometry2.morphAttributes[ name ] = morphArray;

		}

		geometry2.morphTargetsRelative = this.morphTargetsRelative;

		// groups

		const groups = this.groups;

		for ( let i = 0, l = groups.length; i < l; i ++ ) {

			const group = groups[ i ];
			geometry2.addGroup( group.start, group.count, group.materialIndex );

		}

		return geometry2;

	}*/

	/**
	 * Serializes the geometry into JSON.
	 *
	 * @return {Object} A JSON object representing the serialized geometry.
	 */
	public function toJSON() {

		var data:Dynamic = {
			metadata: cast {
				version: 4.6,
				type: 'BufferGeometry',
				generator: 'BufferGeometry.toJSON'
			}
		};

		// standard BufferGeometry serialization

		data.uuid = this.uuid;
		data.type = this.type;
		if ( this.name != '' ) data.name = this.name;
		if ( Reflect.fields( this.userData ).length > 0 ) data.userData = this.userData;

		if ( this.parameters != null ) {

			var parameters = this.parameters;

			for ( key in Reflect.fields(parameters) ) {

				if ( Reflect.field(parameters, key) != null ) Reflect.setField(data, key, Reflect.field(parameters, key));

			}

			return data;

		}

		// for simplicity the code assumes attributes are not shared across geometries, see #15811

		data.data = cast { attributes: cast {} };

		var index = this.index;

		if ( index != null ) {

			data.data.index = {
				type: Type.getClassName(Type.getClass(index.array)),
				array: index.array.copy()
			};

		}

		var attributes = this.attributes;

		for ( key in Reflect.fields(attributes) ) {

			var attribute = Reflect.field(attributes, key);

			Reflect.setField(data.data.attributes, key, attribute.toJSON( data.data ));

		}

		var morphAttributes:Dynamic = {};
		var hasMorphAttributes = false;

		for ( key in Reflect.fields(this.morphAttributes) ) {

			var attributeArray = Reflect.field(this.morphAttributes, key);

			var array = [];

			for ( i in 0...attributeArray.length ) {

				var attribute = attributeArray[ i ];

				array.push( attribute.toJSON( data.data ) );

			}

			if ( array.length > 0 ) {

				Reflect.setField(morphAttributes, key, array);

				hasMorphAttributes = true;

			}

		}

		if ( hasMorphAttributes ) {

			data.data.morphAttributes = morphAttributes;
			data.data.morphTargetsRelative = this.morphTargetsRelative;

		}

		var groups = this.groups;

		if ( groups.length > 0 ) {
			data.data.groups = Json.parse( Json.stringify( groups ) );
		}

		var boundingSphere = this.boundingSphere;

		if ( boundingSphere != null ) {

			data.data.boundingSphere = {
				center: boundingSphere.center.toArray(),
				radius: boundingSphere.radius
			};

		}

		return data;

	}

	/**
	 * Returns a new geometry with copied values from this instance.
	 *
	 * @return {BufferGeometry} A clone of this instance.
	 */
	public function clone():Dynamic {
		return Common.reconstruct(this).copy( this );
	}

	/**
	 * Copies the values of the given geometry to this instance.
	 *
	 * @param {BufferGeometry} source - The geometry to copy.
	 * @return {BufferGeometry} A reference to this instance.
	 */
	public function copy( source:BufferGeometry ) {

		// reset

		this.index = null;
		this.attributes = {};
		this.morphAttributes = {};
		this.groups = [];
		this.boundingBox = null;
		this.boundingSphere = null;

		// used for storing cloned, shared data

		var data = {};

		// name

		this.name = source.name;

		// index

		var index = source.index;

		if ( index != null ) {

			this.setIndex( index.clone() );

		}

		// attributes

		var attributes = source.attributes;

		for ( name in Reflect.fields(attributes) ) {

			var attribute = Reflect.field(attributes, name);
			this.setAttribute( name, attribute.clone( data ) );

		}

		// morph attributes

		var morphAttributes = source.morphAttributes;

		for ( name in Reflect.fields(morphAttributes) ) {

			var array = [];
			var morphAttribute = Reflect.field(morphAttributes, name); // morphAttribute: array of Float32BufferAttributes

			for ( i in 0...morphAttribute.length ) {

				array.push( morphAttribute[ i ].clone( data ) );

			}

			Reflect.setField(this.morphAttributes, name, array);

		}

		this.morphTargetsRelative = source.morphTargetsRelative;

		// groups

		var groups = source.groups;

		for ( i in 0...groups.length ) {

			var group = groups[ i ];
			this.addGroup( group.start, group.count, group.materialIndex );

		}

		// bounding box

		if ( source.boundingBox != null ) {

			this.boundingBox = source.boundingBox.clone();

		}

		// bounding sphere

		var boundingSphere = source.boundingSphere;

		if ( boundingSphere != null ) {

			this.boundingSphere = boundingSphere.clone();

		}

		// draw range

		this.drawRange.start = source.drawRange.start;
		this.drawRange.count = source.drawRange.count;

		// user data

		this.userData = source.userData;

		return this;

	}

    public var type(get, never):String;
    function get_type() {
        return Common.typeName(this);
    }

	/**
	 * Frees the GPU-related resources allocated by this instance. Call this
	 * method whenever this instance is no longer used in your app.
	 *
	 * @fires BufferGeometry#dispose
	 */
	public function dispose() {

		this.dispatchEvent( { type: 'dispose' } );

	}

    var _m1 = /*@__PURE__*/ new Matrix4();
    var _obj = /*@__PURE__*/ new Object3D();
    var _offset = /*@__PURE__*/ new Vector3();
    var _box = /*@__PURE__*/ new Box3();
    var _boxMorphTargets = /*@__PURE__*/ new Box3();
    var _vector = /*@__PURE__*/ new Vector3();
}