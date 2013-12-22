package hxdebug;

import haxe.macro.ExprTools;
import hxdebug.Injector;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.unit.TestCase;
class InjectorTest extends TestCase {
    public function testMakeBlock() {
        var exprArr = new Array<Expr>();
        exprArr.push(macro var a = 1);
        exprArr.push(macro var b = 1);
        exprArr.push(macro if (a > b) trace("test"));

        var block = Injector.makeBlock(exprArr, {file: "test.hx", min:0, max: 0});
        switch (block.expr) {
            case ExprDef.EBlock(exprs):
                assertEquals(exprs.length, 6);
            default:
                assertTrue(false);
        }
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
        trace(ExprTools.toString(Injector.inject(e)));

    }
}