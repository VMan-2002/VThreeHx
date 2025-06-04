package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.Constants;
import vman2002.vthreehx.math.ColorManagement;

class WebGLUtils {
	//TODO: what type are these?
	var gl:GL;
	var extensions:Dynamic;

	public function new(gl, extensions) {
		this.gl = gl;
		this.extensions = extensions;
	}

	/**
		@param p `Int` (from `Constants`) or `String` (GL constant as a string)
	**/
	function convert( p:Dynamic, colorSpace:String ) {
		colorSpace = colorSpace ?? Constants.NoColorSpace;

		if ( p == Constants.UnsignedByteType ) return gl.UNSIGNED_BYTE;
		if ( p == Constants.UnsignedShort4444Type ) return gl.UNSIGNED_SHORT_4_4_4_4;
		if ( p == Constants.UnsignedShort5551Type ) return gl.UNSIGNED_SHORT_5_5_5_1;
		if ( p == Constants.UnsignedInt5999Type ) return gl.UNSIGNED_INT_5_9_9_9_REV;

		if ( p == Constants.ByteType ) return gl.BYTE;
		if ( p == Constants.ShortType ) return gl.SHORT;
		if ( p == Constants.UnsignedShortType ) return gl.UNSIGNED_SHORT;
		if ( p == Constants.IntType ) return gl.INT;
		if ( p == Constants.UnsignedIntType ) return gl.UNSIGNED_INT;
		if ( p == Constants.FloatType ) return gl.FLOAT;
		if ( p == Constants.HalfFloatType ) return gl.HALF_FLOAT;

		if ( p == Constants.AlphaFormat ) return gl.ALPHA;
		if ( p == Constants.RGBFormat ) return gl.RGB;
		if ( p == Constants.RGBAFormat ) return gl.RGBA;
		if ( p == Constants.DepthFormat ) return gl.DEPTH_COMPONENT;
		if ( p == Constants.DepthStencilFormat ) return gl.DEPTH_STENCIL;

		// WebGL2 formats.

		if ( p == Constants.RedFormat ) return gl.RED;
		if ( p == Constants.RedIntegerFormat ) return gl.RED_INTEGER;
		if ( p == Constants.RGFormat ) return gl.RG;
		if ( p == Constants.RGIntegerFormat ) return gl.RG_INTEGER;
		if ( p == Constants.RGBAIntegerFormat ) return gl.RGBA_INTEGER;

		// S3TC

		var extension;

		var transfer = ColorManagement.getTransfer( colorSpace );

		if ( p == Constants.RGB_S3TC_DXT1_Format || p == Constants.RGBA_S3TC_DXT1_Format || p == Constants.RGBA_S3TC_DXT3_Format || p == Constants.RGBA_S3TC_DXT5_Format ) {

			if ( transfer == Constants.SRGBTransfer ) {

				extension = extensions.get( 'WEBGL_compressed_texture_s3tc_srgb' );

				if ( extension != null ) {

					if ( p == Constants.RGB_S3TC_DXT1_Format ) return extension.COMPRESSED_SRGB_S3TC_DXT1_EXT;
					if ( p == Constants.RGBA_S3TC_DXT1_Format ) return extension.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;
					if ( p == Constants.RGBA_S3TC_DXT3_Format ) return extension.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;
					if ( p == Constants.RGBA_S3TC_DXT5_Format ) return extension.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT;

				} else {

					return null;

				}

			} else {

				extension = extensions.get( 'WEBGL_compressed_texture_s3tc' );

				if ( extension != null ) {

					if ( p == Constants.RGB_S3TC_DXT1_Format ) return extension.COMPRESSED_RGB_S3TC_DXT1_EXT;
					if ( p == Constants.RGBA_S3TC_DXT1_Format ) return extension.COMPRESSED_RGBA_S3TC_DXT1_EXT;
					if ( p == Constants.RGBA_S3TC_DXT3_Format ) return extension.COMPRESSED_RGBA_S3TC_DXT3_EXT;
					if ( p == Constants.RGBA_S3TC_DXT5_Format ) return extension.COMPRESSED_RGBA_S3TC_DXT5_EXT;

				} else {

					return null;

				}

			}

		}

		// PVRTC

		if ( p == Constants.RGB_PVRTC_4BPPV1_Format || p == Constants.RGB_PVRTC_2BPPV1_Format || p == Constants.RGBA_PVRTC_4BPPV1_Format || p == Constants.RGBA_PVRTC_2BPPV1_Format ) {

			extension = extensions.get( 'WEBGL_compressed_texture_pvrtc' );

			if ( extension != null ) {

				if ( p == Constants.RGB_PVRTC_4BPPV1_Format ) return extension.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
				if ( p == Constants.RGB_PVRTC_2BPPV1_Format ) return extension.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
				if ( p == Constants.RGBA_PVRTC_4BPPV1_Format ) return extension.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
				if ( p == Constants.RGBA_PVRTC_2BPPV1_Format ) return extension.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;

			} else {

				return null;

			}

		}

		// ETC

		if ( p == Constants.RGB_ETC1_Format || p == Constants.RGB_ETC2_Format || p == Constants.RGBA_ETC2_EAC_Format ) {

			extension = extensions.get( 'WEBGL_compressed_texture_etc' );

			if ( extension != null ) {

				if ( p == Constants.RGB_ETC1_Format || p == Constants.RGB_ETC2_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ETC2 : extension.COMPRESSED_RGB8_ETC2;
				if ( p == Constants.RGBA_ETC2_EAC_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC : extension.COMPRESSED_RGBA8_ETC2_EAC;

			} else {

				return null;

			}

		}

		// ASTC

		if ( p == Constants.RGBA_ASTC_4x4_Format || p == Constants.RGBA_ASTC_5x4_Format || p == Constants.RGBA_ASTC_5x5_Format ||
			p == Constants.RGBA_ASTC_6x5_Format || p == Constants.RGBA_ASTC_6x6_Format || p == Constants.RGBA_ASTC_8x5_Format ||
			p == Constants.RGBA_ASTC_8x6_Format || p == Constants.RGBA_ASTC_8x8_Format || p == Constants.RGBA_ASTC_10x5_Format ||
			p == Constants.RGBA_ASTC_10x6_Format || p == Constants.RGBA_ASTC_10x8_Format || p == Constants.RGBA_ASTC_10x10_Format ||
			p == Constants.RGBA_ASTC_12x10_Format || p == Constants.RGBA_ASTC_12x12_Format ) {

			extension = extensions.get( 'WEBGL_compressed_texture_astc' );

			if ( extension != null ) {

				if ( p == Constants.RGBA_ASTC_4x4_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR : extension.COMPRESSED_RGBA_ASTC_4x4_KHR;
				if ( p == Constants.RGBA_ASTC_5x4_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR : extension.COMPRESSED_RGBA_ASTC_5x4_KHR;
				if ( p == Constants.RGBA_ASTC_5x5_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR : extension.COMPRESSED_RGBA_ASTC_5x5_KHR;
				if ( p == Constants.RGBA_ASTC_6x5_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR : extension.COMPRESSED_RGBA_ASTC_6x5_KHR;
				if ( p == Constants.RGBA_ASTC_6x6_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR : extension.COMPRESSED_RGBA_ASTC_6x6_KHR;
				if ( p == Constants.RGBA_ASTC_8x5_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR : extension.COMPRESSED_RGBA_ASTC_8x5_KHR;
				if ( p == Constants.RGBA_ASTC_8x6_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR : extension.COMPRESSED_RGBA_ASTC_8x6_KHR;
				if ( p == Constants.RGBA_ASTC_8x8_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR : extension.COMPRESSED_RGBA_ASTC_8x8_KHR;
				if ( p == Constants.RGBA_ASTC_10x5_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR : extension.COMPRESSED_RGBA_ASTC_10x5_KHR;
				if ( p == Constants.RGBA_ASTC_10x6_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR : extension.COMPRESSED_RGBA_ASTC_10x6_KHR;
				if ( p == Constants.RGBA_ASTC_10x8_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR : extension.COMPRESSED_RGBA_ASTC_10x8_KHR;
				if ( p == Constants.RGBA_ASTC_10x10_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR : extension.COMPRESSED_RGBA_ASTC_10x10_KHR;
				if ( p == Constants.RGBA_ASTC_12x10_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR : extension.COMPRESSED_RGBA_ASTC_12x10_KHR;
				if ( p == Constants.RGBA_ASTC_12x12_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR : extension.COMPRESSED_RGBA_ASTC_12x12_KHR;

			} else {

				return null;

			}

		}

		// BPTC

		if ( p == Constants.RGBA_BPTC_Format || p == Constants.RGB_BPTC_SIGNED_Format || p == Constants.RGB_BPTC_UNSIGNED_Format ) {

			extension = extensions.get( 'EXT_texture_compression_bptc' );

			if ( extension != null ) {

				if ( p == Constants.RGBA_BPTC_Format ) return ( transfer == Constants.SRGBTransfer ) ? extension.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT : extension.COMPRESSED_RGBA_BPTC_UNORM_EXT;
				if ( p == Constants.RGB_BPTC_SIGNED_Format ) return extension.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;
				if ( p == Constants.RGB_BPTC_UNSIGNED_Format ) return extension.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT;

			} else {

				return null;

			}

		}

		// RGTC

		if ( p == Constants.RED_RGTC1_Format || p == Constants.SIGNED_RED_RGTC1_Format || p == Constants.RED_GREEN_RGTC2_Format || p == Constants.SIGNED_RED_GREEN_RGTC2_Format ) {

			extension = extensions.get( 'EXT_texture_compression_rgtc' );

			if ( extension != null ) {

				if ( p == Constants.RGBA_BPTC_Format ) return extension.COMPRESSED_RED_RGTC1_EXT;
				if ( p == Constants.SIGNED_RED_RGTC1_Format ) return extension.COMPRESSED_SIGNED_RED_RGTC1_EXT;
				if ( p == Constants.RED_GREEN_RGTC2_Format ) return extension.COMPRESSED_RED_GREEN_RGTC2_EXT;
				if ( p == Constants.SIGNED_RED_GREEN_RGTC2_Format ) return extension.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT;

			} else {

				return null;

			}

		}

		//

		if ( p == Constants.UnsignedInt248Type ) return gl.UNSIGNED_INT_24_8;

		// if "p" can't be resolved, assume the user defines a WebGL constant as a string (fallback/workaround for packed RGB formats)

		return Reflect.field(gl, p) ?? null;

	}

}