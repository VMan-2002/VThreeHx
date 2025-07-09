package vman2002.vthreehx.renderers.webgl;

import vman2002.vthreehx.Constants;
import vman2002.vthreehx.math.Color;
import vman2002.vthreehx.math.Vector4;
import lime.graphics.opengl.GLTexture;

class WebGLState {
	public function new() {
		if ( glVersion.indexOf( 'WebGL' ) != - 1 ) {

			version = parseFloat( ~/^WebGL (\d)/.exec( glVersion )[ 1 ] );
			lineWidthAvailable = ( version >= 1.0 );

		} else if ( glVersion.indexOf( 'OpenGL ES' ) != - 1 ) {

			version = parseFloat( ~/^OpenGL ES (\d)/.exec( glVersion )[ 1 ] );
			lineWidthAvailable = ( version >= 2.0 );

		}

		// init

		colorBuffer.setClear( 0, 0, 0, 1 );
		depthBuffer.setClear( 1 );
		stencilBuffer.setClear( 0 );

		enable( gl.DEPTH_TEST );
		depthBuffer.setFunc( LessEqualDepth );

		setFlipSided( false );
		setCullFace( CullFaceBack );
		enable( gl.CULL_FACE );

		setBlending( NoBlending );
		
		buffers = {
			color: colorBuffer,
			depth: depthBuffer,
			stencil: stencilBuffer
		};
	}

    static var reversedFuncs:Map<Int, Int> = [
        Constants.NeverDepth => Constants.AlwaysDepth,
        Constants.LessDepth => Constants.GreaterDepth,
        Constants.EqualDepth => Constants.NotEqualDepth,
        Constants.LessEqualDepth => Constants.GreaterEqualDepth,

        Constants.AlwaysDepth => Constants.NeverDepth,
        Constants.GreaterDepth => Constants.LessDepth,
        Constants.NotEqualDepth => Constants.EqualDepth,
        Constants.GreaterEqualDepth => Constants.LessEqualDepth,
    ];

	function ColorBuffer() {

		var locked = false;

		var color = new Vector4();
		var currentColorMask = null;
		var currentColorClear = new Vector4( 0, 0, 0, 0 );

		return {

			setMask: function ( colorMask ) {

				if ( currentColorMask != colorMask && ! locked ) {

					gl.colorMask( colorMask, colorMask, colorMask, colorMask );
					currentColorMask = colorMask;

				}

			},

			setLocked: function ( lock ) {

				locked = lock;

			},

			setClear: function ( r, g, b, a, premultipliedAlpha ) {

				if ( premultipliedAlpha == true ) {

					r *= a; g *= a; b *= a;

				}

				color.set( r, g, b, a );

				if ( currentColorClear.equals( color ) == false ) {

					gl.clearColor( r, g, b, a );
					currentColorClear.copy( color );

				}

			},

			reset: function () {

				locked = false;

				currentColorMask = null;
				currentColorClear.set( - 1, 0, 0, 0 ); // set to invalid state

			}

		};

	}

