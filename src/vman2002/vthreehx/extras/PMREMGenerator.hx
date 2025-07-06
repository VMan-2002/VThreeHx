package vman2002.vthreehx.extras;

import vman2002.vthreehx.Constants.CubeReflectionMapping;
import vman2002.vthreehx.Constants.CubeRefractionMapping;
import vman2002.vthreehx.Constants.CubeUVReflectionMapping;
import vman2002.vthreehx.Constants.LinearFilter;
import vman2002.vthreehx.Constants.NoToneMapping;
import vman2002.vthreehx.Constants.NoBlending;
import vman2002.vthreehx.Constants.RGBAFormat;
import vman2002.vthreehx.Constants.HalfFloatType;
import vman2002.vthreehx.Constants.BackSide;
import vman2002.vthreehx.Constants.LinearSRGBColorSpace;
import vman2002.vthreehx.core.BufferAttribute;
import vman2002.vthreehx.core.BufferGeometry;
import vman2002.vthreehx.objects.Mesh;
import vman2002.vthreehx.cameras.OrthographicCamera;
import vman2002.vthreehx.cameras.PerspectiveCamera;
import vman2002.vthreehx.materials.ShaderMaterial;
import vman2002.vthreehx.math.Vector3;
import vman2002.vthreehx.math.Color;
import vman2002.vthreehx.renderers.WebGLRenderTarget;
import vman2002.vthreehx.materials.MeshBasicMaterial;
import vman2002.vthreehx.geometries.BoxGeometry;

/**
 * This class generates a Prefiltered, Mipmapped Radiance Environment Map
 * (PMREM) from a cubeMap environment texture. This allows different levels of
 * blur to be quickly accessed based on material roughness. It is packed into a
 * special CubeUV format that allows us to perform custom interpolation so that
 * we can support nonlinear formats such as RGBE. Unlike a traditional mipmap
 * chain, it only goes down to the LOD_MIN level (above), and then creates extra
 * even more filtered 'mips' at the same LOD_MIN resolution, associated with
 * higher roughness levels. In this way we maintain resolution to smoothly
 * interpolate diffuse lighting while limiting sampling computation.
 *
 * Paper: Fast, Accurate Image-Based Lighting:
 * {@link https://drive.google.com/file/d/15y8r_UpKlU9SvV4ILb0C3qCPecS8pvLz/view}
*/
class PMREMGenerator {

	/**
	 * Constructs a new PMREM generator.
	 *
	 * @param {WebGLRenderer} renderer - The renderer.
	 */
	public function new( renderer ) {

		this._renderer = renderer;
		this._pingPongRenderTarget = null;

		this._lodMax = 0;
		this._cubeSize = 0;
		this._lodPlanes = [];
		this._sizeLods = [];
		this._sigmas = [];

		this._blurMaterial = null;
		this._cubemapMaterial = null;
		this._equirectMaterial = null;

		this._compileMaterial( this._blurMaterial );

	}

	/**
	 * Generates a PMREM from a supplied Scene, which can be faster than using an
	 * image if networking bandwidth is low. Optional sigma specifies a blur radius
	 * in radians to be applied to the scene before PMREM generation. Optional near
	 * and far planes ensure the scene is rendered in its entirety.
	 *
	 * @param {Scene} scene - The scene to be captured.
	 * @param {number} [sigma=0] - The blur radius in radians.
	 * @param {number} [near=0.1] - The near plane distance.
	 * @param {number} [far=100] - The far plane distance.
	 * @param {Object} [options={}] - The configuration options.
	 * @param {number} [options.size=256] - The texture size of the PMREM.
	 * @param {Vector3} [options.renderTarget=origin] - The position of the internal cube camera that renders the scene.
	 * @return {WebGLRenderTarget} The resulting PMREM.
	 */
	public function fromScene( scene, sigma = 0, near = 0.1, far = 100, options = {} ) {

        if (Reflect.hasField(options, "size"))
		    options.size = 256;
        if (Reflect.hasField(options, "position"))
            options.position = _origin;

		_oldTarget = this._renderer.getRenderTarget();
		_oldActiveCubeFace = this._renderer.getActiveCubeFace();
		_oldActiveMipmapLevel = this._renderer.getActiveMipmapLevel();
		_oldXrEnabled = this._renderer.xr.enabled;

		this._renderer.xr.enabled = false;

		this._setSize( size );

		var cubeUVRenderTarget = this._allocateTargets();
		cubeUVRenderTarget.depthBuffer = true;

		this._sceneToCubeUV( scene, near, far, cubeUVRenderTarget, position );

		if ( sigma > 0 ) {

			this._blur( cubeUVRenderTarget, 0, 0, sigma );

		}

		this._applyPMREM( cubeUVRenderTarget );
		this._cleanup( cubeUVRenderTarget );

		return cubeUVRenderTarget;

	}

