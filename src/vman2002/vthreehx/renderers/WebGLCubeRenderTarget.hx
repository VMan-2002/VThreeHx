package vman2002.vthreehx.renderers;

import vman2002.vthreehx.Constants.BackSide;
import vman2002.vthreehx.Constants.LinearFilter;
import vman2002.vthreehx.Constants.LinearMipmapLinearFilter;
import vman2002.vthreehx.Constants.NoBlending;
import vman2002.vthreehx.objects.Mesh;
import vman2002.vthreehx.geometries.BoxGeometry;
import vman2002.vthreehx.materials.ShaderMaterial;
import vman2002.vthreehx.renderers.shaders.UniformsUtils;
import vman2002.vthreehx.renderers.WebGLRenderTarget;
import vman2002.vthreehx.cameras.CubeCamera;
import vman2002.vthreehx.textures.CubeTexture;

/**
 * A cube render target used in context of {@link WebGLRenderer}.
 *
 * @augments WebGLRenderTarget
 */
class WebGLCubeRenderTarget extends WebGLRenderTarget {

	/**
	 * Constructs a new cube render target.
	 *
	 * @param {number} [size=1] - The size of the render target.
	 * @param {RenderTarget~Options} [options] - The configuration object.
	 */
	public function new( size = 1, options:Dynamic = {} ) {

		super( size, size, options );

		/**
		 * This flag can be used for type testing.
		 *
		 * @type {boolean}
		 * @readonly
		 * @default true
		 */
		this.isWebGLCubeRenderTarget = true;

		var image = { width: size, height: size, depth: 1 };
		var images = [ image, image, image, image, image, image ];

		/**
		 * Overwritten with a different texture type.
		 *
		 * @type {DataArrayTexture}
		 */
		this.texture = new CubeTexture( images, options.mapping, options.wrapS, options.wrapT, options.magFilter, options.minFilter, options.format, options.type, options.anisotropy, options.colorSpace );

		// By convention -- likely based on the RenderMan spec from the 1990's -- cube maps are specified by WebGL (and three.js)
		// in a coordinate system in which positive-x is to the right when looking up the positive-z axis -- in other words,
		// in a left-handed coordinate system. By continuing this convention, preexisting cube maps continued to render correctly.

		// three.js uses a right-handed coordinate system. So environment maps used in three.js appear to have px and nx swapped
		// and the flag isRenderTargetTexture controls this conversion. The flip is not required when using WebGLCubeRenderTarget.texture
		// as a cube texture (this is detected when isRenderTargetTexture is set to true for cube textures).

		this.texture.isRenderTargetTexture = true;

		this.texture.generateMipmaps = options.generateMipmaps != undefined ? options.generateMipmaps : false;
		this.texture.minFilter = options.minFilter != undefined ? options.minFilter : LinearFilter;

	}

	/**
	 * Converts the given equirectangular texture to a cube map.
	 *
	 * @param {WebGLRenderer} renderer - The renderer.
	 * @param {Texture} texture - The equirectangular texture.
	 * @return {WebGLCubeRenderTarget} A reference to this cube render target.
	 */
	public function fromEquirectangularTexture( renderer, texture ) {

		this.texture.type = texture.type;
		this.texture.colorSpace = texture.colorSpace;

		this.texture.generateMipmaps = texture.generateMipmaps;
		this.texture.minFilter = texture.minFilter;
		this.texture.magFilter = texture.magFilter;

		var shader = {

			uniforms: {
				tEquirect: { value: null },
			},

			vertexShader: glsl("

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			"),

			fragmentShader: glsl("

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			")
		};

		var geometry = new BoxGeometry( 5, 5, 5 );

		var material = new ShaderMaterial( {

			name: 'CubemapFromEquirect',

			uniforms: cloneUniforms( shader.uniforms ),
			vertexShader: shader.vertexShader,
			fragmentShader: shader.fragmentShader,
			side: BackSide,
			blending: NoBlending

		} );

		material.uniforms.tEquirect.value = texture;

		var mesh = new Mesh( geometry, material );

		var currentMinFilter = texture.minFilter;

		// Avoid blurred poles
		if ( texture.minFilter == LinearMipmapLinearFilter ) texture.minFilter = LinearFilter;

		var camera = new CubeCamera( 1, 10, this );
		camera.update( renderer, mesh );

		texture.minFilter = currentMinFilter;

		mesh.geometry.dispose();
		mesh.material.dispose();

		return this;

	}

	/**
	 * Clears this cube render target.
	 *
	 * @param {WebGLRenderer} renderer - The renderer.
	 * @param {boolean} [color=true] - Whether the color buffer should be cleared or not.
	 * @param {boolean} [depth=true] - Whether the depth buffer should be cleared or not.
	 * @param {boolean} [stencil=true] - Whether the stencil buffer should be cleared or not.
	 */
	public function clear( renderer, color = true, depth = true, stencil = true ) {

		var currentRenderTarget = renderer.getRenderTarget();

		for ( i in 0...6 ) {

			renderer.setRenderTarget( this, i );

			renderer.clear( color, depth, stencil );

		}

		renderer.setRenderTarget( currentRenderTarget );

	}

}