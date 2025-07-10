package vman2002.vthreehx.core;

import vman2002.vthreehx.objects.Mesh;
import vman2002.vthreehx.cameras.Camera;
import vman2002.vthreehx.interfaces.GetType;
import vman2002.vthreehx.math.Quaternion;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.Euler;
import vman2002.vthreehx.core.Layers;
import vman2002.vthreehx.math.Matrix3;
import vman2002.vthreehx.math.MathUtils.generateUUID in generateUUID;
import haxe.Json in JSON;
import vman2002.vthreehx.scenes.Scene;

/** This is the base class for most objects in three.js and provides a set of properties and methods for manipulating objects in 3D space. **/
class Object3D extends vman2002.vthreehx.core.EventDispatcher implements GetType {
	/** The default up direction for objects, also used as the default position for {@link DirectionalLight} and {@link HemisphereLight}. **/
	public static var DEFAULT_UP = /*@__PURE__*/ new Vector3( 0, 1, 0 );

	/** The default setting for {@link Object3D#matrixAutoUpdate} for newly created 3D objects. **/
	public static var DEFAULT_MATRIX_AUTO_UPDATE = true;

	/** The default setting for {@link Object3D#matrixWorldAutoUpdate} for newly created 3D objects. **/
	public static var DEFAULT_MATRIX_WORLD_AUTO_UPDATE = true;

	/** The ID of the 3D object. Don't modify. **/
	public var id:Int;

	/** The UUID of the 3D object. Don't modify**/
	public var uuid = generateUUID();

	/** An array holding the child 3D objects of this instance. **/
	public var children = new Array<Object3D>();

	/** The name of the 3D object. **/
	public var name = '';

	/** A reference to the parent object. **/
	public var parent:Object3D = null;

	/**
	* Defines the `up` direction of the 3D object which influences the orientation via methods like {@link Object3D#lookAt}.
	*
	* The default values for all 3D objects is defined by `Object3D.DEFAULT_UP`.@type {Vector3}
	*/
	public var up = Object3D.DEFAULT_UP.clone();

	/** Represents the object's local position. **/
	public var position = new Vector3();

	/** Represents the object's local rotation as Euler angles, in radians. **/
	public var rotation = new Euler();

	/** Represents the object's local rotation as Quaternions. **/
	public var quaternion = new Quaternion();
	
	/** Represents the object's local scale. **/
	public var scale = new Vector3( 1, 1, 1 );

	/** Represents the object's model-view matrix. **/
	public var modelViewMatrix = new Matrix4();

	/** Represents the object's normal matrix. **/
	public var normalMatrix = new Matrix3();

	/**
		* Represents the object's transformation matrix in local space.
		*
		* @type {Matrix4}
		*/
	public var matrix = new Matrix4();

	/**
		* Represents the object's transformation matrix in world space.
		* If the 3D object has no parent, then it's identical to the local transformation matrix
		*
		* @type {Matrix4}
		*/
	public var matrixWorld = new Matrix4();

	/**
		* When set to `true`, the engine automatically computes the local matrix from position,
		* rotation and scale every frame.
		*
		* The default values for all 3D objects is defined by `Object3D.DEFAULT_MATRIX_AUTO_UPDATE`.
		*
		* @type {boolean}
		* @default true
		*/
	public var matrixAutoUpdate = Object3D.DEFAULT_MATRIX_AUTO_UPDATE;

	/**
		* When set to `true`, the engine automatically computes the world matrix from the current local
		* matrix and the object's transformation hierarchy.
		*
		* The default values for all 3D objects is defined by `Object3D.DEFAULT_MATRIX_WORLD_AUTO_UPDATE`.
		*
		* @type {boolean}
		* @default true
		*/
	public var matrixWorldAutoUpdate = Object3D.DEFAULT_MATRIX_WORLD_AUTO_UPDATE; // checked by the renderer

	/**
		* When set to `true`, it calculates the world matrix in that frame and resets this property
		* to `false`.
		*
		* @type {boolean}
		* @default false
		*/
	public var matrixWorldNeedsUpdate = false;

	/**
		* The layer membership of the 3D object. The 3D object is only visible if it has
		* at least one layer in common with the camera in use. This property can also be
		* used to filter out unwanted objects in ray-intersection tests when using {@link Raycaster}.
		*
		* @type {Layers}
		*/
	public var layers = new Layers();

	/**
		* When set to `true`, the 3D object gets rendered.
		*
		* @type {boolean}
		* @default true
		*/
	public var visible = true;

	/**
		* When set to `true`, the 3D object gets rendered into shadow maps.
		*
		* @type {boolean}
		* @default false
		*/
	public var castShadow = false;

	/**
		* When set to `true`, the 3D object is affected by shadows in the scene.
		*
		* @type {boolean}
		* @default false
		*/
	public var receiveShadow = false;

	/**
		* When set to `true`, the 3D object is honored by view frustum culling.
		*
		* @type {boolean}
		* @default true
		*/
	public var frustumCulled = true;

