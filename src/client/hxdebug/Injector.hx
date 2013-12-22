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

    public static function hitLine(file:String, ?p:PosInfos) {
        trace("HIT: " + file + ":" + p.lineNumber);
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
        var pInfos:PosInfos = Context.getPosInfos(position);

        var functionName = macro hxdebug.Injector.hitLine;
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
}