package vman2002.vthreehx.materials;

import vman2002.vthreehx.textures.Texture;
import vman2002.vthreehx.math.Vector3;
import haxe.Json;
import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.interfaces.GetType;
import vman2002.vthreehx.math.Color;
import vman2002.vthreehx.core.EventDispatcher;
import vman2002.vthreehx.Constants.FrontSide;
import vman2002.vthreehx.Constants.NormalBlending;
import vman2002.vthreehx.Constants.LessEqualDepth;
import vman2002.vthreehx.Constants.AddEquation;
import vman2002.vthreehx.Constants.OneMinusSrcAlphaFactor;
import vman2002.vthreehx.Constants.SrcAlphaFactor;
import vman2002.vthreehx.Constants.AlwaysStencilFunc;
import vman2002.vthreehx.Constants.KeepStencilOp;
import vman2002.vthreehx.math.MathUtils.generateUUID;

/**
 * Abstract base class for materials.
 *
 * Materials define the appearance of renderable 3D objects.
 *
 * @abstract
 * @augments EventDispatcher
 */
class Material extends EventDispatcher implements GetType {

		/**
		 * The ID of the material.
		 *
		 * @name Material#id
		 * @type {number}
		 * @readonly
		 */
		public var id:Int = _materialId += 1;

		/**
		 * The UUID of the material.
		 *
		 * @type {string}
		 * @readonly
		 */
		public var uuid = generateUUID();

		/**
		 * The name of the material.
		 *
		 * @type {string}
		 */
		public var name = '';

		/**
		 * Defines the blending type of the material.
		 *
		 * It must be set to `CustomBlending` if custom blending properties like
		 * {@link Material#blendSrc}, {@link Material#blendDst} or {@link Material#blendEquation}
		 * should have any effect.
		 *
		 * @type {(NoBlending|NormalBlending|AdditiveBlending|SubtractiveBlending|MultiplyBlending|CustomBlending)}
		 * @default NormalBlending
		 */
		public var blending = NormalBlending;

		/**
		 * Defines which side of faces will be rendered - front, back or both.
		 *
		 * @type {(FrontSide|BackSide|DoubleSide)}
		 * @default FrontSide
		 */
		public var side = FrontSide;

		/**
		 * If set to `true`, vertex colors should be used.
		 *
		 * The engine supports RGB and RGBA vertex colors depending on whether a three (RGB) or
		 * four (RGBA) component color buffer attribute is used.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var vertexColors = false;

		/**
		 * Defines how transparent the material is.
		 * A value of `0.0` indicates fully transparent, `1.0` is fully opaque.
		 *
		 * If the {@link Material#transparent} is not set to `true`,
		 * the material will remain fully opaque and this value will only affect its color.
		 *
		 * @type {number}
		 * @default 1
		 */
		public var opacity:Float = 1;

		/**
		 * Defines whether this material is transparent. This has an effect on
		 * rendering as transparent objects need special treatment and are rendered
		 * after non-transparent objects.
		 *
		 * When set to true, the extent to which the material is transparent is
		 * controlled by {@link Material#opacity}.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var transparent = false;

		/**
		 * Enables alpha hashed transparency, an alternative to {@link Material#transparent} or
		 * {@link Material#alphaTest}. The material will not be rendered if opacity is lower than
		 * a random threshold. Randomization introduces some grain or noise, but approximates alpha
		 * blending without the associated problems of sorting. Using TAA can reduce the resulting noise.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var alphaHash = false;

		/**
		 * Defines the blending source factor.
		 *
		 * @type {(ZeroFactor|OneFactor|SrcColorFactor|OneMinusSrcColorFactor|SrcAlphaFactor|OneMinusSrcAlphaFactor|DstAlphaFactor|OneMinusDstAlphaFactor|DstColorFactor|OneMinusDstColorFactor|SrcAlphaSaturateFactor|ConstantColorFactor|OneMinusConstantColorFactor|ConstantAlphaFactor|OneMinusConstantAlphaFactor)}
		 * @default SrcAlphaFactor
		 */
		public var blendSrc = SrcAlphaFactor;

