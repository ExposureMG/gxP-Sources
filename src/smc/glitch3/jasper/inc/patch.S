.include "macros.S"

.globl _start
_start:

#============================================================================
# Jasper Glitch3 SMC Patch
#============================================================================

# reboot on no_handshake failure
MAKEPATCH 0x129C
0:
	.long 0x0212D100 # ljmp 0x12D1 (at 0x129E)
9:

# GPU check skip 1
MAKEPATCH 0x11e0
0:
	.long 0x12004F80 # GPU1 (0x11e3 = 0x80)
9:

# GPU check skip 2
MAKEPATCH 0x1208
0:
	.long 0x12004F80 # GPU2 (0x120b = 0x80)
9:

# DBG input skip
MAKEPATCH 0x2358
0:
	.long 0x22000000 # (0x2359 = 0x00 * 3)
9:

# DBG LED read skip
MAKEPATCH 0x235c
0:
	.long 0xA2C0C211 # (0x235e = 0xC2)
9:

# UART persistence
MAKEPATCH 0x23c8
0:
	.long 0x75E8C043 # (0x23ca = 0xC0)
9:

# Stack move logic
MAKEPATCH 0x758
0:
	.long 0xBD1222D1 # (0x758 = 0xBD)
9:

MAKEPATCH 0x774
0:
	.long 0x0A7581BD # (0x777 = 0xBD)
9:

# Init Hook
MAKEPATCH 0x770
0:
	.long 0x1213CE92 # lcall 0x13CE
9:

#============================================================================
# PAYLOADS
#============================================================================

# Init Payload
MAKEPATCH 0x13CC
0:
	.long 0xFFFF78BA
	.long 0x760075E9
	.long 0xFF000000
9:

# Main Payload (align 0x2d73 to 0x2d70)
MAKEPATCH 0x2d70
0:
	.long 0xFFFFFF12
	.long 0x2D7A122D
	.long 0xD42278A6
	.long 0xB600FA78
	.long 0BAE630E2
	.long 0x07A2E392
	.long 0xE0C2E2F6
	.long 0xA2E04005
	.long 0x30E1E680
	.long 0x0320E1E1
	.long 0x7579ED30
	.long 0xE1037579
	.long 0xDF122671
	.long 0x20D5D278
	.long 0xA6760478
	.long 0xBAE6D2E2
	.long 0xA2E192E3
	.long 0xF622C000
	.long 0x78BCE643
	.long 0xBF01B577
	.long 0x02800BA6
	.long 0x77B41505
	.long 0xB6010280
	.long 0x01D353BF
	.long 0xFED00022
	.long 0x78BB79BA
	.long 0xE7208602
	.long 0x7600B600
	.long 0x11C2C0C2
	.long 0xE1F720E0
	.long 0x14308611
	.long 0x79BD77FF
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
	.long 0xE1F779BD
	.long 0x771906E6
	.long 0x022EA5B6
	.long 0x040D122D
	.long 0xB650D279
	.long 0xBD17E770
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
	.long 0x234FDCF7
	.long 0xD2C03087
	.long 0xFD12234F
	.long 0xDDFEDEFC
	.long 0xDFFAC286
	.long 0xD2861223
	.long 0x4FC2C053
	.long 0xBFFEC2E1
	.long 0xF779BD77
	.long 0x0A809FB6
	.long 0x060D80A2
	.long 0xB6092730
	.long 0x0E942087
	.long 0x91800CB6
	.long 0x070E79BD
	.long 0x7700D25B
	.long 0x30878376
	.long 0x0A0212D1
	.long 0x0B608E180 # alignment check needed
	.long 0x812430F5
	.long 0xE77409D5
	.long 0xE0FD2200
9:

.long 0xFFFFFFFF
.end
