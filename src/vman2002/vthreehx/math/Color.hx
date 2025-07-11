package vman2002.vthreehx.math;

import vman2002.vthreehx.math.MathUtils.clamp in clamp;
import vman2002.vthreehx.math.MathUtils.euclideanModulo in euclideanModulo;
import vman2002.vthreehx.math.MathUtils;
import vman2002.vthreehx.math.ColorManagement;
import vman2002.vthreehx.math.ColorManagement.SRGBToLinear in SRGBToLinear;
import vman2002.vthreehx.math.ColorManagement.LinearToSRGB in LinearToSRGB;
import vman2002.vthreehx.Constants.SRGBColorSpace in SRGBColorSpace;
import Std.parseInt;
import Std.parseFloat;
import vman2002.vthreehx.Common.parseInt in parseInt2;
#if flixel
import flixel.math.FlxMath.roundDecimal in flxRoundDecimal;
#end

/**
 * A Color instance is represented by RGB components in the linear <i>working
 * color space</i>, which defaults to `LinearSRGBColorSpace`. Inputs
 * conventionally using `SRGBColorSpace` (such as hexadecimals and CSS
 * strings) are converted to the working color space automatically.
 *
 * ```js
 * // converted automatically from SRGBColorSpace to LinearSRGBColorSpace
 * const color = new THREE.Color().setHex( 0x112233 );
 * ```
 * Source color spaces may be specified explicitly, to ensure correct conversions.
 * ```js
 * // assumed already LinearSRGBColorSpace; no conversion
 * const color = new THREE.Color().setRGB( 0.5, 0.5, 0.5 );
 *
 * // converted explicitly from SRGBColorSpace to LinearSRGBColorSpace
 * const color = new THREE.Color().setRGB( 0.5, 0.5, 0.5, SRGBColorSpace );
 * ```
 * If THREE.ColorManagement is disabled, no conversions occur. For details,
 * see <i>Color management</i>. Iterating through a Color instance will yield
 * its components (r, g, b) in the corresponding order. A Color can be initialised
 * in any of the following ways:
 * ```js
 * //empty constructor - will default white
 * const color1 = new THREE.Color();
 *
 * //Hexadecimal color (recommended)
 * const color2 = new THREE.Color( 0xff0000 );
 *
 * //RGB string
 * const color3 = new THREE.Color("rgb(255, 0, 0)");
 * const color4 = new THREE.Color("rgb(100%, 0%, 0%)");
 *
 * //X11 color name - all 140 color names are supported.
 * //Note the lack of CamelCase in the name
 * const color5 = new THREE.Color( 'skyblue' );
 * //HSL string
 * const color6 = new THREE.Color("hsl(0, 100%, 50%)");
 *
 * //Separate RGB values between 0 and 1
 * const color7 = new THREE.Color( 1, 0, 0 );
 * ```
 */
