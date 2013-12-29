package hxdebug.tools;
import sys.io.File;


/**
* Singleton which caches file contents
**/
class FileCache {
    static var cache:Map<String, String>;

    public static function __init__() {
        cache = new Map<String, String>();
    }

    public static function readFile(filePath:String) {
        if (!cache.exists(filePath)) {
            var f = File.getContent(filePath);
            cache.set(filePath, f);
            return f;
        }
        return cache[filePath];
    }
}