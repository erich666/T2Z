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
The user interface for the camera. This is mostly straightforward calls on 
the G4P library for UI elements. We have a bunch of controls, and I visually
group them into colored rectangles. I also create G4P groups (GGroups) for
all the controls, just the run button, and just the build button. That's because
at different times we want to enable and disable different groups, so this lets
us get at each one conveniently.
*/

GWindow CameraWindow;                      // the window that holds the controls
ArrayList<GroupRect> CameraWindowRects;    // the colored rectangles that form visual groups

GLabel PNGDIrectoryLabel;
GTextField PNGDIrectoryField;
 
GLabel ImageControlsLabel;
GSlider NumFramesSlider, FrameSizeSlider, SnapshotsSlider;
GLabel NumFramesLabel, FrameSizeLabel, SnapshotsLabel;
  
GImageToggleButton SaveAnimationButton, RunAnimationButton; 
GCheckbox SaveGIFAnimationCheckbox, SavePNGFramesCheckbox;

GGroup CameraControlsGroup;
GGroup RunAnimationButtonGroup;
GGroup SaveAnimationButtonGroup; 

/*
The Run Animation button is a little different than the other buttons, because it's not a 
momentary pushbutton. Rather, push it and it moves into a new state while the animation
runs. Push it again and it moves back to the original state. The G4P library automatically
switches the image for the button when it's pressed (though I usually set it manually as
well, just to be safe), but we need to know the state ourselves to know what to do when
we receive an event that the button's been pressed. Sadly, G4P doesn't let us interrogate
a button to find out what state it's in, so we have to keep track of that ourselves.
*/

int RunAnimationButtonState = 0;

/******************* Callbacks *******************/

synchronized public void CameraWindow_draw1(GWinApplet appc, GWinData data) { 
  appc.background(240);  
  for (GroupRect gr: CameraWindowRects) {
    gr.render();
  }
} 

/*
G4P doesn't do anything particular for handling text fields, so we have to
do it ourselves. Our policy for a text box, as implemented in this code, is this:

Box doesn't have focus: background is white, global variable has value of box contents
Click in box: box gets focus, background goes gray
Type in box: box contents update to reflect typing. Global variable not changed.
Click anywhere outside of box: box loses focus, background goes white, global 
                               variable gets contents of box

So if the box is black-on-white, then what you see is the value of the global. If it's
black-on-gray, you're editing it. But as soon as you click anywhere else (on a slider,
on a button, on the background, etc.) the box loses focus and the global inherits the
value that's in the box. So for example you can modify the box contents and then click 
immediately on one of the creation buttons, and your newly-typed value will be used. 

There's no explicit cancel or undo, aside from the normal use of the backspace and delete keys.
*/

public void PNGDIrectoryField_change1(GTextField source, GEvent event) { 
  //println("PNGDIrectoryField - GTextField >> GEvent." + event + " @ " + millis());
  switch (event) {
    case CHANGED:
      // The typed key is in the char variable CameraWindow.papplet.key
      // Some special keys (e.g., escape) don't get passed through to here
      break;
    case GETS_FOCUS:
      source.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);
      break;
    case LOST_FOCUS:
      source.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
      PNGDirectoryName = source.getText();
      break;
    case ENTERED:
      // This is here in case we want the enter key to do something one day
      break;
    default:
  }
}

public void NumFramesSlider_change1(GSlider source, GEvent event) { 
  //println("NumFramesSlider - GSlider >> GEvent." + event + " @ " + millis());
  AnumFrames = source.getValueI();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
}

public void FrameSizeSlider_change1(GSlider source, GEvent event) { 
  //println("FrameSizeSlider - GSlider >> GEvent." + event + " @ " + millis());
  Awidth = source.getValueI();
  Aheight = Awidth;
  invalidateMeasures();
  NeedToRebuildGlobals = true;
  NeedToRebuildMarcherFields = true;
} 

