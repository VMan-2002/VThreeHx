package vman2002.vthreehx.flixel;

#if flixel
class FlxViewSprite extends flixel.FlxSprite {
    public var renderer:WebGLRenderer;
    public var scene:Scene;
    public var camera:Camera;

    public function new(renderer, scene, camera, ?x:Float = 0, ?y:Float = 0) {
        super(x, y);
        this.renderer = renderer;
        this.scene = scene;
        this.camera = camera;
    }

    public override function update(elapsed:Float) {
        scene.update(elapsed);
    }
}
#end