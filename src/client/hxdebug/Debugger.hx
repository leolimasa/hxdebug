package hxdebug;

class Debugger {
    public static var current:Debugger;
    private var breakpoints:Map<String, Map<Int,Bool>>;

    public static function hit(file:String, line:Int) {
        if (current == null) {
            return;
        }
        current.hitLine(file, line);
    }

    // ..................................................................................

    private function new() {
        breakpoints = new Map<String, Map<Int, Bool>>();
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

    public function onBreak(file:String, line:Int) {
        // TO BE OVERRIDEN
    }
}