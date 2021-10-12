# Cobhan FFI

Cobhan FFI is a proof of concept system for enabling shared code to be written in Go and consumed from all major languages/platforms in a safe and effective way, using easy helper functions to manage any unsafe data marshaling.

## Types

* Supported scalar types
   * int32 - 32 bit signed integer
   * int64 - 64 bit signed integer
   * float64 - double precision 64 bit IEEE 754 floating point
* Supported buffer types
   * string - utf-8 encoded length delimited string
   * JSON - utf-8 encoded length delimited string containing valid JSON
   * []byte - 8 bit raw binary buffer
* Buffer passing requirements
   * All buffers are passed as pointers + signed int32 lengths (length delimited)
   * Callers may optionally append null to strings or JSON but must not include the null in the length
   * No guarantee of null termination on returned output buffers
   * Callers provide the output buffer allocation and capacity
   * Callers can re-use the input buffer as the output buffer (memmove/copy semantics)
   * Insufficient capacity in output buffer causes functions to fail by returning less than zero
* Output buffer sizing
   * Callers may know the appropriate output buffer size
       * If it is a fixed / constant documented size
       * If it matches the input buffer size
       * If it can be computed from the input buffer size in an documented fashion (e.g. Base64)
       * If the library provides a method that returns the output buffer size for a provided input buffer size
   * When output buffer size cannot be predicted easily callers may utilize a buffer pool with a tuned
       buffer size that covers most rational cases
  * When functions return insufficient buffer errors (should be rare) caller can allocate increasing buffer
       sizes up to a maximum size, retrying until the operation is successful
  * Functions can also return dynamically sized buffers as temp files (**modern [tmpfs](https://en.wikipedia.org/wiki/Tmpfs) is entirely memory backed**)
* Return values
   * Functions that return scalar values can return the value directly
       * Functions *can* use special case and return maximum positive or maximum negative or zero values to
           represent error or overflow conditions
       * Functions *can* allow scalar values to wrap, which is the default behavior in Go
       * Functions should document their overflow / underflow behavior
   * Functions that return buffer values should return an int32 containing the populated output buffer length or
       an error code if the value is less than zero

## Todo

* Add callbacks
* Add logging & debug callback
* Add last error functionality
* Add example of get output buffer size for Base64
* Add example of binary buffer (e.g. encrypt)
* Add PHP extension support
* Add InputBufferToTmp (zero copy) and OutputBufferToTmp
