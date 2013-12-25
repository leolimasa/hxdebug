package hxdebug;
import haxe.macro.Context;

class Builder {

    public static function build() {
        var injector = new Injector();
        Context.onGenerate(function(types) {
            for (type in types) {
                injector.injectType(type);
            }
        });
    }

}