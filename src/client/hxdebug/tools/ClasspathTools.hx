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
     * Thanks to the mcover library for providing this
     */
    public static function getClassesInPackage(cp:String, pack:String) {
        var classes:Array<String> = [];
        var prefix:String = pack;
        var path:String = cp;

        if(pack != "") {
            prefix += ".";
            path += "/" + pack.split(".").join("/");
        }

        if (!FileSystem.exists(path) || !FileSystem.isDirectory(path)) return;

        for(file in FileSystem.readDirectory(path)) {
            var filePath = path + "/" + file;

            if (StringTools.endsWith(file, ".hx")) {
                classes.concat(getClassesInFile(filePath));
            }
            else if (FileSystem.isDirectory(filePath)) {
                classes.concat(getClassesInPackage(cp, prefix + file));
            }
        }
        return classes;
    }

    // ..................................................................................

    /**
    Parses the contents of a hx file and returns the found class names

    @param path - the file path to cache
     */
    public static function getClassesInFile(path:String) {
        var includes:Array<String> = [];
        var contents:String = FileCache.readFile(path);
        var prefix = getPackageDefinitionInFile(contents);
        var temp = contents;
        var regInclude = ~/^([^\*;]*)class ([A-Z]([A-Za-z0-9_])+)/m;

        while (regInclude.match(temp)) {
            var cls = prefix + regInclude.matched(2);
            includes.push(cls);
            temp = regInclude.matchedRight();
        }

        return includes;
    }

    // ..................................................................................

    /**
     * looks for a valid package definition in a class
     */
    public static function getPackageDefinitionInFile(contents:String):String {
        var reg:EReg = ~/^package ([a-z]([A-Za-z0-9\._])+);/m;
        if(reg.match(contents)) {
            return reg.matched(1) + ".";
        }
        return "";
    }
}