		/**
		 * Defines the blending destination factor.
		 *
		 * @type {(ZeroFactor|OneFactor|SrcColorFactor|OneMinusSrcColorFactor|SrcAlphaFactor|OneMinusSrcAlphaFactor|DstAlphaFactor|OneMinusDstAlphaFactor|DstColorFactor|OneMinusDstColorFactor|SrcAlphaSaturateFactor|ConstantColorFactor|OneMinusConstantColorFactor|ConstantAlphaFactor|OneMinusConstantAlphaFactor)}
		 * @default OneMinusSrcAlphaFactor
		 */
		public var blendDst = OneMinusSrcAlphaFactor;

		/**
		 * Defines the blending equation.
		 *
		 * @type {(AddEquation|SubtractEquation|ReverseSubtractEquation|MinEquation|MaxEquation)}
		 * @default AddEquation
		 */
		public var blendEquation = AddEquation;

		/**
		 * Defines the blending source alpha factor.
		 *
		 * @type {?(ZeroFactor|OneFactor|SrcColorFactor|OneMinusSrcColorFactor|SrcAlphaFactor|OneMinusSrcAlphaFactor|DstAlphaFactor|OneMinusDstAlphaFactor|DstColorFactor|OneMinusDstColorFactor|SrcAlphaSaturateFactor|ConstantColorFactor|OneMinusConstantColorFactor|ConstantAlphaFactor|OneMinusConstantAlphaFactor)}
		 * @default null
		 */
		public var blendSrcAlpha = null;

		/**
		 * Defines the blending destination alpha factor.
		 *
		 * @type {?(ZeroFactor|OneFactor|SrcColorFactor|OneMinusSrcColorFactor|SrcAlphaFactor|OneMinusSrcAlphaFactor|DstAlphaFactor|OneMinusDstAlphaFactor|DstColorFactor|OneMinusDstColorFactor|SrcAlphaSaturateFactor|ConstantColorFactor|OneMinusConstantColorFactor|ConstantAlphaFactor|OneMinusConstantAlphaFactor)}
		 * @default null
		 */
		public var blendDstAlpha = null;

		/**
		 * Defines the blending equation of the alpha channel.
		 *
		 * @type {?(AddEquation|SubtractEquation|ReverseSubtractEquation|MinEquation|MaxEquation)}
		 * @default null
		 */
		public var blendEquationAlpha = null;

		/**
		 * Represents the RGB values of the constant blend color.
		 *
		 * This property has only an effect when using custom blending with `ConstantColor` or `OneMinusConstantColor`.
		 *
		 * @type {Color}
		 * @default (0,0,0)
		 */
		public var blendColor = new Color( 0, 0, 0 );

		/**
		 * Represents the alpha value of the constant blend color.
		 *
		 * This property has only an effect when using custom blending with `ConstantAlpha` or `OneMinusConstantAlpha`.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var blendAlpha:Float = 0;

		/**
		 * Defines the depth function.
		 *
		 * @type {(NeverDepth|AlwaysDepth|LessDepth|LessEqualDepth|EqualDepth|GreaterEqualDepth|GreaterDepth|NotEqualDepth)}
		 * @default LessEqualDepth
		 */
		public var depthFunc = LessEqualDepth;

		/**
		 * Whether to have depth test enabled when rendering this material.
		 * When the depth test is disabled, the depth write will also be implicitly disabled.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var depthTest = true;

		/**
		 * Whether rendering this material has any effect on the depth buffer.
		 *
		 * When drawing 2D overlays it can be useful to disable the depth writing in
		 * order to layer several things together without creating z-index artifacts.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var depthWrite = true;

		/**
		 * The bit mask to use when writing to the stencil buffer.
		 *
		 * @type {number}
		 * @default 0xff
		 */
		public var stencilWriteMask = 0xff;

		/**
		 * The stencil comparison function to use.
		 *
		 * @type {NeverStencilFunc|LessStencilFunc|EqualStencilFunc|LessEqualStencilFunc|GreaterStencilFunc|NotEqualStencilFunc|GreaterEqualStencilFunc|AlwaysStencilFunc}
		 * @default AlwaysStencilFunc
		 */
		public var stencilFunc = AlwaysStencilFunc;

