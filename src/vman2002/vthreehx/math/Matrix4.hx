package vman2002.vthreehx.math;

import vman2002.vthreehx.Constants.WebGLCoordinateSystem in WebGLCoordinateSystem;
import vman2002.vthreehx.Constants.WebGPUCoordinateSystem in WebGPUCoordinateSystem;
import vman2002.vthreehx.math.Vector3;

/**
 * Represents a 4x4 matrix.
 *
 * The most common use of a 4x4 matrix in 3D computer graphics is as a transformation matrix.
 * For an introduction to transformation matrices as used in WebGL, check out [this tutorial]{@link https://www.opengl-tutorial.org/beginners-tutorials/tutorial-3-matrices}
 *
 * This allows a 3D vector representing a point in 3D space to undergo
 * transformations such as translation, rotation, shear, scale, reflection,
 * orthogonal or perspective projection and so on, by being multiplied by the
 * matrix. This is known as `applying` the matrix to the vector.
 *
 * A Note on Row-Major and Column-Major Ordering:
 *
 * The constructor and {@link Matrix3#set} method take arguments in
 * [row-major]{@link https://en.wikipedia.org/wiki/Row-_and_column-major_order#Column-major_order}
 * order, while internally they are stored in the {@link Matrix3#elements} array in column-major order.
 * This means that calling:
 * ```js
 * const m = new THREE.Matrix4();
 * m.set( 11, 12, 13, 14,
 *        21, 22, 23, 24,
 *        31, 32, 33, 34,
 *        41, 42, 43, 44 );
 * ```
 * will result in the elements array containing:
 * ```js
 * m.elements = [ 11, 21, 31, 41,
 *                12, 22, 32, 42,
 *                13, 23, 33, 43,
 *                14, 24, 34, 44 ];
 * ```
 * and internally all calculations are performed using column-major ordering.
 * However, as the actual ordering makes no difference mathematically and
 * most people are used to thinking about matrices in row-major order, the
 * three.js documentation shows matrices in row-major order. Just bear in
 * mind that if you are reading the source code, you'll have to take the
 * transpose of any matrices outlined here to make sense of the calculations.
 */
class Matrix4 {
	public var elements:Array<Float> = [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    ];
	/**
	 * Constructs a new 4x4 matrix. The arguments are supposed to be
	 * in row-major order. If no arguments are provided, the constructor
	 * initializes the matrix as an identity matrix.
	 *
	 * @param {number} [n11] - 1-1 matrix element.
	 * @param {number} [n12] - 1-2 matrix element.
	 * @param {number} [n13] - 1-3 matrix element.
	 * @param {number} [n14] - 1-4 matrix element.
	 * @param {number} [n21] - 2-1 matrix element.
	 * @param {number} [n22] - 2-2 matrix element.
	 * @param {number} [n23] - 2-3 matrix element.
	 * @param {number} [n24] - 2-4 matrix element.
	 * @param {number} [n31] - 3-1 matrix element.
	 * @param {number} [n32] - 3-2 matrix element.
	 * @param {number} [n33] - 3-3 matrix element.
	 * @param {number} [n34] - 3-4 matrix element.
	 * @param {number} [n41] - 4-1 matrix element.
	 * @param {number} [n42] - 4-2 matrix element.
	 * @param {number} [n43] - 4-3 matrix element.
	 * @param {number} [n44] - 4-4 matrix element.
	 */
	public function new( ?n11, ?n12, ?n13, ?n14, ?n21, ?n22, ?n23, ?n24, ?n31, ?n32, ?n33, ?n34, ?n41, ?n42, ?n43, ?n44 ) {
		if ( n11 != null )
			this.set( n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 );
	}

	/**
	 * Sets the elements of the matrix.The arguments are supposed to be
	 * in row-major order.
	 *
	 * @param {number} [n11] - 1-1 matrix element.
	 * @param {number} [n12] - 1-2 matrix element.
	 * @param {number} [n13] - 1-3 matrix element.
	 * @param {number} [n14] - 1-4 matrix element.
	 * @param {number} [n21] - 2-1 matrix element.
	 * @param {number} [n22] - 2-2 matrix element.
	 * @param {number} [n23] - 2-3 matrix element.
	 * @param {number} [n24] - 2-4 matrix element.
	 * @param {number} [n31] - 3-1 matrix element.
	 * @param {number} [n32] - 3-2 matrix element.
	 * @param {number} [n33] - 3-3 matrix element.
	 * @param {number} [n34] - 3-4 matrix element.
	 * @param {number} [n41] - 4-1 matrix element.
	 * @param {number} [n42] - 4-2 matrix element.
	 * @param {number} [n43] - 4-3 matrix element.
	 * @param {number} [n44] - 4-4 matrix element.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function set( n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 ) {

		var te = this.elements;

		te[ 0 ] = n11; te[ 4 ] = n12; te[ 8 ] = n13; te[ 12 ] = n14;
		te[ 1 ] = n21; te[ 5 ] = n22; te[ 9 ] = n23; te[ 13 ] = n24;
		te[ 2 ] = n31; te[ 6 ] = n32; te[ 10 ] = n33; te[ 14 ] = n34;
		te[ 3 ] = n41; te[ 7 ] = n42; te[ 11 ] = n43; te[ 15 ] = n44;

		return this;

	}

	/**
	 * Sets this matrix to the 4x4 identity matrix.
	 *
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function identity() {
		this.set(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);

		return this;
	}

	/**
	 * Returns a matrix with copied values from this instance.
	 *
	 * @return {Matrix4} A clone of this instance.
	 */
	public function clone() {
		return new Matrix4().fromArray( this.elements );
	}

