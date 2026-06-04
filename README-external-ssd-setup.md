# External SSD Auto-Mount Setup untuk Arch Linux + Hyprland

Script ini menyelesaikan masalah external SSD/USB yang tidak auto-mount setelah fresh install Arch + Hyprland.

## Masalah yang Dipecahkan

- ✅ External SSD harus di-mount manual setiap kali colok USB
- ✅ Copy-paste dari laptop ke SSD tidak bisa via GUI file manager
- ✅ Nautilus menunjukkan icon "unwritable" padahal terminal bisa write
- ✅ ntfs3 kernel driver tidak stabil untuk operasi GUI besar

## Quick Start

```bash
# Download dan jalankan script
bash setup-external-ssd-automount.sh

# Atau manual:
chmod +x setup-external-ssd-automount.sh
./setup-external-ssd-automount.sh
```

## Yang Dilakukan Script

1. **Install dependencies**:
   - `udisks2` - daemon untuk disk management
   - `udiskie` - auto-mounter untuk removable media
   - `ntfs-3g` - NTFS filesystem driver (lebih stabil dari ntfs3)
   - `ntfsprogs` - NTFS utilities

2. **Konfigurasi Hyprland**:
   - Menambahkan `udiskie --tray` ke `~/.config/hypr/hyprland/execs.lua`
   - Auto-start setiap kali Hyprland dimulai

3. **Setup Polkit**:
   - Membuat rule `/etc/polkit-1/rules.d/50-udisks.rules`
   - User di group `wheel` bisa mount/unmount tanpa password

4. **Test udiskie**:
   - Langsung menjalankan udiskie di background
   - Verify apakah berjalan dengan baik

## Setelah Instalasi

### Test Auto-Mount

```bash
# Cek drive yang terdeteksi
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL

# Unplug dan replug SSD - harusnya auto-mount ke:
# /run/media/your-username/<drive-label>
```

### Menggunakan File Manager

**✅ GUNAKAN DOLPHIN** untuk copy-paste ke NTFS drives:
```bash
dolphin /run/media/$USER/
```

**❌ JANGAN PAKAI NAUTILUS** - ada bug dengan ntfs3 kernel driver yang menunjukkan drive sebagai read-only padahal tidak.

### Unmount External Drive

Tiga cara:

1. **Via tray icon**: Right-click icon udiskie di system tray → pilih drive → unmount
2. **Via terminal**:
   ```bash
   udisksctl unmount -b /dev/sda1
   # atau
   udiskie-umount /dev/sda1
   ```
3. **Via Dolphin**: Right-click drive → "Safely Remove"

## Troubleshooting

### Drive tidak auto-mount setelah colok USB

```bash
# Cek apakah udiskie berjalan
ps aux | grep udiskie

# Kalau tidak, jalankan manual:
udiskie --tray &

# Cek log untuk error:
udiskie --tray -v
```

### Copy-paste gagal dari GUI

```bash
# Cek filesystem type yang dipakai
mount | grep sda1

# Kalau pakai ntfs3:
# /dev/sda1 on /run/media/... type ntfs3 (...)
#
# Solusi: PAKAI DOLPHIN, bukan Nautilus
# Nautilus punya bug dengan ntfs3

# Test write via terminal untuk confirm hardware OK:
touch /run/media/$USER/<drive-label>/test.txt
```

### Permission denied saat mount

```bash
# Cek apakah user ada di group wheel
groups

# Kalau tidak ada 'wheel', tambahkan:
sudo usermod -aG wheel $USER

# Logout dan login lagi
```

### udiskie tidak start di boot

```bash
# Cek apakah ada di Hyprland config:
grep "udiskie" ~/.config/hypr/hyprland/execs.lua

# Kalau tidak ada, jalankan script lagi atau tambah manual:
# Di dalam hl.on("hyprland.start", function() ... end):
#     hl.exec_cmd("udiskie --tray")
```

## Technical Details

### Kenapa ntfs3 bermasalah?

- `ntfs3` = kernel driver (built-in, fast)
- `ntfs-3g` = FUSE driver (userspace, lebih stabil)

Kernel ntfs3 di beberapa versi punya bug:
- GUI file manager salah deteksi write permission
- Operasi write besar kadang corrupt
- Icon "emblem-unwritable" salah di Nautilus

### Kenapa Dolphin OK tapi Nautilus tidak?

Nautilus rely heavily pada GIO/GVfs untuk permission check, dan GIO tidak handle ntfs3 edge cases dengan baik. Dolphin menggunakan KIO yang lebih toleran terhadap filesystem quirks.

### Mount options yang dipakai udiskie

Default options dari udiskie untuk NTFS:
```
rw,nosuid,nodev,relatime,uid=1000,gid=1000,iocharset=utf8
```

Ini memastikan:
- User bisa read/write (`rw`, `uid=1000`)
- UTF-8 encoding untuk filename
- Security flags (`nosuid`, `nodev`)

## File-file yang Dimodifikasi

```
~/.config/hypr/hyprland/execs.lua    # Ditambah udiskie --tray
/etc/polkit-1/rules.d/50-udisks.rules # Dibuat (passwordless mount)
```

## Uninstall

Kalau mau hapus setup ini:

```bash
# 1. Hapus dari Hyprland config
# Edit ~/.config/hypr/hyprland/execs.lua
# Hapus baris: hl.exec_cmd("udiskie --tray")

# 2. Hapus polkit rule
sudo rm /etc/polkit-1/rules.d/50-udisks.rules

# 3. Stop udiskie
killall udiskie

# 4. (Opsional) Uninstall packages
sudo pacman -Rns udiskie ntfs-3g ntfsprogs
```

## Referensi

- [Arch Wiki - udisks](https://wiki.archlinux.org/title/Udisks)
- [Arch Wiki - udiskie](https://wiki.archlinux.org/title/Udiskie)
- [NTFS-3G](https://wiki.archlinux.org/title/NTFS-3G)

---

**Dibuat**: 2026-06-04  
**Tested on**: Arch Linux (kernel 7.0.10-2-cachyos-bore) + Hyprland
