// Copyright (c) 2015 Andrew Glassner and Eric Haines
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

/* 
NOTE: This code is prototype developer's code. It started as something very small
and grew over time as we added, changed, and removed features. Because we are still
making changes, we haven't gone back to do a "second system" version, where we clean
everything up, re-package and re-factor it, and so on. In particular, there are lots
of global variables, which generally isn't the most modern way to program, but it is
the easiest way to hack in new things and change existing things. Before this release,
we've looked through the code and cleaned it up where that was straightforward. We've 
also tried to document, through comments, what's going on where. 

There are several big pieces. This file sets everything up, and contains the draw()
routine that is at the heart of all animation in Processing. The files that begin 
with UI hold the user interface controls and callbacks for the various windows, built
on the G4P library. The files BinaryWriter and STLWriter manage efficient writing of
the huge 3D files that we produce. The Marcher file holds the code for our implementation
of the marching cubes algorithm, which turns stacks of frames into 3D objects. The
Utilities file is a catch-all for routines that feel like they are (or could be) general
purpose. Finally, the Animations file is where the various animation-making routines
live. This is where you can add your own code to make new loops and models!

We hope that you enjoy using this system and sharing the stuff you make with it.
Please feel free to hack away at this code and make it do whatever YOU want it to do!
*/

/* 
This is the main file for the Project323 system. It holds the system-wide globals,
and the top-level routines that make up the overall flow.
*/

import AULib.*;          // Andrew's Utilities library, for AUField and AUMultiField objects
import g4p_controls.*;   // The G4P library gives us multiple windows with UI elements
import gifAnimation.*;   // Provides us routines to directly write animated gifs

// These variables are mostly controlled via the user interface

String PNGDirectoryName = "pngFrames";  // directory name for the png files
int AnumFrames = 300;               // number of source image frames available to be read in
int Asnapshots = 1;                 // images per frame combined to do motion blur

String STLFilename = "Amazohedron.stl";  // name of STL file, relative to sketch directory
float Soffset = 0;                  // percentage of model where we start (ignoring block)
float Scycles = 1;                  // number of times the animation repeats
boolean SincludeBlock = false;      // should we include the block?
float SblockStart = 0.0;            // block starting location as percentage of height
float SblockHeight = 0.1;           // thickness of block in CM
int SvoxelSize = 1;                 // voxel size for the marcher. Its slider is labeled "Speedup"  
float Sheight = 5.0;                // total model height in CM
float ScrossSectionScale = 1;       // reduce the image size to speed up marching
boolean SaveGIFAnimation = false;   // save the frames as an animated gif
boolean SavePNGFrames = false;      // save animated frames in PNG format
boolean SaveSculpture = false;      // turn the frames into a 3D sculpture (no explicit UI for this)
PGraphics resizingPG = null;        // reusable buffer to help us quickly resize camera images
PImage resizingImage = null;        // reusable image to help use quickly resize camera images

int TotalMillis = 0;

// User variables not controlled by any UI widgets

/* 
The colors for animated gifs are selected by a neural net. It takes a single argument that
is undocumented, but smaller values are supposed to result in better color selections. They
recommend a value of 10. I found 7 is nicer, though 25% slower. I figure that's worth it. 
*/
int GifCompressionQuality = 7;  

int Border = 1;  // width in pixels of border around the image given to the marcher; normally 1

// Pixels of the background color will be "air" in the final model. All others will be solid.
color BackgroundColor = color(255, 205, 180);  // Define in each animation

// These globals are not for user control. They're shared by various pieces of the system.

// Globals for general, system-wide use

String SketchPath;                 // full path to the location of the sketch
PApplet ThisApplet;                // the Java applet that is this program. Needed by the Camera.
boolean EscapeCanExit = true;      // if true, hit escape while in graphics window to quit
boolean AskToConfirmExit = true;  // should we bring up a dialog box to confirm exit?

// Globals for the Camera

String PNGFrameBaseName = "frame";  // default name for frames

int MaxWindowWidth = 500;       // width of graphics window = maximum possible size for 2D animations
int MaxWindowHeight = 500;      // height of graphics window = maximum possible size for 2D animations
int Awidth = MaxWindowWidth;    // width of the animation we're drawing (and frames saved)
int Aheight = MaxWindowHeight;  // height of the animation we're drawing (and frames saved)
int HoldAwidth, HoldAheight;

GifMaker GifExporter;           // the object that manages creating animated gifs (not an easy job!)

// Globals for the Marcher that builds the sculpture (using the Marching Cubes algorithm)

Marcher TheMarcher;             // our Marcher object

boolean NeedToRebuildMarcherFields = true;  // when the frame size changes, rebuild the marcher fields
AUField LowerField, UpperField;             // 2D arrays of floats holding the data to be marched
AUField BlockField, AllOutsideField;        // all-in (0) with all-out (1) around the edge, and all out, at marcher input size

float CcMaterial = 0.0;                     // cubic centimeters of material
float CcMachine = 0.0;                      // cubic centimeters of machine space
String Scost = "not yet computed";          // estimated cost in dollars (a string)
String StriangleCount = "not yet computed"; // number of triangles in model (a string)

