
# Packman2 - the revenge

This is a pascal source code for a game, similar
to packman. Full source code (besides some music TPUs) is available.

If you plan in fixing the code - just cosmetic pull requests. I will not maintian this game besides the historical value. 

You will need TP7 (or compatible compiler for DOS) in order to compile it.

Home page contains also a zip with the EXEs
https://darkclouddos.github.io/darkcloud/

# Game play

Nothing to add. You know how this works. The gameplay is slow... 

Please comment if I should adjust the timings for the year 2019. 

# PMLE - Packman2 Level Editor

   The level editor is where you edit the levels for Pack Man 2 - The Revenge.
I used this program to write the game and if you know how to use it, it is
very usefull.

   The program edits 10 maps (or levels) in the same time. They are all saved
under the same name, all in one file. It uses the pictures of the first world
and the first picture. You can see how the level will look  on the screen,
and you can also play in the level you just wrote.

   The level editor can also be compiled to protected mode, as it was the
game. That means that you need to add the new condition NO_SOUND. It also
has the bug of the sounds and the problem with graphics. You need a lot of
memory to run it, ifyou dont have refer to PACKMAN.DOC to see how you can
run the game from TURBO-PASCAL and have a lot of memory.

##   Drawing something
   
  To draw some thing on the screen just press enter or space, you can move
with the cursor movement keys. If you are in draw mode when you mode it
draws the selected shape on the screen. Draw mode determinateshow do you
see the screen, any way the current spot is showed at the top of the screen.


Each slot in the map can contain:

 * Nothing               Clear terrain
 * Wall                  A normal wall
 * Food                  Food that the pack man eats in the maze
 * Cracker               The food you eat if you want to chase the mounsters
 * Mousnter wall         A wall that only the mounsters can walk trew (invisible)
 * Pack-Man wall         A wall that only the pack man can walk trew (invisible)
 * Both Wall             An invisible wall
* Black Hole            A place in wich no one can walk
 * Pack-Man Home         Where the packman begins the game
 * Mousnters Home        Where the mounsters begin the game

  Invisible wall meas that it looks like a normal wall, but you can walk trough them.


   ## Savings

  The first step in saving anything is naming the file (you do it by
pressing F4), then you have 2 options:

  1)  Saving the entire level in the format of the game.
  2)  Just save the buffer (makes a 640 byte file, no header).

  When you load a file, the program looks for the size of the file,
if it is 640 then it loads the file to the current level, otherwise
it loads all the levels into the editor.


## Function keys

     
    Gray Minus : See level before current.
    Gray Plus  : See level after current.
    Shift Tab,
    Control+M  : Change user mode.
    F2         : Save all the levels to file.
    F3         : Load all the levels from file.
    F4         : Read level name.
    F5         : Read number of normal mounsters in level.
    F6         : Read number of chase mounsters in level.
    F7         : Read number of hunt mounsters in level.
    F8         : Save current level.
    F9         : Copy current level to clipboard.
    F10        : Paste form clipboard.
    Insert,
    Control+V  : Change draw mode.
    Delete     : Fill level with selected thing (how do you call it???).
    Tab        : Select level on the map current.
    Alt+V      : See how the level will be.
    T,
    Control+T,
    Alt+T      : Test current level.
    Alt+R      : Redraw screen.
    <          : Select left.  (dont press shift just the key )
    >          : Select right. ( dont press shift just the key )
    0-9        : Select picture to draw.
    Alt+n      : (Where n is a number form 0 to 9) Select level n as active.

