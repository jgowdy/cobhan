#include <ctype.h>

void toUpperInC(char* c_str) {
    while(*c_str) {
        *c_str = toupper(*c_str);
        c_str++;
    }
}