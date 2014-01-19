package hxdebug;
import haxe.macro.Expr.Position;
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
        var t = Sys.time();
        switch (exp.expr) {
            case (ExprDef.EBlock(exprs)):
                this.exprs = exprs;
                this.pos = exp.pos;
            default:
                throw "Expression is not a BLOCK";
        }
        Injector.incTimer("BlockExp.new", t);
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
        var t = Sys.time();
        var blockexp = block.toExpr();

        fun.expr = blockexp;
        Injector.incTimer("FunctionExp.toExpr", t);
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

    public static var timers:Map<String, Float>;

    public static function __init__() {
        timers = new Map<String,Float>();
    }

    public static function incTimer(name:String, startTime:Float) {
        var t = 0.0;
        if (timers.exists(name)) {
            t = timers[name];
        }
        timers[name] = t + (Sys.time() - startTime);
    }

    public function new() {
        files = new Map<String, String>();
    }

    // ..................................................................................

    public function inject(exp: Expr) : Expr {
        var t = Sys.time();

        switch(exp.expr) {
            case ExprDef.EBlock(exprs):
                var e = makeBlock(exp);
                incTimer("inject", t);
                return e;
            case ExprDef.EFunction(name, f):
                var e = makeFunction(exp);
                incTimer("inject",t);
                return e;
            case _:
                var e = ExprTools.map(exp, inject);
                incTimer("inject",t);
                return e;
        }
    }

    // ..................................................................................

    public function injectFields(fields:Array<Field>) : Array<Field> {
        var t = Sys.time();
        var result = new Array<Field>();

        for (f in fields) {
            switch (f.kind) {
                case (FFun(fun)):

                    var expr = inject(fun.expr);

                    // Adds stack start and end
                    //var block = new BlockExp(expr);
                    //addStackHandlingToBlock(f.pos, f.name, block);

                    // Creates the new function declaration with injected blocks
                    var newFun = {
                        args: fun.args,
                        ret: fun.ret,
                        expr: expr,
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
        incTimer("injectFields", t);
        return result;
    }

    // ..................................................................................

    /**
    * Will return an Expr object that is equivalent of the following:
    *
    * Debugger.hit([file],[line])
    **/
    public function makeInjectExpr(pos:Position) {
        var t = Sys.time();

        #if macro
        var p = Context.getPosInfos(pos);
        #else
        var p = pos;
        #end
        var file = p.file;
        var min = p.min;
        var line = findLineInFile(file, min);

        var exp = macro hxdebug.Debugger.hit($v{file}, $v{line});

        incTimer("makeInjectExpr", t);
        return {
            expr: exp.expr,
            pos: pos
        }
    }

    // ..................................................................................

    public function makeStackStartExpr(pos:Position, funName:String) : Expr {
        var t = Sys.time();

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

        incTimer("makeStackStartExpr", t);
        return {
            expr: exp.expr,
            pos: pos
        };
    }

    // ..................................................................................

    public function makeStackEndExpr(pos:Position) : Expr {
        var t = Sys.time();

        var exp = macro hxdebug.Debugger.popStack();
        incTimer("makeStackEndExpr", t);
        return {
            expr: exp.expr,
            pos: pos
        };
    }

    // ..................................................................................

    public function makeBlock(expr : Expr) : Expr {
        var t = Sys.time();

        var block = new BlockExp(expr);

        var result = new Array<Expr>();
        for (expr in block.exprs) {
            result.push(makeInjectExpr(expr.pos));
            result.push(inject(expr));
        }

        block.exprs = result;
        incTimer("makeBlock", t);
        return block.toExpr();
    }

    // ..................................................................................

    private function makeFunction(expr : Expr) : Expr {
        var t = Sys.time();

        var fun = new FunctionExp(expr);
        fun.block = new BlockExp(makeBlock(fun.block.toExpr()));
        fun.block.exprs.insert(0, makeStackStartExpr(fun.pos, fun.name));
        fun.block.exprs.push(makeStackEndExpr(fun.pos));

        incTimer("makeFunction", t);
        return fun.toExpr();
    }

    // ..................................................................................

    /**
    * Returns the count of how many linebreaks there are in contents before the specified
    * position.
    **/
    public function charPosToLine(contents:String, pos:Int) : Int {
        var t = Sys.time();
        var stripped = contents.substr(0, pos);
        var count = 0;
        for (i in 0...stripped.length) {
            if (stripped.charAt(i) == '\n') {
                count++;
            }
        }
        incTimer("charPosToLine", t);
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



