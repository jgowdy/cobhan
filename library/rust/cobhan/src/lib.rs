use std::os::raw::c_char;
use std::ptr::copy_nonoverlapping;
use std::slice::from_raw_parts;
use serde_json::{Value};
use std::collections::HashMap;
use tempfile::NamedTempFile;
use std::io::{Write};
use std::fs;
use std::str;

const ERR_NONE: i32 = 0;

//One of the provided pointers is NULL / nil / 0
const ERR_NULL_PTR: i32 = -1;

//One of the provided buffer lengths is too large
const ERR_BUFFER_TOO_LARGE: i32 = -2;

//One of the provided buffers was too small
const ERR_BUFFER_TOO_SMALL: i32 = -3;

//Failed to copy a buffer (copy length != expected length)
//const ERR_COPY_FAILED: i32 = -4;

//Failed to decode a JSON buffer
const ERR_JSON_DECODE_FAILED: i32 = -5;

//Failed to encode to JSON buffer
const ERR_JSON_ENCODE_FAILED: i32 = -6;

const ERR_INVALID_UTF8: i32 = -7;

const ERR_READ_TEMP_FILE_FAILED: i32 = -8;

const ERR_WRITE_TEMP_FILE_FAILED: i32 = -9;

const BUFFER_HEADER_SIZE: isize = 64 / 8; // 64 bit buffer header provides 8 byte alignment for data pointers

const SIZEOF_INT32: isize = 32 / 8;

static MAXIMUM_BUFFER_SIZE: i32 = i32::MAX;

#[cfg(feature = "cobhan_debug")]
macro_rules! debug_print {
    ($( $args:expr ),*) => { println!( $( $args ),* ); }
}

#[cfg(not(feature = "cobhan_debug"))]
macro_rules! debug_print {
    ($( $args:expr ),*) => {}
}

pub unsafe fn cbuffer_to_vector(buffer: *const c_char) -> Result<Vec<u8>, i32> {
    if buffer.is_null() {
        debug_print!("cbuffer_to_vector: buffer is NULL");
        return Err(ERR_NULL_PTR);
    }
    let length = *(buffer as *const i32);
    let _reserved = buffer.offset(SIZEOF_INT32) as *const i32;
    let payload = buffer.offset(BUFFER_HEADER_SIZE) as *const u8;
    debug_print!("cbuffer_to_vector: raw length field is {}", length);

    if length > MAXIMUM_BUFFER_SIZE {
        debug_print!("cbuffer_to_vector: length {} is larger than MAXIMUM_BUFFER_SIZE ({})", length, MAXIMUM_BUFFER_SIZE);
        return Err(ERR_BUFFER_TOO_LARGE)
    }
    if length < 0 {
        debug_print!("cbuffer_to_vector: calling temp_to_vector");
        return temp_to_vector(payload, length);
    }

    //Allocation: to_vec() is a clone/copy
    Ok(from_raw_parts(payload, length as usize).to_vec())
}

unsafe fn temp_to_vector(payload: *const u8, length: i32)  -> Result<Vec<u8>, i32> {
    let file_name;
    match str::from_utf8(from_raw_parts(payload, (0 - length) as usize)) {
        Ok(f) => file_name = f,
        Err(..) => {
            debug_print!("temp_to_vector: temp file name is invalid utf-8 string (length = {})", 0 - length);
            return Err(ERR_INVALID_UTF8);
        }
    }

    match fs::read(file_name) {
        Ok(s) => return Ok(s),
        Err(_e) => {
            debug_print!("temp_to_vector: failed to read temporary file {}: {}", file_name, _e);
            return Err(ERR_READ_TEMP_FILE_FAILED);
        }
    }
}