	function DepthBuffer() {

		var locked = false;

		var currentReversed = false;
		var currentDepthMask = null;
		var currentDepthFunc = null;
		var currentDepthClear = null;

		return {

			setReversed: function ( reversed ) {

				if ( currentReversed != reversed ) {

					var ext = extensions.get( 'EXT_clip_control' );

					if ( reversed ) {

						ext.clipControlEXT( ext.LOWER_LEFT_EXT, ext.ZERO_TO_ONE_EXT );

					} else {

						ext.clipControlEXT( ext.LOWER_LEFT_EXT, ext.NEGATIVE_ONE_TO_ONE_EXT );

					}

					currentReversed = reversed;

					var oldDepth = currentDepthClear;
					currentDepthClear = null;
					this.setClear( oldDepth );

				}

			},

			getReversed: function () {

				return currentReversed;

			},

			setTest: function ( depthTest ) {

				if ( depthTest ) {

					enable( gl.DEPTH_TEST );

				} else {

					disable( gl.DEPTH_TEST );

				}

			},

			setMask: function ( depthMask ) {

				if ( currentDepthMask != depthMask && ! locked ) {

					gl.depthMask( depthMask );
					currentDepthMask = depthMask;

				}

			},

			setFunc: function ( depthFunc ) {

				if ( currentReversed ) depthFunc = reversedFuncs[ depthFunc ];

				if ( currentDepthFunc != depthFunc ) {

					switch ( depthFunc ) {

						case NeverDepth:

							gl.depthFunc( gl.NEVER );
							break;

						case AlwaysDepth:

							gl.depthFunc( gl.ALWAYS );
							break;

						case LessDepth:

							gl.depthFunc( gl.LESS );
							break;

						case LessEqualDepth:

							gl.depthFunc( gl.LEQUAL );
							break;

						case EqualDepth:

							gl.depthFunc( gl.EQUAL );
							break;

						case GreaterEqualDepth:

							gl.depthFunc( gl.GEQUAL );
							break;

						case GreaterDepth:

							gl.depthFunc( gl.GREATER );
							break;

						case NotEqualDepth:

							gl.depthFunc( gl.NOTEQUAL );
							break;

						default:

							gl.depthFunc( gl.LEQUAL );

					}

					currentDepthFunc = depthFunc;

				}

			},

			setLocked: function ( lock ) {

				locked = lock;

			},

			setClear: function ( depth ) {

				if ( currentDepthClear != depth ) {

					if ( currentReversed ) {

						depth = 1 - depth;

					}

					gl.clearDepth( depth );
					currentDepthClear = depth;

				}

			},

			reset: function () {

				locked = false;

				currentDepthMask = null;
				currentDepthFunc = null;
				currentDepthClear = null;
				currentReversed = false;

			}

		};

	}

	function StencilBuffer() {

		var locked = false;

		var currentStencilMask = null;
		var currentStencilFunc = null;
		var currentStencilRef = null;
		var currentStencilFuncMask = null;
		var currentStencilFail = null;
		var currentStencilZFail = null;
		var currentStencilZPass = null;
		var currentStencilClear = null;

		return {

			setTest: function ( stencilTest ) {

				if ( ! locked ) {

					if ( stencilTest ) {

						enable( gl.STENCIL_TEST );

					} else {

						disable( gl.STENCIL_TEST );

					}

				}

			},

			setMask: function ( stencilMask ) {

				if ( currentStencilMask != stencilMask && ! locked ) {

					gl.stencilMask( stencilMask );
					currentStencilMask = stencilMask;

				}

			},

			setFunc: function ( stencilFunc, stencilRef, stencilMask ) {

				if ( currentStencilFunc != stencilFunc ||
				     currentStencilRef != stencilRef ||
				     currentStencilFuncMask != stencilMask ) {

					gl.stencilFunc( stencilFunc, stencilRef, stencilMask );

					currentStencilFunc = stencilFunc;
					currentStencilRef = stencilRef;
					currentStencilFuncMask = stencilMask;

				}

			},

			setOp: function ( stencilFail, stencilZFail, stencilZPass ) {

				if ( currentStencilFail != stencilFail ||
				     currentStencilZFail != stencilZFail ||
				     currentStencilZPass != stencilZPass ) {

					gl.stencilOp( stencilFail, stencilZFail, stencilZPass );

					currentStencilFail = stencilFail;
					currentStencilZFail = stencilZFail;
					currentStencilZPass = stencilZPass;

				}

			},

			setLocked: function ( lock ) {

				locked = lock;

			},

			setClear: function ( stencil ) {

				if ( currentStencilClear != stencil ) {

					gl.clearStencil( stencil );
					currentStencilClear = stencil;

				}

			},

			reset: function () {

				locked = false;

				currentStencilMask = null;
				currentStencilFunc = null;
				currentStencilRef = null;
				currentStencilFuncMask = null;
				currentStencilFail = null;
				currentStencilZFail = null;
				currentStencilZPass = null;
				currentStencilClear = null;

			}

		};

	}

	//

	var colorBuffer = new ColorBuffer();
	var depthBuffer = new DepthBuffer();
	var stencilBuffer = new StencilBuffer();

	var uboBindings = new WeakMap();
	var uboProgramMap = new WeakMap();

	var enabledCapabilities = {};

	var currentBoundFramebuffers = {};
	var currentDrawbuffers = new WeakMap();
	var defaultDrawbuffers = [];

	var currentProgram = null;

