package vman2002.vthreehx.core;

import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.cameras.Camera;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.Ray;
import vman2002.vthreehx.core.Layers;
import vman2002.vthreehx.cameras.PerspectiveCamera;


/**
 * This class is designed to assist with raycasting. Raycasting is used for
 * mouse picking (working out what objects in the 3d space the mouse is over)
 * amongst other things.
 */
class Raycaster {

		/**
		 * The ray used for raycasting.
		 *
		 * @type {Ray}
		 */
		public var ray:Ray;

		/**
		 * All results returned are further away than near. Near can't be negative.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var near:Float;

		/**
		 * All results returned are further away than near. Near can't be negative.
		 *
		 * @type {number}
		 * @default Infinity
		 */
		public var far:Float;

		/**
		 * The camera to use when raycasting against view-dependent objects such as
		 * billboarded objects like sprites. This field can be set manually or
		 * is set when calling `setFromCamera()`.
		 *
		 * @type {?Camera}
		 * @default null
		 */
		public var camera = null;

		/**
		 * Allows to selectively ignore 3D objects when performing intersection tests.
		 * The following code example ensures that only 3D objects on layer `1` will be
		 * honored by raycaster.
		 * ```js
		 * raycaster.layers.set( 1 );
		 * object.layers.enable( 1 );
		 * ```
		 *
		 * @type {Layers}
		 */
		public var layers = new Layers();


		/**
		 * A parameter object that configures the raycasting. It has the structure:
		 *
		 * ```
		 * {
		 * 	Mesh: {},
		 * 	Line: { threshold: 1 },
		 * 	LOD: {},
		 * 	Points: { threshold: 1 },
		 * 	Sprite: {}
		 * }
		 * ```
		 * Where `threshold` is the precision of the raycaster when intersecting objects, in world units.
		 *
		 * @type {Object}
		 */
		public var params = {
			Mesh: {},
			Line: { threshold: 1 },
			LOD: {},
			Points: { threshold: 1 },
			Sprite: {}
		};

	/**
	 * Constructs a new raycaster.
	 *
	 * @param {Vector3} origin - The origin vector where the ray casts from.
	 * @param {Vector3} direction - The (normalized) direction vector that gives direction to the ray.
	 * @param {number} [near=0] - All results returned are further away than near. Near can't be negative.
	 * @param {number} [far=Infinity] - All results returned are closer than far. Far can't be lower than near.
	 */
	public function new( origin, direction, ?near:Float = 0, ?far:Float ) {
        this.near = near;
        this.far = far ?? Math.POSITIVE_INFINITY;
        this.ray = new Ray(origin, direction);
	}

	/**
	 * Updates the ray with a new origin and direction by copying the values from the arguments.
	 *
	 * @param {Vector3} origin - The origin vector where the ray casts from.
	 * @param {Vector3} direction - The (normalized) direction vector that gives direction to the ray.
	 */
	public function set( origin, direction ) {

		// direction is assumed to be normalized (for accurate distance calculations)

		this.ray.set( origin, direction );

	}

	/**
	 * Uses the given coordinates and camera to compute a new origin and direction for the internal ray.
	 *
	 * @param {Vector2} coords - 2D coordinates of the mouse, in normalized device coordinates (NDC).
	 * X and Y components should be between `-1` and `1`.
	 * @param {Camera} camera - The camera from which the ray should originate.
	 */
	public function setFromCamera( coords:Vector2, camera:Camera ) {

		if ( Std.isOfType(camera, PerspectiveCamera ) ) {

			this.ray.origin.setFromMatrixPosition( camera.matrixWorld );
			this.ray.direction.set( coords.x, coords.y, 0.5 ).unproject( camera ).sub( this.ray.origin ).normalize();
			this.camera = camera;

		} /*else if ( camera.isOrthographicCamera ) { //TODO: OrthographicCamera

			this.ray.origin.set( coords.x, coords.y, ( camera.near + camera.far ) / ( camera.near - camera.far ) ).unproject( camera ); // set origin in plane of camera
			this.ray.direction.set( 0, 0, - 1 ).transformDirection( camera.matrixWorld );
			this.camera = camera;

		}*/ else {

			Common.error( 'THREE.Raycaster: Unsupported camera type: ' + camera.type );

		}

	}

