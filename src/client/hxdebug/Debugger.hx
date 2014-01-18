package hxdebug;

class Debugger {
    public static var current:Debugger;
    public var stack:Array<StackFrame>;
    private var breakpoints:Map<String, Map<Int,Bool>>;

    public static function hit(file:String, line:Int) {
        if (current == null) {
            return;
        }
        current.hitLine(file, line);
    }

    // ..................................................................................

    public static function pushStack(self:Dynamic, metName:String, file:String,
    line:Int) {
        if (current == null) {
            return;
        }

        var frame = new StackFrame();
        frame.file = file;
        frame.line = line;
        frame.index = current.stack.length;
        frame.assignVar("this", self);
        current.stackPush(frame);
    }

    // ..................................................................................

    public static function popStack() {
        if (current == null) {
            return;
        }
        return current.stackPop();
    }

    // ..................................................................................

    private function new() {
        breakpoints = new Map<String, Map<Int, Bool>>();
        stack = new Array<StackFrame>();
    }

    // ..................................................................................

    /**
    * Adds and enables a new breakpoint
    **/
    public function addBreakpoint(file:String, line:Int) {
        if (!breakpoints.exists(file)) {
            breakpoints.set(file, new Map<Int,Bool>());
        }
        breakpoints[file].set(line, true);
    }

    // ..................................................................................

    /**
    * Removes a breakpoint from the map
    **/
    public function removeBreakpoint(file:String, line:Int) {
        if (!breakpoints.exists(file)) {
            return;
        }
        breakpoints[file].remove(line);
    }

    // ..................................................................................

    public function enableBreakpoint(file:String, line:Int) {
        if (!breakpoints.exists(file)) {
            addBreakpoint(file, line);
            return;
        }
        breakpoints[file].set(line, true);
    }

    // ..................................................................................

    public function disableBreakpoint(file:String, line:Int) {
        if (!breakpoints.exists(file) || !breakpoints[file].exists(line)) {
            return;
        }
        breakpoints[file].remove(line);
    }

    // ..................................................................................

    public function hitLine(file:String, line:Int) {
        if (breakpoints.exists(file)
        && breakpoints[file].exists(line)
        && breakpoints[file][line]) {
            onBreak(file, line);
        }
    }

    // ..................................................................................

    public function stackPush(frame:StackFrame) {
        stack.push(frame);
    }

    // ..................................................................................

    public function stackPop() : StackFrame {
        return stack.pop();
    }

    // ..................................................................................

    public function assignVar(name:String, value:Dynamic) {
        stack[stack.length].assignVar(name, value);
    }

    // ..................................................................................

    public function onBreak(file:String, line:Int) {
        // TO BE OVERRIDEN
    }
}