		/**
		 * The value to use when performing stencil comparisons or stencil operations.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var stencilRef = 0;

		/**
		 * The bit mask to use when comparing against the stencil buffer.
		 *
		 * @type {number}
		 * @default 0xff
		 */
		public var stencilFuncMask = 0xff;

		/**
		 * Which stencil operation to perform when the comparison function returns `false`.
		 *
		 * @type {ZeroStencilOp|KeepStencilOp|ReplaceStencilOp|IncrementStencilOp|DecrementStencilOp|IncrementWrapStencilOp|DecrementWrapStencilOp|InvertStencilOp}
		 * @default KeepStencilOp
		 */
		public var stencilFail = KeepStencilOp;

		/**
		 * Which stencil operation to perform when the comparison function returns
		 * `true` but the depth test fails.
		 *
		 * @type {ZeroStencilOp|KeepStencilOp|ReplaceStencilOp|IncrementStencilOp|DecrementStencilOp|IncrementWrapStencilOp|DecrementWrapStencilOp|InvertStencilOp}
		 * @default KeepStencilOp
		 */
		public var stencilZFail = KeepStencilOp;

		/**
		 * Which stencil operation to perform when the comparison function returns
		 * `true` and the depth test passes.
		 *
		 * @type {ZeroStencilOp|KeepStencilOp|ReplaceStencilOp|IncrementStencilOp|DecrementStencilOp|IncrementWrapStencilOp|DecrementWrapStencilOp|InvertStencilOp}
		 * @default KeepStencilOp
		 */
		public var stencilZPass = KeepStencilOp;

		/**
		 * Whether stencil operations are performed against the stencil buffer. In
		 * order to perform writes or comparisons against the stencil buffer this
		 * value must be `true`.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var stencilWrite = false;

		/**
		 * User-defined clipping planes specified as THREE.Plane objects in world
		 * space. These planes apply to the objects this material is attached to.
		 * Points in space whose signed distance to the plane is negative are clipped
		 * (not rendered). This requires {@link WebGLRenderer#localClippingEnabled} to
		 * be `true`.
		 *
		 * @type {?Array<Plane>}
		 * @default null
		 */
		public var clippingPlanes = null;

		/**
		 * Changes the behavior of clipping planes so that only their intersection is
		 * clipped, rather than their union.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var clipIntersection = false;

		/**
		 * Defines whether to clip shadows according to the clipping planes specified
		 * on this material.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var clipShadows = false;

		/**
		 * Defines which side of faces cast shadows. If `null`, the side casting shadows
		 * is determined as follows:
		 *
		 * - When {@link Material#side} is set to `FrontSide`, the back side cast shadows.
		 * - When {@link Material#side} is set to `BackSide`, the front side cast shadows.
		 * - When {@link Material#side} is set to `DoubleSide`, both sides cast shadows.
		 *
		 * @type {?(FrontSide|BackSide|DoubleSide)}
		 * @default null
		 */
		public var shadowSide = null;

		/**
		 * Whether to render the material's color.
		 *
		 * This can be used in conjunction with {@link Object3D#renderOder} to create invisible
		 * objects that occlude other objects.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var colorWrite = true;

		/**
		 * Override the renderer's default precision for this material.
		 *
		 * @type {?('highp'|'mediump'|'lowp')}
		 * @default null
		 */
		public var precision = null;

		/**
		 * Whether to use polygon offset or not. When enabled, each fragment's depth value will
		 * be offset after it is interpolated from the depth values of the appropriate vertices.
		 * The offset is added before the depth test is performed and before the value is written
		 * into the depth buffer.
		 *
		 * Can be useful for rendering hidden-line images, for applying decals to surfaces, and for
		 * rendering solids with highlighted edges.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var polygonOffset = false;

		/**
		 * Specifies a scale factor that is used to create a variable depth offset for each polygon.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var polygonOffsetFactor = 0;

		/**
		 * Is multiplied by an implementation-specific value to create a constant depth offset.
		 *
		 * @type {number}
		 * @default 0
		 */
		public var polygonOffsetUnits = 0;

