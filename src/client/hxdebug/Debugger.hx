package hxdebug;

class Debugger {
    public static function hit(file:String, line:Int) {
        trace("HIT " + file + ":" + line);
    }
}