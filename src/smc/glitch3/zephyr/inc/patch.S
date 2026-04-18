.include "macros.S"

.globl _start
_start:

#============================================================================
# Zephyr Glitch3 SMC Patch
#============================================================================

# reboot on no_handshake failure
MAKEPATCH 0x1244
0:
	.long 0x02126E00 # (at 0x1244 is ljmp 0x126E)
9:

# GPIO patches
MAKEPATCH 0x1188
0:
	.long 0x12004F80 # (0x118b = 0x80)
9:

MAKEPATCH 0x11b4
0:
	.long 0x004F8012 # (0x11b6 = 0x80)
9:

# UART persistence
MAKEPATCH 0x2324
0:
	.long 0xC086AC75 # (0x2325 = 0xC0)
9:

# Stack move logic
MAKEPATCH 0x758
0:
	.long 0x801222D1 # (0x758 = 0x80)
9:

MAKEPATCH 0x774
0:
	.long 0x0A758180 # (0x777 = 0x80)
9:

# Init Hook (hook at 0x770)
MAKEPATCH 0x770
0:
	.long 0x12137692 # (0x770 = lcall 0x1376)
9:

#============================================================================
# PAYLOADS
#============================================================================

# Init Payload (0x1376, aligned 0x1374)
MAKEPATCH 0x1374
0:
	.long 0xFFFF787D
	.long 0x760075E9
	.long 0xFF000000
9:

# Main Payload (0x2c5f, aligned 0x2c5c)
MAKEPATCH 0x2c5c
0:
	.long 0xFFFFFF12
	.long 0x2C66122C
	.long 0xC02278CD
	.long 0xB600FA78
	.long 0x7DE630E2
	.long 0x07A2E392
	.long 0xE0C2E2F6
	.long 0xA2E04005
	.long 0x30E1E680
	.long 0x0320E1E1
	.long 0x7578C330
	.long 0xE1037578
	.long 0xB5122587
	.long 0x20D5D278
	.long 0xCD760478
	.long 0x7DE6D2E2
	.long 0xA2E192E3
	.long 0xF622C000
	.long 0x787FE643
	.long 0xBF01B576
	.long 0x02800BA6
	.long 0x76B41505
	.long 0xB6010280
	.long 0x01D353BF
	.long 0xFED00022
	.long 0x787E797D
	.long 0xE7208602
	.long 0x7600B600
	.long 0x11C2C0C2
	.long 0xE1F720E0
	.long 0x14308611
	.long 0x798077FF
	.long 0x802CB601
	.long 0x02802FB6
	.long 0x02042087
	.long 0x2122B603
	.long 0x2243BF01
	.long 0x2087FD30
	.long 0x87FD2087
	.long 0xFD3087FD
	.long 0xD2C053BF
	.long 0xFEC259D2
	.long 0xE1F77980
	.long 0x771906E6
	.long 0x022D91B6
	.long 0x040D122C
	.long 0xA250D279
	.long 0x8017E770
	.long 0xCC80EBB6
	.long 0x0549C2C0
	.long 0x43BF0120
	.long 0x87FD7A01
	.long 0x7BCC7C04
	.long 0x7D017EA9
	.long 0x7F02A2E4
	.long 0x40027D02
	.long 0xB2E4F7DA
	.long 0xFEDBFC12
	.long 0x22AADCF7
	.long 0xD2C03087
	.long 0xFD1222AA
	.long 0xDDFEDEFC
	.long 0xDFFAC286
	.long 0xD2861222
	.long 0xAAC2C053
	.long 0xBFFEC2E1
	.long 0xF7798077
	.long 0x0A809FB6
	.long 0x060D80A2
	.long 0xB6092730
	.long 0x0E942087
	.long 0x91800CB6
	.long 0x070E7980
	.long 0x7700D259
	.long 0x30878376
	.long 0x0A02126E
	.long 0xB608E180
	.long 0x812430F5
	.long 0xE77409D5
	.long 0xE0FD2200
9:

.long 0xFFFFFFFF
.end
