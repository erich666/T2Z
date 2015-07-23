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
These are utility functions for various system operations. Think of this as a "miscellaneous"
file. The sculpture and animation support routines could have gone into their own tabs, but
that would have given us 2 more tabs, and there are already plenty of them. So I left them
all here together.
*/

/******************************
****  SCULPTURE UTILITIES
******************************/

// cost of sculpture as a String
String getCostEstimate( float cubicCentimetersMaterial, float cubicCentimetersMachine, float voxelCCM ) {
  // where the crazy formula comes from, with our own approximations thrown in:
  // https://www.shapeways.com/blog/archives/18174-how-much-does-it-cost-when-you-3d-print-a-thousand-different-parts-all-at-once.html
  float cost = 1.50 + // handling costubicCentimetersMhine;
               0.28 * cubicCentimetersMaterial * voxelCCM +
               0.21 * cubicCentimetersMachine * voxelCCM;
  return "$" + nf(cost, 0, 2);
}

// the number of triangles in the model
String getTriangleCount() {
  return TheMarcher.triangleString();
}

void updateSTLName() {
  String stlName = getNoBlanksAnimationName()+".stl";
  String stlTimeStampName = getNoBlanksTimeStampAnimationName()+".stl";
  // if you want the sculpture to change name to match your animation, uncomment the call
  // to setSTLName() below, and pass in one of the two variables above.
  //setSTLName(stlTimeStampName);
}

/*
We build the sculpture one pair of slices at a time. The first slice becomes the "lower" slice,
and the second one is the "upper". We build the triangles that connect them. Then the next time
a new slice arrives, the old "upper" becomes the new "lower", and the new slice becomes the "upper",
and we repeat. 
*/

void addFieldToSculpture(AUField newField) {
  boolean gotPair = getFieldPair(newField);
  if (gotPair) {
    processFieldPair();
  } else {
    reportError("addFieldToSculpture", "getPGPair returned false");
  }  
}

/*
Given the upper and lower fields, process them. Include the block beforehand
if it's been selected and this is the right place. If the block comes at the
very end, it gets inserted by concludeSculptureCreation() which is called when
all the slices have been processed.
*/
void processFieldPair() {
  // draw block before the next set of slices?
  float percentDone = norm(NextSliceNumber, 0, SculptureTotalSlices);
  if (SincludeBlock && (percentDone > SblockStart) && (!WroteBlock)) {
    // insert a block between the lower and upper fields
    TheMarcher.processFields(LowerField, BlockField, 1);
    if ( SculptureBlockThickness > 1 ) {
      TheMarcher.processFields(BlockField, BlockField, SculptureBlockThickness - 1);
    }
    TheMarcher.processFields(BlockField, UpperField, 1);
    WroteBlock = true;
  }
  else
  {
    // write out the normal slice
    TheMarcher.processFields(LowerField, UpperField, 1);
  }
}

// copy the upper field to the lower one, if needed, and get a new upper
boolean getFieldPair(AUField newField) {
  // copy upper of last frame to be lower of this frame
  if (NextSliceNumber > 0) {
    assert UpperField != null : "getFieldPair: b1 NextSliceNumber="+NextSliceNumber+" and UpperField is null";
    assert LowerField != null : "getFieldPair: b1 NextSliceNumber="+NextSliceNumber+" and LowerField is null";
    UpperField.copy(LowerField);
  } else if ( NextSliceNumber > SculptureTotalSlices ) {
    return false;
  } else {
    // or if starting out, copy blank to lower  
    assert LowerField != null : "getFieldPair: b3 NextSliceNumber="+NextSliceNumber+" and LowerField is null";
    AllOutsideField.copy(LowerField);
  }

  UpperField.flatten(1);
  assert newField.h == UpperField.h - Border*2 : "UpperField "+UpperField.h+" and newField "+newField.h+" plus Border don't match in size!";
  for (int y=0; y<newField.h; y++) {
    for (int x=0; x<newField.w; x++) {
      UpperField.z[y+Border][x+Border] = newField.z[y][x];
    }
  }
  assert UpperField.z[0][0] == 1.0 : "UpperField should have a value of 1.0, but it's "+UpperField.z[0][0]+" instead!";
  
  if (Asnapshots > 2) {
    applySmoothingFilter(UpperField);  
  }
  
  // Count off this frame
  NextSliceNumber++;

  return true; 
}

