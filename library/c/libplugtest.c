#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

/*
Technically we don't need to pull in APR just for base64.
However, having APR gives us memory pools and other facilities
for any future examples.
*/
#include <apr.h>
#include <apr_general.h>
#include <apr_pools.h>
#include <apr_base64.h>

#include "cobhan.h"
#include "libplugtest.h"
//APR's JSON support never got released as it's part of APR2
#include "cJSON.h"

apr_pool_t *pool;

void init() {
    apr_status_t result = apr_initialize();
    if (result != APR_SUCCESS) {
        abort();
    }
    atexit(apr_terminate);
    apr_pool_create(&pool, NULL);
}

void sleepTest(int32_t seconds) {
    sleep(seconds);
}

int32_t addInt32(int32_t x, int32_t y) {
    return x + y;
}

int64_t addInt64(int64_t x, int64_t y) {
    return x + y;
}

double addDouble(double x, double y) {
    return x + y;
}

int32_t toUpper(const char *input, int32_t input_len, char *output, int32_t output_cap) {
    struct cobhan_str str, output_str;
    int32_t result = input_string(input, input_len, &str);
    if (result != 0) {
        return result;
    }

    struct cobhan_buf output_buf;
    result = output_buffer(output, output_cap, &output_buf);
    if (result != 0) {
        return result;
    }

    result = to_upper(&str, &output_buf, &output_str);
    if (result < 0) {
        return result;
    }
    return (int32_t)output_str.length;
}

int32_t filterJson(const char *input, int32_t input_len, const char *disallowed_value, int32_t disallowed_value_len, char *output, int32_t output_cap) {
    struct cobhan_json json;
    int32_t result = input_json(input, input_len, &json);
    if (result != 0) {
        return result;
    }

    struct cobhan_str disallowed;
    result = input_string(disallowed_value, disallowed_value_len, &disallowed);
    if (result != 0) {
        return result;
    }

    struct cobhan_buf output_buf;
    result = output_buffer(output, output_cap, &output_buf);
    if (result != 0) {
        return result;
    }

    const cJSON *item;
    char *delete_list[cJSON_GetArraySize(json.cjson)];
    int delete_index = 0;
    cJSON_ArrayForEach(item, json.cjson)
    {
        int value_len = strlen(item->valuestring);
        if (memmem(item->valuestring, value_len, disallowed.data, disallowed.length)) {
            delete_list[delete_index++] = item->string;
        }
    }

    while (delete_index) {
        cJSON_DeleteItemFromObjectCaseSensitive(json.cjson, delete_list[delete_index - 1]);
        delete_index--;
    }

    return output_free_json(&json, &output_buf);
}

int32_t base64Encode(const char *input, int32_t input_len, char *output, int32_t output_cap) {
    int output_len = apr_base64_encode_len(input_len);
    if (output_len > output_cap) {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }

    int result = apr_base64_encode(output, input, input_len);

    return (int32_t)result;
}

