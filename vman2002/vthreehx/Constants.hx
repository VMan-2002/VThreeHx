package vman2002.vthreehx;

class Constants {
    public static var REVISION = 176;

    /** Represents mouse buttons and interaction types in context of controls. **/
    public static var MOUSE = { LEFT: 0, MIDDLE: 1, RIGHT: 2, ROTATE: 0, DOLLY: 1, PAN: 2 };
    /** Represents touch interaction types in context of controls. **/
    public static var TOUCH = { ROTATE: 0, PAN: 1, DOLLY_PAN: 2, DOLLY_ROTATE: 3 };

    /** Disables face culling. **/
    public static var CullFaceNone = 0;
    /** Culls back faces. **/
    public static var CullFaceBack = 1;
    /** Culls front faces. **/
    public static var CullFaceFront = 2;
    /** Culls both front and back faces. **/
    public static var CullFaceFrontBack = 3;

    /** Gives unfiltered shadow maps - fastest, but lowest quality. **/
    public static var BasicShadowMap = 0;
    /** Filters shadow maps using the Percentage-Closer Filtering (PCF) algorithm. **/
    public static var PCFShadowMap = 1;
    /** Filters shadow maps using the Percentage-Closer Filtering (PCF) algorithm with better soft shadows especially when using low-resolution shadow maps. **/
    public static var PCFSoftShadowMap = 2;
    /** Filters shadow maps using the Variance Shadow Map (VSM) algorithm. When using VSMShadowMap all shadow receivers will also cast shadows. **/
    public static var VSMShadowMap = 3;

    /** Only front faces are rendered. **/
    public static var FrontSide = 0;
    /** Only back faces are rendered. **/
    public static var BackSide = 1;
    /** Both front and back faces are rendered. **/
    public static var DoubleSide = 2;

    /** No blending is performed which effectively disables alpha transparency. **/
    public static var NoBlending = 0;
    /** The default blending. **/
    public static var NormalBlending = 1;
    /** Represents additive blending. **/
    public static var AdditiveBlending = 2;
    /** Represents subtractive blending. **/
    public static var SubtractiveBlending = 3;
    /** Represents multiply blending. **/
    public static var MultiplyBlending = 4;
    /** Represents custom blending. **/
    public static var CustomBlending = 5;
    /** A `source + destination` blending equation. **/
    public static var AddEquation = 100;
    /** A `source - destination` blending equation. **/
    public static var SubtractEquation = 101;
    /** A `destination - source` blending equation. **/
    public static var ReverseSubtractEquation = 102;
    /** A blend equation that uses the minimum of source and destination. **/
    public static var MinEquation = 103;
    /** A blend equation that uses the maximum of source and destination. **/
    public static var MaxEquation = 104;

    /** Multiplies all colors by `0`. **/
    public static var ZeroFactor = 200;
    /** Multiplies all colors by `1`. **/
    public static var OneFactor = 201;
    /** Multiplies all colors by the source colors. **/
    public static var SrcColorFactor = 202;
    /** Multiplies all colors by `1` minus each source color. **/
    public static var OneMinusSrcColorFactor = 203;
    /** Multiplies all colors by the source alpha value. **/
    public static var SrcAlphaFactor = 204;
    /** Multiplies all colors by 1 minus the source alpha value. **/
    public static var OneMinusSrcAlphaFactor = 205;
    /** Multiplies all colors by the destination alpha value. **/
    public static var DstAlphaFactor = 206;
    /** Multiplies all colors by `1` minus the destination alpha value. **/
    public static var OneMinusDstAlphaFactor = 207;
    /** Multiplies all colors by the destination color. **/
    public static var DstColorFactor = 208;
    /** Multiplies all colors by `1` minus each destination color. **/
    public static var OneMinusDstColorFactor = 209;
    /** Multiplies the RGB colors by the smaller of either the source alpha value or the value of `1` minus the destination alpha value. The alpha value is multiplied by `1`. **/
    public static var SrcAlphaSaturateFactor = 210;
    /** Multiplies all colors by a constant color. **/
    public static var ConstantColorFactor = 211;
    /** Multiplies all colors by `1` minus a constant color. **/
    public static var OneMinusConstantColorFactor = 212;
    /** Multiplies all colors by a constant alpha value. **/
    public static var ConstantAlphaFactor = 213;
    /** Multiplies all colors by 1 minus a constant alpha value. **/
    public static var OneMinusConstantAlphaFactor = 214;

