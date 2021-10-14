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

#include <unistr.h>
#include <unicase.h>
#include <string.h>

#include "libplugtest.h"
#include "cJSON.h"

apr_pool_t *pool;

void init() {
    int result = apr_initialize();
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
    const uint8_t *invalid = u8_check((const uint8_t *)input, (size_t) input_len);
    if (invalid) {
        return ERR_INPUT_INVALID_UTF8;
    }

    size_t result_length = (size_t)output_cap;
    unistring_uint8_t *result = u8_ct_toupper((const uint8_t *)input, input_len,
        u8_casing_prefix_context((const uint8_t *)input, 0),
        u8_casing_suffix_context((const uint8_t *)input + input_len, 0),
        "en", NULL, (uint8_t *)output, &result_length);

    if (result != (uint8_t *)output) {
        // If result_length isn't large enough, u8_ct_toupper will allocate
        free(result);
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    return (int32_t)result_length;
}

int32_t filterJson(const char *input, int32_t input_len, const char *disallowed_value, int32_t disallowed_value_len, char *output, int32_t output_cap) {
    const uint8_t *invalid =  u8_check((const uint8_t *)input, (size_t) input_len);
    if (invalid != NULL) {
        return ERR_INPUT_INVALID_UTF8;
    }

    cJSON *json = cJSON_ParseWithLength((const char *)input, input_len);
    if (json == NULL) {
        return ERR_JSON_INPUT_DECODE_FAILED;
    }

    const cJSON *item;
    char *delete_list[cJSON_GetArraySize(json)];
    int delete_index = 0;
    cJSON_ArrayForEach(item, json)
    {
        int value_len = strlen(item->valuestring);
        if (memmem(item->valuestring, value_len, disallowed_value, disallowed_value_len)) {
            delete_list[delete_index++] = item->string;
        }
    }

    while (delete_index) {
        cJSON_DeleteItemFromObjectCaseSensitive(json, delete_list[delete_index - 1]);
        delete_index--;
    }

    int result = cJSON_PrintPreallocated(json, (char *)output, output_cap, 0);

    cJSON_Delete(json);

    if (result != 1) {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }

    int length = strlen(output);

    return length;
}

int32_t base64Encode(const char *input, int32_t input_len, char *output, int32_t output_cap) {
    int output_len = apr_base64_encode_len(input_len);
    if (output_len > output_cap) {
        return -1;
    }

    int result = apr_base64_encode(output, input, input_len);

    return (int32_t)result;
}

