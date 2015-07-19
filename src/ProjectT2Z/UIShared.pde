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
These are the UI routines that are shared by the different panels. They're mostly to
get things started, and manage the status of the windows that hold the UI elements. We
can also turn on and off groups of controls. For some objects (like toggle buttons and
drop-down lists), G4P always calls a single handler. So I put those here. They check
the object that triggered the event, and call the proper handler.
*/

import java.awt.Font;
import java.awt.*;

/******************************
****  GUI UTILITIES
******************************/

// This is the master starting point for the G4P library and should precede
// all other calls to G4P.

public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  //G4P.setGlobalColorScheme(15);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Sketch Window");
  createAnimationWindow();
  createCameraGUI();
  createSculptureGUI();
  // now that all windows are made, they can start receiving events
  setAllGUILoopStatus(true);  
}

void setAllGUILoopStatus(boolean loopOn) {
  if (loopOn) {
    CameraWindow.papplet.loop();
    SculptureWindow.papplet.loop();
    AnimationWindow.papplet.loop();  
  } else {
    CameraWindow.papplet.noLoop();
    SculptureWindow.papplet.noLoop();
    AnimationWindow.papplet.noLoop();  
  }
}

public void initUI() {  
  // this order is important. Don't shuffle the order of initializations!
  setAllGUILoopStatus(true);  // turn off handling while we adjust controls
  initCameraUI();
  initAnimationUI();
  initSculptureUI();
  setAllGUILoopStatus(true);  // turn handling back on
}

/*
Pressing the escape key while the mouse is in any UI panel will normally cause the 
program to immediately exit. But happily, Processing calls our key handler before
it takes that action. So here I simply set the key variable to 0. That's not the
same as escape, so Processing doesn't quit. Compare this to keyPressed() in the main
file, where we bring up a dialog window to confirm escape. I felt like if the mouse
is in the UI windows, we should just ignore escape altogether, rather then asking
if you really meant to quit.
see http://forum.processing.org/two/discussion/575/stop-escape-key-from-closing-app-in-new-window-g4p
*/
public void myKeyPress(GWinApplet appc, GWinData data, KeyEvent kevent) {
  if (appc.key == ESC) {
    appc.key = 0;
  }
} 

/******************* Turning groups on and off *******************/

void turnGroupOn(GGroup group) {
  group.setEnabled(FadeDuration, true);
  group.fadeTo(0, FadeDuration, 255);
}

void turnGroupOff(GGroup group) {
  group.setEnabled(0, false);
  group.fadeTo(0, FadeDuration, FadeOutAlpha);
}

/******************* The rectangles for visually grouping controls *******************/

// These rectangles have no functional purpose. They're just to visually group things.
class GroupRect {
  GWindow window;
  float ulx, uly, wid, hgt;
  color clr;
  
  GroupRect(GWindow _window, float _ulx, float _uly, float _wid, float _hgt, color _clr) {
    window = _window;
    ulx = _ulx; uly = _uly;
    wid = _wid; hgt = _hgt;
    clr = _clr;
  }
  
  void render() {
    window.papplet.fill(clr);
    window.papplet.rect(ulx, uly, wid, hgt);
  }
}

/******************* Handle toggle buttons *******************/
/* 
Unfortunately, all toggle buttons get handled by one master handler.
So here it is. It just checks which button was involved and calls
its handler.
*/

public void handleToggleButtonEvents(GImageToggleButton button, GEvent event) { 
  //println(button + "   State: " + button.getState());
  if (button == SaveAnimationButton) {
    SaveAnimationButtonToggled(); 
  } else if (button == RunAnimationButton) {
    RunAnimationButtonToggled();
  } else if (button == BuildSculptureButton) { 
    BuildSculptureButtonToggled();
  } 
}

/******************* Handle drop lists *******************/
/* 
Unfortunately, all drop lists get handled by one master handler.
So here it is. It just checks which button was involved and calls
its handler.
*/

public void handleDropListEvents(GDropList list, GEvent event) { 
  if (list == AnimationsDropList) {
    handleChangedAnimationDropList();
  }
}

