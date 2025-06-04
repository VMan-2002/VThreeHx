package vman2002.vthreehx.textures;

import vman2002.vthreehx.math.MathUtils.generateUUID;


/**
 * Represents the data source of a texture.
 *
 * The main purpose of this class is to decouple the data definition from the texture
 * definition so the same data can be used with multiple texture instances.
 */
class Source {


		/**
		 * The ID of the source.
		 *
		 * @name Source#id
		 * @type {number}
		 * @readonly
		 */
		public var id = _sourceId += 1;

		/**
		 * The UUID of the source.
		 *
		 * @type {string}
		 * @readonly
		 */
		public var uuid = generateUUID();

		/**
		 * The data definition of a texture.
		 *
		 * @type {any}
		 */
		public var data:Dynamic;

		/**
		 * This property is only relevant when {@link Source#needsUpdate} is set to `true` and
		 * provides more control on how texture data should be processed. When `dataReady` is set
		 * to `false`, the engine performs the memory allocation (if necessary) but does not transfer
		 * the data into the GPU memory.
		 *
		 * @type {boolean}
		 * @default true
		 */
		public var dataReady = true;

		/**
		 * This starts at `0` and counts how many times {@link Source#needsUpdate} is set to `true`.
		 *
		 * @type {number}
		 * @readonly
		 * @default 0
		 */
		public var version = 0;

	/**
	 * Constructs a new video texture.
	 *
	 * @param {any} [data=null] - The data definition of a texture.
	 */
	public function new( data = null ) {
        this.data = data;
	}

	/**
	 * When the property is set to `true`, the engine allocates the memory
	 * for the texture (if necessary) and triggers the actual texture upload
	 * to the GPU next time the source is used.
	 *
	 * @type {boolean}
	 * @default false
	 * @param {boolean} value
	 */
     public var needsUpdate(never, set):Bool;
	function set_needsUpdate( value:Bool ) {

		if ( value ) this.version ++;
        return value;

	}

	/**
	 * Serializes the source into JSON.
	 *
	 * @param {?(Object|string)} meta - An optional value holding meta information about the serialization.
	 * @return {Object} A JSON object representing the serialized source.
	 * @see {@link ObjectLoader#parse}
	 */
	public function toJSON( meta:Dynamic ) {

		var isRootObject = ( meta == null || Std.isOfType(meta, String) );

		if ( !isRootObject && meta.images.get( this.uuid) != null ) {

			return meta.images.get( this.uuid );

		}

		var output = {
			uuid: this.uuid,
			url: ''
		};

		var data = this.data;

		if ( data != null ) {

			var url:Dynamic;

			if ( Std.isOfType( data, Array ) ) {

				// cube texture

				url = [];

				for ( i in 0...data.length ) {

					if ( data[ i ].isDataTexture ) {

						url.push( serializeImage( data[ i ].image ) );

					} else {

						url.push( serializeImage( data[ i ] ) );

					}

				}

			} else {

				// texture

				url = serializeImage( data );

			}

			output.url = url;

		}

		if ( ! isRootObject ) {

			meta.images.set( this.uuid, output);

		}

		return output;

	}

    /**
        Accepts:
        - `BitmapData` (OpenFL)
        - `FlxGraphic` (Flixel)
    **/
    public static function serializeImage( image:Dynamic ) {
        #if openfl
        if (Std.isOfType(image, openfl.display.BitmapData)) {
            return image;
        } else
        #end
        #if flixel
        if (Std.isOfType(image, flixel.graphics.FlxGraphic)) {
            return serializeImage(cast(image, flixel.graphics.FlxGraphic).bitmap);
        } else
        #end

        /*if ( ( typeof HTMLImageElement != 'undefined' && image instanceof HTMLImageElement ) ||
            ( typeof HTMLCanvasElement != 'undefined' && image instanceof HTMLCanvasElement ) ||
            ( typeof ImageBitmap != 'undefined' && image instanceof ImageBitmap ) ) {

            // default images

            return ImageUtils.getDataURL( image );

        } else {

            if ( image.data ) {

                // images of DataTexture

                return {
                    data: Array.from( image.data ),
                    width: image.width,
                    height: image.height,
                    type: image.data.constructor.name
                };

            } else {

                console.warn( 'THREE.Texture: Unable to serialize Texture.' );
                return {};

            }

        }*/
        {

            Common.warn( 'THREE.Texture: Unable to serialize Texture.' );
            return {};

        }

    }
    static var _sourceId = 0;

}