class Color {
    /**
    * A dictionary with X11 color names.
    *
    * Note that multiple words such as Dark Orange become the string 'darkorange'.
    *
    * @static
    * @type {Object}
    */
    public static var NAMES:Map<String, Int> = [ 'aliceblue' => 0xF0F8FF, 'antiquewhite' => 0xFAEBD7, 'aqua' => 0x00FFFF, 'aquamarine' => 0x7FFFD4, 'azure' => 0xF0FFFF,
	'beige' => 0xF5F5DC, 'bisque' => 0xFFE4C4, 'black' => 0x000000, 'blanchedalmond' => 0xFFEBCD, 'blue' => 0x0000FF, 'blueviolet' => 0x8A2BE2,
	'brown' => 0xA52A2A, 'burlywood' => 0xDEB887, 'cadetblue' => 0x5F9EA0, 'chartreuse' => 0x7FFF00, 'chocolate' => 0xD2691E, 'coral' => 0xFF7F50,
	'cornflowerblue' => 0x6495ED, 'cornsilk' => 0xFFF8DC, 'crimson' => 0xDC143C, 'cyan' => 0x00FFFF, 'darkblue' => 0x00008B, 'darkcyan' => 0x008B8B,
	'darkgoldenrod' => 0xB8860B, 'darkgray' => 0xA9A9A9, 'darkgreen' => 0x006400, 'darkgrey' => 0xA9A9A9, 'darkkhaki' => 0xBDB76B, 'darkmagenta' => 0x8B008B,
	'darkolivegreen' => 0x556B2F, 'darkorange' => 0xFF8C00, 'darkorchid' => 0x9932CC, 'darkred' => 0x8B0000, 'darksalmon' => 0xE9967A, 'darkseagreen' => 0x8FBC8F,
	'darkslateblue' => 0x483D8B, 'darkslategray' => 0x2F4F4F, 'darkslategrey' => 0x2F4F4F, 'darkturquoise' => 0x00CED1, 'darkviolet' => 0x9400D3,
	'deeppink' => 0xFF1493, 'deepskyblue' => 0x00BFFF, 'dimgray' => 0x696969, 'dimgrey' => 0x696969, 'dodgerblue' => 0x1E90FF, 'firebrick' => 0xB22222,
	'floralwhite' => 0xFFFAF0, 'forestgreen' => 0x228B22, 'fuchsia' => 0xFF00FF, 'gainsboro' => 0xDCDCDC, 'ghostwhite' => 0xF8F8FF, 'gold' => 0xFFD700,
	'goldenrod' => 0xDAA520, 'gray' => 0x808080, 'green' => 0x008000, 'greenyellow' => 0xADFF2F, 'grey' => 0x808080, 'honeydew' => 0xF0FFF0, 'hotpink' => 0xFF69B4,
	'indianred' => 0xCD5C5C, 'indigo' => 0x4B0082, 'ivory' => 0xFFFFF0, 'khaki' => 0xF0E68C, 'lavender' => 0xE6E6FA, 'lavenderblush' => 0xFFF0F5, 'lawngreen' => 0x7CFC00,
	'lemonchiffon' => 0xFFFACD, 'lightblue' => 0xADD8E6, 'lightcoral' => 0xF08080, 'lightcyan' => 0xE0FFFF, 'lightgoldenrodyellow' => 0xFAFAD2, 'lightgray' => 0xD3D3D3,
	'lightgreen' => 0x90EE90, 'lightgrey' => 0xD3D3D3, 'lightpink' => 0xFFB6C1, 'lightsalmon' => 0xFFA07A, 'lightseagreen' => 0x20B2AA, 'lightskyblue' => 0x87CEFA,
	'lightslategray' => 0x778899, 'lightslategrey' => 0x778899, 'lightsteelblue' => 0xB0C4DE, 'lightyellow' => 0xFFFFE0, 'lime' => 0x00FF00, 'limegreen' => 0x32CD32,
	'linen' => 0xFAF0E6, 'magenta' => 0xFF00FF, 'maroon' => 0x800000, 'mediumaquamarine' => 0x66CDAA, 'mediumblue' => 0x0000CD, 'mediumorchid' => 0xBA55D3,
	'mediumpurple' => 0x9370DB, 'mediumseagreen' => 0x3CB371, 'mediumslateblue' => 0x7B68EE, 'mediumspringgreen' => 0x00FA9A, 'mediumturquoise' => 0x48D1CC,
	'mediumvioletred' => 0xC71585, 'midnightblue' => 0x191970, 'mintcream' => 0xF5FFFA, 'mistyrose' => 0xFFE4E1, 'moccasin' => 0xFFE4B5, 'navajowhite' => 0xFFDEAD,
	'navy' => 0x000080, 'oldlace' => 0xFDF5E6, 'olive' => 0x808000, 'olivedrab' => 0x6B8E23, 'orange' => 0xFFA500, 'orangered' => 0xFF4500, 'orchid' => 0xDA70D6,
	'palegoldenrod' => 0xEEE8AA, 'palegreen' => 0x98FB98, 'paleturquoise' => 0xAFEEEE, 'palevioletred' => 0xDB7093, 'papayawhip' => 0xFFEFD5, 'peachpuff' => 0xFFDAB9,
	'peru' => 0xCD853F, 'pink' => 0xFFC0CB, 'plum' => 0xDDA0DD, 'powderblue' => 0xB0E0E6, 'purple' => 0x800080, 'rebeccapurple' => 0x663399, 'red' => 0xFF0000, 'rosybrown' => 0xBC8F8F,
	'royalblue' => 0x4169E1, 'saddlebrown' => 0x8B4513, 'salmon' => 0xFA8072, 'sandybrown' => 0xF4A460, 'seagreen' => 0x2E8B57, 'seashell' => 0xFFF5EE,
	'sienna' => 0xA0522D, 'silver' => 0xC0C0C0, 'skyblue' => 0x87CEEB, 'slateblue' => 0x6A5ACD, 'slategray' => 0x708090, 'slategrey' => 0x708090, 'snow' => 0xFFFAFA,
	'springgreen' => 0x00FF7F, 'steelblue' => 0x4682B4, 'tan' => 0xD2B48C, 'teal' => 0x008080, 'thistle' => 0xD8BFD8, 'tomato' => 0xFF6347, 'turquoise' => 0x40E0D0,
	'violet' => 0xEE82EE, 'wheat' => 0xF5DEB3, 'white' => 0xFFFFFF, 'whitesmoke' => 0xF5F5F5, 'yellow' => 0xFFFF00, 'yellowgreen' => 0x9ACD32 ];

