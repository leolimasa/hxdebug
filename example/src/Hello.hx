import haxe.PosInfos;
import haxe.macro.Context;
import haxe.macro.Expr;

class Hello {


    public static function main() {

        out();
    }

    public static macro function out() {
        var ex = macro trace("Hello there!");
        trace(Context.getPosInfos(ex.pos));
        return ex;
    }
}