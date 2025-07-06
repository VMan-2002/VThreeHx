package vman2002.vthreehx.renderers.shaders;

import vman2002.vthreehx.math.ColorManagement;

// Uniform Utilities

class UniformsUtils {

    public static function cloneUniforms( src ) {

        var dst = {};

        for ( u in Reflect.fields(src) ) {

            dst[ u ] = {};

            for ( p in Reflect.fields(src[ u ]) ) {

                var property = src[ u ][ p ];

                if ( property && ( property.isColor ||
                    property.isMatrix3 || property.isMatrix4 ||
                    property.isVector2 || property.isVector3 || property.isVector4 ||
                    property.isTexture || property.isQuaternion ) ) {

                    if ( property.isRenderTargetTexture ) {

                        console.warn( 'UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms().' );
                        dst[ u ][ p ] = null;

                    } else {

                        dst[ u ][ p ] = property.clone();

                    }

                } else if ( Array.isArray( property ) ) {

                    dst[ u ][ p ] = property.slice();

                } else {

                    dst[ u ][ p ] = property;

                }

            }

        }

        return dst;

    }

    public static function mergeUniforms( uniforms ) {

        var merged = {};

        for ( u in 0...uniforms.length ) {

            var tmp = cloneUniforms( uniforms[ u ] );

            for ( p in 0...tmp.length ) {

                merged[ p ] = tmp[ p ];

            }

        }

        return merged;

    }

    public static function cloneUniformsGroups( src ) {

        var dst = [];

        for ( u in 0...src.length ) {

            dst.push( src[ u ].clone() );

        }

        return dst;

    }

    public static function getUnlitUniformColorSpace( renderer ) {

        var currentRenderTarget = renderer.getRenderTarget();

        if ( currentRenderTarget == null ) {

            // https://github.com/mrdoob/three.js/pull/23937#issuecomment-1111067398
            return renderer.outputColorSpace;

        }

        // https://github.com/mrdoob/three.js/issues/27868
        if ( currentRenderTarget.isXRRenderTarget == true ) {

            return currentRenderTarget.texture.colorSpace;

        }

        return ColorManagement.workingColorSpace;

    }

}