		/**
		 * Whether to apply dithering to the color to remove the appearance of banding.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var dithering = false;

		/**
		 * Whether alpha to coverage should be enabled or not. Can only be used with MSAA-enabled contexts
		 * (meaning when the renderer was created with *antialias* parameter set to `true`). Enabling this
		 * will smooth aliasing on clip plane edges and alphaTest-clipped edges.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var alphaToCoverage = false;

		/**
		 * Whether to premultiply the alpha (transparency) value.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var premultipliedAlpha = false;

		/**
		 * Whether double-sided, transparent objects should be rendered with a single pass or not.
		 *
		 * The engine renders double-sided, transparent objects with two draw calls (back faces first,
		 * then front faces) to mitigate transparency artifacts. There are scenarios however where this
		 * approach produces no quality gains but still doubles draw calls e.g. when rendering flat
		 * vegetation like grass sprites. In these cases, set the `forceSinglePass` flag to `true` to
		 * disable the two pass rendering to avoid performance issues.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var forceSinglePass = false;

		/**
		 * Whether it's possible to override the material with {@link Scene#overrideMaterial} or not.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var allowOverride = true;

		/**
		 * Defines whether 3D objects using this material are visible.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var visible = true;

		/**
		 * Defines whether this material is tone mapped according to the renderer's tone mapping setting.
		 *
		 * It is ignored when rendering to a render target or using post processing or when using
		 * `WebGPURenderer`. In all these cases, all materials are honored by tone mapping.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var toneMapped = true;

		/**
		 * An object that can be used to store custom data about the Material. It
		 * should not hold references to functions as these will not be cloned.
		 *
		 * @type {Object}
		 */
		public var userData = {};

		/**
		 * This starts at `0` and counts how many times {@link Material#needsUpdate} is set to `true`.
		 *
		 * @type {number}
		 * @readonly
		 * @default 0
		 */
		public var version = 0;

		var _alphaTest:Float = 0;

	/**
	 * Constructs a new material.
	 */
	public function new() {
		super();

	}

	/**
	 * Sets the alpha value to be used when running an alpha test. The material
	 * will not be rendered if the opacity is lower than this value.
	 *
	 * @type {number}
	 * @readonly
	 * @default 0
	 */
    public var alphaTest(get, set):Float;

	function get_alphaTest() {

		return this._alphaTest;

	}

	function set_alphaTest( value ) {

		if ( (this._alphaTest > 0) != (value > 0) ) {

			this.version ++;

		}

		return _alphaTest = value;

	}

	/**
	 * An optional callback that is executed immediately before the material is used to render a 3D object.
	 *
	 * This method can only be used when rendering with {@link WebGLRenderer}.
	 *
	 * @param {WebGLRenderer} renderer - The renderer.
	 * @param {Scene} scene - The scene.
	 * @param {Camera} camera - The camera that is used to render the scene.
	 * @param {BufferGeometry} geometry - The 3D object's geometry.
	 * @param {Object3D} object - The 3D object.
	 * @param {Object} group - The geometry group data.
	 */
	public dynamic function onBeforeRender(  renderer, scene, camera, geometry, object, group  ) {}

	/**
	 * An optional callback that is executed immediately before the shader
	 * program is compiled. This function is called with the shader source code
	 * as a parameter. Useful for the modification of built-in materials.
	 *
	 * This method can only be used when rendering with {@link WebGLRenderer}. The
	 * recommended approach when customizing materials is to use `WebGPURenderer` with the new
	 * Node Material system and [TSL]{@link https://github.com/mrdoob/three.js/wiki/Three.js-Shading-Language}.
	 *
	 * @param {{vertexShader:string,fragmentShader:string,uniforms:Object}} shaderobject - The object holds the uniforms and the vertex and fragment shader source.
	 * @param {WebGLRenderer} renderer - A reference to the renderer.
	 */
	public dynamic function onBeforeCompile(  shaderobject, renderer  ) {}

