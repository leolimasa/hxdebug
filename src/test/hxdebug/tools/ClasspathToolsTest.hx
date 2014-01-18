package hxdebug.tools;

import haxe.unit.TestCase;

class ClasspathToolsTest extends TestCase {

    private function contains(arr:Array<String>, value:String) : Bool {
        for (v in arr) {
            if (v == value) {
                return true;
            }
        }
        return false;
    }

    public function testGetClassesInFile() {
        var resources = ClasspathTools.compilationRoot() + "resources";
        var classes = ClasspathTools.getClassesInFile(resources + "/Classes.hx");
        assertEquals("Class1", classes[0]);
        assertEquals("Class2", classes[1]);
    }

    public function testGetClassesInPackage() {
        var resources = ClasspathTools.compilationRoot() + "resources";
        var classes = ClasspathTools.getClassesInPackage(resources, "");

        assertTrue(contains(classes, "Class1"));
        assertTrue(contains(classes, "Class2"));
        assertTrue(contains(classes, "dummypackage.AnotherClass1"));
        assertTrue(contains(classes, "dummypackage.AnotherClass2"));

        classes = ClasspathTools.getClassesInPackage(resources,"dummypackage");
        assertEquals("dummypackage.AnotherClass1", classes[0]);
        assertEquals("dummypackage.AnotherClass2", classes[1]);
    }
}