	var currentBlendingEnabled = false;
	var currentBlending = null;
	var currentBlendEquation = null;
	var currentBlendSrc = null;
	var currentBlendDst = null;
	var currentBlendEquationAlpha = null;
	var currentBlendSrcAlpha = null;
	var currentBlendDstAlpha = null;
	var currentBlendColor = new Color( 0, 0, 0 );
	var currentBlendAlpha = 0;
	var currentPremultipledAlpha = false;

	var currentFlipSided = null;
	var currentCullFace = null;

	var currentLineWidth = null;

	var currentPolygonOffsetFactor = null;
	var currentPolygonOffsetUnits = null;

	var maxTextures = GL.getParameter( GL.MAX_COMBINED_TEXTURE_IMAGE_UNITS );

	var lineWidthAvailable = false;
	var version = 0;
	var glVersion = GL.getParameter( GL.VERSION );

	var currentTextureSlot = null;
	var currentBoundTextures = {};

	var scissorParam = GL.getParameter( GL.SCISSOR_BOX );
	var viewportParam = GL.getParameter( GL.VIEWPORT );

	var currentScissor = new Vector4().fromArray( scissorParam );
	var currentViewport = new Vector4().fromArray( viewportParam );

	function createTexture( type, target, count, dimensions ) {

		var data = new Uint8Array( 4 ); // 4 is required to match default unpack alignment of 4.
		var texture = GL.createTexture();

		GL.bindTexture( type, texture );
		GL.texParameteri( type, GL.TEXTURE_MIN_FILTER, GL.NEAREST );
		GL.texParameteri( type, GL.TEXTURE_MAG_FILTER, GL.NEAREST );

		for ( i in 0...count ) {

			if ( type == GL.TEXTURE_3D || type == GL.TEXTURE_2D_ARRAY ) {

				GL.texImage3D( target, 0, GL.RGBA, 1, 1, dimensions, 0, GL.RGBA, GL.UNSIGNED_BYTE, data );

			} else {

				GL.texImage2D( target + i, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, data );

			}

		}

		return texture;

	}

	var emptyTextures:Map<Int, GLTexture> = [
		GL.TEXTURE_2D => createTexture( GL.TEXTURE_2D, GL.TEXTURE_2D, 1 ),
		GL.TEXTURE_CUBE_MAP => createTexture( GL.TEXTURE_CUBE_MAP, GL.TEXTURE_CUBE_MAP_POSITIVE_X, 6 ),
		GL.TEXTURE_2D_ARRAY => createTexture( GL.TEXTURE_2D_ARRAY, GL.TEXTURE_2D_ARRAY, 1, 1 ),
		GL.TEXTURE_3D => createTexture( GL.TEXTURE_3D, GL.TEXTURE_3D, 1, 1 )
	];

	//

	function enable( id ) {

		if ( enabledCapabilities[ id ] != true ) {

			GL.enable( id );
			enabledCapabilities[ id ] = true;

		}

	}

	function disable( id ) {

		if ( enabledCapabilities[ id ] != false ) {

			GL.disable( id );
			enabledCapabilities[ id ] = false;

		}

	}

	function bindFramebuffer( target, framebuffer ) {

		if ( currentBoundFramebuffers[ target ] != framebuffer ) {

			GL.bindFramebuffer( target, framebuffer );

			currentBoundFramebuffers[ target ] = framebuffer;

			// GL.DRAW_FRAMEBUFFER is equivalent to GL.FRAMEBUFFER

			if ( target == GL.DRAW_FRAMEBUFFER ) {

				currentBoundFramebuffers[ GL.FRAMEBUFFER ] = framebuffer;

			}

			if ( target == GL.FRAMEBUFFER ) {

				currentBoundFramebuffers[ GL.DRAW_FRAMEBUFFER ] = framebuffer;

			}

			return true;

		}

		return false;

	}

