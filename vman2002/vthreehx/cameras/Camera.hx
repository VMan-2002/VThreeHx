package vman2002.vthreehx.cameras;

import vman2002.vthreehx.Constants.WebGLCoordinateSystem in WebGLCoordinateSystem;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.core.Object3D;

/**
 * Abstract base class for cameras. This class should always be inherited
 * when you build a new camera.
 *
 * @abstract
 * @augments Object3D
 */
class Camera extends Object3D {
    /**
    * The inverse of the camera's world matrix.
    *
    * @type {Matrix4}
    */
    public var matrixWorldInverse = new Matrix4();

    /**
    * The camera's projection matrix.
    *
    * @type {Matrix4}
    */
    public var projectionMatrix = new Matrix4();

    /**
    * The inverse of the camera's projection matrix.
    *
    * @type {Matrix4}
    */
    public var projectionMatrixInverse = new Matrix4();

    /**
    * The coordinate system in which the camera is used.
    *
    * @type {(WebGLCoordinateSystem|WebGPUCoordinateSystem)}
    */
    public var coordinateSystem = WebGLCoordinateSystem;

	/**
	 * Constructs a new camera.
	 */
	public function new() {
		super();
	}

	public override function copy( source:Dynamic, ?recursive:Bool = true ):Dynamic {
		super.copy( source, recursive );

		this.matrixWorldInverse.copy( source.matrixWorldInverse );

		this.projectionMatrix.copy( source.projectionMatrix );
		this.projectionMatrixInverse.copy( source.projectionMatrixInverse );

		this.coordinateSystem = source.coordinateSystem;

		return this;
	}

	/**
	 * Returns a vector representing the ("look") direction of the 3D object in world space.
	 *
	 * This method is overwritten since cameras have a different forward vector compared to other
	 * 3D objects. A camera looks down its local, negative z-axis by default.
	 *
	 * @param {Vector3} target - The target vector the result is stored to.
	 * @return {Vector3} The 3D object's direction in world space.
	 */
	public override function getWorldDirection( target:Vector3 ):Vector3 {
		return super.getWorldDirection( target ).negate();
	}

	public override function updateMatrixWorld( force ) {
		super.updateMatrixWorld( force );

		this.matrixWorldInverse.copy( this.matrixWorld ).invert();
	}

	public override function updateWorldMatrix( updateParents, updateChildren ) {
		super.updateWorldMatrix( updateParents, updateChildren );

		this.matrixWorldInverse.copy( this.matrixWorld ).invert();
	}
}