package hxdebug;

class Variable {
    public var name:String;
    public var type:String;
    public var value:Dynamic;
    public var fields:Array<Field>;

    public function new() {
    }

}

class Field {
    public var name:String;
    public var type:String;

}