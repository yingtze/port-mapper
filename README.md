# 🗺️ Port Mapper

> Lihat semua port yang sedang dipakai. Proses mana yang pakai. Kill dengan mudah.

Lelah harus buka Activity Monitor cuma untuk cari tahu siapa yang nge-block port 3000-mu? Port Mapper hadir sebagai solusi ringan berbasis terminal — cukup satu perintah, semua terjawab.

---

## ✨ Fitur Utama

- **📋 List** — tampilkan semua port aktif dengan info proses, PID, user, dan status koneksi
- **🔍 Filter** — cari berdasarkan nomor port atau nama proses
- **⚡ Kill** — hentikan proses hanya dengan nomor port, tanpa perlu cari PID manual
- **👁️ Watch** — pantau port secara real-time seperti `top`, tapi khusus port
- **📊 Info** — detail lengkap proses termasuk penggunaan CPU dan RAM
- **🎨 Warna** — output berwarna untuk keterbacaan maksimal di terminal

---

## 🖥️ Persyaratan

| Komponen | Keterangan |
|----------|------------|
| macOS | 11 Big Sur ke atas (termasuk Apple Silicon M1/M2/M3) |
| Shell | Bash 3.2+ (sudah tersedia di semua macOS) |
| Dependensi | `lsof`, `ps` — sudah tersedia secara default |

Tidak perlu Homebrew. Tidak perlu install apapun tambahan.

---

## 🚀 Instalasi

### Cara Cepat (Recommended)

```bash
git clone https://github.com/yingtze/port-mapper.git
cd port-mapper
chmod +x install.sh
./install.sh
```

Setelah itu, jalankan dari mana saja:

```bash
port-mapper list
```

### Manual

```bash
# Clone repo
git clone https://github.com/yingtze/port-mapper.git

# Buat executable dan copy ke PATH
chmod +x port-mapper/port-mapper.sh
sudo cp port-mapper/port-mapper.sh /usr/local/bin/port-mapper
```

### Tanpa Instalasi (langsung jalankan)

```bash
chmod +x port-mapper.sh
./port-mapper.sh list
```

---

## 📖 Penggunaan

### Lihat semua port aktif

```bash
port-mapper list
```

```
🔍 Port Aktif (8 ditemukan)

PORT     PID      PROSES               USER         STATUS         ALAMAT
────────────────────────────────────────────────────────────────────────────────
3000     12345    node                 kamu         LISTEN         *:3000
5432     12100    postgres             _postgres    LISTEN         *:5432
8080     13421    python3              kamu         LISTEN         *:8080
```

### Filter berdasarkan port

```bash
port-mapper list -p 3000
```

### Filter berdasarkan nama proses

```bash
port-mapper list -n node
port-mapper list -n python
```

### Kill proses pada port tertentu

```bash
port-mapper kill 3000
```

```
Proses yang memakai port 3000:

PORT     PID      PROSES               USER         STATUS
────────────────────────────────────────────────────────
3000     12345    node                 kamu         LISTEN

⚡ Kill 1 proses? (y/N): y
✓ PID 12345 berhasil di-kill

🎯 Selesai! 1/1 proses dihentikan.
```

### Kill tanpa konfirmasi (cocok untuk scripting)

```bash
port-mapper kill -f 3000
```

### Lihat detail lengkap sebuah port

```bash
port-mapper info 5432
```

### Pantau port secara real-time

```bash
port-mapper watch              # refresh setiap 2 detik
port-mapper watch -i 5         # refresh setiap 5 detik
```

---

## 📋 Referensi Perintah

| Perintah | Shorthand | Keterangan |
|----------|-----------|------------|
| `list` | `ls` | Tampilkan semua port aktif |
| `list -p <port>` | — | Filter berdasarkan nomor port |
| `list -n <nama>` | — | Filter berdasarkan nama proses |
| `kill <port>` | `k` | Kill proses pada port (dengan konfirmasi) |
| `kill -f <port>` | — | Kill tanpa konfirmasi |
| `watch` | `w` | Monitor port real-time |
| `watch -i <detik>` | — | Monitor dengan interval custom |
| `info <port>` | `i` | Detail proses pada port |
| `version` | `-v` | Tampilkan versi |
| `help` | `-h` | Tampilkan bantuan |

---

## 💡 Tips & Trik

**Butuh sudo?** Jika ada proses yang gagal di-kill, coba:
```bash
sudo port-mapper kill 80
```

**Integrasikan ke workflow:**
```bash
# Di package.json scripts, pastikan port bersih sebelum dev server naik
"predev": "port-mapper kill -f 3000 || true"
```

**Cek semua proses Node.js yang jalan:**
```bash
port-mapper list -n node
```

---

## 🔄 Changelog

Lihat [CHANGELOG.md](CHANGELOG.md) untuk riwayat perubahan lengkap.

---

## 📄 Lisensi

MIT License — bebas digunakan, dimodifikasi, dan didistribusikan.

---

<p align="center">Dibuat dengan ❤️ untuk developer Indonesia yang capek buka Activity Monitor</p>
