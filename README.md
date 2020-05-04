# Midway MCR3 port for MiSTer

[Original readme](README_orig.txt) (mostly irrelevant to MiSTer)

# Keyboard inputs :
```
   ESC    : Coin 1
   UP,DOWN,LEFT,RIGHT arrows : Player 1
   LCtrl  : Fire A
   LAlt   : Fire B
   Space  : Fire C   
   LShift : Fire D
   Z      : Fire E
   X      : Fire F 

   MAME/IPAC/JPAC Style Keyboard inputs:
     1           : Start 1 Player
     2           : Start 2 Player
     5           : Coin 1
     6           : Coin 2
     R,F,D,G     : Player 2
     A           : Fire2 A
     S           : Fire2 B 
     Q           : Fire2 C
     W           : Fire2 D
     I           : Fire2 E
     K           : Fire2 F
	
 Joystick support. 
```
# Games

### Timber
Up to 2 players. 
* Up/Down/Left/Right - movements 
* A - Chop Right 
* B - Chop Left

### Tapper
Up to 2 players.
* Up/Down/Left/Right - movements
* A - Fill
 
### Discs of Tron
Up to 2 players.
* Up/Down/Left/Right - movements
* A - Toss
* B - Deflect
* C - Aim Up
* D - Aim Down
Supports 2 control modes: Joystick/Spinner
Spinner - Rotate Right,Rotate Left

### Journey
Up to 2 players.
* Up/Down/Left/Right - movements
* A - Blast

Download a sound file from mame sounds ( https://samples.mameworld.info/ click current samples ) , and put journey.zip in:
_Arcade/sound/
 
 
# ROMs
```
                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip

```

Launch game using the appropriate .MRA