	function drawBuffers( renderTarget, framebuffer ) {

		var drawBuffers = defaultDrawbuffers;

		var needsUpdate = false;

		if ( renderTarget ) {

			drawBuffers = currentDrawbuffers.get( framebuffer );

			if ( drawBuffers == undefined ) {

				drawBuffers = [];
				currentDrawbuffers.set( framebuffer, drawBuffers );

			}

			var textures = renderTarget.textures;

			if ( drawBuffers.length != textures.length || drawBuffers[ 0 ] != GL.COLOR_ATTACHMENT0 ) {

				for ( i in 0...textures.length ) {

					drawBuffers[ i ] = GL.COLOR_ATTACHMENT0 + i;

				}

				drawBuffers.length = textures.length;

				needsUpdate = true;

			}

		} else {

			if ( drawBuffers[ 0 ] != GL.BACK ) {

				drawBuffers[ 0 ] = GL.BACK;

				needsUpdate = true;

			}

		}

		if ( needsUpdate ) {

			GL.drawBuffers( drawBuffers );

		}

	}

	function useProgram( program ) {

		if ( currentProgram != program ) {

			GL.useProgram( program );

			currentProgram = program;

			return true;

		}

		return false;

	}

	static var equationToGL:Map<Int, Int> = [
		Constants.AddEquation => GL.FUNC_ADD,
		Constants.SubtractEquation => GL.FUNC_SUBTRACT,
		Constants.ReverseSubtractEquation => GL.FUNC_REVERSE_SUBTRACT,
        Constants.MinEquation = GL.MIN,
        Constants.MaxEquation = GL.MAX
    ];

	static var factorToGL:Map<Int, Int> = [
		Constants.ZeroFactor => GL.ZERO,
		Constants.OneFactor => GL.ONE,
		Constants.SrcColorFactor => GL.SRC_COLOR,
		Constants.SrcAlphaFactor => GL.SRC_ALPHA,
		Constants.SrcAlphaSaturateFactor => GL.SRC_ALPHA_SATURATE,
		Constants.DstColorFactor => GL.DST_COLOR,
		Constants.DstAlphaFactor => GL.DST_ALPHA,
		Constants.OneMinusSrcColorFactor => GL.ONE_MINUS_SRC_COLOR,
		Constants.OneMinusSrcAlphaFactor => GL.ONE_MINUS_SRC_ALPHA,
		Constants.OneMinusDstColorFactor => GL.ONE_MINUS_DST_COLOR,
		Constants.OneMinusDstAlphaFactor => GL.ONE_MINUS_DST_ALPHA,
		Constants.ConstantColorFactor => GL.CONSTANT_COLOR,
		Constants.OneMinusConstantColorFactor => GL.ONE_MINUS_CONSTANT_COLOR,
		Constants.ConstantAlphaFactor => GL.CONSTANT_ALPHA,
		Constants.OneMinusConstantAlphaFactor => GL.ONE_MINUS_CONSTANT_ALPHA
    ];

