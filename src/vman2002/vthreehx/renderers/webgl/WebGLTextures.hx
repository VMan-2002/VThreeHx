package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.math.Vector2;
import vman2002.vthreehx.Utils;
import vman2002.vthreehx.math.ColorManagement;
import vman2002.vthreehx.Constants.LinearFilter;
import vman2002.vthreehx.Constants.LinearMipmapLinearFilter;
import vman2002.vthreehx.Constants.LinearMipmapNearestFilter;
import vman2002.vthreehx.Constants.NearestFilter;
import vman2002.vthreehx.Constants.NearestMipmapLinearFilter;
import vman2002.vthreehx.Constants.NearestMipmapNearestFilter;
import vman2002.vthreehx.Constants.RGBAFormat;
import vman2002.vthreehx.Constants.DepthFormat;
import vman2002.vthreehx.Constants.DepthStencilFormat;
import vman2002.vthreehx.Constants.UnsignedIntType;
import vman2002.vthreehx.Constants.FloatType;
import vman2002.vthreehx.Constants.MirroredRepeatWrapping;
import vman2002.vthreehx.Constants.ClampToEdgeWrapping;
import vman2002.vthreehx.Constants.RepeatWrapping;
import vman2002.vthreehx.Constants.UnsignedByteType;
import vman2002.vthreehx.Constants.NoColorSpace;
import vman2002.vthreehx.Constants.LinearSRGBColorSpace;
import vman2002.vthreehx.Constants.NeverCompare;
import vman2002.vthreehx.Constants.AlwaysCompare;
import vman2002.vthreehx.Constants.LessCompare;
import vman2002.vthreehx.Constants.LessEqualCompare;
import vman2002.vthreehx.Constants.EqualCompare;
import vman2002.vthreehx.Constants.GreaterEqualCompare;
import vman2002.vthreehx.Constants.GreaterCompare;
import vman2002.vthreehx.Constants.NotEqualCompare;
import vman2002.vthreehx.Constants.SRGBTransfer;
import vman2002.vthreehx.Constants.LinearTransfer;
import vman2002.vthreehx.Constants.UnsignedShortType;
import vman2002.vthreehx.Constants.UnsignedInt248Type;
//import { createElementNS } from '../../utils.js';
import vman2002.vthreehx.extras.TextureUtils.getByteLength;

class WebGLTextures {

	public var _gl:GL;
	public var extensions:WebGLExtensions;
	public var state:WebGLState;
	public var properties:WebGLProperties;
	public var capabilities:WebGLCapabilities;
	public var utils:WebGLUtils;
	public var info:WebGLInfo;

    public function new( _gl, extensions, state, properties, capabilities, utils, info ) {
		this._gl = _gl;
		this.extensions = extensions;
		this.state = state;
		this.properties = properties;
		this.capabilities = capabilities;
		this.utils = utils;
		this.info = info;
		/*try {

			useOffscreenCanvas = typeof OffscreenCanvas != 'undefined'
				// eslint-disable-next-line compat/compat
				&& ( new OffscreenCanvas( 1, 1 ).getContext( '2d' ) ) != null;

		} catch ( err ) {

			// Ignore any errors

		}*/
    }

	var multisampledRTTExt = extensions.has( 'WEBGL_multisampled_render_to_texture' ) ? extensions.get( 'WEBGL_multisampled_render_to_texture' ) : null;
	//var supportsInvalidateFramebuffer = typeof navigator == 'undefined' ? false : ~/OculusBrowser/g.test( navigator.userAgent );
	var supportsInvalidateFramebuffer = false;

	var _imageDimensions = new Vector2();
	var _videoTextures = new WeakMap();
	var _canvas;

	var _sources = new WeakMap(); // maps WebglTexture objects to instances of Source

	// cordova iOS (as of 5.0) still uses UIWebView, which provides OffscreenCanvas,
	// also OffscreenCanvas.getContext("webgl"), but not OffscreenCanvas.getContext("2d")!
	// Some implementations may only implement OffscreenCanvas partially (e.g. lacking 2d).

	var useOffscreenCanvas = true;

    //TODO: we need this
	function createCanvas( width, height ) {

		// Use OffscreenCanvas when available. Specially needed in web workers

		return useOffscreenCanvas ?
			// eslint-disable-next-line compat/compat
			new OffscreenCanvas( width, height ) : createElementNS( 'canvas' );

	}

	function resizeImage( image, needsNewCanvas, maxSize ) {

		var scale = 1;

		var dimensions = getDimensions( image );

		// handle case if texture exceeds max size

		if ( dimensions.width > maxSize || dimensions.height > maxSize ) {

			scale = maxSize / Math.max( dimensions.width, dimensions.height );

		}

		// only perform resize if necessary

		if ( scale < 1 ) {

			// only perform resize for certain image types

			if ( /*( typeof HTMLImageElement != 'undefined' && image instanceof HTMLImageElement ) ||
				( typeof HTMLCanvasElement != 'undefined' && image instanceof HTMLCanvasElement ) ||
				( typeof ImageBitmap != 'undefined' && image instanceof ImageBitmap ) ||
				( typeof VideoFrame != 'undefined' && image instanceof VideoFrame )*/ false /* TODO: what*/ ) {

				var width = Math.floor( scale * dimensions.width );
				var height = Math.floor( scale * dimensions.height );

				if ( _canvas == undefined ) _canvas = createCanvas( width, height );

				// cube textures can't reuse the same canvas

				var canvas = needsNewCanvas ? createCanvas( width, height ) : _canvas;

				canvas.width = width;
				canvas.height = height;

				var context = canvas.getContext( '2d' );
				context.drawImage( image, 0, 0, width, height );

				console.warn( 'THREE.WebGLRenderer: Texture has been resized from (' + dimensions.width + 'x' + dimensions.height + ') to (' + width + 'x' + height + ').' );

				return canvas;

			} else {

				if ( 'data' in image ) {

					console.warn( 'THREE.WebGLRenderer: Image in DataTexture is too big (' + dimensions.width + 'x' + dimensions.height + ').' );

				}

				return image;

			}

		}

		return image;

	}

	function textureNeedsGenerateMipmaps( texture ) {

		return texture.generateMipmaps;

	}

	function generateMipmap( target ) {

		_gl.generateMipmap( target );

	}

	function getTargetType( texture ) {

		if ( texture.isWebGLCubeRenderTarget ) return _gl.TEXTURE_CUBE_MAP;
		if ( texture.isWebGL3DRenderTarget ) return _gl.TEXTURE_3D;
		if ( texture.isWebGLArrayRenderTarget || texture.isCompressedArrayTexture ) return _gl.TEXTURE_2D_ARRAY;
		return _gl.TEXTURE_2D;

	}