    /** Never pass. **/
    public static var NeverDepth = 0;
    /** Always pass. **/
    public static var AlwaysDepth = 1;
    /** Pass if the incoming value is less than the depth buffer value. **/
    public static var LessDepth = 2;
    /** Pass if the incoming value is less than or equal to the depth buffer value. **/
    public static var LessEqualDepth = 3;
    /** Pass if the incoming value equals the depth buffer value. **/
    public static var EqualDepth = 4;
    /** Pass if the incoming value is greater than or equal to the depth buffer value. **/
    public static var GreaterEqualDepth = 5;
    /** Pass if the incoming value is greater than the depth buffer value. **/
    public static var GreaterDepth = 6;
    /** Pass if the incoming value is not equal to the depth buffer value. **/
    public static var NotEqualDepth = 7;

    /** Multiplies the environment map color with the surface color. **/
    public static var MultiplyOperation = 0;
    /** Uses reflectivity to blend between the two colors. **/
    public static var MixOperation = 1;
    /** Adds the two colors. **/
    public static var AddOperation = 2;

    /** No tone mapping is applied. **/
    public static var NoToneMapping = 0;
    /** Linear tone mapping. **/
    public static var LinearToneMapping = 1;
    /** Reinhard tone mapping. **/
    public static var ReinhardToneMapping = 2;
    /** Cineon tone mapping. **/
    public static var CineonToneMapping = 3;
    /** ACES Filmic tone mapping. **/
    public static var ACESFilmicToneMapping = 4;
    /** Custom tone mapping. Expects a custom implementation by modifying shader code of the material's fragment shader. **/
    public static var CustomToneMapping = 5;
    /** AgX tone mapping. **/
    public static var AgXToneMapping = 6;
    /** Neutral tone mapping. Implementation based on the Khronos 3D Commerce Group standard tone mapping. **/
    public static var NeutralToneMapping = 7;

/**
 * The skinned mesh shares the same world space as the skeleton.
 *
 * @type {string}
 * @constant
 */
public static var AttachedBindMode = 'attached';

/**
 * The skinned mesh does not share the same world space as the skeleton.
 * This is useful when a skeleton is shared across multiple skinned meshes.
 *
 * @type {string}
 * @constant
 */
public static var DetachedBindMode = 'detached';

/**
 * Maps textures using the geometry's UV coordinates.
 *
 * @type {number}
 * @constant
 */
public static var UVMapping = 300;

/**
 * Reflection mapping for cube textures.
 *
 * @type {number}
 * @constant
 */
public static var CubeReflectionMapping = 301;

/**
 * Refraction mapping for cube textures.
 *
 * @type {number}
 * @constant
 */
public static var CubeRefractionMapping = 302;

/**
 * Reflection mapping for equirectangular textures.
 *
 * @type {number}
 * @constant
 */
public static var EquirectangularReflectionMapping = 303;

/**
 * Refraction mapping for equirectangular textures.
 *
 * @type {number}
 * @constant
 */
public static var EquirectangularRefractionMapping = 304;

/**
 * Reflection mapping for PMREM textures.
 *
 * @type {number}
 * @constant
 */
public static var CubeUVReflectionMapping = 306;

/**
 * The texture will simply repeat to infinity.
 *
 * @type {number}
 * @constant
 */
public static var RepeatWrapping = 1000;

/**
 * The last pixel of the texture stretches to the edge of the mesh.
 *
 * @type {number}
 * @constant
 */
public static var ClampToEdgeWrapping = 1001;

/**
 * The texture will repeats to infinity, mirroring on each repeat.
 *
 * @type {number}
 * @constant
 */
public static var MirroredRepeatWrapping = 1002;

/**
 * Returns the value of the texture element that is nearest (in Manhattan distance)
 * to the specified texture coordinates.
 *
 * @type {number}
 * @constant
 */
public static var NearestFilter = 1003;

/**
 * Chooses the mipmap that most closely matches the size of the pixel being textured
 * and uses the `NearestFilter` criterion (the texel nearest to the center of the pixel)
 * to produce a texture value.
 *
 * @type {number}
 * @constant
 */
public static var NearestMipmapNearestFilter = 1004;
public static var NearestMipMapNearestFilter = 1004; // legacy

/**
 * Chooses the two mipmaps that most closely match the size of the pixel being textured and
 * uses the `NearestFilter` criterion to produce a texture value from each mipmap.
 * The final texture value is a weighted average of those two values.
 *
 * @type {number}
 * @constant
 */
public static var NearestMipmapLinearFilter = 1005;
public static var NearestMipMapLinearFilter = 1005; // legacy

/**
 * Returns the weighted average of the four texture elements that are closest to the specified
 * texture coordinates, and can include items wrapped or repeated from other parts of a texture,
 * depending on the values of `wrapS` and `wrapT`, and on the exact mapping.
 *
 * @type {number}
 * @constant
 */
public static var LinearFilter = 1006;

/**
 * Chooses the mipmap that most closely matches the size of the pixel being textured and uses
 * the `LinearFilter` criterion (a weighted average of the four texels that are closest to the
 * center of the pixel) to produce a texture value.
 *
 * @type {number}
 * @constant
 */
public static var LinearMipmapNearestFilter = 1007;
public static var LinearMipMapNearestFilter = 1007; // legacy

/**
 * Chooses the two mipmaps that most closely match the size of the pixel being textured and uses
 * the `LinearFilter` criterion to produce a texture value from each mipmap. The final texture value
 * is a weighted average of those two values.
 *
 * @type {number}
 * @constant
 */
public static var LinearMipmapLinearFilter = 1008;
public static var LinearMipMapLinearFilter = 1008; // legacy

/**
 * An unsigned byte data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedByteType = 1009;

/**
 * A byte data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var ByteType = 1010;

/**
 * A short data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var ShortType = 1011;

/**
 * An unsigned short data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedShortType = 1012;

/**
 * An int data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var IntType = 1013;

/**
 * An unsigned int data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedIntType = 1014;

/**
 * A float data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var FloatType = 1015;

/**
 * A half float data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var HalfFloatType = 1016;

/**
 * An unsigned short 4_4_4_4 (packed) data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedShort4444Type = 1017;

/**
 * An unsigned short 5_5_5_1 (packed) data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedShort5551Type = 1018;

/**
 * An unsigned int 24_8 data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedInt248Type = 1020;

/**
 * An unsigned int 5_9_9_9 (packed) data type for textures.
 *
 * @type {number}
 * @constant
 */
public static var UnsignedInt5999Type = 35902;

/**
 * Discards the red, green and blue components and reads just the alpha component.
 *
 * @type {number}
 * @constant
 */
public static var AlphaFormat = 1021;

/**
 * Discards the alpha component and reads the red, green and blue component.
 *
 * @type {number}
 * @constant
 */
public static var RGBFormat = 1022;

/**
 * Reads the red, green, blue and alpha components.
 *
 * @type {number}
 * @constant
 */
public static var RGBAFormat = 1023;

/**
 * Reads each element as a single depth value, converts it to floating point, and clamps to the range `[0,1]`.
 *
 * @type {number}
 * @constant
 */
public static var DepthFormat = 1026;

/**
 * Reads each element is a pair of depth and stencil values. The depth component of the pair is interpreted as
 * in `DepthFormat`. The stencil component is interpreted based on the depth + stencil internal format.
 *
 * @type {number}
 * @constant
 */
public static var DepthStencilFormat = 1027;

/**
 * Discards the green, blue and alpha components and reads just the red component.
 *
 * @type {number}
 * @constant
 */
public static var RedFormat = 1028;

/**
 * Discards the green, blue and alpha components and reads just the red component. The texels are read as integers instead of floating point.
 *
 * @type {number}
 * @constant
 */
public static var RedIntegerFormat = 1029;

/**
 * Discards the alpha, and blue components and reads the red, and green components.
 *
 * @type {number}
 * @constant
 */
public static var RGFormat = 1030;

/**
 * Discards the alpha, and blue components and reads the red, and green components. The texels are read as integers instead of floating point.
 *
 * @type {number}
 * @constant
 */
public static var RGIntegerFormat = 1031;

/**
 * Discards the alpha component and reads the red, green and blue component. The texels are read as integers instead of floating point.
 *
 * @type {number}
 * @constant
 */
public static var RGBIntegerFormat = 1032;

/**
 * Reads the red, green, blue and alpha components. The texels are read as integers instead of floating point.
 *
 * @type {number}
 * @constant
 */
public static var RGBAIntegerFormat = 1033;

/**
 * A DXT1-compressed image in an RGB image format.
 *
 * @type {number}
 * @constant
 */
public static var RGB_S3TC_DXT1_Format = 33776;

/**
 * A DXT1-compressed image in an RGB image format with a simple on/off alpha value.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_S3TC_DXT1_Format = 33777;

/**
 * A DXT3-compressed image in an RGBA image format. Compared to a 32-bit RGBA texture, it offers 4:1 compression.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_S3TC_DXT3_Format = 33778;

/**
 * A DXT5-compressed image in an RGBA image format. It also provides a 4:1 compression, but differs to the DXT3
 * compression in how the alpha compression is done.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_S3TC_DXT5_Format = 33779;

/**
 * PVRTC RGB compression in 4-bit mode. One block for each 4×4 pixels.
 *
 * @type {number}
 * @constant
 */
public static var RGB_PVRTC_4BPPV1_Format = 35840;

/**
 * PVRTC RGB compression in 2-bit mode. One block for each 8×4 pixels.
 *
 * @type {number}
 * @constant
 */
public static var RGB_PVRTC_2BPPV1_Format = 35841;

/**
 * PVRTC RGBA compression in 4-bit mode. One block for each 4×4 pixels.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_PVRTC_4BPPV1_Format = 35842;

/**
 * PVRTC RGBA compression in 2-bit mode. One block for each 8×4 pixels.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_PVRTC_2BPPV1_Format = 35843;

/**
 * ETC1 RGB format.
 *
 * @type {number}
 * @constant
 */
public static var RGB_ETC1_Format = 36196;

/**
 * ETC2 RGB format.
 *
 * @type {number}
 * @constant
 */
public static var RGB_ETC2_Format = 37492;

/**
 * ETC2 RGBA format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ETC2_EAC_Format = 37496;

/**
 * ASTC RGBA 4x4 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_4x4_Format = 37808;

/**
 * ASTC RGBA 5x4 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_5x4_Format = 37809;

/**
 * ASTC RGBA 5x5 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_5x5_Format = 37810;

/**
 * ASTC RGBA 6x5 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_6x5_Format = 37811;

/**
 * ASTC RGBA 6x6 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_6x6_Format = 37812;

/**
 * ASTC RGBA 8x5 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_8x5_Format = 37813;

/**
 * ASTC RGBA 8x6 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_8x6_Format = 37814;

/**
 * ASTC RGBA 8x8 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_8x8_Format = 37815;

/**
 * ASTC RGBA 10x5 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_10x5_Format = 37816;

/**
 * ASTC RGBA 10x6 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_10x6_Format = 37817;

/**
 * ASTC RGBA 10x8 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_10x8_Format = 37818;

/**
 * ASTC RGBA 10x10 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_10x10_Format = 37819;

/**
 * ASTC RGBA 12x10 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_12x10_Format = 37820;

/**
 * ASTC RGBA 12x12 format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_ASTC_12x12_Format = 37821;

/**
 * BPTC RGBA format.
 *
 * @type {number}
 * @constant
 */
public static var RGBA_BPTC_Format = 36492;

/**
 * BPTC Signed RGB format.
 *
 * @type {number}
 * @constant
 */
public static var RGB_BPTC_SIGNED_Format = 36494;

/**
 * BPTC Unsigned RGB format.
 *
 * @type {number}
 * @constant
 */
public static var RGB_BPTC_UNSIGNED_Format = 36495;

/**
 * RGTC1 Red format.
 *
 * @type {number}
 * @constant
 */
public static var RED_RGTC1_Format = 36283;

/**
 * RGTC1 Signed Red format.
 *
 * @type {number}
 * @constant
 */
public static var SIGNED_RED_RGTC1_Format = 36284;

/**
 * RGTC2 Red Green format.
 *
 * @type {number}
 * @constant
 */
public static var RED_GREEN_RGTC2_Format = 36285;

/**
 * RGTC2 Signed Red Green format.
 *
 * @type {number}
 * @constant
 */
public static var SIGNED_RED_GREEN_RGTC2_Format = 36286;

/**
 * Animations are played once.
 *
 * @type {number}
 * @constant
 */
public static var LoopOnce = 2200;

/**
 * Animations are played with a chosen number of repetitions, each time jumping from
 * the end of the clip directly to its beginning.
 *
 * @type {number}
 * @constant
 */
public static var LoopRepeat = 2201;

/**
 * Animations are played with a chosen number of repetitions, alternately playing forward
 * and backward.
 *
 * @type {number}
 * @constant
 */
public static var LoopPingPong = 2202;

/**
 * Discrete interpolation mode for keyframe tracks.
 *
 * @type {number}
 * @constant
 */
public static var InterpolateDiscrete = 2300;

/**
 * Linear interpolation mode for keyframe tracks.
 *
 * @type {number}
 * @constant
 */
public static var InterpolateLinear = 2301;

/**
 * Smooth interpolation mode for keyframe tracks.
 *
 * @type {number}
 * @constant
 */
public static var InterpolateSmooth = 2302;

/**
 * Zero curvature ending for animations.
 *
 * @type {number}
 * @constant
 */
public static var ZeroCurvatureEnding = 2400;

/**
 * Zero slope ending for animations.
 *
 * @type {number}
 * @constant
 */
public static var ZeroSlopeEnding = 2401;

/**
 * Wrap around ending for animations.
 *
 * @type {number}
 * @constant
 */
public static var WrapAroundEnding = 2402;

/**
 * Default animation blend mode.
 *
 * @type {number}
 * @constant
 */
public static var NormalAnimationBlendMode = 2500;

/**
 * Additive animation blend mode. Can be used to layer motions on top of
 * each other to build complex performances from smaller re-usable assets.
 *
 * @type {number}
 * @constant
 */
public static var AdditiveAnimationBlendMode = 2501;

/**
 * For every three vertices draw a single triangle.
 *
 * @type {number}
 * @constant
 */
public static var TrianglesDrawMode = 0;

/**
 * For each vertex draw a triangle from the last three vertices.
 *
 * @type {number}
 * @constant
 */
public static var TriangleStripDrawMode = 1;

/**
 * For each vertex draw a triangle from the first vertex and the last two vertices.
 *
 * @type {number}
 * @constant
 */
public static var TriangleFanDrawMode = 2;

/**
 * Basic depth packing.
 *
 * @type {number}
 * @constant
 */
public static var BasicDepthPacking = 3200;

/**
 * A depth value is packed into 32 bit RGBA.
 *
 * @type {number}
 * @constant
 */
public static var RGBADepthPacking = 3201;

/**
 * A depth value is packed into 24 bit RGB.
 *
 * @type {number}
 * @constant
 */
public static var RGBDepthPacking = 3202;

/**
 * A depth value is packed into 16 bit RG.
 *
 * @type {number}
 * @constant
 */
public static var RGDepthPacking = 3203;

/**
 * Normal information is relative to the underlying surface.
 *
 * @type {number}
 * @constant
 */
public static var TangentSpaceNormalMap = 0;

/**
 * Normal information is relative to the object orientation.
 *
 * @type {number}
 * @constant
 */
public static var ObjectSpaceNormalMap = 1;

// Color space string identifiers, matching CSS Color Module Level 4 and WebGPU names where available.

/**
 * No color space.
 *
 * @type {string}
 * @constant
 */
public static var NoColorSpace = '';

/**
 * sRGB color space.
 *
 * @type {string}
 * @constant
 */
public static var SRGBColorSpace = 'srgb';

/**
 * sRGB-linear color space.
 *
 * @type {string}
 * @constant
 */
public static var LinearSRGBColorSpace = 'srgb-linear';

/**
 * Linear transfer function.
 *
 * @type {string}
 * @constant
 */
public static var LinearTransfer = 'linear';

/**
 * sRGB transfer function.
 *
 * @type {string}
 * @constant
 */
public static var SRGBTransfer = 'srgb';

/**
 * Sets the stencil buffer value to `0`.
 *
 * @type {number}
 * @constant
 */
public static var ZeroStencilOp = 0;

/**
 * Keeps the current value.
 *
 * @type {number}
 * @constant
 */
public static var KeepStencilOp = 7680;

/**
 * Sets the stencil buffer value to the specified reference value.
 *
 * @type {number}
 * @constant
 */
public static var ReplaceStencilOp = 7681;

/**
 * Increments the current stencil buffer value. Clamps to the maximum representable unsigned value.
 *
 * @type {number}
 * @constant
 */
public static var IncrementStencilOp = 7682;

/**
 * Decrements the current stencil buffer value. Clamps to `0`.
 *
 * @type {number}
 * @constant
 */
public static var DecrementStencilOp = 7683;

/**
 * Increments the current stencil buffer value. Wraps stencil buffer value to zero when incrementing
 * the maximum representable unsigned value.
 *
 * @type {number}
 * @constant
 */
public static var IncrementWrapStencilOp = 34055;

/**
 * Decrements the current stencil buffer value. Wraps stencil buffer value to the maximum representable
 * unsigned value when decrementing a stencil buffer value of `0`.
 *
 * @type {number}
 * @constant
 */
public static var DecrementWrapStencilOp = 34056;

/**
 * Inverts the current stencil buffer value bitwise.
 *
 * @type {number}
 * @constant
 */
public static var InvertStencilOp = 5386;

/**
 * Will never return true.
 *
 * @type {number}
 * @constant
 */
public static var NeverStencilFunc = 512;

/**
 * Will return true if the stencil reference value is less than the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var LessStencilFunc = 513;

/**
 * Will return true if the stencil reference value is equal to the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var EqualStencilFunc = 514;

/**
 * Will return true if the stencil reference value is less than or equal to the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var LessEqualStencilFunc = 515;

/**
 * Will return true if the stencil reference value is greater than the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var GreaterStencilFunc = 516;

/**
 * Will return true if the stencil reference value is not equal to the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var NotEqualStencilFunc = 517;

/**
 * Will return true if the stencil reference value is greater than or equal to the current stencil value.
 *
 * @type {number}
 * @constant
 */
public static var GreaterEqualStencilFunc = 518;

/**
 * Will always return true.
 *
 * @type {number}
 * @constant
 */
public static var AlwaysStencilFunc = 519;

/**
 * Never pass.
 *
 * @type {number}
 * @constant
 */
public static var NeverCompare = 512;

/**
 * Pass if the incoming value is less than the texture value.
 *
 * @type {number}
 * @constant
 */
public static var LessCompare = 513;

/**
 * Pass if the incoming value equals the texture value.
 *
 * @type {number}
 * @constant
 */
public static var EqualCompare = 514;

/**
 * Pass if the incoming value is less than or equal to the texture value.
 *
 * @type {number}
 * @constant
 */
public static var LessEqualCompare = 515;

/**
 * Pass if the incoming value is greater than the texture value.
 *
 * @type {number}
 * @constant
 */
public static var GreaterCompare = 516;

/**
 * Pass if the incoming value is not equal to the texture value.
 *
 * @type {number}
 * @constant
 */
public static var NotEqualCompare = 517;

/**
 * Pass if the incoming value is greater than or equal to the texture value.
 *
 * @type {number}
 * @constant
 */
public static var GreaterEqualCompare = 518;

/**
 * Always pass.
 *
 * @type {number}
 * @constant
 */
public static var AlwaysCompare = 519;

/**
 * The contents are intended to be specified once by the application, and used many
 * times as the source for drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var StaticDrawUsage = 35044;

/**
 * The contents are intended to be respecified repeatedly by the application, and
 * used many times as the source for drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var DynamicDrawUsage = 35048;

/**
 * The contents are intended to be specified once by the application, and used at most
 * a few times as the source for drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var StreamDrawUsage = 35040;

/**
 * The contents are intended to be specified once by reading data from the 3D API, and queried
 * many times by the application.
 *
 * @type {number}
 * @constant
 */
public static var StaticReadUsage = 35045;

/**
 * The contents are intended to be respecified repeatedly by reading data from the 3D API, and queried
 * many times by the application.
 *
 * @type {number}
 * @constant
 */
public static var DynamicReadUsage = 35049;

/**
 * The contents are intended to be specified once by reading data from the 3D API, and queried at most
 * a few times by the application
 *
 * @type {number}
 * @constant
 */
public static var StreamReadUsage = 35041;

/**
 * The contents are intended to be specified once by reading data from the 3D API, and used many times as
 * the source for WebGL drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var StaticCopyUsage = 35046;

/**
 * The contents are intended to be respecified repeatedly by reading data from the 3D API, and used many times
 * as the source for WebGL drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var DynamicCopyUsage = 35050;

/**
 * The contents are intended to be specified once by reading data from the 3D API, and used at most a few times
 * as the source for WebGL drawing and image specification commands.
 *
 * @type {number}
 * @constant
 */
public static var StreamCopyUsage = 35042;

/**
 * GLSL 1 shader code.
 *
 * @type {string}
 * @constant
 */
public static var GLSL1 = '100';

/**
 * GLSL 3 shader code.
 *
 * @type {string}
 * @constant
 */
public static var GLSL3 = '300 es';

/**
 * WebGL coordinate system.
 *
 * @type {number}
 * @constant
 */
public static var WebGLCoordinateSystem = 2000;

/**
 * WebGPU coordinate system.
 *
 * @type {number}
 * @constant
 */
public static var WebGPUCoordinateSystem = 2001;

/**
 * Represents the different timestamp query types.
 *
 * @type {ConstantsTimestampQuery}
 * @constant
 */
public static var TimestampQuery = {
	COMPUTE: 'compute',
	RENDER: 'render'
};

/**
 * Represents mouse buttons and interaction types in context of controls.
 *
 * @type {ConstantsInterpolationSamplingType}
 * @constant
 */
public static var InterpolationSamplingType = {
	PERSPECTIVE: 'perspective',
	LINEAR: 'linear',
	FLAT: 'flat'
};

/**
 * Represents the different interpolation sampling modes.
 *
 * @type {ConstantsInterpolationSamplingMode}
 * @constant
 */
public static var InterpolationSamplingMode = {
	NORMAL: 'normal',
	CENTROID: 'centroid',
	SAMPLE: 'sample',
	FLAT_FIRST: 'flat first',
	FLAT_EITHER: 'flat either'
};

/**
 * This type represents mouse buttons and interaction types in context of controls.
 *
 * @typedef {Object} ConstantsMouse
 * @property {number} MIDDLE - The left mouse button.
 * @property {number} LEFT - The middle mouse button.
 * @property {number} RIGHT - The right mouse button.
 * @property {number} ROTATE - A rotate interaction.
 * @property {number} DOLLY - A dolly interaction.
 * @property {number} PAN - A pan interaction.
 **/

/**
 * This type represents touch interaction types in context of controls.
 *
 * @typedef {Object} ConstantsTouch
 * @property {number} ROTATE - A rotate interaction.
 * @property {number} PAN - A pan interaction.
 * @property {number} DOLLY_PAN - The dolly-pan interaction.
 * @property {number} DOLLY_ROTATE - A dolly-rotate interaction.
 **/

/**
 * This type represents the different timestamp query types.
 *
 * @typedef {Object} ConstantsTimestampQuery
 * @property {string} COMPUTE - A `compute` timestamp query.
 * @property {string} RENDER - A `render` timestamp query.
 **/

/**
 * Represents the different interpolation sampling types.
 *
 * @typedef {Object} ConstantsInterpolationSamplingType
 * @property {string} PERSPECTIVE - Perspective-correct interpolation.
 * @property {string} LINEAR - Linear interpolation.
 * @property {string} FLAT - Flat interpolation.
 */

/**
 * Represents the different interpolation sampling modes.
 *
 * @typedef {Object} ConstantsInterpolationSamplingMode
 * @property {string} NORMAL - Normal sampling mode.
 * @property {string} CENTROID - Centroid sampling mode.
 * @property {string} SAMPLE - Sample-specific sampling mode.
 * @property {string} FLAT_FIRST - Flat interpolation using the first vertex.
 * @property {string} FLAT_EITHER - Flat interpolation using either vertex.
 */
}

