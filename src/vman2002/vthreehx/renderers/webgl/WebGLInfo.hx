package vman2002.vthreehx.renderers.webgl;

class WebGLInfo {
    public var gl:GL;
    public function new(gl) {
        this.gl = gl;
    }

    public var autoReset:Bool = true;
    public var programs = null;

	public var memory = {
		geometries: 0,
		textures: 0
	};

	public var render = {
		frame: 0,
		calls: 0,
		triangles: 0,
		points: 0,
		lines: 0
	};

	public function update( count, mode, instanceCount ) {

		render.calls ++;

		if (mode == GL.TRIANGLES) {
			render.triangles += Std.int(instanceCount * ( count / 3 ));
			return;
		}
		if (mode == GL.LINES) {
			render.lines += Std.int(instanceCount * ( count / 2 ));
			return;
		}
		if (mode == GL.LINE_STRIP) {
			render.lines += instanceCount * ( count - 1 );
			return;
		}
		if (mode == GL.LINE_LOOP) {
			render.lines += instanceCount * count;
			return;
		}
		if (mode == GL.POINTS) {
			render.points += instanceCount * count;
			return;
		}
		Common.error( 'THREE.WebGLInfo: Unknown draw mode:', mode );
	}

	public function reset() {
		render.calls = 0;
		render.triangles = 0;
		render.points = 0;
		render.lines = 0;
	}
}