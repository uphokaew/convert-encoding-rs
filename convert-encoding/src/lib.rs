// ---------------------------------------------------------
//  ConvertEncoding — TIS-620 ↔ UTF-8 Conversion Plugin
//  Rust rewrite of the original C++ plugin by EasyCore
// ---------------------------------------------------------
//
//  Pawn native:
//    native ConvertEncoding(const input[], const from[], const to[],
//                           output[], size = sizeof output);
//
//  Supported conversions:
//    - TIS-620 → UTF-8
//    - UTF-8   → TIS-620
//
//  Build modes:
//    - Legacy plugin:  cargo build --release
//    - OMP component:  cargo build --release --features component
// ---------------------------------------------------------

use samp_sdk::exports;
use samp_sdk::types::{Amx, AmxNativeInfo, Cell};
#[cfg(not(feature = "component"))]
use samp_sdk::define_plugin;
use samp_sdk::{error::AmxError, get_param_cell, get_string_from_amx, log, SampPlugin};

mod tis620;

// ---------------------------------------------------------
//  Plugin Definition
// ---------------------------------------------------------

struct ConvertEncodingPlugin;

impl SampPlugin for ConvertEncodingPlugin {
    fn load() -> bool {
        log("");
        log(" |----------------------------------------------------|");
        log(" |         ConvertEncoding v2.1.0 (Rust)               |");
        log(" |         TIS-620 <-> UTF-8 Conversion                |");
        log(" |         Original by EasyCore                        |");
        log(" |----------------------------------------------------|");
        log("");
        true
    }

    fn unload() {
        log("ConvertEncoding v2.1.0 (Rust) unloaded");
    }

    fn amx_load(amx: *mut Amx) -> i32 {
        let natives = Self::natives();
        unsafe { exports::amx_register(amx, natives.as_ptr(), natives.len() as i32) }
    }

    fn amx_unload(_amx: *mut Amx) -> i32 {
        AmxError::None as i32
    }

    fn natives() -> Vec<AmxNativeInfo> {
        vec![AmxNativeInfo::new(
            b"ConvertEncoding\0".as_ptr().cast(),
            n_convert_encoding,
        )]
    }
}

// ---------------------------------------------------------
//  open.mp Component (feature-gated)
// ---------------------------------------------------------

#[cfg(feature = "component")]
impl samp_sdk::OmpComponent for ConvertEncodingPlugin {
    fn uid() -> u64 {
        // Same UID as the original C++ plugin
        0xBA284FB180FCD75A
    }

    fn component_name() -> &'static str {
        "ConvertEncoding"
    }

    fn component_version() -> samp_sdk::ComponentVersion {
        samp_sdk::ComponentVersion::new(2, 1, 0)
    }
}

// ---------------------------------------------------------
//  Native: ConvertEncoding(input[], from[], to[], output[], size)
// ---------------------------------------------------------
//
//  Pawn usage:
//    ConvertEncoding(text, TIS620, UTF8, output);
//    ConvertEncoding(text, UTF8, TIS620, output);
//
//  Returns 1 on success, 0 on unsupported conversion.

unsafe extern "C" fn n_convert_encoding(amx: *mut Amx, params: *mut Cell) -> Cell {
    // Read params (1-indexed)
    let input_addr = unsafe { get_param_cell(params, 1) };
    let from_addr = unsafe { get_param_cell(params, 2) };
    let to_addr = unsafe { get_param_cell(params, 3) };
    let output_addr = unsafe { get_param_cell(params, 4) };
    let output_size = unsafe { get_param_cell(params, 5) } as usize;

    // Read encoding names (these are ASCII, always valid UTF-8)
    let from_enc = match unsafe { get_string_from_amx(amx, from_addr) } {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let to_enc = match unsafe { get_string_from_amx(amx, to_addr) } {
        Ok(s) => s,
        Err(_) => return 0,
    };

    // Read input as raw bytes from AMX cells
    // (TIS-620 bytes 0x80+ are NOT valid UTF-8, so we can't use get_string_from_amx)
    let input_bytes = match unsafe { get_raw_bytes_from_amx(amx, input_addr) } {
        Some(b) => b,
        None => return 0,
    };

    // Perform conversion
    let result_bytes: Vec<u8> = match (from_enc.as_str(), to_enc.as_str()) {
        ("TIS-620", "UTF-8") => {
            tis620::to_utf8(&input_bytes).into_bytes()
        }
        ("UTF-8", "TIS-620") => {
            // Input bytes are UTF-8, convert to string first
            let utf8_str = match String::from_utf8(input_bytes) {
                Ok(s) => s,
                Err(_) => return 0,
            };
            tis620::from_utf8(&utf8_str)
        }
        _ => return 0, // Unsupported conversion
    };

    // Write result bytes to Pawn output buffer as raw cells
    unsafe { set_raw_bytes_to_amx(amx, output_addr, &result_bytes, output_size) }
}

/// Read raw bytes from an AMX string parameter.
///
/// Unlike `get_string_from_amx`, this does NOT attempt UTF-8 validation.
/// Each AMX cell's low byte is collected into a Vec<u8>.
unsafe fn get_raw_bytes_from_amx(amx: *mut Amx, param: Cell) -> Option<Vec<u8>> {
    let mut ptr: *mut Cell = core::ptr::null_mut();
    let err = unsafe { exports::amx_get_addr(amx, param, &mut ptr) };
    if err != 0 { return None; }

    let mut len: i32 = 0;
    let err = unsafe { exports::amx_str_len(ptr, &mut len) };
    if err != 0 { return None; }

    if len <= 0 { return Some(Vec::new()); }

    let size = (len + 1) as usize;
    let mut buffer = vec![0u8; size];
    let err = unsafe { exports::amx_get_string(buffer.as_mut_ptr().cast(), ptr, 0, size) };
    if err != 0 { return None; }

    // Trim trailing null
    let actual_len = buffer.iter().position(|&b| b == 0).unwrap_or(buffer.len());
    buffer.truncate(actual_len);
    Some(buffer)
}

/// Write raw bytes to an AMX output buffer (one byte per cell).
unsafe fn set_raw_bytes_to_amx(amx: *mut Amx, param: Cell, data: &[u8], max_len: usize) -> Cell {
    let mut dest: *mut Cell = core::ptr::null_mut();
    let err = unsafe { exports::amx_get_addr(amx, param, &mut dest) };
    if err != 0 { return 0; }

    let write_len = data.len().min(max_len.saturating_sub(1));
    for i in 0..write_len {
        unsafe { *dest.add(i) = data[i] as Cell; }
    }
    // Null terminator
    unsafe { *dest.add(write_len) = 0; }
    1
}

// ---------------------------------------------------------
//  Export (conditional on build mode)
// ---------------------------------------------------------

#[cfg(not(feature = "component"))]
define_plugin!(ConvertEncodingPlugin);

#[cfg(feature = "component")]
samp_sdk::define_component!(ConvertEncodingPlugin);
