from cobhan import Cobhan

class Libplugtest(Cobhan):
    CDEFINES = """
        void sleepTest(int32_t seconds);
        int32_t addInt32(int32_t x, int32_t y);
        int64_t addInt64(int64_t x, int64_t y);
        double addDouble(double x, double y);
        int32_t toUpper(const char *input, int32_t inputLength, char *output, int32_t outputCapacity);
        int32_t filterJson(const char *input, int32_t inputLength, const char *disallowedValue, int32_t disallowedValueLen, char *output, int32_t outputCap);
        int32_t base64Encode(const char *input, int32_t inputLength, char *output, int32_t outputCap);
    """

    @classmethod
    def from_library_path(cls, library_root_path):
        instance = cls()
        instance._load_library(library_root_path, 'libplugtest', Libplugtest.CDEFINES)
        return instance

    @classmethod
    def from_library_file(cls, library_file_path):
        instance = cls()
        instance._load_library_direct(library_file_path, Libplugtest.CDEFINES)
        return instance

    def to_upper(self, input):
        buf = self.str_to_buf(input)

        result = self._lib.toUpper(buf, len(buf), buf, len(buf))
        if result < 0:
            raise Exception("toUpper failed")

        return self.buf_to_str(buf, result)

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

        result = self._lib.filterJson(input_buf, len(input_buf), disallowed_buf, len(disallowed_buf), output_buf, output_len)
        if result < 0:
            raise Exception("filterJson failed")

        return self.from_json_buf(output_buf, result)

    def base64Encode(self, input):
        input_buf = self.str_to_buf(input)
        output_len = int((4 * len(input_buf) / 3) + 3) & ~3
        output_buf = self.allocate_buf(output_len)

        result = self._lib.base64Encode(input_buf, len(input_buf), output_buf, output_len)
        if result < 0:
            raise Exception("base64Encode failed")

        return self.buf_to_str(output_buf, result)
