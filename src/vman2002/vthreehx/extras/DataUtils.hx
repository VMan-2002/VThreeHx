package vman2002.vthreehx.extras;

import vman2002.vthreehx.math.MathUtils.clamp;

/**
 * A class containing utility functions for data.
 *
 * @hideconstructor
 */
class DataUtils {
    /**
    * Returns a half precision floating point value (FP16) from the given single
    * precision floating point value (FP32).
    *
    * @param {number} val - A single precision floating point value.
    * @return {number} The FP16 value.
    */
    public static function toHalfFloat( val ) {

        if ( Math.abs( val ) > 65504 ) Common.warn( 'THREE.DataUtils.toHalfFloat(): Value out of range.' );

        val = clamp( val, - 65504, 65504 );

        _tables.floatView.set(0,  val);
        var f = _tables.uint32View.get( 0);
        var e = ( f >> 23 ) & 0x1ff;
        return _tables.baseTable.get( e) + ( ( f & 0x007fffff ) >> _tables.shiftTable.get( e) );

    }

    /**
    * Returns a single precision floating point value (FP32) from the given half
    * precision floating point value (FP16).
    *
    * @param {number} val - A half precision floating point value.
    * @return {number} The FP32 value.
    */
    public static function fromHalfFloat( val ) {

        var m = val >> 10;
        _tables.uint32View.set( 0, _tables.mantissaTable.get( _tables.offsetTable.get( m ) + ( val & 0x3ff ) ) + _tables.exponentTable.get( m ));
        return _tables.floatView.get( 0 );

    }

    // Fast Half Float Conversions, http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf

    static inline function _generateTables() {

        // float32 to float16 helpers

        //var buffer = new ArrayBuffer( 4 );
        var floatView = new Float32Array( 4 );
        var uint32View = new Uint32Array( 4 );

        var baseTable = new Uint32Array( 512 );
        var shiftTable = new Uint32Array( 512 );

        for ( i in 0...256 ) {

            var e = i - 127;

            // very small number (0, -0)

            if ( e < - 27 ) {

                baseTable.set( i, 0x0000);
                baseTable.set( i | 0x100, 0x8000);
                shiftTable.set( i, 24);
                shiftTable.set( i | 0x100, 24);

                // small number (denorm)

            } else if ( e < - 14 ) {

                baseTable.set( i, 0x0400 >> ( - e - 14 ));
                baseTable.set( i | 0x100, ( 0x0400 >> ( - e - 14 ) ) | 0x8000);
                shiftTable.set( i, - e - 1);
                shiftTable.set( i | 0x100, - e - 1);

                // normal number

            } else if ( e <= 15 ) {

                baseTable.set( i, ( e + 15 ) << 10);
                baseTable.set( i | 0x100, ( ( e + 15 ) << 10 ) | 0x8000);
                shiftTable.set( i, 13);
                shiftTable.set( i | 0x100, 13);

                // large number (Infinity, -Infinity)

            } else if ( e < 128 ) {

                baseTable.set( i, 0x7c00);
                baseTable.set( i | 0x100, 0xfc00);
                shiftTable.set( i, 24);
                shiftTable.set( i | 0x100, 24);

                // stay (NaN, Infinity, -Infinity)

            } else {

                baseTable.set( i, 0x7c00);
                baseTable.set( i | 0x100, 0xfc00);
                shiftTable.set( i, 13);
                shiftTable.set( i | 0x100, 13);

            }

        }

        // float16 to float32 helpers

        var mantissaTable = new Uint32Array( 2048 );
        var exponentTable = new Uint32Array( 64 );
        var offsetTable = new Uint32Array( 64 );

        for ( i in 1...1024 ) {

            var m = i << 13; // zero pad mantissa bits
            var e = 0; // zero exponent

            // normalized
            while ( ( m & 0x00800000 ) == 0 ) {

                m <<= 1;
                e -= 0x00800000; // decrement exponent

            }

            m &= ~ 0x00800000; // clear leading 1 bit
            e += 0x38800000; // adjust bias

            mantissaTable.set( i, m | e);

        }

        for ( i in 1024...2048 ) {

            mantissaTable.set( i, 0x38000000 + ( ( i - 1024 ) << 13 ));

        }

        for ( i in 1...31 ) {

            exponentTable.set( i, i << 23);

        }

        exponentTable.set( 31, 0x47800000);
        exponentTable.set( 32, 0x80000000);

        for ( i in 33...63 ) {

            exponentTable.set( i, 0x80000000 + ( ( i - 32 ) << 23 ));

        }

        exponentTable.set( 63, 0xc7800000);

        for ( i in 1...64 ) {

            if ( i != 32 ) {

                offsetTable.set( i, 1024);

            }

        }

        return {
            floatView: floatView,
            uint32View: uint32View,
            baseTable: baseTable,
            shiftTable: shiftTable,
            mantissaTable: mantissaTable,
            exponentTable: exponentTable,
            offsetTable: offsetTable
        };

    }

    static var _tables = _generateTables();
}