	/**
	 * Copies the values of the given matrix to this instance.
	 *
	 * @param {Matrix4} m - The matrix to copy.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function copy( m ) {
		var te = this.elements;
		var me = m.elements;

		te[ 0 ] = me[ 0 ]; te[ 1 ] = me[ 1 ]; te[ 2 ] = me[ 2 ]; te[ 3 ] = me[ 3 ];
		te[ 4 ] = me[ 4 ]; te[ 5 ] = me[ 5 ]; te[ 6 ] = me[ 6 ]; te[ 7 ] = me[ 7 ];
		te[ 8 ] = me[ 8 ]; te[ 9 ] = me[ 9 ]; te[ 10 ] = me[ 10 ]; te[ 11 ] = me[ 11 ];
		te[ 12 ] = me[ 12 ]; te[ 13 ] = me[ 13 ]; te[ 14 ] = me[ 14 ]; te[ 15 ] = me[ 15 ];

		return this;
	}

	/**
	 * Copies the translation component of the given matrix
	 * into this matrix's translation component.
	 *
	 * @param {Matrix4} m - The matrix to copy the translation component.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function copyPosition( m ) {
		var te = this.elements, me = m.elements;

		te[ 12 ] = me[ 12 ];
		te[ 13 ] = me[ 13 ];
		te[ 14 ] = me[ 14 ];

		return this;
	}

	/**
	 * Set the upper 3x3 elements of this matrix to the values of given 3x3 matrix.
	 *
	 * @param {Matrix3} m - The 3x3 matrix.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function setFromMatrix3( m ) {
		var me = m.elements;

		this.set(
			me[ 0 ], me[ 3 ], me[ 6 ], 0,
			me[ 1 ], me[ 4 ], me[ 7 ], 0,
			me[ 2 ], me[ 5 ], me[ 8 ], 0,
			0, 0, 0, 1
		);

		return this;
	}

	/**
	 * Extracts the basis of this matrix into the three axis vectors provided.
	 *
	 * @param {Vector3} xAxis - The basis's x axis.
	 * @param {Vector3} yAxis - The basis's y axis.
	 * @param {Vector3} zAxis - The basis's z axis.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function extractBasis( xAxis, yAxis, zAxis ) {
		xAxis.setFromMatrixColumn( this, 0 );
		yAxis.setFromMatrixColumn( this, 1 );
		zAxis.setFromMatrixColumn( this, 2 );

		return this;
	}

	/**
	 * Sets the given basis vectors to this matrix.
	 *
	 * @param {Vector3} xAxis - The basis's x axis.
	 * @param {Vector3} yAxis - The basis's y axis.
	 * @param {Vector3} zAxis - The basis's z axis.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeBasis( xAxis, yAxis, zAxis ) {
		this.set(
			xAxis.x, yAxis.x, zAxis.x, 0,
			xAxis.y, yAxis.y, zAxis.y, 0,
			xAxis.z, yAxis.z, zAxis.z, 0,
			0, 0, 0, 1
		);

		return this;
	}

	/**
	 * Extracts the rotation component of the given matrix
	 * into this matrix's rotation component.
	 *
	 * Note: This method does not support reflection matrices.
	 *
	 * @param {Matrix4} m - The matrix.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function extractRotation( m ) {
		var te = this.elements;
		var me = m.elements;

		var scaleX = 1 / _v1.setFromMatrixColumn( m, 0 ).length();
		var scaleY = 1 / _v1.setFromMatrixColumn( m, 1 ).length();
		var scaleZ = 1 / _v1.setFromMatrixColumn( m, 2 ).length();

		te[ 0 ] = me[ 0 ] * scaleX;
		te[ 1 ] = me[ 1 ] * scaleX;
		te[ 2 ] = me[ 2 ] * scaleX;
		te[ 3 ] = 0;

		te[ 4 ] = me[ 4 ] * scaleY;
		te[ 5 ] = me[ 5 ] * scaleY;
		te[ 6 ] = me[ 6 ] * scaleY;
		te[ 7 ] = 0;

		te[ 8 ] = me[ 8 ] * scaleZ;
		te[ 9 ] = me[ 9 ] * scaleZ;
		te[ 10 ] = me[ 10 ] * scaleZ;
		te[ 11 ] = 0;

		te[ 12 ] = 0;
		te[ 13 ] = 0;
		te[ 14 ] = 0;
		te[ 15 ] = 1;

		return this;
	}

	/**
	 * Sets the rotation component (the upper left 3x3 matrix) of this matrix to
	 * the rotation specified by the given Euler angles. The rest of
	 * the matrix is set to the identity. Depending on the {@link Euler#order},
	 * there are six possible outcomes. See [this page]{@link https://en.wikipedia.org/wiki/Euler_angles#Rotation_matrix}
	 * for a complete list.
	 *
	 * @param {Euler} euler - The Euler angles.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationFromEuler( euler ) {
		var te = this.elements;

		var x = euler.x, y = euler.y, z = euler.z;
		var a = Math.cos( x ), b = Math.sin( x );
		var c = Math.cos( y ), d = Math.sin( y );
		var e = Math.cos( z ), f = Math.sin( z );

		if ( euler.order == 'XYZ' ) {

			var ae = a * e, af = a * f, be = b * e, bf = b * f;

			te[ 0 ] = c * e;
			te[ 4 ] = - c * f;
			te[ 8 ] = d;

			te[ 1 ] = af + be * d;
			te[ 5 ] = ae - bf * d;
			te[ 9 ] = - b * c;

			te[ 2 ] = bf - ae * d;
			te[ 6 ] = be + af * d;
			te[ 10 ] = a * c;

		} else if ( euler.order == 'YXZ' ) {

			var ce = c * e, cf = c * f, de = d * e, df = d * f;

			te[ 0 ] = ce + df * b;
			te[ 4 ] = de * b - cf;
			te[ 8 ] = a * d;

			te[ 1 ] = a * f;
			te[ 5 ] = a * e;
			te[ 9 ] = - b;

			te[ 2 ] = cf * b - de;
			te[ 6 ] = df + ce * b;
			te[ 10 ] = a * c;

		} else if ( euler.order == 'ZXY' ) {

			var ce = c * e, cf = c * f, de = d * e, df = d * f;

			te[ 0 ] = ce - df * b;
			te[ 4 ] = - a * f;
			te[ 8 ] = de + cf * b;

			te[ 1 ] = cf + de * b;
			te[ 5 ] = a * e;
			te[ 9 ] = df - ce * b;

			te[ 2 ] = - a * d;
			te[ 6 ] = b;
			te[ 10 ] = a * c;

		} else if ( euler.order == 'ZYX' ) {

			var ae = a * e, af = a * f, be = b * e, bf = b * f;

			te[ 0 ] = c * e;
			te[ 4 ] = be * d - af;
			te[ 8 ] = ae * d + bf;

			te[ 1 ] = c * f;
			te[ 5 ] = bf * d + ae;
			te[ 9 ] = af * d - be;

			te[ 2 ] = - d;
			te[ 6 ] = b * c;
			te[ 10 ] = a * c;

		} else if ( euler.order == 'YZX' ) {

			var ac = a * c, ad = a * d, bc = b * c, bd = b * d;

			te[ 0 ] = c * e;
			te[ 4 ] = bd - ac * f;
			te[ 8 ] = bc * f + ad;

			te[ 1 ] = f;
			te[ 5 ] = a * e;
			te[ 9 ] = - b * e;

			te[ 2 ] = - d * e;
			te[ 6 ] = ad * f + bc;
			te[ 10 ] = ac - bd * f;

		} else if ( euler.order == 'XZY' ) {

			var ac = a * c, ad = a * d, bc = b * c, bd = b * d;

			te[ 0 ] = c * e;
			te[ 4 ] = - f;
			te[ 8 ] = d * e;

			te[ 1 ] = ac * f + bd;
			te[ 5 ] = a * e;
			te[ 9 ] = ad * f - bc;

			te[ 2 ] = bc * f - ad;
			te[ 6 ] = b * e;
			te[ 10 ] = bd * f + ac;

		}

		// bottom row
		te[ 3 ] = 0;
		te[ 7 ] = 0;
		te[ 11 ] = 0;

		// last column
		te[ 12 ] = 0;
		te[ 13 ] = 0;
		te[ 14 ] = 0;
		te[ 15 ] = 1;

		return this;
	}

	/**
	 * Sets the rotation component of this matrix to the rotation specified by
	 * the given Quaternion as outlined [here]{@link https://en.wikipedia.org/wiki/Rotation_matrix#Quaternion}
	 * The rest of the matrix is set to the identity.
	 *
	 * @param {Quaternion} q - The Quaternion.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationFromQuaternion( q:Quaternion ) {
		return this.compose( _zero, q, _one );
	}

	/**
	 * Sets the rotation component of the transformation matrix, looking from `eye` towards
	 * `target`, and oriented by the up-direction.
	 *
	 * @param {Vector3} eye - The eye vector.
	 * @param {Vector3} target - The target vector.
	 * @param {Vector3} up - The up vector.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function lookAt( eye:Vector3, target:Vector3, up:Vector3 ) {

		var te = this.elements;

		_z.subVectors( eye, target );

		if ( _z.lengthSq() == 0 ) {

			// eye and target are in the same position

			_z.z = 1;

		}

		_z.normalize();
		_x.crossVectors( up, _z );

		if ( _x.lengthSq() == 0 ) {

			// up and z are parallel

			if ( Math.abs( up.z ) == 1 ) {

				_z.x += 0.0001;

			} else {

				_z.z += 0.0001;

			}

			_z.normalize();
			_x.crossVectors( up, _z );

		}

		_x.normalize();
		_y.crossVectors( _z, _x );

		te[ 0 ] = _x.x; te[ 4 ] = _y.x; te[ 8 ] = _z.x;
		te[ 1 ] = _x.y; te[ 5 ] = _y.y; te[ 9 ] = _z.y;
		te[ 2 ] = _x.z; te[ 6 ] = _y.z; te[ 10 ] = _z.z;

		return this;

	}

	/**
	 * Post-multiplies this matrix by the given 4x4 matrix.
	 *
	 * @param {Matrix4} m - The matrix to multiply with.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function multiply( m ) {
		return this.multiplyMatrices( this, m );
	}

	/**
	 * Pre-multiplies this matrix by the given 4x4 matrix.
	 *
	 * @param {Matrix4} m - The matrix to multiply with.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function premultiply( m ) {
		return this.multiplyMatrices( m, this );
	}

	/**
	 * Multiples the given 4x4 matrices and stores the result
	 * in this matrix.
	 *
	 * @param {Matrix4} a - The first matrix.
	 * @param {Matrix4} b - The second matrix.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function multiplyMatrices( a:Matrix4, b:Matrix4 ) {
		var ae = a.elements;
		var be = b.elements;
		var te = this.elements;

		var a11 = ae[ 0 ], a12 = ae[ 4 ], a13 = ae[ 8 ], a14 = ae[ 12 ];
		var a21 = ae[ 1 ], a22 = ae[ 5 ], a23 = ae[ 9 ], a24 = ae[ 13 ];
		var a31 = ae[ 2 ], a32 = ae[ 6 ], a33 = ae[ 10 ], a34 = ae[ 14 ];
		var a41 = ae[ 3 ], a42 = ae[ 7 ], a43 = ae[ 11 ], a44 = ae[ 15 ];

		var b11 = be[ 0 ], b12 = be[ 4 ], b13 = be[ 8 ], b14 = be[ 12 ];
		var b21 = be[ 1 ], b22 = be[ 5 ], b23 = be[ 9 ], b24 = be[ 13 ];
		var b31 = be[ 2 ], b32 = be[ 6 ], b33 = be[ 10 ], b34 = be[ 14 ];
		var b41 = be[ 3 ], b42 = be[ 7 ], b43 = be[ 11 ], b44 = be[ 15 ];

		te[ 0 ] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
		te[ 4 ] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
		te[ 8 ] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
		te[ 12 ] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;

		te[ 1 ] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
		te[ 5 ] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
		te[ 9 ] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
		te[ 13 ] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;

		te[ 2 ] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
		te[ 6 ] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
		te[ 10 ] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
		te[ 14 ] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;

		te[ 3 ] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
		te[ 7 ] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
		te[ 11 ] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
		te[ 15 ] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;

		return this;
	}

	/**
	 * Multiplies every component of the matrix by the given scalar.
	 *
	 * @param {number} s - The scalar.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function multiplyScalar( s ) {
		var te = this.elements;

		te[ 0 ] *= s; te[ 4 ] *= s; te[ 8 ] *= s; te[ 12 ] *= s;
		te[ 1 ] *= s; te[ 5 ] *= s; te[ 9 ] *= s; te[ 13 ] *= s;
		te[ 2 ] *= s; te[ 6 ] *= s; te[ 10 ] *= s; te[ 14 ] *= s;
		te[ 3 ] *= s; te[ 7 ] *= s; te[ 11 ] *= s; te[ 15 ] *= s;

		return this;
	}

	/**
	 * Computes and returns the determinant of this matrix.
	 *
	 * Based on the method outlined [here]{@link http://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/fourD/index.html}.
	 *
	 * @return {number} The determinant.
	 */
	public function determinant() {
		var te = this.elements;

		var n11 = te[ 0 ], n12 = te[ 4 ], n13 = te[ 8 ], n14 = te[ 12 ];
		var n21 = te[ 1 ], n22 = te[ 5 ], n23 = te[ 9 ], n24 = te[ 13 ];
		var n31 = te[ 2 ], n32 = te[ 6 ], n33 = te[ 10 ], n34 = te[ 14 ];
		var n41 = te[ 3 ], n42 = te[ 7 ], n43 = te[ 11 ], n44 = te[ 15 ];

		//TODO: make this more efficient

		return (
			n41 * (
				n14 * n23 * n32
				 - n13 * n24 * n32
				 - n14 * n22 * n33
				 + n12 * n24 * n33
				 + n13 * n22 * n34
				 - n12 * n23 * n34
			) +
			n42 * (
				n11 * n23 * n34
				 - n11 * n24 * n33
				 + n14 * n21 * n33
				 - n13 * n21 * n34
				 + n13 * n24 * n31
				 - n14 * n23 * n31
			) +
			n43 * (
				n11 * n24 * n32
				 - n11 * n22 * n34
				 - n14 * n21 * n32
				 + n12 * n21 * n34
				 + n14 * n22 * n31
				 - n12 * n24 * n31
			) +
			n44 * (
				- n13 * n22 * n31
				 - n11 * n23 * n32
				 + n11 * n22 * n33
				 + n13 * n21 * n32
				 - n12 * n21 * n33
				 + n12 * n23 * n31
			)

		);

	}

