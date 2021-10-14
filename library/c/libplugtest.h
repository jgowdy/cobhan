#ifndef _LIBPLUGTEST_H
#define _LIBPLUGTEST_H

#include <stdint.h>

//One of the provided input pointers is NULL / nil / 0
#define ERR_NULL_PTR -1

//One of the provided input buffer lengths is too large
#define ERR_INPUT_BUFFER_TOO_LARGE -2

//One of the provided output buffers was too small to receive the output
#define ERR_OUTPUT_BUFFER_TOO_SMALL -3

//Failed to copy the output into the output buffer (copy length != expected length)
#define ERR_COPY_FAILED -4

//Failed to decode a JSON input buffer
#define ERR_JSON_INPUT_DECODE_FAILED -5

//Failed to encode to JSON output buffer
#define ERR_JSON_OUTPUT_ENCODE_FAILED -6

#define ERR_INPUT_INVALID_UTF8 -7

void sleepTest(int32_t seconds);
int32_t addInt32(int32_t x, int32_t y);
int64_t addInt64(int64_t x, int64_t y);
double addDouble(double x, double y);
int32_t toUpper(const char *input, int32_t input_len, char *output, int32_t output_cap);
int32_t filterJson(const char *input, int32_t input_len, const char *disallowed_value, int32_t disallowed_value_len, char *output, int32_t output_cap);
int32_t base64Encode(const char *input, int32_t input_len, char *output, int32_t output_cap);

#endif
