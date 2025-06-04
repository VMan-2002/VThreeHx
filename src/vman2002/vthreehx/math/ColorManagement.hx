package vman2002.vthreehx.math;

import vman2002.vthreehx.Constants.SRGBColorSpace in SRGBColorSpace;
import vman2002.vthreehx.Constants.LinearSRGBColorSpace in LinearSRGBColorSpace;
import vman2002.vthreehx.Constants.SRGBTransfer in SRGBTransfer;
import vman2002.vthreehx.Constants.LinearTransfer in LinearTransfer;
import vman2002.vthreehx.Constants.NoColorSpace in NoColorSpace;
import vman2002.vthreehx.math.Matrix3;
import vman2002.vthreehx.math.Color;

typedef ColorSpace = {
    primaries:Array<Float>,
    whitePoint:Array<Float>,
    transfer:String,
    toXYZ:Matrix3,
    fromXYZ:Matrix3,
    luminanceCoefficients: Array<Float>,
    ?outputColorSpaceConfig: {drawingBufferColorSpace:String},
    ?workingColorSpaceConfig: {unpackColorSpace:String}
}

class ColorManagement {
    public static var LINEAR_REC709_TO_XYZ = new Matrix3().set(
        0.4123908, 0.3575843, 0.1804808,
        0.2126390, 0.7151687, 0.0721923,
        0.0193308, 0.1191948, 0.9505322
    );

    public static var XYZ_TO_LINEAR_REC709 = /*@__PURE__*/ new Matrix3().set(
        3.2409699, - 1.5373832, - 0.4986108,
        - 0.9692436, 1.8759675, 0.0415551,
        0.0556301, - 0.2039770, 1.0569715
    );

    public static function SRGBToLinear( c ) {
        return ( c < 0.04045 ) ? c * 0.0773993808 : Math.pow( c * 0.9478672986 + 0.0521327014, 2.4 );
    }

    public static function LinearToSRGB( c ) {
        return ( c < 0.0031308 ) ? c * 12.92 : 1.055 * ( Math.pow( c, 0.41666 ) ) - 0.055;
    }

    public static var enabled = true;
    public static var workingColorSpace = LinearSRGBColorSpace;

    /**
    * Implementations of supported color spaces.
    *
    * Required:
    *	- primaries: chromaticity coordinates [ rx ry gx gy bx by ]
    *	- whitePoint: reference white [ x y ]
    *	- transfer: transfer function (pre-defined)
    *	- toXYZ: Matrix3 RGB to XYZ transform
    *	- fromXYZ: Matrix3 XYZ to RGB transform
    *	- luminanceCoefficients: RGB luminance coefficients
    *
    * Optional:
    *  - outputColorSpaceConfig: { drawingBufferColorSpace: ColorSpace }
    *  - workingColorSpaceConfig: { unpackColorSpace: ColorSpace }
    *
    * Reference:
    * - https://www.russellcottrell.com/photo/matrixCalculator.htm
    */
    public static var spaces:Map<String, ColorSpace> = [
		LinearSRGBColorSpace => {
			primaries: REC709_PRIMARIES,
			whitePoint: D65,
			transfer: LinearTransfer,
			toXYZ: LINEAR_REC709_TO_XYZ,
			fromXYZ: XYZ_TO_LINEAR_REC709,
			luminanceCoefficients: REC709_LUMINANCE_COEFFICIENTS,
			workingColorSpaceConfig: { unpackColorSpace: SRGBColorSpace },
			outputColorSpaceConfig: { drawingBufferColorSpace: SRGBColorSpace }
		},
		SRGBColorSpace => {
			primaries: REC709_PRIMARIES,
			whitePoint: D65,
			transfer: SRGBTransfer,
			toXYZ: LINEAR_REC709_TO_XYZ,
			fromXYZ: XYZ_TO_LINEAR_REC709,
			luminanceCoefficients: REC709_LUMINANCE_COEFFICIENTS,
			outputColorSpaceConfig: { drawingBufferColorSpace: SRGBColorSpace }
		}
    ];

    public static function convert ( color:Color, sourceColorSpace:String, targetColorSpace:String ) {

        if ( !enabled || sourceColorSpace == targetColorSpace || sourceColorSpace == null || targetColorSpace == null ) {

            return color;

        }

        if ( spaces[ sourceColorSpace ].transfer == SRGBTransfer ) {

            color.r = SRGBToLinear( color.r );
            color.g = SRGBToLinear( color.g );
            color.b = SRGBToLinear( color.b );

        }

        if ( spaces[ sourceColorSpace ].primaries != spaces[ targetColorSpace ].primaries ) {

            color.applyMatrix3( spaces[ sourceColorSpace ].toXYZ );
            color.applyMatrix3( spaces[ targetColorSpace ].fromXYZ );

        }

        if ( spaces[ targetColorSpace ].transfer == SRGBTransfer ) {

            color.r = LinearToSRGB( color.r );
            color.g = LinearToSRGB( color.g );
            color.b = LinearToSRGB( color.b );

        }

        return color;

    }

    public static function fromWorkingColorSpace ( color, targetColorSpace ) {

        return convert( color, workingColorSpace, targetColorSpace );

    }

    public static function toWorkingColorSpace ( color, sourceColorSpace ) {

        return convert( color, sourceColorSpace, workingColorSpace );

    }

    public static function getPrimaries ( colorSpace ) {

        return spaces[ colorSpace ].primaries;

    }

    public static function getTransfer ( colorSpace ) {

        if ( colorSpace == NoColorSpace ) return LinearTransfer;

        return spaces[ colorSpace ].transfer;

    }

    public static function getLuminanceCoefficients ( target, colorSpace ) {

        return target.fromArray( spaces[ colorSpace ?? workingColorSpace].luminanceCoefficients );

    }

    public static function define ( colorSpaces:Map<String, ColorSpace> ) {
        for (k => v in colorSpaces)
            spaces.set(k, v);
    }

    // Internal APIs

    static function _getMatrix ( targetMatrix, sourceColorSpace, targetColorSpace ) {
        return targetMatrix
            .copy( spaces[ sourceColorSpace ].toXYZ )
            .multiply( spaces[ targetColorSpace ].fromXYZ );
    }

    static function _getDrawingBufferColorSpace ( colorSpace ) {
        return spaces[ colorSpace ].outputColorSpaceConfig.drawingBufferColorSpace;
    }

    static function _getUnpackColorSpace ( ?colorSpace  ) {
        return spaces[ colorSpace ?? workingColorSpace ].workingColorSpaceConfig.unpackColorSpace;
    }

	public static var REC709_PRIMARIES = [ 0.640, 0.330, 0.300, 0.600, 0.150, 0.060 ];
	public static var REC709_LUMINANCE_COEFFICIENTS = [ 0.2126, 0.7152, 0.0722 ];
	public static var D65 = [ 0.3127, 0.3290 ];
}