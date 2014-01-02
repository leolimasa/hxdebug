package hxdebug;

import hxdebug.tools.ClasspathToolsTest;
import haxe.macro.Type.ClassField;
import haxe.unit.TestRunner;
class Main {
    public static function main() {
        var runner = new TestRunner();
        runner.add(new InjectorTest());
        runner.add(new ClasspathToolsTest());
        runner.run();
    }
}