package vman2002.vthreehx.objects;

import vman2002.vthreehx.core.BufferAttribute;
import vman2002.vthreehx.materials.Material;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.math.Sphere;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.core.Object3D;
import vman2002.vthreehx.Constants.BackSide;
import vman2002.vthreehx.Constants.FrontSide;
import vman2002.vthreehx.materials.MeshBasicMaterial;
import vman2002.vthreehx.core.BufferGeometry;
import vman2002.vthreehx.math.Ray;
import vman2002.vthreehx.math.Triangle;
import vman2002.vthreehx.core.Raycaster;

/**
 * Class representing triangular polygon mesh based objects.
 *
 * ```js
 * const geometry = new THREE.BoxGeometry( 1, 1, 1 );
 * const material = new THREE.MeshBasicMaterial( { color: 0xffff00 } );
 * const mesh = new THREE.Mesh( geometry, material );
 * scene.add( mesh );
 * ```
 *
 * @augments Object3D
 */
class Mesh extends Object3D {

		/**
		 * The mesh geometry.
		 *
		 * @type {BufferGeometry}
		 */
		public var geometry:BufferGeometry;

		/**
		 * The mesh material.
		 *
		 * @type {Material|Array<Material>}
		 * @default MeshBasicMaterial
		 */
		public var material:Dynamic;

		/**
		 * A dictionary representing the morph targets in the geometry. The key is the
		 * morph targets name, the value its attribute index. This member is `null`
		 * by default and only set when morph targets are detected in the geometry.
		 *
		 * @type {Object<String,number>|null}
		 * @default null
		 */
		public var morphTargetDictionary:Map<String, Int>;

		/**
		 * An array of weights typically in the range `[0,1]` that specify how much of the morph
		 * is applied. This member is `null` by default and only set when morph targets are
		 * detected in the geometry.
		 *
		 * @type {Array<number>|null}
		 * @default null
		 */
		public var morphTargetInfluences:Null<Array<Float>> = null;

	/**
	 * Constructs a new mesh.
	 *
	 * @param {BufferGeometry} [geometry] - The mesh geometry.
	 * @param {Material|Array<Material>} [material] - The mesh material.
	 */
	public function new( geometry:BufferGeometry, material:MeshBasicMaterial ) {

		super();

		this.geometry = geometry ?? new vman2002.vthreehx.core.BufferGeometry();
        this.material = material ?? new vman2002.vthreehx.materials.MeshBasicMaterial();

		this.updateMorphTargets();

	}

	public override function copy( source:Dynamic, ?recursive:Bool = true ):Dynamic {

		super.copy( source, recursive );

		if ( source.morphTargetInfluences != null ) {

			this.morphTargetInfluences = source.morphTargetInfluences.slice();

		}

		if ( source.morphTargetDictionary != null ) {

			this.morphTargetDictionary = Common.assign( {}, source.morphTargetDictionary );

		}

		this.material = Std.isOfType( source.material, Array ) ? source.material.copy() : source.material;
		this.geometry = source.geometry;

		return this;

	}

	/**
	 * Sets the values of {@link Mesh#morphTargetDictionary} and {@link Mesh#morphTargetInfluences}
	 * to make sure existing morph targets can influence this 3D object.
	 */
	public function updateMorphTargets() {

		var geometry = this.geometry;

		var morphAttributes = geometry.morphAttributes;
		var keys = Reflect.fields( morphAttributes );

		if ( keys.length > 0 ) {

			var morphAttribute = morphAttributes.get( keys[ 0 ] );

			if ( morphAttribute != null ) {

				this.morphTargetInfluences = [];
				this.morphTargetDictionary = [];

				for ( m in 0...morphAttribute.length ) {

					var name = morphAttribute[ m ].name ?? Std.string(m);

					this.morphTargetInfluences.push( 0 );
					this.morphTargetDictionary.set(name, m);

				}

			}

		}

	}

	/**
	 * Returns the local-space position of the vertex at the given index, taking into
	 * account the current animation state of both morph targets and skinning.
	 *
	 * @param {number} index - The vertex index.
	 * @param {Vector3} target - The target object that is used to store the method's result.
	 * @return {Vector3} The vertex position in local space.
	 */
	public function getVertexPosition( index:Int, target:Vector3 ) {

		var geometry = this.geometry;
		var position = geometry.attributes.position;
		var morphPosition = geometry.morphAttributes.position;
		var morphTargetsRelative = geometry.morphTargetsRelative;

		target.fromBufferAttribute( position, index );

		var morphInfluences = this.morphTargetInfluences;

		if ( morphPosition != null && morphInfluences != null ) {

			_morphA.set( 0, 0, 0 );

			for ( i in 0...morphPosition.length ) {

				var influence = morphInfluences[ i ];
				var morphAttribute = morphPosition[ i ];

				if ( influence == 0 ) continue;

				_tempA.fromBufferAttribute( morphAttribute, index );

				if ( morphTargetsRelative ) {

					_morphA.addScaledVector( _tempA, influence );

				} else {

					_morphA.addScaledVector( _tempA.sub( target ), influence );

				}

			}

			target.add( _morphA );

		}

		return target;

	}

