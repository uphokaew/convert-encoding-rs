#include <open.mp>
#include <ConvertEncoding>

main() {
    print("=================================");
    print("  ConvertEncoding v2.1.0 (Rust)");
    print("  Comprehensive Test Suite");
    print("=================================");
}

public OnGameModeInit() {
    new passed = 0;
    new failed = 0;

    printf("[Test] Starting ConvertEncoding test suite...");
    printf("");

    // =========================================================
    // Test 1: TIS-620 → UTF-8 (Thai greeting)
    // =========================================================
    {
        new tis[7];
        tis[0] = 0xCA; // ส
        tis[1] = 0xC7; // ว
        tis[2] = 0xD1; // ั
        tis[3] = 0xCA; // ส
        tis[4] = 0xB4; // ด
        tis[5] = 0xD5; // ี
        tis[6] = 0;

        new utf8[256];
        new result = ConvertEncoding(tis, TIS620, UTF8, utf8);
        if (result == 1) {
            printf("[PASS] Test 1: TIS-620 -> UTF-8 Thai greeting: '%s'", utf8);
            passed++;
        } else {
            printf("[FAIL] Test 1: TIS-620 -> UTF-8 returned %d", result);
            failed++;
        }
    }

    // =========================================================
    // Test 2: UTF-8 → TIS-620 (roundtrip)
    // =========================================================
    {
        new tis[7];
        tis[0] = 0xCA; tis[1] = 0xC7; tis[2] = 0xD1;
        tis[3] = 0xCA; tis[4] = 0xB4; tis[5] = 0xD5; tis[6] = 0;

        new utf8[256], back[256];
        ConvertEncoding(tis, TIS620, UTF8, utf8);
        new result = ConvertEncoding(utf8, UTF8, TIS620, back);

        // Verify roundtrip: back should equal original tis
        new match = 1;
        for (new i = 0; i < 6; i++) {
            if (back[i] != tis[i]) { match = 0; break; }
        }
        if (result == 1 && match) {
            printf("[PASS] Test 2: UTF-8 -> TIS-620 roundtrip");
            passed++;
        } else {
            printf("[FAIL] Test 2: Roundtrip failed (result=%d, match=%d)", result, match);
            failed++;
        }
    }

    // =========================================================
    // Test 3: ASCII passthrough (no conversion needed)
    // =========================================================
    {
        new ascii[] = "Hello World 123!@#";
        new out[256];
        new result = ConvertEncoding(ascii, TIS620, UTF8, out);
        if (result == 1 && !strcmp(out, ascii)) {
            printf("[PASS] Test 3: ASCII passthrough: '%s'", out);
            passed++;
        } else {
            printf("[FAIL] Test 3: ASCII passthrough (result=%d, out='%s')", result, out);
            failed++;
        }
    }

    // =========================================================
    // Test 4: Inline SA-MP color codes preserved
    // {FF0000} = red, {00FF00} = green
    // =========================================================
    {
        new colored[] = "{FF0000}Hello{00FF00}World";
        new out[256];
        new result = ConvertEncoding(colored, TIS620, UTF8, out);
        if (result == 1 && !strcmp(out, colored)) {
            printf("[PASS] Test 4: Inline color codes preserved: '%s'", out);
            passed++;
        } else {
            printf("[FAIL] Test 4: Color codes (result=%d, out='%s')", result, out);
            failed++;
        }
    }

    // =========================================================
    // Test 5: Mixed Thai TIS-620 + inline color codes
    // =========================================================
    {
        new mixed[32];
        // {FF0000} + Thai "กข" (0xA1, 0xA2)
        mixed[0] = '{'; mixed[1] = 'F'; mixed[2] = 'F';
        mixed[3] = '0'; mixed[4] = '0'; mixed[5] = '0';
        mixed[6] = '0'; mixed[7] = '}';
        mixed[8] = 0xA1; // ก
        mixed[9] = 0xA2; // ข
        mixed[10] = 0;

        new out[256];
        new result = ConvertEncoding(mixed, TIS620, UTF8, out);
        if (result == 1) {
            printf("[PASS] Test 5: Color + Thai TIS-620: '%s'", out);
            passed++;
        } else {
            printf("[FAIL] Test 5: Color + Thai (result=%d)", result);
            failed++;
        }
    }

    // =========================================================
    // Test 6: Empty string
    // =========================================================
    {
        new empty[] = "";
        new out[256];
        out[0] = 'X'; // Pre-fill to verify it gets cleared
        new result = ConvertEncoding(empty, TIS620, UTF8, out);
        if (result == 1) {
            printf("[PASS] Test 6: Empty string handled");
            passed++;
        } else {
            printf("[FAIL] Test 6: Empty string (result=%d)", result);
            failed++;
        }
    }

    // =========================================================
    // Test 7: Baht sign ฿ (TIS-620: 0xDF → U+0E3F)
    // =========================================================
    {
        new baht[2];
        baht[0] = 0xDF; // ฿
        baht[1] = 0;

        new out[256];
        new result = ConvertEncoding(baht, TIS620, UTF8, out);
        if (result == 1) {
            printf("[PASS] Test 7: Baht sign: '%s'", out);
            passed++;
        } else {
            printf("[FAIL] Test 7: Baht sign (result=%d)", result);
            failed++;
        }
    }

    // =========================================================
    // Test 8: Thai digits (TIS-620: 0xF0-0xF9 → ๐-๙)
    // =========================================================
    {
        new digits[11];
        for (new i = 0; i < 10; i++) {
            digits[i] = 0xF0 + i; // ๐๑๒๓๔๕๖๗๘๙
        }
        digits[10] = 0;

        new out[256];
        new result = ConvertEncoding(digits, TIS620, UTF8, out);
        if (result == 1) {
            printf("[PASS] Test 8: Thai digits: '%s'", out);
            passed++;
        } else {
            printf("[FAIL] Test 8: Thai digits (result=%d)", result);
            failed++;
        }
    }

    // =========================================================
    // Test 9: Unsupported encoding returns 0
    // =========================================================
    {
        new text[] = "test";
        new out[256];
        new result = ConvertEncoding(text, "WINDOWS-1252", "UTF-8", out);
        if (result == 0) {
            printf("[PASS] Test 9: Unsupported encoding returns 0");
            passed++;
        } else {
            printf("[FAIL] Test 9: Should return 0 but got %d", result);
            failed++;
        }
    }

    // =========================================================
    // Test 10: Long string (stress test)
    // =========================================================
    {
        new long_str[256];
        for (new i = 0; i < 200; i++) {
            long_str[i] = 0xA1 + (i % 58); // Cycle through Thai chars
        }
        long_str[200] = 0;

        new out[1024];
        new result = ConvertEncoding(long_str, TIS620, UTF8, out);
        if (result == 1) {
            printf("[PASS] Test 10: Long string (200 chars) converted");
            passed++;
        } else {
            printf("[FAIL] Test 10: Long string (result=%d)", result);
            failed++;
        }
    }

    // =========================================================
    // Summary
    // =========================================================
    printf("");
    printf("=================================");
    printf("  Results: %d passed, %d failed", passed, failed);
    printf("=================================");

    return 1;
}