	/**
	 * Uses the given WebXR controller to compute a new origin and direction for the internal ray.
	 *
	 * @param {WebXRController} controller - The controller to copy the position and direction from.
	 * @return {Raycaster} A reference to this raycaster.
	 */
     //TODO: WebXRController
	/*public function setFromXRController( controller ) {

		_matrix.identity().extractRotation( controller.matrixWorld );

		this.ray.origin.setFromMatrixPosition( controller.matrixWorld );
		this.ray.direction.set( 0, 0, - 1 ).applyMatrix4( _matrix );

		return this;

	}*/

	/**
	 * The intersection point of a raycaster intersection test.
	 * @typedef {Object} Raycaster~Intersection
	 * @property {number} distance - The distance from the ray's origin to the intersection point.
	 * @property {number} distanceToRay -  Some 3D objects e.g. {@link Points} provide the distance of the
	 * intersection to the nearest point on the ray. For other objects it will be `undefined`.
	 * @property {Vector3} point - The intersection point, in world coordinates.
	 * @property {Object} face - The face that has been intersected.
	 * @property {number} faceIndex - The face index.
	 * @property {Object3D} object - The 3D object that has been intersected.
	 * @property {Vector2} uv - U,V coordinates at point of intersection.
	 * @property {Vector2} uv1 - Second set of U,V coordinates at point of intersection.
	 * @property {Vector3} uv1 - Interpolated normal vector at point of intersection.
	 * @property {number} instanceId - The index number of the instance where the ray
	 * intersects the {@link InstancedMesh}.
	 */

	/**
	 * Checks all intersection between the ray and the object with or without the
	 * descendants. Intersections are returned sorted by distance, closest first.
	 *
	 * `Raycaster` delegates to the `raycast()` method of the passed 3D object, when
	 * evaluating whether the ray intersects the object or not. This allows meshes to respond
	 * differently to ray casting than lines or points.
	 *
	 * Note that for meshes, faces must be pointed towards the origin of the ray in order
	 * to be detected; intersections of the ray passing through the back of a face will not
	 * be detected. To raycast against both faces of an object, you'll want to set  {@link Material#side}
	 * to `THREE.DoubleSide`.
	 *
	 * @param {Object3D} object - The 3D object to check for intersection with the ray.
	 * @param {boolean} [recursive=true] - If set to `true`, it also checks all descendants.
	 * Otherwise it only checks intersection with the object.
	 * @param {Array<Raycaster~Intersection>} [intersects=[]] The target array that holds the result of the method.
	 * @return {Array<Raycaster~Intersection>} An array holding the intersection points.
	 */
     //TODO:
	/*public function intersectObject( object, recursive = true, ?intersects:Array<Dynamic> ) {
        if (intersects == null)
            intersects = [];

		intersect( object, this, intersects, recursive );

		intersects.sort( ascSort );

		return intersects;

	}*/

	/**
	 * Checks all intersection between the ray and the objects with or without
	 * the descendants. Intersections are returned sorted by distance, closest first.
	 *
	 * @param {Array<Object3D>} objects - The 3D objects to check for intersection with the ray.
	 * @param {boolean} [recursive=true] - If set to `true`, it also checks all descendants.
	 * Otherwise it only checks intersection with the object.
	 * @param {Array<Raycaster~Intersection>} [intersects=[]] The target array that holds the result of the method.
	 * @return {Array<Raycaster~Intersection>} An array holding the intersection points.
	 */
     //TODO:
	/*public function intersectObjects( objects:Array<Object3D>, recursive = true, intersects:Array<Dynamic> ) {

		for ( i in 0...objects.length ) {

			intersect( objects[ i ], this, intersects, recursive );

		}

		intersects.sort( ascSort );

		return intersects;

	}*/

    static function ascSort( a, b ) {

        return a.distance - b.distance;

    }

    //TODO: what the hell object.raycast doesn't return anything why are we checking if it's false
    /*static function intersect( object:Object3D, raycaster:Raycaster, intersects:Array<Dynamic>, recursive:Bool ) {

        var propagate = true;

        if ( object.layers.test( raycaster.layers ) ) {

            var result = object.raycast( raycaster, intersects );

            if ( result == false ) propagate = false;

        }

        if ( propagate == true && recursive == true ) {

            var children = object.children;

            for (i in 0...children.length ) {

                intersect( children[ i ], raycaster, intersects, true );

            }

        }

    }*/
    static var _matrix = /*@__PURE__*/ new Matrix4();
}
