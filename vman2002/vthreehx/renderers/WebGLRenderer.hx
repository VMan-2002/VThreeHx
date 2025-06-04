package vman2002.vthreehx.renderers;

//goodluck

import vman2002.vthreehx.Constants.REVISION;
import vman2002.vthreehx.Constants.BackSide;
import vman2002.vthreehx.Constants.FrontSide;
import vman2002.vthreehx.Constants.DoubleSide;
import vman2002.vthreehx.Constants.HalfFloatType;
import vman2002.vthreehx.Constants.UnsignedByteType;
import vman2002.vthreehx.Constants.NoToneMapping;
import vman2002.vthreehx.Constants.LinearMipmapLinearFilter;
import vman2002.vthreehx.Constants.SRGBColorSpace;
import vman2002.vthreehx.Constants.LinearSRGBColorSpace;
import vman2002.vthreehx.Constants.RGBAIntegerFormat;
import vman2002.vthreehx.Constants.RGIntegerFormat;
import vman2002.vthreehx.Constants.RedIntegerFormat;
import vman2002.vthreehx.Constants.UnsignedIntType;
import vman2002.vthreehx.Constants.UnsignedShortType;
import vman2002.vthreehx.Constants.UnsignedInt248Type;
import vman2002.vthreehx.Constants.UnsignedShort4444Type;
import vman2002.vthreehx.Constants.UnsignedShort5551Type;
import vman2002.vthreehx.Constants.WebGLCoordinateSystem;
import vman2002.vthreehx.math.Color;
import vman2002.vthreehx.math.Matrix4;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Vector4;
import vman2002.vthreehx.math.ColorManagement;
import vman2002.vthreehx.math.Frustum;
import vman2002.vthreehx.renderers.webgl.WebGLAnimation;
import vman2002.vthreehx.renderers.webgl.WebGLAttributes;
import vman2002.vthreehx.renderers.webgl.WebGLBackground;
import vman2002.vthreehx.renderers.webgl.WebGLBindingStates;
import vman2002.vthreehx.renderers.webgl.WebGLBufferRenderer;
import vman2002.vthreehx.renderers.webgl.WebGLCapabilities;
import vman2002.vthreehx.renderers.webgl.WebGLClipping;
import vman2002.vthreehx.renderers.webgl.WebGLCubeMaps;
import vman2002.vthreehx.renderers.webgl.WebGLCubeUVMaps;
import vman2002.vthreehx.renderers.webgl.WebGLExtensions;
import vman2002.vthreehx.renderers.webgl.WebGLGeometries;
import vman2002.vthreehx.renderers.webgl.WebGLIndexedBufferRenderer;
import vman2002.vthreehx.renderers.webgl.WebGLInfo;
import vman2002.vthreehx.renderers.webgl.WebGLMorphtargets;
import vman2002.vthreehx.renderers.webgl.WebGLObjects;
import vman2002.vthreehx.renderers.webgl.WebGLPrograms;
import vman2002.vthreehx.renderers.webgl.WebGLProperties;
import vman2002.vthreehx.renderers.webgl.WebGLRenderLists;
import vman2002.vthreehx.renderers.webgl.WebGLRenderStates;
import vman2002.vthreehx.renderers.webgl.WebGLRenderTarget;
import vman2002.vthreehx.renderers.webgl.WebGLShadowMap;
import vman2002.vthreehx.renderers.webgl.WebGWebGLStateLProperties;
import vman2002.vthreehx.renderers.webgl.WebGLTextures;
import vman2002.vthreehx.renderers.webgl.WebGLUniforms;
import vman2002.vthreehx.renderers.webgl.WebGLUtils;
import vman2002.vthreehx.renderers.webxr.WebXRManager;
import vman2002.vthreehx.renderers.webgl.WebGLMaterials;
import vman2002.vthreehx.renderers.webgl.WebGLUniformsGroups;
import vman2002.vthreehx.Utils.warnOnce;
import vman2002.vthreehx.Utils.toNormalizedProjectionMatix;
import vman2002.vthreehx.Utils.toReversedProjectionMatrix;
//import { createCanvasElement, probeAsync, } from '../utils.js';

/**
 * This renderer uses WebGL 2 to display scenes.
 *
 * WebGL 1 is not supported since `r163`.
 */
class WebGLRenderer {

    var parameters = {
        //TODO: Haxe canvas
        /*canvas: createCanvasElement(),*/
        context: null,
        depth: true,
        stencil: false,
        alpha: false,
        antialias: false,
        premultipliedAlpha: true,
        preserveDrawingBuffer: false,
        powerPreference: 'default',
        failIfMajorPerformanceCaveat: false,
        reverseDepthBuffer: false,
    };

		// public properties

		/**
		 * A canvas where the renderer draws its output.This is automatically created by the renderer
		 * in the constructor (if not provided already); you just need to add it to your page like so:
		 * ```js
		 * document.body.appendChild( renderer.domElement );
		 * ```
		 *
		 * @type {DOMElement}
		 */
		public var domElement = canvas;

		/**
		 * A object with debug configuration settings.
		 *
		 * - `checkShaderErrors`: If it is `true`, defines whether material shader programs are
		 * checked for errors during compilation and linkage process. It may be useful to disable
		 * this check in production for performance gain. It is strongly recommended to keep these
		 * checks enabled during development. If the shader does not compile and link - it will not
		 * work and associated material will not render.
		 * - `onShaderError(gl, program, glVertexShader,glFragmentShader)`: A callback function that
		 * can be used for custom error reporting. The callback receives the WebGL context, an instance
		 * of WebGLProgram as well two instances of WebGLShader representing the vertex and fragment shader.
		 * Assigning a custom function disables the default error reporting.
		 *
		 * @type {Object}
		 */
		public var debug = {

			/**
			 * Enables error checking and reporting when shader programs are being compiled.
			 * @type {boolean}
			 */
			checkShaderErrors: true,
			/**
			 * Callback for custom error reporting.
			 * @type {?Function}
			 */
			onShaderError: null
		};

		// clearing

		/**
		 * Whether the renderer should automatically clear its output before rendering a frame or not.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var autoClear = true;

		/**
		 * If {@link WebGLRenderer#autoClear} set to `true`, whether the renderer should clear
		 * the color buffer or not.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var autoClearColor = true;

		/**
		 * If {@link WebGLRenderer#autoClear} set to `true`, whether the renderer should clear
		 * the depth buffer or not.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var autoClearDepth = true;

		/**
		 * If {@link WebGLRenderer#autoClear} set to `true`, whether the renderer should clear
		 * the stencil buffer or not.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var autoClearStencil = true;
        

		// scene graph

		/**
		 * Whether the renderer should sort objects or not.
		 *
		 * Note: Sorting is used to attempt to properly render objects that have some
		 * degree of transparency. By definition, sorting objects may not work in all
		 * cases. Depending on the needs of application, it may be necessary to turn
		 * off sorting and use other methods to deal with transparency rendering e.g.
		 * manually determining each object's rendering order.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public varsortObjects = true;

		// user-defined clipping

		/**
		 * User-defined clipping planes specified in world space. These planes apply globally.
		 * Points in space whose dot product with the plane is negative are cut away.
		 *
		 * @type {Array<Plane>}
		 */
		public var clippingPlanes = [];

		/**
		 * Whether the renderer respects object-level clipping planes or not.
		 *
		 * @type {boolean}
		 * @default false
		 */
		public var localClippingEnabled = false;

		// tone mapping

		/**
		 * The tone mapping technique of the renderer.
		 *
		 * @type {(NoToneMapping|LinearToneMapping|ReinhardToneMapping|CineonToneMapping|ACESFilmicToneMapping|CustomToneMapping|AgXToneMapping|NeutralToneMapping)}
		 * @default NoToneMapping
		 */
		public var toneMapping = NoToneMapping;

		/**
		 * Exposure level of tone mapping.
		 *
		 * @type {number}
		 * @default 1
		 */
		public var toneMappingExposure = 1.0;

		// transmission

		/**
		 * The normalized resolution scale for the transmission render target, measured in percentage
		 * of viewport dimensions. Lowering this value can result in significant performance improvements
		 * when using {@link MeshPhysicalMaterial#transmission}.
		 *
		 * @type {number}
		 * @default 1
		 */
		public var transmissionResolutionScale = 1.0;

