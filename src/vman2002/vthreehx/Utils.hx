package vman2002.vthreehx;

import vman2002.vthreehx.math.Matrix4;

class Utils {
    public static function arrayMin( array ) {

        if ( array.length == 0 ) return Infinity;

        var min = array[ 0 ];

        for ( i in 1...array.length ) {

            if ( array[ i ] < min ) min = array[ i ];

        }

        return min;

    }

    public static function arrayMax( array ) {

        if ( array.length == 0 ) return - Infinity;

        var max = array[ 0 ];

        for ( i in 1...array.length ) {

            if ( array[ i ] > max ) max = array[ i ];

        }

        return max;

    }

    public static function arrayNeedsUint32( array:Array<Int> ) {
        // assumes larger values usually on last

        for ( n in array ) {
            if ( n >= 65535 ) return true; // account for PRIMITIVE_RESTART_FIXED_INDEX, #24565
        }

        return false;
    }

    static var TYPED_ARRAYS:Map<String, Class<Dynamic>> = [
        "Int8Array" => TypedArray.Int8Array,
        "Uint8Array" => TypedArray.Uint8Array,
        "Uint8ClampedArray" => TypedArray.Uint8ClampedArray,
        "Int16Array" => TypedArray.Int16Array,
        "Uint16Array" => TypedArray.Uint16Array,
        "Int32Array" => TypedArray.Int32Array,
        "Uint32Array" => TypedArray.Uint32Array,
        "Float32Array" => TypedArray.Float32Array,
        "Float64Array" => TypedArray.Float64Array
    ];

    public static  function getTypedArray( type, buffer ) {

        return Type.createInstance(TYPED_ARRAYS[ type ], [buffer] );

    }

    /*function createElementNS( name ) {

        return document.createElementNS( 'http://www.w3.org/1999/xhtml', name );

    }*/

    /*function createCanvasElement() {

        const canvas = createElementNS( 'canvas' );
        canvas.style.display = 'block';
        return canvas;

    }*/

    static var _cache = new Map<String, Bool>();

    public static function warnOnce( message:String ) {

        if ( _cache.exists(message) ) return;

        _cache.set(message, true);

        Common.warn( message );

    }

    //TODO:
    /*function probeAsync( gl, sync, interval ) {

        return new Promise( function ( resolve, reject ) {

            function probe() {

                switch ( gl.clientWaitSync( sync, gl.SYNC_FLUSH_COMMANDS_BIT, 0 ) ) {

                    case gl.WAIT_FAILED:
                        reject();
                        break;

                    case gl.TIMEOUT_EXPIRED:
                        setTimeout( probe, interval );
                        break;

                    default:
                        resolve();

                }

            }

            setTimeout( probe, interval );

        } );

    }*/

    public static function toNormalizedProjectionMatrix( projectionMatrix:Matrix4 ) {

        var m = projectionMatrix.elements;

        // Convert [-1, 1] to [0, 1] projection matrix
        m[ 2 ] = 0.5 * m[ 2 ] + 0.5 * m[ 3 ];
        m[ 6 ] = 0.5 * m[ 6 ] + 0.5 * m[ 7 ];
        m[ 10 ] = 0.5 * m[ 10 ] + 0.5 * m[ 11 ];
        m[ 14 ] = 0.5 * m[ 14 ] + 0.5 * m[ 15 ];

    }

    public static function toReversedProjectionMatrix( projectionMatrix:Matrix4 ) {

        var m = projectionMatrix.elements;
        var isPerspectiveMatrix = m[ 11 ] == - 1;

        // Reverse [0, 1] projection matrix
        if ( isPerspectiveMatrix ) {

            m[ 10 ] = - m[ 10 ] - 1;
            m[ 14 ] = - m[ 14 ];

        } else {

            m[ 10 ] = - m[ 10 ];
            m[ 14 ] = - m[ 14 ] + 1;

        }

    }
}