void applySmoothingFilter(AUField field) {
  /* For snapshots > 2, adjust the grayscale values towards
  0.5. This is easiest to explain with an example.
  I will not put my logic here, but think of how a
  series of motion blur values would interpolate
  when put next to a series of 0.0's (fully inside), like so:
    1.00   0.75   0.50   0.25   0.00
    0.00   0.00   0.00   0.00   0.00
  
  You want the isosurface at 0.5 to pass halfway between
  0.00 and 1.0 - that works, it's halfway between. You want
  it to go through 0.5 itself - that works, it's then all
  the way up through 0.5. But 0.75 and 0.00 will not give
  you a value that is 3/4ths of the way up from 0.00 - instead
  0.5 is just 2/3rds of the way up. To get it 3/4ths of the
  way up, the 0.75 needs to be replaced with an 0.6666.
  This is where the formulae come from, essentially: the
  values greater than 0.0 and less than 1.0 are made to be
  closer to 0.5, to draw the surface more in line. This
  actually works! The < 0.5 formula is for the opposite case,
  where the bottom row is all 1.0's.
  */
  for (int y=0; y<field.h; y++) {
    for (int x=0; x<field.w; x++) {
      float v = field.z[y][x];
      if (v > .5) field.z[y][x] = 0.5/(1.5-v);
      else field.z[y][x] = v/(0.5+v);
    }
  }
}  


/*
Set everything up to begin a new sculpture. There are a few controls that could cause
our data structures to change size: the frame size, the "speedup" control (which controls
the voxel size), the size of the border, and so on. Rather than keep track of what's
changed since the last time, we just build new versions of everything. It's a little
blunt, but it's a solid way to be sure we're starting fresh, and it's fast enough that
it adds almost nothing to the time required to build the sculpture.
*/

void initNewSculpture() {
  //////////// Build new everything related to the marcher
  //TotalMillis = millis();
  
  /*
  When we speed up the sculpture, we use fewer frames, and each one
  is smaller. To get smaller images we temporarily scale down the values
  of Awidth and Aheight from the values they have from the sliders. 
  After we build the sculpture, we restore their original values. We don't
  have to move the sliders themselves because they're disabled while the
  sculpture is building. We'll rebuild all the marcher objects to use
  these new sizes, knowing that they'll get rebuilt later if we move
  the speedup slider.
  */
  HoldAwidth = Awidth;
  HoldAheight = Aheight;
  Awidth = int(Awidth / SvoxelSize);  
  Aheight = int(Aheight / SvoxelSize);

  if (NeedToRebuildMarcherFields) {
    NeedToRebuildMarcherFields = false;
        
    // pass in height and cross-sectional width of voxel, in MM
    MarchWid = Awidth;  
    MarchHgt = Aheight;
    int fieldWid = (2*Border)+MarchWid;
    int fieldHgt = (2*Border)+MarchHgt;
   
    PGraphics blockPG = createGraphics(fieldWid, fieldHgt);
    blockPG.beginDraw();
      // fill with outside stuff
      blockPG.background(255);
      blockPG.noStroke();
      // now fill interior with inside stuff
      blockPG.fill(0);
      blockPG.rect(Border, Border, MarchWid, MarchHgt);
    blockPG.endDraw();
    BlockField = new AUField(this, fieldWid, fieldHgt);
    AllOutsideField = new AUField(this, fieldWid, fieldHgt);
    BlockField.fromPixels(AUField.FIELD_RED, blockPG);
    BlockField.mul(1./255);  // set range to [0,1]
        
    PGraphics allOutsidePG = createGraphics(fieldWid, fieldHgt);
    allOutsidePG.beginDraw();
      allOutsidePG.background(255);
    allOutsidePG.endDraw();
    AllOutsideField.fromPixels(AUField.FIELD_RED, allOutsidePG);
    AllOutsideField.mul(1./255);  // set range to [0,1]
    
    resizingPG = createGraphics(fieldWid, fieldHgt);
    resizingImage = createImage(Awidth, Aheight, RGB);

    LowerField = new AUField(this, fieldWid, fieldHgt);
    UpperField = new AUField(this, fieldWid, fieldHgt); 
  }
  
  assert MarchWid == Awidth : "MarchWid of "+MarchWid+" and Awidth of "+Awidth+" don't match!";
  
  StlWriter = new STLWriter(STLFilename, true);

  SculptureTotalSlices = int(AnumFrames / int(SvoxelSize + 0.5));

  // The rule: by default, the object (without a base) will fit into a cube;
  // remember that Awidth is the scaled down (by SvoxelSize) dimensions
  int marchControl = ( Awidth > Aheight ) ? Awidth : Aheight;
  TheMarcher = new Marcher(StlWriter,
      10.0*Sheight/SculptureTotalSlices,  // mm, height divided by total slices
      10.0*Sheight*ScrossSectionScale/marchControl);  // mm, height*width_scale*cluster/

  NextSliceNumber = 0;
  
  // these only get used if we're including the block
  // Take the number of slices, divide by total height to get slices per 1 CM.
  // Multiply by block thickness in CM to get number of slices in CM.
  SculptureBlockThickness = SblockHeight * SculptureTotalSlices / Sheight;
  WroteBlock = false;
}

