.include "macros.S"

.globl _start
_start:

#============================================================================
# Corona Glitch3 SMC Patch
#============================================================================

# reboot on no_handshake failure
MAKEPATCH 0x13A0
0:
	.long 0x120213D9 # (at 0x13A3 is ljmp 0x13D9)
9:

# GPIO patches
MAKEPATCH 0x2568
0:
	.long 0x0075A290 # (0x256B = 0x90, P0.5 OUT dir)
9:

MAKEPATCH 0x2538
0:
	.long 0x84C25D22 # (0x2539 = 0xC2, force EXT_JTM to 0)
9:

# UART persistence
MAKEPATCH 0x25B4
0:
	.long 0xF275E8C0 # (0x25B7 = 0xC0)
9:

# Stack move logic
MAKEPATCH 0x7E4
0:
	.long 0x81C21224 # (0x7E5 = 0xC2)
9:

MAKEPATCH 0x804
0:
	.long 0xC21224A5 # (0x804 = 0xC2)
9:

# main calls hijack (0x805..0x84d)
# [Simplified for this example; full implementation would iterate these same offsets]

# Init Hook (hook at 0x7fd)
MAKEPATCH 0x7FC
0:
	.long 0x0D1214C0 # (0x7FD = lcall 0x14C0)
9:

#============================================================================
# PAYLOADS
#============================================================================

# Init Payload (0x14c0)
MAKEPATCH 0x14C0
0:
	.long 0x78BF7600
	.long 0x75E9FF00
9:

# Main Payload (align 0x31e0)
MAKEPATCH 0x31E0
0:
	.long 0x1231E712
	.long 0x32412278
	.long 0xA4B600FA
	.long 0x78BFE630
	.long 0xE207A2E3
	.long 0x92E0C2E2
	.long 0xF6A2E040
	.long 0x0530E1E6
	.long 0x800320E1
	.long 0xE17579E3
	.long 0x30E10375
	.long 0x79EB1229
	.long 0x9520D5D2
	.long 0x78A47604
	.long 0x78BFE6D2
	.long 0xE2A2E192
	.long 0xE3F622C0
	.long 0x0078C1E6
	.long 0x43BF01B5
	.long 0x7702800B
	.long 0xA677B415
	.long 0x05B60102
	.long 0x8001D353
	.long 0xBFFED000
	.long 0x2278C079
	.long 0xBFE72086
	.long 0x027600B6
	.long 0x0011C285
	.long 0xC2E1F720
	.long 0xE0143086
	.long 0x1179C277
	.long 0xFF802CB6
	.long 0x0102802F
	.long 0xB6020420
	.long 0x842122B6
	.long 0x032243BF
	.long 0x012084FD
	.long 0x3084FD20
	.long 0x84FD3084
	.long 0xFDD28553
	.long 0xBFFEC264
	.long 0xD2E1F779
	.long 0xC2771906
	.long 0xE60232FE
	.long 0xB6040D12
	.long 0x322350D2
	.long 0x79C217E7
	.long 0x70CC80EB
	.long 0xB60549C2
	.long 0x8543BF01
	.long 0x2084FD7A
	.long 0x107B097C
	.long 0x037D697E
	.long 0x6C7F05A2
	.long 0xE440027D
	.long 0x6AB2E4F7
	.long 0xDAFEDBFC
	.long 0x122523DC
	.long 0xF7D28530
	.long 0x84FD1225
	.long 0x23DDFEDE
	.long 0xFCDFFAC2
	.long 0x86D28612
	.long 0x2523C285
	.long 0x53BFFEC2
	.long 0xE1F779C2
	.long 0x770A809F
	.long 0xB6060280
	.long 0xA2B60713
	.long 0xD2643084
	.long 0x92760A02
	.long 0x13D92430
	.long 0xF5E77409
	.long 0xD5E0FD22
9:

.long 0xFFFFFFFF
.end
