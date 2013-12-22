package hxdebug;

import haxe.unit.TestRunner;
class Main {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new InjectorTest());
        runner.run();
    }
}