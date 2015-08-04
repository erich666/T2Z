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
The Animation Controls panel is given a fixed size on creation, big enough to hold seven sliders. 
So that's the maximum number of sliders each animation can present to the user.
*/

GWindow AnimationWindow = null;                          // the pane to control the Animation UI
GDropList AnimationsDropList;                            // the animation name drop-down list object
ArrayList<GroupRect> AnimationWindowRects;               // the list of rectangles we draw on the pane
GLabel AnimationChoiceLabel, AnimationParametersLabel;   // the selected animation name
GGroup AnimationControlsGroup;                           // the group that gets dimmed when we're saving

/* 
The set of sliders associated with a single animation. 
*/

class SliderSet {
  GGroup group;                   // The group holding all sliders and labels
  ArrayList<GSlider> sliderList;  // A list of the sliders
  ArrayList<GLabel> labelList;    // A list of the corresponding labels
  IntList isInteger;              // since we don't have a built-in boolean list, 0=false, 1=true
  IntList needsRebuild;           // another boolean list, as above
  
  SliderSet() {
    if ((AnimationWindow == null) || (AnimationWindow.papplet == null)) {
      reportError("SliderSet constructor", "You're building sliders before the AnimationWindow has been set up");
      return;
    }
    sliderList = new ArrayList<GSlider>();
    group = new GGroup(AnimationWindow.papplet); // create the list to hold the sliders themselves
    labelList = new ArrayList<GLabel>();         // create the list of labels for the sliders
    isInteger = new IntList();                   // create a list telling us if a slider is integer  
    needsRebuild = new IntList();                // create a list telling us if moving the slider triggers a rebuild         
  }
}

// a convenience version of addSlider() where we set needsRebuild to false for you. Use this for "normal"
// sliders (drawn in green) where you can change the value as the animation runs. 

void addSlider(SliderSet _sliderSet, String _label, float _minValue, float _maxValue, float _startValue, boolean _isInteger) {
  addSlider(_sliderSet, _label, _minValue, _maxValue, _startValue, _isInteger, false);
}

// if _needsRebuild is false, the slider is drawn in green and it can be freely moved while the animation runs,
// allowing you to fine-tune your animation. If _needsRebuild is true, the slider is drawn in red. When you move
// such a slider, the animation stops, and the animation's rebuild() routine is called. You can then push the
// Run Animation button to start it up again. Only set _needsRebuild to true if your animation depends on the
// results of a potentially time-consuming computation.

void addSlider(SliderSet _sliderSet, String _label, float _minValue, float _maxValue, float _startValue, boolean _isInteger, boolean _needsRebuild) {
  ArrayList<GSlider> sliderList = _sliderSet.sliderList;
  if (sliderList.size() >= 7) {
    reportError("SliderSet.addSlider", "You're only allowed 7 sliders per animation");
    return;
  }    
  if ((AnimationWindow == null) || (AnimationWindow.papplet == null)) {
    reportError("SliderSet.addSlider", "You're creating a slider but the AnimationWindow isn't ready yet");
    return;
  }

  int thisSliderIndex = sliderList.size();
  float ulx = 30;
  float uly = 170 + (thisSliderIndex * 50);
  GSlider slider = new GSlider(AnimationWindow.papplet, ulx, uly, 310, 50, 10); // build and insert slider into window
  slider.setShowValue(true);                                       // all the little details about this slider
  slider.setShowLimits(true);
  slider.setLimits(_startValue, _minValue, _maxValue);
  slider.setShowTicks(true);
  if (_isInteger) {  
    slider.setNumberFormat(G4P.INTEGER, 0);
  } else {
    slider.setNumberFormat(G4P.DECIMAL, 2);
  }
  slider.setOpaque(false);
  slider.addEventHandler(this, "animationSliderCallback");  
  slider.setLocalColorScheme(G4P.BLUE_SCHEME);
  if (_needsRebuild) slider.setLocalColorScheme(G4P.RED_SCHEME);
    
  GLabel label = new GLabel(AnimationWindow.papplet, ulx+320, uly, 90, 50);  // build and insert label into window
  label.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label.setText(_label);  
  label.setTextBold();
  label.setOpaque(false);

  _sliderSet.sliderList.add(slider);                   // add the slider into the list for this set
  _sliderSet.labelList.add(label);                     // add the label into its list
  _sliderSet.isInteger.append(_isInteger ? 1 : 0);     // is this is an integer-only slider? 
  _sliderSet.needsRebuild.append(_needsRebuild ? 1 : 0);  // do we need to rebuild the animation when the slider moves?
  _sliderSet.group.addControls(slider, label);         // the slider and label join the group
}

