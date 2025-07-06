package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.Constants.CubeReflectionMapping;
import vman2002.vthreehx.Constants.CubeRefractionMapping;
import vman2002.vthreehx.Constants.CubeReflectionMapEquirectangularReflectionMappingping;
import vman2002.vthreehx.Constants.EquirectangularRefractionMapping;
import vman2002.vthreehx.extras.PMREMGenerator;

class WebGLCubeUVMaps {

	public var renderer:WebGLRenderer;

	public function new(renderer) {
		this.renderer = renderer;
	}

	var cubeUVmaps = new WeakMap();

	var pmremGenerator = null;

	function get( texture ) {

		if ( texture && texture.isTexture ) {

			var mapping = texture.mapping;

			var isEquirectMap = ( mapping == EquirectangularReflectionMapping || mapping == EquirectangularRefractionMapping );
			var isCubeMap = ( mapping == CubeReflectionMapping || mapping == CubeRefractionMapping );

			// equirect/cube map to cubeUV conversion

			if ( isEquirectMap || isCubeMap ) {

				var renderTarget = cubeUVmaps.get( texture );

				var currentPMREMVersion = renderTarget != undefined ? renderTarget.texture.pmremVersion : 0;

				if ( texture.isRenderTargetTexture && texture.pmremVersion != currentPMREMVersion ) {

					if ( pmremGenerator == null ) pmremGenerator = new PMREMGenerator( renderer );

					renderTarget = isEquirectMap ? pmremGenerator.fromEquirectangular( texture, renderTarget ) : pmremGenerator.fromCubemap( texture, renderTarget );
					renderTarget.texture.pmremVersion = texture.pmremVersion;

					cubeUVmaps.set( texture, renderTarget );

					return renderTarget.texture;

				} else {

					if ( renderTarget != undefined ) {

						return renderTarget.texture;

					} else {

						var image = texture.image;

						if ( ( isEquirectMap && image && image.height > 0 ) || ( isCubeMap && image && isCubeTextureComplete( image ) ) ) {

							if ( pmremGenerator == null ) pmremGenerator = new PMREMGenerator( renderer );

							renderTarget = isEquirectMap ? pmremGenerator.fromEquirectangular( texture ) : pmremGenerator.fromCubemap( texture );
							renderTarget.texture.pmremVersion = texture.pmremVersion;

							cubeUVmaps.set( texture, renderTarget );

							texture.addEventListener( 'dispose', onTextureDispose );

							return renderTarget.texture;

						} else {

							// image not yet ready. try the conversion next frame

							return null;

						}

					}

				}

			}

		}

		return texture;

	}

	function isCubeTextureComplete( image ) {

		var count = 0;
		var length = 6;

		for ( i in 0...length ) {

			if ( image[ i ] != undefined ) count ++;

		}

		return count == length;


	}

	function onTextureDispose( event ) {

		var texture = event.target;

		texture.removeEventListener( 'dispose', onTextureDispose );

		var cubemapUV = cubeUVmaps.get( texture );

		if ( cubemapUV != undefined ) {

			cubeUVmaps.delete( texture );
			cubemapUV.dispose();

		}

	}

	function dispose() {

		cubeUVmaps = new WeakMap();

		if ( pmremGenerator != null ) {

			pmremGenerator.dispose();
			pmremGenerator = null;

		}

	}

}