	/**
	 * Generates a PMREM from an equirectangular texture, which can be either LDR
	 * or HDR. The ideal input image size is 1k (1024 x 512),
	 * as this matches best with the 256 x 256 cubemap output.
	 *
	 * @param {Texture} equirectangular - The equirectangular texture to be converted.
	 * @param {?WebGLRenderTarget} [renderTarget=null] - The render target to use.
	 * @return {WebGLRenderTarget} The resulting PMREM.
	 */
	public function fromEquirectangular( equirectangular, renderTarget = null ) {

		return this._fromTexture( equirectangular, renderTarget );

	}

	/**
	 * Generates a PMREM from an cubemap texture, which can be either LDR
	 * or HDR. The ideal input cube size is 256 x 256,
	 * as this matches best with the 256 x 256 cubemap output.
	 *
	 * @param {Texture} cubemap - The cubemap texture to be converted.
	 * @param {?WebGLRenderTarget} [renderTarget=null] - The render target to use.
	 * @return {WebGLRenderTarget} The resulting PMREM.
	 */
	public function fromCubemap( cubemap, renderTarget = null ) {

		return this._fromTexture( cubemap, renderTarget );

	}

	/**
	 * Pre-compiles the cubemap shader. You can get faster start-up by invoking this method during
	 * your texture's network fetch for increased concurrency.
	 */
	public function compileCubemapShader() {

		if ( this._cubemapMaterial == null ) {

			this._cubemapMaterial = _getCubemapMaterial();
			this._compileMaterial( this._cubemapMaterial );

		}

	}

	/**
	 * Pre-compiles the equirectangular shader. You can get faster start-up by invoking this method during
	 * your texture's network fetch for increased concurrency.
	 */
	public function compileEquirectangularShader() {

		if ( this._equirectMaterial == null ) {

			this._equirectMaterial = _getEquirectMaterial();
			this._compileMaterial( this._equirectMaterial );

		}

	}

	/**
	 * Disposes of the PMREMGenerator's internal memory. Note that PMREMGenerator is a static class,
	 * so you should not need more than one PMREMGenerator object. If you do, calling dispose() on
	 * one of them will cause any others to also become unusable.
	 */
	public function dispose() {

		this._dispose();

		if ( this._cubemapMaterial != null ) this._cubemapMaterial.dispose();
		if ( this._equirectMaterial != null ) this._equirectMaterial.dispose();

	}

	// private interface

	public function _setSize( cubeSize ) {

		this._lodMax = Math.floor( Math.log2( cubeSize ) );
		this._cubeSize = Math.pow( 2, this._lodMax );

	}

	public function _dispose() {

		if ( this._blurMaterial != null ) this._blurMaterial.dispose();

		if ( this._pingPongRenderTarget != null ) this._pingPongRenderTarget.dispose();

		for ( i in 0...this._lodPlanes.length ) {

			this._lodPlanes[ i ].dispose();

		}

	}

	public function _cleanup( outputTarget ) {

		this._renderer.setRenderTarget( _oldTarget, _oldActiveCubeFace, _oldActiveMipmapLevel );
		this._renderer.xr.enabled = _oldXrEnabled;

		outputTarget.scissorTest = false;
		_setViewport( outputTarget, 0, 0, outputTarget.width, outputTarget.height );

	}