	/**
	 * Constructs a new WebGL renderer.
	 *
	 * @param {WebGLRenderer~Options} [parameters] - The configuration parameter.
	 */
	public function new( parameters:Dynamic ) {

        for (thing in Reflect.fields(parameters)) {
            Reflect.setField(this.parameters, thing, Reflect.field(parameters, thing));
        }

		var _alpha;

		if ( context != null ) {

			if ( typeof WebGLRenderingContext != 'undefined' && context instanceof WebGLRenderingContext ) {

				throw ( 'THREE.WebGLRenderer: WebGL 1 is not supported since r163.' );

			}

			_alpha = context.getContextAttributes().alpha;

		} else {

			_alpha = alpha;

		}

		var uintClearColor = new Uint32Array( 4 );
		var intClearColor = new Int32Array( 4 );

		var currentRenderList = null;
		var currentRenderState = null;

		// render() can be called from within a callback triggered by another render.
		// We track this so that the nested render call gets its list and state isolated from the parent render call.

		var renderListStack = [];
		var renderStateStack = [];

		function getTargetPixelRatio() {

			return _currentRenderTarget == null ? _pixelRatio : 1;

		}

		// initialize

		var _gl = context;

		function getContext( contextName, contextAttributes ) {

			return canvas.getContext( contextName, contextAttributes );

		}

		try {

			var contextAttributes = {
				alpha: true,
				depth,
				stencil,
				antialias,
				premultipliedAlpha,
				preserveDrawingBuffer,
				powerPreference,
				failIfMajorPerformanceCaveat,
			};

			// OffscreenCanvas does not have setAttribute, see #22811
			if ( 'setAttribute' in canvas ) canvas.setAttribute( 'data-engine', `three.js r${REVISION}` );

			// event listeners must be registered before WebGL context is created, see #12753
			canvas.addEventListener( 'webglcontextlost', onContextLost, false );
			canvas.addEventListener( 'webglcontextrestored', onContextRestore, false );
			canvas.addEventListener( 'webglcontextcreationerror', onContextCreationError, false );

			if ( _gl == null ) {

				var contextName = 'webgl2';

				_gl = getContext( contextName, contextAttributes );

				if ( _gl == null ) {

					if ( getContext( contextName ) ) {

						throw ( 'Error creating WebGL context with your selected attributes.' );

					} else {

						throw ( 'Error creating WebGL context.' );

					}

				}

			}

		} catch ( error ) {

			Common.error( 'THREE.WebGLRenderer: ' + error.message );
			throw error;

		}

		var extensions, capabilities, state, info;
		var properties, textures, cubemaps, cubeuvmaps, attributes, geometries, objects;
		var programCache, materials, renderLists, renderStates, clipping, shadowMap;

		var background, morphtargets, bufferRenderer, indexedBufferRenderer;

		var utils, bindingStates, uniformsGroups;

		function initGLContext() {

			extensions = new WebGLExtensions( _gl );
			extensions.init();

			utils = new WebGLUtils( _gl, extensions );

			capabilities = new WebGLCapabilities( _gl, extensions, parameters, utils );

			state = new WebGLState( _gl, extensions );

			if ( capabilities.reverseDepthBuffer && reverseDepthBuffer ) {

				state.buffers.depth.setReversed( true );

			}

			info = new WebGLInfo( _gl );
			properties = new WebGLProperties();
			textures = new WebGLTextures( _gl, extensions, state, properties, capabilities, utils, info );
			cubemaps = new WebGLCubeMaps( _this );
			cubeuvmaps = new WebGLCubeUVMaps( _this );
			attributes = new WebGLAttributes( _gl );
			bindingStates = new WebGLBindingStates( _gl, attributes );
			geometries = new WebGLGeometries( _gl, attributes, info, bindingStates );
			objects = new WebGLObjects( _gl, geometries, attributes, info );
			morphtargets = new WebGLMorphtargets( _gl, capabilities, textures );
			clipping = new WebGLClipping( properties );
			programCache = new WebGLPrograms( _this, cubemaps, cubeuvmaps, extensions, capabilities, bindingStates, clipping );
			materials = new WebGLMaterials( _this, properties );
			renderLists = new WebGLRenderLists();
			renderStates = new WebGLRenderStates( extensions );
			background = new WebGLBackground( _this, cubemaps, cubeuvmaps, state, objects, _alpha, premultipliedAlpha );
			shadowMap = new WebGLShadowMap( _this, objects, capabilities );
			uniformsGroups = new WebGLUniformsGroups( _gl, info, capabilities, state );

			bufferRenderer = new WebGLBufferRenderer( _gl, extensions, info );
			indexedBufferRenderer = new WebGLIndexedBufferRenderer( _gl, extensions, info );

			info.programs = programCache.programs;

			/**
			 * Holds details about the capabilities of the current rendering context.
			 *
			 * @name WebGLRenderer#capabilities
			 * @type {WebGLRenderer~Capabilities}
			 */
			_this.capabilities = capabilities;

			/**
			 * Provides methods for retrieving and testing WebGL extensions.
			 *
			 * - `get(extensionName:string)`: Used to check whether a WebGL extension is supported
			 * and return the extension object if available.
			 * - `has(extensionName:string)`: returns `true` if the extension is supported.
			 *
			 * @name WebGLRenderer#extensions
			 * @type {Object}
			 */
			_this.extensions = extensions;

			/**
			 * Used to track properties of other objects like native WebGL objects.
			 *
			 * @name WebGLRenderer#properties
			 * @type {Object}
			 */
			_this.properties = properties;

			/**
			 * Manages the render lists of the renderer.
			 *
			 * @name WebGLRenderer#renderLists
			 * @type {Object}
			 */
			_this.renderLists = renderLists;



			/**
			 * Interface for managing shadows.
			 *
			 * @name WebGLRenderer#shadowMap
			 * @type {WebGLRenderer~ShadowMap}
			 */
			_this.shadowMap = shadowMap;

			/**
			 * Interface for managing the WebGL state.
			 *
			 * @name WebGLRenderer#state
			 * @type {Object}
			 */
			_this.state = state;

			/**
			 * Holds a series of statistical information about the GPU memory
			 * and the rendering process. Useful for debugging and monitoring.
			 *
			 * By default these data are reset at each render call but when having
			 * multiple render passes per frame (e.g. when using post processing) it can
			 * be preferred to reset with a custom pattern. First, set `autoReset` to
			 * `false`.
			 * ```js
			 * renderer.info.autoReset = false;
			 * ```
			 * Call `reset()` whenever you have finished to render a single frame.
			 * ```js
			 * renderer.info.reset();
			 * ```
			 *
			 * @name WebGLRenderer#info
			 * @type {WebGLRenderer~Info}
			 */
			_this.info = info;

		}

		initGLContext();

		// xr

		var xr = new WebXRManager( _this, _gl );

		/**
		 * A reference to the XR manager.
		 *
		 * @type {WebXRManager}
		 */
		this.xr = xr;

		/**
		 * Returns the rendering context.
		 *
		 * @return {WebGL2RenderingContext} The rendering context.
		 */
		this.getContext = function () {

			return _gl;

		};

		/**
		 * Returns the rendering context attributes.
		 *
		 * @return {WebGLContextAttributes} The rendering context attributes.
		 */
		this.getContextAttributes = function () {

			return _gl.getContextAttributes();

		};

		/**
		 * Simulates a loss of the WebGL context. This requires support for the `WEBGL_lose_context` extension.
		 */
		this.forceContextLoss = function () {

			var extension = extensions.get( 'WEBGL_lose_context' );
			if ( extension ) extension.loseContext();

		};

		/**
		 * Simulates a restore of the WebGL context. This requires support for the `WEBGL_lose_context` extension.
		 */
		this.forceContextRestore = function () {

			var extension = extensions.get( 'WEBGL_lose_context' );
			if ( extension ) extension.restoreContext();

		};

		/**
		 * Returns the pixel ratio.
		 *
		 * @return {number} The pixel ratio.
		 */
		this.getPixelRatio = function () {

			return _pixelRatio;

		};

		/**
		 * Sets the given pixel ratio and resizes the canvas if necessary.
		 *
		 * @param {number} value - The pixel ratio.
		 */
		this.setPixelRatio = function ( value ) {

			if ( value == undefined ) return;

			_pixelRatio = value;

			this.setSize( _width, _height, false );

		};

		/**
		 * Returns the renderer's size in logical pixels. This method does not honor the pixel ratio.
		 *
		 * @param {Vector2} target - The method writes the result in this target object.
		 * @return {Vector2} The renderer's size in logical pixels.
		 */
		this.getSize = function ( target ) {

			return target.set( _width, _height );

		};

		/**
		 * Resizes the output canvas to (width, height) with device pixel ratio taken
		 * into account, and also sets the viewport to fit that size, starting in (0,
		 * 0). Setting `updateStyle` to false prevents any style changes to the output canvas.
		 *
		 * @param {number} width - The width in logical pixels.
		 * @param {number} height - The height in logical pixels.
		 * @param {boolean} [updateStyle=true] - Whether to update the `style` attribute of the canvas or not.
		 */
		this.setSize = function ( width, height, updateStyle = true ) {

			if ( xr.isPresenting ) {

				Common.warn( 'THREE.WebGLRenderer: Can\'t change size while VR device is presenting.' );
				return;

			}

			_width = width;
			_height = height;

			canvas.width = Math.floor( width * _pixelRatio );
			canvas.height = Math.floor( height * _pixelRatio );

			if ( updateStyle == true ) {

				canvas.style.width = width + 'px';
				canvas.style.height = height + 'px';

			}

			this.setViewport( 0, 0, width, height );

		};

		/**
		 * Returns the drawing buffer size in physical pixels. This method honors the pixel ratio.
		 *
		 * @param {Vector2} target - The method writes the result in this target object.
		 * @return {Vector2} The drawing buffer size.
		 */
		this.getDrawingBufferSize = function ( target ) {

			return target.set( _width * _pixelRatio, _height * _pixelRatio ).floor();

		};

		/**
		 * This method allows to define the drawing buffer size by specifying
		 * width, height and pixel ratio all at once. The size of the drawing
		 * buffer is computed with this formula:
		 * ```js
		 * size.x = width * pixelRatio;
		 * size.y = height * pixelRatio;
		 * ```
		 *
		 * @param {number} width - The width in logical pixels.
		 * @param {number} height - The height in logical pixels.
		 * @param {number} pixelRatio - The pixel ratio.
		 */
		this.setDrawingBufferSize = function ( width, height, pixelRatio ) {

			_width = width;
			_height = height;

			_pixelRatio = pixelRatio;

			canvas.width = Math.floor( width * pixelRatio );
			canvas.height = Math.floor( height * pixelRatio );

			this.setViewport( 0, 0, width, height );

		};

		/**
		 * Returns the current viewport definition.
		 *
		 * @param {Vector2} target - The method writes the result in this target object.
		 * @return {Vector2} The current viewport definition.
		 */
		this.getCurrentViewport = function ( target ) {

			return target.copy( _currentViewport );

		};

		/**
		 * Returns the viewport definition.
		 *
		 * @param {Vector4} target - The method writes the result in this target object.
		 * @return {Vector4} The viewport definition.
		 */
		this.getViewport = function ( target ) {

			return target.copy( _viewport );

		};

		/**
		 * Sets the viewport to render from `(x, y)` to `(x + width, y + height)`.
		 *
		 * @param {number | Vector4} x - The horizontal coordinate for the lower left corner of the viewport origin in logical pixel unit.
		 * Or alternatively a four-component vector specifying all the parameters of the viewport.
		 * @param {number} y - The vertical coordinate for the lower left corner of the viewport origin  in logical pixel unit.
		 * @param {number} width - The width of the viewport in logical pixel unit.
		 * @param {number} height - The height of the viewport in logical pixel unit.
		 */
		this.setViewport = function ( x, y, width, height ) {

			if ( x.isVector4 ) {

				_viewport.set( x.x, x.y, x.z, x.w );

			} else {

				_viewport.set( x, y, width, height );

			}

			state.viewport( _currentViewport.copy( _viewport ).multiplyScalar( _pixelRatio ).round() );

		};

		/**
		 * Returns the scissor region.
		 *
		 * @param {Vector4} target - The method writes the result in this target object.
		 * @return {Vector4} The scissor region.
		 */
		this.getScissor = function ( target ) {

			return target.copy( _scissor );

		};

		/**
		 * Sets the scissor region to render from `(x, y)` to `(x + width, y + height)`.
		 *
		 * @param {number | Vector4} x - The horizontal coordinate for the lower left corner of the scissor region origin in logical pixel unit.
		 * Or alternatively a four-component vector specifying all the parameters of the scissor region.
		 * @param {number} y - The vertical coordinate for the lower left corner of the scissor region origin  in logical pixel unit.
		 * @param {number} width - The width of the scissor region in logical pixel unit.
		 * @param {number} height - The height of the scissor region in logical pixel unit.
		 */
		this.setScissor = function ( x, y, width, height ) {

			if ( x.isVector4 ) {

				_scissor.set( x.x, x.y, x.z, x.w );

			} else {

				_scissor.set( x, y, width, height );

			}

			state.scissor( _currentScissor.copy( _scissor ).multiplyScalar( _pixelRatio ).round() );

		};

		/**
		 * Returns `true` if the scissor test is enabled.
		 *
		 * @return {boolean} Whether the scissor test is enabled or not.
		 */
		this.getScissorTest = function () {

			return _scissorTest;

		};

		/**
		 * Enable or disable the scissor test. When this is enabled, only the pixels
		 * within the defined scissor area will be affected by further renderer
		 * actions.
		 *
		 * @param {boolean} boolean - Whether the scissor test is enabled or not.
		 */
		this.setScissorTest = function ( boolean ) {

			state.setScissorTest( _scissorTest = boolean );

		};

		/**
		 * Sets a custom opaque sort function for the render lists. Pass `null`
		 * to use the default `painterSortStable` function.
		 *
		 * @param {?Function} method - The opaque sort function.
		 */
		this.setOpaqueSort = function ( method ) {

			_opaqueSort = method;

		};

		/**
		 * Sets a custom transparent sort function for the render lists. Pass `null`
		 * to use the default `reversePainterSortStable` function.
		 *
		 * @param {?Function} method - The opaque sort function.
		 */
		this.setTransparentSort = function ( method ) {

			_transparentSort = method;

		};

		// Clearing

		/**
		 * Returns the clear color.
		 *
		 * @param {Color} target - The method writes the result in this target object.
		 * @return {Color} The clear color.
		 */
		this.getClearColor = function ( target ) {

			return target.copy( background.getClearColor() );

		};

		/**
		 * Sets the clear color and alpha.
		 *
		 * @param {Color} color - The clear color.
		 * @param {number} [alpha=1] - The clear alpha.
		 */
		this.setClearColor = function () {

			background.setClearColor( ...arguments );

		};

		/**
		 * Returns the clear alpha. Ranges within `[0,1]`.
		 *
		 * @return {number} The clear alpha.
		 */
		this.getClearAlpha = function () {

			return background.getClearAlpha();

		};

		/**
		 * Sets the clear alpha.
		 *
		 * @param {number} alpha - The clear alpha.
		 */
		this.setClearAlpha = function () {

			background.setClearAlpha( ...arguments );

		};

		/**
		 * Tells the renderer to clear its color, depth or stencil drawing buffer(s).
		 * This method initializes the buffers to the current clear color values.
		 *
		 * @param {boolean} [color=true] - Whether the color buffer should be cleared or not.
		 * @param {boolean} [depth=true] - Whether the depth buffer should be cleared or not.
		 * @param {boolean} [stencil=true] - Whether the stencil buffer should be cleared or not.
		 */
		this.clear = function ( color = true, depth = true, stencil = true ) {

			var bits = 0;

			if ( color ) {

				// check if we're trying to clear an integer target
				var isIntegerFormat = false;
				if ( _currentRenderTarget != null ) {

					var targetFormat = _currentRenderTarget.texture.format;
					isIntegerFormat = targetFormat == RGBAIntegerFormat ||
						targetFormat == RGIntegerFormat ||
						targetFormat == RedIntegerFormat;

				}

				// use the appropriate clear functions to clear the target if it's a signed
				// or unsigned integer target
				if ( isIntegerFormat ) {

					var targetType = _currentRenderTarget.texture.type;
					var isUnsignedType = targetType == UnsignedByteType ||
						targetType == UnsignedIntType ||
						targetType == UnsignedShortType ||
						targetType == UnsignedInt248Type ||
						targetType == UnsignedShort4444Type ||
						targetType == UnsignedShort5551Type;

					var clearColor = background.getClearColor();
					var a = background.getClearAlpha();
					var r = clearColor.r;
					var g = clearColor.g;
					var b = clearColor.b;

					if ( isUnsignedType ) {

						uintClearColor[ 0 ] = r;
						uintClearColor[ 1 ] = g;
						uintClearColor[ 2 ] = b;
						uintClearColor[ 3 ] = a;
						_gl.clearBufferuiv( _gl.COLOR, 0, uintClearColor );

					} else {

						intClearColor[ 0 ] = r;
						intClearColor[ 1 ] = g;
						intClearColor[ 2 ] = b;
						intClearColor[ 3 ] = a;
						_gl.clearBufferiv( _gl.COLOR, 0, intClearColor );

					}

				} else {

					bits |= _gl.COLOR_BUFFER_BIT;

				}

			}

			if ( depth ) {

				bits |= _gl.DEPTH_BUFFER_BIT;

			}

			if ( stencil ) {

				bits |= _gl.STENCIL_BUFFER_BIT;
				this.state.buffers.stencil.setMask( 0xffffffff );

			}

			_gl.clear( bits );

		};

		/**
		 * Clears the color buffer. Equivalent to calling `renderer.clear( true, false, false )`.
		 */
		this.clearColor = function () {

			this.clear( true, false, false );

		};

		/**
		 * Clears the depth buffer. Equivalent to calling `renderer.clear( false, true, false )`.
		 */
		this.clearDepth = function () {

			this.clear( false, true, false );

		};

		/**
		 * Clears the stencil buffer. Equivalent to calling `renderer.clear( false, false, true )`.
		 */
		this.clearStencil = function () {

			this.clear( false, false, true );

		};

		/**
		 * Frees the GPU-related resources allocated by this instance. Call this
		 * method whenever this instance is no longer used in your app.
		 */
		this.dispose = function () {

			canvas.removeEventListener( 'webglcontextlost', onContextLost, false );
			canvas.removeEventListener( 'webglcontextrestored', onContextRestore, false );
			canvas.removeEventListener( 'webglcontextcreationerror', onContextCreationError, false );

			background.dispose();
			renderLists.dispose();
			renderStates.dispose();
			properties.dispose();
			cubemaps.dispose();
			cubeuvmaps.dispose();
			objects.dispose();
			bindingStates.dispose();
			uniformsGroups.dispose();
			programCache.dispose();

			xr.dispose();

			xr.removeEventListener( 'sessionstart', onXRSessionStart );
			xr.removeEventListener( 'sessionend', onXRSessionEnd );

			animation.stop();

		};

		// Events

		function onContextLost( event ) {

			event.preventDefault();

			Common.log( 'THREE.WebGLRenderer: Context Lost.' );

			_isContextLost = true;

		}

		function onContextRestore( /* event */ ) {

			Common.log( 'THREE.WebGLRenderer: Context Restored.' );

			_isContextLost = false;

			var infoAutoReset = info.autoReset;
			var shadowMapEnabled = shadowMap.enabled;
			var shadowMapAutoUpdate = shadowMap.autoUpdate;
			var shadowMapNeedsUpdate = shadowMap.needsUpdate;
			var shadowMapType = shadowMap.type;

			initGLContext();

			info.autoReset = infoAutoReset;
			shadowMap.enabled = shadowMapEnabled;
			shadowMap.autoUpdate = shadowMapAutoUpdate;
			shadowMap.needsUpdate = shadowMapNeedsUpdate;
			shadowMap.type = shadowMapType;

		}

		function onContextCreationError( event ) {

			Common.error( 'THREE.WebGLRenderer: A WebGL context could not be created. Reason: ', event.statusMessage );

		}

		function onMaterialDispose( event ) {

			var material = event.target;

			material.removeEventListener( 'dispose', onMaterialDispose );

			deallocateMaterial( material );

		}

		// Buffer deallocation

		function deallocateMaterial( material ) {

			releaseMaterialProgramReferences( material );

			properties.remove( material );

		}


		function releaseMaterialProgramReferences( material ) {

			var programs = properties.get( material ).programs;

			if ( programs != undefined ) {

				programs.forEach( function ( program ) {

					programCache.releaseProgram( program );

				} );

				if ( material.isShaderMaterial ) {

					programCache.releaseShaderCache( material );

				}

			}

		}

		// Buffer rendering

		this.renderBufferDirect = function ( camera, scene, geometry, material, object, group ) {

			if ( scene == null ) scene = _emptyScene; // renderBufferDirect second parameter used to be fog (could be null)

			var frontFaceCW = ( object.isMesh && object.matrixWorld.determinant() < 0 );

			var program = setProgram( camera, scene, geometry, material, object );

			state.setMaterial( material, frontFaceCW );

			//

			var index = geometry.index;
			var rangeFactor = 1;

			if ( material.wireframe == true ) {

				index = geometries.getWireframeAttribute( geometry );

				if ( index == undefined ) return;

				rangeFactor = 2;

			}

			//

			var drawRange = geometry.drawRange;
			var position = geometry.attributes.position;

			var drawStart = drawRange.start * rangeFactor;
			var drawEnd = ( drawRange.start + drawRange.count ) * rangeFactor;

			if ( group != null ) {

				drawStart = Math.max( drawStart, group.start * rangeFactor );
				drawEnd = Math.min( drawEnd, ( group.start + group.count ) * rangeFactor );

			}

			if ( index != null ) {

				drawStart = Math.max( drawStart, 0 );
				drawEnd = Math.min( drawEnd, index.count );

			} else if ( position != undefined && position != null ) {

				drawStart = Math.max( drawStart, 0 );
				drawEnd = Math.min( drawEnd, position.count );

			}

			var drawCount = drawEnd - drawStart;

			if ( drawCount < 0 || drawCount == Infinity ) return;

			//

			bindingStates.setup( object, material, program, geometry, index );

			var attribute;
			var renderer = bufferRenderer;

			if ( index != null ) {

				attribute = attributes.get( index );

				renderer = indexedBufferRenderer;
				renderer.setIndex( attribute );

			}

			//

			if ( object.isMesh ) {

				if ( material.wireframe == true ) {

					state.setLineWidth( material.wireframeLinewidth * getTargetPixelRatio() );
					renderer.setMode( _gl.LINES );

				} else {

					renderer.setMode( _gl.TRIANGLES );

				}

			} else if ( object.isLine ) {

				var lineWidth = material.linewidth;

				if ( lineWidth == undefined ) lineWidth = 1; // Not using Line*Material

				state.setLineWidth( lineWidth * getTargetPixelRatio() );

				if ( object.isLineSegments ) {

					renderer.setMode( _gl.LINES );

				} else if ( object.isLineLoop ) {

					renderer.setMode( _gl.LINE_LOOP );

				} else {

					renderer.setMode( _gl.LINE_STRIP );

				}

			} else if ( object.isPoints ) {

				renderer.setMode( _gl.POINTS );

			} else if ( object.isSprite ) {

				renderer.setMode( _gl.TRIANGLES );

			}

			if ( object.isBatchedMesh ) {

				if ( object._multiDrawInstances != null ) {

					// @deprecated, r174
					warnOnce( 'THREE.WebGLRenderer: renderMultiDrawInstances has been deprecated and will be removed in r184. Append to renderMultiDraw arguments and use indirection.' );
					renderer.renderMultiDrawInstances( object._multiDrawStarts, object._multiDrawCounts, object._multiDrawCount, object._multiDrawInstances );

				} else {

					if ( ! extensions.get( 'WEBGL_multi_draw' ) ) {

						var starts = object._multiDrawStarts;
						var counts = object._multiDrawCounts;
						var drawCount = object._multiDrawCount;
						var bytesPerElement = index ? attributes.get( index ).bytesPerElement : 1;
						var uniforms = properties.get( material ).currentProgram.getUniforms();
						for ( var i = 0; i < drawCount; i ++ ) {

							uniforms.setValue( _gl, '_gl_DrawID', i );
							renderer.render( starts[ i ] / bytesPerElement, counts[ i ] );

						}

					} else {

						renderer.renderMultiDraw( object._multiDrawStarts, object._multiDrawCounts, object._multiDrawCount );

					}

				}

			} else if ( object.isInstancedMesh ) {

				renderer.renderInstances( drawStart, drawCount, object.count );

			} else if ( geometry.isInstancedBufferGeometry ) {

				var maxInstanceCount = geometry._maxInstanceCount != undefined ? geometry._maxInstanceCount : Infinity;
				var instanceCount = Math.min( geometry.instanceCount, maxInstanceCount );

				renderer.renderInstances( drawStart, drawCount, instanceCount );

			} else {

				renderer.render( drawStart, drawCount );

			}

		};

		// Compile

		function prepareMaterial( material, scene, object ) {

			if ( material.transparent == true && material.side == DoubleSide && material.forceSinglePass == false ) {

				material.side = BackSide;
				material.needsUpdate = true;
				getProgram( material, scene, object );

				material.side = FrontSide;
				material.needsUpdate = true;
				getProgram( material, scene, object );

				material.side = DoubleSide;

			} else {

				getProgram( material, scene, object );

			}

		}

		/**
		 * Compiles all materials in the scene with the camera. This is useful to precompile shaders
		 * before the first rendering. If you want to add a 3D object to an existing scene, use the third
		 * optional parameter for applying the target scene.
		 *
		 * Note that the (target) scene's lighting and environment must be configured before calling this method.
		 *
		 * @param {Object3D} scene - The scene or another type of 3D object to precompile.
		 * @param {Camera} camera - The camera.
		 * @param {?Scene} [targetScene=null] - The target scene.
		 * @return {Set<Material>} The precompiled materials.
		 */
		this.compile = function ( scene, camera, targetScene = null ) {

			if ( targetScene == null ) targetScene = scene;

			currentRenderState = renderStates.get( targetScene );
			currentRenderState.init( camera );

			renderStateStack.push( currentRenderState );

			// gather lights from both the target scene and the new object that will be added to the scene.

			targetScene.traverseVisible( function ( object ) {

				if ( object.isLight && object.layers.test( camera.layers ) ) {

					currentRenderState.pushLight( object );

					if ( object.castShadow ) {

						currentRenderState.pushShadow( object );

					}

				}

			} );

			if ( scene != targetScene ) {

				scene.traverseVisible( function ( object ) {

					if ( object.isLight && object.layers.test( camera.layers ) ) {

						currentRenderState.pushLight( object );

						if ( object.castShadow ) {

							currentRenderState.pushShadow( object );

						}

					}

				} );

			}

			currentRenderState.setupLights();

			// Only initialize materials in the new scene, not the targetScene.

			var materials = new Set();

			scene.traverse( function ( object ) {

				if ( ! ( object.isMesh || object.isPoints || object.isLine || object.isSprite ) ) {

					return;

				}

				var material = object.material;

				if ( material ) {

					if ( Array.isArray( material ) ) {

						for ( var i = 0; i < material.length; i ++ ) {

							var material2 = material[ i ];

							prepareMaterial( material2, targetScene, object );
							materials.add( material2 );

						}

					} else {

						prepareMaterial( material, targetScene, object );
						materials.add( material );

					}

				}

			} );

			currentRenderState = renderStateStack.pop();

			return materials;

		};

		// compileAsync

		/**
		 * Asynchronous version of {@link WebGLRenderer#compile}.
		 *
		 * This method makes use of the `KHR_parallel_shader_compile` WebGL extension. Hence,
		 * it is recommended to use this version of `compile()` whenever possible.
		 *
		 * @async
		 * @param {Object3D} scene - The scene or another type of 3D object to precompile.
		 * @param {Camera} camera - The camera.
		 * @param {?Scene} [targetScene=null] - The target scene.
		 * @return {Promise} A Promise that resolves when the given scene can be rendered without unnecessary stalling due to shader compilation.
		 */
		this.compileAsync = function ( scene, camera, targetScene = null ) {

			var materials = this.compile( scene, camera, targetScene );

			// Wait for all the materials in the new object to indicate that they're
			// ready to be used before resolving the promise.

			return new Promise( ( resolve ) => {

				function checkMaterialsReady() {

					materials.forEach( function ( material ) {

						var materialProperties = properties.get( material );
						var program = materialProperties.currentProgram;

						if ( program.isReady() ) {

							// remove any programs that report they're ready to use from the list
							materials.delete( material );

						}

					} );

					// once the list of compiling materials is empty, call the callback

					if ( materials.size == 0 ) {

						resolve( scene );
						return;

					}

					// if some materials are still not ready, wait a bit and check again

					setTimeout( checkMaterialsReady, 10 );

				}

				if ( extensions.get( 'KHR_parallel_shader_compile' ) != null ) {

					// If we can check the compilation status of the materials without
					// blocking then do so right away.

					checkMaterialsReady();

				} else {

					// Otherwise start by waiting a bit to give the materials we just
					// initialized a chance to finish.

					setTimeout( checkMaterialsReady, 10 );

				}

			} );

		};

		// Animation Loop

		var onAnimationFrameCallback = null;

		function onAnimationFrame( time ) {

			if ( onAnimationFrameCallback ) onAnimationFrameCallback( time );

		}

		function onXRSessionStart() {

			animation.stop();

		}

		function onXRSessionEnd() {

			animation.start();

		}

		var animation = new WebGLAnimation();
		animation.setAnimationLoop( onAnimationFrame );

		if ( typeof self != 'undefined' ) animation.setContext( self );

		this.setAnimationLoop = function ( callback ) {

			onAnimationFrameCallback = callback;
			xr.setAnimationLoop( callback );

			( callback == null ) ? animation.stop() : animation.start();

		};

		xr.addEventListener( 'sessionstart', onXRSessionStart );
		xr.addEventListener( 'sessionend', onXRSessionEnd );

		// Rendering

		/**
		 * Renders the given scene (or other type of 3D object) using the given camera.
		 *
		 * The render is done to a previously specified render target set by calling {@link WebGLRenderer#setRenderTarget}
		 * or to the canvas as usual.
		 *
		 * By default render buffers are cleared before rendering but you can prevent
		 * this by setting the property `autoClear` to `false`. If you want to prevent
		 * only certain buffers being cleared you can `autoClearColor`, `autoClearDepth`
		 * or `autoClearStencil` to `false`. To force a clear, use {@link WebGLRenderer#clear}.
		 *
		 * @param {Object3D} scene - The scene to render.
		 * @param {Camera} camera - The camera.
		 */
		this.render = function ( scene, camera ) {

			if ( camera != undefined && camera.isCamera != true ) {

				Common.error( 'THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.' );
				return;

			}

			if ( _isContextLost == true ) return;

			// update scene graph

			if ( scene.matrixWorldAutoUpdate == true ) scene.updateMatrixWorld();

			// update camera matrices and frustum

			if ( camera.parent == null && camera.matrixWorldAutoUpdate == true ) camera.updateMatrixWorld();

			if ( xr.enabled == true && xr.isPresenting == true ) {

				if ( xr.cameraAutoUpdate == true ) xr.updateCamera( camera );

				camera = xr.getCamera(); // use XR camera for rendering

			}

			//
			if ( scene.isScene == true ) scene.onBeforeRender( _this, scene, camera, _currentRenderTarget );

			currentRenderState = renderStates.get( scene, renderStateStack.length );
			currentRenderState.init( camera );

			renderStateStack.push( currentRenderState );

			_projScreenMatrix.multiplyMatrices( camera.projectionMatrix, camera.matrixWorldInverse );
			_frustum.setFromProjectionMatrix( _projScreenMatrix );

			_localClippingEnabled = this.localClippingEnabled;
			_clippingEnabled = clipping.init( this.clippingPlanes, _localClippingEnabled );

			currentRenderList = renderLists.get( scene, renderListStack.length );
			currentRenderList.init();

			renderListStack.push( currentRenderList );

			if ( xr.enabled == true && xr.isPresenting == true ) {

				var depthSensingMesh = _this.xr.getDepthSensingMesh();

				if ( depthSensingMesh != null ) {

					projectObject( depthSensingMesh, camera, - Infinity, _this.sortObjects );

				}

			}

			projectObject( scene, camera, 0, _this.sortObjects );

			currentRenderList.finish();

			if ( _this.sortObjects == true ) {

				currentRenderList.sort( _opaqueSort, _transparentSort );

			}

			_renderBackground = xr.enabled == false || xr.isPresenting == false || xr.hasDepthSensing() == false;
			if ( _renderBackground ) {

				background.addToRenderList( currentRenderList, scene );

			}

			//

			this.info.render.frame ++;

			if ( _clippingEnabled == true ) clipping.beginShadows();

			var shadowsArray = currentRenderState.state.shadowsArray;

			shadowMap.render( shadowsArray, scene, camera );

			if ( _clippingEnabled == true ) clipping.endShadows();

			//

			if ( this.info.autoReset == true ) this.info.reset();

			// render scene

			var opaqueObjects = currentRenderList.opaque;
			var transmissiveObjects = currentRenderList.transmissive;

			currentRenderState.setupLights();

			if ( camera.isArrayCamera ) {

				var cameras = camera.cameras;

				if ( transmissiveObjects.length > 0 ) {

					for ( var i = 0, l = cameras.length; i < l; i ++ ) {

						var camera2 = cameras[ i ];

						renderTransmissionPass( opaqueObjects, transmissiveObjects, scene, camera2 );

					}

				}

				if ( _renderBackground ) background.render( scene );

				for ( var i = 0, l = cameras.length; i < l; i ++ ) {

					var camera2 = cameras[ i ];

					renderScene( currentRenderList, scene, camera2, camera2.viewport );

				}

			} else {

				if ( transmissiveObjects.length > 0 ) renderTransmissionPass( opaqueObjects, transmissiveObjects, scene, camera );

				if ( _renderBackground ) background.render( scene );

				renderScene( currentRenderList, scene, camera );

			}

			//

			if ( _currentRenderTarget != null && _currentActiveMipmapLevel == 0 ) {

				// resolve multisample renderbuffers to a single-sample texture if necessary

				textures.updateMultisampleRenderTarget( _currentRenderTarget );

				// Generate mipmap if we're using any kind of mipmap filtering

				textures.updateRenderTargetMipmap( _currentRenderTarget );

			}

			//

			if ( scene.isScene == true ) scene.onAfterRender( _this, scene, camera );

			// _gl.finish();

			bindingStates.resetDefaultState();
			_currentMaterialId = - 1;
			_currentCamera = null;

			renderStateStack.pop();

			if ( renderStateStack.length > 0 ) {

				currentRenderState = renderStateStack[ renderStateStack.length - 1 ];

				if ( _clippingEnabled == true ) clipping.setGlobalState( _this.clippingPlanes, currentRenderState.state.camera );

			} else {

				currentRenderState = null;

			}

			renderListStack.pop();

			if ( renderListStack.length > 0 ) {

				currentRenderList = renderListStack[ renderListStack.length - 1 ];

			} else {

				currentRenderList = null;

			}

		};

		function projectObject( object, camera, groupOrder, sortObjects ) {

			if ( object.visible == false ) return;

			var visible = object.layers.test( camera.layers );

			if ( visible ) {

				if ( object.isGroup ) {

					groupOrder = object.renderOrder;

				} else if ( object.isLOD ) {

					if ( object.autoUpdate == true ) object.update( camera );

				} else if ( object.isLight ) {

					currentRenderState.pushLight( object );

					if ( object.castShadow ) {

						currentRenderState.pushShadow( object );

					}

				} else if ( object.isSprite ) {

					if ( ! object.frustumCulled || _frustum.intersectsSprite( object ) ) {

						if ( sortObjects ) {

							_vector4.setFromMatrixPosition( object.matrixWorld )
								.applyMatrix4( _projScreenMatrix );

						}

						var geometry = objects.update( object );
						var material = object.material;

						if ( material.visible ) {

							currentRenderList.push( object, geometry, material, groupOrder, _vector4.z, null );

						}

					}

				} else if ( object.isMesh || object.isLine || object.isPoints ) {

					if ( ! object.frustumCulled || _frustum.intersectsObject( object ) ) {

						var geometry = objects.update( object );
						var material = object.material;

						if ( sortObjects ) {

							if ( object.boundingSphere != undefined ) {

								if ( object.boundingSphere == null ) object.computeBoundingSphere();
								_vector4.copy( object.boundingSphere.center );

							} else {

								if ( geometry.boundingSphere == null ) geometry.computeBoundingSphere();
								_vector4.copy( geometry.boundingSphere.center );

							}

							_vector4
								.applyMatrix4( object.matrixWorld )
								.applyMatrix4( _projScreenMatrix );

						}

						if ( Array.isArray( material ) ) {

							var groups = geometry.groups;

							for ( var i = 0, l = groups.length; i < l; i ++ ) {

								var group = groups[ i ];
								var groupMaterial = material[ group.materialIndex ];

								if ( groupMaterial && groupMaterial.visible ) {

									currentRenderList.push( object, geometry, groupMaterial, groupOrder, _vector4.z, group );

								}

							}

						} else if ( material.visible ) {

							currentRenderList.push( object, geometry, material, groupOrder, _vector4.z, null );

						}

					}

				}

			}

			var children = object.children;

			for ( var i = 0, l = children.length; i < l; i ++ ) {

				projectObject( children[ i ], camera, groupOrder, sortObjects );

			}

		}

		function renderScene( currentRenderList, scene, camera, viewport ) {

			var opaqueObjects = currentRenderList.opaque;
			var transmissiveObjects = currentRenderList.transmissive;
			var transparentObjects = currentRenderList.transparent;

			currentRenderState.setupLightsView( camera );

			if ( _clippingEnabled == true ) clipping.setGlobalState( _this.clippingPlanes, camera );

			if ( viewport ) state.viewport( _currentViewport.copy( viewport ) );

			if ( opaqueObjects.length > 0 ) renderObjects( opaqueObjects, scene, camera );
			if ( transmissiveObjects.length > 0 ) renderObjects( transmissiveObjects, scene, camera );
			if ( transparentObjects.length > 0 ) renderObjects( transparentObjects, scene, camera );

			// Ensure depth buffer writing is enabled so it can be cleared on next render

			state.buffers.depth.setTest( true );
			state.buffers.depth.setMask( true );
			state.buffers.color.setMask( true );

			state.setPolygonOffset( false );

		}

		function renderTransmissionPass( opaqueObjects, transmissiveObjects, scene, camera ) {

			var overrideMaterial = scene.isScene == true ? scene.overrideMaterial : null;

			if ( overrideMaterial != null ) {

				return;

			}

			if ( currentRenderState.state.transmissionRenderTarget[ camera.id ] == undefined ) {

				currentRenderState.state.transmissionRenderTarget[ camera.id ] = new WebGLRenderTarget( 1, 1, {
					generateMipmaps: true,
					type: ( extensions.has( 'EXT_color_buffer_half_float' ) || extensions.has( 'EXT_color_buffer_float' ) ) ? HalfFloatType : UnsignedByteType,
					minFilter: LinearMipmapLinearFilter,
					samples: 4,
					stencilBuffer: stencil,
					resolveDepthBuffer: false,
					resolveStencilBuffer: false,
					colorSpace: ColorManagement.workingColorSpace,
				} );

				// debug

				/*
				var geometry = new PlaneGeometry();
				var material = new MeshBasicMaterial( { map: _transmissionRenderTarget.texture } );

				var mesh = new Mesh( geometry, material );
				scene.add( mesh );
				*/

			}

			var transmissionRenderTarget = currentRenderState.state.transmissionRenderTarget[ camera.id ];

			var activeViewport = camera.viewport || _currentViewport;
			transmissionRenderTarget.setSize( activeViewport.z * _this.transmissionResolutionScale, activeViewport.w * _this.transmissionResolutionScale );

			//

			var currentRenderTarget = _this.getRenderTarget();
			_this.setRenderTarget( transmissionRenderTarget );

			_this.getClearColor( _currentClearColor );
			_currentClearAlpha = _this.getClearAlpha();
			if ( _currentClearAlpha < 1 ) _this.setClearColor( 0xffffff, 0.5 );

			_this.clear();

			if ( _renderBackground ) background.render( scene );

			// Turn off the features which can affect the frag color for opaque objects pass.
			// Otherwise they are applied twice in opaque objects pass and transmission objects pass.
			var currentToneMapping = _this.toneMapping;
			_this.toneMapping = NoToneMapping;

			// Remove viewport from camera to avoid nested render calls resetting viewport to it (e.g Reflector).
			// Transmission render pass requires viewport to match the transmissionRenderTarget.
			var currentCameraViewport = camera.viewport;
			if ( camera.viewport != undefined ) camera.viewport = undefined;

			currentRenderState.setupLightsView( camera );

			if ( _clippingEnabled == true ) clipping.setGlobalState( _this.clippingPlanes, camera );

			renderObjects( opaqueObjects, scene, camera );

			textures.updateMultisampleRenderTarget( transmissionRenderTarget );
			textures.updateRenderTargetMipmap( transmissionRenderTarget );

			if ( extensions.has( 'WEBGL_multisampled_render_to_texture' ) == false ) { // see #28131

				var renderTargetNeedsUpdate = false;

				for ( var i = 0, l = transmissiveObjects.length; i < l; i ++ ) {

					var renderItem = transmissiveObjects[ i ];

					var object = renderItem.object;
					var geometry = renderItem.geometry;
					var material = renderItem.material;
					var group = renderItem.group;

					if ( material.side == DoubleSide && object.layers.test( camera.layers ) ) {

						var currentSide = material.side;

						material.side = BackSide;
						material.needsUpdate = true;

						renderObject( object, scene, camera, geometry, material, group );

						material.side = currentSide;
						material.needsUpdate = true;

						renderTargetNeedsUpdate = true;

					}

				}

				if ( renderTargetNeedsUpdate == true ) {

					textures.updateMultisampleRenderTarget( transmissionRenderTarget );
					textures.updateRenderTargetMipmap( transmissionRenderTarget );

				}

			}

			_this.setRenderTarget( currentRenderTarget );

			_this.setClearColor( _currentClearColor, _currentClearAlpha );

			if ( currentCameraViewport != undefined ) camera.viewport = currentCameraViewport;

			_this.toneMapping = currentToneMapping;

		}

		function renderObjects( renderList, scene, camera ) {

			var overrideMaterial = scene.isScene == true ? scene.overrideMaterial : null;

			for ( var i = 0, l = renderList.length; i < l; i ++ ) {

				var renderItem = renderList[ i ];

				var object = renderItem.object;
				var geometry = renderItem.geometry;
				var group = renderItem.group;
				var material = renderItem.material;

				if ( material.allowOverride == true && overrideMaterial != null ) {

					material = overrideMaterial;

				}

				if ( object.layers.test( camera.layers ) ) {

					renderObject( object, scene, camera, geometry, material, group );

				}

			}

		}

		function renderObject( object, scene, camera, geometry, material, group ) {

			object.onBeforeRender( _this, scene, camera, geometry, material, group );

			object.modelViewMatrix.multiplyMatrices( camera.matrixWorldInverse, object.matrixWorld );
			object.normalMatrix.getNormalMatrix( object.modelViewMatrix );

			material.onBeforeRender( _this, scene, camera, geometry, object, group );

			if ( material.transparent == true && material.side == DoubleSide && material.forceSinglePass == false ) {

				material.side = BackSide;
				material.needsUpdate = true;
				_this.renderBufferDirect( camera, scene, geometry, material, object, group );

				material.side = FrontSide;
				material.needsUpdate = true;
				_this.renderBufferDirect( camera, scene, geometry, material, object, group );

				material.side = DoubleSide;

			} else {

				_this.renderBufferDirect( camera, scene, geometry, material, object, group );

			}

			object.onAfterRender( _this, scene, camera, geometry, material, group );

		}

		function getProgram( material, scene, object ) {

			if ( scene.isScene != true ) scene = _emptyScene; // scene could be a Mesh, Line, Points, ...

			var materialProperties = properties.get( material );

			var lights = currentRenderState.state.lights;
			var shadowsArray = currentRenderState.state.shadowsArray;

			var lightsStateVersion = lights.state.version;

			var parameters = programCache.getParameters( material, lights.state, shadowsArray, scene, object );
			var programCacheKey = programCache.getProgramCacheKey( parameters );

			var programs = materialProperties.programs;

			// always update environment and fog - changing these trigger an getProgram call, but it's possible that the program doesn't change

			materialProperties.environment = material.isMeshStandardMaterial ? scene.environment : null;
			materialProperties.fog = scene.fog;
			materialProperties.envMap = ( material.isMeshStandardMaterial ? cubeuvmaps : cubemaps ).get( material.envMap || materialProperties.environment );
			materialProperties.envMapRotation = ( materialProperties.environment != null && material.envMap == null ) ? scene.environmentRotation : material.envMapRotation;

			if ( programs == undefined ) {

				// new material

				material.addEventListener( 'dispose', onMaterialDispose );

				programs = new Map();
				materialProperties.programs = programs;

			}

			var program = programs.get( programCacheKey );

			if ( program != undefined ) {

				// early out if program and light state is identical

				if ( materialProperties.currentProgram == program && materialProperties.lightsStateVersion == lightsStateVersion ) {

					updateCommonMaterialProperties( material, parameters );

					return program;

				}

			} else {

				parameters.uniforms = programCache.getUniforms( material );

				material.onBeforeCompile( parameters, _this );

				program = programCache.acquireProgram( parameters, programCacheKey );
				programs.set( programCacheKey, program );

				materialProperties.uniforms = parameters.uniforms;

			}

			var uniforms = materialProperties.uniforms;

			if ( ( ! material.isShaderMaterial && ! material.isRawShaderMaterial ) || material.clipping == true ) {

				uniforms.clippingPlanes = clipping.uniform;

			}

			updateCommonMaterialProperties( material, parameters );

			// store the light setup it was created for

			materialProperties.needsLights = materialNeedsLights( material );
			materialProperties.lightsStateVersion = lightsStateVersion;

			if ( materialProperties.needsLights ) {

				// wire up the material to this renderer's lighting state

				uniforms.ambientLightColor.value = lights.state.ambient;
				uniforms.lightProbe.value = lights.state.probe;
				uniforms.directionalLights.value = lights.state.directional;
				uniforms.directionalLightShadows.value = lights.state.directionalShadow;
				uniforms.spotLights.value = lights.state.spot;
				uniforms.spotLightShadows.value = lights.state.spotShadow;
				uniforms.rectAreaLights.value = lights.state.rectArea;
				uniforms.ltc_1.value = lights.state.rectAreaLTC1;
				uniforms.ltc_2.value = lights.state.rectAreaLTC2;
				uniforms.pointLights.value = lights.state.point;
				uniforms.pointLightShadows.value = lights.state.pointShadow;
				uniforms.hemisphereLights.value = lights.state.hemi;

				uniforms.directionalShadowMap.value = lights.state.directionalShadowMap;
				uniforms.directionalShadowMatrix.value = lights.state.directionalShadowMatrix;
				uniforms.spotShadowMap.value = lights.state.spotShadowMap;
				uniforms.spotLightMatrix.value = lights.state.spotLightMatrix;
				uniforms.spotLightMap.value = lights.state.spotLightMap;
				uniforms.pointShadowMap.value = lights.state.pointShadowMap;
				uniforms.pointShadowMatrix.value = lights.state.pointShadowMatrix;
				// TODO (abelnation): add area lights shadow info to uniforms

			}

			materialProperties.currentProgram = program;
			materialProperties.uniformsList = null;

			return program;

		}

		function getUniformList( materialProperties ) {

			if ( materialProperties.uniformsList == null ) {

				var progUniforms = materialProperties.currentProgram.getUniforms();
				materialProperties.uniformsList = WebGLUniforms.seqWithValue( progUniforms.seq, materialProperties.uniforms );

			}

			return materialProperties.uniformsList;

		}

		function updateCommonMaterialProperties( material, parameters ) {

			var materialProperties = properties.get( material );

			materialProperties.outputColorSpace = parameters.outputColorSpace;
			materialProperties.batching = parameters.batching;
			materialProperties.batchingColor = parameters.batchingColor;
			materialProperties.instancing = parameters.instancing;
			materialProperties.instancingColor = parameters.instancingColor;
			materialProperties.instancingMorph = parameters.instancingMorph;
			materialProperties.skinning = parameters.skinning;
			materialProperties.morphTargets = parameters.morphTargets;
			materialProperties.morphNormals = parameters.morphNormals;
			materialProperties.morphColors = parameters.morphColors;
			materialProperties.morphTargetsCount = parameters.morphTargetsCount;
			materialProperties.numClippingPlanes = parameters.numClippingPlanes;
			materialProperties.numIntersection = parameters.numClipIntersection;
			materialProperties.vertexAlphas = parameters.vertexAlphas;
			materialProperties.vertexTangents = parameters.vertexTangents;
			materialProperties.toneMapping = parameters.toneMapping;

		}

		function setProgram( camera, scene, geometry, material, object ) {

			if ( scene.isScene != true ) scene = _emptyScene; // scene could be a Mesh, Line, Points, ...

			textures.resetTextureUnits();

			var fog = scene.fog;
			var environment = material.isMeshStandardMaterial ? scene.environment : null;
			var colorSpace = ( _currentRenderTarget == null ) ? _this.outputColorSpace : ( _currentRenderTarget.isXRRenderTarget == true ? _currentRenderTarget.texture.colorSpace : LinearSRGBColorSpace );
			var envMap = ( material.isMeshStandardMaterial ? cubeuvmaps : cubemaps ).get( material.envMap || environment );
			var vertexAlphas = material.vertexColors == true && !! geometry.attributes.color && geometry.attributes.color.itemSize == 4;
			var vertexTangents = !! geometry.attributes.tangent && ( !! material.normalMap || material.anisotropy > 0 );
			var morphTargets = !! geometry.morphAttributes.position;
			var morphNormals = !! geometry.morphAttributes.normal;
			var morphColors = !! geometry.morphAttributes.color;

			var toneMapping = NoToneMapping;

			if ( material.toneMapped ) {

				if ( _currentRenderTarget == null || _currentRenderTarget.isXRRenderTarget == true ) {

					toneMapping = _this.toneMapping;

				}

			}

			var morphAttribute = geometry.morphAttributes.position || geometry.morphAttributes.normal || geometry.morphAttributes.color;
			var morphTargetsCount = ( morphAttribute != undefined ) ? morphAttribute.length : 0;

			var materialProperties = properties.get( material );
			var lights = currentRenderState.state.lights;

			if ( _clippingEnabled == true ) {

				if ( _localClippingEnabled == true || camera != _currentCamera ) {

					var useCache =
						camera == _currentCamera &&
						material.id == _currentMaterialId;

					// we might want to call this function with some ClippingGroup
					// object instead of the material, once it becomes feasible
					// (#8465, #8379)
					clipping.setState( material, camera, useCache );

				}

			}

			//

			var needsProgramChange = false;

			if ( material.version == materialProperties.__version ) {

				if ( materialProperties.needsLights && ( materialProperties.lightsStateVersion != lights.state.version ) ) {

					needsProgramChange = true;

				} else if ( materialProperties.outputColorSpace != colorSpace ) {

					needsProgramChange = true;

				} else if ( object.isBatchedMesh && materialProperties.batching == false ) {

					needsProgramChange = true;

				} else if ( ! object.isBatchedMesh && materialProperties.batching == true ) {

					needsProgramChange = true;

				} else if ( object.isBatchedMesh && materialProperties.batchingColor == true && object.colorTexture == null ) {

					needsProgramChange = true;

				} else if ( object.isBatchedMesh && materialProperties.batchingColor == false && object.colorTexture != null ) {

					needsProgramChange = true;

				} else if ( object.isInstancedMesh && materialProperties.instancing == false ) {

					needsProgramChange = true;

				} else if ( ! object.isInstancedMesh && materialProperties.instancing == true ) {

					needsProgramChange = true;

				} else if ( object.isSkinnedMesh && materialProperties.skinning == false ) {

					needsProgramChange = true;

				} else if ( ! object.isSkinnedMesh && materialProperties.skinning == true ) {

					needsProgramChange = true;

				} else if ( object.isInstancedMesh && materialProperties.instancingColor == true && object.instanceColor == null ) {

					needsProgramChange = true;

				} else if ( object.isInstancedMesh && materialProperties.instancingColor == false && object.instanceColor != null ) {

					needsProgramChange = true;

				} else if ( object.isInstancedMesh && materialProperties.instancingMorph == true && object.morphTexture == null ) {

					needsProgramChange = true;

				} else if ( object.isInstancedMesh && materialProperties.instancingMorph == false && object.morphTexture != null ) {

					needsProgramChange = true;

				} else if ( materialProperties.envMap != envMap ) {

					needsProgramChange = true;

				} else if ( material.fog == true && materialProperties.fog != fog ) {

					needsProgramChange = true;

				} else if ( materialProperties.numClippingPlanes != undefined &&
					( materialProperties.numClippingPlanes != clipping.numPlanes ||
					materialProperties.numIntersection != clipping.numIntersection ) ) {

					needsProgramChange = true;

				} else if ( materialProperties.vertexAlphas != vertexAlphas ) {

					needsProgramChange = true;

				} else if ( materialProperties.vertexTangents != vertexTangents ) {

					needsProgramChange = true;

				} else if ( materialProperties.morphTargets != morphTargets ) {

					needsProgramChange = true;

				} else if ( materialProperties.morphNormals != morphNormals ) {

					needsProgramChange = true;

				} else if ( materialProperties.morphColors != morphColors ) {

					needsProgramChange = true;

				} else if ( materialProperties.toneMapping != toneMapping ) {

					needsProgramChange = true;

				} else if ( materialProperties.morphTargetsCount != morphTargetsCount ) {

					needsProgramChange = true;

				}

			} else {

				needsProgramChange = true;
				materialProperties.__version = material.version;

			}

			//

			var program = materialProperties.currentProgram;

			if ( needsProgramChange == true ) {

				program = getProgram( material, scene, object );

			}

			var refreshProgram = false;
			var refreshMaterial = false;
			var refreshLights = false;

			var p_uniforms = program.getUniforms(),
				m_uniforms = materialProperties.uniforms;

			if ( state.useProgram( program.program ) ) {

				refreshProgram = true;
				refreshMaterial = true;
				refreshLights = true;

			}

			if ( material.id != _currentMaterialId ) {

				_currentMaterialId = material.id;

				refreshMaterial = true;

			}

			if ( refreshProgram || _currentCamera != camera ) {

				// common camera uniforms

				var reverseDepthBuffer = state.buffers.depth.getReversed();

				if ( reverseDepthBuffer ) {

					_currentProjectionMatrix.copy( camera.projectionMatrix );

					toNormalizedProjectionMatrix( _currentProjectionMatrix );
					toReversedProjectionMatrix( _currentProjectionMatrix );

					p_uniforms.setValue( _gl, 'projectionMatrix', _currentProjectionMatrix );

				} else {

					p_uniforms.setValue( _gl, 'projectionMatrix', camera.projectionMatrix );

				}

				p_uniforms.setValue( _gl, 'viewMatrix', camera.matrixWorldInverse );

				var uCamPos = p_uniforms.map.cameraPosition;

				if ( uCamPos != undefined ) {

					uCamPos.setValue( _gl, _vector3.setFromMatrixPosition( camera.matrixWorld ) );

				}

				if ( capabilities.logarithmicDepthBuffer ) {

					p_uniforms.setValue( _gl, 'logDepthBufFC',
						2.0 / ( Math.log( camera.far + 1.0 ) / Math.LN2 ) );

				}

				// consider moving isOrthographic to UniformLib and WebGLMaterials, see https://github.com/mrdoob/three.js/pull/26467#issuecomment-1645185067

				if ( material.isMeshPhongMaterial ||
					material.isMeshToonMaterial ||
					material.isMeshLambertMaterial ||
					material.isMeshBasicMaterial ||
					material.isMeshStandardMaterial ||
					material.isShaderMaterial ) {

					p_uniforms.setValue( _gl, 'isOrthographic', camera.isOrthographicCamera == true );

				}

				if ( _currentCamera != camera ) {

					_currentCamera = camera;

					// lighting uniforms depend on the camera so enforce an update
					// now, in case this material supports lights - or later, when
					// the next material that does gets activated:

					refreshMaterial = true;		// set to true on material change
					refreshLights = true;		// remains set until update done

				}

			}

			// skinning and morph target uniforms must be set even if material didn't change
			// auto-setting of texture unit for bone and morph texture must go before other textures
			// otherwise textures used for skinning and morphing can take over texture units reserved for other material textures

			if ( object.isSkinnedMesh ) {

				p_uniforms.setOptional( _gl, object, 'bindMatrix' );
				p_uniforms.setOptional( _gl, object, 'bindMatrixInverse' );

				var skeleton = object.skeleton;

				if ( skeleton ) {

					if ( skeleton.boneTexture == null ) skeleton.computeBoneTexture();

					p_uniforms.setValue( _gl, 'boneTexture', skeleton.boneTexture, textures );

				}

			}

			if ( object.isBatchedMesh ) {

				p_uniforms.setOptional( _gl, object, 'batchingTexture' );
				p_uniforms.setValue( _gl, 'batchingTexture', object._matricesTexture, textures );

				p_uniforms.setOptional( _gl, object, 'batchingIdTexture' );
				p_uniforms.setValue( _gl, 'batchingIdTexture', object._indirectTexture, textures );

				p_uniforms.setOptional( _gl, object, 'batchingColorTexture' );
				if ( object._colorsTexture != null ) {

					p_uniforms.setValue( _gl, 'batchingColorTexture', object._colorsTexture, textures );

				}

			}

			var morphAttributes = geometry.morphAttributes;

			if ( morphAttributes.position != undefined || morphAttributes.normal != undefined || ( morphAttributes.color != undefined ) ) {

				morphtargets.update( object, geometry, program );

			}

			if ( refreshMaterial || materialProperties.receiveShadow != object.receiveShadow ) {

				materialProperties.receiveShadow = object.receiveShadow;
				p_uniforms.setValue( _gl, 'receiveShadow', object.receiveShadow );

			}

			// https://github.com/mrdoob/three.js/pull/24467#issuecomment-1209031512

			if ( material.isMeshGouraudMaterial && material.envMap != null ) {

				m_uniforms.envMap.value = envMap;

				m_uniforms.flipEnvMap.value = ( envMap.isCubeTexture && envMap.isRenderTargetTexture == false ) ? - 1 : 1;

			}

			if ( material.isMeshStandardMaterial && material.envMap == null && scene.environment != null ) {

				m_uniforms.envMapIntensity.value = scene.environmentIntensity;

			}

			if ( refreshMaterial ) {

				p_uniforms.setValue( _gl, 'toneMappingExposure', _this.toneMappingExposure );

				if ( materialProperties.needsLights ) {

					// the current material requires lighting info

					// note: all lighting uniforms are always set correctly
					// they simply reference the renderer's state for their
					// values
					//
					// use the current material's .needsUpdate flags to set
					// the GL state when required

					markUniformsLightsNeedsUpdate( m_uniforms, refreshLights );

				}

				// refresh uniforms common to several materials

				if ( fog && material.fog == true ) {

					materials.refreshFogUniforms( m_uniforms, fog );

				}

				materials.refreshMaterialUniforms( m_uniforms, material, _pixelRatio, _height, currentRenderState.state.transmissionRenderTarget[ camera.id ] );

				WebGLUniforms.upload( _gl, getUniformList( materialProperties ), m_uniforms, textures );

			}

			if ( material.isShaderMaterial && material.uniformsNeedUpdate == true ) {

				WebGLUniforms.upload( _gl, getUniformList( materialProperties ), m_uniforms, textures );
				material.uniformsNeedUpdate = false;

			}

			if ( material.isSpriteMaterial ) {

				p_uniforms.setValue( _gl, 'center', object.center );

			}

			// common matrices

			p_uniforms.setValue( _gl, 'modelViewMatrix', object.modelViewMatrix );
			p_uniforms.setValue( _gl, 'normalMatrix', object.normalMatrix );
			p_uniforms.setValue( _gl, 'modelMatrix', object.matrixWorld );

			// UBOs

			if ( material.isShaderMaterial || material.isRawShaderMaterial ) {

				var groups = material.uniformsGroups;

				for ( var i = 0, l = groups.length; i < l; i ++ ) {

					var group = groups[ i ];

					uniformsGroups.update( group, program );
					uniformsGroups.bind( group, program );

				}

			}

			return program;

		}

		// If uniforms are marked as clean, they don't need to be loaded to the GPU.

		function markUniformsLightsNeedsUpdate( uniforms, value ) {

			uniforms.ambientLightColor.needsUpdate = value;
			uniforms.lightProbe.needsUpdate = value;

			uniforms.directionalLights.needsUpdate = value;
			uniforms.directionalLightShadows.needsUpdate = value;
			uniforms.pointLights.needsUpdate = value;
			uniforms.pointLightShadows.needsUpdate = value;
			uniforms.spotLights.needsUpdate = value;
			uniforms.spotLightShadows.needsUpdate = value;
			uniforms.rectAreaLights.needsUpdate = value;
			uniforms.hemisphereLights.needsUpdate = value;

		}

		function materialNeedsLights( material ) {

			return material.isMeshLambertMaterial || material.isMeshToonMaterial || material.isMeshPhongMaterial ||
				material.isMeshStandardMaterial || material.isShadowMaterial ||
				( material.isShaderMaterial && material.lights == true );

		}

		/**
		 * Returns the active cube face.
		 *
		 * @return {number} The active cube face.
		 */
		this.getActiveCubeFace = function () {

			return _currentActiveCubeFace;

		};

		/**
		 * Returns the active mipmap level.
		 *
		 * @return {number} The active mipmap level.
		 */
		this.getActiveMipmapLevel = function () {

			return _currentActiveMipmapLevel;

		};

		/**
		 * Returns the active render target.
		 *
		 * @return {?WebGLRenderTarget} The active render target. Returns `null` if no render target
		 * is currently set.
		 */
		this.getRenderTarget = function () {

			return _currentRenderTarget;

		};

		this.setRenderTargetTextures = function ( renderTarget, colorTexture, depthTexture ) {

			var renderTargetProperties = properties.get( renderTarget );

			renderTargetProperties.__autoAllocateDepthBuffer = renderTarget.resolveDepthBuffer == false;
			if ( renderTargetProperties.__autoAllocateDepthBuffer == false ) {

				// The multisample_render_to_texture extension doesn't work properly if there
				// are midframe flushes and an external depth buffer. Disable use of the extension.
				renderTargetProperties.__useRenderToTexture = false;

			}

			properties.get( renderTarget.texture ).__webglTexture = colorTexture;
			properties.get( renderTarget.depthTexture ).__webglTexture = renderTargetProperties.__autoAllocateDepthBuffer ? undefined : depthTexture;

			renderTargetProperties.__hasExternalTextures = true;

		};

		this.setRenderTargetFramebuffer = function ( renderTarget, defaultFramebuffer ) {

			var renderTargetProperties = properties.get( renderTarget );
			renderTargetProperties.__webglFramebuffer = defaultFramebuffer;
			renderTargetProperties.__useDefaultFramebuffer = defaultFramebuffer == undefined;

		};

		var _scratchFrameBuffer = _gl.createFramebuffer();

		/**
		 * Sets the active rendertarget.
		 *
		 * @param {?WebGLRenderTarget} renderTarget - The render target to set. When `null` is given,
		 * the canvas is set as the active render target instead.
		 * @param {number} [activeCubeFace=0] - The active cube face when using a cube render target.
		 * Indicates the z layer to render in to when using 3D or array render targets.
		 * @param {number} [activeMipmapLevel=0] - The active mipmap level.
		 */
		this.setRenderTarget = function ( renderTarget, activeCubeFace = 0, activeMipmapLevel = 0 ) {

			_currentRenderTarget = renderTarget;
			_currentActiveCubeFace = activeCubeFace;
			_currentActiveMipmapLevel = activeMipmapLevel;

			var useDefaultFramebuffer = true;
			var framebuffer = null;
			var isCube = false;
			var isRenderTarget3D = false;

			if ( renderTarget ) {

				var renderTargetProperties = properties.get( renderTarget );

				if ( renderTargetProperties.__useDefaultFramebuffer != undefined ) {

					// We need to make sure to rebind the framebuffer.
					state.bindFramebuffer( _gl.FRAMEBUFFER, null );
					useDefaultFramebuffer = false;

				} else if ( renderTargetProperties.__webglFramebuffer == undefined ) {

					textures.setupRenderTarget( renderTarget );

				} else if ( renderTargetProperties.__hasExternalTextures ) {

					// Color and depth texture must be rebound in order for the swapchain to update.
					textures.rebindTextures( renderTarget, properties.get( renderTarget.texture ).__webglTexture, properties.get( renderTarget.depthTexture ).__webglTexture );

				} else if ( renderTarget.depthBuffer ) {

					// check if the depth texture is already bound to the frame buffer and that it's been initialized
					var depthTexture = renderTarget.depthTexture;
					if ( renderTargetProperties.__boundDepthTexture != depthTexture ) {

						// check if the depth texture is compatible
						if (
							depthTexture != null &&
							properties.has( depthTexture ) &&
							( renderTarget.width != depthTexture.image.width || renderTarget.height != depthTexture.image.height )
						) {

							throw ( 'WebGLRenderTarget: Attached DepthTexture is initialized to the incorrect size.' );

						}

						// Swap the depth buffer to the currently attached one
						textures.setupDepthRenderbuffer( renderTarget );

					}

				}

				var texture = renderTarget.texture;

				if ( texture.isData3DTexture || texture.isDataArrayTexture || texture.isCompressedArrayTexture ) {

					isRenderTarget3D = true;

				}

				var __webglFramebuffer = properties.get( renderTarget ).__webglFramebuffer;

				if ( renderTarget.isWebGLCubeRenderTarget ) {

					if ( Array.isArray( __webglFramebuffer[ activeCubeFace ] ) ) {

						framebuffer = __webglFramebuffer[ activeCubeFace ][ activeMipmapLevel ];

					} else {

						framebuffer = __webglFramebuffer[ activeCubeFace ];

					}

					isCube = true;

				} else if ( ( renderTarget.samples > 0 ) && textures.useMultisampledRTT( renderTarget ) == false ) {

					framebuffer = properties.get( renderTarget ).__webglMultisampledFramebuffer;

				} else {

					if ( Array.isArray( __webglFramebuffer ) ) {

						framebuffer = __webglFramebuffer[ activeMipmapLevel ];

					} else {

						framebuffer = __webglFramebuffer;

					}

				}

				_currentViewport.copy( renderTarget.viewport );
				_currentScissor.copy( renderTarget.scissor );
				_currentScissorTest = renderTarget.scissorTest;

			} else {

				_currentViewport.copy( _viewport ).multiplyScalar( _pixelRatio ).floor();
				_currentScissor.copy( _scissor ).multiplyScalar( _pixelRatio ).floor();
				_currentScissorTest = _scissorTest;

			}

			// Use a scratch frame buffer if rendering to a mip level to avoid depth buffers
			// being bound that are different sizes.
			if ( activeMipmapLevel != 0 ) {

				framebuffer = _scratchFrameBuffer;

			}

			var framebufferBound = state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

			if ( framebufferBound && useDefaultFramebuffer ) {

				state.drawBuffers( renderTarget, framebuffer );

			}

			state.viewport( _currentViewport );
			state.scissor( _currentScissor );
			state.setScissorTest( _currentScissorTest );

			if ( isCube ) {

				var textureProperties = properties.get( renderTarget.texture );
				_gl.framebufferTexture2D( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_CUBE_MAP_POSITIVE_X + activeCubeFace, textureProperties.__webglTexture, activeMipmapLevel );

			} else if ( isRenderTarget3D ) {

				var textureProperties = properties.get( renderTarget.texture );
				var layer = activeCubeFace;
				_gl.framebufferTextureLayer( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, textureProperties.__webglTexture, activeMipmapLevel, layer );

			} else if ( renderTarget != null && activeMipmapLevel != 0 ) {

				// Only bind the frame buffer if we are using a scratch frame buffer to render to a mipmap.
				// If we rebind the texture when using a multi sample buffer then an error about inconsistent samples will be thrown.
				var textureProperties = properties.get( renderTarget.texture );
				_gl.framebufferTexture2D( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, textureProperties.__webglTexture, activeMipmapLevel );

			}

			_currentMaterialId = - 1; // reset current material to ensure correct uniform bindings

		};

		/**
		 * Reads the pixel data from the given render target into the given buffer.
		 *
		 * @param {WebGLRenderTarget} renderTarget - The render target to read from.
		 * @param {number} x - The `x` coordinate of the copy region's origin.
		 * @param {number} y - The `y` coordinate of the copy region's origin.
		 * @param {number} width - The width of the copy region.
		 * @param {number} height - The height of the copy region.
		 * @param {TypedArray} buffer - The result buffer.
		 * @param {number} [activeCubeFaceIndex] - The active cube face index.
		 * @param {number} [textureIndex=0] - The texture index of an MRT render target.
		 */
		this.readRenderTargetPixels = function ( renderTarget, x, y, width, height, buffer, activeCubeFaceIndex, textureIndex = 0 ) {

			if ( ! ( renderTarget && renderTarget.isWebGLRenderTarget ) ) {

				Common.error( 'THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.' );
				return;

			}

			var framebuffer = properties.get( renderTarget ).__webglFramebuffer;

			if ( renderTarget.isWebGLCubeRenderTarget && activeCubeFaceIndex != undefined ) {

				framebuffer = framebuffer[ activeCubeFaceIndex ];

			}

			if ( framebuffer ) {

				state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

				try {

					var texture = renderTarget.textures[ textureIndex ];
					var textureFormat = texture.format;
					var textureType = texture.type;

					if ( ! capabilities.textureFormatReadable( textureFormat ) ) {

						Common.error( 'THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.' );
						return;

					}

					if ( ! capabilities.textureTypeReadable( textureType ) ) {

						Common.error( 'THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.' );
						return;

					}

					// the following if statement ensures valid read requests (no out-of-bounds pixels, see #8604)

					if ( ( x >= 0 && x <= ( renderTarget.width - width ) ) && ( y >= 0 && y <= ( renderTarget.height - height ) ) ) {

						// when using MRT, select the corect color buffer for the subsequent read command

						if ( renderTarget.textures.length > 1 ) _gl.readBuffer( _gl.COLOR_ATTACHMENT0 + textureIndex );

						_gl.readPixels( x, y, width, height, utils.convert( textureFormat ), utils.convert( textureType ), buffer );

					}

				} finally {

					// restore framebuffer of current render target if necessary

					var framebuffer = ( _currentRenderTarget != null ) ? properties.get( _currentRenderTarget ).__webglFramebuffer : null;
					state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

				}

			}

		};

		/**
		 * Asynchronous, non-blocking version of {@link WebGLRenderer#readRenderTargetPixels}.
		 *
		 * It is recommended to use this version of `readRenderTargetPixels()` whenever possible.
		 *
		 * @async
		 * @param {WebGLRenderTarget} renderTarget - The render target to read from.
		 * @param {number} x - The `x` coordinate of the copy region's origin.
		 * @param {number} y - The `y` coordinate of the copy region's origin.
		 * @param {number} width - The width of the copy region.
		 * @param {number} height - The height of the copy region.
		 * @param {TypedArray} buffer - The result buffer.
		 * @param {number} [activeCubeFaceIndex] - The active cube face index.
		 * @param {number} [textureIndex=0] - The texture index of an MRT render target.
		 * @return {Promise<TypedArray>} A Promise that resolves when the read has been finished. The resolve provides the read data as a typed array.
		 */
		this.readRenderTargetPixelsAsync = async function ( renderTarget, x, y, width, height, buffer, activeCubeFaceIndex, textureIndex = 0 ) {

			if ( ! ( renderTarget && renderTarget.isWebGLRenderTarget ) ) {

				throw ( 'THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.' );

			}

			var framebuffer = properties.get( renderTarget ).__webglFramebuffer;
			if ( renderTarget.isWebGLCubeRenderTarget && activeCubeFaceIndex != undefined ) {

				framebuffer = framebuffer[ activeCubeFaceIndex ];

			}

			if ( framebuffer ) {

				// the following if statement ensures valid read requests (no out-of-bounds pixels, see #8604)
				if ( ( x >= 0 && x <= ( renderTarget.width - width ) ) && ( y >= 0 && y <= ( renderTarget.height - height ) ) ) {

					// set the active frame buffer to the one we want to read
					state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

					var texture = renderTarget.textures[ textureIndex ];
					var textureFormat = texture.format;
					var textureType = texture.type;

					if ( ! capabilities.textureFormatReadable( textureFormat ) ) {

						throw ( 'THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in RGBA or implementation defined format.' );

					}

					if ( ! capabilities.textureTypeReadable( textureType ) ) {

						throw ( 'THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in UnsignedByteType or implementation defined type.' );

					}

					var glBuffer = _gl.createBuffer();
					_gl.bindBuffer( _gl.PIXEL_PACK_BUFFER, glBuffer );
					_gl.bufferData( _gl.PIXEL_PACK_BUFFER, buffer.byteLength, _gl.STREAM_READ );

					// when using MRT, select the corect color buffer for the subsequent read command

					if ( renderTarget.textures.length > 1 ) _gl.readBuffer( _gl.COLOR_ATTACHMENT0 + textureIndex );

					_gl.readPixels( x, y, width, height, utils.convert( textureFormat ), utils.convert( textureType ), 0 );

					// reset the frame buffer to the currently set buffer before waiting
					var currFramebuffer = _currentRenderTarget != null ? properties.get( _currentRenderTarget ).__webglFramebuffer : null;
					state.bindFramebuffer( _gl.FRAMEBUFFER, currFramebuffer );

					// check if the commands have finished every 8 ms
					var sync = _gl.fenceSync( _gl.SYNC_GPU_COMMANDS_COMPLETE, 0 );

					_gl.flush();

					await probeAsync( _gl, sync, 4 );

					// read the data and delete the buffer
					_gl.bindBuffer( _gl.PIXEL_PACK_BUFFER, glBuffer );
					_gl.getBufferSubData( _gl.PIXEL_PACK_BUFFER, 0, buffer );
					_gl.deleteBuffer( glBuffer );
					_gl.deleteSync( sync );

					return buffer;

				} else {

					throw ( 'THREE.WebGLRenderer.readRenderTargetPixelsAsync: requested read bounds are out of range.' );

				}

			}

		};

		/**
		 * Copies pixels from the current bound framebuffer into the given texture.
		 *
		 * @param {FramebufferTexture} texture - The texture.
		 * @param {?Vector2} [position=null] - The start position of the copy operation.
		 * @param {number} [level=0] - The mip level. The default represents the base mip.
		 */
		this.copyFramebufferToTexture = function ( texture, position = null, level = 0 ) {

			var levelScale = Math.pow( 2, - level );
			var width = Math.floor( texture.image.width * levelScale );
			var height = Math.floor( texture.image.height * levelScale );

			var x = position != null ? position.x : 0;
			var y = position != null ? position.y : 0;

			textures.setTexture2D( texture, 0 );

			_gl.copyTexSubImage2D( _gl.TEXTURE_2D, level, 0, 0, x, y, width, height );

			state.unbindTexture();

		};

		var _srcFramebuffer = _gl.createFramebuffer();
		var _dstFramebuffer = _gl.createFramebuffer();

		/**
		 * Copies data of the given source texture into a destination texture.
		 *
		 * When using render target textures as `srcTexture` and `dstTexture`, you must make sure both render targets are initialized
		 * {@link WebGLRenderer#initRenderTarget}.
		 *
		 * @param {Texture} srcTexture - The source texture.
		 * @param {Texture} dstTexture - The destination texture.
		 * @param {?(Box2|Box3)} [srcRegion=null] - A bounding box which describes the source region. Can be two or three-dimensional.
		 * @param {?(Vector2|Vector3)} [dstPosition=null] - A vector that represents the origin of the destination region. Can be two or three-dimensional.
		 * @param {number} [srcLevel=0] - The source mipmap level to copy.
		 * @param {?number} [dstLevel=null] - The destination mipmap level.
		 */
		this.copyTextureToTexture = function ( srcTexture, dstTexture, srcRegion = null, dstPosition = null, srcLevel = 0, dstLevel = null ) {

			// support the previous signature with just a single dst mipmap level
			if ( dstLevel == null ) {

				if ( srcLevel != 0 ) {

					// @deprecated, r171
					warnOnce( 'WebGLRenderer: copyTextureToTexture function signature has changed to support src and dst mipmap levels.' );
					dstLevel = srcLevel;
					srcLevel = 0;

				} else {

					dstLevel = 0;

				}

			}

			// gather the necessary dimensions to copy
			var width, height, depth, minX, minY, minZ;
			var dstX, dstY, dstZ;
			var image = srcTexture.isCompressedTexture ? srcTexture.mipmaps[ dstLevel ] : srcTexture.image;
			if ( srcRegion != null ) {

				width = srcRegion.max.x - srcRegion.min.x;
				height = srcRegion.max.y - srcRegion.min.y;
				depth = srcRegion.isBox3 ? srcRegion.max.z - srcRegion.min.z : 1;
				minX = srcRegion.min.x;
				minY = srcRegion.min.y;
				minZ = srcRegion.isBox3 ? srcRegion.min.z : 0;

			} else {

				var levelScale = Math.pow( 2, - srcLevel );
				width = Math.floor( image.width * levelScale );
				height = Math.floor( image.height * levelScale );
				if ( srcTexture.isDataArrayTexture ) {

					depth = image.depth;

				} else if ( srcTexture.isData3DTexture ) {

					depth = Math.floor( image.depth * levelScale );

				} else {

					depth = 1;

				}

				minX = 0;
				minY = 0;
				minZ = 0;

			}

			if ( dstPosition != null ) {

				dstX = dstPosition.x;
				dstY = dstPosition.y;
				dstZ = dstPosition.z;

			} else {

				dstX = 0;
				dstY = 0;
				dstZ = 0;

			}

			// Set up the destination target
			var glFormat = utils.convert( dstTexture.format );
			var glType = utils.convert( dstTexture.type );
			var glTarget;

			if ( dstTexture.isData3DTexture ) {

				textures.setTexture3D( dstTexture, 0 );
				glTarget = _gl.TEXTURE_3D;

			} else if ( dstTexture.isDataArrayTexture || dstTexture.isCompressedArrayTexture ) {

				textures.setTexture2DArray( dstTexture, 0 );
				glTarget = _gl.TEXTURE_2D_ARRAY;

			} else {

				textures.setTexture2D( dstTexture, 0 );
				glTarget = _gl.TEXTURE_2D;

			}

			_gl.pixelStorei( _gl.UNPACK_FLIP_Y_WEBGL, dstTexture.flipY );
			_gl.pixelStorei( _gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, dstTexture.premultiplyAlpha );
			_gl.pixelStorei( _gl.UNPACK_ALIGNMENT, dstTexture.unpackAlignment );

			// used for copying data from cpu
			var currentUnpackRowLen = _gl.getParameter( _gl.UNPACK_ROW_LENGTH );
			var currentUnpackImageHeight = _gl.getParameter( _gl.UNPACK_IMAGE_HEIGHT );
			var currentUnpackSkipPixels = _gl.getParameter( _gl.UNPACK_SKIP_PIXELS );
			var currentUnpackSkipRows = _gl.getParameter( _gl.UNPACK_SKIP_ROWS );
			var currentUnpackSkipImages = _gl.getParameter( _gl.UNPACK_SKIP_IMAGES );

			_gl.pixelStorei( _gl.UNPACK_ROW_LENGTH, image.width );
			_gl.pixelStorei( _gl.UNPACK_IMAGE_HEIGHT, image.height );
			_gl.pixelStorei( _gl.UNPACK_SKIP_PIXELS, minX );
			_gl.pixelStorei( _gl.UNPACK_SKIP_ROWS, minY );
			_gl.pixelStorei( _gl.UNPACK_SKIP_IMAGES, minZ );

			// set up the src texture
			var isSrc3D = srcTexture.isDataArrayTexture || srcTexture.isData3DTexture;
			var isDst3D = dstTexture.isDataArrayTexture || dstTexture.isData3DTexture;
			if ( srcTexture.isDepthTexture ) {

				var srcTextureProperties = properties.get( srcTexture );
				var dstTextureProperties = properties.get( dstTexture );
				var srcRenderTargetProperties = properties.get( srcTextureProperties.__renderTarget );
				var dstRenderTargetProperties = properties.get( dstTextureProperties.__renderTarget );
				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, srcRenderTargetProperties.__webglFramebuffer );
				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, dstRenderTargetProperties.__webglFramebuffer );

				for ( var i = 0; i < depth; i ++ ) {

					// if the source or destination are a 3d target then a layer needs to be bound
					if ( isSrc3D ) {

						_gl.framebufferTextureLayer( _gl.READ_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, properties.get( srcTexture ).__webglTexture, srcLevel, minZ + i );
						_gl.framebufferTextureLayer( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, properties.get( dstTexture ).__webglTexture, dstLevel, dstZ + i );

					}

					_gl.blitFramebuffer( minX, minY, width, height, dstX, dstY, width, height, _gl.DEPTH_BUFFER_BIT, _gl.NEAREST );

				}

				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, null );
				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, null );

			} else if ( srcLevel != 0 || srcTexture.isRenderTargetTexture || properties.has( srcTexture ) ) {

				// get the appropriate frame buffers
				var srcTextureProperties = properties.get( srcTexture );
				var dstTextureProperties = properties.get( dstTexture );

				// bind the frame buffer targets
				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, _srcFramebuffer );
				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, _dstFramebuffer );

				for ( var i = 0; i < depth; i ++ ) {

					// assign the correct layers and mip maps to the frame buffers
					if ( isSrc3D ) {

						_gl.framebufferTextureLayer( _gl.READ_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, srcTextureProperties.__webglTexture, srcLevel, minZ + i );

					} else {

						_gl.framebufferTexture2D( _gl.READ_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, srcTextureProperties.__webglTexture, srcLevel );

					}

					if ( isDst3D ) {

						_gl.framebufferTextureLayer( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, dstTextureProperties.__webglTexture, dstLevel, dstZ + i );

					} else {

						_gl.framebufferTexture2D( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, dstTextureProperties.__webglTexture, dstLevel );

					}

					// copy the data using the fastest function that can achieve the copy
					if ( srcLevel != 0 ) {

						_gl.blitFramebuffer( minX, minY, width, height, dstX, dstY, width, height, _gl.COLOR_BUFFER_BIT, _gl.NEAREST );

					} else if ( isDst3D ) {

						_gl.copyTexSubImage3D( glTarget, dstLevel, dstX, dstY, dstZ + i, minX, minY, width, height );

					} else {

						_gl.copyTexSubImage2D( glTarget, dstLevel, dstX, dstY, minX, minY, width, height );

					}

				}

				// unbind read, draw buffers
				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, null );
				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, null );

			} else {

				if ( isDst3D ) {

					// copy data into the 3d texture
					if ( srcTexture.isDataTexture || srcTexture.isData3DTexture ) {

						_gl.texSubImage3D( glTarget, dstLevel, dstX, dstY, dstZ, width, height, depth, glFormat, glType, image.data );

					} else if ( dstTexture.isCompressedArrayTexture ) {

						_gl.compressedTexSubImage3D( glTarget, dstLevel, dstX, dstY, dstZ, width, height, depth, glFormat, image.data );

					} else {

						_gl.texSubImage3D( glTarget, dstLevel, dstX, dstY, dstZ, width, height, depth, glFormat, glType, image );

					}

				} else {

					// copy data into the 2d texture
					if ( srcTexture.isDataTexture ) {

						_gl.texSubImage2D( _gl.TEXTURE_2D, dstLevel, dstX, dstY, width, height, glFormat, glType, image.data );

					} else if ( srcTexture.isCompressedTexture ) {

						_gl.compressedTexSubImage2D( _gl.TEXTURE_2D, dstLevel, dstX, dstY, image.width, image.height, glFormat, image.data );

					} else {

						_gl.texSubImage2D( _gl.TEXTURE_2D, dstLevel, dstX, dstY, width, height, glFormat, glType, image );

					}

				}

			}

			// reset values
			_gl.pixelStorei( _gl.UNPACK_ROW_LENGTH, currentUnpackRowLen );
			_gl.pixelStorei( _gl.UNPACK_IMAGE_HEIGHT, currentUnpackImageHeight );
			_gl.pixelStorei( _gl.UNPACK_SKIP_PIXELS, currentUnpackSkipPixels );
			_gl.pixelStorei( _gl.UNPACK_SKIP_ROWS, currentUnpackSkipRows );
			_gl.pixelStorei( _gl.UNPACK_SKIP_IMAGES, currentUnpackSkipImages );

			// Generate mipmaps only when copying level 0
			if ( dstLevel == 0 && dstTexture.generateMipmaps ) {

				_gl.generateMipmap( glTarget );

			}

			state.unbindTexture();

		};

		this.copyTextureToTexture3D = function ( srcTexture, dstTexture, srcRegion = null, dstPosition = null, level = 0 ) {

			// @deprecated, r170
			warnOnce( 'WebGLRenderer: copyTextureToTexture3D function has been deprecated. Use "copyTextureToTexture" instead.' );

			return this.copyTextureToTexture( srcTexture, dstTexture, srcRegion, dstPosition, level );

		};

		/**
		 * Initializes the given WebGLRenderTarget memory. Useful for initializing a render target so data
		 * can be copied into it using {@link WebGLRenderer#copyTextureToTexture} before it has been
		 * rendered to.
		 *
		 * @param {WebGLRenderTarget} target - The render target.
		 */
		this.initRenderTarget = function ( target ) {

			if ( properties.get( target ).__webglFramebuffer == undefined ) {

				textures.setupRenderTarget( target );

			}

		};

		/**
		 * Initializes the given texture. Useful for preloading a texture rather than waiting until first
		 * render (which can cause noticeable lags due to decode and GPU upload overhead).
		 *
		 * @param {Texture} texture - The texture.
		 */
		this.initTexture = function ( texture ) {

			if ( texture.isCubeTexture ) {

				textures.setTextureCube( texture, 0 );

			} else if ( texture.isData3DTexture ) {

				textures.setTexture3D( texture, 0 );

			} else if ( texture.isDataArrayTexture || texture.isCompressedArrayTexture ) {

				textures.setTexture2DArray( texture, 0 );

			} else {

				textures.setTexture2D( texture, 0 );

			}

			state.unbindTexture();

		};

		/**
		 * Can be used to reset the internal WebGL state. This method is mostly
		 * relevant for applications which share a single WebGL context across
		 * multiple WebGL libraries.
		 */
		this.resetState = function () {

			_currentActiveCubeFace = 0;
			_currentActiveMipmapLevel = 0;
			_currentRenderTarget = null;

			state.reset();
			bindingStates.reset();

		};

		if ( typeof __THREE_DEVTOOLS__ != 'undefined' ) {

			__THREE_DEVTOOLS__.dispatchEvent( new CustomEvent( 'observe', { detail: this } ) );

		}

	}

	/**
	 * Defines the coordinate system of the renderer.
	 *
	 * In `WebGLRenderer`, the value is always `WebGLCoordinateSystem`.
	 *
	 * @type {WebGLCoordinateSystem|WebGPUCoordinateSystem}
	 * @default WebGLCoordinateSystem
	 * @readonly
	 */
	get coordinateSystem() {

		return WebGLCoordinateSystem;

	}

	/**
	 * Defines the output color space of the renderer.
	 *
	 * @type {SRGBColorSpace|LinearSRGBColorSpace}
	 * @default SRGBColorSpace
	 */
	get outputColorSpace() {

		return this._outputColorSpace;

	}

	set outputColorSpace( colorSpace ) {

		this._outputColorSpace = colorSpace;

		var gl = this.getContext();
		gl.drawingBufferColorSpace = ColorManagement._getDrawingBufferColorSpace( colorSpace );
		gl.unpackColorSpace = ColorManagement._getUnpackColorSpace();

	}

		// internal properties

		var _this = this;

		var _isContextLost = false;

		// internal state cache

		this._outputColorSpace = SRGBColorSpace;

		var _currentActiveCubeFace = 0;
		var _currentActiveMipmapLevel = 0;
		var _currentRenderTarget = null;
		var _currentMaterialId = - 1;

		var _currentCamera = null;

		var _currentViewport = new Vector4();
		var _currentScissor = new Vector4();
		var _currentScissorTest = null;

		var _currentClearColor = new Color( 0x000000 );
		var _currentClearAlpha = 0;

		//

		var _width = canvas.width;
		var _height = canvas.height;

		var _pixelRatio = 1;
		var _opaqueSort = null;
		var _transparentSort = null;

		var _viewport = new Vector4( 0, 0, _width, _height );
		var _scissor = new Vector4( 0, 0, _width, _height );
		var _scissorTest = false;

		// frustum

		var _frustum = new Frustum();

		// clipping

		var _clippingEnabled = false;
		var _localClippingEnabled = false;

		// camera matrices cache

		var _currentProjectionMatrix = new Matrix4();
		var _projScreenMatrix = new Matrix4();

		var _vector3 = new Vector3();

		var _vector4 = new Vector4();

		var _emptyScene = { background: null, fog: null, environment: null, overrideMaterial: null, isScene: true };

		var _renderBackground = false;

}

