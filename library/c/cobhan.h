#ifndef _COBHAN_H
#define _COBHAN_H

#include <stdint.h>
#include "cJSON.h"

#define ERR_NONE 0

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

struct cobhan_str {
    int32_t length;
    const char *data;
};

struct cobhan_buf {
    int32_t capacity;
    int32_t length;
    char *data;
};

struct cobhan_json {
    cJSON *cjson;
};

int32_t cobhan_input_string(const char *input, int32_t input_len, struct cobhan_str *str);
int32_t cobhan_input_json(const char *input, int32_t input_len, struct cobhan_json *json);
void cobhan_free_json(struct cobhan_json *json);
int32_t cobhan_output_buffer(char *output, int32_t output_cap, struct cobhan_buf *buf);
int32_t cobhan_output_free_json(struct cobhan_json *json, struct cobhan_buf *buf);

int32_t cobhan_to_upper(struct cobhan_str *input, struct cobhan_buf *buffer, struct cobhan_str *output);
char* cobhan_cstr_contains(const char *haystack, struct cobhan_str *needle);
char* cobhan_str_contains(struct cobhan_str *haystack, struct cobhan_str *needle);

#endif
