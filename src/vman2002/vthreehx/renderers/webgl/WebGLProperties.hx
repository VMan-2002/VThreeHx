package vman2002.vthreehx.renderers.webgl;


class WebGLProperties {
    var properties = new WeakMap<Dynamic, Dynamic>();

    public function new() {
    }

    public function has( object ) {

        return properties.exists( object );

    }

    public function get( object ) {

        var map:Dynamic = properties.get( object );

        if ( map == null ) {

            map = {};
            properties.set( object, map );

        }

        return map;

    }

    public function remove( object ) {

        properties.remove( object );

    }

    public function update( object, key, value ) {

        Reflect.setField(properties.get( object ), key, value);

    }

    public function dispose() {

        properties = new Map<Dynamic, Dynamic>();

    }

}