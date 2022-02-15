from cobhan.cobhan import Cobhan

class Asherah(Cobhan):
    CDEFINES = """
        void sleepTest(int32_t seconds);
        int32_t addInt32(int32_t x, int32_t y);
        int64_t addInt64(int64_t x, int64_t y);
        double addDouble(double x, double y);
        int32_t toUpper(void *input, void *output);
        int32_t filterJson(void *input, void *disallowedValue, void *output);
        int32_t base64Encode(void *input, void *output);
    """

    @classmethod
    def from_library_path(cls, library_root_path):
        instance = cls()
        instance._load_library(library_root_path, 'cobhan-demo-lib', CobhanDemoLib.CDEFINES)
        return instance

    @classmethod
    def from_library_file(cls, library_file_path):
        instance = cls()
        instance._load_library_direct(library_file_path, CobhanDemoLib.CDEFINES)
        return instance

    def to_upper(self, input):
        in_buf = self.str_to_buf(input)
        out_buf = self.allocate_buf(len(in_buf))

        result = self._lib.toUpper(in_buf, out_buf)
        if result < 0:
            raise Exception(f"toUpper failed {result}")

        return self.buf_to_str(out_buf)

    def sleep_test(self, seconds):
        self._lib.sleepTest(seconds)

    def add_int32(self, x, y):
        return self._lib.addInt32(x, y)

    def add_int64(self, x, y):
        return self._lib.addInt64(x, y)

    def add_double(self, x, y):
        return self._lib.addDouble(x, y)

    def filterJson(self, input, disallowed):
        input_buf = self.to_json_buf(input)

        disallowed_buf = self.str_to_buf(disallowed)

        output_len = int(len(input_buf) * 1.5) # Allow extra space for reformatting
        output_buf = self.allocate_buf(output_len)

        result = self._lib.filterJson(input_buf, disallowed_buf, output_buf)
        if result < 0:
            raise Exception(f"filterJson failed {result}")

        return self.from_json_buf(output_buf)

    def base64Encode(self, input):
        input_buf = self.str_to_buf(input)
        output_len = int((4 * len(input_buf) / 3) + 3) & ~3
        output_buf = self.allocate_buf(output_len)

        result = self._lib.base64Encode(input_buf, output_buf)
        if result < 0:
            raise Exception(f"base64Encode failed {result}")

        return self.buf_to_str(output_buf)
