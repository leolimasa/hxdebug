package ;
import haxe.macro.Expr;
class Injector {
    public static function inject(exp: Expr) : Expr {
        return exp;
    }

    public static function makeBlock(exprs:Array<Expr>, pos:Position) : Expr {
        var result = new Array<Expr>();
        for (expr in exprs) {
            var file = expr.pos.file;
            var ex = macro trace("hit");
            trace(ex);
            result.push(ex);
            result.push(inject(expr));
        }

        return {
            expr: ExprDef.EBlock(result),
            pos: pos
        }
    }
}