// JSDoc

/**
 * WebGLRenderer options.
 *
 * @typedef {Object} WebGLRenderer~Options
 * @property {DOMElement} [canvas=null] - A canvas element where the renderer draws its output. If not passed in here, a new canvas element will be created by the renderer.
 * @property {WebGL2RenderingContext} [context=null] - Can be used to attach an existing rendering context to this renderer.
 * @property {('highp'|'mediump'|'lowp')} [precision='highp'] - The default shader precision. Uses `highp` if supported by the device.
 * @property {boolean} [alpha=false] - Controls the default clear alpha value. When set to`true`, the value is `0`. Otherwise it's `1`.
 * @property {boolean} [premultipliedAlpha=true] Whether the renderer will assume colors have premultiplied alpha or not.
 * @property {boolean} [antialias=false] Whether to use the default MSAA or not.
 * @property {boolean} [stencil=false] Whether the drawing buffer has a stencil buffer of at least 8 bits or not.
 * @property {boolean} [preserveDrawingBuffer=false] Whether to preserve the buffer until manually cleared or overwritten.
 * @property {('default'|'low-power'|'high-performance')} [powerPreference='default'] Provides a hint to the user agent indicating what configuration of GPU is suitable for this WebGL context.
 * @property {boolean} [failIfMajorPerformanceCaveat=false] Whether the renderer creation will fail upon low performance is detected.
 * @property {boolean} [depth=true] Whether the drawing buffer has a depth buffer of at least 16 bits.
 * @property {boolean} [logarithmicDepthBuffer=false] Whether to use a logarithmic depth buffer. It may be necessary to use this if dealing with huge differences in scale in a single scene.
 * Note that this setting uses `gl_FragDepth` if available which disables the Early Fragment Test optimization and can cause a decrease in performance.
 * @property {boolean} [reverseDepthBuffer=false] Whether to use a reverse depth buffer. Requires the `EXT_clip_control` extension.
 * This is a more faster and accurate version than logarithmic depth buffer.
 **/

