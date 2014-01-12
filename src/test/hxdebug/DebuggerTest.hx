package hxdebug;

import hxdebug.Debugger;
import haxe.unit.TestCase;

class DebuggerImpl extends Debugger {
    public var fileName:String = "";
    public var lineNum:Int = 0;

    public function new() {
        super();
    }

    public override function onBreak(file:String, line:Int) {
        lineNum = line;
        fileName = file;
    }

}

class DebuggerTest extends TestCase {
    public function testBreakpoints() {
        var dbg = new DebuggerImpl();

        dbg.addBreakpoint("file1.txt", 30);
        dbg.addBreakpoint("file1.txt", 40);
        dbg.addBreakpoint("file2.txt", 42);

        dbg.hitLine("file1.txt", 10);
        assertEquals("", dbg.fileName);
        assertEquals(0, dbg.lineNum);

        dbg.hitLine("somefile.txt", 77);
        assertEquals("", dbg.fileName);
        assertEquals(0, dbg.lineNum);

        dbg.hitLine("file1.txt", 40);
        assertEquals("file1.txt", dbg.fileName);
        assertEquals(40, dbg.lineNum);

        dbg.disableBreakpoint("file1.txt", 30);
        dbg.lineNum = 0;
        dbg.fileName = "";
        dbg.hitLine("file1.txt", 30);
        assertEquals("", dbg.fileName);
        assertEquals(0, dbg.lineNum);

        dbg.enableBreakpoint("file1.txt", 30);
        dbg.hitLine("file1.txt", 30);
        assertEquals("file1.txt", dbg.fileName);
        assertEquals(30, dbg.lineNum);

        dbg.removeBreakpoint("file1.txt", 30);
        dbg.lineNum = 0;
        dbg.fileName = "";
        dbg.hitLine("file1.txt", 30);
        assertEquals("", dbg.fileName);
        assertEquals(0, dbg.lineNum);

    }

}