	/** The red component. **/
    public var r:Float = 1;
	/** * The green component. **/
    public var g:Float = 1;
	/** * The blue component. **/
    public var b:Float = 1;

	/**
	 * Constructs a new color.
	 *
	 * Note that standard method of specifying color in three.js is with a hexadecimal triplet,
	 * and that method is used throughout the rest of the documentation.
	 *
	 * @param {(number|string|Color)} [r] - The red component of the color. If `g` and `b` are
	 * not provided, it can be hexadecimal triplet, a CSS-style string or another `Color` instance.
	 * @param {number} [g] - The green component.
	 * @param {number} [b] - The blue component.
	 */
	public function new( ?r:Dynamic = null, ?g:Float, ?b:Float ) {
        if (r != null)
		    set( r, g, b );
	}

	/**
	 * Sets the colors's components from the given values.
	 *
	 * @param {(number|string|Color)} [r] - The red component of the color. If `g` and `b` are
	 * not provided, it can be hexadecimal triplet, a CSS-style string or another `Color` instance.
	 * @param {number} [g] - The green component.
	 * @param {number} [b] - The blue component.
	 * @return {Color} A reference to this color.
	 */
	public function set( r:Dynamic, ?g:Float, ?b:Float ) {
		if ( g == null && b == null ) {

			// r is THREE.Color, hex or string

			var value = r;

			if (Std.isOfType(r, Color)) {
				this.copy(value);
			} else if (Std.isOfType(r, Int)) {
				this.setHex( cast value );
			} else if (Std.isOfType(r, String)) {
				this.setStyle( cast value );
			}
		} else {
			this.setRGB( r, g, b );
		}

		return this;
	}

	/**
	 * Sets the colors's components to the given scalar value.
	 *
	 * @param {number} scalar - The scalar value.
	 * @return {Color} A reference to this color.
	 */
	public function setScalar( scalar ) {

		this.r = scalar;
		this.g = scalar;
		this.b = scalar;

		return this;

	}

	/**
	 * Sets this color from a hexadecimal value.
	 *
	 * @param {number} hex - The hexadecimal value.
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {Color} A reference to this color.
	 */
	public function setHex( hex:Int, ?colorSpace:String ) {

		this.r = ( hex >> 16 & 255 ) / 255;
		this.g = ( hex >> 8 & 255 ) / 255;
		this.b = ( hex & 255 ) / 255;

		ColorManagement.toWorkingColorSpace( this, colorSpace ?? SRGBColorSpace );

		return this;

	}

	/**
	 * Sets this color from RGB values.
	 *
	 * @param {number} r - Red channel value between `0.0` and `1.0`.
	 * @param {number} g - Green channel value between `0.0` and `1.0`.
	 * @param {number} b - Blue channel value between `0.0` and `1.0`.
	 * @param {string} [colorSpace=ColorManagement.workingColorSpace] - The color space.
	 * @return {Color} A reference to this color.
	 */
	public function setRGB( r, g, b, ?colorSpace:String ) {

		this.r = r;
		this.g = g;
		this.b = b;

		ColorManagement.toWorkingColorSpace( this, colorSpace ?? ColorManagement.workingColorSpace );

		return this;

	}

