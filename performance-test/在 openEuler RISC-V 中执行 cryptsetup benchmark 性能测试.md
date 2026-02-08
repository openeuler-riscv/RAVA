## 在 openEuler RISC-V 中执行 cryptsetup benchmark 性能测试

### 1. 介绍

cryptsetup benchmark 是 cryptsetup（Linux 下管理 LUKS/dm-crypt 的工具） 自带的加密算法性能测试命令，用来测当前系统上：

- 各种对称加密算法/模式（如 aes-xts, serpent-xts 等）的加/解密吞吐；
- 各种 KDF/PBKDF（如 pbkdf2, argon2i/id 等）的密钥派生性能。

它是基准测试，不会去读写你的磁盘数据；只是测算法速度（主要是 CPU/内核加密路径）。

cryptsetup benchmark 主要测试两大类：

1）块加密算法/模式（对称加密）

- 常见：`aes-xts`、`aes-cbc`、`serpent-xts`、`twofish-xts` 等；
- 会列出：
  - 不同 key size（密钥长度，比如 256/512 bits）
  - encryption / decryption 速度（通常 MB/s）

2）KDF / PBKDF（密钥派生函数，用于从密码生成 LUKS 主密钥）

- `pbkdf2`、`argon2i`、`argon2id` 等；
- 会显示：
  - 在指定时间/内存/并行度参数下，每秒可完成多少次派生（iterations/s 等）或完成一次耗时多少。

### 2. 执行测试

查看帮助

````
$ cryptsetup benchmark --help
cryptsetup 2.6.1 flags: UDEV BLKID KEYRING FIPS KERNEL_CAPI PWQUALITY 
Usage: cryptsetup [OPTION...] <action> <action-specific>