	/**
	 * Transposes this matrix in place.
	 *
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function transpose() {

		var te = this.elements;
		var tmp;

		tmp = te[ 1 ]; te[ 1 ] = te[ 4 ]; te[ 4 ] = tmp;
		tmp = te[ 2 ]; te[ 2 ] = te[ 8 ]; te[ 8 ] = tmp;
		tmp = te[ 6 ]; te[ 6 ] = te[ 9 ]; te[ 9 ] = tmp;

		tmp = te[ 3 ]; te[ 3 ] = te[ 12 ]; te[ 12 ] = tmp;
		tmp = te[ 7 ]; te[ 7 ] = te[ 13 ]; te[ 13 ] = tmp;
		tmp = te[ 11 ]; te[ 11 ] = te[ 14 ]; te[ 14 ] = tmp;

		return this;

	}

	/**
	 * Sets the position component for this matrix from the given vector,
	 * without affecting the rest of the matrix.
	 *
	 * @param {number|Vector3} x - The x component of the vector or alternatively the vector object.
	 * @param {number} y - The y component of the vector.
	 * @param {number} z - The z component of the vector.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function setPosition( x, y:Float, z:Float ) {

		var te = this.elements;

		if ( Std.isOfType(x, Vector3) ) {
			te[ 12 ] = x.x;
			te[ 13 ] = x.y;
			te[ 14 ] = x.z;
		} else {
			te[ 12 ] = cast x;
			te[ 13 ] = y;
			te[ 14 ] = z;
		}

		return this;

	}

	/**
	 * Inverts this matrix, using the [analytic method]{@link https://en.wikipedia.org/wiki/Invertible_matrix#Analytic_solution}.
	 * You can not invert with a determinant of zero. If you attempt this, the method produces
	 * a zero matrix instead.
	 *
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function invert() {

		// based on http://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/fourD/index.htm
		var te = this.elements,

			n11 = te[ 0 ], n21 = te[ 1 ], n31 = te[ 2 ], n41 = te[ 3 ],
			n12 = te[ 4 ], n22 = te[ 5 ], n32 = te[ 6 ], n42 = te[ 7 ],
			n13 = te[ 8 ], n23 = te[ 9 ], n33 = te[ 10 ], n43 = te[ 11 ],
			n14 = te[ 12 ], n24 = te[ 13 ], n34 = te[ 14 ], n44 = te[ 15 ],

			t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44,
			t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44,
			t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44,
			t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

		var det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;

		if ( det == 0 ) return this.set( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

		var detInv = 1 / det;

		te[ 0 ] = t11 * detInv;
		te[ 1 ] = ( n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44 ) * detInv;
		te[ 2 ] = ( n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44 ) * detInv;
		te[ 3 ] = ( n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43 ) * detInv;

		te[ 4 ] = t12 * detInv;
		te[ 5 ] = ( n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44 ) * detInv;
		te[ 6 ] = ( n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44 ) * detInv;
		te[ 7 ] = ( n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43 ) * detInv;

		te[ 8 ] = t13 * detInv;
		te[ 9 ] = ( n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44 ) * detInv;
		te[ 10 ] = ( n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44 ) * detInv;
		te[ 11 ] = ( n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43 ) * detInv;

		te[ 12 ] = t14 * detInv;
		te[ 13 ] = ( n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34 ) * detInv;
		te[ 14 ] = ( n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34 ) * detInv;
		te[ 15 ] = ( n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33 ) * detInv;

		return this;

	}

	/**
	 * Multiplies the columns of this matrix by the given vector.
	 *
	 * @param {Vector3} v - The scale vector.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function scale( v ) {

		var te = this.elements;
		var x = v.x, y = v.y, z = v.z;

		te[ 0 ] *= x; te[ 4 ] *= y; te[ 8 ] *= z;
		te[ 1 ] *= x; te[ 5 ] *= y; te[ 9 ] *= z;
		te[ 2 ] *= x; te[ 6 ] *= y; te[ 10 ] *= z;
		te[ 3 ] *= x; te[ 7 ] *= y; te[ 11 ] *= z;

		return this;

	}

	/**
	 * Gets the maximum scale value of the three axes.
	 *
	 * @return {number} The maximum scale.
	 */
	public function getMaxScaleOnAxis() {

		var te = this.elements;

		var scaleXSq = te[ 0 ] * te[ 0 ] + te[ 1 ] * te[ 1 ] + te[ 2 ] * te[ 2 ];
		var scaleYSq = te[ 4 ] * te[ 4 ] + te[ 5 ] * te[ 5 ] + te[ 6 ] * te[ 6 ];
		var scaleZSq = te[ 8 ] * te[ 8 ] + te[ 9 ] * te[ 9 ] + te[ 10 ] * te[ 10 ];

		return Math.sqrt( Math.max( Math.max(scaleXSq, scaleYSq), scaleZSq ) );

	}

