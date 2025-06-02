package vman2002.vthreehx.scenes;

import vman2002.vthreehx.materials.Material;
import vman2002.vthreehx.textures.Texture;
import vman2002.vthreehx.core.Object3D;
import vman2002.vthreehx.math.Euler;

/**
 * Scenes allow you to set up what is to be rendered and where by three.js.
 * This is where you place 3D objects like meshes, lines or lights.
 *
 * @augments Object3D
 */
class Scene extends Object3D {
    /**
    * Defines the background of the scene. Valid inputs are:
    *
    * - A color for defining a uniform colored background.
    * - A texture for defining a (flat) textured background.
    * - Cube textures or equirectangular textures for defining a skybox.
    *
    * @type {?(Color|Texture)}
    * @default null
    */
    public var background:Dynamic = null;

    /**
    * Sets the environment map for all physical materials in the scene. However,
    * it's not possible to overwrite an existing texture assigned to the `envMap`
    * material property.
    *
    * @type {?Texture}
    * @default null
    */
    public var environment:Texture = null;

    /**
    * A fog instance defining the type of fog that affects everything
    * rendered in the scene.
    *
    * @type {?(Fog|FogExp2)}
    * @default null
    */
    public var fog = null;

    /**
    * Sets the blurriness of the background. Only influences environment maps
    * assigned to {@link Scene#background}. Valid input is a float between `0`
    * and `1`.
    *
    * @type {number}
    * @default 0
    */
    public var backgroundBlurriness:Float = 0;

    /**
    * Attenuates the color of the background. Only applies to background textures.
    *
    * @type {number}
    * @default 1
    */
    public var backgroundIntensity:Float = 1;

    /**
    * The rotation of the background in radians. Only influences environment maps
    * assigned to {@link Scene#background}.
    *
    * @type {Euler}
    * @default (0,0,0)
    */
    public var backgroundRotation = new Euler();

    /**
    * Attenuates the color of the environment. Only influences environment maps
    * assigned to {@link Scene#environment}.
    *
    * @type {number}
    * @default 1
    */
    public var environmentIntensity:Float = 1;

    /**
    * The rotation of the environment map in radians. Only influences physical materials
    * in the scene when {@link Scene#environment} is used.
    *
    * @type {Euler}
    * @default (0,0,0)
    */
    public var environmentRotation = new Euler();

    /**
    * Forces everything in the scene to be rendered with the defined material. It is possible
    * to exclude materials from override by setting {@link Material#allowOverride} to `false`.
    *
    * @type {?Material}
    * @default null
    */
    public var overrideMaterial:Material = null;

	/**
	 * Constructs a new scene.
	 */
	public function new() {
		super();

        //TODO: what is this
		/*if ( typeof __THREE_DEVTOOLS__ !== 'undefined' ) {

			__THREE_DEVTOOLS__.dispatchEvent( new CustomEvent( 'observe', { detail: this } ) );

		}*/

	}

	public override function copy( source:Dynamic, ?recursive:Bool = true ):Dynamic {

		super.copy( source, recursive );

		if ( source.background != null ) this.background = source.background.clone();
		if ( source.environment != null ) this.environment = source.environment.clone();
		if ( source.fog != null ) this.fog = source.fog.clone();

		this.backgroundBlurriness = source.backgroundBlurriness;
		this.backgroundIntensity = source.backgroundIntensity;
		this.backgroundRotation.copy( source.backgroundRotation );

		this.environmentIntensity = source.environmentIntensity;
		this.environmentRotation.copy( source.environmentRotation );

		if ( source.overrideMaterial != null ) this.overrideMaterial = source.overrideMaterial.clone();

		this.matrixAutoUpdate = source.matrixAutoUpdate;

		return this;

	}

	public override function toJSON( ?meta:Dynamic ):Dynamic {
		var data = super.toJSON( meta );

		if ( this.fog != null ) data.object.fog = this.fog.toJSON();

		if ( this.backgroundBlurriness > 0 ) data.object.backgroundBlurriness = this.backgroundBlurriness;
		if ( this.backgroundIntensity != 1 ) data.object.backgroundIntensity = this.backgroundIntensity;
		data.object.backgroundRotation = this.backgroundRotation.toArray();

		if ( this.environmentIntensity != 1 ) data.object.environmentIntensity = this.environmentIntensity;
		data.object.environmentRotation = this.environmentRotation.toArray();

		return data;
	}
}