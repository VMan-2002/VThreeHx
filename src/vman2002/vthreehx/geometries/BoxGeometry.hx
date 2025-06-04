package vman2002.vthreehx.geometries;

import vman2002.vthreehx.core.BufferGeometry;
import vman2002.vthreehx.core.BufferAttribute.Float32BufferAttribute;
import vman2002.vthreehx.math.Vector3;

/**
 * A geometry class for a rectangular cuboid with a given width, height, and depth.
 * On creation, the cuboid is centred on the origin, with each edge parallel to one
 * of the axes.
 *
 * ```js
 * const geometry = new THREE.BoxGeometry( 1, 1, 1 );
 * const material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
 * const cube = new THREE.Mesh( geometry, material );
 * scene.add( cube );
 * ```
 *
 * @augments BufferGeometry
 */
class BoxGeometry extends BufferGeometry {

	/**
	 * Constructs a new box geometry.
	 *
	 * @param {number} [width=1] - The width. That is, the length of the edges parallel to the X axis.
	 * @param {number} [height=1] - The height. That is, the length of the edges parallel to the Y axis.
	 * @param {number} [depth=1] - The depth. That is, the length of the edges parallel to the Z axis.
	 * @param {number} [widthSegments=1] - Number of segmented rectangular faces along the width of the sides.
	 * @param {number} [heightSegments=1] - Number of segmented rectangular faces along the height of the sides.
	 * @param {number} [depthSegments=1] - Number of segmented rectangular faces along the depth of the sides.
	 */
	public function new( ?width:Float = 1, ?height:Float = 1, ?depth:Float = 1, ?widthSegments:Int = 1, ?heightSegments:Int = 1, ?depthSegments:Int = 1 ) {
		super();

		var scope = this;

        parameters = {
            width: width,
            height: height,
            depth: depth,
            widthSegments: widthSegments,
            heightSegments: heightSegments,
            depthSegments: depthSegments
        }

		// segments

		widthSegments = Math.floor( widthSegments );
		heightSegments = Math.floor( heightSegments );
		depthSegments = Math.floor( depthSegments );

		// buffers

		var indices:Array<Int> = [];
		var vertices = new Float32Array();
		var normals = new Float32Array();
		var uvs = new Float32Array();

		// helper variables

		var numberOfVertices = 0;
		var groupStart = 0;

		// build each side of the box geometry

		function buildPlane( u:String, v:String, w:String, udir:Float, vdir:Float, width:Float, height:Float, depth:Float, gridX:Int, gridY:Int, materialIndex:Int ) {
            //TODO: I probably did something wrong with u,v,w, might be necessary to re-port this
			var segmentWidth = width / gridX;
			var segmentHeight = height / gridY;

			var widthHalf = width / 2;
			var heightHalf = height / 2;
			var depthHalf = depth / 2;

			var gridX1 = gridX + 1;
			var gridY1 = gridY + 1;

			var vertexCounter = 0;
			var groupCount = 0;

			var vx:Float, vy:Float, vz:Float;

			// generate vertices, normals and uvs

			for ( iy in 0...gridY1 ) {

				var y = iy * segmentHeight - heightHalf;

				for ( ix in 0...gridX1 ) {

					var x = ix * segmentWidth - widthHalf;

					// set values to correct vector component

					vx = ( x * udir);
					vy = (  y * vdir);
					vz = (  depthHalf);

					// now apply vector to vertex buffer

					vertices.push( vx);
                    vertices.push(vy);
                    vertices.push(vz );

					// set values to correct vector component

					vx = (  0);
					vy = (  0);
					vz = (  depth > 0 ? 1 : - 1);

					// now apply vector to normal buffer

					normals.push( vx);
                    normals.push(vy);
                    normals.push(vz );

					// uvs

					uvs.push( ix / gridX );
					uvs.push( 1 - ( iy / gridY ) );

					// counters

					vertexCounter += 1;

				}

			}

			// indices

			// 1. you need three indices to draw a single face
			// 2. a single segment consists of two faces
			// 3. so we need to generate six (2*3) indices per segment

			for ( iy in 0...gridY ) {

				for ( ix in 0...gridX ) {

					var a = numberOfVertices + ix + gridX1 * iy;
					var b = numberOfVertices + ix + gridX1 * ( iy + 1 );
					var c = numberOfVertices + ( ix + 1 ) + gridX1 * ( iy + 1 );
					var d = numberOfVertices + ( ix + 1 ) + gridX1 * iy;

					// faces

                    indices.push(a);
                    indices.push(b);
                    indices.push(d);
                    indices.push(b);
                    indices.push(c);
                    indices.push(d);

					// increase counter

					groupCount += 6;

				}

			}

			// add a group to the geometry. this will ensure multi material support

			scope.addGroup( groupStart, groupCount, materialIndex );

			// calculate new start value for groups

			groupStart += groupCount;

			// update total number of vertices

			numberOfVertices += vertexCounter;

		}

		buildPlane( 'z', 'y', 'x', - 1, - 1, depth, height, width, depthSegments, heightSegments, 0 ); // px
		buildPlane( 'z', 'y', 'x', 1, - 1, depth, height, - width, depthSegments, heightSegments, 1 ); // nx
		buildPlane( 'x', 'z', 'y', 1, 1, width, depth, height, widthSegments, depthSegments, 2 ); // py
		buildPlane( 'x', 'z', 'y', 1, - 1, width, depth, - height, widthSegments, depthSegments, 3 ); // ny
		buildPlane( 'x', 'y', 'z', 1, - 1, width, height, depth, widthSegments, heightSegments, 4 ); // pz
		buildPlane( 'x', 'y', 'z', - 1, - 1, width, height, - depth, widthSegments, heightSegments, 5 ); // nz

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3 ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3 ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2 ) );

	}

	public override function copy( source ) {
		super.copy( source );
		this.parameters = Common.assign( {}, source.parameters );
		return this;
	}

	/**
	 * Factory method for creating an instance of this class from the given
	 * JSON object.
	 *
	 * @param {Object} data - A JSON object representing the serialized geometry.
	 * @return {BoxGeometry} A new instance.
	 */
	public static function fromJSON( data ) {
		return new BoxGeometry( data.width, data.height, data.depth, data.widthSegments, data.heightSegments, data.depthSegments );
	}

}