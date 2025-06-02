package vman2002.vthreehx.renderers.webgl;

class WebGLProperties {

    public function new() {
        //TODO: This is originally a WeakMap, this implementation may not garbage collect as intended
        var properties = new Map<Dynamic, Dynamic>();

        public function has( object ) {

            return properties.exists( object );

        }

        public function get( object ) {

            var map = properties.get( object );

            if ( map == undefined ) {

                map:Dynamic = {};
                properties.set( object, map );

            }

            return map;

        }

        public function remove( object ) {

            properties.delete( object );

        }

        public function update( object, key, value ) {

            Reflect.setField(properties.get( object ), key, value);

        }

        public function dispose() {

            properties = new Map<Dynamic, Dynamic>();

        }
    }

}