	function getInternalFormat( internalFormatName, glFormat, glType, colorSpace, forceLinearTransfer = false ) {

		if ( internalFormatName != null ) {

			if ( _gl[ internalFormatName ] != undefined ) return _gl[ internalFormatName ];

			console.warn( 'THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format \'' + internalFormatName + '\'' );

		}

		var internalFormat = glFormat;

		if ( glFormat == _gl.RED ) {

			if ( glType == _gl.FLOAT ) internalFormat = _gl.R32F;
			if ( glType == _gl.HALF_FLOAT ) internalFormat = _gl.R16F;
			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.R8;

		}

		if ( glFormat == _gl.RED_INTEGER ) {

			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.R8UI;
			if ( glType == _gl.UNSIGNED_SHORT ) internalFormat = _gl.R16UI;
			if ( glType == _gl.UNSIGNED_INT ) internalFormat = _gl.R32UI;
			if ( glType == _gl.BYTE ) internalFormat = _gl.R8I;
			if ( glType == _gl.SHORT ) internalFormat = _gl.R16I;
			if ( glType == _gl.INT ) internalFormat = _gl.R32I;

		}

		if ( glFormat == _gl.RG ) {

			if ( glType == _gl.FLOAT ) internalFormat = _gl.RG32F;
			if ( glType == _gl.HALF_FLOAT ) internalFormat = _gl.RG16F;
			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.RG8;

		}

		if ( glFormat == _gl.RG_INTEGER ) {

			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.RG8UI;
			if ( glType == _gl.UNSIGNED_SHORT ) internalFormat = _gl.RG16UI;
			if ( glType == _gl.UNSIGNED_INT ) internalFormat = _gl.RG32UI;
			if ( glType == _gl.BYTE ) internalFormat = _gl.RG8I;
			if ( glType == _gl.SHORT ) internalFormat = _gl.RG16I;
			if ( glType == _gl.INT ) internalFormat = _gl.RG32I;

		}

		if ( glFormat == _gl.RGB_INTEGER ) {

			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.RGB8UI;
			if ( glType == _gl.UNSIGNED_SHORT ) internalFormat = _gl.RGB16UI;
			if ( glType == _gl.UNSIGNED_INT ) internalFormat = _gl.RGB32UI;
			if ( glType == _gl.BYTE ) internalFormat = _gl.RGB8I;
			if ( glType == _gl.SHORT ) internalFormat = _gl.RGB16I;
			if ( glType == _gl.INT ) internalFormat = _gl.RGB32I;

		}

		if ( glFormat == _gl.RGBA_INTEGER ) {

			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = _gl.RGBA8UI;
			if ( glType == _gl.UNSIGNED_SHORT ) internalFormat = _gl.RGBA16UI;
			if ( glType == _gl.UNSIGNED_INT ) internalFormat = _gl.RGBA32UI;
			if ( glType == _gl.BYTE ) internalFormat = _gl.RGBA8I;
			if ( glType == _gl.SHORT ) internalFormat = _gl.RGBA16I;
			if ( glType == _gl.INT ) internalFormat = _gl.RGBA32I;

		}

		if ( glFormat == _gl.RGB ) {

			if ( glType == _gl.UNSIGNED_INT_5_9_9_9_REV ) internalFormat = _gl.RGB9_E5;

		}

		if ( glFormat == _gl.RGBA ) {

			var transfer = forceLinearTransfer ? LinearTransfer : ColorManagement.getTransfer( colorSpace );

			if ( glType == _gl.FLOAT ) internalFormat = _gl.RGBA32F;
			if ( glType == _gl.HALF_FLOAT ) internalFormat = _gl.RGBA16F;
			if ( glType == _gl.UNSIGNED_BYTE ) internalFormat = ( transfer == SRGBTransfer ) ? _gl.SRGB8_ALPHA8 : _gl.RGBA8;
			if ( glType == _gl.UNSIGNED_SHORT_4_4_4_4 ) internalFormat = _gl.RGBA4;
			if ( glType == _gl.UNSIGNED_SHORT_5_5_5_1 ) internalFormat = _gl.RGB5_A1;

		}

		if ( internalFormat == _gl.R16F || internalFormat == _gl.R32F ||
			internalFormat == _gl.RG16F || internalFormat == _gl.RG32F ||
			internalFormat == _gl.RGBA16F || internalFormat == _gl.RGBA32F ) {

			extensions.get( 'EXT_color_buffer_float' );

		}

		return internalFormat;

	}

	function getInternalDepthFormat( useStencil, depthType ) {

		var glInternalFormat;
		if ( useStencil ) {

			if ( depthType == null || depthType == UnsignedIntType || depthType == UnsignedInt248Type ) {

				glInternalFormat = _gl.DEPTH24_STENCIL8;

			} else if ( depthType == FloatType ) {

				glInternalFormat = _gl.DEPTH32F_STENCIL8;

			} else if ( depthType == UnsignedShortType ) {

				glInternalFormat = _gl.DEPTH24_STENCIL8;
				console.warn( 'DepthTexture: 16 bit depth attachment is not supported with stencil. Using 24-bit attachment.' );

			}

		} else {

			if ( depthType == null || depthType == UnsignedIntType || depthType == UnsignedInt248Type ) {

				glInternalFormat = _gl.DEPTH_COMPONENT24;

			} else if ( depthType == FloatType ) {

				glInternalFormat = _gl.DEPTH_COMPONENT32F;

			} else if ( depthType == UnsignedShortType ) {

				glInternalFormat = _gl.DEPTH_COMPONENT16;

			}

		}

		return glInternalFormat;

	}

	function getMipLevels( texture, image ) {

		if ( textureNeedsGenerateMipmaps( texture ) == true || ( texture.isFramebufferTexture && texture.minFilter != NearestFilter && texture.minFilter != LinearFilter ) ) {

			return Math.log2( Math.max( image.width, image.height ) ) + 1;

		} else if ( texture.mipmaps != undefined && texture.mipmaps.length > 0 ) {

			// user-defined mipmaps

			return texture.mipmaps.length;

		} else if ( texture.isCompressedTexture && Array.isArray( texture.image ) ) {

			return image.mipmaps.length;

		} else {

			// texture without mipmaps (only base level)

			return 1;

		}

	}

	//

	function onTextureDispose( event ) {

		var texture = event.target;

		texture.removeEventListener( 'dispose', onTextureDispose );

		deallocateTexture( texture );

		if ( texture.isVideoTexture ) {

			_videoTextures.delete( texture );

		}

	}

	function onRenderTargetDispose( event ) {

		var renderTarget = event.target;

		renderTarget.removeEventListener( 'dispose', onRenderTargetDispose );

		deallocateRenderTarget( renderTarget );

	}

	//

	function deallocateTexture( texture ) {

		var textureProperties = properties.get( texture );

		if ( textureProperties.__webglInit == undefined ) return;

		// check if it's necessary to remove the WebGLTexture object

		var source = texture.source;
		var webglTextures = _sources.get( source );

		if ( webglTextures ) {

			var webglTexture = webglTextures[ textureProperties.__cacheKey ];
			webglTexture.usedTimes --;

			// the WebGLTexture object is not used anymore, remove it

			if ( webglTexture.usedTimes == 0 ) {

				deleteTexture( texture );

			}

			// remove the weak map entry if no WebGLTexture uses the source anymore

			if ( Object.keys( webglTextures ).length == 0 ) {

				_sources.delete( source );

			}

		}

		properties.remove( texture );

	}

	function deleteTexture( texture ) {

		var textureProperties = properties.get( texture );
		_gl.deleteTexture( textureProperties.__webglTexture );

		var source = texture.source;
		var webglTextures = _sources.get( source );
		Reflect.deleteField(webglTextures, textureProperties.__cacheKey);

		info.memory.textures --;

	}

	function deallocateRenderTarget( renderTarget ) {

		var renderTargetProperties = properties.get( renderTarget );

		if ( renderTarget.depthTexture ) {

			renderTarget.depthTexture.dispose();

			properties.remove( renderTarget.depthTexture );

		}

		if ( renderTarget.isWebGLCubeRenderTarget ) {

			for ( i in 0...6 ) {

				if ( Array.isArray( renderTargetProperties.__webglFramebuffer[ i ] ) ) {

					for ( level in 0...renderTargetProperties.__webglFramebuffer[ i ].length ) _gl.deleteFramebuffer( renderTargetProperties.__webglFramebuffer[ i ][ level ] );

				} else {

					_gl.deleteFramebuffer( renderTargetProperties.__webglFramebuffer[ i ] );

				}

				if ( renderTargetProperties.__webglDepthbuffer ) _gl.deleteRenderbuffer( renderTargetProperties.__webglDepthbuffer[ i ] );

			}

		} else {

			if ( Array.isArray( renderTargetProperties.__webglFramebuffer ) ) {

				for ( level in 0...renderTargetProperties.__webglFramebuffer.length ) _gl.deleteFramebuffer( renderTargetProperties.__webglFramebuffer[ level ] );

			} else {

				_gl.deleteFramebuffer( renderTargetProperties.__webglFramebuffer );

			}

			if ( renderTargetProperties.__webglDepthbuffer ) _gl.deleteRenderbuffer( renderTargetProperties.__webglDepthbuffer );
			if ( renderTargetProperties.__webglMultisampledFramebuffer ) _gl.deleteFramebuffer( renderTargetProperties.__webglMultisampledFramebuffer );

			if ( renderTargetProperties.__webglColorRenderbuffer ) {

				for ( i in 0...renderTargetProperties.__webglColorRenderbuffer.length ) {

					if ( renderTargetProperties.__webglColorRenderbuffer[ i ] ) _gl.deleteRenderbuffer( renderTargetProperties.__webglColorRenderbuffer[ i ] );

				}

			}

			if ( renderTargetProperties.__webglDepthRenderbuffer ) _gl.deleteRenderbuffer( renderTargetProperties.__webglDepthRenderbuffer );

		}

		var textures = renderTarget.textures;

		for ( i in 0...textures.length ) {

			var attachmentProperties = properties.get( textures[ i ] );

			if ( attachmentProperties.__webglTexture ) {

				_gl.deleteTexture( attachmentProperties.__webglTexture );

				info.memory.textures --;

			}

			properties.remove( textures[ i ] );

		}

		properties.remove( renderTarget );

	}

