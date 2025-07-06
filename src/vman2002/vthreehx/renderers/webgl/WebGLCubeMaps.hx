package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.Constants.CubeReflectionMapping;
import vman2002.vthreehx.Constants.CubeRefractionMapping;
import vman2002.vthreehx.Constants.EquirectangularReflectionMapping;
import vman2002.vthreehx.Constants.EquirectangularRefractionMapping;
import vman2002.vthreehx.renderers.WebGLCubeRenderTarget;

class WebGLCubeMaps {

    var renderer:vman2002.vthreehx.renderers.WebGLRenderer;
    public function new(renderer) {
        this.renderer = renderer;
    }

	var cubemaps = new WeakMap();

	function mapTextureMapping( texture, mapping ) {

		if ( mapping == EquirectangularReflectionMapping ) {

			texture.mapping = CubeReflectionMapping;

		} else if ( mapping == EquirectangularRefractionMapping ) {

			texture.mapping = CubeRefractionMapping;

		}

		return texture;

	}

	public function get( texture ) {

		if ( texture && texture.isTexture ) {

			var mapping = texture.mapping;

			if ( mapping == EquirectangularReflectionMapping || mapping == EquirectangularRefractionMapping ) {

				if ( cubemaps.has( texture ) ) {

					var cubemap = cubemaps.get( texture ).texture;
					return mapTextureMapping( cubemap, texture.mapping );

				} else {

					var image = texture.image;

					if ( image != null && image.height > 0 ) {

						var renderTarget = new WebGLCubeRenderTarget( image.height );
						renderTarget.fromEquirectangularTexture( renderer, texture );
						cubemaps.set( texture, renderTarget );

						texture.addEventListener( 'dispose', onTextureDispose );

						return mapTextureMapping( renderTarget.texture, texture.mapping );

					} else {

						// image not yet ready. try the conversion next frame

						return null;

					}

				}

			}

		}

		return texture;

	}

	function onTextureDispose( event ) {

		var texture = event.target;

		texture.removeEventListener( 'dispose', onTextureDispose );

		var cubemap = cubemaps.get( texture );

		if ( cubemap != undefined ) {

			cubemaps.delete( texture );
			cubemap.dispose();

		}

	}

	public function dispose() {

		cubemaps = new WeakMap();

	}

}