use std::os::raw::c_char;
use std::string::FromUtf8Error;
use std::ptr::copy_nonoverlapping;
use std::slice::from_raw_parts;
use serde_json::{Value};
use std::collections::HashMap;
use tempfile::NamedTempFile;
use std::io::{Write};

//One of the provided input pointers is NULL / nil / 0
const ERR_NULL_PTR: i32 = -1;

//One of the provided input buffer lengths is too large
const ERR_INPUT_BUFFER_TOO_LARGE: i32 = -2;

//One of the provided output buffers was too small to receive the output
const ERR_OUTPUT_BUFFER_TOO_SMALL: i32 = -3;

//Failed to copy the output into the output buffer (copy length != expected length)
const ERR_COPY_FAILED: i32 = -4;

//Failed to decode a JSON input buffer
const ERR_JSON_INPUT_DECODE_FAILED: i32 = -5;

//Failed to encode to JSON output buffer
const ERR_JSON_OUTPUT_ENCODE_FAILED: i32 = -6;

const ERR_INPUT_INVALID_UTF8: i32 = -7;

pub unsafe fn input_bytes(input: *const c_char, input_len: i32, input_max: i32) -> Result<Vec<u8>, i32> {
    if input_len > input_max {
        return Err(ERR_INPUT_BUFFER_TOO_LARGE)
    }

    return Ok(from_raw_parts(input as *const u8, input_len as usize).to_vec());
}

pub unsafe fn input_string(input: *const c_char, input_len: i32, input_max: i32) -> Result<String, i32> {
    if input.is_null() {
        return Err(ERR_NULL_PTR);
    }
    if input_len > input_max {
        return Err(ERR_INPUT_BUFFER_TOO_LARGE);
    }
    let result: Result<String, FromUtf8Error> = String::from_utf8(from_raw_parts(input as *const u8, input_len as usize).to_vec());
    match result {
        Ok(input_str) => return Ok(input_str),
        Err(..) => return Err(ERR_INPUT_INVALID_UTF8)
    }
}

pub unsafe fn input_hashmap_json(input: *const c_char, input_len: i32, input_max: i32) -> Result<HashMap<String,Value>, i32> {
    let input_str;
    match input_string(input, input_len, input_max) {
        Ok(str) => input_str = str,
        Err(e) => return Err(e)
    }

    match serde_json::from_str(&input_str) {
        Ok(json) => return Ok(json),
        Err(..) => return Err(ERR_JSON_INPUT_DECODE_FAILED)
    }
}

pub unsafe fn output_hashmap_json(json: &HashMap<String,Value>, output: *mut c_char, output_cap: i32) -> i32 {
    match serde_json::to_string(&json) {
        Ok(json_str) => return output_string(&json_str, output, output_cap),
        Err(..) => return ERR_JSON_OUTPUT_ENCODE_FAILED
    }
}

pub unsafe fn output_string(output_str: &str, output: *mut c_char, output_cap: i32) -> i32 {
    if output_str.len() > output_cap as usize {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    copy_nonoverlapping(output_str.as_ptr(), output as *mut u8, output_str.len());
    output_str.len() as i32
}

pub unsafe fn output_bytes(bytes: Vec<u8>, output: *mut c_char, output_cap: i32) -> i32 {
    if (output_cap as usize) < bytes.len() {
        return ERR_OUTPUT_BUFFER_TOO_SMALL;
    }
    copy_nonoverlapping(bytes.as_ptr(), output as *mut u8, bytes.len());
    bytes.len() as i32
}

pub unsafe fn output_bytes_tmp(bytes: Vec<u8>, output: *mut c_char, output_cap: i32) -> i32 {
    let tmpfile;
    match NamedTempFile::new() {
        Ok(f) => tmpfile = f,
        Err(..) => return ERR_COPY_FAILED
    }

    let result;
    match tmpfile.keep() {
        Ok(r) => result = r,
        Err(..) => return ERR_COPY_FAILED
    }
    let (mut file, path) = result;

    let bytes_written;
    match file.write_all(&bytes) {
        Ok(..) => bytes_written = bytes.len() as i32,
        Err(..) => return ERR_COPY_FAILED
    }

    if (bytes_written as usize) != bytes.len() {
        return ERR_COPY_FAILED;
    }

    match path.into_os_string().into_string() {
        Ok(path) => return output_string(&path, output, output_cap),
        Err(..) => return ERR_COPY_FAILED
    }
}