	public function _fromTexture( texture, renderTarget ) {

		if ( texture.mapping == CubeReflectionMapping || texture.mapping == CubeRefractionMapping ) {

			this._setSize( texture.image.length == 0 ? 16 : ( texture.image[ 0 ].width || texture.image[ 0 ].image.width ) );

		} else { // Equirectangular

			this._setSize( texture.image.width / 4 );

		}

		_oldTarget = this._renderer.getRenderTarget();
		_oldActiveCubeFace = this._renderer.getActiveCubeFace();
		_oldActiveMipmapLevel = this._renderer.getActiveMipmapLevel();
		_oldXrEnabled = this._renderer.xr.enabled;

		this._renderer.xr.enabled = false;

		var cubeUVRenderTarget = renderTarget || this._allocateTargets();
		this._textureToCubeUV( texture, cubeUVRenderTarget );
		this._applyPMREM( cubeUVRenderTarget );
		this._cleanup( cubeUVRenderTarget );

		return cubeUVRenderTarget;

	}

	public function _allocateTargets() {

		var width = 3 * Math.max( this._cubeSize, 16 * 7 );
		var height = 4 * this._cubeSize;

		var params = {
			magFilter: LinearFilter,
			minFilter: LinearFilter,
			generateMipmaps: false,
			type: HalfFloatType,
			format: RGBAFormat,
			colorSpace: LinearSRGBColorSpace,
			depthBuffer: false
		};

		var cubeUVRenderTarget = _createRenderTarget( width, height, params );

		if ( this._pingPongRenderTarget == null || this._pingPongRenderTarget.width != width || this._pingPongRenderTarget.height != height ) {

			if ( this._pingPongRenderTarget != null ) {

				this._dispose();

			}

			this._pingPongRenderTarget = _createRenderTarget( width, height, params );

			var _lodMax = this._lodMax;
			( { sizeLods: this._sizeLods, lodPlanes: this._lodPlanes, sigmas: this._sigmas } = _createPlanes( _lodMax ) );

			this._blurMaterial = _getBlurShader( _lodMax, width, height );

		}

		return cubeUVRenderTarget;

	}

	public function _compileMaterial( material ) {

		var tmpMesh = new Mesh( this._lodPlanes[ 0 ], material );
		this._renderer.compile( tmpMesh, _flatCamera );

	}

	public function _sceneToCubeUV( scene, near, far, cubeUVRenderTarget, position ) {

		var fov = 90;
		var aspect = 1;
		var cubeCamera = new PerspectiveCamera( fov, aspect, near, far );
		var upSign = [ 1, - 1, 1, 1, 1, 1 ];
		var forwardSign = [ 1, 1, 1, - 1, - 1, - 1 ];
		var renderer = this._renderer;

		var originalAutoClear = renderer.autoClear;
		var toneMapping = renderer.toneMapping;
		renderer.getClearColor( _clearColor );

		renderer.toneMapping = NoToneMapping;
		renderer.autoClear = false;

		var backgroundMaterial = new MeshBasicMaterial( {
			name: 'PMREM.Background',
			side: BackSide,
			depthWrite: false,
			depthTest: false,
		} );

		var backgroundBox = new Mesh( new BoxGeometry(), backgroundMaterial );

		var useSolidColor = false;
		var background = scene.background;

		if ( background ) {

			if ( background.isColor ) {

				backgroundMaterial.color.copy( background );
				scene.background = null;
				useSolidColor = true;

			}

		} else {

			backgroundMaterial.color.copy( _clearColor );
			useSolidColor = true;

		}

		for ( i in 0...6 ) {

			var col = i % 3;

			if ( col == 0 ) {

				cubeCamera.up.set( 0, upSign[ i ], 0 );
				cubeCamera.position.set( position.x, position.y, position.z );
				cubeCamera.lookAt( position.x + forwardSign[ i ], position.y, position.z );

			} else if ( col == 1 ) {

				cubeCamera.up.set( 0, 0, upSign[ i ] );
				cubeCamera.position.set( position.x, position.y, position.z );
				cubeCamera.lookAt( position.x, position.y + forwardSign[ i ], position.z );


			} else {

				cubeCamera.up.set( 0, upSign[ i ], 0 );
				cubeCamera.position.set( position.x, position.y, position.z );
				cubeCamera.lookAt( position.x, position.y, position.z + forwardSign[ i ] );

			}

			var size = this._cubeSize;

			_setViewport( cubeUVRenderTarget, col * size, i > 2 ? size : 0, size, size );

			renderer.setRenderTarget( cubeUVRenderTarget );

			if ( useSolidColor ) {

				renderer.render( backgroundBox, cubeCamera );

			}

			renderer.render( scene, cubeCamera );

		}

		backgroundBox.geometry.dispose();
		backgroundBox.material.dispose();

		renderer.toneMapping = toneMapping;
		renderer.autoClear = originalAutoClear;
		scene.background = background;

	}