/**
 * WebGLRenderer Capabilities.
 *
 * @typedef {Object} WebGLRenderer~Capabilities
 * @property {Function} getMaxAnisotropy - Returns the maximum available anisotropy.
 * @property {Function} getMaxPrecision - Returns the maximum available precision for vertex and fragment shaders.
 * @property {boolean} logarithmicDepthBuffer - `true` if `logarithmicDepthBuffer` was set to `true` in the constructor.
 * @property {number} maxAttributes - The number of shader attributes that can be used by the vertex shader.
 * @property {number} maxCubemapSize - Maximum height * width of cube map textures that a shader can use.
 * @property {number} maxFragmentUniforms - The number of uniforms that can be used by a fragment shader.
 * @property {number} maxSamples - Maximum number of samples in context of Multisample anti-aliasing (MSAA).
 * @property {number} maxTextures - The maximum number of textures that can be used by a shader.
 * @property {number} maxTextureSize - Maximum height * width of a texture that a shader use.
 * @property {number} maxVaryings - The number of varying vectors that can used by shaders.
 * @property {number} maxVertexTextures - The number of textures that can be used in a vertex shader.
 * @property {number} maxVertexUniforms - The maximum number of uniforms that can be used in a vertex shader.
 * @property {string} precision - The shader precision currently being used by the renderer.
 * @property {boolean} reverseDepthBuffer - `true` if `reverseDepthBuffer` was set to `true` in the constructor
 * and the rendering context supports `EXT_clip_control`.
 * @property {boolean} vertexTextures - `true` if vertex textures can be used.
 **/