	/**
	 * Computes intersection points between a casted ray and this line.
	 *
	 * @param {Raycaster} raycaster - The raycaster.
	 * @param {Array<Object>} intersects - The target array that holds the intersection points.
	 */
	public override function raycast( raycaster:Raycaster, intersects:Array<Dynamic> ) {

		var geometry = this.geometry;
		var material = this.material;
		var matrixWorld = this.matrixWorld;

		if ( material == null ) return;

		// test with bounding sphere in world space

		if ( geometry.boundingSphere == null ) geometry.computeBoundingSphere();

		_sphere.copy( geometry.boundingSphere );
		_sphere.applyMatrix4( matrixWorld );

		// check distance from ray origin to bounding sphere

		_ray.copy( raycaster.ray ).recast( raycaster.near );

		if ( _sphere.containsPoint( _ray.origin ) == false ) {

			if ( _ray.intersectSphere( _sphere, _sphereHitAt ) == null ) return;

			if ( _ray.origin.distanceToSquared( _sphereHitAt ) > Math.pow( raycaster.far - raycaster.near, 2.0) ) return;

		}

		// convert ray to local space of mesh

		_inverseMatrix.copy( matrixWorld ).invert();
		_ray.copy( raycaster.ray ).applyMatrix4( _inverseMatrix );

		// test with bounding box in local space

		if ( geometry.boundingBox != null ) {

			if ( _ray.intersectsBox( geometry.boundingBox ) == false ) return;

		}

		// test for intersections with geometry

		this._computeIntersections( raycaster, intersects, _ray );

	}

