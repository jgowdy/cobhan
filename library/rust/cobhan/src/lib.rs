use std::os::raw::c_char;
use std::ptr::copy_nonoverlapping;
use std::slice::from_raw_parts;
use serde_json::{Value};
use std::collections::HashMap;
use tempfile::NamedTempFile;
use std::io::{Write};
use std::fs;

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

static MAXIMUM_BUFFER_SIZE: i32 = i32::MAX;

pub unsafe fn buffer_to_vector(buffer: *const c_char) -> Result<Vec<u8>, i32> {
    if buffer.is_null() {
        return Err(ERR_NULL_PTR);
    }
    let data = (buffer.offset(BUFFER_HEADER_SIZE)) as *const u8;

    let length = *(buffer as *const i32);
    if length > MAXIMUM_BUFFER_SIZE {
        return Err(ERR_BUFFER_TOO_LARGE)
    }
    if length < 0 {
        let file_name;
        match String::from_utf8(from_raw_parts(data, (0 - length) as usize).to_vec()) {
            Ok(f) => file_name = f,
            Err(..) => return Err(ERR_INVALID_UTF8)
        }

        match fs::read(file_name) {
            Ok(s) => return Ok(s),
            Err(..) => return Err(ERR_READ_TEMP_FILE_FAILED)
        }
    }

    return Ok(from_raw_parts(data, length as usize).to_vec());
}

pub unsafe fn buffer_to_string(buffer: *const c_char) -> Result<String, i32> {
    if buffer.is_null() {
        return Err(ERR_NULL_PTR);
    }
    let data = (buffer.offset(BUFFER_HEADER_SIZE)) as *const u8;

    let length = *(buffer as *const i32);
    if length > MAXIMUM_BUFFER_SIZE {
        return Err(ERR_BUFFER_TOO_LARGE);
    }
    if length < 0 {
        let file_name;
        match String::from_utf8(from_raw_parts(data, (0 - length) as usize).to_vec()) {
            Ok(f) => file_name = f,
            Err(..) => return Err(ERR_INVALID_UTF8)
        }

        match fs::read_to_string(file_name) {
            Ok(s) => return Ok(s),
            Err(..) => return Err(ERR_READ_TEMP_FILE_FAILED)
        }
    }

    match String::from_utf8(from_raw_parts(data, length as usize).to_vec()) {
        Ok(input_str) => return Ok(input_str),
        Err(..) => return Err(ERR_INVALID_UTF8)
    }
}

pub unsafe fn buffer_to_hashmap_json(buffer: *const c_char) -> Result<HashMap<String,Value>, i32> {
    let json_str;
    match buffer_to_string(buffer) {
        Ok(str) => json_str = str,
        Err(e) => return Err(e)
    }

    match serde_json::from_str(&json_str) {
        Ok(json) => return Ok(json),
        Err(..) => return Err(ERR_JSON_DECODE_FAILED)
    }
}

pub unsafe fn hashmap_json_to_buffer(json: &HashMap<String,Value>, buffer: *mut c_char) -> i32 {
    match serde_json::to_string(&json) {
        Ok(json_str) => return string_to_buffer(&json_str, buffer),
        Err(..) => return ERR_JSON_ENCODE_FAILED
    }
}

pub unsafe fn string_to_buffer(string: &str, buffer: *mut c_char) -> i32 {
    return bytes_to_buffer(string.as_bytes(), buffer);
}

pub unsafe fn bytes_to_buffer(bytes: &[u8], buffer: *mut c_char) -> i32 {
    if buffer.is_null() {
        return ERR_NULL_PTR;
    }

    let length = buffer as *mut i32;
    let buffer_cap = *length;
    let data = (buffer.offset(BUFFER_HEADER_SIZE)) as *const u8;
    let bytes_len = bytes.len();

    if (buffer_cap as usize) < bytes_len {
        let tmp_file_path;
        match write_file(bytes) {
            Ok(t) => tmp_file_path = t,
            Err(r) => return r
        }

        if buffer_cap < tmp_file_path.len() as i32 {
            //Temp file path won't fit in output buffer, we're out of luck
            let _ = fs::remove_file(tmp_file_path);
            return ERR_BUFFER_TOO_SMALL;
        }

        let result = string_to_buffer(&tmp_file_path, buffer);

        if result != ERR_NONE {
            let _ = fs::remove_file(tmp_file_path);
        }
        return result;
    }

    copy_nonoverlapping(bytes.as_ptr(), data as *mut u8, bytes_len);

    *length = bytes_len as i32;

    ERR_NONE
}

unsafe fn write_file(bytes: &[u8]) -> Result<String, i32> {
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
        Err(..) => return Err(ERR_WRITE_TEMP_FILE_FAILED)
    }
}