	public function _textureToCubeUV( texture, cubeUVRenderTarget ) {

		var renderer = this._renderer;

		var isCubeTexture = ( texture.mapping == CubeReflectionMapping || texture.mapping == CubeRefractionMapping );

		if ( isCubeTexture ) {

			if ( this._cubemapMaterial == null ) {

				this._cubemapMaterial = _getCubemapMaterial();

			}

			this._cubemapMaterial.uniforms.flipEnvMap.value = ( texture.isRenderTargetTexture == false ) ? - 1 : 1;

		} else {

			if ( this._equirectMaterial == null ) {

				this._equirectMaterial = _getEquirectMaterial();

			}

		}

		var material = isCubeTexture ? this._cubemapMaterial : this._equirectMaterial;
		var mesh = new Mesh( this._lodPlanes[ 0 ], material );

		var uniforms = material.uniforms;

		uniforms[ 'envMap' ].value = texture;

		var size = this._cubeSize;

		_setViewport( cubeUVRenderTarget, 0, 0, 3 * size, 2 * size );

		renderer.setRenderTarget( cubeUVRenderTarget );
		renderer.render( mesh, _flatCamera );

	}

	public function _applyPMREM( cubeUVRenderTarget ) {

		var renderer = this._renderer;
		var autoClear = renderer.autoClear;
		renderer.autoClear = false;
		var n = this._lodPlanes.length;

		for ( i in 1...n ) {

			var sigma = Math.sqrt( this._sigmas[ i ] * this._sigmas[ i ] - this._sigmas[ i - 1 ] * this._sigmas[ i - 1 ] );

			var poleAxis = _axisDirections[ ( n - i - 1 ) % _axisDirections.length ];

			this._blur( cubeUVRenderTarget, i - 1, i, sigma, poleAxis );

		}

		renderer.autoClear = autoClear;

	}

	/**
	 * This is a two-pass Gaussian blur for a cubemap. Normally this is done
	 * vertically and horizontally, but this breaks down on a cube. Here we apply
	 * the blur latitudinally (around the poles), and then longitudinally (towards
	 * the poles) to approximate the orthogonally-separable blur. It is least
	 * accurate at the poles, but still does a decent job.
	 *
	 * @private
	 * @param {WebGLRenderTarget} cubeUVRenderTarget
	 * @param {number} lodIn
	 * @param {number} lodOut
	 * @param {number} sigma
	 * @param {Vector3} [poleAxis]
	 */
	public function _blur( cubeUVRenderTarget, lodIn, lodOut, sigma, poleAxis ) {

		var pingPongRenderTarget = this._pingPongRenderTarget;

		this._halfBlur(
			cubeUVRenderTarget,
			pingPongRenderTarget,
			lodIn,
			lodOut,
			sigma,
			'latitudinal',
			poleAxis );

		this._halfBlur(
			pingPongRenderTarget,
			cubeUVRenderTarget,
			lodOut,
			lodOut,
			sigma,
			'longitudinal',
			poleAxis );

	}