/**
 * WebGLRenderer Info Memory
 *
 * @typedef {Object} WebGLRenderer~InfoMemory
 * @property {number} geometries - The number of active geometries.
 * @property {number} textures - The number of active textures.
 **/

/**
 * WebGLRenderer Info Render
 *
 * @typedef {Object} WebGLRenderer~InfoRender
 * @property {number} frame - The frame ID.
 * @property {number} calls - The number of draw calls per frame.
 * @property {number} triangles - The number of rendered triangles primitives per frame.
 * @property {number} points - The number of rendered points primitives per frame.
 * @property {number} lines - The number of rendered lines primitives per frame.
 **/

/**
 * WebGLRenderer Info
 *
 * @typedef {Object} WebGLRenderer~Info
 * @property {boolean} [autoReset=true] - Whether to automatically reset the info by the renderer or not.
 * @property {WebGLRenderer~InfoMemory} memory - Information about allocated objects.
 * @property {WebGLRenderer~InfoRender} render - Information about rendered objects.
 * @property {?Array<WebGLProgram>} programs - An array `WebGLProgram`s used for rendering.
 * @property {Function} reset - Resets the info object for the next frame.
 **/

/**
 * WebGLRenderer Shadow Map.
 *
 * @typedef {Object} WebGLRenderer~ShadowMap
 * @property {boolean} [enabled=false] - If set to `true`, use shadow maps in the scene.
 * @property {boolean} [autoUpdate=true] - Enables automatic updates to the shadows in the scene.
 * If you do not require dynamic lighting / shadows, you may set this to `false`.
 * @property {boolean} [needsUpdate=false] - When set to `true`, shadow maps in the scene
 * will be updated in the next `render` call.
 * @property {(BasicShadowMap|PCFShadowMap|PCFSoftShadowMap|VSMShadowMap)} [type=PCFShadowMap] - Defines the shadow map type.
 **/