	/**
		* This value allows the default rendering order of scene graph objects to be
		* overridden although opaque and transparent objects remain sorted independently.
		* When this property is set for an instance of {@link Group},all descendants
		* objects will be sorted and rendered together. Sorting is from lowest to highest
		* render order.
		*
		* @type {number}
		* @default 0
		*/
	public var renderOrder = 0;

	/**
		* An array holding the animation clips of the 3D object.
		*
		* @type {Array<AnimationClip>}
		*/
	public var animations = [];

	/**
		* Custom depth material to be used when rendering to the depth map. Can only be used
		* in context of meshes. When shadow-casting with a {@link DirectionalLight} or {@link SpotLight},
		* if you are modifying vertex positions in the vertex shader you must specify a custom depth
		* material for proper shadows.
		*
		* Only relevant in context of {@link WebGLRenderer}.
		*
		* @type {(Material|null)}
		* @default null
		*/
	public var customDepthMaterial = null;

	/**
		* Same as {@link Object3D#customDepthMaterial}, but used with {@link PointLight}.
		*
		* Only relevant in context of {@link WebGLRenderer}.
		*
		* @type {(Material|null)}
		* @default null
		*/
	public var customDistanceMaterial = null;

	/**
		* An object that can be used to store custom data about the 3D object. It
		* should not hold references to functions as these will not be cloned.
		*
		* @type {Object}
		*/
	public var userData = {};

	public var type(get, never):String;

	/** Constructs a new 3D object. **/
	public function new() {
		super();

		id = _object3DId;
		_object3DId += 1;

		function onRotationChange() {
			quaternion.setFromEuler( rotation, false );
		}

		function onQuaternionChange() {
			rotation.setFromQuaternion( quaternion, null, false );
		}

		rotation._onChange( onRotationChange );
		quaternion._onChange( onQuaternionChange );
	}

	/** Whether or not this object's update function is called **/
	public var active:Bool = true;

	/** Update function. Called on all children too **/
	public function update(elapsed:Float) {
		for (thing in children) {
			if (thing.active)
				thing.update(elapsed);
		}
	}

	/**
	 * A callback that is executed immediately before a 3D object is rendered to a shadow map.
	 *
	 * @param {Renderer|WebGLRenderer} renderer - The renderer.
	 * @param {Object3D} object - The 3D object.
	 * @param {Camera} camera - The camera that is used to render the scene.
	 * @param {Camera} shadowCamera - The shadow camera.
	 * @param {BufferGeometry} geometry - The 3D object's geometry.
	 * @param {Material} depthMaterial - The depth material.
	 * @param {Object} group - The geometry group data.
	 */
	public dynamic function onBeforeShadow( renderer, object, camera, shadowCamera, geometry, depthMaterial, group ) {}

	/**
	 * A callback that is executed immediately after a 3D object is rendered to a shadow map.
	 *
	 * @param {Renderer|WebGLRenderer} renderer - The renderer.
	 * @param {Object3D} object - The 3D object.
	 * @param {Camera} camera - The camera that is used to render the scene.
	 * @param {Camera} shadowCamera - The shadow camera.
	 * @param {BufferGeometry} geometry - The 3D object's geometry.
	 * @param {Material} depthMaterial - The depth material.
	 * @param {Object} group - The geometry group data.
	 */
	public dynamic function onAfterShadow( renderer, object, camera, shadowCamera, geometry, depthMaterial, group ) {}

	/**
	 * A callback that is executed immediately before a 3D object is rendered.
	 *
	 * @param {Renderer|WebGLRenderer} renderer - The renderer.
	 * @param {Object3D} object - The 3D object.
	 * @param {Camera} camera - The camera that is used to render the scene.
	 * @param {BufferGeometry} geometry - The 3D object's geometry.
	 * @param {Material} material - The 3D object's material.
	 * @param {Object} group - The geometry group data.
	 */
	public dynamic function onBeforeRender( renderer, scene, camera, geometry, material, group ) {}

	/**
	 * A callback that is executed immediately after a 3D object is rendered.
	 *
	 * @param {Renderer|WebGLRenderer} renderer - The renderer.
	 * @param {Object3D} object - The 3D object.
	 * @param {Camera} camera - The camera that is used to render the scene.
	 * @param {BufferGeometry} geometry - The 3D object's geometry.
	 * @param {Material} material - The 3D object's material.
	 * @param {Object} group - The geometry group data.
	 */
	public dynamic function onAfterRender( renderer, scene, camera, geometry, material, group ) {}

	/**
	 * Applies the given transformation matrix to the object and updates the object's position,
	 * rotation and scale.
	 *
	 * @param {Matrix4} matrix - The transformation matrix.
	 */
	public function applyMatrix4( matrix ) {

		if ( this.matrixAutoUpdate ) this.updateMatrix();

		this.matrix.premultiply( matrix );

		this.matrix.decompose( this.position, this.quaternion, this.scale );

	}