	public function _halfBlur( targetIn, targetOut, lodIn, lodOut, sigmaRadians, direction, poleAxis ) {

		var renderer = this._renderer;
		var blurMaterial = this._blurMaterial;

		if ( direction != 'latitudinal' && direction != 'longitudinal' ) {

			console.error(
				'blur direction must be either latitudinal or longitudinal!' );

		}

		// Number of standard deviations at which to cut off the discrete approximation.
		var STANDARD_DEVIATIONS = 3;

		var blurMesh = new Mesh( this._lodPlanes[ lodOut ], blurMaterial );
		var blurUniforms = blurMaterial.uniforms;

		var pixels = this._sizeLods[ lodIn ] - 1;
		var radiansPerPixel = isFinite( sigmaRadians ) ? Math.PI / ( 2 * pixels ) : 2 * Math.PI / ( 2 * MAX_SAMPLES - 1 );
		var sigmaPixels = sigmaRadians / radiansPerPixel;
		var samples = isFinite( sigmaRadians ) ? 1 + Math.floor( STANDARD_DEVIATIONS * sigmaPixels ) : MAX_SAMPLES;

		if ( samples > MAX_SAMPLES ) {

			Common.warn( 'sigmaRadians, ${
				sigmaRadians}, is too large and will clip, as it requested ${
				samples} samples when the maximum is set to ${MAX_SAMPLES}' );

		}

		var weights = [];
		var sum = 0;

		for ( i in 0...MAX_SAMPLES ) {

			var x = i / sigmaPixels;
			var weight = Math.exp( - x * x / 2 );
			weights.push( weight );

			if ( i == 0 ) {

				sum += weight;

			} else if ( i < samples ) {

				sum += 2 * weight;

			}

		}

		for ( i in 0...weights.length ) {

			weights[ i ] = weights[ i ] / sum;

		}

		blurUniforms[ 'envMap' ].value = targetIn.texture;
		blurUniforms[ 'samples' ].value = samples;
		blurUniforms[ 'weights' ].value = weights;
		blurUniforms[ 'latitudinal' ].value = direction == 'latitudinal';

		if ( poleAxis ) {

			blurUniforms[ 'poleAxis' ].value = poleAxis;

		}

		var _lodMax = this._lodMax;
		blurUniforms[ 'dTheta' ].value = radiansPerPixel;
		blurUniforms[ 'mipInt' ].value = _lodMax - lodIn;

		var outputSize = this._sizeLods[ lodOut ];
		var x = 3 * outputSize * ( lodOut > _lodMax - LOD_MIN ? lodOut - _lodMax + LOD_MIN : 0 );
		var y = 4 * ( this._cubeSize - outputSize );

		_setViewport( targetOut, x, y, 3 * outputSize, 2 * outputSize );
		renderer.setRenderTarget( targetOut );
		renderer.render( blurMesh, _flatCamera );

	}

    

    static var LOD_MIN = 4;

    // The standard deviations (radians) associated with the extra mips. These are
    // chosen to approximate a Trowbridge-Reitz distribution function times the
    // geometric shadowing function. These sigma values squared must match the
    // variance #defines in cube_uv_reflection_fragment.glsl.js.
    static var EXTRA_LOD_SIGMA = [ 0.125, 0.215, 0.35, 0.446, 0.526, 0.582 ];

    // The maximum length of the blur for loop. Smaller sigmas will use fewer
    // samples and exit early, but not recompile the shader.
    static var MAX_SAMPLES = 20;

    static var _flatCamera = /*@__PURE__*/ new OrthographicCamera();
    static var _clearColor = /*@__PURE__*/ new Color();
    static var _oldTarget = null;
    static var _oldActiveCubeFace = 0;
    static var _oldActiveMipmapLevel = 0;
    static var _oldXrEnabled = false;

    // Golden Ratio
    static var PHI = ( 1 + Math.sqrt( 5 ) ) / 2;
    static var INV_PHI = 1 / PHI;