	function setBlending( blending, blendEquation, blendSrc, blendDst, blendEquationAlpha, blendSrcAlpha, blendDstAlpha, blendColor, blendAlpha, premultipliedAlpha ) {

		if ( blending == NoBlending ) {

			if ( currentBlendingEnabled == true ) {

				disable( GL.BLEND );
				currentBlendingEnabled = false;

			}

			return;

		}

		if ( currentBlendingEnabled == false ) {

			enable( GL.BLEND );
			currentBlendingEnabled = true;

		}

		if ( blending != CustomBlending ) {

			if ( blending != currentBlending || premultipliedAlpha != currentPremultipledAlpha ) {

				if ( currentBlendEquation != AddEquation || currentBlendEquationAlpha != AddEquation ) {

					GL.blendEquation( GL.FUNC_ADD );

					currentBlendEquation = AddEquation;
					currentBlendEquationAlpha = AddEquation;

				}

				if ( premultipliedAlpha ) {

					switch ( blending ) {

						case NormalBlending:
							GL.blendFuncSeparate( GL.ONE, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE_MINUS_SRC_ALPHA );
							break;

						case AdditiveBlending:
							GL.blendFunc( GL.ONE, GL.ONE );
							break;

						case SubtractiveBlending:
							GL.blendFuncSeparate( GL.ZERO, GL.ONE_MINUS_SRC_COLOR, GL.ZERO, GL.ONE );
							break;

						case MultiplyBlending:
							GL.blendFuncSeparate( GL.ZERO, GL.SRC_COLOR, GL.ZERO, GL.SRC_ALPHA );
							break;

						default:
							console.error( 'THREE.WebGLState: Invalid blending: ', blending );
							break;

					}

				} else {

					switch ( blending ) {

						case NormalBlending:
							gl.blendFuncSeparate( gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA );
							break;

						case AdditiveBlending:
							gl.blendFunc( gl.SRC_ALPHA, gl.ONE );
							break;

						case SubtractiveBlending:
							gl.blendFuncSeparate( gl.ZERO, gl.ONE_MINUS_SRC_COLOR, gl.ZERO, gl.ONE );
							break;

						case MultiplyBlending:
							gl.blendFunc( gl.ZERO, gl.SRC_COLOR );
							break;

						default:
							console.error( 'THREE.WebGLState: Invalid blending: ', blending );
							break;

					}

				}

				currentBlendSrc = null;
				currentBlendDst = null;
				currentBlendSrcAlpha = null;
				currentBlendDstAlpha = null;
				currentBlendColor.set( 0, 0, 0 );
				currentBlendAlpha = 0;

				currentBlending = blending;
				currentPremultipledAlpha = premultipliedAlpha;

			}

			return;

		}

		// custom blending

		blendEquationAlpha = blendEquationAlpha || blendEquation;
		blendSrcAlpha = blendSrcAlpha || blendSrc;
		blendDstAlpha = blendDstAlpha || blendDst;

		if ( blendEquation != currentBlendEquation || blendEquationAlpha != currentBlendEquationAlpha ) {

			gl.blendEquationSeparate( equationToGL[ blendEquation ], equationToGL[ blendEquationAlpha ] );

			currentBlendEquation = blendEquation;
			currentBlendEquationAlpha = blendEquationAlpha;

		}

		if ( blendSrc != currentBlendSrc || blendDst != currentBlendDst || blendSrcAlpha != currentBlendSrcAlpha || blendDstAlpha != currentBlendDstAlpha ) {

			gl.blendFuncSeparate( factorToGL[ blendSrc ], factorToGL[ blendDst ], factorToGL[ blendSrcAlpha ], factorToGL[ blendDstAlpha ] );

			currentBlendSrc = blendSrc;
			currentBlendDst = blendDst;
			currentBlendSrcAlpha = blendSrcAlpha;
			currentBlendDstAlpha = blendDstAlpha;

		}

		if ( blendColor.equals( currentBlendColor ) == false || blendAlpha != currentBlendAlpha ) {

			gl.blendColor( blendColor.r, blendColor.g, blendColor.b, blendAlpha );

			currentBlendColor.copy( blendColor );
			currentBlendAlpha = blendAlpha;

		}

		currentBlending = blending;
		currentPremultipledAlpha = false;

	}

	function setMaterial( material, frontFaceCW ) {

		material.side == DoubleSide
			? disable( gl.CULL_FACE )
			: enable( gl.CULL_FACE );

		var flipSided = ( material.side == BackSide );
		if ( frontFaceCW ) flipSided = ! flipSided;

		setFlipSided( flipSided );

		( material.blending == NormalBlending && material.transparent == false )
			? setBlending( NoBlending )
			: setBlending( material.blending, material.blendEquation, material.blendSrc, material.blendDst, material.blendEquationAlpha, material.blendSrcAlpha, material.blendDstAlpha, material.blendColor, material.blendAlpha, material.premultipliedAlpha );

		depthBuffer.setFunc( material.depthFunc );
		depthBuffer.setTest( material.depthTest );
		depthBuffer.setMask( material.depthWrite );
		colorBuffer.setMask( material.colorWrite );

		var stencilWrite = material.stencilWrite;
		stencilBuffer.setTest( stencilWrite );
		if ( stencilWrite ) {

			stencilBuffer.setMask( material.stencilWriteMask );
			stencilBuffer.setFunc( material.stencilFunc, material.stencilRef, material.stencilFuncMask );
			stencilBuffer.setOp( material.stencilFail, material.stencilZFail, material.stencilZPass );

		}

		setPolygonOffset( material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits );

		material.alphaToCoverage == true
			? enable( gl.SAMPLE_ALPHA_TO_COVERAGE )
			: disable( gl.SAMPLE_ALPHA_TO_COVERAGE );

	}

	//

	function setFlipSided( flipSided ) {

		if ( currentFlipSided != flipSided ) {

			if ( flipSided ) {

				gl.frontFace( gl.CW );

			} else {

				gl.frontFace( gl.CCW );

			}

			currentFlipSided = flipSided;

		}

	}