	/**
	 * Applies a rotation represented by given the quaternion to the 3D object.
	 *
	 * @param {Quaternion} q - The quaternion.
	 * @return {Object3D} A reference to this instance.
	 */
	public function applyQuaternion( q ) {

		this.quaternion.premultiply( q );

		return this;

	}

	/**
	 * Sets the given rotation represented as an axis/angle couple to the 3D object.
	 *
	 * @param {Vector3} axis - The (normalized) axis vector.
	 * @param {number} angle - The angle in radians.
	 */
	public function setRotationFromAxisAngle( axis, angle ) {

		// assumes axis is normalized

		this.quaternion.setFromAxisAngle( axis, angle );

	}

	/**
	 * Sets the given rotation represented as Euler angles to the 3D object.
	 *
	 * @param {Euler} euler - The Euler angles.
	 */
	public function setRotationFromEuler( euler ) {

		this.quaternion.setFromEuler( euler, true );

	}

	/**
	 * Sets the given rotation represented as rotation matrix to the 3D object.
	 *
	 * @param {Matrix4} m - Although a 4x4 matrix is expected, the upper 3x3 portion must be
	 * a pure rotation matrix (i.e, unscaled).
	 */
	public function setRotationFromMatrix( m ) {

		// assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

		this.quaternion.setFromRotationMatrix( m );

	}

	/**
	 * Sets the given rotation represented as a Quaternion to the 3D object.
	 *
	 * @param {Quaternion} q - The Quaternion
	 */
	public function setRotationFromQuaternion( q ) {

		// assumes q is normalized

		this.quaternion.copy( q );

	}

	/**
	 * Rotates the 3D object along an axis in local space.
	 *
	 * @param {Vector3} axis - The (normalized) axis vector.
	 * @param {number} angle - The angle in radians.
	 * @return {Object3D} A reference to this instance.
	 */
	public function rotateOnAxis( axis, angle ) {

		// rotate object on axis in object space
		// axis is assumed to be normalized

		_q1.setFromAxisAngle( axis, angle );

		this.quaternion.multiply( _q1 );

		return this;

	}

	/**
	 * Rotates the 3D object along an axis in world space.
	 *
	 * @param {Vector3} axis - The (normalized) axis vector.
	 * @param {number} angle - The angle in radians.
	 * @return {Object3D} A reference to this instance.
	 */
	public function rotateOnWorldAxis( axis, angle ) {

		// rotate object on axis in world space
		// axis is assumed to be normalized
		// method assumes no rotated parent

		_q1.setFromAxisAngle( axis, angle );

		this.quaternion.premultiply( _q1 );

		return this;

	}

	/**
	 * Rotates the 3D object around its X axis in local space.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {Object3D} A reference to this instance.
	 */
	public function rotateX( angle ) {

		return this.rotateOnAxis( _xAxis, angle );

	}

	/**
	 * Rotates the 3D object around its Y axis in local space.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {Object3D} A reference to this instance.
	 */
	public function rotateY( angle ) {

		return this.rotateOnAxis( _yAxis, angle );

	}

	/**
	 * Rotates the 3D object around its Z axis in local space.
	 *
	 * @param {number} angle - The angle in radians.
	 * @return {Object3D} A reference to this instance.
	 */
	public function rotateZ( angle ) {

		return this.rotateOnAxis( _zAxis, angle );

	}

	/**
	 * Translate the 3D object by a distance along the given axis in local space.
	 *
	 * @param {Vector3} axis - The (normalized) axis vector.
	 * @param {number} distance - The distance in world units.
	 * @return {Object3D} A reference to this instance.
	 */
	public function translateOnAxis( axis, distance ) {

		// translate object by distance along axis in object space
		// axis is assumed to be normalized

		_v1.copy( axis ).applyQuaternion( this.quaternion );

		this.position.add( _v1.multiplyScalar( distance ) );

		return this;

	}

	/**
	 * Translate the 3D object by a distance along its X-axis in local space.
	 *
	 * @param {number} distance - The distance in world units.
	 * @return {Object3D} A reference to this instance.
	 */
	public function translateX( distance ) {

		return this.translateOnAxis( _xAxis, distance );

	}

	/**
	 * Translate the 3D object by a distance along its Y-axis in local space.
	 *
	 * @param {number} distance - The distance in world units.
	 * @return {Object3D} A reference to this instance.
	 */
	public function translateY( distance ) {

		return this.translateOnAxis( _yAxis, distance );

	}

	/**
	 * Translate the 3D object by a distance along its Z-axis in local space.
	 *
	 * @param {number} distance - The distance in world units.
	 * @return {Object3D} A reference to this instance.
	 */
	public function translateZ( distance ) {

		return this.translateOnAxis( _zAxis, distance );

	}

	/**
	 * Converts the given vector from this 3D object's local space to world space.
	 *
	 * @param {Vector3} vector - The vector to convert.
	 * @return {Vector3} The converted vector.
	 */
	public function localToWorld( vector ) {

		this.updateWorldMatrix( true, false );

		return vector.applyMatrix4( this.matrixWorld );

	}

