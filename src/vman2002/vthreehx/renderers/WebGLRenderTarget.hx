package vman2002.vthreehx.renderers;

import vman2002.vthreehx.core.RenderTarget;

/**
 * A render target used in context of {@link WebGLRenderer}.
 *
 * @augments RenderTarget
 */
class WebGLRenderTarget extends RenderTarget {

	/**
	 * Constructs a new 3D render target.
	 *
	 * @param {number} [width=1] - The width of the render target.
	 * @param {number} [height=1] - The height of the render target.
	 * @param {RenderTarget~Options} [options] - The configuration object.
	 */
	public function new( width = 1, height = 1, options = {} ) {

		super( width, height, options );

	}

}