	function setCullFace( cullFace ) {

		if ( cullFace != CullFaceNone ) {

			enable( gl.CULL_FACE );

			if ( cullFace != currentCullFace ) {

				if ( cullFace == CullFaceBack ) {

					gl.cullFace( gl.BACK );

				} else if ( cullFace == CullFaceFront ) {

					gl.cullFace( gl.FRONT );

				} else {

					gl.cullFace( gl.FRONT_AND_BACK );

				}

			}

		} else {

			disable( gl.CULL_FACE );

		}

		currentCullFace = cullFace;

	}

	function setLineWidth( width ) {

		if ( width != currentLineWidth ) {

			if ( lineWidthAvailable ) gl.lineWidth( width );

			currentLineWidth = width;

		}

	}

	function setPolygonOffset( polygonOffset, factor, units ) {

		if ( polygonOffset ) {

			enable( gl.POLYGON_OFFSET_FILL );

			if ( currentPolygonOffsetFactor != factor || currentPolygonOffsetUnits != units ) {

				gl.polygonOffset( factor, units );

				currentPolygonOffsetFactor = factor;
				currentPolygonOffsetUnits = units;

			}

		} else {

			disable( gl.POLYGON_OFFSET_FILL );

		}

	}

	function setScissorTest( scissorTest ) {

		if ( scissorTest ) {

			enable( gl.SCISSOR_TEST );

		} else {

			disable( gl.SCISSOR_TEST );

		}

	}

	// texture

	function activeTexture( webglSlot ) {

		if ( webglSlot == undefined ) webglSlot = gl.TEXTURE0 + maxTextures - 1;

		if ( currentTextureSlot != webglSlot ) {

			gl.activeTexture( webglSlot );
			currentTextureSlot = webglSlot;

		}

	}

	function bindTexture( webglType, webglTexture, webglSlot ) {

		if ( webglSlot == undefined ) {

			if ( currentTextureSlot == null ) {

				webglSlot = gl.TEXTURE0 + maxTextures - 1;

			} else {

				webglSlot = currentTextureSlot;

			}

		}

		var boundTexture = currentBoundTextures[ webglSlot ];

		if ( boundTexture == undefined ) {

			boundTexture = { type: undefined, texture: undefined };
			currentBoundTextures[ webglSlot ] = boundTexture;

		}

		if ( boundTexture.type != webglType || boundTexture.texture != webglTexture ) {

			if ( currentTextureSlot != webglSlot ) {

				gl.activeTexture( webglSlot );
				currentTextureSlot = webglSlot;

			}

			gl.bindTexture( webglType, webglTexture || emptyTextures[ webglType ] );

			boundTexture.type = webglType;
			boundTexture.texture = webglTexture;

		}

	}

	function unbindTexture() {

		var boundTexture = currentBoundTextures[ currentTextureSlot ];

		if ( boundTexture != undefined && boundTexture.type != undefined ) {

			gl.bindTexture( boundTexture.type, null );

			boundTexture.type = undefined;
			boundTexture.texture = undefined;

		}

	}

