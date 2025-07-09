package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.Constants;

class WebGLCapabilities {
    var gl:GL;
    var extensions:vman2002.vthreehx.renderers.webgl.WebGLExtensions;
    var parameters:Dynamic;
    var utils:WebGLUtils;

    public function new(gl, extensions, parameters, utils) {
        this.gl = gl;
        this.extensions = extensions;
        this.parameters = parameters;
        this.utils = utils;

        if ( maxPrecision != precision ) {

            console.warn( 'THREE.WebGLRenderer:', precision, 'not supported, using', maxPrecision, 'instead.' );
            precision = maxPrecision;

        }
    }

	var maxAnisotropy;

	function getMaxAnisotropy() {

		if ( maxAnisotropy != null ) return maxAnisotropy;

		if ( extensions.has( 'EXT_texture_filter_anisotropic' ) == true ) {

			var extension = extensions.get( 'EXT_texture_filter_anisotropic' );

			maxAnisotropy = gl.getParameter( extension.MAX_TEXTURE_MAX_ANISOTROPY_EXT );

		} else {

			maxAnisotropy = 0;

		}

		return maxAnisotropy;

	}

	function textureFormatReadable( textureFormat ) {

		if ( textureFormat != Constants.RGBAFormat && utils.convert( textureFormat ) != gl.getParameter( gl.IMPLEMENTATION_COLOR_READ_FORMAT ) ) {

			return false;

		}

		return true;

	}

	function textureTypeReadable( textureType ) {

		var halfFloatSupportedByExt = ( textureType == HalfFloatType ) && ( extensions.has( 'EXT_color_buffer_half_float' ) || extensions.has( 'EXT_color_buffer_float' ) );

		if ( textureType != Constants.UnsignedByteType && utils.convert( textureType ) != gl.getParameter( gl.IMPLEMENTATION_COLOR_READ_TYPE ) && // Edge and Chrome Mac < 52 (#9513)
			textureType != Constants.FloatType && ! halfFloatSupportedByExt ) {

			return false;

		}

		return true;

	}

	function getMaxPrecision( precision ) {

		if ( precision == 'highp' ) {

			if ( gl.getShaderPrecisionFormat( gl.VERTEX_SHADER, gl.HIGH_FLOAT ).precision > 0 &&
				gl.getShaderPrecisionFormat( gl.FRAGMENT_SHADER, gl.HIGH_FLOAT ).precision > 0 ) {

				return 'highp';

			}

			precision = 'mediump';

		}

		if ( precision == 'mediump' ) {

			if ( gl.getShaderPrecisionFormat( gl.VERTEX_SHADER, gl.MEDIUM_FLOAT ).precision > 0 &&
				gl.getShaderPrecisionFormat( gl.FRAGMENT_SHADER, gl.MEDIUM_FLOAT ).precision > 0 ) {

				return 'mediump';

			}

		}

		return 'lowp';

	}

	public var precision = parameters.precision != null ? parameters.precision : 'highp';
	var maxPrecision = getMaxPrecision( precision );

	public var logarithmicDepthBuffer = parameters.logarithmicDepthBuffer == true;
	public var reverseDepthBuffer = parameters.reverseDepthBuffer == true && extensions.has( 'EXT_clip_control' );

	public var maxTextures = gl.getParameter( gl.MAX_TEXTURE_IMAGE_UNITS );
	public var maxVertexTextures = gl.getParameter( gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS );
	public var maxTextureSize = gl.getParameter( gl.MAX_TEXTURE_SIZE );
	public var maxCubemapSize = gl.getParameter( gl.MAX_CUBE_MAP_TEXTURE_SIZE );

	public var maxAttributes = gl.getParameter( gl.MAX_VERTEX_ATTRIBS );
	public var maxVertexUniforms = gl.getParameter( gl.MAX_VERTEX_UNIFORM_VECTORS );
	public var maxVaryings = gl.getParameter( gl.MAX_VARYING_VECTORS );
	public var maxFragmentUniforms = gl.getParameter( gl.MAX_FRAGMENT_UNIFORM_VECTORS );

	public var vertexTextures = maxVertexTextures > 0;

	public var maxSamples = gl.getParameter( gl.MAX_SAMPLES );

    public var isWebGL2 = true; // keeping this for backwards compatibility

}