public void SnapShotsSlider_change1(GSlider source, GEvent event) {
  //println("SnapshotsSlider - GSlider >> GEvent." + event + " @ " + millis());
  Asnapshots = source.getValueI();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

/*
These buttons are both of type GImageToggleButton, which means all events on them
get routed to the single master routine handleToggleButtonEvents() in the UIShared
tab. That routine just looks at which button was targeted and calls the appropriate
handler. So these are button handlers, but they're called indirectly.
*/

void SaveAnimationButtonToggled() {
  //record the frames
  if (SaveGIFAnimation || SavePNGFrames) {
    SaveAnimationButton.setState(1);
    DrawMode = DRAW_MODE_SAVE_ANIM;
    turnOffAllControls();  
  } else {
    reportWarning("SaveAnimationButtonToggled", "You haven't selected anything to save");    
    SaveAnimationButton.setState(0);  // undo the automatic state change
  }
}    

/*
We use RunAnimationButtonState to determine the current state of the Run Animation
button (since we can't ask for that information). We either start the animation or
stop it. We call turnOffAllControls() to disable all the controls while the animation
is happening, but that routine does a special check of DrawMode. If it's the value
we set here (DRAW_MODE_RUN_ANIM) then the sliders that control the animation itself
(in the Animation Controls UI pane) are not disabled, so you can adjust them while
the animation is running. Note that if we're stopping, we have to manually set
NewDrawing to true, so the system knows that the next time we start animating, we 
need to start again from the beginning. 
*/

void RunAnimationButtonToggled() {
  if (RunAnimationButtonState == 0) { 
    // start animating
    RunAnimationButton.setState(1);
    RunAnimationButtonState = 1;
    DrawMode = DRAW_MODE_RUN_ANIM;
    turnOffAllControls();
  } else {
    RunAnimationButton.setState(0);
    RunAnimationButtonState = 0;
    DrawMode = DRAW_MODE_NONE;
    turnOnAllControls();
    NewDrawing = true;
  }
}

public void SaveGIFAnimationCheckbox_clicked1(GCheckbox source, GEvent event) { 
  //println("SaveGIFAnimationCheckbox_clicked1 - GCheckbox >> GEvent." + event + " @ " + millis());
  SaveGIFAnimation = source.isSelected();
} 

public void SavePNGFramesCheckbox_clicked1(GCheckbox source, GEvent event) { 
  //println("SavePNGFramesCheckbox_clicked1 - GCheckbox >> GEvent." + event + " @ " + millis());
  SavePNGFrames = source.isSelected();
} 

/******************* Build controls with default values *******************/

public void createCameraGUI(){
    
  CameraWindowRects = new ArrayList<GroupRect>();
  float paneULx, paneULy;

  /********* Create Window ************/

  CameraWindow = new GWindow(this, "Camera Controls", 80, 400, 470, 540, false, JAVA2D);
  CameraWindow.papplet.noLoop();
  CameraWindow.setOnTop(false);
  
  /********* PNG File name ************/
  
  paneULx = 20;
  paneULy = 20;
  GroupRect PNGNameRect = new GroupRect(CameraWindow, paneULx+0, paneULy+0, 430, 80, color(255, 225, 140));
  CameraWindowRects.add(PNGNameRect);
  
  PNGDIrectoryLabel = new GLabel(CameraWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  PNGDIrectoryLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  PNGDIrectoryLabel.setText("PNG File Directory");
  PNGDIrectoryLabel.setTextBold();
  PNGDIrectoryLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  PNGDIrectoryLabel.setOpaque(true);
  
  PNGDIrectoryField = new GTextField(CameraWindow.papplet, paneULx+10, paneULy+40, 410, 30, G4P.SCROLLBARS_NONE);
  PNGDIrectoryField.setOpaque(true);  
  PNGDIrectoryField.setTextBold();
  PNGDIrectoryField.setText("frame");
  PNGDIrectoryField.setFont(new Font("Dialog", Font.BOLD, 16));
  PNGDIrectoryField.addEventHandler(this, "PNGDIrectoryField_change1");
  PNGDIrectoryField.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
 
  /********* Image Controls ************/
  
  paneULx = 20;
  paneULy = 120;
  GroupRect ImageControlsRect = new GroupRect(CameraWindow, paneULx+0, paneULy+0, 430, 200, color(245, 255, 128));
  CameraWindowRects.add(ImageControlsRect);
  
  ImageControlsLabel = new GLabel(CameraWindow.papplet, paneULx+10, 130, 410, 20);
  ImageControlsLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  ImageControlsLabel.setText("  Image Controls");
  ImageControlsLabel.setTextBold();
  ImageControlsLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  ImageControlsLabel.setOpaque(true);
  
  NumFramesSlider = new GSlider(CameraWindow.papplet, paneULx+10, paneULy+40, 310, 50, 10.0);
  NumFramesSlider.setShowValue(true);
  NumFramesSlider.setShowLimits(true);
  NumFramesSlider.setLimits(20, 20, 600);
  NumFramesSlider.setShowTicks(true);
  NumFramesSlider.setNumberFormat(G4P.INTEGER, 0);
  NumFramesSlider.setOpaque(false);
  NumFramesSlider.addEventHandler(this, "NumFramesSlider_change1");
  
  NumFramesLabel = new GLabel(CameraWindow.papplet, paneULx+330, paneULy+40, 90, 50);
  NumFramesLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  NumFramesLabel.setText("Number of Frames");
  NumFramesLabel.setTextBold();
  NumFramesLabel.setOpaque(false);
  
  FrameSizeSlider = new GSlider(CameraWindow.papplet, paneULx+10, paneULy+90, 310, 50, 10.0);
  FrameSizeSlider.setShowValue(true);
  FrameSizeSlider.setShowLimits(true);
  FrameSizeSlider.setLimits(300, 100, MaxWindowWidth);
  FrameSizeSlider.setShowTicks(true);
  FrameSizeSlider.setNbrTicks(21);
  FrameSizeSlider.setStickToTicks(true);
  FrameSizeSlider.setNumberFormat(G4P.INTEGER, 0);
  FrameSizeSlider.setOpaque(false);
  FrameSizeSlider.addEventHandler(this, "FrameSizeSlider_change1");
  
  FrameSizeLabel = new GLabel(CameraWindow.papplet, paneULx+330, paneULy+90, 90, 50);
  FrameSizeLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  FrameSizeLabel.setText("Frame Size");
  FrameSizeLabel.setTextBold();
  FrameSizeLabel.setOpaque(false);
    
  SnapshotsSlider = new GSlider(CameraWindow.papplet, paneULx+10, paneULy+140, 310, 50, 10.0);
  SnapshotsSlider.setShowValue(true);
  SnapshotsSlider.setShowLimits(true);
  SnapshotsSlider.setLimits(1, 1, 20);
  SnapshotsSlider.setShowTicks(true);
  SnapshotsSlider.setNumberFormat(G4P.INTEGER, 0);
  SnapshotsSlider.setOpaque(false);
  SnapshotsSlider.addEventHandler(this, "SnapShotsSlider_change1");

  SnapshotsLabel = new GLabel(CameraWindow.papplet, paneULx+330, paneULy+140, 90, 50);
  SnapshotsLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SnapshotsLabel.setText("Snapshots per frame");
  SnapshotsLabel.setTextBold();
  SnapshotsLabel.setOpaque(false);
  
  /********* The Buttons ************/
  
  paneULx = 20;
  paneULy = 340;
  GroupRect RunAnimationButtonRect = new GroupRect(CameraWindow, paneULx+0, paneULy+0, 200, 180, color(255, 235, 100));
  CameraWindowRects.add(RunAnimationButtonRect);
  
  RunAnimationButton = new GImageToggleButton(CameraWindow.papplet, paneULx+20, paneULy+55, "RunAnimationButtons.png", 2, 1);
  
  GroupRect SaveAnimationButtonRect = new GroupRect(CameraWindow, paneULx+230, paneULy+0, 200, 180, color(245, 255, 128));
  CameraWindowRects.add(SaveAnimationButtonRect);
  
  SaveGIFAnimationCheckbox = new GCheckbox(CameraWindow.papplet, paneULx+250, paneULy+10, 400, 30);
  SaveGIFAnimationCheckbox.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SaveGIFAnimationCheckbox.setText("Build GIF Animation");  
  SaveGIFAnimationCheckbox.setSelected(SaveGIFAnimation);
  SaveGIFAnimationCheckbox.setTextBold();
  SaveGIFAnimationCheckbox.setOpaque(false);
  SaveGIFAnimationCheckbox.addEventHandler(this, "SaveGIFAnimationCheckbox_clicked1");
  
  SavePNGFramesCheckbox = new GCheckbox(CameraWindow.papplet, paneULx+250, paneULy+40, 400, 30);
  SavePNGFramesCheckbox.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SavePNGFramesCheckbox.setText("Save PNG Frames");  
  SavePNGFramesCheckbox.setSelected(SavePNGFrames);
  SavePNGFramesCheckbox.setTextBold();
  SavePNGFramesCheckbox.setOpaque(false);
  SavePNGFramesCheckbox.addEventHandler(this, "SavePNGFramesCheckbox_clicked1");
  
  SaveAnimationButton = new GImageToggleButton(CameraWindow.papplet, paneULx+250, paneULy+75, "RecordAnimationButtons.png", 2, 1);
    
  /********* The groups ************/
  
  CameraControlsGroup = new GGroup(CameraWindow.papplet);
  CameraControlsGroup.addControls(PNGDIrectoryField, NumFramesSlider, FrameSizeSlider, SnapshotsSlider, 
        SaveGIFAnimationCheckbox, SavePNGFramesCheckbox);
  
  RunAnimationButtonGroup = new GGroup(CameraWindow.papplet);
  RunAnimationButtonGroup.addControls(RunAnimationButton);

  SaveAnimationButtonGroup = new GGroup(CameraWindow.papplet);
  SaveAnimationButtonGroup.addControls(SaveAnimationButton);

  /********* Turn off escape to close windows ************/ 
  CameraWindow.addKeyHandler(this, "myKeyPress");
  
  /********* Final step: add draw handlers for the windows ************/
  CameraWindow.addDrawHandler(this, "CameraWindow_draw1");
}

/******************* Control initialization from globals *******************/

void initCameraUI() {
  PNGDIrectoryField.setText(PNGDirectoryName);
  NumFramesSlider.setValue(AnumFrames);
  FrameSizeSlider.setValue(width);
  SnapshotsSlider.setValue(Asnapshots);
}