	function compressedTexImage2D() {

		try {

			gl.compressedTexImage2D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function compressedTexImage3D() {

		try {

			gl.compressedTexImage3D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texSubImage2D() {

		try {

			gl.texSubImage2D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texSubImage3D() {

		try {

			gl.texSubImage3D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function compressedTexSubImage2D() {

		try {

			gl.compressedTexSubImage2D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function compressedTexSubImage3D() {

		try {

			gl.compressedTexSubImage3D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texStorage2D() {

		try {

			gl.texStorage2D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texStorage3D() {

		try {

			gl.texStorage3D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texImage2D() {

		try {

			gl.texImage2D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	function texImage3D() {

		try {

			gl.texImage3D( ...arguments );

		} catch ( error ) {

			console.error( 'THREE.WebGLState:', error );

		}

	}

	//

	function scissor( scissor ) {

		if ( currentScissor.equals( scissor ) == false ) {

			gl.scissor( scissor.x, scissor.y, scissor.z, scissor.w );
			currentScissor.copy( scissor );

		}

	}

	function viewport( viewport ) {

		if ( currentViewport.equals( viewport ) == false ) {

			gl.viewport( viewport.x, viewport.y, viewport.z, viewport.w );
			currentViewport.copy( viewport );

		}

	}

	function updateUBOMapping( uniformsGroup, program ) {

		var mapping = uboProgramMap.get( program );

		if ( mapping == undefined ) {

			mapping = new WeakMap();

			uboProgramMap.set( program, mapping );

		}

		var blockIndex = mapping.get( uniformsGroup );

		if ( blockIndex == undefined ) {

			blockIndex = gl.getUniformBlockIndex( program, uniformsGroup.name );

			mapping.set( uniformsGroup, blockIndex );

		}

	}

	function uniformBlockBinding( uniformsGroup, program ) {

		var mapping = uboProgramMap.get( program );
		var blockIndex = mapping.get( uniformsGroup );

		if ( uboBindings.get( program ) != blockIndex ) {

			// bind shader specific block index to global block point
			gl.uniformBlockBinding( program, blockIndex, uniformsGroup.__bindingPointIndex );

			uboBindings.set( program, blockIndex );

		}

	}

	//

	function reset() {

		// reset state

		gl.disable( gl.BLEND );
		gl.disable( gl.CULL_FACE );
		gl.disable( gl.DEPTH_TEST );
		gl.disable( gl.POLYGON_OFFSET_FILL );
		gl.disable( gl.SCISSOR_TEST );
		gl.disable( gl.STENCIL_TEST );
		gl.disable( gl.SAMPLE_ALPHA_TO_COVERAGE );

		gl.blendEquation( gl.FUNC_ADD );
		gl.blendFunc( gl.ONE, gl.ZERO );
		gl.blendFuncSeparate( gl.ONE, gl.ZERO, gl.ONE, gl.ZERO );
		gl.blendColor( 0, 0, 0, 0 );

		gl.colorMask( true, true, true, true );
		gl.clearColor( 0, 0, 0, 0 );

		gl.depthMask( true );
		gl.depthFunc( gl.LESS );

		depthBuffer.setReversed( false );

		gl.clearDepth( 1 );

		gl.stencilMask( 0xffffffff );
		gl.stencilFunc( gl.ALWAYS, 0, 0xffffffff );
		gl.stencilOp( gl.KEEP, gl.KEEP, gl.KEEP );
		gl.clearStencil( 0 );

		gl.cullFace( gl.BACK );
		gl.frontFace( gl.CCW );

		gl.polygonOffset( 0, 0 );

		gl.activeTexture( gl.TEXTURE0 );

		gl.bindFramebuffer( gl.FRAMEBUFFER, null );
		gl.bindFramebuffer( gl.DRAW_FRAMEBUFFER, null );
		gl.bindFramebuffer( gl.READ_FRAMEBUFFER, null );

		gl.useProgram( null );

		gl.lineWidth( 1 );

		gl.scissor( 0, 0, gl.canvas.width, gl.canvas.height );
		gl.viewport( 0, 0, gl.canvas.width, gl.canvas.height );

		// reset internals

		enabledCapabilities = {};

		currentTextureSlot = null;
		currentBoundTextures = {};

		currentBoundFramebuffers = {};
		currentDrawbuffers = new WeakMap();
		defaultDrawbuffers = [];

		currentProgram = null;

		currentBlendingEnabled = false;
		currentBlending = null;
		currentBlendEquation = null;
		currentBlendSrc = null;
		currentBlendDst = null;
		currentBlendEquationAlpha = null;
		currentBlendSrcAlpha = null;
		currentBlendDstAlpha = null;
		currentBlendColor = new Color( 0, 0, 0 );
		currentBlendAlpha = 0;
		currentPremultipledAlpha = false;

		currentFlipSided = null;
		currentCullFace = null;

		currentLineWidth = null;

		currentPolygonOffsetFactor = null;
		currentPolygonOffsetUnits = null;

		currentScissor.set( 0, 0, gl.canvas.width, gl.canvas.height );
		currentViewport.set( 0, 0, gl.canvas.width, gl.canvas.height );

		colorBuffer.reset();
		depthBuffer.reset();
		stencilBuffer.reset();

	}

	public var buffers:{color:ColorBuffer, depth:DepthBuffer, stencil:StencilBuffer};
}