package hxdebug.tools;

import hxdebug.tools.FileCache;
import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.Context;
import hxdebug.tools.FileCache;
import sys.FileSystem;

/**
* Utlity functions to extract class and package information from .hx files.
*
* Most of the code here was stolen from mcover. Check it out, they do some cool stuff:
* https://github.com/massiveinteractive/MassiveCover
**/
class ClasspathTools {

    /**
     * Recursively searches a package within a class path for matching classes
     *
     * Thanks to the mcover library for providing this.
     */
    public static function getClassesInPackage(cp:String, pack:String) : Array<String> {
        var classes:Array<String> = [];
        var prefix:String = pack;
        var path:String = cp;

        if(pack != "") {
            prefix += ".";
            path += "/" + pack.split(".").join("/");
        }

        if (!FileSystem.exists(path) || !FileSystem.isDirectory(path)) return classes;

        for(file in FileSystem.readDirectory(path)) {
            var filePath = path + "/" + file;

            if (StringTools.endsWith(file, ".hx")) {
                classes = classes.concat(getClassesInFile(filePath));
            }
            else if (FileSystem.isDirectory(filePath)) {
                classes = classes.concat(getClassesInPackage(cp, prefix + file));
            }
        }
        return classes;
    }

    // ..................................................................................

    /**
    Parses the contents of a hx file and returns the found class names

    @param path - the file path to cache
     */
    public static function getClassesInFile(path:String) : Array<String> {
        var includes:Array<String> = [];
        var contents:String = FileCache.readFile(path);
        var prefix = getPackageDefinitionInFile(contents);
        var temp = contents;
        var regInclude = ~/^\s*class ([A-Z]([A-Za-z0-9_])+)/m;

        while (regInclude.match(temp)) {
            var cls = prefix + regInclude.matched(1);
            includes.push(cls);
            temp = regInclude.matchedRight();
        }
        return includes;
    }

    // ..................................................................................

    /**
     * looks for a valid package definition in a class
     */
    public static function getPackageDefinitionInFile(contents:String) : String {
        var reg:EReg = ~/^package ([a-z]([A-Za-z0-9\._])+);/m;
        if(reg.match(contents)) {
            return reg.matched(1) + ".";
        }
        return "";
    }

    // ..................................................................................

    /**
    * Returns the file name of the source file calling this method.
    *
    **/
    public static function currentFile(?p:haxe.PosInfos) : String {
        return p.fileName;
    }

    // ..................................................................................

    /**
    * Returns the full path of the source file calling this method at compile time
    **/
    macro public static function currentFileFullPath() : Expr {
        var pos = Context.getPosInfos(Context.currentPos());
        var file = pos.file;
        return macro $v{file};
    }

    // ..................................................................................

    /**
    * Returns the root directory in which the caller was originally compiled.
    *
    * Example: if I place a compilationRoot() under /home/me/haxeproject/packname/Test.hx
    * and Test.hx is inside the packname package, then it will return
    * "/home/me/haxeproject/"
    **/
    macro public static function compilationRoot() : Expr {
        var pos = Context.getPosInfos(Context.currentPos());
        var fullPath:String = pos.file;
        var pack = getPackageDefinitionInFile(FileCache.readFile(fullPath));
        var packageDir = pack.split(".").join("/");
        var root = fullPath.substr(0, fullPath.indexOf(packageDir));
        return macro $v{root};
    }
}