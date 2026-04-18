.include "macros.S"

.globl _start
_start:

#============================================================================
# Falcon Glitch3 SMC Patch
#============================================================================

# reboot on no_handshake failure
MAKEPATCH 0x1290
0:
	.long 0x0212BA00 # (at 0x1290 is ljmp 0x12BA)
9:

# GPIO patches
MAKEPATCH 0x11d4
0:
	.long 0x12004F80 # (0x11d7 = 0x80)
9:

MAKEPATCH 0x1200
0:
	.long 0x004F8012 # (0x1202 = 0x80)
9:

# UART persistence
MAKEPATCH 0x23AC
0:
	.long 0x86AC75C0 # (0x23AF = 0xC0, alignment adjusted)
9:

# Stack move logic
MAKEPATCH 0x758
0:
	.long 0xBC1222D1 # (0x758 = 0xBC)
9:

MAKEPATCH 0x774
0:
	.long 0x0A7581BC # (0x777 = 0xBC)
9:

# Init Hook (hook at 0x770)
MAKEPATCH 0x770
0:
	.long 0x1213C292 # (0x770 = lcall 0x13C2)
9:

#============================================================================
# PAYLOADS
#============================================================================

# Init Payload (0x13c2, aligned 0x13c0)
MAKEPATCH 0x13C0
0:
	.long 0xFFFF78B9
	.long 0x760075E9
	.long 0xFF000000
9:

# Main Payload (0x2d03, aligned 0x2d00)
MAKEPATCH 0x2d00
0:
	.long 0xFFFFFF12
	.long 0x2D0A122D
	.long 0x642278A5
	.long 0xB600FA78
	.long 0xB9E630E2
	.long 0x07A2E392
	.long 0xE0C2E2F6
	.long 0xA2E04005
	.long 0x30E1E680
	.long 0x0320E1E1
	.long 0x7578CF30
	.long 0xE1037578
	.long 0xC112261F
	.long 0x20D5D278
	.long 0xA5760478
	.long 0xB9E6D2E2
	.long 0xA2E192E3
	.long 0xF622C000
	.long 0x78BBE643
	.long 0xBF01B576
	.long 0x02800BA6
	.long 0x76B41505
	.long 0xB6010280
	.long 0x01D353BF
	.long 0xFED00022
	.long 0x78BA79B9
	.long 0xE7208602
	.long 0x7600B600
	.long 0x11C2C0C2
	.long 0xE1F720E0
	.long 0x14308611
	.long 0x79BC77FF
	.long 0x802CB601
	.long 0x02802FB6
	.long 0x02042087
	.long 0x2122B603
	.long 0x2243BF01
	.long 0x2087FD30
	.long 0x87FD2087
	.long 0xFD3087FD
	.long 0xD2C053BF
	.long 0xFEC25BD2
	.long 0xE1F779BC
	.long 0x771906E6
	.long 0x022E35B6
	.long 0x040D122D
	.long 0x4650D279
	.long 0xBC17E770
	.long 0xCC80EBB6
	.long 0x0549C2C0
	.long 0x43BF0120
	.long 0x87FD7A01
	.long 0x7BC07C04
	.long 0x7D047EA4
	.long 0x7F02A2E4
	.long 0x40027D05
	.long 0xB2E4F7DA
	.long 0xFEDBFC12
	.long 0x2334DCF7
	.long 0xD2C03087
	.long 0xFD122334
	.long 0xDDFEDEFC
	.long 0xDFFAC286
	.long 0xD2861223
	.long 0x34C2C053
	.long 0xBFFEC2E1
	.long 0xF779BC77
	.long 0x0A809FB6
	.long 0x060D80A2
	.long 0xB6092730
	.long 0x0E942087
	.long 0x91800CB6
	.long 0x070E79BC
	.long 0x7700D25B
	.long 0x30878376
	.long 0x0A0212BA
	.long 0xB608E180
	.long 0x812430F5
	.long 0xE77409D5
	.long 0xE0FD2200
9:

.long 0xFFFFFFFF
.end
