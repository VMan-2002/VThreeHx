package vman2002.vthreehx.extras;

import vman2002.vthreehx.Constants;
import vman2002.vthreehx.textures.Texture;

/**
 * A class containing utility functions for textures.
 *
 * @hideconstructor
 */
class TextureUtils {

	static function getTextureTypeByteLength( type ):{byteLength:Int, components:Int} {
		if (type == Constants.UnsignedByteType || type == Constants.ByteType)
			return { byteLength: 1, components: 1 };
		if (type == Constants.UnsignedShortType || type == Constants.ShortType || type == Constants.HalfFloatType)
			return { byteLength: 2, components: 1 };
		if (type == Constants.UnsignedShort4444Type || type == Constants.UnsignedShort5551Type)
			return { byteLength: 2, components: 4 };
		if (type == Constants.UnsignedIntType || type == Constants.IntType || type == Constants.FloatType)
			return { byteLength: 4, components: 1 };
		if (type == Constants.UnsignedInt5999Type)
			return { byteLength: 4, components: 3 };


		throw ('Unknown texture type ${type}.' );
	}

	/**
	 * Scales the texture as large as possible within its surface without cropping
	 * or stretching the texture. The method preserves the original aspect ratio of
	 * the texture. Akin to CSS `object-fit: contain`
	 *
	 * @param {Texture} texture - The texture.
	 * @param {number} aspect - The texture's aspect ratio.
	 * @return {Texture} The updated texture.
	 */
	public static function contain( texture:Texture, aspect ) {
		var imageAspect = texture?.image.width != null ? texture.image.width / texture.image.height : 1;

		if ( imageAspect > aspect ) {

			texture.repeat.x = 1;
			texture.repeat.y = imageAspect / aspect;

			texture.offset.x = 0;
			texture.offset.y = ( 1 - texture.repeat.y ) / 2;

		} else {

			texture.repeat.x = aspect / imageAspect;
			texture.repeat.y = 1;

			texture.offset.x = ( 1 - texture.repeat.x ) / 2;
			texture.offset.y = 0;

		}

		return texture;
	}

	/**
	 * Scales the texture to the smallest possible size to fill the surface, leaving
	 * no empty space. The method preserves the original aspect ratio of the texture.
	 * Akin to CSS `object-fit: cover`.
	 *
	 * @param {Texture} texture - The texture.
	 * @param {number} aspect - The texture's aspect ratio.
	 * @return {Texture} The updated texture.
	 */
	public static function cover( texture:Texture, aspect:Float ) {

		var imageAspect = texture?.image.width != null ? texture.image.width / texture.image.height : 1;

		if ( imageAspect > aspect ) {

			texture.repeat.x = aspect / imageAspect;
			texture.repeat.y = 1;

			texture.offset.x = ( 1 - texture.repeat.x ) / 2;
			texture.offset.y = 0;

		} else {

			texture.repeat.x = 1;
			texture.repeat.y = imageAspect / aspect;

			texture.offset.x = 0;
			texture.offset.y = ( 1 - texture.repeat.y ) / 2;

		}

		return texture;

	}

	/**
	 * Configures the texture to the default transformation. Akin to CSS `object-fit: fill`.
	 *
	 * @param {Texture} texture - The texture.
	 * @return {Texture} The updated texture.
	 */
	public static function fill( texture:Texture ) {
		texture.repeat.x = 1;
		texture.repeat.y = 1;

		texture.offset.x = 0;
		texture.offset.y = 0;

		return texture;
	}

