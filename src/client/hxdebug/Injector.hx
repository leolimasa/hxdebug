package hxdebug;
import haxe.macro.Type.ClassField;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import Std;
import sys.io.File;
import haxe.macro.ExprTools;
import haxe.macro.Expr;

/**
* Changes arbitrary code such that there will be a Debugger.hit() call inside every
* block.
**/
class Injector {

    private var files:Map<String,String>;

    public function new() {
        files = new Map<String, String>();
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

   /* public function injectType(type:Type) {
        //trace("INJECTING!!!");
        //trace(type);
       //var newFields = new Array<ClassField>();

      switch (type) {
            case (TInst(t, params)):
                var cls:ClassType = t.get();

                var fields = cls.fields.get();
                for (f in fields) {

                    switch (f.kind) {
                        case (FMethod(k)):
                            trace(f.type);
                            var exp = f.expr();
                            if (exp != null) {
                                var newMeth = inject(Context.getTypedExpr(exp));
                            }
                        case _:
                    }
                }
           case (_):
       }
    } */

    // ..................................................................................

    public function injectFields(fields:Array<Field>) : Array<Field> {
        var result = new Array<Field>();

        for (f in fields) {
            switch (f.kind) {
                case (FFun(fun)):

                    // Creates the new function declaration with injected blocks
                    var newFun = {
                        args: fun.args,
                        ret: fun.ret,
                        expr: inject(fun.expr),
                        params: fun.params
                    };

                    // Creates the
                    result.push({
                       name: f.name,
                       doc: f.doc,
                       access: f.access,
                       kind: FFun(newFun),
                       pos: f.pos,
                       meta: f.meta
                    });
                case (_):
                    result.push(f);
            }
        }
        return result;
    }

    // ..................................................................................

    /**
    * Will return an Expr object that is equivalent of the following:
    *
    * Debugger.hit([file], [min], [max])
    **/
    public function makeInjectExpr(pos:Position) {
        #if macro
        var p = Context.getPosInfos(pos);
        #else
        var p = pos;
        #end
        var file = p.file;
        var min = p.min;
        var line = findLineInFile(file, min);

        var exp = macro hxdebug.Debugger.hit($v{file}, $v{line});
        return {
            expr: exp.expr,
            pos: pos
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