	//

	var textureUnits = 0;

	function resetTextureUnits() {

		textureUnits = 0;

	}

	function allocateTextureUnit() {

		var textureUnit = textureUnits;

		if ( textureUnit >= capabilities.maxTextures ) {

			console.warn( 'THREE.WebGLTextures: Trying to use ' + textureUnit + ' texture units while this GPU supports only ' + capabilities.maxTextures );

		}

		textureUnits += 1;

		return textureUnit;

	}

	function getTextureCacheKey( texture ) {

		var array = [];

		array.push( texture.wrapS );
		array.push( texture.wrapT );
		array.push( texture.wrapR || 0 );
		array.push( texture.magFilter );
		array.push( texture.minFilter );
		array.push( texture.anisotropy );
		array.push( texture.internalFormat );
		array.push( texture.format );
		array.push( texture.type );
		array.push( texture.generateMipmaps );
		array.push( texture.premultiplyAlpha );
		array.push( texture.flipY );
		array.push( texture.unpackAlignment );
		array.push( texture.colorSpace );

		return array.join();

	}

	//

	function setTexture2D( texture, slot ) {

		var textureProperties = properties.get( texture );

		if ( texture.isVideoTexture ) updateVideoTexture( texture );

		if ( texture.isRenderTargetTexture == false && texture.version > 0 && textureProperties.__version != texture.version ) {

			var image = texture.image;

			if ( image == null ) {

				console.warn( 'THREE.WebGLRenderer: Texture marked for update but no image data found.' );

			} else if ( image.complete == false ) {

				console.warn( 'THREE.WebGLRenderer: Texture marked for update but image is incomplete' );

			} else {

				uploadTexture( textureProperties, texture, slot );
				return;

			}

		}

		state.bindTexture( _gl.TEXTURE_2D, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

	}

	function setTexture2DArray( texture, slot ) {

		var textureProperties = properties.get( texture );

		if ( texture.version > 0 && textureProperties.__version != texture.version ) {

			uploadTexture( textureProperties, texture, slot );
			return;

		}

		state.bindTexture( _gl.TEXTURE_2D_ARRAY, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

	}

	function setTexture3D( texture, slot ) {

		var textureProperties = properties.get( texture );

		if ( texture.version > 0 && textureProperties.__version != texture.version ) {

			uploadTexture( textureProperties, texture, slot );
			return;

		}

		state.bindTexture( _gl.TEXTURE_3D, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

	}

	function setTextureCube( texture, slot ) {

		var textureProperties = properties.get( texture );

		if ( texture.version > 0 && textureProperties.__version != texture.version ) {

			uploadCubeTexture( textureProperties, texture, slot );
			return;

		}

		state.bindTexture( _gl.TEXTURE_CUBE_MAP, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

	}

	var wrappingToGL = [
		RepeatWrapping => _gl.REPEAT,
		ClampToEdgeWrapping => _gl.CLAMP_TO_EDGE,
		MirroredRepeatWrapping => _gl.MIRRORED_REPEAT
	];

	var filterToGL = [
		NearestFilter => _gl.NEAREST,
		NearestMipmapNearestFilter => _gl.NEAREST_MIPMAP_NEAREST,
		NearestMipmapLinearFilter => _gl.NEAREST_MIPMAP_LINEAR,

		LinearFilter => _gl.LINEAR,
		LinearMipmapNearestFilter => _gl.LINEAR_MIPMAP_NEAREST,
		LinearMipmapLinearFilter => _gl.LINEAR_MIPMAP_LINEAR
	];

	var compareToGL = [
		NeverCompare => _gl.NEVER,
		AlwaysCompare => _gl.ALWAYS,
		LessCompare => _gl.LESS,
		LessEqualCompare => _gl.LEQUAL,
		EqualCompare => _gl.EQUAL,
		GreaterEqualCompare => _gl.GEQUAL,
		GreaterCompare => _gl.GREATER,
		NotEqualCompare => _gl.NOTEQUAL
	];

	function setTextureParameters( textureType, texture ) {

		if ( texture.type == FloatType && extensions.has( 'OES_texture_float_linear' ) == false &&
			( texture.magFilter == LinearFilter || texture.magFilter == LinearMipmapNearestFilter || texture.magFilter == NearestMipmapLinearFilter || texture.magFilter == LinearMipmapLinearFilter ||
			texture.minFilter == LinearFilter || texture.minFilter == LinearMipmapNearestFilter || texture.minFilter == NearestMipmapLinearFilter || texture.minFilter == LinearMipmapLinearFilter ) ) {

			console.warn( 'THREE.WebGLRenderer: Unable to use linear filtering with floating point textures. OES_texture_float_linear not supported on this device.' );

		}

		_gl.texParameteri( textureType, _gl.TEXTURE_WRAP_S, wrappingToGL[ texture.wrapS ] );
		_gl.texParameteri( textureType, _gl.TEXTURE_WRAP_T, wrappingToGL[ texture.wrapT ] );

		if ( textureType == _gl.TEXTURE_3D || textureType == _gl.TEXTURE_2D_ARRAY ) {

			_gl.texParameteri( textureType, _gl.TEXTURE_WRAP_R, wrappingToGL[ texture.wrapR ] );

		}

		_gl.texParameteri( textureType, _gl.TEXTURE_MAG_FILTER, filterToGL[ texture.magFilter ] );
		_gl.texParameteri( textureType, _gl.TEXTURE_MIN_FILTER, filterToGL[ texture.minFilter ] );

		if ( texture.compareFunction ) {

			_gl.texParameteri( textureType, _gl.TEXTURE_COMPARE_MODE, _gl.COMPARE_REF_TO_TEXTURE );
			_gl.texParameteri( textureType, _gl.TEXTURE_COMPARE_FUNC, compareToGL[ texture.compareFunction ] );

		}

		if ( extensions.has( 'EXT_texture_filter_anisotropic' ) == true ) {

			if ( texture.magFilter == NearestFilter ) return;
			if ( texture.minFilter != NearestMipmapLinearFilter && texture.minFilter != LinearMipmapLinearFilter ) return;
			if ( texture.type == FloatType && extensions.has( 'OES_texture_float_linear' ) == false ) return; // verify extension

			if ( texture.anisotropy > 1 || properties.get( texture ).__currentAnisotropy ) {

				var extension = extensions.get( 'EXT_texture_filter_anisotropic' );
				_gl.texParameterf( textureType, extension.TEXTURE_MAX_ANISOTROPY_EXT, Math.min( texture.anisotropy, capabilities.getMaxAnisotropy() ) );
				properties.get( texture ).__currentAnisotropy = texture.anisotropy;

			}

		}

	}

	function initTexture( textureProperties, texture ) {

		var forceUpload = false;

		if ( textureProperties.__webglInit == undefined ) {

			textureProperties.__webglInit = true;

			texture.addEventListener( 'dispose', onTextureDispose );

		}

		// create Source <-> WebGLTextures mapping if necessary

		var source = texture.source;
		var webglTextures = _sources.get( source );

		if ( webglTextures == undefined ) {

			webglTextures = {};
			_sources.set( source, webglTextures );

		}

		// check if there is already a WebGLTexture object for the given texture parameters

		var textureCacheKey = getTextureCacheKey( texture );

		if ( textureCacheKey != textureProperties.__cacheKey ) {

			// if not, create a new instance of WebGLTexture

			if ( webglTextures[ textureCacheKey ] == undefined ) {

				// create new entry

				webglTextures[ textureCacheKey ] = {
					texture: _gl.createTexture(),
					usedTimes: 0
				};

				info.memory.textures ++;

				// when a new instance of WebGLTexture was created, a texture upload is required
				// even if the image contents are identical

				forceUpload = true;

			}

			webglTextures[ textureCacheKey ].usedTimes ++;

			// every time the texture cache key changes, it's necessary to check if an instance of
			// WebGLTexture can be deleted in order to avoid a memory leak.

			var webglTexture = webglTextures[ textureProperties.__cacheKey ];

			if ( webglTexture != undefined ) {

				webglTextures[ textureProperties.__cacheKey ].usedTimes --;

				if ( webglTexture.usedTimes == 0 ) {

					deleteTexture( texture );

				}

			}

			// store references to cache key and WebGLTexture object

			textureProperties.__cacheKey = textureCacheKey;
			textureProperties.__webglTexture = webglTextures[ textureCacheKey ].texture;

		}

		return forceUpload;

	}

	function uploadTexture( textureProperties, texture, slot ) {

		var textureType = _gl.TEXTURE_2D;

		if ( texture.isDataArrayTexture || texture.isCompressedArrayTexture ) textureType = _gl.TEXTURE_2D_ARRAY;
		if ( texture.isData3DTexture ) textureType = _gl.TEXTURE_3D;

		var forceUpload = initTexture( textureProperties, texture );
		var source = texture.source;

		state.bindTexture( textureType, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

		var sourceProperties = properties.get( source );

		if ( source.version != sourceProperties.__version || forceUpload == true ) {

			state.activeTexture( _gl.TEXTURE0 + slot );

			var workingPrimaries = ColorManagement.getPrimaries( ColorManagement.workingColorSpace );
			var texturePrimaries = texture.colorSpace == NoColorSpace ? null : ColorManagement.getPrimaries( texture.colorSpace );
			var unpackConversion = texture.colorSpace == NoColorSpace || workingPrimaries == texturePrimaries ? _gl.NONE : _gl.BROWSER_DEFAULT_WEBGL;

			_gl.pixelStorei( _gl.UNPACK_FLIP_Y_WEBGL, texture.flipY );
			_gl.pixelStorei( _gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, texture.premultiplyAlpha );
			_gl.pixelStorei( _gl.UNPACK_ALIGNMENT, texture.unpackAlignment );
			_gl.pixelStorei( _gl.UNPACK_COLORSPACE_CONVERSION_WEBGL, unpackConversion );

			var image = resizeImage( texture.image, false, capabilities.maxTextureSize );
			image = verifyColorSpace( texture, image );

			var glFormat = utils.convert( texture.format, texture.colorSpace );

			var glType = utils.convert( texture.type );
			var glInternalFormat = getInternalFormat( texture.internalFormat, glFormat, glType, texture.colorSpace, texture.isVideoTexture );

			setTextureParameters( textureType, texture );

			var mipmap;
			var mipmaps = texture.mipmaps;

			var useTexStorage = ( texture.isVideoTexture != true );
			var allocateMemory = ( sourceProperties.__version == undefined ) || ( forceUpload == true );
			var dataReady = source.dataReady;
			var levels = getMipLevels( texture, image );

			if ( texture.isDepthTexture ) {

				glInternalFormat = getInternalDepthFormat( texture.format == DepthStencilFormat, texture.type );

				//

				if ( allocateMemory ) {

					if ( useTexStorage ) {

						state.texStorage2D( _gl.TEXTURE_2D, 1, glInternalFormat, image.width, image.height );

					} else {

						state.texImage2D( _gl.TEXTURE_2D, 0, glInternalFormat, image.width, image.height, 0, glFormat, glType, null );

					}

				}

			} else if ( texture.isDataTexture ) {

				// use manually created mipmaps if available
				// if there are no manual mipmaps
				// set 0 level mipmap and then use GL to generate other mipmap levels

				if ( mipmaps.length > 0 ) {

					if ( useTexStorage && allocateMemory ) {

						state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, mipmaps[ 0 ].width, mipmaps[ 0 ].height );

					}

					for ( i in 0...mipmaps.length ) {

						mipmap = mipmaps[ i ];

						if ( useTexStorage ) {

							if ( dataReady ) {

								state.texSubImage2D( _gl.TEXTURE_2D, i, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );

							}

						} else {

							state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );

						}

					}

					texture.generateMipmaps = false;

				} else {

					if ( useTexStorage ) {

						if ( allocateMemory ) {

							state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, image.width, image.height );

						}

						if ( dataReady ) {

							state.texSubImage2D( _gl.TEXTURE_2D, 0, 0, 0, image.width, image.height, glFormat, glType, image.data );

						}

					} else {

						state.texImage2D( _gl.TEXTURE_2D, 0, glInternalFormat, image.width, image.height, 0, glFormat, glType, image.data );

					}

				}

			} else if ( texture.isCompressedTexture ) {

				if ( texture.isCompressedArrayTexture ) {

					if ( useTexStorage && allocateMemory ) {

						state.texStorage3D( _gl.TEXTURE_2D_ARRAY, levels, glInternalFormat, mipmaps[ 0 ].width, mipmaps[ 0 ].height, image.depth );

					}

					for ( i in 0...mipmaps.length ) {

						mipmap = mipmaps[ i ];

						if ( texture.format != RGBAFormat ) {

							if ( glFormat != null ) {

								if ( useTexStorage ) {

									if ( dataReady ) {

										if ( texture.layerUpdates.size > 0 ) {

											var layerByteLength = getByteLength( mipmap.width, mipmap.height, texture.format, texture.type );

											for ( layerIndex in texture.layerUpdates ) {

												var layerData = mipmap.data.subarray(
													layerIndex * layerByteLength / mipmap.data.BYTES_PER_ELEMENT,
													( layerIndex + 1 ) * layerByteLength / mipmap.data.BYTES_PER_ELEMENT
												);
												state.compressedTexSubImage3D( _gl.TEXTURE_2D_ARRAY, i, 0, 0, layerIndex, mipmap.width, mipmap.height, 1, glFormat, layerData );

											}

											texture.clearLayerUpdates();

										} else {

											state.compressedTexSubImage3D( _gl.TEXTURE_2D_ARRAY, i, 0, 0, 0, mipmap.width, mipmap.height, image.depth, glFormat, mipmap.data );

										}

									}

								} else {

									state.compressedTexImage3D( _gl.TEXTURE_2D_ARRAY, i, glInternalFormat, mipmap.width, mipmap.height, image.depth, 0, mipmap.data, 0, 0 );

								}

							} else {

								console.warn( 'THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()' );

							}

						} else {

							if ( useTexStorage ) {

								if ( dataReady ) {

									state.texSubImage3D( _gl.TEXTURE_2D_ARRAY, i, 0, 0, 0, mipmap.width, mipmap.height, image.depth, glFormat, glType, mipmap.data );

								}

							} else {

								state.texImage3D( _gl.TEXTURE_2D_ARRAY, i, glInternalFormat, mipmap.width, mipmap.height, image.depth, 0, glFormat, glType, mipmap.data );

							}

						}

					}

				} else {

					if ( useTexStorage && allocateMemory ) {

						state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, mipmaps[ 0 ].width, mipmaps[ 0 ].height );

					}

					for ( i in 0...mipmaps.length ) {

						mipmap = mipmaps[ i ];

						if ( texture.format != RGBAFormat ) {

							if ( glFormat != null ) {

								if ( useTexStorage ) {

									if ( dataReady ) {

										state.compressedTexSubImage2D( _gl.TEXTURE_2D, i, 0, 0, mipmap.width, mipmap.height, glFormat, mipmap.data );

									}

								} else {

									state.compressedTexImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, mipmap.data );

								}

							} else {

								console.warn( 'THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()' );

							}

						} else {

							if ( useTexStorage ) {

								if ( dataReady ) {

									state.texSubImage2D( _gl.TEXTURE_2D, i, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );

								}

							} else {

								state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );

							}

						}

					}

				}

			} else if ( texture.isDataArrayTexture ) {

				if ( useTexStorage ) {

					if ( allocateMemory ) {

						state.texStorage3D( _gl.TEXTURE_2D_ARRAY, levels, glInternalFormat, image.width, image.height, image.depth );

					}

					if ( dataReady ) {

						if ( texture.layerUpdates.size > 0 ) {

							var layerByteLength = getByteLength( image.width, image.height, texture.format, texture.type );

							for ( layerIndex in texture.layerUpdates ) {

								var layerData = image.data.subarray(
									layerIndex * layerByteLength / image.data.BYTES_PER_ELEMENT,
									( layerIndex + 1 ) * layerByteLength / image.data.BYTES_PER_ELEMENT
								);
								state.texSubImage3D( _gl.TEXTURE_2D_ARRAY, 0, 0, 0, layerIndex, image.width, image.height, 1, glFormat, glType, layerData );

							}

							texture.clearLayerUpdates();

						} else {

							state.texSubImage3D( _gl.TEXTURE_2D_ARRAY, 0, 0, 0, 0, image.width, image.height, image.depth, glFormat, glType, image.data );

						}

					}

				} else {

					state.texImage3D( _gl.TEXTURE_2D_ARRAY, 0, glInternalFormat, image.width, image.height, image.depth, 0, glFormat, glType, image.data );

				}

			} else if ( texture.isData3DTexture ) {

				if ( useTexStorage ) {

					if ( allocateMemory ) {

						state.texStorage3D( _gl.TEXTURE_3D, levels, glInternalFormat, image.width, image.height, image.depth );

					}

					if ( dataReady ) {

						state.texSubImage3D( _gl.TEXTURE_3D, 0, 0, 0, 0, image.width, image.height, image.depth, glFormat, glType, image.data );

					}

				} else {

					state.texImage3D( _gl.TEXTURE_3D, 0, glInternalFormat, image.width, image.height, image.depth, 0, glFormat, glType, image.data );

				}

			} else if ( texture.isFramebufferTexture ) {

				if ( allocateMemory ) {

					if ( useTexStorage ) {

						state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, image.width, image.height );

					} else {

						var width = image.width, height = image.height;

						for ( i in 0...levels ) {

							state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, width, height, 0, glFormat, glType, null );

							width >>= 1;
							height >>= 1;

						}

					}

				}

			} else {

				// regular Texture (image, video, canvas)

				// use manually created mipmaps if available
				// if there are no manual mipmaps
				// set 0 level mipmap and then use GL to generate other mipmap levels

				if ( mipmaps.length > 0 ) {

					if ( useTexStorage && allocateMemory ) {

						var dimensions = getDimensions( mipmaps[ 0 ] );

						state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, dimensions.width, dimensions.height );

					}

					for ( i in 0...mipmaps.length ) {

						mipmap = mipmaps[ i ];

						if ( useTexStorage ) {

							if ( dataReady ) {

								state.texSubImage2D( _gl.TEXTURE_2D, i, 0, 0, glFormat, glType, mipmap );

							}

						} else {

							state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, glFormat, glType, mipmap );

						}

					}

					texture.generateMipmaps = false;

				} else {

					if ( useTexStorage ) {

						if ( allocateMemory ) {

							var dimensions = getDimensions( image );

							state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, dimensions.width, dimensions.height );

						}

						if ( dataReady ) {

							state.texSubImage2D( _gl.TEXTURE_2D, 0, 0, 0, glFormat, glType, image );

						}

					} else {

						state.texImage2D( _gl.TEXTURE_2D, 0, glInternalFormat, glFormat, glType, image );

					}

				}

			}

			if ( textureNeedsGenerateMipmaps( texture ) ) {

				generateMipmap( textureType );

			}

			sourceProperties.__version = source.version;

			if ( texture.onUpdate ) texture.onUpdate( texture );

		}

		textureProperties.__version = texture.version;

	}

	function uploadCubeTexture( textureProperties, texture, slot ) {

		if ( texture.image.length != 6 ) return;

		var forceUpload = initTexture( textureProperties, texture );
		var source = texture.source;

		state.bindTexture( _gl.TEXTURE_CUBE_MAP, textureProperties.__webglTexture, _gl.TEXTURE0 + slot );

		var sourceProperties = properties.get( source );

		if ( source.version != sourceProperties.__version || forceUpload == true ) {

			state.activeTexture( _gl.TEXTURE0 + slot );

			var workingPrimaries = ColorManagement.getPrimaries( ColorManagement.workingColorSpace );
			var texturePrimaries = texture.colorSpace == NoColorSpace ? null : ColorManagement.getPrimaries( texture.colorSpace );
			var unpackConversion = texture.colorSpace == NoColorSpace || workingPrimaries == texturePrimaries ? _gl.NONE : _gl.BROWSER_DEFAULT_WEBGL;

			_gl.pixelStorei( _gl.UNPACK_FLIP_Y_WEBGL, texture.flipY );
			_gl.pixelStorei( _gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, texture.premultiplyAlpha );
			_gl.pixelStorei( _gl.UNPACK_ALIGNMENT, texture.unpackAlignment );
			_gl.pixelStorei( _gl.UNPACK_COLORSPACE_CONVERSION_WEBGL, unpackConversion );

			var isCompressed = ( texture.isCompressedTexture || texture.image[ 0 ].isCompressedTexture );
			var isDataTexture = ( texture.image[ 0 ] && texture.image[ 0 ].isDataTexture );

			var cubeImage = [];

			for ( i = 0...6 ) {

				if ( ! isCompressed && ! isDataTexture ) {

					cubeImage[ i ] = resizeImage( texture.image[ i ], true, capabilities.maxCubemapSize );

				} else {

					cubeImage[ i ] = isDataTexture ? texture.image[ i ].image : texture.image[ i ];

				}

				cubeImage[ i ] = verifyColorSpace( texture, cubeImage[ i ] );

			}

			var image = cubeImage[ 0 ],
				glFormat = utils.convert( texture.format, texture.colorSpace ),
				glType = utils.convert( texture.type ),
				glInternalFormat = getInternalFormat( texture.internalFormat, glFormat, glType, texture.colorSpace );

			var useTexStorage = ( texture.isVideoTexture != true );
			var allocateMemory = ( sourceProperties.__version == undefined ) || ( forceUpload == true );
			var dataReady = source.dataReady;
			var levels = getMipLevels( texture, image );

			setTextureParameters( _gl.TEXTURE_CUBE_MAP, texture );

			var mipmaps;

			if ( isCompressed ) {

				if ( useTexStorage && allocateMemory ) {

					state.texStorage2D( _gl.TEXTURE_CUBE_MAP, levels, glInternalFormat, image.width, image.height );

				}

				for ( i in 0...6 ) {

					mipmaps = cubeImage[ i ].mipmaps;

					for ( j in 0...mipmaps.length ) {

						var mipmap = mipmaps[ j ];

						if ( texture.format != RGBAFormat ) {

							if ( glFormat != null ) {

								if ( useTexStorage ) {

									if ( dataReady ) {

										state.compressedTexSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, 0, 0, mipmap.width, mipmap.height, glFormat, mipmap.data );

									}

								} else {

									state.compressedTexImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, glInternalFormat, mipmap.width, mipmap.height, 0, mipmap.data );

								}

							} else {

								console.warn( 'THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()' );

							}

						} else {

							if ( useTexStorage ) {

								if ( dataReady ) {

									state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );

								}

							} else {

								state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );

							}

						}

					}

				}

			} else {

				mipmaps = texture.mipmaps;

				if ( useTexStorage && allocateMemory ) {

					// TODO: Uniformly handle mipmap definitions
					// Normal textures and compressed cube textures define base level + mips with their mipmap array
					// Uncompressed cube textures use their mipmap array only for mips (no base level)

					if ( mipmaps.length > 0 ) levels ++;

					var dimensions = getDimensions( cubeImage[ 0 ] );

					state.texStorage2D( _gl.TEXTURE_CUBE_MAP, levels, glInternalFormat, dimensions.width, dimensions.height );

				}

				for ( i in 0...6 ) {

					if ( isDataTexture ) {

						if ( useTexStorage ) {

							if ( dataReady ) {

								state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, 0, 0, cubeImage[ i ].width, cubeImage[ i ].height, glFormat, glType, cubeImage[ i ].data );

							}

						} else {

							state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, cubeImage[ i ].width, cubeImage[ i ].height, 0, glFormat, glType, cubeImage[ i ].data );

						}

						for ( j in 0...mipmaps.length ) {

							var mipmap = mipmaps[ j ];
							var mipmapImage = mipmap.image[ i ].image;

							if ( useTexStorage ) {

								if ( dataReady ) {

									state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, 0, 0, mipmapImage.width, mipmapImage.height, glFormat, glType, mipmapImage.data );

								}

							} else {

								state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, glInternalFormat, mipmapImage.width, mipmapImage.height, 0, glFormat, glType, mipmapImage.data );

							}

						}

					} else {

						if ( useTexStorage ) {

							if ( dataReady ) {

								state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, 0, 0, glFormat, glType, cubeImage[ i ] );

							}

						} else {

							state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, glFormat, glType, cubeImage[ i ] );

						}

						for ( j in 0...mipmaps.length ) {

							var mipmap = mipmaps[ j ];

							if ( useTexStorage ) {

								if ( dataReady ) {

									state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, 0, 0, glFormat, glType, mipmap.image[ i ] );

								}

							} else {

								state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, glInternalFormat, glFormat, glType, mipmap.image[ i ] );

							}

						}

					}

				}

			}

			if ( textureNeedsGenerateMipmaps( texture ) ) {

				// We assume images for cube map have the same size.
				generateMipmap( _gl.TEXTURE_CUBE_MAP );

			}

			sourceProperties.__version = source.version;

			if ( texture.onUpdate ) texture.onUpdate( texture );

		}

		textureProperties.__version = texture.version;

	}

	// Render targets

	// Setup storage for target texture and bind it to correct framebuffer
	function setupFrameBufferTexture( framebuffer, renderTarget, texture, attachment, textureTarget, level ) {

		var glFormat = utils.convert( texture.format, texture.colorSpace );
		var glType = utils.convert( texture.type );
		var glInternalFormat = getInternalFormat( texture.internalFormat, glFormat, glType, texture.colorSpace );
		var renderTargetProperties = properties.get( renderTarget );
		var textureProperties = properties.get( texture );

		textureProperties.__renderTarget = renderTarget;

		if ( ! renderTargetProperties.__hasExternalTextures ) {

			var width = Math.max( 1, renderTarget.width >> level );
			var height = Math.max( 1, renderTarget.height >> level );

			if ( textureTarget == _gl.TEXTURE_3D || textureTarget == _gl.TEXTURE_2D_ARRAY ) {

				state.texImage3D( textureTarget, level, glInternalFormat, width, height, renderTarget.depth, 0, glFormat, glType, null );

			} else {

				state.texImage2D( textureTarget, level, glInternalFormat, width, height, 0, glFormat, glType, null );

			}

		}

		state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

		if ( useMultisampledRTT( renderTarget ) ) {

			multisampledRTTExt.framebufferTexture2DMultisampleEXT( _gl.FRAMEBUFFER, attachment, textureTarget, textureProperties.__webglTexture, 0, getRenderTargetSamples( renderTarget ) );

		} else if ( textureTarget == _gl.TEXTURE_2D || ( textureTarget >= _gl.TEXTURE_CUBE_MAP_POSITIVE_X && textureTarget <= _gl.TEXTURE_CUBE_MAP_NEGATIVE_Z ) ) { // see #24753

			_gl.framebufferTexture2D( _gl.FRAMEBUFFER, attachment, textureTarget, textureProperties.__webglTexture, level );

		}

		state.bindFramebuffer( _gl.FRAMEBUFFER, null );

	}

	// Setup storage for internal depth/stencil buffers and bind to correct framebuffer
	function setupRenderBufferStorage( renderbuffer, renderTarget, isMultisample ) {

		_gl.bindRenderbuffer( _gl.RENDERBUFFER, renderbuffer );

		if ( renderTarget.depthBuffer ) {

			// retrieve the depth attachment types
			var depthTexture = renderTarget.depthTexture;
			var depthType = depthTexture && depthTexture.isDepthTexture ? depthTexture.type : null;
			var glInternalFormat = getInternalDepthFormat( renderTarget.stencilBuffer, depthType );
			var glAttachmentType = renderTarget.stencilBuffer ? _gl.DEPTH_STENCIL_ATTACHMENT : _gl.DEPTH_ATTACHMENT;

			// set up the attachment
			var samples = getRenderTargetSamples( renderTarget );
			var isUseMultisampledRTT = useMultisampledRTT( renderTarget );
			if ( isUseMultisampledRTT ) {

				multisampledRTTExt.renderbufferStorageMultisampleEXT( _gl.RENDERBUFFER, samples, glInternalFormat, renderTarget.width, renderTarget.height );

			} else if ( isMultisample ) {

				_gl.renderbufferStorageMultisample( _gl.RENDERBUFFER, samples, glInternalFormat, renderTarget.width, renderTarget.height );

			} else {

				_gl.renderbufferStorage( _gl.RENDERBUFFER, glInternalFormat, renderTarget.width, renderTarget.height );

			}

			_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, glAttachmentType, _gl.RENDERBUFFER, renderbuffer );

		} else {

			var textures = renderTarget.textures;

			for ( i in 0...textures.length ) {

				var texture = textures[ i ];

				var glFormat = utils.convert( texture.format, texture.colorSpace );
				var glType = utils.convert( texture.type );
				var glInternalFormat = getInternalFormat( texture.internalFormat, glFormat, glType, texture.colorSpace );
				var samples = getRenderTargetSamples( renderTarget );

				if ( isMultisample && useMultisampledRTT( renderTarget ) == false ) {

					_gl.renderbufferStorageMultisample( _gl.RENDERBUFFER, samples, glInternalFormat, renderTarget.width, renderTarget.height );

				} else if ( useMultisampledRTT( renderTarget ) ) {

					multisampledRTTExt.renderbufferStorageMultisampleEXT( _gl.RENDERBUFFER, samples, glInternalFormat, renderTarget.width, renderTarget.height );

				} else {

					_gl.renderbufferStorage( _gl.RENDERBUFFER, glInternalFormat, renderTarget.width, renderTarget.height );

				}

			}

		}

		_gl.bindRenderbuffer( _gl.RENDERBUFFER, null );

	}

	// Setup resources for a Depth Texture for a FBO (needs an extension)
	function setupDepthTexture( framebuffer, renderTarget ) {

		var isCube = ( renderTarget && renderTarget.isWebGLCubeRenderTarget );
		if ( isCube ) throw new Error( 'Depth Texture with cube render targets is not supported' );

		state.bindFramebuffer( _gl.FRAMEBUFFER, framebuffer );

		if ( ! ( renderTarget.depthTexture && renderTarget.depthTexture.isDepthTexture ) ) {

			throw new Error( 'renderTarget.depthTexture must be an instance of THREE.DepthTexture' );

		}

		var textureProperties = properties.get( renderTarget.depthTexture );
		textureProperties.__renderTarget = renderTarget;

		// upload an empty depth texture with framebuffer size
		if ( ! textureProperties.__webglTexture ||
				renderTarget.depthTexture.image.width != renderTarget.width ||
				renderTarget.depthTexture.image.height != renderTarget.height ) {

			renderTarget.depthTexture.image.width = renderTarget.width;
			renderTarget.depthTexture.image.height = renderTarget.height;
			renderTarget.depthTexture.needsUpdate = true;

		}

		setTexture2D( renderTarget.depthTexture, 0 );

		var webglDepthTexture = textureProperties.__webglTexture;
		var samples = getRenderTargetSamples( renderTarget );

		if ( renderTarget.depthTexture.format == DepthFormat ) {

			if ( useMultisampledRTT( renderTarget ) ) {

				multisampledRTTExt.framebufferTexture2DMultisampleEXT( _gl.FRAMEBUFFER, _gl.DEPTH_ATTACHMENT, _gl.TEXTURE_2D, webglDepthTexture, 0, samples );

			} else {

				_gl.framebufferTexture2D( _gl.FRAMEBUFFER, _gl.DEPTH_ATTACHMENT, _gl.TEXTURE_2D, webglDepthTexture, 0 );

			}

		} else if ( renderTarget.depthTexture.format == DepthStencilFormat ) {

			if ( useMultisampledRTT( renderTarget ) ) {

				multisampledRTTExt.framebufferTexture2DMultisampleEXT( _gl.FRAMEBUFFER, _gl.DEPTH_STENCIL_ATTACHMENT, _gl.TEXTURE_2D, webglDepthTexture, 0, samples );

			} else {

				_gl.framebufferTexture2D( _gl.FRAMEBUFFER, _gl.DEPTH_STENCIL_ATTACHMENT, _gl.TEXTURE_2D, webglDepthTexture, 0 );

			}

		} else {

			throw new Error( 'Unknown depthTexture format' );

		}

	}

	// Setup GL resources for a non-texture depth buffer
	function setupDepthRenderbuffer( renderTarget ) {

		var renderTargetProperties = properties.get( renderTarget );
		var isCube = ( renderTarget.isWebGLCubeRenderTarget == true );

		// if the bound depth texture has changed
		if ( renderTargetProperties.__boundDepthTexture != renderTarget.depthTexture ) {

			// fire the dispose event to get rid of stored state associated with the previously bound depth buffer
			var depthTexture = renderTarget.depthTexture;
			if ( renderTargetProperties.__depthDisposeCallback ) {

				renderTargetProperties.__depthDisposeCallback();

			}

			// set up dispose listeners to track when the currently attached buffer is implicitly unbound
			if ( depthTexture ) {

				var disposeEvent = function() {

					Reflect.deleteField(renderTargetProperties, "__boundDepthTexture");
					Reflect.deleteField(renderTargetProperties, "__depthDisposeCallback");
					depthTexture.removeEventListener( 'dispose', disposeEvent );

				};

				depthTexture.addEventListener( 'dispose', disposeEvent );
				renderTargetProperties.__depthDisposeCallback = disposeEvent;

			}

			renderTargetProperties.__boundDepthTexture = depthTexture;

		}

		if ( renderTarget.depthTexture && ! renderTargetProperties.__autoAllocateDepthBuffer ) {

			if ( isCube ) throw new Error( 'target.depthTexture not supported in Cube render targets' );

			var mipmaps = renderTarget.texture.mipmaps;

			if ( mipmaps && mipmaps.length > 0 ) {

				setupDepthTexture( renderTargetProperties.__webglFramebuffer[ 0 ], renderTarget );

			} else {

				setupDepthTexture( renderTargetProperties.__webglFramebuffer, renderTarget );

			}

		} else {

			if ( isCube ) {

				renderTargetProperties.__webglDepthbuffer = [];

				for ( i in 0...6 ) {

					state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglFramebuffer[ i ] );

					if ( renderTargetProperties.__webglDepthbuffer[ i ] == undefined ) {

						renderTargetProperties.__webglDepthbuffer[ i ] = _gl.createRenderbuffer();
						setupRenderBufferStorage( renderTargetProperties.__webglDepthbuffer[ i ], renderTarget, false );

					} else {

						// attach buffer if it's been created already
						var glAttachmentType = renderTarget.stencilBuffer ? _gl.DEPTH_STENCIL_ATTACHMENT : _gl.DEPTH_ATTACHMENT;
						var renderbuffer = renderTargetProperties.__webglDepthbuffer[ i ];
						_gl.bindRenderbuffer( _gl.RENDERBUFFER, renderbuffer );
						_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, glAttachmentType, _gl.RENDERBUFFER, renderbuffer );

					}

				}

			} else {

				var mipmaps = renderTarget.texture.mipmaps;

				if ( mipmaps && mipmaps.length > 0 ) {

					state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglFramebuffer[ 0 ] );

				} else {

					state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglFramebuffer );

				}

				if ( renderTargetProperties.__webglDepthbuffer == undefined ) {

					renderTargetProperties.__webglDepthbuffer = _gl.createRenderbuffer();
					setupRenderBufferStorage( renderTargetProperties.__webglDepthbuffer, renderTarget, false );

				} else {

					// attach buffer if it's been created already
					var glAttachmentType = renderTarget.stencilBuffer ? _gl.DEPTH_STENCIL_ATTACHMENT : _gl.DEPTH_ATTACHMENT;
					var renderbuffer = renderTargetProperties.__webglDepthbuffer;
					_gl.bindRenderbuffer( _gl.RENDERBUFFER, renderbuffer );
					_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, glAttachmentType, _gl.RENDERBUFFER, renderbuffer );

				}

			}

		}

		state.bindFramebuffer( _gl.FRAMEBUFFER, null );

	}

	// rebind framebuffer with external textures
	function rebindTextures( renderTarget, colorTexture, depthTexture ) {

		var renderTargetProperties = properties.get( renderTarget );

		if ( colorTexture != undefined ) {

			setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer, renderTarget, renderTarget.texture, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, 0 );

		}

		if ( depthTexture != undefined ) {

			setupDepthRenderbuffer( renderTarget );

		}

	}

	// Set up GL resources for the render target
	function setupRenderTarget( renderTarget ) {

		var texture = renderTarget.texture;

		var renderTargetProperties = properties.get( renderTarget );
		var textureProperties = properties.get( texture );

		renderTarget.addEventListener( 'dispose', onRenderTargetDispose );

		var textures = renderTarget.textures;

		var isCube = ( renderTarget.isWebGLCubeRenderTarget == true );
		var isMultipleRenderTargets = ( textures.length > 1 );

		if ( ! isMultipleRenderTargets ) {

			if ( textureProperties.__webglTexture == undefined ) {

				textureProperties.__webglTexture = _gl.createTexture();

			}

			textureProperties.__version = texture.version;
			info.memory.textures ++;

		}

		// Setup framebuffer

		if ( isCube ) {

			renderTargetProperties.__webglFramebuffer = [];

			for ( i in 0...6 ) {

				if ( texture.mipmaps && texture.mipmaps.length > 0 ) {

					renderTargetProperties.__webglFramebuffer[ i ] = [];

					for ( level in 0...texture.mipmaps.length ) {

						renderTargetProperties.__webglFramebuffer[ i ][ level ] = _gl.createFramebuffer();

					}

				} else {

					renderTargetProperties.__webglFramebuffer[ i ] = _gl.createFramebuffer();

				}

			}

		} else {

			if ( texture.mipmaps && texture.mipmaps.length > 0 ) {

				renderTargetProperties.__webglFramebuffer = [];

				for ( level in 0...texture.mipmaps.length ) {

					renderTargetProperties.__webglFramebuffer[ level ] = _gl.createFramebuffer();

				}

			} else {

				renderTargetProperties.__webglFramebuffer = _gl.createFramebuffer();

			}

			if ( isMultipleRenderTargets ) {

				for ( i in 0...textures.length ) {

					var attachmentProperties = properties.get( textures[ i ] );

					if ( attachmentProperties.__webglTexture == undefined ) {

						attachmentProperties.__webglTexture = _gl.createTexture();

						info.memory.textures ++;

					}

				}

			}

			if ( ( renderTarget.samples > 0 ) && useMultisampledRTT( renderTarget ) == false ) {

				renderTargetProperties.__webglMultisampledFramebuffer = _gl.createFramebuffer();
				renderTargetProperties.__webglColorRenderbuffer = [];

				state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglMultisampledFramebuffer );

				for ( i in 0...textures.length ) {

					var texture = textures[ i ];
					renderTargetProperties.__webglColorRenderbuffer[ i ] = _gl.createRenderbuffer();

					_gl.bindRenderbuffer( _gl.RENDERBUFFER, renderTargetProperties.__webglColorRenderbuffer[ i ] );

					var glFormat = utils.convert( texture.format, texture.colorSpace );
					var glType = utils.convert( texture.type );
					var glInternalFormat = getInternalFormat( texture.internalFormat, glFormat, glType, texture.colorSpace, renderTarget.isXRRenderTarget == true );
					var samples = getRenderTargetSamples( renderTarget );
					_gl.renderbufferStorageMultisample( _gl.RENDERBUFFER, samples, glInternalFormat, renderTarget.width, renderTarget.height );

					_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0 + i, _gl.RENDERBUFFER, renderTargetProperties.__webglColorRenderbuffer[ i ] );

				}

				_gl.bindRenderbuffer( _gl.RENDERBUFFER, null );

				if ( renderTarget.depthBuffer ) {

					renderTargetProperties.__webglDepthRenderbuffer = _gl.createRenderbuffer();
					setupRenderBufferStorage( renderTargetProperties.__webglDepthRenderbuffer, renderTarget, true );

				}

				state.bindFramebuffer( _gl.FRAMEBUFFER, null );

			}

		}

		// Setup color buffer

		if ( isCube ) {

			state.bindTexture( _gl.TEXTURE_CUBE_MAP, textureProperties.__webglTexture );
			setTextureParameters( _gl.TEXTURE_CUBE_MAP, texture );

			for ( i in 0...6 ) {

				if ( texture.mipmaps && texture.mipmaps.length > 0 ) {

					for ( level in 0...texture.mipmaps.length ) {

						setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer[ i ][ level ], renderTarget, texture, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, level );

					}

				} else {

					setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer[ i ], renderTarget, texture, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0 );

				}

			}

			if ( textureNeedsGenerateMipmaps( texture ) ) {

				generateMipmap( _gl.TEXTURE_CUBE_MAP );

			}

			state.unbindTexture();

		} else if ( isMultipleRenderTargets ) {

			for ( i in 0...textures.length ) {

				var attachment = textures[ i ];
				var attachmentProperties = properties.get( attachment );

				state.bindTexture( _gl.TEXTURE_2D, attachmentProperties.__webglTexture );
				setTextureParameters( _gl.TEXTURE_2D, attachment );
				setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer, renderTarget, attachment, _gl.COLOR_ATTACHMENT0 + i, _gl.TEXTURE_2D, 0 );

				if ( textureNeedsGenerateMipmaps( attachment ) ) {

					generateMipmap( _gl.TEXTURE_2D );

				}

			}

			state.unbindTexture();

		} else {

			var glTextureType = _gl.TEXTURE_2D;

			if ( renderTarget.isWebGL3DRenderTarget || renderTarget.isWebGLArrayRenderTarget ) {

				glTextureType = renderTarget.isWebGL3DRenderTarget ? _gl.TEXTURE_3D : _gl.TEXTURE_2D_ARRAY;

			}

			state.bindTexture( glTextureType, textureProperties.__webglTexture );
			setTextureParameters( glTextureType, texture );

			if ( texture.mipmaps && texture.mipmaps.length > 0 ) {

				for ( level in 0...texture.mipmaps.length ) {

					setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer[ level ], renderTarget, texture, _gl.COLOR_ATTACHMENT0, glTextureType, level );

				}

			} else {

				setupFrameBufferTexture( renderTargetProperties.__webglFramebuffer, renderTarget, texture, _gl.COLOR_ATTACHMENT0, glTextureType, 0 );

			}

			if ( textureNeedsGenerateMipmaps( texture ) ) {

				generateMipmap( glTextureType );

			}

			state.unbindTexture();

		}

		// Setup depth and stencil buffers

		if ( renderTarget.depthBuffer ) {

			setupDepthRenderbuffer( renderTarget );

		}

	}

	function updateRenderTargetMipmap( renderTarget ) {

		var textures = renderTarget.textures;

		for ( i in 0...textures.length ) {

			var texture = textures[ i ];

			if ( textureNeedsGenerateMipmaps( texture ) ) {

				var targetType = getTargetType( renderTarget );
				var webglTexture = properties.get( texture ).__webglTexture;

				state.bindTexture( targetType, webglTexture );
				generateMipmap( targetType );
				state.unbindTexture();

			}

		}

	}

	var invalidationArrayRead = [];
	var invalidationArrayDraw = [];

	function updateMultisampleRenderTarget( renderTarget ) {

		if ( renderTarget.samples > 0 ) {

			if ( useMultisampledRTT( renderTarget ) == false ) {

				var textures = renderTarget.textures;
				var width = renderTarget.width;
				var height = renderTarget.height;
				var mask = _gl.COLOR_BUFFER_BIT;
				var depthStyle = renderTarget.stencilBuffer ? _gl.DEPTH_STENCIL_ATTACHMENT : _gl.DEPTH_ATTACHMENT;
				var renderTargetProperties = properties.get( renderTarget );
				var isMultipleRenderTargets = ( textures.length > 1 );

				// If MRT we need to remove FBO attachments
				if ( isMultipleRenderTargets ) {

					for ( i in 0...textures.length ) {

						state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglMultisampledFramebuffer );
						_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0 + i, _gl.RENDERBUFFER, null );

						state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglFramebuffer );
						_gl.framebufferTexture2D( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0 + i, _gl.TEXTURE_2D, null, 0 );

					}

				}

				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, renderTargetProperties.__webglMultisampledFramebuffer );

				var mipmaps = renderTarget.texture.mipmaps;

				if ( mipmaps && mipmaps.length > 0 ) {

					state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, renderTargetProperties.__webglFramebuffer[ 0 ] );

				} else {

					state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, renderTargetProperties.__webglFramebuffer );

				}

				for ( i in 0...textures.length ) {

					if ( renderTarget.resolveDepthBuffer ) {

						if ( renderTarget.depthBuffer ) mask |= _gl.DEPTH_BUFFER_BIT;

						// resolving stencil is slow with a D3D backend. disable it for all transmission render targets (see #27799)

						if ( renderTarget.stencilBuffer && renderTarget.resolveStencilBuffer ) mask |= _gl.STENCIL_BUFFER_BIT;

					}

					if ( isMultipleRenderTargets ) {

						_gl.framebufferRenderbuffer( _gl.READ_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.RENDERBUFFER, renderTargetProperties.__webglColorRenderbuffer[ i ] );

						var webglTexture = properties.get( textures[ i ] ).__webglTexture;
						_gl.framebufferTexture2D( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, webglTexture, 0 );

					}

					_gl.blitFramebuffer( 0, 0, width, height, 0, 0, width, height, mask, _gl.NEAREST );

					if ( supportsInvalidateFramebuffer == true ) {

						invalidationArrayRead.length = 0;
						invalidationArrayDraw.length = 0;

						invalidationArrayRead.push( _gl.COLOR_ATTACHMENT0 + i );

						if ( renderTarget.depthBuffer && renderTarget.resolveDepthBuffer == false ) {

							invalidationArrayRead.push( depthStyle );
							invalidationArrayDraw.push( depthStyle );

							_gl.invalidateFramebuffer( _gl.DRAW_FRAMEBUFFER, invalidationArrayDraw );

						}

						_gl.invalidateFramebuffer( _gl.READ_FRAMEBUFFER, invalidationArrayRead );

					}

				}

				state.bindFramebuffer( _gl.READ_FRAMEBUFFER, null );
				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, null );

				// If MRT since pre-blit we removed the FBO we need to reconstruct the attachments
				if ( isMultipleRenderTargets ) {

					for ( i in 0...textures.length ) {

						state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglMultisampledFramebuffer );
						_gl.framebufferRenderbuffer( _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0 + i, _gl.RENDERBUFFER, renderTargetProperties.__webglColorRenderbuffer[ i ] );

						var webglTexture = properties.get( textures[ i ] ).__webglTexture;

						state.bindFramebuffer( _gl.FRAMEBUFFER, renderTargetProperties.__webglFramebuffer );
						_gl.framebufferTexture2D( _gl.DRAW_FRAMEBUFFER, _gl.COLOR_ATTACHMENT0 + i, _gl.TEXTURE_2D, webglTexture, 0 );

					}

				}

				state.bindFramebuffer( _gl.DRAW_FRAMEBUFFER, renderTargetProperties.__webglMultisampledFramebuffer );

			} else {

				if ( renderTarget.depthBuffer && renderTarget.resolveDepthBuffer == false && supportsInvalidateFramebuffer ) {

					var depthStyle = renderTarget.stencilBuffer ? _gl.DEPTH_STENCIL_ATTACHMENT : _gl.DEPTH_ATTACHMENT;

					_gl.invalidateFramebuffer( _gl.DRAW_FRAMEBUFFER, [ depthStyle ] );

				}

			}

		}

	}

	function getRenderTargetSamples( renderTarget ) {

		return Math.min( capabilities.maxSamples, renderTarget.samples );

	}

	function useMultisampledRTT( renderTarget ) {

		var renderTargetProperties = properties.get( renderTarget );

		return renderTarget.samples > 0 && extensions.has( 'WEBGL_multisampled_render_to_texture' ) == true && renderTargetProperties.__useRenderToTexture != false;

	}

	function updateVideoTexture( texture ) {

		var frame = info.render.frame;

		// Check the last frame we updated the VideoTexture

		if ( _videoTextures.get( texture ) != frame ) {

			_videoTextures.set( texture, frame );
			texture.update();

		}

	}

	function verifyColorSpace( texture, image ) {

		var colorSpace = texture.colorSpace;
		var format = texture.format;
		var type = texture.type;

		if ( texture.isCompressedTexture == true || texture.isVideoTexture == true ) return image;

		if ( colorSpace != LinearSRGBColorSpace && colorSpace != NoColorSpace ) {

			// sRGB

			if ( ColorManagement.getTransfer( colorSpace ) == SRGBTransfer ) {

				// in WebGL 2 uncompressed textures can only be sRGB encoded if they have the RGBA8 format

				if ( format != RGBAFormat || type != UnsignedByteType ) {

					console.warn( 'THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType.' );

				}

			} else {

				console.error( 'THREE.WebGLTextures: Unsupported texture color space:', colorSpace );

			}

		}

		return image;

	}

	function getDimensions( image ) {

		//TODO:
		/*if ( typeof HTMLImageElement != 'undefined' && image instanceof HTMLImageElement ) {

			// if intrinsic data are not available, fallback to width/height

			_imageDimensions.width = image.naturalWidth ?? image.width;
			_imageDimensions.height = image.naturalHeight ?? image.height;

		} else if ( typeof VideoFrame != 'undefined' && image instanceof VideoFrame ) {

			_imageDimensions.width = image.displayWidth;
			_imageDimensions.height = image.displayHeight;

		} else {

			_imageDimensions.width = image.width;
			_imageDimensions.height = image.height;

		}*/

		return _imageDimensions;

	}

}