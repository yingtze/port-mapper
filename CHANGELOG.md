# Changelog

Semua perubahan penting pada project ini akan didokumentasikan di sini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan project ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2025-03-15

### Rilis Pertama 🎉

- Perintah `list` untuk menampilkan semua port TCP/UDP yang aktif beserta PID, nama proses, user, status, dan alamat koneksi
- Filter berdasarkan nomor port (`-p`) dan nama proses (`-n`)
- Perintah `kill <port>` dengan konfirmasi interaktif sebelum menghentikan proses
- Flag `--force` / `-f` untuk kill tanpa konfirmasi (cocok untuk scripting)
- Perintah `watch` untuk memantau port secara real-time dengan interval yang bisa dikustomisasi (`-i`)
- Perintah `info <port>` untuk menampilkan detail proses termasuk statistik CPU dan RAM
- Shorthand perintah: `ls`, `k`, `w`, `i`
- Pewarnaan output berdasarkan jenis proses (Node.js, Python, Ruby, Java, Nginx, Docker, dll)
- Banner ASCII art dan tampilan tabel yang rapi
- Install script otomatis (`install.sh`) dengan fallback ke sudo
- Dukungan penuh untuk macOS Apple Silicon (M1/M2/M3) dan Intel

---

[1.0.0]: https://github.com/yingtze/port-mapper/releases/tag/v1.0.0
