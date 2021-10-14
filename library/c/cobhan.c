#include <stdint.h>
#include <stdlib.h>

//ICU requires round trip to UTF-16
//GNU libunistring doesn't
#include <unistr.h>
#include <unicase.h>

#include <string.h>
#include <stdio.h>

#include "cobhan.h"
#include "cJSON.h"

#define ISO639_LANG "en"

static int32_t validate_utf8(const char *input, int32_t input_len) {
    const uint8_t *invalid = u8_check((const uint8_t *)input, (size_t) input_len);
    if (invalid) {
        return ERR_INPUT_INVALID_UTF8;
    }
    return 0;
}

int32_t cobhan_input_string(const char *input, int32_t input_len, struct cobhan_str *str) {
    int result = validate_utf8(input, input_len);
    if (result != 0) {
        return result;
    }

    str->data = input;
    str->length = input_len;
    return 0;
}

int32_t cobhan_input_json(const char *input, int32_t input_len, struct cobhan_json *json) {
    const uint8_t *invalid =  u8_check((const uint8_t *)input, (size_t) input_len);
    if (invalid != NULL) {
        return ERR_INPUT_INVALID_UTF8;
    }

    json->cjson = cJSON_ParseWithLength((const char *)input, input_len);
    if (json->cjson == NULL) {
        return ERR_JSON_INPUT_DECODE_FAILED;
    }

    return 0;
}

int32_t cobhan_output_buffer(char *output, int32_t output_cap, struct cobhan_buf *buf) {
    buf->data = output;
    buf->capacity = output_cap;
    buf->length = 0;
    return 0;
}

int32_t cobhan_output_free_json(struct cobhan_json *json, struct cobhan_buf *buf) {
    //Technically this reduces our output_cap by one, because it writes a NULL terminator
    int result = cJSON_PrintPreallocated(json->cjson, buf->data, buf->capacity, 0);
    cJSON_Delete(json->cjson);

    if (result != 1) {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    int length = strlen(buf->data);
    buf->length = length;
    return length;
}

void cobhan_free_json(struct cobhan_json *json) {
    cJSON_Delete(json->cjson);
}

char* cobhan_cstr_contains(const char *haystack, struct cobhan_str *needle) {
    int haystack_len = strlen(haystack);
    return memmem(haystack, haystack_len, needle->data, needle->length);
}

char* cobhan_str_contains(struct cobhan_str *haystack, struct cobhan_str *needle) {
    return memmem(haystack->data, haystack->length, needle->data, needle->length);
}

int32_t cobhan_to_upper(struct cobhan_str *input, struct cobhan_buf *buffer, struct cobhan_str *output) {
    if (input->data == NULL) {
        return ERR_NULL_PTR;
    }

    if (input->length > buffer->capacity) {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }

    if (buffer->data == NULL) {
        return ERR_NULL_PTR;
    }

    size_t result_length = (size_t)buffer->capacity;
    unistring_uint8_t *result = u8_toupper((const uint8_t *)input->data, input->length, ISO639_LANG, NULL, (uint8_t *)buffer->data, &result_length);

    if (result != (uint8_t *)buffer->data) {
        // If result_length isn't large enough, u8_ct_toupper will allocate
        free(result);
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }

    output->data = buffer->data;
    output->length = result_length;
    return result_length;
}