	public function _computeIntersections( raycaster:Raycaster, intersects, rayLocalSpace ) {

		var intersection;

		var geometry = this.geometry;
		var material = this.material;

		var index = geometry.index;
		var position = geometry.attributes.position;
		var uv = geometry.attributes.uv;
		var uv1 = geometry.attributes.uv1;
		var normal = geometry.attributes.normal;
		var groups = geometry.groups;
		var drawRange = geometry.drawRange;

		if ( index != null ) {

			// indexed buffer geometry

			if ( Std.isOfType( material, Array ) ) {

				for ( i in 0...groups.length ) {

					var group = groups[ i ];
					var groupMaterial = material[ group.materialIndex ];

					var start = Std.int(Math.max( group.start, drawRange.start ));
					var end = Std.int(Math.min( index.count, Math.min( ( group.start + group.count ), ( drawRange.start + drawRange.count ) ) ));
                     var j = start;

					while ( j < end ) {

						//TODO: this is wrong (they should already be int)
						var a = Std.int(index.getX( j ));
						var b = Std.int(index.getX( j + 1 ));
						var c = Std.int(index.getX( j + 2 ));

						intersection = checkGeometryIntersection( this, groupMaterial, raycaster, rayLocalSpace, uv, uv1, normal, a, b, c );

						if ( intersection != null ) {

							intersection.faceIndex = Math.floor( j / 3 ); // triangle number in indexed buffer semantics
							intersection.face.materialIndex = group.materialIndex;
							intersects.push( intersection );

						}
                        j += 3;

					}

				}

			} else {

				var start:Int = Std.int(Math.max( 0, drawRange.start ));
				var end:Int = Std.int(Math.min( index.count, ( drawRange.start + drawRange.count ) ));
                var i = start;

				while ( i < end ) {

					//TODO: this is wrong (they should already be int)
					var a = Std.int(index.getX( i ));
					var b = Std.int(index.getX( i + 1 ));
					var c = Std.int(index.getX( i + 2 ));

					intersection = checkGeometryIntersection( this, cast(material, Material), raycaster, rayLocalSpace, uv, uv1, normal, a, b, c );

					if ( intersection != null ) {

						intersection.faceIndex = Math.floor( i / 3 ); // triangle number in indexed buffer semantics
						intersects.push( intersection );

					}
                    i += 3;
				}

			}

		} else if ( position != null ) {

			// non-indexed buffer geometry

			if ( Std.isOfType( material, Array ) ) {

				for ( i in 0...groups.length ) {

					var group = groups[ i ];
					var groupMaterial = material[ group.materialIndex ];

					var start = Std.int(Math.max( group.start, drawRange.start ));
					var end = Std.int(Math.min( position.count, Math.min( ( group.start + group.count ), ( drawRange.start + drawRange.count ) ) ));
                    var j = start;
					while (  j < end  ) {

						var a = j;
						var b = j + 1;
						var c = j + 2;

						intersection = checkGeometryIntersection( this, groupMaterial, raycaster, rayLocalSpace, uv, uv1, normal, a, b, c );

						if ( intersection != null ) {

							intersection.faceIndex = Math.floor( j / 3 ); // triangle number in non-indexed buffer semantics
							intersection.face.materialIndex = group.materialIndex;
							intersects.push( intersection );

						}

                        j += 3;
					}

				}

			} else {

				var start = Std.int(Math.max( 0, drawRange.start ));
				var end = Std.int(Math.min( position.count, ( drawRange.start + drawRange.count ) ));
                var i = start;

				while ( i < end ) {

					var a = i;
					var b = i + 1;
					var c = i + 2;

					intersection = checkGeometryIntersection( this, cast(material, Material), raycaster, rayLocalSpace, uv, uv1, normal, a, b, c );

					if ( intersection != null) {

						intersection.faceIndex = Math.floor( i / 3 ); // triangle number in non-indexed buffer semantics
						intersects.push( intersection );

					}
                    i += 3;

				}

			}

		}

	}


static function checkIntersection( object:Mesh, material, raycaster:Raycaster, ray, pA, pB, pC, point ):Dynamic {

	var intersect;

	if ( material.side == BackSide ) {

		intersect = ray.intersectTriangle( pC, pB, pA, true, point );

	} else {

		intersect = ray.intersectTriangle( pA, pB, pC, ( material.side == FrontSide ), point );

	}

	if ( intersect == null ) return null;

	_intersectionPointWorld.copy( point );
	_intersectionPointWorld.applyMatrix4( object.matrixWorld );

	var distance = raycaster.ray.origin.distanceTo( _intersectionPointWorld );

	if ( distance < raycaster.near || distance > raycaster.far ) return null;

	return {
		distance: distance,
		point: _intersectionPointWorld.clone(),
		object: object
	};

}

static function checkGeometryIntersection( object:Mesh, material:Material, raycaster:Raycaster, ray:Ray, uv, uv1, normal, a:Int, b:Int, c:Int ):Dynamic {

	object.getVertexPosition( a, _vA );
	object.getVertexPosition( b, _vB );
	object.getVertexPosition( c, _vC );

	var intersection = checkIntersection( object, material, raycaster, ray, _vA, _vB, _vC, _intersectionPoint );

	if ( intersection != null ) {

		var barycoord = new Vector3();
		Triangle.s_getBarycoord( _intersectionPoint, _vA, _vB, _vC, barycoord );

		if ( uv != null ) {

			Triangle.getInterpolatedAttribute( uv, a, b, c, barycoord, _tempA );
			intersection.uv = new Vector2(_tempA.x, _tempA.y);
		}

		if ( uv1 != null ) {

			Triangle.getInterpolatedAttribute( uv1, a, b, c, barycoord, _tempA );
			intersection.uv1 = new Vector2(_tempA.x, _tempA.y);
		}

		if ( normal != null ) {

			intersection.normal = Triangle.getInterpolatedAttribute( normal, a, b, c, barycoord, new Vector3() );

			if ( intersection.normal.dot( ray.direction ) > 0 ) {

				intersection.normal.multiplyScalar( - 1 );

			}

		}

		var face = {
			a: a,
			b: b,
			c: c,
			normal: new Vector3(),
			materialIndex: 0
		};

		Triangle.s_getNormal( _vA, _vB, _vC, face.normal );

		intersection.face = face;
		intersection.barycoord = barycoord;

	}

	return intersection;

}

static var _inverseMatrix = /*@__PURE__*/ new Matrix4();
static var _ray = /*@__PURE__*/ new Ray();
static var _sphere = /*@__PURE__*/ new Sphere();
static var _sphereHitAt = /*@__PURE__*/ new Vector3();

static var _vA = /*@__PURE__*/ new Vector3();
static var _vB = /*@__PURE__*/ new Vector3();
static var _vC = /*@__PURE__*/ new Vector3();

static var _tempA = /*@__PURE__*/ new Vector3();
static var _morphA = /*@__PURE__*/ new Vector3();

static var _intersectionPoint = /*@__PURE__*/ new Vector3();
static var _intersectionPointWorld = /*@__PURE__*/ new Vector3();
}