	/**
	 * Sets this matrix as a translation transform from the given vector.
	 *
	 * @param {number|Vector3} x - The amount to translate in the X axis or alternatively a translation vector.
	 * @param {number} y - The amount to translate in the Y axis.
	 * @param {number} z - The amount to translate in the z axis.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeTranslation( x:Dynamic, y:Float, z:Float ) {

		if ( Std.isOfType(x, Vector3) ) {

			this.set(

				1, 0, 0, x.x,
				0, 1, 0, x.y,
				0, 0, 1, x.z,
				0, 0, 0, 1

			);

		} else {

			this.set(

				1, 0, 0, cast x,
				0, 1, 0, y,
				0, 0, 1, z,
				0, 0, 0, 1

			);

		}

		return this;

	}

	/**
	 * Sets this matrix as a rotational transformation around the X axis by
	 * the given angle.
	 *
	 * @param {number} theta - The rotation in radians.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationX( theta ) {

		var c = Math.cos( theta ), s = Math.sin( theta );

		this.set(

			1, 0, 0, 0,
			0, c, - s, 0,
			0, s, c, 0,
			0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix as a rotational transformation around the Y axis by
	 * the given angle.
	 *
	 * @param {number} theta - The rotation in radians.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationY( theta ) {

		var c = Math.cos( theta ), s = Math.sin( theta );

		this.set(

			 c, 0, s, 0,
			 0, 1, 0, 0,
			- s, 0, c, 0,
			 0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix as a rotational transformation around the Z axis by
	 * the given angle.
	 *
	 * @param {number} theta - The rotation in radians.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationZ( theta ) {

		var c = Math.cos( theta ), s = Math.sin( theta );

		this.set(

			c, - s, 0, 0,
			s, c, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix as a rotational transformation around the given axis by
	 * the given angle.
	 *
	 * This is a somewhat controversial but mathematically sound alternative to
	 * rotating via Quaternions. See the discussion [here]{@link https://www.gamedev.net/articles/programming/math-and-physics/do-we-really-need-quaternions-r1199}.
	 *
	 * @param {Vector3} axis - The normalized rotation axis.
	 * @param {number} angle - The rotation in radians.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeRotationAxis( axis, angle ) {

		// Based on http://www.gamedev.net/reference/articles/article1199.asp

		var c = Math.cos( angle );
		var s = Math.sin( angle );
		var t = 1 - c;
		var x = axis.x, y = axis.y, z = axis.z;
		var tx = t * x, ty = t * y;

		this.set(

			tx * x + c, tx * y - s * z, tx * z + s * y, 0,
			tx * y + s * z, ty * y + c, ty * z - s * x, 0,
			tx * z - s * y, ty * z + s * x, t * z * z + c, 0,
			0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix as a scale transformation.
	 *
	 * @param {number} x - The amount to scale in the X axis.
	 * @param {number} y - The amount to scale in the Y axis.
	 * @param {number} z - The amount to scale in the Z axis.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeScale( x, y, z ) {

		this.set(

			x, 0, 0, 0,
			0, y, 0, 0,
			0, 0, z, 0,
			0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix as a shear transformation.
	 *
	 * @param {number} xy - The amount to shear X by Y.
	 * @param {number} xz - The amount to shear X by Z.
	 * @param {number} yx - The amount to shear Y by X.
	 * @param {number} yz - The amount to shear Y by Z.
	 * @param {number} zx - The amount to shear Z by X.
	 * @param {number} zy - The amount to shear Z by Y.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeShear( xy, xz, yx, yz, zx, zy ) {

		this.set(

			1, yx, zx, 0,
			xy, 1, zy, 0,
			xz, yz, 1, 0,
			0, 0, 0, 1

		);

		return this;

	}

	/**
	 * Sets this matrix to the transformation composed of the given position,
	 * rotation (Quaternion) and scale.
	 *
	 * @param {Vector3} position - The position vector.
	 * @param {Quaternion} quaternion - The rotation as a Quaternion.
	 * @param {Vector3} scale - The scale vector.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function compose( position:Vector3, quaternion:Quaternion, scale:Vector3 ) {

		var te = this.elements;

		var x = quaternion.x, y = quaternion.y, z = quaternion.z, w = quaternion.w;
		var x2 = x + x,	y2 = y + y, z2 = z + z;
		var xx = x * x2, xy = x * y2, xz = x * z2;
		var yy = y * y2, yz = y * z2, zz = z * z2;
		var wx = w * x2, wy = w * y2, wz = w * z2;

		var sx = scale.x, sy = scale.y, sz = scale.z;

		te[ 0 ] = ( 1 - ( yy + zz ) ) * sx;
		te[ 1 ] = ( xy + wz ) * sx;
		te[ 2 ] = ( xz - wy ) * sx;
		te[ 3 ] = 0;

		te[ 4 ] = ( xy - wz ) * sy;
		te[ 5 ] = ( 1 - ( xx + zz ) ) * sy;
		te[ 6 ] = ( yz + wx ) * sy;
		te[ 7 ] = 0;

		te[ 8 ] = ( xz + wy ) * sz;
		te[ 9 ] = ( yz - wx ) * sz;
		te[ 10 ] = ( 1 - ( xx + yy ) ) * sz;
		te[ 11 ] = 0;

		te[ 12 ] = position.x;
		te[ 13 ] = position.y;
		te[ 14 ] = position.z;
		te[ 15 ] = 1;

		return this;

	}

	/**
	 * Decomposes this matrix into its position, rotation and scale components
	 * and provides the result in the given objects.
	 *
	 * Note: Not all matrices are decomposable in this way. For example, if an
	 * object has a non-uniformly scaled parent, then the object's world matrix
	 * may not be decomposable, and this method may not be appropriate.
	 *
	 * @param {Vector3} position - The position vector.
	 * @param {Quaternion} quaternion - The rotation as a Quaternion.
	 * @param {Vector3} scale - The scale vector.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function decompose( position:Vector3, quaternion:Quaternion, scale:Vector3 ) {

		var te = this.elements;

		var sx = _v1.set( te[ 0 ], te[ 1 ], te[ 2 ] ).length();
		var sy = _v1.set( te[ 4 ], te[ 5 ], te[ 6 ] ).length();
		var sz = _v1.set( te[ 8 ], te[ 9 ], te[ 10 ] ).length();

		// if determine is negative, we need to invert one scale
		var det = this.determinant();
		if ( det < 0 ) sx = - sx;

		position.x = te[ 12 ];
		position.y = te[ 13 ];
		position.z = te[ 14 ];

		// scale the rotation part
		_m1.copy( this );

		var invSX = 1 / sx;
		var invSY = 1 / sy;
		var invSZ = 1 / sz;

		_m1.elements[ 0 ] *= invSX;
		_m1.elements[ 1 ] *= invSX;
		_m1.elements[ 2 ] *= invSX;

		_m1.elements[ 4 ] *= invSY;
		_m1.elements[ 5 ] *= invSY;
		_m1.elements[ 6 ] *= invSY;

		_m1.elements[ 8 ] *= invSZ;
		_m1.elements[ 9 ] *= invSZ;
		_m1.elements[ 10 ] *= invSZ;

		quaternion.setFromRotationMatrix( _m1 );

		scale.x = sx;
		scale.y = sy;
		scale.z = sz;

		return this;

	}

	/**
	 * Creates a perspective projection matrix. This is used internally by
	 * {@link PerspectiveCamera#updateProjectionMatrix}.

	 * @param {number} left - Left boundary of the viewing frustum at the near plane.
	 * @param {number} right - Right boundary of the viewing frustum at the near plane.
	 * @param {number} top - Top boundary of the viewing frustum at the near plane.
	 * @param {number} bottom - Bottom boundary of the viewing frustum at the near plane.
	 * @param {number} near - The distance from the camera to the near plane.
	 * @param {number} far - The distance from the camera to the far plane.
	 * @param {(WebGLCoordinateSystem|WebGPUCoordinateSystem)} [coordinateSystem=WebGLCoordinateSystem] - The coordinate system.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makePerspective( left:Float, right:Float, top:Float, bottom:Float, near:Float, far:Float, ?coordinateSystem:Int = null ) {

		var te = this.elements;
		var x = 2 * near / ( right - left );
		var y = 2 * near / ( top - bottom );

		var a = ( right + left ) / ( right - left );
		var b = ( top + bottom ) / ( top - bottom );

		var c, d;

		if ( coordinateSystem == WebGLCoordinateSystem || coordinateSystem == null ) {

			c = - ( far + near ) / ( far - near );
			d = ( - 2 * far * near ) / ( far - near );

		} else if ( coordinateSystem == WebGPUCoordinateSystem ) {

			c = - far / ( far - near );
			d = ( - far * near ) / ( far - near );

		} else {

			throw( 'THREE.Matrix4.makePerspective(): Invalid coordinate system: ' + coordinateSystem );

		}

		te[ 0 ] = x;	te[ 4 ] = 0;	te[ 8 ] = a; 	te[ 12 ] = 0;
		te[ 1 ] = 0;	te[ 5 ] = y;	te[ 9 ] = b; 	te[ 13 ] = 0;
		te[ 2 ] = 0;	te[ 6 ] = 0;	te[ 10 ] = c; 	te[ 14 ] = d;
		te[ 3 ] = 0;	te[ 7 ] = 0;	te[ 11 ] = - 1;	te[ 15 ] = 0;

		return this;

	}

	/**
	 * Creates a orthographic projection matrix. This is used internally by
	 * {@link OrthographicCamera#updateProjectionMatrix}.

	 * @param {number} left - Left boundary of the viewing frustum at the near plane.
	 * @param {number} right - Right boundary of the viewing frustum at the near plane.
	 * @param {number} top - Top boundary of the viewing frustum at the near plane.
	 * @param {number} bottom - Bottom boundary of the viewing frustum at the near plane.
	 * @param {number} near - The distance from the camera to the near plane.
	 * @param {number} far - The distance from the camera to the far plane.
	 * @param {(WebGLCoordinateSystem|WebGPUCoordinateSystem)} [coordinateSystem=WebGLCoordinateSystem] - The coordinate system.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function makeOrthographic( left, right, top, bottom, near, far, ?coordinateSystem:Int ) {

		var te = this.elements;
		var w = 1.0 / ( right - left );
		var h = 1.0 / ( top - bottom );
		var p = 1.0 / ( far - near );

		var x = ( right + left ) * w;
		var y = ( top + bottom ) * h;

		var z, zInv;

		if ( coordinateSystem == WebGLCoordinateSystem || coordinateSystem == null ) {

			z = ( far + near ) * p;
			zInv = - 2 * p;

		} else if ( coordinateSystem == WebGPUCoordinateSystem ) {

			z = near * p;
			zInv = - 1 * p;

		} else {

			throw( 'THREE.Matrix4.makeOrthographic(): Invalid coordinate system: ' + coordinateSystem );

		}

		te[ 0 ] = 2 * w;	te[ 4 ] = 0;		te[ 8 ] = 0; 		te[ 12 ] = - x;
		te[ 1 ] = 0; 		te[ 5 ] = 2 * h;	te[ 9 ] = 0; 		te[ 13 ] = - y;
		te[ 2 ] = 0; 		te[ 6 ] = 0;		te[ 10 ] = zInv;	te[ 14 ] = - z;
		te[ 3 ] = 0; 		te[ 7 ] = 0;		te[ 11 ] = 0;		te[ 15 ] = 1;

		return this;

	}

	/**
	 * Returns `true` if this matrix is equal with the given one.
	 *
	 * @param {Matrix4} matrix - The matrix to test for equality.
	 * @return {boolean} Whether this matrix is equal with the given one.
	 */
	public function equals( matrix ) {

		var te = this.elements;
		var me = matrix.elements;

		for ( i in 0...16 ) {

			if ( te[ i ] != me[ i ] ) return false;

		}

		return true;

	}

