import haxe.PosInfos;
import haxe.macro.Context;
import haxe.macro.Expr;

@:build(hxdebug.Builder.build())
class Hello {

    public static function main() {
        trace("Hello world!");
    }
}