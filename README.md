# Convert Encoding (Rust)

ปลั๊กอิน **ConvertEncoding** เวอร์ชัน Rust — แปลง TIS-620 ↔ UTF-8 สำหรับ SA-MP / open.mp server

> Rewrite จาก [convert-encoding](https://github.com/exsycore/convert-encoding) (C++) ด้วย [samp-sdk-rs](https://github.com/user/samp-sdk-rs)

## ฟีเจอร์

- แปลง TIS-620 → UTF-8 (สำหรับแสดงภาษาไทยใน chat/dialog)
- แปลง UTF-8 → TIS-620 (สำหรับส่งข้อความกลับ)
- รองรับทั้ง Legacy Plugin และ Native Component (open.mp)
- Zero dependencies — ไม่ต้องติดตั้ง iconv หรือ library เพิ่มเติม
- Unit tests ครบ 9 กรณี

## การติดตั้ง

### open.mp (Component Mode — แนะนำ)

1. วางไฟล์ `convert_encoding.so` ใน `components/`
2. วาง `ConvertEncoding.inc` ใน `include/` ของ Pawn compiler
3. ไม่ต้องเพิ่มอะไรใน `config.json`

```
server/
├── components/
│   └── convert_encoding.so
└── include/
    └── ConvertEncoding.inc
```

### open.mp / SA-MP (Legacy Plugin Mode)

1. วางไฟล์ `convert_encoding.so` ใน `plugins/`
2. เพิ่มใน config:

```jsonc
// open.mp config.json
{ "pawn": { "legacy_plugins": ["convert_encoding"] } }
```
```ini
# SA-MP server.cfg
plugins convert_encoding.so
```

## วิธีใช้งาน

```pawn
#include <open.mp>
#include <ConvertEncoding>

public OnPlayerConnect(playerid) {
    new tis_text[] = "สวัสดีครับ";  // TIS-620 encoded
    new utf8[256], back[256];

    // TIS-620 → UTF-8 (สำหรับแสดงผลที่รองรับ Unicode)
    ConvertEncoding(tis_text, TIS620, UTF8, utf8);

    // UTF-8 → TIS-620 (แปลงกลับ)
    ConvertEncoding(utf8, UTF8, TIS620, back);

    SendClientMessage(playerid, -1, utf8);
    return 1;
}
```

### Native Function

```pawn
native ConvertEncoding(const input[], const from[], const to[], output[], size = sizeof output);
```

| Parameter | Description |
|-----------|-------------|
| `input[]` | ข้อความต้นฉบับ |
| `from[]` | Encoding ต้นทาง (`TIS620` หรือ `UTF8`) |
| `to[]` | Encoding ปลายทาง (`TIS620` หรือ `UTF8`) |
| `output[]` | Buffer สำหรับเก็บผลลัพธ์ |
| `size` | ขนาด Buffer (default: sizeof output) |

**Returns:** `1` สำเร็จ, `0` ล้มเหลว (encoding ไม่รองรับ)

## การบิวด์

```bash
# ติดตั้ง Rust + 32-bit target
rustup target add i686-unknown-linux-gnu
sudo apt install gcc-multilib

# Legacy plugin
cargo build --release

# Native component (open.mp)
cargo build --release --features component
```

Output: `target/i686-unknown-linux-gnu/release/libconvert_encoding.so`

## ทดสอบ

```bash
# Unit tests (encoding conversion)
cargo test --target x86_64-unknown-linux-gnu
```

## License

MIT
