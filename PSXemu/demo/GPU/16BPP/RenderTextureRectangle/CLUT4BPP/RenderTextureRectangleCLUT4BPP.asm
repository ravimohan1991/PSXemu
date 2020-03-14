; PSX 'Bare Metal' GPU 16BPP Render Texture Rectangle CLUT 4BPP Demo by krom (Peter Lemon):
.psx
.create "RenderTextureRectangleCLUT4BPP.bin", 0x80010000

.include "LIB/PSX.INC" ; Include PSX Definitions
.include "LIB/PSX_GPU.INC" ; Include PSX GPU Definitions & Macros

.org 0x80010000 ; Entry Point Of Code

la a0,IO_BASE ; A0 = I/O Port Base Address ($1F80XXXX)

; Setup Screen Mode
WRGP1 GPURESET,0  ; Write GP1 Command Word (Reset GPU)
WRGP1 GPUDISPEN,0 ; Write GP1 Command Word (Enable Display)
WRGP1 GPUDISPM,HRES320+VRES240+BPP15+VNTSC ; Write GP1 Command Word (Set Display Mode: 320x240, 15BPP, NTSC)
WRGP1 GPUDISPH,0xC60260 ; Write GP1 Command Word (Horizontal Display Range 608..3168)
WRGP1 GPUDISPV,0x042018 ; Write GP1 Command Word (Vertical Display Range 24..264)

; Setup Drawing Area
WRGP0 GPUDRAWM,0x000408   ; Write GP0 Command Word (Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)
WRGP0 GPUDRAWATL,0x000000 ; Write GP0 Command Word (Set Drawing Area Top Left X1=0, Y1=0)
WRGP0 GPUDRAWABR,0x03BD3F ; Write GP0 Command Word (Set Drawing Area Bottom Right X2=319, Y2=239)
WRGP0 GPUDRAWOFS,0x000000 ; Write GP0 Command Word (Set Drawing Offset X=0, Y=0)

; Copy Textures To VRAM
CopyRectCPU 512,0, 2,8 ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height
li t0,7 ; T0 = Data Copy Word Count
la a1,Texture8x8 ; A1 = Texture RAM Offset
CopyTexture8x8:
  lw t1,0(a1) ; T1 = DATA Word
  addiu a1,4  ; A1 += 4 (Delay Slot)
  sw t1,GP0(a0) ; Write GP0 Packet Word
  bnez t0,CopyTexture8x8 ; IF (T0 != 0) Copy Texture8x8
  subiu t0,1 ; T0-- (Delay Slot)

CopyRectCPU 514,0, 4,16 ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height
li t0,31 ; T0 = Data Copy Word Count
la a1,Texture16x16 ; A1 = Texture RAM Offset
CopyTexture16x16:
  lw t1,0(a1) ; T1 = DATA Word
  addiu a1,4  ; A1 += 4 (Delay Slot)
  sw t1,GP0(a0) ; Write GP0 Packet Word
  bnez t0,CopyTexture16x16 ; IF (T0 != 0) Copy Texture16x16
  subiu t0,1 ; T0-- (Delay Slot)

CopyRectCPU 518,0, 8,32 ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height
li t0,127 ; T0 = Data Copy Word Count
la a1,Texture32x32 ; A1 = Texture RAM Offset
CopyTexture32x32:
  lw t1,0(a1) ; T1 = DATA Word
  addiu a1,4  ; A1 += 4 (Delay Slot)
  sw t1,GP0(a0) ; Write GP0 Packet Word
  bnez t0,CopyTexture32x32 ; IF (T0 != 0) Copy Texture32x32
  subiu t0,1 ; T0-- (Delay Slot)

CopyRectCPU 526,0, 16,64 ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height
li t0,511 ; T0 = Data Copy Word Count
la a1,Texture64x64 ; A1 = Texture RAM Offset
CopyTexture64x64:
  lw t1,0(a1) ; T1 = DATA Word
  addiu a1,4  ; A1 += 4 (Delay Slot)
  sw t1,GP0(a0) ; Write GP0 Packet Word
  bnez t0,CopyTexture64x64 ; IF (T0 != 0) Copy Texture64x64
  subiu t0,1 ; T0-- (Delay Slot)

