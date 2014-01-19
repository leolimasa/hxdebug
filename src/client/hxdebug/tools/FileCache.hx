package hxdebug.tools;
import sys.io.File;


/**
* Singleton which caches file contents
**/
class FileCache {
    static var cache:Map<String, String>;

    /**
    * Stores the relationship between character position and which line that character
    * is in the specified file.
    **/
    static var linesCache:Map<String,Array<Int>>;

    public static function __init__() {
        cache = new Map<String, String>();
        linesCache = new Map<String,Array<Int>>();
    }

    public static function readFile(filePath:String) : String {
        if (!cache.exists(filePath)) {
            var f = File.getContent(filePath);
            cache.set(filePath, f);
            return f;
        }
        return cache[filePath];
    }

    public static function readLines(filePath:String) {
        var contents = readFile(filePath);
        var currentLine = 1;
        var lines = new Array<Int>();

        for (i in 0...contents.length) {
            lines.push(currentLine);
            if (contents.charAt(i) == '\n') {
                currentLine++;
            }
        }

        linesCache[filePath] = lines;
    }

    public static function findLine(file:String, pos:Int) {
        if (!linesCache.exists(file)) {
            readLines(file);
        }
        return linesCache[file][pos];
    }
}