    // Vertices of a dodecahedron (except the opposites, which represent the
    // same axis), used as axis directions evenly spread on a sphere.
    static var _axisDirections = [
        /*@__PURE__*/ new Vector3( - PHI, INV_PHI, 0 ),
        /*@__PURE__*/ new Vector3( PHI, INV_PHI, 0 ),
        /*@__PURE__*/ new Vector3( - INV_PHI, 0, PHI ),
        /*@__PURE__*/ new Vector3( INV_PHI, 0, PHI ),
        /*@__PURE__*/ new Vector3( 0, PHI, - INV_PHI ),
        /*@__PURE__*/ new Vector3( 0, PHI, INV_PHI ),
        /*@__PURE__*/ new Vector3( - 1, 1, - 1 ),
        /*@__PURE__*/ new Vector3( 1, 1, - 1 ),
        /*@__PURE__*/ new Vector3( - 1, 1, 1 ),
        /*@__PURE__*/ new Vector3( 1, 1, 1 ) ];

    static var _origin = /*@__PURE__*/ new Vector3();
}



function _createPlanes( lodMax ) {

	var lodPlanes = [];
	var sizeLods = [];
	var sigmas = [];

	var lod = lodMax;

	var totalLods = lodMax - LOD_MIN + 1 + EXTRA_LOD_SIGMA.length;

	for ( i in 0...totalLods ) {

		var sizeLod = Math.pow( 2, lod );
		sizeLods.push( sizeLod );
		var sigma = 1.0 / sizeLod;

		if ( i > lodMax - LOD_MIN ) {

			sigma = EXTRA_LOD_SIGMA[ i - lodMax + LOD_MIN - 1 ];

		} else if ( i == 0 ) {

			sigma = 0;

		}

		sigmas.push( sigma );

		var texelSize = 1.0 / ( sizeLod - 2 );
		var min = - texelSize;
		var max = 1 + texelSize;
		var uv1 = [ min, min, max, min, max, max, min, min, max, max, min, max ];

		var cubeFaces = 6;
		var vertices = 6;
		var positionSize = 3;
		var uvSize = 2;
		var faceIndexSize = 1;

		var position = new Float32Array( positionSize * vertices * cubeFaces );
		var uv = new Float32Array( uvSize * vertices * cubeFaces );
		var faceIndex = new Float32Array( faceIndexSize * vertices * cubeFaces );

		for ( face in 0...cubeFaces ) {

			var x = ( face % 3 ) * 2 / 3 - 1;
			var y = face > 2 ? 0 : - 1;
			var coordinates = [
				x, y, 0,
				x + 2 / 3, y, 0,
				x + 2 / 3, y + 1, 0,
				x, y, 0,
				x + 2 / 3, y + 1, 0,
				x, y + 1, 0
			];
			position.set( coordinates, positionSize * vertices * face );
			uv.set( uv1, uvSize * vertices * face );
			var fill = [ face, face, face, face, face, face ];
			faceIndex.set( fill, faceIndexSize * vertices * face );

		}

		var planes = new BufferGeometry();
		planes.setAttribute( 'position', new BufferAttribute( position, positionSize ) );
		planes.setAttribute( 'uv', new BufferAttribute( uv, uvSize ) );
		planes.setAttribute( 'faceIndex', new BufferAttribute( faceIndex, faceIndexSize ) );
		lodPlanes.push( planes );

		if ( lod > LOD_MIN ) {

			lod --;

		}

	}

	return { lodPlanes: lodPlanes, sizeLods: sizeLods, sigmas: sigmas };

}

function _createRenderTarget( width, height, params ) {

	var cubeUVRenderTarget = new WebGLRenderTarget( width, height, params );
	cubeUVRenderTarget.texture.mapping = CubeUVReflectionMapping;
	cubeUVRenderTarget.texture.name = 'PMREM.cubeUv';
	cubeUVRenderTarget.scissorTest = true;
	return cubeUVRenderTarget;

}

function _setViewport( target, x, y, width, height ) {

	target.viewport.set( x, y, width, height );
	target.scissor.set( x, y, width, height );

}