	/**
	 * Determines how many bytes must be used to represent the texture.
	 *
	 * @param {number} width - The width of the texture.
	 * @param {number} height - The height of the texture.
	 * @param {number} format - The texture's format.
	 * @param {number} type - The texture's type.
	 * @return {number} The byte length.
	 */
	public static function getByteLength( width, height, format, type ):Int {
		var typeByteLength = getTextureTypeByteLength( type );

		// https://registry.khronos.org/OpenGL-Refpages/es3.0/html/glTexImage2D.xhtml
		if (type == Constants.AlphaFormat)
			return width * height;
		if (type == Constants.RedFormat)
			return Std.int( ( width * height ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RedIntegerFormat)
			return Std.int( ( width * height ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RGFormat)
			return Std.int( ( width * height * 2 ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RGIntegerFormat)
			return Std.int( ( width * height * 2 ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RGBFormat)
			return Std.int( ( width * height * 3 ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RGBAFormat)
			return Std.int( ( width * height * 4 ) / typeByteLength.components ) * typeByteLength.byteLength;
		if (type == Constants.RGBAIntegerFormat)
			return Std.int( ( width * height * 4 ) / typeByteLength.components ) * typeByteLength.byteLength;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_s3tc_srgb/
		if (type == Constants.RGB_S3TC_DXT1_Format || type == Constants.RGBA_S3TC_DXT1_Format)
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 8;
		if (type == Constants.RGBA_S3TC_DXT3_Format || type == Constants.RGBA_S3TC_DXT5_Format)
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_pvrtc/
		if (type == Constants.RGB_PVRTC_2BPPV1_Format || type == Constants.RGBA_PVRTC_2BPPV1_Format)
			return Std.int(( Math.max( width, 16 ) * Math.max( height, 8 ) ) / 4);
		if (type == Constants.RGB_PVRTC_4BPPV1_Format || type == Constants.RGBA_PVRTC_4BPPV1_Format)
			return Std.int(( Math.max( width, 8 ) * Math.max( height, 8 ) ) / 2);

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_etc/
		if (type == Constants.RGB_ETC1_Format || type == Constants.RGB_ETC2_Format)
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 8;
		if (type == Constants.RGBA_ETC2_EAC_Format)
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_astc/
		if (type == Constants.RGBA_ASTC_4x4_Format)
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;
		if (type == Constants.RGBA_ASTC_5x4_Format)
			return Math.floor( ( width + 4 ) / 5 ) * Math.floor( ( height + 3 ) / 4 ) * 16;
		if (type == Constants.RGBA_ASTC_5x5_Format)
			return Math.floor( ( width + 4 ) / 5 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		if (type == Constants.RGBA_ASTC_6x5_Format)
			return Math.floor( ( width + 5 ) / 6 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		if (type == Constants.RGBA_ASTC_6x6_Format)
			return Math.floor( ( width + 5 ) / 6 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		if (type == Constants.RGBA_ASTC_8x5_Format)
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		if (type == Constants.RGBA_ASTC_8x6_Format)
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		if (type == Constants.RGBA_ASTC_8x8_Format)
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 7 ) / 8 ) * 16;
		if (type == Constants.RGBA_ASTC_10x5_Format)
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		if (type == Constants.RGBA_ASTC_10x6_Format)
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		if (type == Constants.RGBA_ASTC_10x8_Format)
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 7 ) / 8 ) * 16;
		if (type == Constants.RGBA_ASTC_10x10_Format)
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 9 ) / 10 ) * 16;
		if (type == Constants.RGBA_ASTC_12x10_Format)
			return Math.floor( ( width + 11 ) / 12 ) * Math.floor( ( height + 9 ) / 10 ) * 16;
		if (type == Constants.RGBA_ASTC_12x12_Format)
			return Math.floor( ( width + 11 ) / 12 ) * Math.floor( ( height + 11 ) / 12 ) * 16;

		// https://registry.khronos.org/webgl/extensions/EXT_texture_compression_bptc/
		if (type == Constants.RGBA_BPTC_Format || type == Constants.RGB_BPTC_SIGNED_Format || type == Constants.RGB_BPTC_UNSIGNED_Format)
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/EXT_texture_compression_rgtc/
		if (type == Constants.RED_RGTC1_Format || type == Constants.SIGNED_RED_RGTC1_Format)
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 8;
		if (type == Constants.RED_GREEN_RGTC2_Format || type == Constants.SIGNED_RED_GREEN_RGTC2_Format)
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 16;


		throw(
			'Unable to determine texture byte length for ${format} format.'
		);

	}

}