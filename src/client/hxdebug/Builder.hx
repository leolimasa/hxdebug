package hxdebug;
import haxe.macro.Expr.Field;
import haxe.macro.Context;

class Builder {

    public static function generate() {
        /*var injector = new Injector();
        Context.onGenerate(function(types) {
            for (type in types) {
                injector.injectType(type);
            }
        });*/
    }

    macro public static function build() : Array<Field> {
        var fields = Context.getBuildFields();
        var injector = new Injector();
        return injector.injectFields(fields);
    }

}