	/**
	 * Converts the given vector from this 3D object's word space to local space.
	 *
	 * @param {Vector3} vector - The vector to convert.
	 * @return {Vector3} The converted vector.
	 */
	public function worldToLocal( vector ) {

		this.updateWorldMatrix( true, false );

		return vector.applyMatrix4( _m1.copy( this.matrixWorld ).invert() );

	}

	/**
	 * Rotates the object to face a point in world space.
	 *
	 * This method does not support objects having non-uniformly-scaled parent(s).
	 *
	 * @param {number|Vector3} x - The x coordinate in world space. Alternatively, a vector representing a position in world space
	 * @param {number} [y] - The y coordinate in world space.
	 * @param {number} [z] - The z coordinate in world space.
	 */
	public function lookAt( x, ?y, ?z ) {

		// This method does not support objects having non-uniformly-scaled parent(s)

		if ( Std.isOfType(x, Vector3) ) {
			_target.copy( x );
		} else {
			_target.set( cast(x, Float), y, z );
		}

		var parent = this.parent;

		this.updateWorldMatrix( true, false );

		_position.setFromMatrixPosition( this.matrixWorld );

		if ( Std.downcast(this, Camera) != null ) { //TODO: this.isCamera || this.isLight

			_m1.lookAt( _position, _target, this.up );

		} else {

			_m1.lookAt( _target, _position, this.up );

		}

		this.quaternion.setFromRotationMatrix( _m1 );

		if ( parent != null ) {

			_m1.extractRotation( parent.matrixWorld );
			_q1.setFromRotationMatrix( _m1 );
			this.quaternion.premultiply( _q1.invert() );

		}

	}

	/**
	 * Adds the given 3D object as a child to this 3D object. An arbitrary number of
	 * objects may be added. Any current parent on an object passed in here will be
	 * removed, since an object can have at most one parent.
	 *
	 * @fires Object3D#added
	 * @fires Object3D#childadded
	 * @param {Object3D} object - The 3D object to add.
	 * @return {Object3D} A reference to this instance.
	 */
	public function add( object:Object3D, ...arguments:Object3D ) {

		if ( object == this ) {
			Common.error( 'THREE.Object3D.add: object can\'t be added as a child of itself.', object );
			return this;
		}

		if ( true ) { //TODO: object && object.isObject3D
			object.removeFromParent();
			object.parent = this;
			this.children.push( object );

			object.dispatchEvent( _addedEvent );

			_childaddedEvent.child = object;
			this.dispatchEvent( _childaddedEvent );
			_childaddedEvent.child = null;
		} else {
			Common.error( 'THREE.Object3D.add: object not an instance of THREE.Object3D.', object );
		}

		if ( arguments.length != 0 ) {
			for ( i in 0...arguments.length ) {
				this.add( arguments[ i ] );
			}
		}

		return this;

	}

	/**
	 * Removes the given 3D object as child from this 3D object.
	 * An arbitrary number of objects may be removed.
	 *
	 * @fires Object3D#removed
	 * @fires Object3D#childremoved
	 * @param {Object3D} object - The 3D object to remove.
	 * @return {Object3D} A reference to this instance.
	 */
	public function remove( object:Object3D, ...arguments:Object3D ) {
		if ( arguments.length != 0 ) {
			for ( i in 0...arguments.length ) {
				this.remove( arguments[ i ] );
			}

			return this;
		}

		var index = this.children.indexOf( object );

		if ( index != -1 ) {
			object.parent = null;
			this.children.splice( index, 1 );

			object.dispatchEvent( _removedEvent );

			_childremovedEvent.child = object;
			this.dispatchEvent( _childremovedEvent );
			_childremovedEvent.child = null;
		}

		return this;
	}

	/**
	 * Removes this 3D object from its current parent.
	 *
	 * @fires Object3D#removed
	 * @fires Object3D#childremoved
	 * @return {Object3D} A reference to this instance.
	 */
	public function removeFromParent() {
		var parent = this.parent;

		if ( parent != null )
			parent.remove( this );

		return this;
	}

	/**
	 * Removes all child objects.
	 *
	 * @fires Object3D#removed
	 * @fires Object3D#childremoved
	 * @return {Object3D} A reference to this instance.
	 */
	public function clear() {
		for (thing in this.children)
			this.remove( thing );
		return this;
	}

