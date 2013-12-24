package hxdebug;
import haxe.macro.Context;
import haxe.PosInfos;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
class Injector {

    public static function inject(exp: Expr) : Expr {
        var e:ExprDef;

        switch(exp.expr) {
            case ExprDef.EBlock(exprs):
                return makeBlockFromExpr(exp);

            case _:
                return ExprTools.map(exp, inject);
        }
    }

    /**
    * Will return an Expr object that is equivalent of the following:
    *
    * Debugger.hit([file], [min], [max])
    **/
    private static function makeInjectExpr(position: Position) {
        var file = position.file;
        var min = position.min;
        var max = position.max;

        var functionName = macro hxdebug.Debugger.hit;
        var functionParam = {
            expr: ExprDef.EConst(Constant.CString(file)),
            pos: position
        };

        return {
            expr: ExprDef.ECall(
                functionName,
                [functionParam]
            ),
            pos: position
        }
    }

    public static function makeBlock(exprs:Array<Expr>, pos:Position) : Expr {
        var result = new Array<Expr>();
        for (expr in exprs) {
            result.push(makeInjectExpr(expr.pos));
            result.push(inject(expr));
        }

        return {
            expr: ExprDef.EBlock(result),
            pos: pos
        }
    }

    public static function makeBlockFromExpr(expr : Expr) : Expr {
        switch(expr.expr) {
            case ExprDef.EBlock(exprs):
                return makeBlock(exprs, expr.pos);
            default:
                return expr;
        }
    }

    /**
    * Returns the count of how many linebreaks there are in contents before the specified
    * position.
    **/
    public static function posToLine(pos:Position, contents:String) {
        var stripped = contents.substr(0, pos.min);
        var count = 0;
        for (i in 0...stripped.length) {
            if (stripped.charAt(i) == '\n') {
                count++;
            }
        }
        return count + 1;
    }
}