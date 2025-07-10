package vman2002.vthreehx.renderers.webgl;

class WebGLAnimation {
    public function new() {}

	public var context:WebGLRenderer = null;
	public var isAnimating = false;
	public var animationLoop = null;
	public var requestId = null;

	public function onAnimationFrame( time, frame ) {

		animationLoop( time, frame );

		requestId = context.requestAnimationFrame( onAnimationFrame );

	}

    public function start() {

        if ( isAnimating == true || animationLoop == null ) return;

        requestId = context.requestAnimationFrame( onAnimationFrame );

        isAnimating = true;

    }

    public function stop() {

        context.cancelAnimationFrame( requestId );

        isAnimating = false;

    }

    public function setAnimationLoop( callback ) {

        animationLoop = callback;

    }

    public function setContext( value ) {

        context = value;

    }
}