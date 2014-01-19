package hxdebug;
import haxe.macro.Expr.Field;
import haxe.macro.Compiler;
import hxdebug.tools.ClasspathTools;
import haxe.macro.Context;

class Builder {

    /**
    * Cycles through every directory in the class path looking for classes to add a
    * @:build annotation. Only classes with the specified packages will be processed.
    * If no packages are specified, it will default to all packages.
    *
    **/
    public static function debug(?packages:Array<String>) {
        if (packages == null) packages = [""];

        var classPath:Array<String> = Context.getClassPath();

        // adds in the local directory
        classPath.push(Sys.getCwd());

        for (cp in classPath) {

            // don't search on root or empty
            if (cp == "/" || cp == "") {
                continue;
            }

            for (p in packages) {
                for (cls in ClasspathTools.getClassesInPackage(cp, p)) {
                    Compiler.addMetadata("@:build(hxdebug.Builder.build())", cls);
                    Compiler.keep(cls, null, true);
                }
            }
        }
    }

    // ..................................................................................

    macro public static function build() : Array<Field> {
        var fields = Context.getBuildFields();
        var injector = new Injector();
        var fs = injector.injectFields(fields);
        trace(Injector.timers);
        return fs;
    }
}