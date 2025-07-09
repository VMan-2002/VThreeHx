package vman2002.vthreehx.renderers.shaders;

import vman2002.vthreehx.renderers.shaders.ShaderChunk;
import vman2002.vthreehx.renderers.shaders.ShaderLib;
import sys.io.File;
import sys.FileSystem;
import StringTools;

@:allow(ShaderChunk)
@:allow(ShaderLib)
/**
    Macro used to generate fields in `ShaderChunk` and `ShaderLib`
**/
private class ShaderSetBuilder {
    /**
        autogenerate fields lol
    **/
    public static macro function build(path:String):Array<Field> {
        var fields = Context.getBuildFields();

        var basepath = "assets/three_shaders/" + path + "/";
        var count = 0;
        for (thing in FileSystem.readDirectory(basepath)) {
            if (StringTools.endsWith(thing, ".glsl.js")) {
                var v = File.getContent(basepath + thing);
                v = StringTools.trim(v.substring(v.indexOf("`") + 1, v.lastIndexOf("`"))) + "\n";

                fields.push({
                    pos: Context.currentPos(),
                    name: thing,
                    meta: null,
                    kind: FieldType.FVar(macro:String, macro $a{v}),
                    doc: null,
                    access: [Access.APublic, Access.AStatic]
                });
            }
        }
        Context.info('[VThreeHx macro] Populated ${count} shader fields from ${basepath}', Context.currentPos());
        
        return fields;
    }
}