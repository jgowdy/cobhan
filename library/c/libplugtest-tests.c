
#include <stdint.h>
#include <stdio.h>
#include <apr_base64.h>
#include "libplugtest.h"

void toUpperTest() {
    char input[] = "Initial value";
    int32_t input_len = sizeof(input) - 1;
    char output[input_len];
    int32_t result = toUpper(input, input_len, output, sizeof(output));
    if (result < 0) {
        printf("toUpper failed");
        return;
    }
    printf("Output: [%.*s]\n", result, output);
}

void base64EncodeTest() {
    char input[] = "Initial value";
    int input_len = sizeof(input) - 1;

    int output_len = apr_base64_encode_len(input_len);
    char output[output_len];

    int32_t result = base64Encode(input, input_len, output, output_len);
    if (result < 0) {
        printf("base64Encode failed");
        return;
    }
    printf("Output: [%.*s]\n", result, output);
}

void filterJsonTest() {
    char input[] = "{ \"test\": \"foo\", \"test2\": \"kittens\"}";
    int input_len = sizeof(input) - 1;
    char disallowed[] = "foo";
    int disallowed_len = sizeof(disallowed) - 1;
    char output[input_len + 16];

    int32_t result = filterJson(input, input_len, disallowed, disallowed_len, output, sizeof(output));
    if (result < 0) {
        printf("filterJson failed");
        return;
    }
    printf("Output: [%.*s]\n", result, output);
}

extern void init();

int main(void) {
    init();

    toUpperTest();
    base64EncodeTest();
    filterJsonTest();

}