	/**
	 * In case {@link Material#onBeforeCompile} is used, this callback can be used to identify
	 * values of settings used in `onBeforeCompile()`, so three.js can reuse a cached
	 * shader or recompile the shader for this material as needed.
	 *
	 * This method can only be used when rendering with {@link WebGLRenderer}.
	 *
	 * @return {string} The custom program cache key.
	 */
	public function customProgramCacheKey() {

		//TODO: fixing this is necessary,  but i dont know if it's even possible
		//return this.onBeforeCompile.toString();
		return "dummy";

	}

	/**
	 * This method can be used to set default values from parameter objects.
	 * It is a generic implementation so it can be used with different types
	 * of materials.
	 *
	 * @param {Object} [values] - The material values to set.
	 */
	public function setValues( ?values:Dynamic ) {

		if ( values == null ) return;

		var ogFields = Type.getInstanceFields(Type.getClass(this));
		Common.describe("this class", Type.getClass(this));

		//TODO: this doesn't actually set `color` on `MeshBasicMaterial`, why is that?
		for ( key in Reflect.fields(values) ) {

			var newValue:Dynamic = Reflect.field(values, key);

			if ( newValue == null ) {

				Common.warn( 'THREE.Material: parameter ${ key } has value of null.' );
				continue;

			}


			if ( ogFields.contains(key) ) {

				Common.warn( 'THREE.Material: ${ key } is not a property of THREE.${ this.type }.' );
				continue;

			}
			
			var currentValue:Dynamic = Reflect.getProperty(this, key );

			if ( Std.isOfType(currentValue, Color) ) {

				cast (currentValue, Color).set( newValue );

			} else if ( Std.isOfType(currentValue, Vector3) && Std.isOfType(currentValue, Vector3) ) {

				cast (currentValue, Vector3).copy( newValue );

			} else {

				Reflect.setProperty(this, key, newValue);

			}

		}

	}