function _getBlurShader( lodMax, width, height ) {

	var weights = new Float32Array( MAX_SAMPLES );
	var poleAxis = new Vector3( 0, 1, 0 );
	var shaderMaterial = new ShaderMaterial( {

		name: 'SphericalGaussianBlur',

		defines: {
			'n': MAX_SAMPLES,
			'CUBEUV_TEXEL_WIDTH': 1.0 / width,
			'CUBEUV_TEXEL_HEIGHT': 1.0 / height,
			'CUBEUV_MAX_MIP': '${lodMax}.0',
		},

		uniforms: {
			'envMap': { value: null },
			'samples': { value: 1 },
			'weights': { value: weights },
			'latitudinal': { value: false },
			'dTheta': { value: 0 },
			'mipInt': { value: 0 },
			'poleAxis': { value: poleAxis }
		},

		vertexShader: _getCommonVertexShader(),

		fragmentShader: /* glsl */"

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform int samples;
			uniform float weights[ n ];
			uniform bool latitudinal;
			uniform float dTheta;
			uniform float mipInt;
			uniform vec3 poleAxis;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			vec3 getSample( float theta, vec3 axis ) {

				float cosTheta = cos( theta );
				// Rodrigues' axis-angle rotation
				vec3 sampleDirection = vOutputDirection * cosTheta
					+ cross( axis, vOutputDirection ) * sin( theta )
					+ axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

				return bilinearCubeUV( envMap, sampleDirection, mipInt );

			}

			void main() {

				vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

				if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

					axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

				}

				axis = normalize( axis );

				gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
				gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

				for ( int i = 1; i < n; i++ ) {

					if ( i >= samples ) {

						break;

					}

					float theta = dTheta * float( i );
					gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
					gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

				}

			}
		",

		blending: NoBlending,
		depthTest: false,
		depthWrite: false

	} );

	return shaderMaterial;

}

function _getEquirectMaterial() {

	return new ShaderMaterial( {

		name: 'EquirectangularToCubeUV',

		uniforms: {
			'envMap': { value: null }
		},

		vertexShader: _getCommonVertexShader(),

		fragmentShader: /* glsl */"

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		",

		blending: NoBlending,
		depthTest: false,
		depthWrite: false

	} );

}

function _getCubemapMaterial() {

	return new ShaderMaterial( {

		name: 'CubemapToCubeUV',

		uniforms: {
			'envMap': { value: null },
			'flipEnvMap': { value: - 1 }
		},

		vertexShader: _getCommonVertexShader(),

		fragmentShader: /* glsl */"

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		",

		blending: NoBlending,
		depthTest: false,
		depthWrite: false

	} );

}

function _getCommonVertexShader() {

	return /* glsl */"

		precision mediump float;
		precision mediump int;

		attribute float faceIndex;

		varying vec3 vOutputDirection;

		// RH coordinate system; PMREM face-indexing convention
		vec3 getDirection( vec2 uv, float face ) {

			uv = 2.0 * uv - 1.0;

			vec3 direction = vec3( uv, 1.0 );

			if ( face == 0.0 ) {

				direction = direction.zyx; // ( 1, v, u ) pos x

			} else if ( face == 1.0 ) {

				direction = direction.xzy;
				direction.xz *= -1.0; // ( -u, 1, -v ) pos y

			} else if ( face == 2.0 ) {

				direction.x *= -1.0; // ( -u, v, 1 ) pos z

			} else if ( face == 3.0 ) {

				direction = direction.zyx;
				direction.xz *= -1.0; // ( -1, v, -u ) neg x

			} else if ( face == 4.0 ) {

				direction = direction.xzy;
				direction.xy *= -1.0; // ( -u, -1, v ) neg y

			} else if ( face == 5.0 ) {

				direction.z *= -1.0; // ( u, v, -1 ) neg z

			}

			return direction;

		}

		void main() {

			vOutputDirection = getDirection( uv, faceIndex );
			gl_Position = vec4( position, 1.0 );

		}
	";

}