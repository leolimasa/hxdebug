package hxdebug;

import haxe.macro.Type.TypedExpr;
import haxe.macro.ExprTools;
import hxdebug.Injector;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.unit.TestCase;
import haxe.CallStack;

class MockInjector extends Injector {
    public override function makeInjectExpr(position: Position) {
        return macro trace("hi");
    }
}

class InjectorTest extends TestCase {

    var inj:Injector;

    public override function setup() {
        super.setup();
        inj = new MockInjector();
    }

    public function testInject() {
        var e = macro if (a > b) {
            var c = 1;
            var d = 2;
            for (e in f) {
                call1("arg");
                call2("arg");
            }
            trace("test");
        }
        var expect = "if(a > b) {
\ttrace(\"hi\");
\tvar c = 1;
\ttrace(\"hi\");
\tvar d = 2;
\ttrace(\"hi\");
\tfor(e in f) {
\t\ttrace(\"hi\");
\t\tcall1(\"arg\");
\t\ttrace(\"hi\");
\t\tcall2(\"arg\");
\t};
\ttrace(\"hi\");
\ttrace(\"test\");
} ";
        assertEquals(expect, ExprTools.toString(inj.inject(e)));
    }

    public function testMakeBlock() {
        var exprArr = new Array<Expr>();
        exprArr.push(macro var a = 1);
        exprArr.push(macro var b = 1);
        exprArr.push(macro if (a > b) trace("test"));

        var block = inj.makeBlock(exprArr, {file: "test.hx", min:0, max: 0});
        switch (block.expr) {
            case ExprDef.EBlock(exprs):
                assertEquals(exprs.length, 6);
            default:
                assertTrue(false);
        }

    }

    public function testPosToLine() {
        var cont = "line1\r\nline2\r\nline3";

        var c = macro : {
        function extraMethod() {
        var foo = 5,
        bar = 4;
        return foo + bar;
        }
        };
        trace(c);
        trace(Injector);

        assertEquals(1, inj.charPosToLine(cont, 2));
        assertEquals(2, inj.charPosToLine(cont, 7));
        assertEquals(3, inj.charPosToLine(cont, 15));
    }


}