// All the book-keeping associated with finishing a new sculpture.
void concludeSculptureCreation() {
  // write the block and finish it, if needed
  if (SincludeBlock && (!WroteBlock)) {
    TheMarcher.processFields(UpperField, BlockField, 1);
    if ( SculptureBlockThickness > 1 ) {
      TheMarcher.processFields(BlockField, BlockField, SculptureBlockThickness - 1);
    }
    TheMarcher.processFields(BlockField, AllOutsideField, 1);
    WroteBlock = true;
  } else {
    // Have to write a final "capping" frame.
    UpperField.copy(LowerField);
    AllOutsideField.copy(UpperField);
    processFieldPair();
  }
  // close the file, post the cost, re-enable buttons, etc.
  TheMarcher.destroy();
  StlWriter.close();
  
  // find the size of a voxel in cubic centimeters
  // height of a voxel is simply the height / slices
  // cross section area is the height times the cross section squared times (slice width or slice height)
  // divided by pixel width and pixel height.
  float voxelCCM = ( Sheight / SculptureTotalSlices ) * 
      ( Sheight * ScrossSectionScale / MarchWid ) * 
      ( Sheight * ScrossSectionScale / MarchHgt );
  Scost = getCostEstimate(TheMarcher.getVoxelsOfMaterial(), TheMarcher.getVoxelsOfMachine(),voxelCCM);
  showCostEstimate();
  StriangleCount = getTriangleCount();
  showTriangleCount();
  
  Awidth = HoldAwidth;
  Aheight = HoldAheight;
  // Uncomment to show time spent building sculpture in the console.
  //TotalMillis = millis()-TotalMillis;
  //println( "Milliseconds spent: " + TotalMillis );
}


/******************************
****  ANIMATION UTILITIES
******************************/

MyCamera Camera;   // The camera that saves images and makes motion blur
PImage SavedImage; // Reusable buffer for GifExporter

// When we start a new animation, we get the globals set up and then
// call the selected Asetup#() function.

void setupNewAnimation() {  
  setupAnimationGlobals(); 
  restartAnimation();
}

/*
Draw a new frame. We clear to the background in case the user forgets, then we call the
currently-active Adraw#() routine. We add the image to the camera. If the camera tells us
that it's ready to save (it's accumulated enough snapshots and has a complete frame), we
then save that image as a PNG, and/or add it to the GIF animation, and/or add it to the
sculpture (in practice, we'll never do the first two if we're building the sculpture, and
vice-versa. But it's easy to just treat them all as possibilities.
*/

void drawAnimation(float time) {  
  background(BackgroundColor);
  renderAnimation(time);
  Camera.expose();
  if (Camera.isReadyToSave()) {
    if (SaveSculpture) {
      addFieldToSculpture(Camera.grayFilm);
    } else if (DrawMode == DRAW_MODE_SAVE_ANIM) {
      if (SavePNGFrames) {
        Camera.saveImage("png");
      }
      if (SaveGIFAnimation) {  
        SavedImage = Camera.exposedFramePG.get();
        GifExporter.addFrame(SavedImage);
      }
    } 
  }
}

// wrap up the animation. Close the sculpture if we were saving that, and close the gif
// if we were saving that. Turn all the controls back on.

void endAnimation() {  
  if (DrawMode == DRAW_MODE_SCULPTURE) {
    concludeSculptureCreation();
  }
  if ((!SaveSculpture) && (SaveGIFAnimation) && (DrawMode == DRAW_MODE_SAVE_ANIM)) {
    GifExporter.finish();
  }
  DrawMode = DRAW_MODE_NONE; 
  SaveSculpture = false;
  turnOnAllControls();
  RunAnimationButton.setState(0);
  RunAnimationButtonState = 0;
  NewDrawing = true;
  
}

// set up the globals for a new run of animation