	/**
	 * Serializes the material into JSON.
	 *
	 * @param {?(Object|string)} meta - An optional value holding meta information about the serialization.
	 * @return {Object} A JSON object representing the serialized material.
	 * @see {@link ObjectLoader#parse}
	 */
	public function toJSON( meta:Dynamic ) {

		var isRootObject = ( meta == null || Std.isOfType(meta, String) );

		if ( isRootObject ) {

			meta = {
				textures: {},
				images: {}
			};

		}

		var data:Dynamic = {
			metadata: {
				version: 4.6,
				type: 'Material',
				generator: 'Material.toJSON'
			}
		};

		// standard Material serialization
		data.uuid = this.uuid;
		data.type = this.type;

		inline function put(name) {
			var v = Reflect.field(this, name);
			if (v != null)
				Reflect.setField(data, name, v);
		}

		inline function badput(name, bad:Any) {
			var v = Reflect.field(this, name);
			if (v != null && v != bad)
				Reflect.setField(data, name, v);
		}

		inline function condput(name, cond:Any->Bool) {
			var v = Reflect.field(this, name);
			if (v != null && cond(v))
				Reflect.setField(data, name, v);
		}

		inline function colorput(name) {
			var v = Reflect.field(this, name);
			if (v != null && Std.isOfType(v, Color))
				Reflect.setField(data, name, cast (v, Color).getHex());
		}

		inline function textureput(name) {
			var v = Reflect.field(this, name);
			if (v != null && Std.isOfType(v, Texture)) {
				Reflect.setField(data, name, cast (v, Texture).toJSON(meta).uuid);
				return true;
			}
			return false;
		}

		inline function vector2put(name) {
			var v = Reflect.field(this, name);
			if (v != null && Std.isOfType(v, Vector2)) {
				Reflect.setField(data, name, cast (v, Vector2).toArray());
				return true;
			}
			return false;
		}

		if ( this.name != '' ) data.name = this.name;

		colorput("color");

		put("roughness");
		put("metalness");

		put("sheen");
		colorput("sheenColor");
		put("sheenRoughness");
		colorput("emissive");
		put("emissiveIntensity");

		colorput("specular");
		put("specularIntensity");
		colorput("specularColor");
		put("shininess");
		put("clearcoat");
		put("clearcoatRoughness");

		textureput("clearcoatMap");
		textureput("clearcoatRoughnessMap");

		if (textureput("clearcoatNormalMap")) {
			vector2put("clearcoatNormalScale");
		}

		put("dispersion");

		put("iridescence");
		put("iridescenceIOR");
		put("iridescenceThicknessRange");

		textureput("iridescenceMap");
		textureput("iridescenceThicknessMap");

		put("anisotropy");
		put("anisotropyRotation");

		textureput("anisotropyMap");

		textureput("map");
		textureput("matcap");
		textureput("alphaMap");

		if (textureput("lightMap")) {
			put("lightMapIntensity");
		}

		if (textureput("aoMap")) {
			put("aoMapIntensity");
		}

		if (textureput("bumpMap")) {
			put("bumpScale");
		}

		if (textureput("normalMap")) {
			put("normalMapType");
			vector2put("normalScale");
		}

		if (textureput("displacementMap")) {
			put("displacementScale");
			put("displacementBias");
		}

		textureput("roughnessMap");
		textureput("metalnessMap");

		textureput("emissiveMap");
		textureput("specularMap");
		textureput("specularIntensityMap");
		textureput("specularColorMap");

		if (textureput("envMap")) {
			put("combine");
		}

		vector2put("envMapRotation");
		put("envMapIntensity");
		put("reflectivity");
		put("refractionRatio");

		textureput("gradientMap");

		put("transmission");
		put("transmissionMap");
		put("thickness");
		put("thicknessMap");
		badput("attenuationDistance", Infinity);
		put("attenuationColor");

		put("size");
		put("shadowSide");
		put("sizeAttenuation");

		badput("blending", NormalBlending);
		badput("side", FrontSide);
		badput("vertexColors", false);

		condput("opacity", function(a:Any) {return cast(a, Float) < 1;});
		badput("transparent", false);

		badput("blendSrc", SrcAlphaFactor);
		badput("blendDst", OneMinusSrcAlphaFactor);
		badput("blendEquation", AddEquation);
		put("blendSrcAlpha");
		put("blendDstAlpha");
		put("blendEquationAlpha");
		colorput("blendColor");
		badput("blendAlpha", 0);

		badput("depthFunc", LessEqualDepth);
		badput("depthTest", true);
		badput("depthWrite", true);
		badput("colorWrite", true);

		badput("stencilWriteMask", 0xff);
		badput("stencilFunc", AlwaysStencilFunc);
		badput("stencilRef", 0);
		badput("stencilFuncMask", 0xff);
		badput("stencilFail", KeepStencilOp);
		badput("stencilZFail", KeepStencilOp);
		badput("stencilZPass", KeepStencilOp);
		badput("stencilWrite", false);

		// rotation (SpriteMaterial)
		badput("rotation", 0);

		badput("polygonOffset", false);
		badput("polygonOffsetFactor", 0);
		badput("polygonOffsetUnits", 0);

		badput("linewidth", 1);
		put("dashSize");
		put("gapSize");
		put("scale");

		badput("dithering", false);

		condput("alphaTest", function(a:Any) { return cast(a, Float) > 0; });
		badput("alphaHash", false);
		badput("alphaToCoverage", false);
		badput("premultipliedAlpha", false);
		badput("forceSinglePass", false);

		badput("wireframe", false);
		condput("wireframeLinewidth", function(a:Any) {return cast(a, Float) > 1;});
		badput("wireframeLinecap", "round");
		badput("wireframeLinejoin", "round");

		badput("flatShading", false);

		badput("visible", true);

		badput("toneMapped", true);

		badput("fog", true);

		if ( Reflect.fields( this.userData ).length > 0 ) data.userData = this.userData;

		// TODO: Copied from Object3D.toJSON

		function extractFromCache( cache ) {

			var values = [];

			for ( key in Reflect.fields(cache) ) {

				var data = Reflect.field(cache, key);
				Reflect.deleteField(data, "metadata");
				values.push( data );

			}

			return values;

		}

		if ( isRootObject ) {

			var textures = extractFromCache( meta.textures );
			var images = extractFromCache( meta.images );

			if ( textures.length > 0 ) data.textures = textures;
			if ( images.length > 0 ) data.images = images;

		}

		return data;

	}