	/**
	 * Adds the given 3D object as a child of this 3D object, while maintaining the object's world
	 * transform. This method does not support scene graphs having non-uniformly-scaled nodes(s).
	 *
	 * @fires Object3D#added
	 * @fires Object3D#childadded
	 * @param {Object3D} object - The 3D object to attach.
	 * @return {Object3D} A reference to this instance.
	 */
	public function attach( object ) {
		// adds object as a child of this, while maintaining the object's world transform

		// Note: This method does not support scene graphs having non-uniformly-scaled nodes(s)

		this.updateWorldMatrix( true, false );

		_m1.copy( this.matrixWorld ).invert();

		if ( object.parent != null ) {
			object.parent.updateWorldMatrix( true, false );

			_m1.multiply( object.parent.matrixWorld );
		}

		object.applyMatrix4( _m1 );

		object.removeFromParent();
		object.parent = this;
		this.children.push( object );

		object.updateWorldMatrix( false, true );

		object.dispatchEvent( _addedEvent );

		_childaddedEvent.child = object;
		this.dispatchEvent( _childaddedEvent );
		_childaddedEvent.child = null;

		return this;
	}

	/**
	 * Searches through the 3D object and its children, starting with the 3D object
	 * itself, and returns the first with a matching ID.
	 *
	 * @param {number} id - The id.
	 * @return {Object3D|null} The found 3D object. Returns `null` if no 3D object has been found.
	 */
	public function getObjectById( id ) {
		return this.getObjectByProperty( 'id', id );
	}

	/**
	 * Searches through the 3D object and its children, starting with the 3D object
	 * itself, and returns the first with a matching name.
	 *
	 * @param {string} name - The name.
	 * @return {Object3D|null} The found 3D object. Returns `null` if no 3D object has been found.
	 */
	public function getObjectByName( name ) {
		return this.getObjectByProperty( 'name', name );
	}

	/**
	 * Searches through the 3D object and its children, starting with the 3D object
	 * itself, and returns the first with a matching property value.
	 *
	 * @param {string} name - The name of the property.
	 * @param {any} value - The value.
	 * @return {Object3D|null} The found 3D object. Returns `null` if no 3D object has been found.
	 */
	public function getObjectByProperty( name:String, value ) {
		if ( Reflect.field(this, name) == value ) return this;

		for ( i in 0...this.children.length ) {
			var child = this.children[ i ];
			var object = child.getObjectByProperty( name, value );

			if ( object != null )
				return object;
		}

		return null;
	}

	/**
	 * Searches through the 3D object and its children, starting with the 3D object
	 * itself, and returns all 3D objects with a matching property value.
	 *
	 * @param {string} name - The name of the property.
	 * @param {any} value - The value.
	 * @param {Array<Object3D>} result - The method stores the result in this array.
	 * @return {Array<Object3D>} The found 3D objects.
	 */
	public function getObjectsByProperty( name:String, value:Dynamic, result:Null<Array<Object3D>> ) {
		if (result == null)
			result = [];

		if ( Reflect.field(this, name) == value ) result.push( this );
		var children = this.children;

		for ( i in 0...children.length )
			children[ i ].getObjectsByProperty( name, value, result );

		return result;
	}

	/**
	 * Returns a vector representing the position of the 3D object in world space.
	 *
	 * @param {Vector3} target - The target vector the result is stored to.
	 * @return {Vector3} The 3D object's position in world space.
	 */
	public function getWorldPosition( target ) {
		this.updateWorldMatrix( true, false );

		return target.setFromMatrixPosition( this.matrixWorld );
	}

	/**
	 * Returns a Quaternion representing the position of the 3D object in world space.
	 *
	 * @param {Quaternion} target - The target Quaternion the result is stored to.
	 * @return {Quaternion} The 3D object's rotation in world space.
	 */
	public function getWorldQuaternion( target ) {
		this.updateWorldMatrix( true, false );

		this.matrixWorld.decompose( _position, target, _scale );

		return target;
	}

	/**
	 * Returns a vector representing the scale of the 3D object in world space.
	 *
	 * @param {Vector3} target - The target vector the result is stored to.
	 * @return {Vector3} The 3D object's scale in world space.
	 */
	public function getWorldScale( target ) {
		this.updateWorldMatrix( true, false );

		this.matrixWorld.decompose( _position, _quaternion, target );

		return target;
	}

	/**
	 * Returns a vector representing the ("look") direction of the 3D object in world space.
	 *
	 * @param {Vector3} target - The target vector the result is stored to.
	 * @return {Vector3} The 3D object's direction in world space.
	 */
	public function getWorldDirection( target:Vector3 ):Vector3 {
		this.updateWorldMatrix( true, false );

		var e = this.matrixWorld.elements;

		return target.set( e[ 8 ], e[ 9 ], e[ 10 ] ).normalize();
	}

	/**
	 * Abstract method to get intersections between a casted ray and this
	 * 3D object. Renderable 3D objects such as {@link Mesh}, {@link Line} or {@link Points}
	 * implement this method in order to use raycasting.
	 *
	 * @abstract
	 * @param {Raycaster} raycaster - The raycaster.
	 * @param {Array<Object>} intersects - An array holding the result of the method.
	 */
	public dynamic function raycast( raycaster, intersects ) {}

	/**
	 * Executes the callback on this 3D object and all descendants.
	 *
	 * Note: Modifying the scene graph inside the callback is discouraged.
	 *
	 * @param {Function} callback - A callback function that allows to process the current 3D object.
	 */
	public function traverse( callback ) {
		callback( this );

		var children = this.children;

		for ( i in 0...children.length ) {
			children[ i ].traverse( callback );
		}
	}

