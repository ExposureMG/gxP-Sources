# GXP Sources

Unlicensed repo of source code for GXP, GXS and JSON patches.

## Disclaimer

I did not make a SINGLE PATCH in this repo! I have translated a few to my own formats but this is entierely based on the work of other people!

I am NOT taking credit for these.

## Contains

- RGLoader KHV and XAM (XEPATCH)
- RGLoader 2BL and 4BL (GXS)
- AudClamp (GXS)
- ArgonData (GXS)
- Glitch3 v2 (GXS)
- Glitch1/2 (JSON)
- SMC+ (JSON)
- FZJ JTAG Fix (JSON)
- Eject Disable (JSON)
- No Drive Blink (JSON)
- PCI Mask Fix (JSON)
- PNC Disable (JSON)
- "Unconditional Boot" (JSON)


## About

Types:

JSON: Signature and wildcard based patches, Mostly for SMC

GXS: Loaderpatch-like Addr:Data patches with PPC ASM functionality

XEPATCH: Traditional xeBuild patches

GXP: Compiled multi-section patch binary


## Planned

Expand GXS with Macros and some more asm statements

Make GXS feasible to translate RGLoader XEPATCHes into

Cleanup LP GXS translations and re-add comments


## Converter

In [src](/src), there is a rust tool to:

- Convert XEPATCH to GXS
- Create GXS from a diff
- Compile and Pack GXS sections into a GXP binary

## License

Leaving unlicensed as no party involved has given me permission.

- JTAG SMC by [tmbinc]()
- Glitch3 SMC by [15432]()
- RGH1.3 by [wurthless-elektroniks]()
- SMC+ by [15432]() and [Octal450]()
- Smc360 Research by [wurthless-elektroniks]()
- x360utils JTAG SMC patcher by [Swizzy]()
- Glitch1/2 SMC patch by c0z