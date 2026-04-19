# GXP Sources

Source code for GXP and GXS patches. The files hosted here will likely not work with any builder other then [gxBuild](https://github.com/ExposureMG/gxBuild).

### Full Patchsets

- Argon Data SMC
- Aud Clamp SMC
- Glitch3 SMC

### Addon Patches

- SMC+
- Glitch1/2 SMC
- Falcon JTAG Fixes
- Disable Eject (XSB/PSB and KSB)
- No Drive ROL Blink (XSB/PSB and KSB)
- Unconditional Boot

## Where is the rest?

Since 1BL/CB/CD/KHV patches remain the same, i am just prefixing a header and suffixing the smc patches onto xeBuild binaries. If you are looking for the source, [Mitchell Waite](https://github.com/mitchellwaite) has a [repository]() of xeBuild patches.

## Developer

GXJ: Signature-based patches
GXS: Offset-based patches
GXP: xeBuild + GXS

All patches built for xeBuild will work on gxBuild; The major difference in GXP is a 16-byte header at the beginning to stop backwards compatibility. xeBuild has no SMC patchfile system, and would interpret 4-section RGH patches as JTAG patches.

## License

Leaving unlicensed as no party involved has given me permission.

- JTAG SMC by [tmbinc]()
- Glitch3 SMC by [15432]()
- SMC+ by [15432]() and [Octal450]()
- Smc360 Research by [wurthless-elektroniks]()
- x360utils JTAG SMC patcher by [Swizzy]()
- Glitch1/2 SMC patcher by c0z