; Copy Palette Color Look Up Table (CLUT) To VRAM
CopyRectCPU 512,256, 6,1 ; Copy Rectangle (CPU To VRAM): X,Y, Width,Height
li t0,3 ; T0 = Data Copy Word Count
la a1,CLUT ; A1 = Texture RAM Offset
CopyCLUT:
  lw t1,0(a1) ; T1 = DATA Word
  addiu a1,4  ; A1 += 4 (Delay Slot)
  sw t1,GP0(a0) ; Write GP0 Packet Word
  bnez t0,CopyCLUT ; IF (T0 != 0) Copy Texture64x64
  subiu t0,1 ; T0-- (Delay Slot)

; Render Texture Rectangles
TexRectRaw 32,8, 0,0, 0x4020, 8,8     ; Texture Rectangle Raw: X,Y, U,V, PAL, Width,Height
TexRectRaw 96,8, 8,0, 0x4020, 16,16   ; Texture Rectangle Raw: X,Y, U,V, PAL, Width,Height
TexRectRaw 160,8, 24,0, 0x4020, 32,32 ; Texture Rectangle Raw: X,Y, U,V, PAL, Width,Height
TexRectRaw 224,8, 56,0, 0x4020, 64,64 ; Texture Rectangle Raw: X,Y, U,V, PAL, Width,Height

