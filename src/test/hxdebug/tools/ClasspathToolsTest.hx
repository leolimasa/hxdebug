package hxdebug.tools;

import haxe.unit.TestCase;

class ClasspathToolsTest extends TestCase {
    public function testGetClassesInFile() {
        var resources = ClasspathTools.compilationRoot() + "resources";
        var classes = ClasspathTools.getClassesInFile(resources + "/Classes.hx");
        assertEquals("Class1", classes[0]);
        assertEquals("Class2", classes[1]);
    }

    public function testGetClassesInPackage() {
        var resources = ClasspathTools.compilationRoot() + "resources";
        var classes = ClasspathTools.getClassesInPackage(resources, "");
        assertEquals("Class1", classes[0]);
        assertEquals("Class2", classes[1]);
        assertEquals("dummypackage.AnotherClass1", classes[2]);
        assertEquals("dummypackage.AnotherClass2", classes[3]);

        classes = ClasspathTools.getClassesInPackage(resources,"dummypackage");
        assertEquals("dummypackage.AnotherClass1", classes[0]);
        assertEquals("dummypackage.AnotherClass2", classes[1]);
    }
}