	/**
	 * Sets the elements of the matrix from the given array.
	 *
	 * @param {Array<number>} array - The matrix elements in column-major order.
	 * @param {number} [offset=0] - Index of the first element in the array.
	 * @return {Matrix4} A reference to this matrix.
	 */
	public function fromArray( array, offset = 0 ) {

		for ( i in 0...16 ) {

			this.elements[ i ] = array[ i + offset ];

		}

		return this;

	}

	/**
	 * Writes the elements of this matrix to the given array. If no array is provided,
	 * the method returns a new instance.
	 *
	 * @param {Array<number>} [array=[]] - The target array holding the matrix elements in column-major order.
	 * @param {number} [offset=0] - Index of the first element in the array.
	 * @return {Array<number>} The matrix elements in column-major order.
	 */
	public function toArray( ?array:Array<Float>, offset = 0 ) {
		if (array == null)
			array = [];

		var te = this.elements;

		array[ offset ] = te[ 0 ];
		array[ offset + 1 ] = te[ 1 ];
		array[ offset + 2 ] = te[ 2 ];
		array[ offset + 3 ] = te[ 3 ];

		array[ offset + 4 ] = te[ 4 ];
		array[ offset + 5 ] = te[ 5 ];
		array[ offset + 6 ] = te[ 6 ];
		array[ offset + 7 ] = te[ 7 ];

		array[ offset + 8 ] = te[ 8 ];
		array[ offset + 9 ] = te[ 9 ];
		array[ offset + 10 ] = te[ 10 ];
		array[ offset + 11 ] = te[ 11 ];

		array[ offset + 12 ] = te[ 12 ];
		array[ offset + 13 ] = te[ 13 ];
		array[ offset + 14 ] = te[ 14 ];
		array[ offset + 15 ] = te[ 15 ];

		return array;

	}

    static var _v1 = /*@__PURE__*/ new Vector3();
    static var _m1 = /*@__PURE__*/ new Matrix4();
    static var _zero = /*@__PURE__*/ new Vector3( 0, 0, 0 );
    static var _one = /*@__PURE__*/ new Vector3( 1, 1, 1 );
    static var _x = /*@__PURE__*/ new Vector3();
    static var _y = /*@__PURE__*/ new Vector3();
    static var _z = /*@__PURE__*/ new Vector3();
}