	/**
	 * Like {@link Object3D#traverse}, but the callback will only be executed for visible 3D objects.
	 * Descendants of invisible 3D objects are not traversed.
	 *
	 * Note: Modifying the scene graph inside the callback is discouraged.
	 *
	 * @param {Function} callback - A callback function that allows to process the current 3D object.
	 */
	public function traverseVisible( callback ) {
		if ( this.visible == false ) return;

		callback( this );

		var children = this.children;

		for ( i in 0...children.length ) 
			children[ i ].traverseVisible( callback );
	}

	/**
	 * Like {@link Object3D#traverse}, but the callback will only be executed for all ancestors.
	 *
	 * Note: Modifying the scene graph inside the callback is discouraged.
	 *
	 * @param {Function} callback - A callback function that allows to process the current 3D object.
	 */
	public function traverseAncestors( callback ) {
		var parent = this.parent;

		if ( parent != null ) {
			callback( parent );

			parent.traverseAncestors( callback );
		}
	}

	/**
	 * Updates the transformation matrix in local space by computing it from the current
	 * position, rotation and scale values.
	 */
	public function updateMatrix() {
		this.matrix.compose( this.position, this.quaternion, this.scale );

		this.matrixWorldNeedsUpdate = true;
	}

	/**
	 * Updates the transformation matrix in world space of this 3D objects and its descendants.
	 *
	 * To ensure correct results, this method also recomputes the 3D object's transformation matrix in
	 * local space. The computation of the local and world matrix can be controlled with the
	 * {@link Object3D#matrixAutoUpdate} and {@link Object3D#matrixWorldAutoUpdate} flags which are both
	 * `true` by default.  Set these flags to `false` if you need more control over the update matrix process.
	 *
	 * @param {boolean} [force=false] - When set to `true`, a recomputation of world matrices is forced even
	 * when {@link Object3D#matrixWorldAutoUpdate} is set to `false`.
	 */
	public function updateMatrixWorld( force ) {
		if ( this.matrixAutoUpdate ) this.updateMatrix();

		if ( this.matrixWorldNeedsUpdate || force ) {
			if ( this.matrixWorldAutoUpdate == true ) {
				if ( this.parent == null )
					this.matrixWorld.copy( this.matrix );
				else
					this.matrixWorld.multiplyMatrices( this.parent.matrixWorld, this.matrix );
			}

			this.matrixWorldNeedsUpdate = false;

			force = true;
		}

		// make sure descendants are updated if required

		var children = this.children;

		for ( i in 0...children.length ) {
			var child = children[ i ];

			child.updateMatrixWorld( force );
		}
	}

	/**
	 * An alternative version of {@link Object3D#updateMatrixWorld} with more control over the
	 * update of ancestor and descendant nodes.
	 *
	 * @param {boolean} [updateParents=false] Whether ancestor nodes should be updated or not.
	 * @param {boolean} [updateChildren=false] Whether descendant nodes should be updated or not.
	 */
	public function updateWorldMatrix( updateParents, updateChildren ) {
		var parent = this.parent;

		if ( updateParents == true && parent != null )
			parent.updateWorldMatrix( true, false );

		if ( this.matrixAutoUpdate ) this.updateMatrix();

		if ( this.matrixWorldAutoUpdate == true ) {
			if ( this.parent == null )
				this.matrixWorld.copy( this.matrix );
			else
				this.matrixWorld.multiplyMatrices( this.parent.matrixWorld, this.matrix );
		}

		// make sure descendants are updated

		if ( updateChildren == true ) {
			var children = this.children;

			for ( i in 0...children.length ) {
				var child = children[ i ];

				child.updateWorldMatrix( false, true );
			}
		}
	}