pub unsafe fn cbuffer_to_string(buffer: *const c_char) -> Result<String, i32> {
    if buffer.is_null() {
        debug_print!("cbuffer_to_string: buffer is NULL");
        return Err(ERR_NULL_PTR);
    }
    let length = *(buffer as *const i32);
    let _reserved = buffer.offset(SIZEOF_INT32) as *const i32;
    let payload = buffer.offset(BUFFER_HEADER_SIZE) as *const u8;
    debug_print!("cbuffer_to_string: raw length field is {}", length);

    if length > MAXIMUM_BUFFER_SIZE {
        debug_print!("cbuffer_to_string: length {} is larger than MAXIMUM_BUFFER_SIZE ({})", length, MAXIMUM_BUFFER_SIZE);
        return Err(ERR_BUFFER_TOO_LARGE);
    }

    debug_print!("cbuffer_to_string: raw length field is {}", length);

    if length < 0 {
        debug_print!("cbuffer_to_string: calling temp_to_string");
        return temp_to_string(payload, length)
    }

    //Allocation: to_vec() is a clone/copy
    match String::from_utf8(from_raw_parts(payload, length as usize).to_vec()) {
        Ok(input_str) => return Ok(input_str),
        Err(..) => {
            debug_print!("cbuffer_to_string: payload is invalid utf-8 string (length = {})", length);
            return Err(ERR_INVALID_UTF8);
        }
    }
}

unsafe fn temp_to_string(payload: *const u8, length: i32) -> Result<String, i32> {
    let file_name;
    match str::from_utf8(from_raw_parts(payload, (0 - length) as usize)) {
        Ok(f) => file_name = f,
        Err(..) => {
            debug_print!("temp_to_string: temp file name is invalid utf-8 string (length = {})", 0 - length);
            return Err(ERR_INVALID_UTF8);
        }
    }

    debug_print!("temp_to_string: reading temp file {}", file_name);

    match fs::read_to_string(file_name) {
        Ok(s) => return Ok(s),
        Err(_e) => {
            debug_print!("temp_to_string: Error reading temp file {}: {}", file_name, _e);
            return Err(ERR_READ_TEMP_FILE_FAILED);
        }
    }
}

pub unsafe fn cbuffer_to_hashmap_json(buffer: *const c_char) -> Result<HashMap<String,Value>, i32> {
    if buffer.is_null() {
        debug_print!("cbuffer_to_hashmap_json: buffer is NULL");
        return Err(ERR_NULL_PTR);
    }
    let length = *(buffer as *const i32);
    let _reserved = buffer.offset(SIZEOF_INT32) as *const i32;
    let payload = buffer.offset(BUFFER_HEADER_SIZE) as *const u8;
    debug_print!("cbuffer_to_hashmap_json: raw length field is {}", length);


    if length > MAXIMUM_BUFFER_SIZE {
        debug_print!("cbuffer_to_hashmap_json: length {} is larger than MAXIMUM_BUFFER_SIZE ({})", length, MAXIMUM_BUFFER_SIZE);
        return Err(ERR_BUFFER_TOO_LARGE);
    }

    debug_print!("cbuffer_to_hashmap_json: raw length field is {}", length);

    let json_str;
    let temp_string_result;
    if length >= 0 {
        match str::from_utf8(from_raw_parts(payload, length as usize)) {
            Ok(input_str) => json_str = input_str,
            Err(..) => {
                debug_print!("cbuffer_to_hashmap_json: payload is invalid utf-8 string (length = {})", length);
                return Err(ERR_INVALID_UTF8);
            }
        }
    } else {
        debug_print!("cbuffer_to_hashmap_json: calling temp_to_string");
        match temp_to_string(payload, length) {
            Ok(string) => {
                temp_string_result = string;
                json_str = &temp_string_result;
            },
            Err(e) => return Err(e)
        }
    }

    match serde_json::from_str(&json_str) {
        Ok(json) => return Ok(json),
        Err(_e) => {
            debug_print!("cbuffer_to_hashmap_json: serde_json::from_str / JSON decode failed {}", _e);
            return Err(ERR_JSON_DECODE_FAILED);
        }
    }
}

