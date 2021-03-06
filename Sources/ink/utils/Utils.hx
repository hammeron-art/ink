package ink.utils;

class Utils {

	// Generate unique string ID
	public static function uniqueID(?val:Null<Int>):String {
		// http://www.anotherchris.net/csharp/friendly-unique-id-generation-part-2/#base62

		if(val == null) {
            #if neko val = Std.random(0x3FFFFFFF);
            #else val = Std.random(0x7fffffff);
            #end
        }

        function to_char(value:Int) : String {
            if (value > 9) {
                var ascii = (65 + (value - 10));

                if (ascii > 90)
					ascii += 6;

                return String.fromCharCode(ascii);
            } else {
				return Std.string(value).charAt(0);
			}
        }

        var r = Std.int(val % 62);
        var q = Std.int(val / 62);

        if (q > 0)
			return uniqueID(q) + to_char(r);
        else
			return Std.string(to_char(r));
	}

	public static inline function int(bool:Bool):Int {
		if (bool)
			return 1;

		return 0;
	}

}