	/**
	 * Serializes the 3D object into JSON.
	 *
	 * @param meta An optional value holding meta information about the serialization.
	 * @return A JSON object representing the serialized 3D object.
	 * @see {@link ObjectLoader#parse}
	 */
	public function toJSON( ?meta:Dynamic ):Dynamic {
		// meta is a string when called from JSON.stringify
		var isRootObject = ( meta == null || Std.isOfType(meta, String) );

		var output = {
			object: null,
			animations: null,
			nodes: null,
			shapes: null,
			images: null,
			textures: null,
			materials: null,
			geometries: null,
			skeletons: null,
			metadata: null
		};

		// meta is a hash used to collect geometries, materials.
		// not providing it implies that this is the root object
		// being serialized.
		if ( isRootObject ) {
			// initialize meta obj
			meta = {
				geometries: {},
				materials: {},
				textures: {},
				images: {},
				shapes: {},
				skeletons: {},
				animations: {},
				nodes: {}
			};

			output.metadata = {
				version: 4.6,
				type: 'Object',
				generator: 'Object3D.toJSON'
			};
		}

		// standard Object3D serialization

		var object:Dynamic = {};

		object.uuid = this.uuid;
		object.type = this.type;

		if ( this.name != '' ) object.name = this.name;
		if ( this.castShadow == true ) object.castShadow = true;
		if ( this.receiveShadow == true ) object.receiveShadow = true;
		if ( this.visible == false ) object.visible = false;
		if ( this.frustumCulled == false ) object.frustumCulled = false;
		if ( this.renderOrder != 0 ) object.renderOrder = this.renderOrder;
		if ( Reflect.fields( this.userData ).length > 0 ) object.userData = this.userData;

		object.layers = this.layers.mask;
		object.matrix = this.matrix.toArray();
		object.up = this.up.toArray();

		if ( this.matrixAutoUpdate == false ) object.matrixAutoUpdate = false;

		// object specific properties

		//TODO:
		/*if ( this.isInstancedMesh ) {
			object.type = 'InstancedMesh';
			object.count = this.count;
			object.instanceMatrix = this.instanceMatrix.toJSON();
			if ( this.instanceColor != null ) object.instanceColor = this.instanceColor.toJSON();
		}*/

		//TODO:
		/*if ( this.isBatchedMesh ) {
			object.type = 'BatchedMesh';
			object.perObjectFrustumCulled = this.perObjectFrustumCulled;
			object.sortObjects = this.sortObjects;

			object.drawRanges = this._drawRanges;
			object.reservedRanges = this._reservedRanges;

			object.geometryInfo = this._geometryInfo.map(function(info) {
				var obj = Reflect.copy(obj);
				obj.boundingBox = info.boundingBox ? {
					min: info.boundingBox.min.toArray(),
					max: info.boundingBox.max.toArray()
				} : null;
				obj.boundingSphere = info.boundingSphere ? {
					radius: info.boundingSphere.radius,
					center: info.boundingSphere.center.toArray()
				} : null;
				return obj;
			});
			object.instanceInfo = this._instanceInfo.map(function(info) {
				return Reflect.copy(info);
			});

			object.availableInstanceIds = this._availableInstanceIds.copy();
			object.availableGeometryIds = this._availableGeometryIds.copy();

			object.nextIndexStart = this._nextIndexStart;
			object.nextVertexStart = this._nextVertexStart;
			object.geometryCount = this._geometryCount;

			object.maxInstanceCount = this._maxInstanceCount;
			object.maxVertexCount = this._maxVertexCount;
			object.maxIndexCount = this._maxIndexCount;

			object.geometryInitialized = this._geometryInitialized;

			object.matricesTexture = this._matricesTexture.toJSON( meta );

			object.indirectTexture = this._indirectTexture.toJSON( meta );

			if ( this._colorsTexture != null ) {
				object.colorsTexture = this._colorsTexture.toJSON( meta );
			}

			if ( this.boundingSphere != null ) {
				object.boundingSphere = {
					center: this.boundingSphere.center.toArray(),
					radius: this.boundingSphere.radius
				};
			}

			if ( this.boundingBox != null ) {
				object.boundingBox = {
					min: this.boundingBox.min.toArray(),
					max: this.boundingBox.max.toArray()
				};
			}
		}*/

		//

		function serialize( library, element ) {
			if ( library[ element.uuid ] == null ) {
				library[ element.uuid ] = element.toJSON( meta );
			}

			return element.uuid;
		}

		if ( Std.isOfType(this, Scene) ) {
			var sc:Scene = cast this;
			if ( sc.background != null ) {
				if ( sc.background.isColor ) {
					object.background = sc.background.toJSON();
				} else if ( sc.background.isTexture ) {
					object.background = sc.background.toJSON( meta ).uuid;
				}
			}

			if ( this.environment && this.environment.isTexture && this.environment.isRenderTargetTexture != true ) {
				object.environment = this.environment.toJSON( meta ).uuid;
			}

		} else if ( Std.downcast(this, Mesh) != null ) { //TODO: this.isMesh || this.isLine || this.isPoints
			object.geometry = serialize( meta.geometries, this.geometry );
			var parameters = this.geometry.parameters;

			if ( parameters != null && parameters.shapes != null ) {
				var shapes = parameters.shapes;

				if ( Std.isOfType( shapes, Array ) ) {
					for ( i in 0...shapes.length ) {
						var shape = shapes[ i ];

						serialize( meta.shapes, shape );
					}
				} else {
					serialize( meta.shapes, shapes );
				}
			}
		}

		if ( false ) { //TODO: isSkinnedMesh
			/*object.bindMode = this.bindMode;
			object.bindMatrix = this.bindMatrix.toArray();

			if ( this.skeleton != null ) {
				serialize( meta.skeletons, this.skeleton );
				object.skeleton = this.skeleton.uuid;
			}*/
		}

		if ( this.material != null ) {
			if ( Std.isOfType( this.material, Array ) ) {
				var uuids = [];
				for ( i in 0...this.material.length )
					uuids.push( serialize( meta.materials, this.material[ i ] ) );
				
				object.material = uuids;
			} else {
				object.material = serialize( meta.materials, this.material );
			}
		}

		//

		if ( this.children.length > 0 ) {
			object.children = [];
			for ( i in 0...this.children.length ) {
				object.children.push( this.children[ i ].toJSON( meta ).object );
			}
		}

		//

		if ( this.animations.length > 0 ) {
			object.animations = [];

			for ( i in 0...this.animations.length ) {
				var animation = this.animations[ i ];
				object.animations.push( serialize( meta.animations, animation ) );
			}
		}

		if ( isRootObject ) {
			// extract data from the cache hash
			// remove metadata on each item
			// and return as array
			function extractFromCache( cache:Dynamic ) {
				var values = [];
				for ( key in Reflect.fields(cache) ) {
					var data = Reflect.field(cache, key);
					Reflect.deleteField(data, "metadata");
					values.push( data );
				}

				return values;
			}

			var geometries = extractFromCache( meta.geometries );
			var materials = extractFromCache( meta.materials );
			var textures = extractFromCache( meta.textures );
			var images = extractFromCache( meta.images );
			var shapes = extractFromCache( meta.shapes );
			var skeletons = extractFromCache( meta.skeletons );
			var animations = extractFromCache( meta.animations );
			var nodes = extractFromCache( meta.nodes );

			if ( geometries.length > 0 ) output.geometries = geometries;
			if ( materials.length > 0 ) output.materials = materials;
			if ( textures.length > 0 ) output.textures = textures;
			if ( images.length > 0 ) output.images = images;
			if ( shapes.length > 0 ) output.shapes = shapes;
			if ( skeletons.length > 0 ) output.skeletons = skeletons;
			if ( animations.length > 0 ) output.animations = animations;
			if ( nodes.length > 0 ) output.nodes = nodes;
		}

		output.object = object;

		return output;
	}