void setupAnimationGlobals() {
  // Raising the number of cycles shouldn't change the number of frames generated.
  // Note that TotalFrameCount == SculptureTotalSlices unless multiple frames
  // are used to generate a single final frame (motion blur via Asnapshots).
  TotalFrameCount = int(AnumFrames * Asnapshots / (SaveSculpture ? float(int(SvoxelSize + 0.5)) : 1.0));
  AframeCount = 0;
  Camera = new MyCamera();  
  if ((SavePNGFrames || SaveGIFAnimation) && (DrawMode == DRAW_MODE_SAVE_ANIM)) {
    SavedImage = createImage(Awidth, Aheight, RGB);
  }  
  if ((!SaveSculpture) && (SavePNGFrames) && (DrawMode == DRAW_MODE_SAVE_ANIM)) {
    String dirPath = savePath(PNGDirectoryName); // undocumented Processing function! 
    File dir = new File(dirPath);                // create the output directory if necessary
    if (dir.exists()) {                          
      for(File file: dir.listFiles()) file.delete();  // delete existing files  
    }
  } 
  if ((!SaveSculpture) && (SaveGIFAnimation) && (DrawMode == DRAW_MODE_SAVE_ANIM)) {
    String noBlanksName = getNoBlanksTimeStampAnimationName();
    String gifName = noBlanksName+".gif";
    GifExporter = new GifMaker(this, gifName, GifCompressionQuality);  
    GifExporter.setRepeat(0); // animation loops forever
    GifExporter.setDelay(16); // 16 ms delay produces about 60 frames/sec. Weirdly, 0 ms makes huge delays.
  }
}

String getNoBlanksTimeStampAnimationName() {
  return getNoBlanksAnimationName() + "-" + getTimeStampAsString();
}

String getNoBlanksAnimationName() {
  String name = ChosenAnimationName;
  String noBlanksName = "";
  for (int i=0; i<name.length(); i++) {
    char ch = name.charAt(i);
    if ((ch==' ') || (ch=='\t') || (ch=='\r')) noBlanksName += "_";
    else noBlanksName += ch;
  }
  return noBlanksName;
}

String getTimeStampAsString() {
  return year()+"-"+nf(month(),2)+"-"+nf(day(),2)+"_"+nf(hour(),2)+"-"+nf(minute(),2);
}

void restartAnimation() {
  Animator anim  = AnimatorList.get(ChosenAnimationUINumber);
  if (anim.needsRebuild) {
    GSlider req = anim.SliderRequestingRebuild;
    if ((req == null)  || (!req.hasFocus())) {
      anim.rebuild();
      anim.SliderRequestingRebuild = null;
      anim.needsRebuild = false;
      RequestStopAnimating = false;
    }
  }
  anim.restart();
}

void renderAnimation(float time) {
  Animator anim  = AnimatorList.get(ChosenAnimationUINumber);
  anim.render(time);
}

/******************************
****  MODE SWITCHING CONTROL
******************************/

void turnOffAllControls() {
  NeedToRebuildGlobals = true;
  
  // Turn off camera controls and animation
  turnGroupOff(SaveAnimationButtonGroup);
  if (DrawMode != DRAW_MODE_RUN_ANIM) {
    turnGroupOff(RunAnimationButtonGroup);  
    turnAnimationGroupsOff();
  } 
  turnGroupOff(CameraControlsGroup);
  turnGroupOff(AnimationControlsGroup);
  
  // turn off sculpture controls
  turnGroupOff(BlockControlsGroup);
  turnGroupOff(BuildSculptureButtonGroup);
  turnGroupOff(SculptureControlsGroup);
}

void turnOnAllControls() {  
  DrawMode = DRAW_MODE_NONE;
  
  // turn camera controls back on
  turnGroupOn(SaveAnimationButtonGroup); 
  turnGroupOn(RunAnimationButtonGroup);
  turnGroupOn(CameraControlsGroup);  
  turnGroupOn(AnimationControlsGroup);
  turnAnimationGroupsOn();
  
  RunAnimationButton.setState(0);
  SaveAnimationButton.setState(0);
  BuildSculptureButton.setState(0);

  
  // turn sculpture controls back on
  if (SincludeBlock) turnGroupOn(BlockControlsGroup);
  turnGroupOn(BuildSculptureButtonGroup);
  turnGroupOn(SculptureControlsGroup);
}
 
/******************************
****  CONSTRUCT FILENAME FOR FRAMES
******************************/

