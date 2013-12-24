package hxdebug;
import haxe.macro.Context;
class Builder {
    public static function build() {
        var injector = new Injector();
        Context.onGenerate(function(type) {
            injector.injectType(type);
        });
    }
}