#ifndef _LIBPLUGTEST_H
#define _LIBPLUGTEST_H

#include <stdint.h>

void sleepTest(int32_t seconds);
int32_t addInt32(int32_t x, int32_t y);
int64_t addInt64(int64_t x, int64_t y);
double addDouble(double x, double y);
int32_t toUpper(const char *input, int32_t input_len, char *output, int32_t output_cap);
int32_t filterJson(const char *input, int32_t input_len, const char *disallowed_value, int32_t disallowed_value_len, char *output, int32_t output_cap);
int32_t base64Encode(const char *input, int32_t input_len, char *output, int32_t output_cap);

#endif