// Search through the animations and their sliders, and find which one got changed. Then call
// the procedure for that animation, handing it the label corresponding to that slider and the
// new values, both in integer and floating-point form (let it pick which one to use). We do
// this because the normal callback mechanism is unable to find callback procedures that are
// class methods, but that's really where we want them to go. So we handle all the animation 
// specific sliders in this one callback, and then send them to the right object for handling.

void animationSliderCallback(GSlider slider, GEvent event) {
  for (int i=0; i<AnimatorList.size(); i++) {
    Animator anim = AnimatorList.get(i);
    SliderSet sset = anim.sliders;
    if (sset == null) continue;
    ArrayList<GSlider> sliderList = sset.sliderList;
    if (sliderList == null) continue;
    for (int j=0; j<sliderList.size(); j++) {
      GSlider animSlider = sliderList.get(j);
      if (slider == animSlider) {
        GLabel label = sset.labelList.get(j);
        String sliderName = label.getText();
        pushStyle();
        anim.sliderChanged(sliderName, slider.getValueI(), slider.getValueF());
        popStyle();
        if (sset.needsRebuild.get(j) != 0) {
          anim.needsRebuild = true;
          anim.SliderRequestingRebuild = slider;
          RequestStopAnimating = true;
        }
        return;
      }
    }
  } 
}

// Disable and fade out the currently-selected slider set, and fade in and enable the new set.
// If the old and new sets are the same, then just return without doing anything.
void displaySliderSet(int newNumber) {
  if (ChosenAnimationUINumber == newNumber) return;
  if ((newNumber < 0) || (newNumber >= AnimatorList.size())) {
    String msg = "your requested new set number "+newNumber+" is either negative or greater than the number of available sets = "+AnimatorList.size();
    reportError("displaySliderSet", msg);
    return;
  }
  SliderSet oldSet = AnimatorList.get(ChosenAnimationUINumber).sliders;
  oldSet.group.setEnabled(0, false);
  oldSet.group.fadeTo(0, FadeDuration, 0);
  SliderSet newSet = AnimatorList.get(newNumber).sliders;
  newSet.group.setEnabled(FadeDuration, true);
  newSet.group.fadeTo(0, FadeDuration, 255);
}

// enable the currently-displayed set of animation sliders
void turnAnimationGroupsOn() {
  SliderSet currentSet = AnimatorList.get(ChosenAnimationUINumber).sliders;
  turnGroupOn(currentSet.group);
}

// disable the currently-displayed set of animation sliders
void turnAnimationGroupsOff() {  
  SliderSet currentSet = AnimatorList.get(ChosenAnimationUINumber).sliders;
  turnGroupOff(currentSet.group);
}

/*
Handler for when the drop-down list gets changed. Normally this won't be called unless the new
selection is different from the existing one. Because the G4P library for UI elements routes all
drop-down list events to a single handler, we put that handler in the UIShared tab, and it
calls this routine if the drop-down was the animation chooser.
*/
void handleChangedAnimationDropList() {
  int newNumber = AnimationsDropList.getSelectedIndex();
  displaySliderSet(newNumber);
  ChosenAnimationName = AnimationsDropList.getSelectedText();
  ChosenAnimationUINumber = newNumber;
  invalidateCostEstimate();
  invalidateTriangleCount();
  updateSTLName();
}

// draw the animation window. That "synchronized" keyword is very important!
synchronized public void AnimationWindow_draw1(GWinApplet appc, GWinData data) { 
  appc.background(240);
  for (GroupRect gr: AnimationWindowRects) {
    gr.render();
  }
} 

