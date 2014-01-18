package hxdebug;
import hxdebug.tools.FileCache;
import haxe.macro.Type.ClassField;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import Std;
import sys.io.File;
import haxe.macro.ExprTools;
import haxe.macro.Expr;

class BlockExp {
    public var exprs:Array<Expr>;
    public var pos:Position;

    public function new(exp:Expr) {
        switch (exp.expr) {
            case (ExprDef.EBlock(exprs)):
                this.exprs = exprs;
                this.pos = exp.pos;
            default:
                throw "Expression is not a BLOCK";
        }
    }

    public function toExpr() {
        return {
            expr: ExprDef.EBlock(exprs),
            pos: pos
        }
    }
}

class FunctionExp {
    public var name:String;
    public var block:BlockExp;
    public var pos:Position;
    private var fun:Function;

    public function new(exp:Expr) {
        switch (exp.expr) {
            case (ExprDef.EFunction(name, f)):
                this.block = new BlockExp(f.expr);
                this.pos = exp.pos;
                this.fun = f;
            default:
                throw "Expression is not a FUNCTION";
        }
    }

    public function toExpr() : Expr {
        var blockexp = block.toExpr();

        fun.expr = blockexp;

        return {
            expr: ExprDef.EFunction(name, fun),
            pos: this.pos
        }
    }
}

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
                return makeBlock(exp);
            case ExprDef.EFunction(name, f):
                return makeFunction(exp);
            case _:
                return ExprTools.map(exp, inject);
        }
    }

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

                    // Creates the field with the new function
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
    * Debugger.hit([file],[line])
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

    public function makeStackStartExpr(pos:Position, funName:String) : Expr {
        #if macro
        var p = Context.getPosInfos(pos);
        #else
        var p = pos;
        #end
        var file = p.file;
        var min = p.min;
        var line = findLineInFile(file, min);
        var exp =  macro hxdebug.Debugger.pushStack(this, $v{funName}, $v{file},
        $v{line});

        return {
            expr: exp.expr,
            pos: pos
        };
    }

    // ..................................................................................

    public function makeStackEndExpr(pos:Position) : Expr {
        var exp = macro hxdebug.Debugger.popStack();
        return {
            expr: exp.expr,
            pos: pos
        };
    }

    // ..................................................................................

    public function makeBlock(expr : Expr) : Expr {
        var block = new BlockExp(expr);

        var result = new Array<Expr>();
        for (expr in block.exprs) {
            result.push(makeInjectExpr(expr.pos));
            result.push(inject(expr));
        }

        block.exprs = result;
        return block.toExpr();
    }

    // ..................................................................................

    private function makeFunction(expr : Expr) : Expr {
        var fun = new FunctionExp(expr);
        fun.block = new BlockExp(makeBlock(fun.block.toExpr()));

        fun.block.exprs.insert(0, makeStackStartExpr(fun.pos, fun.name));
        fun.block.exprs.push(makeStackEndExpr(fun.pos));

        return fun.toExpr();
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
        return charPosToLine(FileCache.readFile(file), pos);
    }
}



