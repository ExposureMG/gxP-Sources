.include "macros.S"

.globl _start
_start:

#============================================================================
# Trinity Glitch3 SMC Patch
#============================================================================

# reboot on no_handshake failure
MAKEPATCH 0x13A0
0:
	.long 0x120213D8 # (at 0x13A2 is ljmp 0x13D8)
9:

# GPIO patches: skip GPU checks
MAKEPATCH 0x1308
0:
	.long 0x80097555 # (0x1308 = 0x80)
9:

MAKEPATCH 0x1320
0:
	.long 0x36800975 # (0x1321 = 0x80)
9:

# skip setting DBG as input
MAKEPATCH 0x2488
0:
	.long 0xE5000000 # (0x248A = 0x00 * 3)
9:

# skip reading dbg_led
MAKEPATCH 0x248c
0:
	.long 0x011FC211 # (0x248F = 0xC2)
9:

# UART persistence
MAKEPATCH 0x2500
0:
	.long 0xC0C0D5E0 # (0x2502 = 0xC0)
9:

# Stack move logic
MAKEPATCH 0x7E4
0:
	.long 0xD2C30211 # (0x7E5 = 0xC3)
9:

MAKEPATCH 0x804
0:
	.long 0xC3E1F77F # (0x804 = 0xC3)
9:

# main calls hijack
MAKEPATCH 0x868
0:
	.long 0x22122EE9 # (0x869 = lcall CODE_START)
9:

MAKEPATCH 0x87C
0:
	.long 0xEC0980A9 # (0x87C = 0xEC)
9:

# pre-main init code hijack (hook at 0x7fd)
MAKEPATCH 0x7fc
0:
	.long 0x0C1214BF # (0x7fd = lcall INIT_START)
9:

#============================================================================
# PAYLOADS
#============================================================================

# Init Payload (align 0x14bf to 0x14bc)
MAKEPATCH 0x14bc
0:
	.long 0xFFFFFF78
	.long 0xC0760075
	.long 0xE9FF0000
9:

# Msec Payload (aligned at 0)
MAKEPATCH 0x0
0:
	.long 0xC00078C2
	.long 0xE643BF01
	.long 0xB5780280
	.long 0x0BA678B4
	.long 0x1505B601
	.long 0x028001D3
	.long 0x53BFFED0
	.long 0x00220000
9:

# Main Payload (align 0x2ee9 to 0x2ee8)
MAKEPATCH 0x2ee8
0:
	.long 0xFFD1EEF1
	.long 0x2A2278A7
	.long 0xB600FA78
	.long 0xC0E630E2
	.long 0x07A2E392
	.long 0xE0C2E2F6
	.long 0xA2E04005
	.long 0x30E1E680
	.long 0x0320E1E1
	.long 0x757AE730
	.long 0xE103757A
	.long 0xDF1227E1
	.long 0x20D5D278
	.long 0xA7760478
	.long 0xC0E6D2E2
	.long 0xA2E192E3
	.long 0xF62278C1
	.long 0x79C0E720
	.long 0x86027600
	.long 0xB60011C2
	.long 0xC0C2E1F7
	.long 0x20E01430
	.long 0x861179C3
	.long 0x77FF802C
	.long 0xB6010280
	.long 0x2EB60204
	.long 0x20872122
	.long 0xB6032143
	.long 0xBF012087
	.long 0xFD3087FD
	.long 0x2087FD30
	.long 0x87FDD2C0
	.long 0x53BFFEC2
	.long 0x5FD2E1F7
	.long 0x79C37719
	.long 0x06E68076
	.long 0xB6040D12
	.long 0x14C950D3
	.long 0x79C317E7
	.long 0x70CD80EC
	.long 0xB60540C2
	.long 0xC043BF01
	.long 0x2087FD7A
	.long 0x807BE27C
	.long 0x027D9A7E
	.long 0x187F05DA
	.long 0xFEDBFC12
	.long 0x2480DCF7
	.long 0xD2C03087
	.long 0xFD122480
	.long 0xDDFEDEFC
	.long 0xDFFAC286
	.long 0xD2861224
	.long 0x80C2C053
	.long 0xBFFEC2E1
	.long 0xF779C377
	.long 0x0A80A9B6
	.long 0x060A80AB
	.long 0xB6091F20
	.long 0x879E800C
	.long 0xB6070E79
	.long 0xC37700D2
	.long 0x5F308790
	.long 0x760A0213
	.long 0xD8B608E4
	.long 0x808D2430
	.long 0xF5E72200
9:

.long 0xFFFFFFFF
.end
