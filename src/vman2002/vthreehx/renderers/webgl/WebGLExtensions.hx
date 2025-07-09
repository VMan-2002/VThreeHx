package vman2002.vthreehx.renderers.webgl;

class WebGLExtensions {
    var gl:GL;
    public function new(gl) {
        this.gl = gl;
    }

    //TODO: what type?
	var extensions = new Map<String, Dynamic>();

	public function getExtension( name ) {

		if ( extensions[ name ] != null ) {

			return extensions[ name ];

		}

		var extension;

		switch ( name ) {

			case 'WEBGL_depth_texture':
				extension = gl.getExtension( 'WEBGL_depth_texture' ) || gl.getExtension( 'MOZ_WEBGL_depth_texture' ) || gl.getExtension( 'WEBKIT_WEBGL_depth_texture' );

			case 'EXT_texture_filter_anisotropic':
				extension = gl.getExtension( 'EXT_texture_filter_anisotropic' ) || gl.getExtension( 'MOZ_EXT_texture_filter_anisotropic' ) || gl.getExtension( 'WEBKIT_EXT_texture_filter_anisotropic' );

			case 'WEBGL_compressed_texture_s3tc':
				extension = gl.getExtension( 'WEBGL_compressed_texture_s3tc' ) || gl.getExtension( 'MOZ_WEBGL_compressed_texture_s3tc' ) || gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_s3tc' );

			case 'WEBGL_compressed_texture_pvrtc':
				extension = gl.getExtension( 'WEBGL_compressed_texture_pvrtc' ) || gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_pvrtc' );

			default:
				extension = gl.getExtension( name );

		}

		extensions[ name ] = extension;

		return extension;

	}

    public function has ( name ) {

        return getExtension( name ) != null;

    }

    public function init () {

        getExtension( 'EXT_color_buffer_float' );
        getExtension( 'WEBGL_clip_cull_distance' );
        getExtension( 'OES_texture_float_linear' );
        getExtension( 'EXT_color_buffer_half_float' );
        getExtension( 'WEBGL_multisampled_render_to_texture' );
        getExtension( 'WEBGL_render_shared_exponent' );

    }

    public function get( name ) {

        var extension = getExtension( name );

        if ( extension == null ) {

            vman2002.vthreehx.Utils.warnOnce( 'THREE.WebGLRenderer: ' + name + ' extension not supported.' );

        }

        return extension;

    }

}