/*
Create the window that holds the drop-down list and animation sliders. At one point
we were thinking of sizing this to fit the number of animations and the number of 
sliders, but that proved unwieldy and it meant the user had to constantly shuffle
around the windows each time they changed animation. So now we just make it a fixed size.
*/
public void createAnimationWindow() {
  AnimationWindow = new GWindow(this, "Animation Controls", 30, 0, 470, 550, false, JAVA2D);
  AnimationWindow.papplet.noLoop();
  AnimationWindow.setOnTop(false);
  AnimationWindowRects = new ArrayList<GroupRect>(); 
  // we attach the key and callback handlers at the end of initAnimationUI to prevent thread collisions
}

// Set up the drop-down list, instantiate all the sliders and their groups, and finish the essential 
// configuration (key & draw handlers) for AnimationWindow
public void initAnimationUI() {
  AnimatorList = new ArrayList<Animator>();
  buildAnimatorList();

  // The panel holding the title for the drop-down list, and the drop-down itself. The panel is
  // enclosed in a colored rectangle.
  float paneULx = 20;
  float paneULy = 20;
  GroupRect AnimationChoiceRect = new GroupRect(AnimationWindow, paneULx+0, paneULy+0, 430, 90, color(190, 240, 240));
  AnimationWindowRects.add(AnimationChoiceRect);
  
  AnimationChoiceLabel = new GLabel(AnimationWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  AnimationChoiceLabel.setOpaque(true);
  AnimationChoiceLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  AnimationChoiceLabel.setText("Animation Choice");
  AnimationChoiceLabel.setTextBold();
  AnimationChoiceLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  
  // populate the drop-down list with the names of the animations
  String[] dropDownStrings = new String[AnimatorList.size()];
  for (int i=0; i<AnimatorList.size(); i++) {
    Animator anim = AnimatorList.get(i);
    dropDownStrings[i] = anim.name;
  }
  AnimationsDropList = new GDropList(AnimationWindow.papplet, paneULx+10, paneULy+40, 410, 40*dropDownStrings.length, dropDownStrings.length);
  AnimationsDropList.setFont(new Font("Dialog", Font.BOLD, 16));

  // choose animation 0 for the start, and set up our globals to hold its number and name
  AnimationsDropList.setItems(dropDownStrings, 0);
  ChosenAnimationName = dropDownStrings[0];
  ChosenAnimationUINumber = 0;
  for (int i=0; i<AnimatorList.size(); i++) {
    SliderSet currentSet = AnimatorList.get(i).sliders;
    if (i == ChosenAnimationUINumber) {    
      currentSet.group.setEnabled(0, true);
      currentSet.group.fadeTo(0, 1, 255);
    } else {
      currentSet.group.setEnabled(0, false);   // otherwise, disable and make invisible
      currentSet.group.fadeTo(0, 1, 0);
    }
  }
    
  // the panel holding the sliders. It is enclosed in a colored rectangle.
  paneULx = 20;
  paneULy = 130;
  GroupRect AnimationParametersRect = new GroupRect(AnimationWindow, paneULx+0, paneULy+0, 430, 400, color(210,255,225));
  AnimationWindowRects.add(AnimationParametersRect);
  
  AnimationParametersLabel = new GLabel(AnimationWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  AnimationParametersLabel.setOpaque(true);
  AnimationParametersLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  AnimationParametersLabel.setText("Animation Parameters");
  AnimationParametersLabel.setTextBold();
  AnimationParametersLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  
  /********* The Groups ************/      
  AnimationControlsGroup = new GGroup(AnimationWindow.papplet);
  AnimationControlsGroup.addControls(AnimationsDropList);
    
  // These lnes MUST come at the very end
  AnimationWindow.addKeyHandler(this, "myKeyPress");             // Don't necessarily exit if the user presses escape
  AnimationWindow.addDrawHandler(this, "AnimationWindow_draw1"); // After all setup is done, add the draw handler.
}