Help options:
  -?, --help                            Show this help message
      --usage                           Display brief usage
  -V, --version                         Print package version
      --active-name=STRING              Override device autodetection of dm
                                        device to be reencrypted
      --align-payload=SECTORS           Align payload at <n> sector boundaries
                                        - for luksFormat
      --allow-discards                  Allow discards (aka TRIM) requests for
                                        device
  -q, --batch-mode                      Do not ask for confirmation
      --cancel-deferred                 Cancel a previously set deferred
                                        device removal
  -c, --cipher=STRING                   The cipher used to encrypt the disk
                                        (see /proc/crypto)
      --debug                           Show debug messages
      --debug-json                      Show debug messages including JSON
                                        metadata
      --deferred                        Device removal is deferred until the
                                        last user closes it
      --device-size=bytes               Use only specified device size (ignore
                                        rest of device). DANGEROUS!
      --decrypt                         Decrypt LUKS2 device (remove
                                        encryption).
      --disable-external-tokens         Disable loading of external LUKS2
                                        token plugins
      --disable-keyring                 Disable loading volume keys via kernel
                                        keyring
      --disable-locks                   Disable locking of on-disk metadata
      --disable-veracrypt               Do not scan for VeraCrypt compatible
                                        device
      --dump-json-metadata              Dump info in JSON format (LUKS2 only)
      --dump-volume-key                 Dump volume key instead of keyslots
                                        info
      --encrypt                         Encrypt LUKS2 device (in-place
                                        encryption).
      --force-password                  Disable password quality check (if
                                        enabled)
      --force-offline-reencrypt         Force offline LUKS2 reencryption and
                                        bypass active device detection.
  -h, --hash=STRING                     The hash used to create the encryption
                                        key from the passphrase
      --header=STRING                   Device or file with separated LUKS
                                        header
      --header-backup-file=STRING       File with LUKS header and keyslots
                                        backup
      --hotzone-size=bytes              Maximal reencryption hotzone size.
      --init-only                       Initialize LUKS2 reencryption in
                                        metadata only.
  -I, --integrity=STRING                Data integrity algorithm (LUKS2 only)
      --integrity-legacy-padding        Use inefficient legacy padding (old
                                        kernels)
      --integrity-no-journal            Disable journal for integrity device
      --integrity-no-wipe               Do not wipe device after format
  -i, --iter-time=msecs                 PBKDF iteration time for LUKS (in ms)
      --iv-large-sectors                Use IV counted in sector size (not in
                                        512 bytes)
      --json-file=STRING                Read or write the json from or to a
                                        file
      --keep-key                        Do not change volume key.
      --key-description=STRING          Key description
  -d, --key-file=STRING                 Read the key from a file
  -s, --key-size=BITS                   The size of the encryption key
  -S, --key-slot=INT                    Slot number for new key (default is
                                        first free)
      --keyfile-offset=bytes            Number of bytes to skip in keyfile
  -l, --keyfile-size=bytes              Limits the read from keyfile
      --keyslot-cipher=STRING           LUKS2 keyslot: The cipher used for
                                        keyslot encryption
      --keyslot-key-size=BITS           LUKS2 keyslot: The size of the
                                        encryption key
      --label=STRING                    Set label for the LUKS2 device
      --luks2-keyslots-size=bytes       LUKS2 header keyslots area size
      --luks2-metadata-size=bytes       LUKS2 header metadata area size
      --volume-key-file=STRING          Use the volume key from file.
      --new-keyfile=STRING              Read the key for a new slot from a file
      --new-key-slot=INT                Slot number for new key (default is
                                        first free)
      --new-keyfile-offset=bytes        Number of bytes to skip in newly added
                                        keyfile
      --new-keyfile-size=bytes          Limits the read from newly added
                                        keyfile
      --new-token-id=INT                Token number (default: any)
  -o, --offset=SECTORS                  The start offset in the backend device
      --pbkdf=STRING                    PBKDF algorithm (for LUKS2): argon2i,
                                        argon2id, pbkdf2
      --pbkdf-force-iterations=LONG     PBKDF iterations cost (forced,
                                        disables benchmark)
      --pbkdf-memory=kilobytes          PBKDF memory cost limit
      --pbkdf-parallel=threads          PBKDF parallel cost
      --perf-no_read_workqueue          Bypass dm-crypt workqueue and process
                                        read requests synchronously
      --perf-no_write_workqueue         Bypass dm-crypt workqueue and process
                                        write requests synchronously
      --perf-same_cpu_crypt             Use dm-crypt same_cpu_crypt
                                        performance compatibility option
      --perf-submit_from_crypt_cpus     Use dm-crypt submit_from_crypt_cpus
                                        performance compatibility option
      --persistent                      Set activation flags persistent for
                                        device
      --priority=STRING                 Keyslot priority: ignore, normal,
                                        prefer
      --progress-json                   Print progress data in json format
                                        (suitable for machine processing)
      --progress-frequency=secs         Progress line update (in seconds)
  -r, --readonly                        Create a readonly mapping
      --reduce-device-size=bytes        Reduce data device size (move data
                                        offset). DANGEROUS!
      --refresh                         Refresh (reactivate) device with new
                                        parameters
      --resilience=STRING               Reencryption hotzone resilience type
                                        (checksum,journal,none)
      --resilience-hash=STRING          Reencryption hotzone checksums hash
      --resume-only                     Resume initialized LUKS2 reencryption
                                        only.
      --sector-size=INT                 Encryption sector size (default: 512
                                        bytes)
      --serialize-memory-hard-pbkdf     Use global lock to serialize memory
                                        hard PBKDF (OOM workaround)
      --shared                          Share device with another
                                        non-overlapping crypt segment
  -b, --size=SECTORS                    The size of the device
  -p, --skip=SECTORS                    How many sectors of the encrypted data
                                        to skip at the beginning
      --subsystem=STRING                Set subsystem label for the LUKS2
                                        device
      --tcrypt-backup                   Use backup (secondary) TCRYPT header
      --tcrypt-hidden                   Use hidden header (hidden TCRYPT
                                        device)
      --tcrypt-system                   Device is system TCRYPT drive (with
                                        bootloader)
      --test-args                       Do not run action, just validate all
                                        command line parameters
      --test-passphrase                 Do not activate device, just check
                                        passphrase
  -t, --timeout=secs                    Timeout for interactive passphrase
                                        prompt (in seconds)
      --token-id=INT                    Token number (default: any)
      --token-only                      Do not ask for passphrase if
                                        activation by token fails
      --token-replace                   Replace the current token
      --token-type=STRING               Restrict allowed token types used to
                                        retrieve LUKS2 key
  -T, --tries=INT                       How often the input of the passphrase
                                        can be retried
  -M, --type=STRING                     Type of device metadata: luks, luks1,
                                        luks2, plain, loopaes, tcrypt, bitlk
      --unbound                         Create or dump unbound LUKS2 keyslot
                                        (unassigned to data segment) or LUKS2
                                        token (unassigned to keyslot)
      --use-random                      Use /dev/random for generating volume
                                        key
      --use-urandom                     Use /dev/urandom for generating volume
                                        key
      --uuid=STRING                     UUID for device to use
      --veracrypt                       Scan also for VeraCrypt compatible
                                        device
      --veracrypt-pim=INT               Personal Iteration Multiplier for
                                        VeraCrypt compatible device
      --veracrypt-query-pim             Query Personal Iteration Multiplier
                                        for VeraCrypt compatible device
  -v, --verbose                         Shows more detailed error messages
  -y, --verify-passphrase               Verifies the passphrase by asking for
                                        it twice
  -B, --block-size=MiB                  Reencryption block size
  -N, --new                             Create new header on not encrypted
                                        device
      --use-directio                    Use direct-io when accessing devices
      --use-fsync                       Use fsync after each block
      --write-log                       Update log file after every block
      --dump-master-key                 Alias for --dump-volume-key
      --master-key-file=STRING          Alias for --dump-volume-key-file

