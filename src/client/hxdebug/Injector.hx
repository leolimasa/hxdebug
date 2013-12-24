package hxdebug;
import haxe.macro.Type;
import Std;
import sys.io.File;
import haxe.macro.ExprTools;
import haxe.macro.Expr;

/**
* Changes arbitrary code such that there will be a Debugger.hit() call inside every
* block.
**/
class Injector {

    private var files:Map<String,String> = new Map<String, String>();

    public function new() {

    }

    // ..................................................................................

    public function inject(exp: Expr) : Expr {
        switch(exp.expr) {
            case ExprDef.EBlock(exprs):
                return makeBlockFromExpr(exp);

            case _:
                return ExprTools.map(exp, inject);
        }
    }

    // ..................................................................................

    public function injectType(type:Type) {
        switch (type) {
            case (TInst(t, params)):
                var cls:ClassType = t.get();
                var fields:Array<ClassField> = cls.fields.get();
                for (f in fields) {
                    var newField = {

                    };
                }
        }
    }

    // ..................................................................................

    /**
    * Will return an Expr object that is equivalent of the following:
    *
    * Debugger.hit([file], [min], [max])
    **/
    public function makeInjectExpr(position: Position) {
        var file = position.file;
        var line = findLineInFile(file, position.min);

        // Construct function
        var functionName = macro hxdebug.Debugger.hit;
        var functionParam1 = {
            expr: ExprDef.EConst(Constant.CString(file)),
            pos: position
        };
        var functionParam2 = {
            expr: ExprDef.EConst(Constant.CInt(Std.string(line))),
            pos: position
        };

        // Return the full expression
        return {
            expr: ExprDef.ECall(
                functionName,
                [functionParam1, functionParam2]
            ),
            pos: position
        }
    }

    // ..................................................................................

    public function makeBlock(exprs:Array<Expr>, pos:Position) : Expr {
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

    // ..................................................................................

    public function makeBlockFromExpr(expr : Expr) : Expr {
        switch(expr.expr) {
            case ExprDef.EBlock(exprs):
                return makeBlock(exprs, expr.pos);
            default:
                return expr;
        }
    }

    // ..................................................................................

    /**
    * Returns the count of how many linebreaks there are in contents before the specified
    * position.
    **/
    public function charPosToLine(contents:String, pos:Int) : Int {
        var stripped = contents.substr(0, pos);
        var count = 0;
        for (i in 0...stripped.length) {
            if (stripped.charAt(i) == '\n') {
                count++;
            }
        }
        return count + 1;
    }

    // ..................................................................................

    /**
    * Returns which line number the specified character position is within a file.
    **/
    public function findLineInFile(file:String, pos:Int) : Int {
        if (!files.exists(file)) {
            var f = File.getContent(file);
            files.set(file, f);
        }
        return charPosToLine(files[file], pos);
    }
}