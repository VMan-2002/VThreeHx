package vman2002.vthreehx.extras;

import vman2002.vthreehx.Constants;

/**
 * Scales the texture as large as possible within its surface without cropping
 * or stretching the texture. The method preserves the original aspect ratio of
 * the texture. Akin to CSS `object-fit: contain`
 *
 * @param {Texture} texture - The texture.
 * @param {number} aspect - The texture's aspect ratio.
 * @return {Texture} The updated texture.
 */
function contain( texture, aspect ) {

	const imageAspect = ( texture.image && texture.image.width ) ? texture.image.width / texture.image.height : 1;

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
function cover( texture, aspect ) {

	const imageAspect = ( texture.image && texture.image.width ) ? texture.image.width / texture.image.height : 1;

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
function fill( texture ) {

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
function getByteLength( width, height, format, type ) {

	const typeByteLength = getTextureTypeByteLength( type );

	switch ( format ) {

		// https://registry.khronos.org/OpenGL-Refpages/es3.0/html/glTexImage2D.xhtml
		case Constants.AlphaFormat:
			return width * height;
		case Constants.RedFormat:
			return ( ( width * height ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RedIntegerFormat:
			return ( ( width * height ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RGFormat:
			return ( ( width * height * 2 ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RGIntegerFormat:
			return ( ( width * height * 2 ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RGBFormat:
			return ( ( width * height * 3 ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RGBAFormat:
			return ( ( width * height * 4 ) / typeByteLength.components ) * typeByteLength.byteLength;
		case Constants.RGBAIntegerFormat:
			return ( ( width * height * 4 ) / typeByteLength.components ) * typeByteLength.byteLength;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_s3tc_srgb/
		case Constants.RGB_S3TC_DXT1_Format:
		case Constants.RGBA_S3TC_DXT1_Format:
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 8;
		case Constants.RGBA_S3TC_DXT3_Format:
		case Constants.RGBA_S3TC_DXT5_Format:
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_pvrtc/
		case Constants.RGB_PVRTC_2BPPV1_Format:
		case Constants.RGBA_PVRTC_2BPPV1_Format:
			return ( Math.max( width, 16 ) * Math.max( height, 8 ) ) / 4;
		case Constants.RGB_PVRTC_4BPPV1_Format:
		case Constants.RGBA_PVRTC_4BPPV1_Format:
			return ( Math.max( width, 8 ) * Math.max( height, 8 ) ) / 2;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_etc/
		case Constants.RGB_ETC1_Format:
		case Constants.RGB_ETC2_Format:
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 8;
		case Constants.RGBA_ETC2_EAC_Format:
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/WEBGL_compressed_texture_astc/
		case Constants.RGBA_ASTC_4x4_Format:
			return Math.floor( ( width + 3 ) / 4 ) * Math.floor( ( height + 3 ) / 4 ) * 16;
		case Constants.RGBA_ASTC_5x4_Format:
			return Math.floor( ( width + 4 ) / 5 ) * Math.floor( ( height + 3 ) / 4 ) * 16;
		case Constants.RGBA_ASTC_5x5_Format:
			return Math.floor( ( width + 4 ) / 5 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		case Constants.RGBA_ASTC_6x5_Format:
			return Math.floor( ( width + 5 ) / 6 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		case Constants.RGBA_ASTC_6x6_Format:
			return Math.floor( ( width + 5 ) / 6 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		case Constants.RGBA_ASTC_8x5_Format:
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		case Constants.RGBA_ASTC_8x6_Format:
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		case Constants.RGBA_ASTC_8x8_Format:
			return Math.floor( ( width + 7 ) / 8 ) * Math.floor( ( height + 7 ) / 8 ) * 16;
		case Constants.RGBA_ASTC_10x5_Format:
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 4 ) / 5 ) * 16;
		case Constants.RGBA_ASTC_10x6_Format:
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 5 ) / 6 ) * 16;
		case Constants.RGBA_ASTC_10x8_Format:
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 7 ) / 8 ) * 16;
		case Constants.RGBA_ASTC_10x10_Format:
			return Math.floor( ( width + 9 ) / 10 ) * Math.floor( ( height + 9 ) / 10 ) * 16;
		case Constants.RGBA_ASTC_12x10_Format:
			return Math.floor( ( width + 11 ) / 12 ) * Math.floor( ( height + 9 ) / 10 ) * 16;
		case Constants.RGBA_ASTC_12x12_Format:
			return Math.floor( ( width + 11 ) / 12 ) * Math.floor( ( height + 11 ) / 12 ) * 16;

		// https://registry.khronos.org/webgl/extensions/EXT_texture_compression_bptc/
		case Constants.RGBA_BPTC_Format:
		case Constants.RGB_BPTC_SIGNED_Format:
		case Constants.RGB_BPTC_UNSIGNED_Format:
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 16;

		// https://registry.khronos.org/webgl/extensions/EXT_texture_compression_rgtc/
		case Constants.RED_RGTC1_Format:
		case Constants.SIGNED_RED_RGTC1_Format:
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 8;
		case Constants.RED_GREEN_RGTC2_Format:
		case Constants.SIGNED_RED_GREEN_RGTC2_Format:
			return Math.ceil( width / 4 ) * Math.ceil( height / 4 ) * 16;

	}

	throw(
		'Unable to determine texture byte length for ${format} format.',
	);

}

function getTextureTypeByteLength( type ) {

	switch ( type ) {

		case Constants.UnsignedByteType:
		case Constants.ByteType:
			return { byteLength: 1, components: 1 };
		case Constants.UnsignedShortType:
		case Constants.ShortType:
		case Constants.HalfFloatType:
			return { byteLength: 2, components: 1 };
		case Constants.UnsignedShort4444Type:
		case Constants.UnsignedShort5551Type:
			return { byteLength: 2, components: 4 };
		case Constants.UnsignedIntType:
		case Constants.IntType:
		case Constants.FloatType:
			return { byteLength: 4, components: 1 };
		case Constants.UnsignedInt5999Type:
			return { byteLength: 4, components: 3 };

	}

	throw ('Unknown texture type ${type}.' );

}

/**
 * A class containing utility functions for textures.
 *
 * @hideconstructor
 */
class TextureUtils {

	/**
	 * Scales the texture as large as possible within its surface without cropping
	 * or stretching the texture. The method preserves the original aspect ratio of
	 * the texture. Akin to CSS `object-fit: contain`
	 *
	 * @param {Texture} texture - The texture.
	 * @param {number} aspect - The texture's aspect ratio.
	 * @return {Texture} The updated texture.
	 */
	static contain( texture, aspect ) {

		return contain( texture, aspect );

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
	static cover( texture, aspect ) {

		return cover( texture, aspect );

	}

	/**
	 * Configures the texture to the default transformation. Akin to CSS `object-fit: fill`.
	 *
	 * @param {Texture} texture - The texture.
	 * @return {Texture} The updated texture.
	 */
	static fill( texture ) {

		return fill( texture );

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
	static getByteLength( width, height, format, type ) {

		return getByteLength( width, height, format, type );

	}

}