WRGP0 GPUDRAWM,0x003408 ; Write GP0 Command Word (Texture Rectangle Flip Y Bit 13, Texture Rectangle Flip X Bit 12, Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectRawAlpha 34,9, 7,7, 0x4020, 8,8        ; Texture Rectangle Raw Alpha: X,Y, U,V, PAL, Width,Height
TexRectRawAlpha 100,10, 23,15, 0x4020, 16,16  ; Texture Rectangle Raw Alpha: X,Y, U,V, PAL, Width,Height
TexRectRawAlpha 168,12, 55,31, 0x4020, 32,32  ; Texture Rectangle Raw Alpha: X,Y, U,V, PAL, Width,Height
TexRectRawAlpha 240,16, 119,63, 0x4020, 64,64 ; Texture Rectangle Raw Alpha: X,Y, U,V, PAL, Width,Height

WRGP0 GPUDRAWM,0x000408 ; Write GP0 Command Word (Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectBlend 0x0000FF, 32,88, 56,0, 0x4020, 64,64  ; Texture Rectangle Blend: Color, X,Y, U,V, PAL, Width,Height
TexRectBlend 0x00FF00, 128,88, 56,0, 0x4020, 64,64 ; Texture Rectangle Blend: Color, X,Y, U,V, PAL, Width,Height
TexRectBlend 0xFF0000, 224,88, 56,0, 0x4020, 64,64 ; Texture Rectangle Blend: Color, X,Y, U,V, PAL, Width,Height

WRGP0 GPUDRAWM,0x003408 ; Write GP0 Command Word (Texture Rectangle Flip Y Bit 13, Texture Rectangle Flip X Bit 12, Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectBlendAlpha 0x00FF00, 48,96, 119,63, 0x4020, 64,64  ; Texture Rectangle Blend Alpha: Color, X,Y, U,V, PAL, Width,Height
TexRectBlendAlpha 0xFF0000, 144,96, 119,63, 0x4020, 64,64 ; Texture Rectangle Blend Alpha: Color, X,Y, U,V, PAL, Width,Height
TexRectBlendAlpha 0x0000FF, 240,96, 119,63, 0x4020, 64,64 ; Texture Rectangle Blend Alpha: Color, X,Y, U,V, PAL, Width,Height

WRGP0 GPUDRAWM,0x000408 ; Write GP0 Command Word (Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectRaw1x1 80,102, 0,0, 0x4020  ; Texture Rectangle Raw Dot (1x1): X,Y, U,V, PAL
TexRectRaw1x1 176,102, 7,0, 0x4020 ; Texture Rectangle Raw Dot (1x1): X,Y, U,V, PAL
TexRectRaw1x1 272,102, 0,7, 0x4020 ; Texture Rectangle Raw Dot (1x1): X,Y, U,V, PAL

TexRectRawAlpha1x1 80,122, 0,0, 0x4020  ; Texture Rectangle Raw Alpha Dot (1x1): X,Y, U,V, PAL
TexRectRawAlpha1x1 176,122, 7,0, 0x4020 ; Texture Rectangle Raw Alpha Dot (1x1): X,Y, U,V, PAL
TexRectRawAlpha1x1 272,122, 0,7, 0x4020 ; Texture Rectangle Raw Alpha Dot (1x1): X,Y, U,V, PAL

TexRectBlend1x1 0x0000FF, 80,132, 0,0, 0x4020  ; Texture Rectangle Blend Dot (1x1): Color, X,Y, U,V, PAL
TexRectBlend1x1 0x00FF00, 176,132, 7,0, 0x4020 ; Texture Rectangle Blend Dot (1x1): Color, X,Y, U,V, PAL
TexRectBlend1x1 0xFF0000, 272,132, 0,7, 0x4020 ; Texture Rectangle Blend Dot (1x1): Color, X,Y, U,V, PAL

TexRectBlendAlpha1x1 0x0000FF, 80,152, 0,0, 0x4020  ; Texture Rectangle Blend Alpha Dot (1x1): Color, X,Y, U,V, PAL
TexRectBlendAlpha1x1 0x00FF00, 176,152, 7,0, 0x4020 ; Texture Rectangle Blend Alpha Dot (1x1): Color, X,Y, U,V, PAL
TexRectBlendAlpha1x1 0xFF0000, 272,152, 0,7, 0x4020 ; Texture Rectangle Blend Alpha Dot (1x1): Color, X,Y, U,V, PAL

TexRectRaw8x8 32,172, 0,0, 0x4020 ; Texture Rectangle Raw (8x8): X,Y, U,V, PAL

TexRectBlend8x8 0x0000FF, 96,172, 0,0, 0x4020  ; Texture Rectangle Blend (8x8): Color, X,Y, U,V, PAL
TexRectBlend8x8 0x00FF00, 160,172, 0,0, 0x4020 ; Texture Rectangle Blend (8x8): Color, X,Y, U,V, PAL
TexRectBlend8x8 0xFF0000, 224,172, 0,0, 0x4020 ; Texture Rectangle Blend (8x8): Color, X,Y, U,V, PAL

WRGP0 GPUDRAWM,0x003408 ; Write GP0 Command Word (Texture Rectangle Flip Y Bit 13, Texture Rectangle Flip X Bit 12, Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectRawAlpha8x8 34,173, 7,7, 0x4020 ; Texture Rectangle Raw Alpha (8x8): X,Y, U,V, PAL

TexRectBlendAlpha8x8 0x00FF00, 98,173, 7,7, 0x4020  ; Texture Rectangle Blend Alpha (8x8): Color, X,Y, U,V, PAL
TexRectBlendAlpha8x8 0xFF0000, 162,173, 7,7, 0x4020 ; Texture Rectangle Blend Alpha (8x8): Color, X,Y, U,V, PAL
TexRectBlendAlpha8x8 0x0000FF, 226,173, 7,7, 0x4020 ; Texture Rectangle Blend Alpha (8x8): Color, X,Y, U,V, PAL

WRGP0 GPUDRAWM,0x000408 ; Write GP0 Command Word (Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectRaw16x16 32,196, 8,0, 0x4020 ; Texture Rectangle Raw (16x16): X,Y, U,V, PAL

TexRectBlend16x16 0x0000FF, 96,196, 8,0, 0x4020  ; Texture Rectangle Blend (16x16): Color, X,Y, U,V, PAL
TexRectBlend16x16 0x00FF00, 160,196, 8,0, 0x4020 ; Texture Rectangle Blend (16x16): Color, X,Y, U,V, PAL
TexRectBlend16x16 0xFF0000, 224,196, 8,0, 0x4020 ; Texture Rectangle Blend (16x16): Color, X,Y, U,V, PAL

WRGP0 GPUDRAWM,0x003408 ; Write GP0 Command Word (Texture Rectangle Flip Y Bit 13, Texture Rectangle Flip X Bit 12, Drawing To Display Area Allowed Bit 10, Texture Page Colors = 4BPP Bit 7..8, Texture Page Y Base = 0 Bit 4, Texture Page X Base = 512 Bit 0..3)

TexRectRawAlpha16x16 36,198, 23,15, 0x4020 ; Texture Rectangle Raw Alpha (16x16): X,Y, U,V, PAL

TexRectBlendAlpha16x16 0x00FF00, 100,198, 23,15, 0x4020 ; Texture Rectangle Blend Alpha (16x16): Color, X,Y, U,V, PAL
TexRectBlendAlpha16x16 0xFF0000, 164,198, 23,15, 0x4020 ; Texture Rectangle Blend Alpha (16x16): Color, X,Y, U,V, PAL
TexRectBlendAlpha16x16 0x0000FF, 228,198, 23,15, 0x4020 ; Texture Rectangle Blend Alpha (16x16): Color, X,Y, U,V, PAL

Loop:
  b Loop
  nop ; Delay Slot

Texture8x8:
  db 0x03,0x20,0x02,0x40 // 8x8x4B = 32 Bytes
  db 0x00,0x12,0x21,0x00
  db 0x20,0x11,0x11,0x02
  db 0x12,0x11,0x11,0x21
  db 0x12,0x11,0x11,0x21
  db 0x22,0x12,0x21,0x22
  db 0x00,0x12,0x21,0x00
  db 0x05,0x22,0x22,0x00

Texture16x16:
  db 0x33,0x00,0x00,0x20,0x02,0x00,0x00,0x44 // 16x16x4B = 128 Bytes
  db 0x33,0x00,0x00,0x12,0x21,0x00,0x00,0x44
  db 0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x12,0x11,0x11,0x21,0x00,0x00
  db 0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00
  db 0x00,0x12,0x11,0x11,0x11,0x11,0x21,0x00
  db 0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x02
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x22,0x22,0x22,0x11,0x11,0x22,0x22,0x22
  db 0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x55,0x00,0x20,0x11,0x11,0x02,0x00,0x00
  db 0x55,0x00,0x20,0x22,0x22,0x02,0x00,0x00

Texture32x32:
  db 0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x20,0x02,0x00,0x00,0x00,0x00,0x00,0x44,0x44 // 32x32x4B = 512 Bytes
  db 0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x12,0x21,0x00,0x00,0x00,0x00,0x00,0x44,0x44
  db 0x33,0x33,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x44,0x44
  db 0x33,0x33,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x44,0x44
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00
  db 0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00
  db 0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00
  db 0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00
  db 0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x22,0x22,0x22,0x22,0x22,0x22,0x11,0x11,0x11,0x11,0x22,0x22,0x22,0x22,0x22,0x22
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x00,0x00,0x00,0x20,0x22,0x22,0x22,0x22,0x02,0x00,0x00,0x00,0x00,0x00

Texture64x64:
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44 // 64x64x4B = 2048 Bytes
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44 
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44 
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44 
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44
  db 0x33,0x33,0x33,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x44,0x44,0x44,0x44
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00,0x00
  db 0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00
  db 0x00,0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00,0x00
  db 0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00
  db 0x00,0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21,0x00
  db 0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x12,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x21
  db 0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x55,0x55,0x55,0x55,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x22,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

CLUT:
  dh 0x0000,0xFFFF,0x8000,0x801F,0x83E0,0xFC00 // 6x16B = 12 Bytes

.close