String makeFrameFullFilename(int frameNumber, String fileType) {
  String path = PNGDirectoryName + "/" + PNGFrameBaseName + nf(frameNumber, 5) + "." + fileType;   
  return path;
}

/******************************
****  CALL EXTERNAL ROUTINE, OS DEPENDENT
******************************/

boolean DetectedOS = false;
boolean IsWindows = false;

// We should be able to do this with Processing's built in open() command,
// but I can't get it to work as documented and nobody on the forum seems
// to know how to get it to work, either. So just use some straight Java.
void runExternalCommand(String cmd) {
  String macCmd = "/bin/bash "+ SketchPath + cmd + ".sh";
  String windowsCmd = SketchPath + "\\" + cmd + ".bat";
  if (!DetectedOS) IsWindows = isWindows();
  try {
    Runtime.getRuntime().exec(cmd);
  }
  catch(IOException e) {
    println("runExternalCommand: IOException:" + e);
  }
}

boolean isWindows() {
  DetectedOS = true;
  return System.getProperty("os.name").startsWith("Windows");
}

// does this file exist? The name is local to the sketch directory. Side effect is
// that the file is created if it's not already there. 
boolean fileExists(String localPath) {
  String fullPath = savePath(localPath); // undocumented Processing function! 
  File file = new File(fullPath); 
  return file.exists();
}

/******************************
****  The Camera
******************************/

/*
I like using the AUCamera from the AULibrary, but preparing frames for the 
marcher requires some special processing that the AUCamera doesn't know about.
So instead, I've written a stripped-down custom version that implements a
simple, always-open shutter, and helps us prepare both color images for 
display and saving, as well as grayscale images for the sculpture.
*/

class MyCamera {
  AUMultiField film;         // the accumulating image
  AUField grayFilm;          // grayscale made from binary black/white images
  int exposureCount;         // how many exposures since last save
  boolean readyToSave;       // true when we have a new save frame
  PGraphics exposedFramePG;  // the new save frame, ready to use
  int savedFrameNumber;      // the number of the frame we're going to save
  
  MyCamera() {
    film = new AUMultiField(ThisApplet, 3, Awidth, Aheight);
    film.flatten(0);
    grayFilm = new AUField(ThisApplet, Awidth, Aheight);
    grayFilm.flatten(0);
    exposedFramePG = createGraphics(Awidth, Aheight);
    exposureCount = 0;
    readyToSave = false;
    savedFrameNumber = 0;
  }
  
  /*
  For the normal color image, add the picture on the screen to the film AUMultiField.
  When the film has been exposed enough times (that is, Asnapshots times since the
  last save), scale the film by the number of snapshots so it's in the range [0,255],
  and set readyToSave to true so we'll know to process this image. The next time in,
  if we just saved, set readyToSave to false, and both the film and the grayFilm to 0.
  The grayFilm is used for the marcher. It's like the film variable, but it's an
  AUField, so it holds only one float per pixel. Initially all black, each time we
  expose a new frame we add 1 to all pixels that are in the background. Then when
  the frame is ready for saving, we divide by the number of snapshots. This means
  that pixels that were always in the background have a value of 0 (meaning air),
  those that were always drawn have a value of 1 (meaning material is present), and
  values in-between are motion-blurred, telling us how much of time the pixel was
  drawn. The marcher is able to use these intermediate values to produce a smoother
  surface than one that was black and white.
  */
  
  void expose() {
    if (readyToSave) { // was the last frame saved? If so, clear the new one
      film.flatten(0);
      grayFilm.flatten(0);
    }
    colorMode(RGB, 255, 255, 255, 255);
    int bgR = int(red(BackgroundColor));
    int bgG = int(green(BackgroundColor));
    int bgB = int(blue(BackgroundColor));
    loadPixels();  // so we can read the screen
    // add every screen pixel RGB to the accumulating RGB in film
    for (int y=0; y<Aheight; y++) {
      for (int x=0; x<Awidth; x++) {
        color c = pixels[(y*width)+x];
        int cR = int(red(c));
        int cG = int(green(c));
        int cB = int(blue(c));
        film.fields[0].z[y][x] += cR;
        film.fields[1].z[y][x] += cG;
        film.fields[2].z[y][x] += cB;
        if (DrawMode == DRAW_MODE_SCULPTURE) {
          if ((cR == bgR) && (cG == bgG) && (cB == bgB)) {
            grayFilm.z[y][x] += 1;  // background pixels go to 1
          }
        } 
      }
    }
    readyToSave = false;
    exposureCount++;
    int amod = (exposureCount % Asnapshots);
    // exposureCount is incremented before this line, so will reach the limit when it hits 0
    if ((exposureCount % Asnapshots) == 0) {
      if (Asnapshots > 1) {
        film.mul(1./Asnapshots);
      }
      if (DrawMode == DRAW_MODE_SCULPTURE) {        
        grayFilm.mul(1./Asnapshots);  // scale to [0,1]
      }
      readyToSave = true;
      exposureCount = 0;
      film.RGBtoPixels(0, 0, exposedFramePG);
    } 
  }
  
