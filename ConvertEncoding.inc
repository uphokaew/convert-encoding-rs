// ---------------------------------------------------------
//  ConvertEncoding.inc — Pawn include file
//  TIS-620 ↔ UTF-8 encoding conversion
// ---------------------------------------------------------
//
//  Usage:
//    #include <ConvertEncoding>
//
//  Example:
//    new text[] = "สวัสดีครับ";
//    new output[256];
//    ConvertEncoding(text, TIS620, UTF8, output);
// ---------------------------------------------------------

#if defined _convert_encoding_included
    #endinput
#endif
#define _convert_encoding_included

#if !defined PACK_PLUGIN_VERSION
    #define PACK_PLUGIN_VERSION(%0,%1,%2) (((%0) << 16) | ((%1) << 8) | (%2))
#endif

#define CONVERTENCODING_VERSION PACK_PLUGIN_VERSION(2, 1, 0)
#define CONVERTENCODING_INCLUDE_VERSION CONVERTENCODING_VERSION

// Encoding identifiers
#define TIS620  "TIS-620"
#define UTF8    "UTF-8"

/// Convert text between encodings.
///
/// @param input   Source text to convert
/// @param from    Source encoding ("TIS-620" or "UTF-8")
/// @param to      Target encoding ("TIS-620" or "UTF-8")
/// @param output  Buffer to receive converted text
/// @param size    Size of the output buffer (default: sizeof output)
/// @return        1 on success, 0 on unsupported conversion
native ConvertEncoding(const input[], const from[], const to[], output[], size = sizeof output);