<action> is one of:
        open <device> [--type <type>] [<name>] - open device as <name>
        close <name> - close device (remove mapping)
        resize <name> - resize active device
        status <name> - show device status
        benchmark [--cipher <cipher>] - benchmark cipher
        repair <device> - try to repair on-disk metadata
        reencrypt <device> - reencrypt LUKS2 device
        erase <device> - erase all keyslots (remove encryption key)
        convert <device> - convert LUKS from/to LUKS2 format
        config <device> - set permanent configuration options for LUKS2
        luksFormat <device> [<new key file>] - formats a LUKS device
        luksAddKey <device> [<new key file>] - add key to LUKS device
        luksRemoveKey <device> [<key file>] - removes supplied key or key file from LUKS device
        luksChangeKey <device> [<key file>] - changes supplied key or key file of LUKS device
        luksConvertKey <device> [<key file>] - converts a key to new pbkdf parameters
        luksKillSlot <device> <key slot> - wipes key with number <key slot> from LUKS device
        luksUUID <device> - print UUID of LUKS device
        isLuks <device> - tests <device> for LUKS partition header
        luksDump <device> - dump LUKS partition information
        tcryptDump <device> - dump TCRYPT device information
        bitlkDump <device> - dump BITLK device information
        fvault2Dump <device> - dump FVAULT2 device information
        luksSuspend <device> - Suspend LUKS device and wipe key (all IOs are frozen)
        luksResume <device> - Resume suspended LUKS device
        luksHeaderBackup <device> - Backup LUKS device header and keyslots
        luksHeaderRestore <device> - Restore LUKS device header and keyslots
        token <add|remove|import|export> <device> - Manipulate LUKS2 tokens

You can also use old <action> syntax aliases:
        open: create (plainOpen), luksOpen, loopaesOpen, tcryptOpen, bitlkOpen, fvault2Open
        close: remove (plainClose), luksClose, loopaesClose, tcryptClose, bitlkClose, fvault2Close

<name> is the device to create under /dev/mapper
<device> is the encrypted device
<key slot> is the LUKS key slot number to modify
<key file> optional key file for the new key for luksAddKey action

Default compiled-in metadata format is LUKS2 (for luksFormat action).

LUKS2 external token plugin support is compiled-in.
LUKS2 external token plugin path: /usr/lib64/cryptsetup.

Default compiled-in key and passphrase parameters:
        Maximum keyfile size: 8192kB, Maximum interactive passphrase length 512 (characters)
Default PBKDF for LUKS1: pbkdf2, iteration time: 2000 (ms)
Default PBKDF for LUKS2: argon2id
        Iteration time: 2000, Memory required: 1048576kB, Parallel threads: 4

Default compiled-in device cipher parameters:
        loop-AES: aes, Key 256 bits
        plain: aes-cbc-essiv:sha256, Key: 256 bits, Password hashing: ripemd160
        LUKS: aes-xts-plain64, Key: 256 bits, LUKS header hashing: sha256, RNG: /dev/urandom
        LUKS: Default keysize with XTS mode (two internal keys) will be doubled.
````

常用参数说明

