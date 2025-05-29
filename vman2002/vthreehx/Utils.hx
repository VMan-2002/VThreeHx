package vman2002.vthreehx;

class Utils {
    function arrayMin( array ) {

        if ( array.length === 0 ) return Infinity;

        let min = array[ 0 ];

        for ( let i = 1, l = array.length; i < l; ++ i ) {

            if ( array[ i ] < min ) min = array[ i ];

        }

        return min;

    }

    function arrayMax( array ) {

        if ( array.length === 0 ) return - Infinity;

        let max = array[ 0 ];

        for ( let i = 1, l = array.length; i < l; ++ i ) {

            if ( array[ i ] > max ) max = array[ i ];

        }

        return max;

    }

    function arrayNeedsUint32( array ) {

        // assumes larger values usually on last

        for ( let i = array.length - 1; i >= 0; -- i ) {

            if ( array[ i ] >= 65535 ) return true; // account for PRIMITIVE_RESTART_FIXED_INDEX, #24565

        }

        return false;

    }

    static var TYPED_ARRAYS = [
        "Int8Array" => Common.Int8Array,
        "Uint8Array" => Common.Uint8Array,
        "Uint8ClampedArray" => Common.Uint8ClampedArray,
        "Int16Array" => Common.Int16Array,
        "Uint16Array" => Common.Uint16Array,
        "Int32Array" => Common.Int32Array,
        "Uint32Array" => Common.Uint32Array,
        "Float32Array" => Common.Float32Array,
        "Float64Array" => Common.Float64Array
    ];

    public function getTypedArray( type, buffer ) {

        return new TYPED_ARRAYS[ type ]( buffer );

    }

    /*function createElementNS( name ) {

        return document.createElementNS( 'http://www.w3.org/1999/xhtml', name );

    }*/

    /*function createCanvasElement() {

        const canvas = createElementNS( 'canvas' );
        canvas.style.display = 'block';
        return canvas;

    }*/

    public var _cache = new Map<String, Bool>();

    function warnOnce( message ) {

        if ( _cache.exists(message) ) return;

        _cache.set(message, true)

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

    function toNormalizedProjectionMatrix( projectionMatrix ) {

        const m = projectionMatrix.elements;

        // Convert [-1, 1] to [0, 1] projection matrix
        m[ 2 ] = 0.5 * m[ 2 ] + 0.5 * m[ 3 ];
        m[ 6 ] = 0.5 * m[ 6 ] + 0.5 * m[ 7 ];
        m[ 10 ] = 0.5 * m[ 10 ] + 0.5 * m[ 11 ];
        m[ 14 ] = 0.5 * m[ 14 ] + 0.5 * m[ 15 ];

    }

    function toReversedProjectionMatrix( projectionMatrix ) {

        const m = projectionMatrix.elements;
        const isPerspectiveMatrix = m[ 11 ] === - 1;

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