pub unsafe fn hashmap_json_to_cbuffer(json: &HashMap<String,Value>, buffer: *mut c_char) -> i32 {
    //TODO: Use tovec?
    match serde_json::to_string(&json) {
        Ok(json_str) => return string_to_cbuffer(&json_str, buffer),
        Err(..) => return ERR_JSON_ENCODE_FAILED
    }
}

pub unsafe fn string_to_cbuffer(string: &str, buffer: *mut c_char) -> i32 {
    bytes_to_cbuffer(string.as_bytes(), buffer)
}

pub unsafe fn bytes_to_cbuffer(bytes: &[u8], buffer: *mut c_char) -> i32 {
    if buffer.is_null() {
        debug_print!("bytes_to_cbuffer: buffer is NULL");
        return ERR_NULL_PTR;
    }

    let length = buffer as *mut i32;
    let _reserved = buffer.offset(SIZEOF_INT32) as *mut i32;
    let payload = (buffer.offset(BUFFER_HEADER_SIZE)) as *mut u8;

    let buffer_cap = *length;
    debug_print!("bytes_to_cbuffer: buffer capacity is {}", buffer_cap);

    if buffer_cap <= 0 {
        debug_print!("bytes_to_cbuffer: Invalid buffer capacity");
        return ERR_BUFFER_TOO_SMALL;
    }

    let bytes_len = bytes.len();
    debug_print!("bytes_to_cbuffer: bytes.len() is {}", bytes_len);

    if buffer_cap < (bytes_len as i32) {
        debug_print!("bytes_to_cbuffer: calling bytes_to_temp");
        return bytes_to_temp(bytes, buffer);
    }

    copy_nonoverlapping(bytes.as_ptr(), payload, bytes_len);

    *length = bytes_len as i32;

    ERR_NONE
}

unsafe fn bytes_to_temp(bytes: &[u8], buffer: *mut c_char) -> i32 {
    let tmp_file_path;
    match write_new_file(bytes) {
        Ok(t) => tmp_file_path = t,
        Err(r) => return r
    }
    debug_print!("bytes_to_temp: write_new_file wrote {} bytes to {}", bytes.len(), tmp_file_path);

    let length = buffer as *mut i32;
    let tmp_file_path_len = tmp_file_path.len() as i32;

    //NOTE: We explicitly test this so we don't recursively attempt to create temp files with string_to_cbuffer()
    if *length < tmp_file_path_len {
        //Temp file path won't fit in output buffer, we're out of luck
        debug_print!("bytes_to_temp: temp file path {} is larger than buffer capacity {}", tmp_file_path, *length);
        let _ = fs::remove_file(tmp_file_path);
        return ERR_BUFFER_TOO_SMALL;
    }

    let result = string_to_cbuffer(&tmp_file_path, buffer);
    if result != ERR_NONE {
        debug_print!("bytes_to_temp: failed to store temp path {} in buffer", tmp_file_path);
        let _ = fs::remove_file(tmp_file_path);
        return result;
    }

    *length = 0 - tmp_file_path_len;
    return result;
}

unsafe fn write_new_file(bytes: &[u8]) -> Result<String, i32> {
    let mut tmpfile;
    match NamedTempFile::new() {
        Ok(f) => tmpfile = f,
        Err(..) => return Err(ERR_WRITE_TEMP_FILE_FAILED)
    }
    let bytes_len = bytes.len();

    let bytes_written;
    match tmpfile.write_all(&bytes) {
        Ok(..) => bytes_written = bytes_len as i32,
        Err(..) => return Err(ERR_WRITE_TEMP_FILE_FAILED)
    }

    if (bytes_written as usize) != bytes_len {
        return Err(ERR_WRITE_TEMP_FILE_FAILED);
    }

    let result;
    match tmpfile.keep() {
        Ok(r) => result = r,
        Err(..) => return Err(ERR_WRITE_TEMP_FILE_FAILED)
    }
    let (_, path) = result;

    match path.into_os_string().into_string() {
        Ok(tmp_path) => return Ok(tmp_path),
        Err(..) => {

            return Err(ERR_WRITE_TEMP_FILE_FAILED);
        }
    }
}
