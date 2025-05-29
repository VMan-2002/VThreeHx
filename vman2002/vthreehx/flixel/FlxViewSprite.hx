package vman2002.vthreehx.flixel;

#if flixel
class FlxViewSprite extends flixel.FlxSprite {
    public var renderer;
    public var scene;
    public var camera;

    public function new(renderer, scene, camera, ?x:Float = 0, ?y:Float = 0) {
        super(x, y);
        this.renderer = renderer;
        this.scene = scene;
        this.camera = camera;
    }
}
#end