int MarchWid, MarchHgt;           // size of the images to be marched 
STLWriter StlWriter;              // object to write STL files
int NextSliceNumber;              // the next slice to be read in 
boolean WroteBlock;               // true if we've written a block for this sculpture

int SculptureTotalSlices;         // the number of slices the sculpture spans
float SculptureBlockThickness;    // the thickness (in marcher slices) of the block

// Globals for Animation

ArrayList<Animator> AnimatorList;  // list of animations
int ChosenAnimationUINumber = -1;  // which UI set is being displayed
String ChosenAnimationName = "";   // name of the selected animation
int TotalFrameCount;               // number of frames to draw. AnumFrames * Asnapshots
int AframeCount;                   // runs [0..TotalFrameCount) over course of animation
boolean NewDrawing = true;         // are we starting a new run of drawings?
boolean RequestStopAnimating = false; // set to true when a rebuild-enabled slider moves

final int DRAW_MODE_NONE = 0;       // draw() has nothing to do
final int DRAW_MODE_RUN_ANIM = 1;   // let the animation run without saving
final int DRAW_MODE_SAVE_ANIM = 2;  // produce animation frames
final int DRAW_MODE_SCULPTURE = 3;  // produce the sculpture
int DrawMode = DRAW_MODE_NONE;      // the current state of what draw() is doing

// Globals for the GUI

boolean NeedToRebuildGlobals = true;        // true when a control changes
final int COLOR_SCHEME_BLACK_ON_WHITE = 8;  // the row in user_gui_palette.png for black on white text 
final int COLOR_SCHEME_BLACK_ON_GRAY = 9;   // the row in user_gui_palette.png for black on gray text 
int FadeOutAlpha = 100;  // the opacity of the controls when they're temporarilhy unavailable (out of 255)
int FadeDuration = 400;  // milliseconds to fade in or out when the controls change 

/*********** END OF GLOBALS SECTION *****************/

// Processing's entry point for all sketches
void setup() {
  size(MaxWindowWidth, MaxWindowHeight);  // The graphics window
  ThisApplet = this;                      // Save the pointer to this Java applet
  SketchPath = sketchPath("");            // File system path to this sketch (undocumented Processing call!)
  rebuildGlobals();                       // Initialize and build all globals
  createGUI();                            // Build the UI windows and controls
  initUI();                               // Set the UI controls to default values from globals. Must come after createGUI().
  DrawMode = DRAW_MODE_NONE;              // We're idling until someone asks us to do something
}

void rebuildGlobals() {              
  if (!NeedToRebuildGlobals) return;
  // We don't need to do anything now, but this is here if we need it.
  NeedToRebuildGlobals = false;
}

// run the animation loop, handling the resulting frames as needed
void draw() {
  background(200);  // The color we draw to indicate that the loop is idle
  if (DrawMode == DRAW_MODE_NONE) return;  // nothing to do? quit now
  rebuildGlobals();         // rebuild the globals if they need it
  if (NewDrawing) {         // are we starting a fresh animation?
    setupNewAnimation();    // set everything up for a new run
    NewDrawing = false;     // and remember we don't need to do it again next time
  }
  // compute the time. It's [0, 1) over the course of one animation.
  float time = Soffset + Scycles * AframeCount / float(TotalFrameCount);
  float time01 = time % 1.0;  // get the time mod 1, so it's always [0, 1)
  drawAnimation(time01);      // build the frame and process it as needed
  // if we're not running free, then stop after one cycle
  if (RequestStopAnimating || ((++AframeCount >= TotalFrameCount) && (DrawMode != DRAW_MODE_RUN_ANIM))) {
    endAnimation();           // wrap up this animation cycle
    NewDrawing = true;        // next time draw() gets called, it's a fresh animation
    RequestStopAnimating = false; // if this is what stopped us, we've handled it
  }
}

/*
Process a keystroke if it was pressed while the mouse is in the graphics window. 
If the key is the Escape key, it will normally cause Processing to exit the
sketch. To prevent that, we overwrite the key variable to something other
than Escape (conventionally 0) so that by the time Processing checks the value
of key, it's no longer Escape, and so doesn't trigger the exit.
*/
void keyPressed() { 
 if (key != ESC) return; // if the key wasn't escape, don't do anything
 if (!EscapeCanExit) {   // escape can't be used to exit, so set key to 0      
   key = 0;
   return;
 }
 if (AskToConfirmExit) {
   if (confirmExitWithDialog()) 
     return;             // user confirmed an exit, so let key retain its value
 } 
 key = 0;  // we don't really want to exit, so set the key value to 0
}

// check with the user that they really want to exit
boolean confirmExitWithDialog() {
  String message = "Do you really want to exit?";
  String title = "Confirm exit";
  int reply = G4P.selectOption(this, message, title, G4P.WARNING, G4P.YES_NO);
  return reply == G4P.OK;
}
   
// put up a warning dialog and also print the warning to the output window
void reportWarning(String procname, String warning) {
  String message = "Warning from function "+procname+"()";  
  String title = warning;
  G4P.showMessage(this, message, title, G4P.WARNING);
  println(message+": "+title);
}
   
// put up an error dialog and also print the warning to the output window
void reportError(String procname, String error) {
  String message = "Error from function "+procname+"()";  
  String title = error;
  G4P.showMessage(this, message, title, G4P.ERROR);
  println(message+": "+title);
}


