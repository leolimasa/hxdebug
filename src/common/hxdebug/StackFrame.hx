
package hxdebug;

import hxdebug.Variable.Field;

class StackFrame {
    public var index:Int;
    public var file: String;
    public var line: Int;
    public var locals(get,set):Array<Variable>;

    private var localVars: Map<String, Dynamic>;

    public function new() {

    }

    public function assignVar(varName:String, value:Dynamic) {
        localVars[varName] = value;
    }

    function get_locals() : Array<Variable> {
        //TODO
        var result = new Array<Variable>();
        for (k in localVars.keys()) {
            result.push(localVars[k]);
        }
        return result;
    }

    function set_locals(value:Array<Variable>) : Array<Variable> {
        //TODO
        for (v in value) {
            localVars.set(v.name, v);
        }
        return value;
    }
}