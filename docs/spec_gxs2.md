# GXS 2.0 Specification

Largely based on LoaderPatch;


Basic Addr:Data patches are written as:

```
0x6860: 48 00 01 68
```


Multi-line patches are also supported:

```
0x31E0:
    12 31 E7 12 32 41 22 78 A4 B6 00 FA 78 BF E6 30
    E2 07 A2 E3 92 E0 C2 E2 F6 A2 E0 40 05 30 E1 E6
    80 03 20 E1 E1 75 79 E3 30 E1 03 75 79 EB 12 29
    95 20 D5 D2 78 A4 76 04 78 BF E6 D2 E2 A2 E1 92
    E3 F6 22 C0 00 78 C1 E6 43 BF 01 B5 77 02 80 0B
    A6 77 B4 15 05 B6 01 02 80 01 D3 53 BF FE D0 00
    22 78 C0 79 BF E7 20 86 02 76 00 B6 00 11 C2 85
    C2 E1 F7 20 E0 14 30 86 11 79 C2 77 FF 80 2C B6
```



## PPC ASM

PowerPC ASM patches are compiled to hex during the conversion process using xenon-as.

### ASM Syntax

ASM sections use the following syntax:

```
[ASM] 0xADDRESS:
	<assembly instructions>
[!ASM]
```

**Requirements:**
- Start with `[ASM] 0xADDRESS:` where ADDRESS is the target memory location
- End with `[!ASM]` marker
- Use comma-separated syntax for xenon-as compatibility
- Registers use `%rX` format (e.g., `%r5`, `%r6`)
- Immediate values can be decimal or hex (e.g., `16` or `0x10`)

**Example:**
```
[ASM] 0xE70:
	mfmsr   %r5
	li      %r6, 16
	andc    %r6, %r5, %r6
	or      %r11, %r11, %r10
	xori    %r11, %r11, 1
[!ASM]
```

### Compilation Process

ASM sections are compiled using platform-specific toolchains:

**Linux:**
- Uses `./bin/xenon-as` from local bin directory
- Uses `./bin/xenon-objcopy` for binary extraction

**Windows:**
- Uses `./bin/xenon-as.exe` from local bin directory  
- Uses `./bin/xenon-objcopy.exe` for binary extraction

**macOS:**
- ASM compilation is not supported

### TXT vs GXS Comparison

**Traditional TXT Format:**
```
.code b 0xE3C
                 or        %r11, %r11, %r10 # do what we patched did originally
                 xori      %r11, %r11, 1   # remove the unpaired bit
.eoc
```

**GXS 2.0 ASM Format:**
```
[ASM] 0xE3C:
	or %r11, %r11, %r10
	xori %r11, %r11, 1
[!ASM]
```

**Benefits of GXS ASM:**
- No need for `.code`/`.eoc` directives
- No need for comments or alignment
- Direct address specification
- Automatic compilation to binary during pack process
- Cleaner, more readable syntax
- Full PowerPC instruction support via xenon-as

### Macro Support

ASM sections have access to standard PowerPC register definitions and xeBuild-compatible macros:
- Register definitions: `hrmor`, `hsprg0`, `ctr`, `lr`, etc.
- Base address: `KBASE, 0x80000000`
- Standard PowerPC instructions and syntax

### Example Conversion

Input ASM:
```
[ASM] 0xE70:
	mfmsr   %r5 
        li      %r6, 0x10
        andc    %r6, %r5, %r6
```

Compiled Output:
```
0xE70: 7C A0 02 A6 38 60 00 10 7C C6 23 78
```