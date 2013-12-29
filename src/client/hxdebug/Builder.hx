package hxdebug;
import ClasspathTools;
import hxdebug.tools.FileCache;
import FileCache;
import haxe.ds.StringMap;
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Type.ClassType;
import haxe.macro.Compiler;
import haxe.macro.Expr.Field;
import haxe.macro.Context;

class Builder {

    public static function debug(?packages:Array<String>) {
        if (packages == null) {
            packages = [""];
        }

        var processedClasses = [];

        for (p in packages) {
            for (cls in ClasspathTools.getClassesInPackage(p)) {
                Compiler.addMetadata("@:build(hxdebug.Builder.build())", cls);
                Compiler.keep(className, null, true);
            }
        }
    }

    // ..................................................................................

    macro public static function build() : Array<Field> {
        var fields = Context.getBuildFields();
        var injector = new Injector();
        return injector.injectFields(fields);
    }



}