	/**
	 * Sets this color from RGB values.
	 *
	 * @param {number} h - Hue value between `0.0` and `1.0`.
	 * @param {number} s - Saturation value between `0.0` and `1.0`.
	 * @param {number} l - Lightness value between `0.0` and `1.0`.
	 * @param {string} [colorSpace=ColorManagement.workingColorSpace] - The color space.
	 * @return {Color} A reference to this color.
	 */
	public function setHSL( h:Float, s:Float, l:Float, ?colorSpace  ) {

		// h,s,l ranges are in 0.0 - 1.0
		h = euclideanModulo( h, 1 );
		s = clamp( s, 0, 1 );
		l = clamp( l, 0, 1 );

		if ( s == 0 ) {

			this.r = this.g = this.b = l;

		} else {

			var p = l <= 0.5 ? l * ( 1 + s ) : l + s - ( l * s );
			var q:Float = ( 2 * l ) - p;

			this.r = hue2rgb( q, p, h + 1 / 3 );
			this.g = hue2rgb( q, p, h );
			this.b = hue2rgb( q, p, h - 1 / 3 );

		}

		ColorManagement.toWorkingColorSpace( this, colorSpace ?? ColorManagement.workingColorSpace );

		return this;

	}

	/**
	 * Sets this color from a CSS-style string. For example, `rgb(250, 0,0)`,
	 * `rgb(100%, 0%, 0%)`, `hsl(0, 100%, 50%)`, `#ff0000`, `#f00`, or `red` ( or
	 * any [X11 color name]{@link https://en.wikipedia.org/wiki/X11_color_names#Color_name_chart} -
	 * all 140 color names are supported).
	 *
	 * @param {string} style - Color as a CSS-style string.
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {Color} A reference to this color.
	 */
	public function setStyle( style, ?colorSpace  ) {
		colorSpace = colorSpace ?? SRGBColorSpace;
		function handleAlpha( string ) {

			if ( string == null ) return;

			if ( parseFloat( string ) < 1 ) {

				Common.warn( 'THREE.Color: Alpha component of ' + style + ' will be ignored.' );

			}

		}


		var m:Array<String>;

		var r1 = ~/^(\w+)\(([^\)]*)\)/;
		var r5 = ~/^#([A-Fa-f\d]+)$/;
		if ( r1.match(style) ) {

			// rgb / hsl

			var color;
			var name = r1.matched(1 );
			var components = r1.matched( 2);

			switch ( name ) {

				case 'rgb':
				case 'rgba':

					var r2 = ~/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/;
					if ( r2.match( components ) ) {

						// rgb(255,0,0) rgba(255,0,0,0.5)

						handleAlpha( r2.matched( 4 ) );

						return this.setRGB(
							Math.min( 255, parseInt( r2.matched( 1 ) ) ) / 255,
							Math.min( 255, parseInt( r2.matched( 2 ) ) ) / 255,
							Math.min( 255, parseInt( r2.matched( 3 ) ) ) / 255,
							colorSpace
						);

					}

					var r3 = ~/^\s*(\d+)%\s*,\s*(\d+)%\s*,\s*(\d+)%\s*(?:,\s*(\d*\.?\d+)\s*)?$/;
					if ( r3.match( components ) ) {

						// rgb(100%,0%,0%) rgba(100%,0%,0%,0.5)

						handleAlpha( r3.matched( 4 ) );

						return this.setRGB(
							Math.min( 100, parseInt( r3.matched(1  ) ) ) / 100,
							Math.min( 100, parseInt( r3.matched( 2 ) ) ) / 100,
							Math.min( 100, parseInt( r3.matched( 3 ) ) ) / 100,
							colorSpace
						);

					}


				case 'hsl':
				case 'hsla':

				var r4 = ~/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)%\s*,\s*(\d*\.?\d+)%\s*(?:,\s*(\d*\.?\d+)\s*)?$/;
					if ( r4.match( components ) ) {

						// hsl(120,50%,50%) hsla(120,50%,50%,0.5)

						handleAlpha( r4.matched( 4 ) );

						return this.setHSL(
							parseFloat( r4.matched( 1 ) ) / 360,
							parseFloat( r4.matched( 2 ) ) / 100,
							parseFloat( r4.matched( 3 ) ) / 100,
							colorSpace
						);

					}


				default:

					Common.warn( 'THREE.Color: Unknown color model ' + style );

			}

		} else if ( r5.match( style ) ) {

			// hex color

			var hex = r5.matched( 1 );
			var size = hex.length;

			if ( size == 3 ) {

				// #ff0
				return this.setRGB(
					parseInt2( hex.charAt( 0 ), 16 ) / 15,
					parseInt2( hex.charAt( 1 ), 16 ) / 15,
					parseInt2( hex.charAt( 2 ), 16 ) / 15,
					colorSpace
				);

			} else if ( size == 6 ) {

				// #ff0000
				return this.setHex( parseInt2( hex, 16 ), colorSpace );

			} else {

				Common.warn( 'THREE.Color: Invalid hex color ' + style );

			}

		} else if ( style != null && style.length != 0 ) {

			return this.setColorName( style, colorSpace );

		}

		return this;

	}

	/**
	 * Sets this color from a color name. Faster than {@link Color#setStyle} if
	 * you don't need the other CSS-style formats.
	 *
	 * For convenience, the list of names is exposed in `Color.NAMES` as a hash.
	 * ```js
	 * Color.NAMES.aliceblue // returns 0xF0F8FF
	 * ```
	 *
	 * @param {string} style - The color name.
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {Color} A reference to this color.
	 */
	public function setColorName( style, ?colorSpace ) {
		// color keywords
		var hex = NAMES[ style.toLowerCase() ];

		if ( hex != null ) {

			// red
			this.setHex( hex, colorSpace ?? SRGBColorSpace );

		} else {

			// unknown color
			Common.warn( 'THREE.Color: Unknown color ' + style );

		}

		return this;

	}

	/**
	 * Returns a new color with copied values from this instance.
	 *
	 * @return {Color} A clone of this instance.
	 */
	public function clone() {
		return new Color( this.r, this.g, this.b );
	}

	/**
	 * Copies the values of the given color to this instance.
	 *
	 * @param {Color} color - The color to copy.
	 * @return {Color} A reference to this color.
	 */
	public function copy( color ) {
		this.r = color.r;
		this.g = color.g;
		this.b = color.b;

		return this;
	}

	/**
	 * Copies the given color into this color, and then converts this color from
	 * `SRGBColorSpace` to `LinearSRGBColorSpace`.
	 *
	 * @param {Color} color - The color to copy/convert.
	 * @return {Color} A reference to this color.
	 */
	public function copySRGBToLinear( color ) {

		this.r = SRGBToLinear( color.r );
		this.g = SRGBToLinear( color.g );
		this.b = SRGBToLinear( color.b );

		return this;

	}

	/**
	 * Copies the given color into this color, and then converts this color from
	 * `LinearSRGBColorSpace` to `SRGBColorSpace`.
	 *
	 * @param {Color} color - The color to copy/convert.
	 * @return {Color} A reference to this color.
	 */
	public function copyLinearToSRGB( color ) {
		this.r = LinearToSRGB( color.r );
		this.g = LinearToSRGB( color.g );
		this.b = LinearToSRGB( color.b );

		return this;
	}

	/**
	 * Converts this color from `SRGBColorSpace` to `LinearSRGBColorSpace`.
	 *
	 * @return {Color} A reference to this color.
	 */
	public function convertSRGBToLinear() {
		return copySRGBToLinear( this );
	}

	/**
	 * Converts this color from `LinearSRGBColorSpace` to `SRGBColorSpace`.
	 *
	 * @return {Color} A reference to this color.
	 */
	public function convertLinearToSRGB() {
		return copyLinearToSRGB( this );
	}

	/**
	 * Returns the hexadecimal value of this color.
	 *
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {number} The hexadecimal value.
	 */
	public function getHex( ?colorSpace ) {
		ColorManagement.fromWorkingColorSpace( _color.copy( this ), colorSpace ?? SRGBColorSpace  );

		return Math.round( clamp( _color.r * 255, 0, 255 ) ) * 65536 + Math.round( clamp( _color.g * 255, 0, 255 ) ) * 256 + Math.round( clamp( _color.b * 255, 0, 255 ) );
	}

	/**
	 * Returns the hexadecimal value of this color as a string (for example, 'FFFFFF').
	 *
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {string} The hexadecimal value as a string.
	 */
	public function getHexString( ?colorSpace  ) {
		ColorManagement.fromWorkingColorSpace( _color.copy( this ), colorSpace ?? SRGBColorSpace  );
		return (MathUtils._lut[Std.int(_color.r * 255)] + MathUtils._lut[Std.int(_color.g * 255)] + MathUtils._lut[Std.int(_color.b * 255)]).toUpperCase();
	}

	/**
	 * Converts the colors RGB values into the HSL format and stores them into the
	 * given target object.
	 *
	 * @param {{h:number,s:number,l:number}} target - The target object that is used to store the method's result.
	 * @param {string} [colorSpace=ColorManagement.workingColorSpace] - The color space.
	 * @return {{h:number,s:number,l:number}} The HSL representation of this color.
	 */
	public function getHSL( ?target:{h:Float,s:Float,l:Float}, ?colorSpace  ) {

		// h,s,l ranges are in 0.0 - 1.0

		ColorManagement.fromWorkingColorSpace( _color.copy( this ), colorSpace ?? ColorManagement.workingColorSpace );

		var r = _color.r, g = _color.g, b = _color.b;

		var max = Math.max( Math.max(r, g), b );
		var min = Math.min( Math.min(r, g), b );

		var hue:Float, saturation:Float;
		var lightness = ( min + max ) / 2.0;

		if ( min == max ) {

			hue = 0;
			saturation = 0;

		} else {

			var delta = max - min;

			saturation = lightness <= 0.5 ? delta / ( max + min ) : delta / ( 2 - max - min );

			if (r == max)
				hue = ( g - b ) / delta + ( g < b ? 6 : 0 ); 
			else if (g == max)
				hue = ( b - r ) / delta + 2; 
			else
				hue = ( r - g ) / delta + 4; 

			hue /= 6;

		}
		if (target == null)
			return {h:hue, s:saturation, l:lightness};

		target.h = hue;
		target.s = saturation;
		target.l = lightness;

		return target;

	}

	/**
	 * Returns the RGB values of this color and stores them into the given target object.
	 *
	 * @param {Color} target - The target color that is used to store the method's result.
	 * @param {string} [colorSpace=ColorManagement.workingColorSpace] - The color space.
	 * @return {Color} The RGB representation of this color.
	 */
	public function getRGB( target, ?colorSpace ) {

		ColorManagement.fromWorkingColorSpace( _color.copy( this ), colorSpace ?? ColorManagement.workingColorSpace );

		target.r = _color.r;
		target.g = _color.g;
		target.b = _color.b;

		return target;

	}

	/**
	 * Returns the value of this color as a CSS style string. Example: `rgb(255,0,0)`.
	 *
	 * @param {string} [colorSpace=SRGBColorSpace] - The color space.
	 * @return {string} The CSS representation of this color.
	 */
	public function getStyle( ?colorSpace  ) {
		colorSpace = colorSpace ?? SRGBColorSpace;
		ColorManagement.fromWorkingColorSpace( _color.copy( this ), colorSpace );

		var r = _color.r, g = _color.g, b = _color.b;
		#if flixel
		r = flxRoundDecimal(r, 2);
		g = flxRoundDecimal(g, 2);
		b = flxRoundDecimal(b, 2);
		#end

		if ( colorSpace != SRGBColorSpace ) {

			// Requires CSS Color Module Level 4 (https://www.w3.org/TR/css-color-4/).
			return 'color(${ colorSpace } ${ r } ${ g } ${ b })';

		}

		return 'rgb(${ Math.round( r * 255 ) },${ Math.round( g * 255 ) },${ Math.round( b * 255 ) })';

	}

	/**
	 * Adds the given HSL values to this color's values.
	 * Internally, this converts the color's RGB values to HSL, adds HSL
	 * and then converts the color back to RGB.
	 *
	 * @param {number} h - Hue value between `0.0` and `1.0`.
	 * @param {number} s - Saturation value between `0.0` and `1.0`.
	 * @param {number} l - Lightness value between `0.0` and `1.0`.
	 * @return {Color} A reference to this color.
	 */
	public function offsetHSL( h, s, l ) {

		this.getHSL( _hslA );

		return this.setHSL( _hslA.h + h, _hslA.s + s, _hslA.l + l );

	}

	/**
	 * Adds the RGB values of the given color to the RGB values of this color.
	 *
	 * @param {Color} color - The color to add.
	 * @return {Color} A reference to this color.
	 */
	public function add( color ) {

		this.r += color.r;
		this.g += color.g;
		this.b += color.b;

		return this;

	}

	/**
	 * Adds the RGB values of the given colors and stores the result in this instance.
	 *
	 * @param {Color} color1 - The first color.
	 * @param {Color} color2 - The second color.
	 * @return {Color} A reference to this color.
	 */
	public function addColors( color1, color2 ) {

		this.r = color1.r + color2.r;
		this.g = color1.g + color2.g;
		this.b = color1.b + color2.b;

		return this;

	}

	/**
	 * Adds the given scalar value to the RGB values of this color.
	 *
	 * @param {number} s - The scalar to add.
	 * @return {Color} A reference to this color.
	 */
	public function addScalar( s ) {

		this.r += s;
		this.g += s;
		this.b += s;

		return this;

	}

	/**
	 * Subtracts the RGB values of the given color from the RGB values of this color.
	 *
	 * @param {Color} color - The color to subtract.
	 * @return {Color} A reference to this color.
	 */
	public function sub( color ) {

		this.r = Math.max( 0, this.r - color.r );
		this.g = Math.max( 0, this.g - color.g );
		this.b = Math.max( 0, this.b - color.b );

		return this;

	}

	/**
	 * Multiplies the RGB values of the given color with the RGB values of this color.
	 *
	 * @param {Color} color - The color to multiply.
	 * @return {Color} A reference to this color.
	 */
	public function multiply( color ) {

		this.r *= color.r;
		this.g *= color.g;
		this.b *= color.b;

		return this;

	}

	/**
	 * Multiplies the given scalar value with the RGB values of this color.
	 *
	 * @param {number} s - The scalar to multiply.
	 * @return {Color} A reference to this color.
	 */
	public function multiplyScalar( s ) {

		this.r *= s;
		this.g *= s;
		this.b *= s;

		return this;

	}

	/**
	 * Linearly interpolates this color's RGB values toward the RGB values of the
	 * given color. The alpha argument can be thought of as the ratio between
	 * the two colors, where `0.0` is this color and `1.0` is the first argument.
	 *
	 * @param {Color} color - The color to converge on.
	 * @param {number} alpha - The interpolation factor in the closed interval `[0,1]`.
	 * @return {Color} A reference to this color.
	 */
	public function lerp( color:Color, alpha:Float ) {

		this.r += ( color.r - this.r ) * alpha;
		this.g += ( color.g - this.g ) * alpha;
		this.b += ( color.b - this.b ) * alpha;

		return this;

	}

	/**
	 * Linearly interpolates between the given colors and stores the result in this instance.
	 * The alpha argument can be thought of as the ratio between the two colors, where `0.0`
	 * is the first and `1.0` is the second color.
	 *
	 * @param {Color} color1 - The first color.
	 * @param {Color} color2 - The second color.
	 * @param {number} alpha - The interpolation factor in the closed interval `[0,1]`.
	 * @return {Color} A reference to this color.
	 */
	public function lerpColors( color1, color2, alpha ) {

		this.r = color1.r + ( color2.r - color1.r ) * alpha;
		this.g = color1.g + ( color2.g - color1.g ) * alpha;
		this.b = color1.b + ( color2.b - color1.b ) * alpha;

		return this;

	}

	/**
	 * Linearly interpolates this color's HSL values toward the HSL values of the
	 * given color. It differs from {@link Color#lerp} by not interpolating straight
	 * from one color to the other, but instead going through all the hues in between
	 * those two colors. The alpha argument can be thought of as the ratio between
	 * the two colors, where 0.0 is this color and 1.0 is the first argument.
	 *
	 * @param {Color} color - The color to converge on.
	 * @param {number} alpha - The interpolation factor in the closed interval `[0,1]`.
	 * @return {Color} A reference to this color.
	 */
	public function lerpHSL( color, alpha ) {

		this.getHSL( _hslA );
		color.getHSL( _hslB );

		var h = MathUtils.lerp( _hslA.h, _hslB.h, alpha );
		var s = MathUtils.lerp( _hslA.s, _hslB.s, alpha );
		var l = MathUtils.lerp( _hslA.l, _hslB.l, alpha );

		this.setHSL( h, s, l );

		return this;

	}

	/**
	 * Sets the color's RGB components from the given 3D vector.
	 *
	 * @param {Vector3} v - The vector to set.
	 * @return {Color} A reference to this color.
	 */
	public function setFromVector3( v ) {

		this.r = v.x;
		this.g = v.y;
		this.b = v.z;

		return this;

	}

	/**
	 * Transforms this color with the given 3x3 matrix.
	 *
	 * @param {Matrix3} m - The matrix.
	 * @return {Color} A reference to this color.
	 */
	public function applyMatrix3( m ) {

		var r = this.r, g = this.g, b = this.b;
		var e = m.elements;

		this.r = e[ 0 ] * r + e[ 3 ] * g + e[ 6 ] * b;
		this.g = e[ 1 ] * r + e[ 4 ] * g + e[ 7 ] * b;
		this.b = e[ 2 ] * r + e[ 5 ] * g + e[ 8 ] * b;

		return this;

	}

	/**
	 * Returns `true` if this color is equal with the given one.
	 *
	 * @param {Color} c - The color to test for equality.
	 * @return {boolean} Whether this bounding color is equal with the given one.
	 */
	public function equals( c ) {

		return ( c.r == this.r ) && ( c.g == this.g ) && ( c.b == this.b );

	}

	/**
	 * Sets this color's RGB components from the given array.
	 *
	 * @param {Array<number>} array - An array holding the RGB values.
	 * @param {number} [offset=0] - The offset into the array.
	 * @return {Color} A reference to this color.
	 */
	public function fromArray( array, offset = 0 ) {

		this.r = array[ offset ];
		this.g = array[ offset + 1 ];
		this.b = array[ offset + 2 ];

		return this;

	}

	/**
	 * Writes the RGB components of this color to the given array. If no array is provided,
	 * the method returns a new instance.
	 *
	 * @param {Array<number>} [array=[]] - The target array holding the color components.
	 * @param {number} [offset=0] - Index of the first element in the array.
	 * @return {Array<number>} The color components.
	 */
	public function toArray( ?array:Array<Float>, ?offset = 0 ) {
		if (array == null)
			array = [];
		array[ offset ] = this.r;
		array[ offset + 1 ] = this.g;
		array[ offset + 2 ] = this.b;

		return array;

	}

	/**
	 * Sets the components of this color from the given buffer attribute.
	 *
	 * @param {BufferAttribute} attribute - The buffer attribute holding color data.
	 * @param {number} index - The index into the attribute.
	 * @return {Color} A reference to this color.
	 */
	public function fromBufferAttribute( attribute, index ) {

		this.r = attribute.getX( index );
		this.g = attribute.getY( index );
		this.b = attribute.getZ( index );

		return this;

	}

	/**
	 * This methods defines the serialization result of this class. Returns the color as a hexadecimal value.
	 *
	 * @return {number} The hexadecimal value.
	 */
	public function toJSON() {
		return this.getHex();
	}

	#if flixel
	/**
		@param alpha Alpha value for the output FlxColor, on a scale from 0 to 1
		@return FlxColor converted from this THREE.Color
	**/
	public function toFlxColor(?alpha:Float = 1) {
		return flixel.util.FlxColor.fromRGBFloat(r, g, b, alpha);
	}

	/**
		Set this color from an FlxColor.
		@return A reference to this color.
	**/
	public function setFromFlxColor(col:flixel.util.FlxColor) {
		return setRGB(col.redFloat, col.greenFloat, col.blueFloat);
	}

	/**
		@return FlxColor using color info from `Color.NAMES`
	**/
	public static function nameToFlxColor(name:String) {
		return flixel.util.FlxColor.fromInt(NAMES.get(name));
	}

	@:from
	public static function castFromFlxColor(n:flixel.util.FlxColor) {
		return new Color(n.redFloat, n.greenFloat, n.blueFloat);	
	}
	#end

    public function iterator() {
        return [this.r, this.g, this.b].iterator();
    }

    static function hue2rgb( p:Float, q:Float, t:Float ) {
        if ( t < 0 ) t += 1;
        if ( t > 1 ) t -= 1;
        if ( t < 1 / 6 ) return p + ( q - p ) * 6 * t;
        if ( t < 1 / 2 ) return q;
        if ( t < 2 / 3 ) return p + ( q - p ) * 6 * ( 2 / 3 - t );
        return p;
    }

    static var _hslA:{h:Float,s:Float,l:Float} = { h: 0, s: 0, l: 0 };
    static var _hslB:{h:Float,s:Float,l:Float} = { h: 0, s: 0, l: 0 };
    static var _color = /*@__PURE__*/ new Color();
}