  boolean isReadyToSave() {
    return readyToSave;
  }
  
  void saveImage(String filetype) {
    String saveFilename = makeFrameFullFilename(savedFrameNumber++, filetype);
    // saveFilename = "EmberSlices/slice_" + savedFrameNumber + ".gif";   // un-comment this line to save Ember style frames
    Camera.exposedFramePG.save(saveFilename);
  }
}

/******************************
****  The Animator Class
******************************/

/*
Our setup for individual animations is to make them subclasses of the Animator class.
This is really not much more than a placeholder for the name and list of sliders that
are created by the animation, but it lets us make an array of these objects (since all
the subclasses are also of type Animator), which makes for a nice code structure, and
gives us a way to handle callbacks on the sliders.
*/

class Animator {
  String name;
  SliderSet sliders;
  boolean needsRebuild;             // do we need to rebuild the animation?
  GSlider SliderRequestingRebuild;  // the slider that set needsRebuild to true

  Animator(String _name) {
    name = _name;
    sliders = new SliderSet();
    needsRebuild = true;
    SliderRequestingRebuild = null;
  }
  
  void rebuild() {
    // empty placeholder. Derived classes may provide an implementation, but it's not required
  }
  
  void restart() {
    // empty placeholder. Derived classes must provide an implementation
  }
  
  void render(float time) {
    // empty placeholder. Derived classes must provide an implementation
  }
  
  void sliderChanged(String sliderName, int iValue, float fValue) {
    // empty placeholder. Derived classes must provide an implementation
  }
}

/******************************
****  The Stepper
******************************/

/*
A liberal adaptation of the AUStepper object, reshaped for a new set of inputs & outputs.
getStepNum() does a simple linear search from the start of the list. Of course we could
make this a nice, mostly-balanced binary tree for O(log n) searching, but the lists are 
usually so short (like 2 to 5 entries) that it doesn't seem worth the effort to allocate
memory for the nodes, link them up, etc. Maybe someday if this becomes a bottleneck that
optimization can be done.
*/

class Stepper323 {
  
  float[] sumLen;
  int[] easeType;
  
  Stepper323(float[] stepLengths) {    
    assert stepLengths != null : "Stepper323: stepLengths vector is null";
    assert stepLengths.length >= 1 : "Stepper323: stepLengths vector length is not >= 1";
    sumLen = new float[1+stepLengths.length];
    easeType = new int[stepLengths.length];
    sumLen[0] = 0;
    for (int i=0; i<stepLengths.length; i++) {
      sumLen[i+1] = sumLen[i] + stepLengths[i];
      easeType[i] = AULib.EASE_IN_OUT_CUBIC;
    }
    for (int i=0; i<stepLengths.length+1; i++) {
      sumLen[i] /= sumLen[stepLengths.length];
    }
  }
  
  int getStepNum(float time) {
    while (time < 0) time += 1;
    if (time > 1) time = time%1; // the test is to avoid doing 1%1 = 0
    for (int i=1; i<sumLen.length; i++) {
      if (time <= sumLen[i]) return i-1;
    }
    // if floating-point error left us hanging off the end, return the end value 
    return sumLen.length-1;
  }
  
  float getAlfa(float time) {
    int stepNum = getStepNum(time);
    float stepStartTime = sumLen[stepNum];
    float stepEndTime = sumLen[stepNum+1];
    float a = norm(time, stepStartTime, stepEndTime);
    a = constrain(a, 0, 1);
    float b = AULib.ease(easeType[stepNum], a);
    return b;
  }
  
  void setAllEases(int _easeType) {
    for (int i=0; i<sumLen.length-1; i++) {
      easeType[i] = _easeType;
    }
  }
  
  void setEases(int[] _eases) {
    assert _eases != null : "setEases: input vector is null";
    assert _eases.length >= 1 : "setEases: input vector length is not >= 1";
    for (int i=0; i<sumLen.length-1; i++) {
      easeType[i] = _eases[i%_eases.length];
    }
  }
}