	/**
	 * Returns a new material with copied values from this instance.
	 *
	 * @return {Material} A clone of this instance.
	 */
	public function clone():Dynamic {

		return Common.reconstruct(this).copy( this );

	}

	/**
	 * Copies the values of the given material to this instance.
	 *
	 * @param {Material} source - The material to copy.
	 * @return {Material} A reference to this instance.
	 */
	public function copy( source:Dynamic ) {

		this.name = source.name;

		this.blending = source.blending;
		this.side = source.side;
		this.vertexColors = source.vertexColors;

		this.opacity = source.opacity;
		this.transparent = source.transparent;

		this.blendSrc = source.blendSrc;
		this.blendDst = source.blendDst;
		this.blendEquation = source.blendEquation;
		this.blendSrcAlpha = source.blendSrcAlpha;
		this.blendDstAlpha = source.blendDstAlpha;
		this.blendEquationAlpha = source.blendEquationAlpha;
		this.blendColor.copy( source.blendColor );
		this.blendAlpha = source.blendAlpha;

		this.depthFunc = source.depthFunc;
		this.depthTest = source.depthTest;
		this.depthWrite = source.depthWrite;

		this.stencilWriteMask = source.stencilWriteMask;
		this.stencilFunc = source.stencilFunc;
		this.stencilRef = source.stencilRef;
		this.stencilFuncMask = source.stencilFuncMask;
		this.stencilFail = source.stencilFail;
		this.stencilZFail = source.stencilZFail;
		this.stencilZPass = source.stencilZPass;
		this.stencilWrite = source.stencilWrite;

		var srcPlanes = source.clippingPlanes;
		var dstPlanes = null;

		if ( srcPlanes != null ) {

			dstPlanes = new Array();

			for ( i in 0...srcPlanes.length ) {

				dstPlanes[ i ] = srcPlanes[ i ].clone();

			}

		}

		this.clippingPlanes = dstPlanes;
		this.clipIntersection = source.clipIntersection;
		this.clipShadows = source.clipShadows;

		this.shadowSide = source.shadowSide;

		this.colorWrite = source.colorWrite;

		this.precision = source.precision;

		this.polygonOffset = source.polygonOffset;
		this.polygonOffsetFactor = source.polygonOffsetFactor;
		this.polygonOffsetUnits = source.polygonOffsetUnits;

		this.dithering = source.dithering;

		this.alphaTest = source.alphaTest;
		this.alphaHash = source.alphaHash;
		this.alphaToCoverage = source.alphaToCoverage;
		this.premultipliedAlpha = source.premultipliedAlpha;
		this.forceSinglePass = source.forceSinglePass;

		this.visible = source.visible;

		this.toneMapped = source.toneMapped;

		this.userData = Json.parse( Json.stringify( source.userData ) );

		return this;

	}

	/**
	 * Frees the GPU-related resources allocated by this instance. Call this
	 * method whenever this instance is no longer used in your app.
	 *
	 * @fires Material#dispose
	 */
	public function dispose() {

		/**
		 * Fires when the material has been disposed of.
		 *
		 * @event Material#dispose
		 * @type {Object}
		 */
		this.dispatchEvent( { type: 'dispose' } );

	}

	/**
	 * Setting this property to `true` indicates the engine the material
	 * needs to be recompiled.
	 *
	 * @type {boolean}
	 * @default false
	 * @param {boolean} value
	 */
     public var needsUpdate(never, set):Bool;
	function set_needsUpdate( value ) {

		if ( value  ) this.version ++;

		return value;
	}

	public var type(get, never):String;
	function get_type() {
		return Common.typeName(this);
	}


    static var _materialId = 0;
}