	/**
	 * Returns a new 3D object with copied values from this instance.
	 *
	 * @param When set to `true`, descendants of the 3D object are also cloned.
	 * @return A clone of this instance.
	 */
	public function clone(?recursive:Bool = true):Dynamic {
		return Type.createInstance(Type.getClass(this), new Array<Dynamic>()).copy( this, recursive );
	}

	/**
	 * Copies the values of the given 3D object to this instance.
	 *
	 * @param {Object3D} source - The 3D object to copy.
	 * @param {boolean} [recursive=true] - When set to `true`, descendants of the 3D object are cloned.
	 * @return {Object3D} A reference to this instance.
	 */
	public function copy( source:Dynamic, ?recursive:Bool = true ):Dynamic {
		this.name = source.name;

		this.up.copy( source.up );

		this.position.copy( source.position );
		this.rotation.order = source.rotation.order;
		this.quaternion.copy( source.quaternion );
		this.scale.copy( source.scale );

		this.matrix.copy( source.matrix );
		this.matrixWorld.copy( source.matrixWorld );

		this.matrixAutoUpdate = source.matrixAutoUpdate;

		this.matrixWorldAutoUpdate = source.matrixWorldAutoUpdate;
		this.matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate;

		this.layers.mask = source.layers.mask;
		this.visible = source.visible;

		this.castShadow = source.castShadow;
		this.receiveShadow = source.receiveShadow;

		this.frustumCulled = source.frustumCulled;
		this.renderOrder = source.renderOrder;

		this.animations = source.animations.copy();

		this.userData = JSON.parse( JSON.stringify( source.userData ) );

		if ( recursive ) {
			for ( i in 0...source.children.length ) {
				var child = source.children[ i ];
				this.add( child.clone() );
			}
		}

		return this;
	}

	function get_type() {
		return Common.typeName(this);
	}

	/** Fires when the object has been added to its parent object. **/
	static var _addedEvent:Event = { type: 'added' };

	/** Fires when the object has been removed from its parent object. **/
	static var _removedEvent:Event = { type: 'removed' };

	/** Fires when a new child object has been added. **/
	static var _childaddedEvent:Event = { type: 'childadded', child: null };

	/** Fires when a new child object has been added. **/
	static var _childremovedEvent:Event = { type: 'childremoved', child: null };

	static var _object3DId = 0;

	static var _v1 = /*@__PURE__*/ new Vector3();
	static var _q1 = /*@__PURE__*/ new Quaternion();
	static var _m1 = /*@__PURE__*/ new Matrix4();
	static var _target = /*@__PURE__*/ new Vector3();

	static var _position = /*@__PURE__*/ new Vector3();
	static var _scale = /*@__PURE__*/ new Vector3();
	static var _quaternion = /*@__PURE__*/ new Quaternion();

	static var _xAxis = /*@__PURE__*/ new Vector3( 1, 0, 0 );
	static var _yAxis = /*@__PURE__*/ new Vector3( 0, 1, 0 );
	static var _zAxis = /*@__PURE__*/ new Vector3( 0, 0, 1 );
}