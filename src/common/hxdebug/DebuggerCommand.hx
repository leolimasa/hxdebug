package hxdebug;

class DebuggerCommand {

}

class BreakpointHit extends DebuggerCommand {
    public var file:String;
    public var line:Int;

    public function new() {
    }
}

class Stack extends DebuggerCommand {
    public var frames:Array<StackFrame>;

    public function new() {
    }

}

class Ok extends DebuggerCommand {
    public function new() {
    }
}

class BreakpointChange extends DebuggerCommand {
    public var breakpoints:Array<Breakpoint>;
}

class Breakpoint {
    public var file:String;
    public var line:Int;
    public var action:String;
}

class Continue extends DebuggerCommand {

}

class Wait extends DebuggerCommand {

}


class StepInto extends DebuggerCommand {

}

class Step extends DebuggerCommand {

}

class ShowStack extends DebuggerCommand {

}