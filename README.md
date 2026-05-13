# GXP Sources

Source code for GXP, GXS and JSON patches. The files hosted here will likely not work with any builder other then [gxBuild](https://github.com/ExposureMG/gxBuild).

Also contains a Patch Converter (gxp-converter)

## About

JSON: Signature-based patches

GXS (GX Source): One compiled section of GXP

GXP (GX Patchset): Compiled and built multi-patch binaries, can contain GXS, XEPATCH, or both.

All patches built for xeBuild will work on gxBuild; The major difference in GXP is a 16-byte header at the beginning to stop backwards compatibility. xeBuild has no GXS support, and would interpret 4-section RGH patches as JTAG patches.

## Developer

View [releases]() and [src] for a full-fledged patch converter:

- Compiled xeBuild to GXS
- Compiled RGH 1.3 to GXS
- Binary Diff to GXS
- GXP Builder

## License

Leaving unlicensed as no party involved has given me permission.

- JTAG SMC by [tmbinc]()
- Glitch3 SMC by [15432]()
- RGH1.3 by [wurthless-elektroniks]()
- SMC+ by [15432]() and [Octal450]()
- Smc360 Research by [wurthless-elektroniks]()
- x360utils JTAG SMC patcher by [Swizzy]()
- Glitch1/2 SMC patch by c0z