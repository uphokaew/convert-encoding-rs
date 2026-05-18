#include <open.mp>
#include <ConvertEncoding>

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_RED       0xFF0000FF
#define COLOR_GREEN     0x00FF00FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_CYAN      0x00FFFFFF
#define COLOR_ORANGE    0xFF8800FF

// =========================================================
//  Helper: แปลง UTF-8 → TIS-620 แล้วส่ง SendClientMessage
//  ใช้แทน SendClientMessage ปกติเมื่อเขียนไทยใน source
// =========================================================
stock SendThaiMessage(playerid, color, const utf8_msg[]) {
    new tis[256];
    ConvertEncoding(utf8_msg, UTF8, TIS620, tis);
    SendClientMessage(playerid, color, tis);
}

main() {
    print("===========================================");
    print("  ConvertEncoding v2.1.0 (Rust) Live Test");
    print("  UTF-8 → TIS-620 for SA-MP display");
    print("===========================================");
}

public OnGameModeInit() {
    SetGameModeText("ConvertEncoding Test");
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    SendClientMessage(playerid, COLOR_YELLOW, "===========================================");
    SendThaiMessage(playerid, COLOR_YELLOW, "  ConvertEncoding ทดสอบในเกมจริง");
    SendClientMessage(playerid, COLOR_YELLOW, "===========================================");
    SendClientMessage(playerid, COLOR_WHITE, "/test  - Run all tests");
    SendClientMessage(playerid, COLOR_WHITE, "/msg   - Thai messages");
    SendClientMessage(playerid, COLOR_WHITE, "/color - Inline color + Thai");
    SendClientMessage(playerid, COLOR_WHITE, "/info  - Player info in Thai");
    return 1;
}

public OnPlayerSpawn(playerid) {
    SendThaiMessage(playerid, COLOR_GREEN, "คุณเกิดแล้ว พิมพ์ /test เพื่อทดสอบ");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if (!strcmp(cmdtext, "/test", true)) {
        TestMessages(playerid);
        TestColors(playerid);
        TestPlayerInfo(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/msg", true)) {
        TestMessages(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/color", true)) {
        TestColors(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/info", true)) {
        TestPlayerInfo(playerid);
        return 1;
    }
    return 0;
}

// =========================================================
//  /msg — ข้อความภาษาไทยแบบต่าง ๆ
// =========================================================
forward TestMessages(playerid);
public TestMessages(playerid) {
    SendClientMessage(playerid, COLOR_CYAN, "--- Thai Messages (UTF-8 source -> TIS-620) ---");

    // ข้อความทั่วไป
    SendThaiMessage(playerid, COLOR_WHITE, "สวัสดีครับ ยินดีต้อนรับเข้าสู่เซิร์ฟเวอร์");
    SendThaiMessage(playerid, COLOR_WHITE, "ระบบพร้อมใช้งานแล้ว");

    // ข้อความผสมไทย-อังกฤษ
    SendThaiMessage(playerid, COLOR_WHITE, "ยินดีต้อนรับ Welcome to Server!");

    // ตัวเลข + ไทย
    SendThaiMessage(playerid, COLOR_WHITE, "ราคา 1,500 บาท จำนวน 10 ชิ้น");

    // อักขระพิเศษ ฿
    SendThaiMessage(playerid, COLOR_WHITE, "ยอดเงิน: ฿50,000");

    // เลขไทย
    SendThaiMessage(playerid, COLOR_WHITE, "เลขไทย: ๐๑๒๓๔๕๖๗๘๙");

    // ประโยคยาว
    SendThaiMessage(playerid, COLOR_WHITE, "กรุณาอ่านกฎของเซิร์ฟเวอร์ก่อนเล่น ห้ามใช้สคริปโกง");

    SendClientMessage(playerid, COLOR_GREEN, "--- Messages test done ---");
    return 1;
}

// =========================================================
//  /color — Inline color แทรกในข้อความไทย
// =========================================================
forward TestColors(playerid);
public TestColors(playerid) {
    new tis[256];

    SendClientMessage(playerid, COLOR_CYAN, "--- Inline Colors + Thai ---");

    // สีแดง + สีเขียว
    ConvertEncoding("{FF0000}ข้อความสีแดง {00FF00}ข้อความสีเขียว", UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    // แจ้งเตือนแบบระบบ
    ConvertEncoding("{FFFF00}[แจ้งเตือน] {FFFFFF}คุณได้รับเงิน {00FF00}$1,000", UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    // ข้อความ kill feed
    ConvertEncoding("{FF0000}ผู้เล่น A {FFFFFF}ฆ่า {00FF00}ผู้เล่น B", UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    // HP/Armor display
    ConvertEncoding("{FF0000}HP: {FFFFFF}100 {0088FF}เกราะ: {FFFFFF}50", UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    // ระบบ VIP
    ConvertEncoding("{FFD700}[VIP] {FFFFFF}คุณเป็นสมาชิก VIP ระดับ {FFD700}Gold", UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    // format + inline color
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    new utf8[256];
    format(utf8, sizeof(utf8), "{00FF00}%s {FFFFFF}เข้าสู่ระบบสำเร็จ", name);
    ConvertEncoding(utf8, UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    SendClientMessage(playerid, COLOR_GREEN, "--- Colors test done ---");
    return 1;
}

// =========================================================
//  /info — แสดงข้อมูลผู้เล่นเป็นภาษาไทย
// =========================================================
forward TestPlayerInfo(playerid);
public TestPlayerInfo(playerid) {
    new tis[256], utf8[256];

    SendClientMessage(playerid, COLOR_CYAN, "--- Player Info (Thai) ---");

    // ชื่อผู้เล่น
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(utf8, sizeof(utf8), "ชื่อ: %s", name);
    SendThaiMessage(playerid, COLOR_WHITE, utf8);

    // ID
    format(utf8, sizeof(utf8), "ไอดี: %d", playerid);
    SendThaiMessage(playerid, COLOR_WHITE, utf8);

    // HP
    new Float:hp;
    GetPlayerHealth(playerid, hp);
    format(utf8, sizeof(utf8), "พลังชีวิต: %.0f", hp);
    SendThaiMessage(playerid, COLOR_WHITE, utf8);

    // ตำแหน่ง
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    format(utf8, sizeof(utf8), "ตำแหน่ง: X=%.1f Y=%.1f Z=%.1f", x, y, z);
    SendThaiMessage(playerid, COLOR_WHITE, utf8);

    // Ping
    format(utf8, sizeof(utf8), "ปิง: %d ms", GetPlayerPing(playerid));
    SendThaiMessage(playerid, COLOR_WHITE, utf8);

    // สรุปด้วย inline color
    format(utf8, sizeof(utf8), "{FFD700}[สรุป] {FFFFFF}%s {00FF00}ออนไลน์ {FFFFFF}HP: {FF0000}%.0f", name, hp);
    ConvertEncoding(utf8, UTF8, TIS620, tis);
    SendClientMessage(playerid, COLOR_WHITE, tis);

    SendClientMessage(playerid, COLOR_GREEN, "--- Info test done ---");
    return 1;
}