| 参数        | 缩写 | 作用与示例                                                   | 说明                                                         |
| ----------- | ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| --hash      | -h   | 仅测试指定的密钥派生函数（用于 PBKDF2 或 AF splitter 的哈希算法）。<br/>`sudo cryptsetup benchmark --hash sha512` | 关注密码破解难度时，比较不同哈希算法的PBKDF2速度。<br>常见值：<br>`sha256`<br>`sha512`<br>`ripemd160`（用得较少） |
| --cipher    | -c   | 仅测试指定的对称加密算法。<br/>`sudo cryptsetup benchmark --cipher aes-xts` | 在已知算法池中（如AES、Twofish）做针对性性能对比。<br>常见写法：<br/>`aes-xts-plain64`：AES-XTS 模式，常用作 LUKS 默认<br/>`aes-cbc-essiv:sha256`：AES-CBC 模式<br/>`twofish-xts-plain64`、`serpent-xts-plain64`：其它块加密算法 |
| --key-size  | -s   | 指定测试的密钥长度（单位：bit），需与`--cipher`联用。<br/>`sudo cryptsetup benchmark --cipher aes-xts --key-size 256` | 测试同一算法不同密钥长度（如AES-128 vs AES-256）的性能差异。<br>常见取值：<br>`256`：XTS 模式下对应 128-bit+128-bit（即你常说的“256 bit key”）<br>`512`：XTS 模式下对应 256-bit+256-bit（即“512 bit key”） |
| --pbkdf     | 无   | 指定PBKDF（KDF 算法，密码密钥派生函数）类型。<br/>`sudo cryptsetup benchmark --pbkdf argon2i` | 测试更新、更安全的密钥派生函数（如Argon2）的性能，此函数抗GPU/ASIC破解能力更强。<br>可选值：<br>`pbkdf2`：传统的基于迭代的 KDF<br>`argon2i`：Argon2i（抗侧信道更强的变种）<br>`argon2id`：Argon2id（混合模式，推荐场景更通用） |
| --iter-time | 无   | 指定PBKDF2的目标迭代时间（毫秒），模拟实际加密设置。<br/>`sudo cryptsetup benchmark --iter-time 2000` | 预估当设置解锁耗时2秒时，系统自动选择的迭代次数，用于评估安全性。<br>典型范围：<br>`500`：解锁较快，安全性略降<br>`1000`：很多发行版的默认参考值<br>`2000`：更慢但更费算力，适合对安全性敏感的场景 |

执行测试

````
$ cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       289661 iterations per second for 256-bit key
PBKDF2-sha256     365612 iterations per second for 256-bit key
PBKDF2-sha512     329740 iterations per second for 256-bit key
PBKDF2-ripemd160  261359 iterations per second for 256-bit key
PBKDF2-whirlpool   94568 iterations per second for 256-bit key
argon2i       4 iterations, 534992 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 550464 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b        49.7 MiB/s        52.8 MiB/s
    serpent-cbc        128b        26.2 MiB/s        30.8 MiB/s
    twofish-cbc        128b        46.4 MiB/s        52.3 MiB/s
        aes-cbc        256b        39.3 MiB/s        40.9 MiB/s
    serpent-cbc        256b        27.6 MiB/s        30.8 MiB/s
    twofish-cbc        256b        48.4 MiB/s        52.3 MiB/s
        aes-xts        256b        52.0 MiB/s        53.8 MiB/s
    serpent-xts        256b        27.5 MiB/s        31.0 MiB/s
    twofish-xts        256b        50.2 MiB/s        52.6 MiB/s
        aes-xts        512b        41.9 MiB/s        41.4 MiB/s
    serpent-xts        512b        28.9 MiB/s        31.0 MiB/s
    twofish-xts        512b        52.9 MiB/s        52.6 MiB/s
````

| 算法与模式       | 密钥长度 | 加密速度 (MiB/s) | 解密速度 (MiB/s) |
| ---------------- | -------- | ---------------- | ---------------- |
| **aes-xts**      | **256b** | **52.0**         | **53.8**         |
| **twofish-xts**  | 512b     | **52.9**         | 52.6             |
| **aes-cbc**      | 128b     | 49.7             | 52.8             |
| **twofish-cbc**  | 256b     | 48.4             | 52.3             |
| **serpent** 系列 | 多种     | 26.2 - 31.0      | 30.8 - 31.0      |

只测试使用 SHA512 哈希算法的 PBKDF2 性能 

````
$ cryptsetup benchmark -h sha512
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha512     328913 iterations per second for 256-bit key
````

命令测试了 PBKDF2 密钥派生函数搭配 SHA-512 哈希算法的速度，结果为 每秒 328，913 次迭代。关键指标`328913 iterations per second for 256-bit key` ，这个数字是安全性的反向指标。数字越低，意味着生成一个密钥需要的时间越长，对暴力破解（尝试无数密码）的抵抗能力就越强，反而越安全。

只测试 AES-CBC 加密算法，使用 256 位密钥长度

````
$ cryptsetup benchmark -c aes-cbc -s 256
# Tests are approximate using memory only (no storage IO).
# Algorithm |       Key |      Encryption |      Decryption
    aes-cbc        256b        39.1 MiB/s        40.9 MiB/s
````

AES-CBC（AES是算法，CBC是加密模式） 算法使用 256 位密钥（256是密钥长度）时，加密速度约为 39.1 MiB/s，解密速度约为 40.9 MiB/s。

