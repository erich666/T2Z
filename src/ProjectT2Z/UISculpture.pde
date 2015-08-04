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
The user interface for the sculpture. This is mostly straightforward calls on 
the G4P library for UI elements. We have a bunch of controls, and I visually
group them into colored rectangles. I also create G4P groups (GGroups) for
all the controls, just the button, and the Block section (that's because when
the Use Block checkbox is unselected, though controls - and only those - get
dimmed and deselected. When the checkbox is on, they respond like the other
controls: normally available, but dimmed and disabled when we're running. The
Block controls require a little special-purpose handling as a result.
*/

GWindow SculptureWindow;                     // the window to hold she controls
ArrayList<GroupRect> SculptureWindowRects;   // the rectangles that visually group controls

GLabel STLNameLabel;
GTextField STLNameField;
  
GLabel CostLabel, CostValueLabel;
GLabel TriangleCountLabel, TriangleCountValueLabel;

GLabel SculptureControlsLabel;
GSlider OffsetSlider, CyclesSlider;
GLabel OffsetLabel, CyclesLabel;

GLabel BlockControlsLabel;
GCheckbox IncludeBlockCheckbox;
GSlider BlockStartSlider, BlockHeightSlider;
GLabel BlockStartLabel, BlockHeightLabel;

GLabel ResamplingLabel;
GSlider SpeedupSlider;
GLabel SpeedupLabel;
  
GLabel SculptureScalingLabel;
GSlider SculptureHeightSlider, SculptureCrossSectionScaleSlider;
GLabel SculptureHeightLabel, SculptureCrossSectionScaleLabel;

GImageToggleButton BuildSculptureButton;
GButton ExitButton;

GGroup BlockControlsGroup;
GGroup BuildSculptureButtonGroup; 
GGroup SculptureControlsGroup;

/******************* Setters *******************/

void invalidateMeasures() {
  invalidateCostEstimate();
  invalidateTriangleCount();
}

void invalidateCostEstimate() {
  CostValueLabel.setText("Build sculpture");
  CostValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);
}

void showCostEstimate() {
  CostValueLabel.setText(Scost);
  CostValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
}

void invalidateTriangleCount() {
  TriangleCountValueLabel.setText("Build sculpture");
  TriangleCountValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);
}

void showTriangleCount() {
  TriangleCountValueLabel.setText(StriangleCount);
  TriangleCountValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
}


/******************* Callbacks *******************/

synchronized public void SculptureWindow_draw1(GWinApplet appc, GWinData data) { 
  appc.background(240);
  for (GroupRect gr: SculptureWindowRects) {
    gr.render();
  }
} 

// See the related comment for PNGDIrectoryField_change1 in UICamera.

public void STLNameField_change1(GTextField source, GEvent event) {
  //println("STLNameField - GTextField >> GEvent." + event + " @ " + millis());
  switch (event) {
    case CHANGED:
      // The typed key is in the char variable SculptureWindow.papplet.key
      // Some special keys (e.g., escape) don't get passed through to here
      break;
    case GETS_FOCUS:
      source.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);
      break;
    case LOST_FOCUS:
      source.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
      STLFilename = source.getText();
      break;
    case ENTERED:
      // This is here in case we want the enter key to do something one day
      break;
    default:
  }
} 

public void OffsetSlider_change1(GSlider source, GEvent event) { 
  //println("OffsetSlider - GSlider >> GEvent." + event + " @ " + millis());
  Soffset = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
}

public void CyclesSlider_change1(GSlider source, GEvent event) { 
  //println("CyclesSlider - GSlider >> GEvent." + event + " @ " + millis());
  Scycles = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

public void IncludeBlockCheckbox_clicked1(GCheckbox source, GEvent event) { 
  //println("IncludeBlockCheckbox - GCheckbox >> GEvent." + event + " @ " + millis());
  SincludeBlock = source.isSelected();
  invalidateMeasures();  
  if (SincludeBlock) turnGroupOn(BlockControlsGroup);
  else turnGroupOff(BlockControlsGroup);
  NeedToRebuildGlobals = true;
} 

public void BlockStartSlider_change1(GSlider source, GEvent event) { 
  //println("BlockStartSlider - GSlider >> GEvent." + event + " @ " + millis());
  SblockStart = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

public void BlockHeight_change1(GSlider source, GEvent event) { 
  //println("BlockHeightSlider - GSlider >> GEvent." + event + " @ " + millis());
  SblockHeight = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

public void SpeedupSlider_change1(GSlider source, GEvent event) { 
  //println("SpeedupSlider - GSlider >> GEvent." + event + " @ " + millis());
  SvoxelSize = source.getValueI();
  invalidateMeasures();
  NeedToRebuildMarcherFields = true;
  NeedToRebuildGlobals = true;
} 

public void SculptureHeightSlider_change1(GSlider source, GEvent event) { 
  //println("SculptureHeightSlider - GSlider >> GEvent." + event + " @ " + millis());
  Sheight = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

public void SculptureCrossSectionScaleSlider_change1(GSlider source, GEvent event) { 
  //println("SculptureCrossSectionScaleSlider - GSlider >> GEvent." + event + " @ " + millis());
  ScrossSectionScale = source.getValueF();
  invalidateMeasures();
  NeedToRebuildGlobals = true;
} 

public void ExitButton_click(GButton source, GEvent event) { 
  //println("button1 - GButton >> GEvent." + event + " @ " + millis());
  if (confirmExitWithDialog()) exit();
} 

// not strictly callbacks, but these are called from the shared GImageToggleButton handler

void BuildSculptureButtonToggled() {
  DrawMode = DRAW_MODE_SCULPTURE;
  SaveSculpture = true;
  BuildSculptureButton.setState(1);   
  turnOffAllControls();  
  initNewSculpture();
}

/******************* Set values programmatically *******************/

void setSTLName(String stlName) {
  STLFilename = stlName;
  STLNameField.setText(STLFilename);
}

/******************* Build controls with default values *******************/

public void createSculptureGUI(){
  SculptureWindowRects = new ArrayList<GroupRect>();
  float paneULx, paneULy;
    
  /********* Create Window ************/

  SculptureWindow = new GWindow(this, "Sculpture Controls", 580, 0, 920, 550, false, JAVA2D);
  SculptureWindow.papplet.noLoop();
  SculptureWindow.setOnTop(false);
  
  /********* STL Name ************/
    
  paneULx = 20;
  paneULy = 20;
  GroupRect STLNameRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 430, 80, color(230, 160, 155));
  SculptureWindowRects.add(STLNameRect);
  
  STLNameLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  STLNameLabel.setOpaque(true);
  STLNameLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  STLNameLabel.setText("STL File name");
  STLNameLabel.setTextBold();
  STLNameLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
   
  STLNameField = new GTextField(SculptureWindow.papplet, paneULx+10, paneULy+40, 410, 30, G4P.SCROLLBARS_NONE);
  STLNameField.setOpaque(true);  
  STLNameField.setTextBold();
  STLNameField.setText("AwesomeModel");  
  STLNameField.setFont(new Font("Dialog", Font.BOLD, 16));
  STLNameField.addEventHandler(this, "STLNameField_change1");
  STLNameField.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  
  /********* Cost ************/
  
  paneULx = 470;
  paneULy = 20;
  GroupRect CostRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 200, 80, color(255, 145, 145));
  SculptureWindowRects.add(CostRect);
  
  CostLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 180, 20);
  CostLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  CostLabel.setText("Cost Estimate");
  CostLabel.setTextBold();
  CostLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  CostLabel.setOpaque(true);
  
  CostValueLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+40, 180, 30);
  CostValueLabel.setOpaque(true);
  CostValueLabel.setTextAlign(GAlign.LEFT, GAlign.CENTER);
  CostValueLabel.setTextBold();
  CostValueLabel.setText("No cost estimate yet");
  CostValueLabel.setFont(new Font("Dialog", Font.BOLD, 16));
  CostValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);
  
  /********* Triangles ************/
  
  paneULx = 690;
  paneULy = 20;
  GroupRect TrianglesRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 210, 80, color(255, 145, 145));
  SculptureWindowRects.add(TrianglesRect);
  
  TriangleCountLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 190, 20);
  TriangleCountLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  TriangleCountLabel.setText("Triangle Count");
  TriangleCountLabel.setTextBold();
  TriangleCountLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  TriangleCountLabel.setOpaque(true);
  
  TriangleCountValueLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+40, 190, 30);
  TriangleCountValueLabel.setOpaque(true);
  TriangleCountValueLabel.setTextAlign(GAlign.LEFT, GAlign.CENTER);
  TriangleCountValueLabel.setTextBold();
  TriangleCountValueLabel.setText("No triangle count yet");
  TriangleCountValueLabel.setFont(new Font("Dialog", Font.BOLD, 16));
  TriangleCountValueLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_GRAY);


  /********* Structure ************/
  
  paneULx = 20;
  paneULy = 140;
  GroupRect StructureRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 430, 150, color(245, 210, 200));//color(255, 110, 110));
  SculptureWindowRects.add(StructureRect);

  SculptureControlsLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  SculptureControlsLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  SculptureControlsLabel.setText("Structure");
  SculptureControlsLabel.setTextBold();
  SculptureControlsLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  SculptureControlsLabel.setOpaque(true);
  
  OffsetSlider = new GSlider(SculptureWindow.papplet, paneULx+10, paneULy+40, 310, 50, 10.0);
  OffsetSlider.setShowValue(true);
  OffsetSlider.setShowLimits(true);
  OffsetSlider.setLimits(0.0, 0.0, 1.0);
  OffsetSlider.setShowTicks(true);
  OffsetSlider.setNumberFormat(G4P.DECIMAL, 2);
  OffsetSlider.setOpaque(false);
  OffsetSlider.addEventHandler(this, "OffsetSlider_change1");
  
  OffsetLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+40, 90, 50);
  OffsetLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  OffsetLabel.setText("Offset");
  OffsetLabel.setTextBold();
  OffsetLabel.setOpaque(false);
  
  CyclesSlider = new GSlider(SculptureWindow.papplet, paneULx+10, paneULy+90, 310, 50, 10.0);
  CyclesSlider.setShowValue(true);
  CyclesSlider.setShowLimits(true);
  CyclesSlider.setLimits(1.0, 0.5, 5.0);
  CyclesSlider.setShowTicks(true);
  CyclesSlider.setNbrTicks(19);
  CyclesSlider.setStickToTicks(true);
  CyclesSlider.setNumberFormat(G4P.DECIMAL, 2);
  CyclesSlider.setOpaque(false);
  CyclesSlider.addEventHandler(this, "CyclesSlider_change1");
  
  CyclesLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+90, 90, 50);
  CyclesLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  CyclesLabel.setText("Number of Cycles");
  CyclesLabel.setTextBold();
  CyclesLabel.setOpaque(false);
    
  /********* The Block ************/
  
  paneULx = 20;
  paneULy = 330;
  GroupRect BlockRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 430, 200, color(255, 155, 175));
  SculptureWindowRects.add(BlockRect);
  
  BlockControlsLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+20, 410, 20);
  BlockControlsLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  BlockControlsLabel.setText("The Block");
  BlockControlsLabel.setTextBold();
  BlockControlsLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  BlockControlsLabel.setOpaque(true);
  
  IncludeBlockCheckbox = new GCheckbox(SculptureWindow.papplet, paneULx+20, paneULy+40, 400, 30);
  IncludeBlockCheckbox.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  IncludeBlockCheckbox.setText(" Include the block");
  IncludeBlockCheckbox.setTextBold();
  IncludeBlockCheckbox.setOpaque(false);
  IncludeBlockCheckbox.addEventHandler(this, "IncludeBlockCheckbox_clicked1");
  
  BlockStartSlider = new GSlider(SculptureWindow.papplet, paneULx+20, paneULy+70, 300, 50, 10.0);
  BlockStartSlider.setShowValue(true);
  BlockStartSlider.setShowLimits(true);
  BlockStartSlider.setLimits(0.5, 0.0, 1.0);
  BlockStartSlider.setShowTicks(true);
  BlockStartSlider.setNumberFormat(G4P.DECIMAL, 2);
  BlockStartSlider.setOpaque(false);
  BlockStartSlider.addEventHandler(this, "BlockStartSlider_change1");
  
  BlockStartLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+70, 90, 50);
  BlockStartLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  BlockStartLabel.setText("Block Start");
  BlockStartLabel.setTextBold();
  BlockStartLabel.setOpaque(false);
  
  BlockHeightSlider = new GSlider(SculptureWindow.papplet, paneULx+20, paneULy+120, 300, 50, 10.0);
  BlockHeightSlider.setShowValue(true);
  BlockHeightSlider.setShowLimits(true);
  BlockHeightSlider.setLimits(0.5, 0.0, 1.0);
  BlockHeightSlider.setShowTicks(true);
  BlockHeightSlider.setNumberFormat(G4P.DECIMAL, 2);
  BlockHeightSlider.setOpaque(false);
  BlockHeightSlider.addEventHandler(this, "BlockHeight_change1");
  
  BlockHeightLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+120, 90, 50);
  BlockHeightLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  BlockHeightLabel.setText("Block Height (cm)");
  BlockHeightLabel.setTextBold();
  BlockHeightLabel.setOpaque(false);
  
  /********* Speedup ************/
    
  paneULx = 470;
  paneULy = 120;
  GroupRect SpeedupRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 430, 100, color(230, 160, 155));
  SculptureWindowRects.add(SpeedupRect);
  
  ResamplingLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  ResamplingLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  ResamplingLabel.setText("Build Speedup - faster means rougher");
  ResamplingLabel.setTextBold();
  ResamplingLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  ResamplingLabel.setOpaque(true);
  
  SpeedupSlider = new GSlider(SculptureWindow.papplet, paneULx+10, paneULy+40, 310, 50, 10.0);
  SpeedupSlider.setShowValue(true);
  SpeedupSlider.setShowLimits(true);
  SpeedupSlider.setLimits(1, 1, 20); 
  SpeedupSlider.setShowTicks(true);
  SpeedupSlider.setNumberFormat(G4P.INTEGER, 0);
  SpeedupSlider.setOpaque(false);
  SpeedupSlider.addEventHandler(this, "SpeedupSlider_change1");
  
  SpeedupLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+40, 90, 50);
  SpeedupLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SpeedupLabel.setText("Speedup");  
  SpeedupLabel.setTextBold();
  SpeedupLabel.setOpaque(false);
  
  /********* Sizing ************/
    
  paneULx = 470;
  paneULy = 240;
  GroupRect SizingRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 430, 150, color(255, 145, 145));
  SculptureWindowRects.add(SizingRect);

  SculptureScalingLabel = new GLabel(SculptureWindow.papplet, paneULx+10, paneULy+10, 410, 20);
  SculptureScalingLabel.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  SculptureScalingLabel.setText("Size");
  SculptureScalingLabel.setTextBold();
  SculptureScalingLabel.setLocalColorScheme(COLOR_SCHEME_BLACK_ON_WHITE);
  SculptureScalingLabel.setOpaque(true);
  
  SculptureHeightSlider = new GSlider(SculptureWindow.papplet, paneULx+10, paneULy+40, 310, 50, 10.0);
  SculptureHeightSlider.setShowValue(true);
  SculptureHeightSlider.setShowLimits(true);
  SculptureHeightSlider.setLimits(20, 0.1, 30);
  SculptureHeightSlider.setShowTicks(true);
  SculptureHeightSlider.setNumberFormat(G4P.DECIMAL, 2);
  SculptureHeightSlider.setOpaque(false);
  SculptureHeightSlider.addEventHandler(this, "SculptureHeightSlider_change1");
  
  SculptureHeightLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+40, 90, 50);
  SculptureHeightLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SculptureHeightLabel.setText("Height (cm)");
  SculptureHeightLabel.setTextBold();
  SculptureHeightLabel.setOpaque(false);
  
  SculptureCrossSectionScaleSlider = new GSlider(SculptureWindow.papplet, paneULx+10, paneULy+90, 310, 50, 10.0);
  SculptureCrossSectionScaleSlider.setShowValue(true);
  SculptureCrossSectionScaleSlider.setShowLimits(true);
  SculptureCrossSectionScaleSlider.setLimits(1.0, 0.1, 5.0);
  SculptureCrossSectionScaleSlider.setShowTicks(true);
  SculptureCrossSectionScaleSlider.setNumberFormat(G4P.DECIMAL, 2);
  SculptureCrossSectionScaleSlider.setOpaque(false);
  SculptureCrossSectionScaleSlider.addEventHandler(this, "SculptureCrossSectionScaleSlider_change1");
  
  SculptureCrossSectionScaleLabel = new GLabel(SculptureWindow.papplet, paneULx+330, paneULy+90, 90, 50);
  SculptureCrossSectionScaleLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  SculptureCrossSectionScaleLabel.setText("Cross Section Scale");
  SculptureCrossSectionScaleLabel.setTextBold();
  SculptureCrossSectionScaleLabel.setOpaque(false);
  
  /********* Build Sculpture Button ************/
    
  paneULx = 470;
  paneULy = 410;
  GroupRect BuildSculptureRect = new GroupRect(SculptureWindow, paneULx+0, paneULy+0, 300, 120, color(245, 210, 200));
  SculptureWindowRects.add(BuildSculptureRect);

  BuildSculptureButton = new GImageToggleButton(SculptureWindow.papplet, paneULx+70, paneULy+20, "BuildSculptureButtons.png", 2, 1);
  
  GroupRect ExitButtonRect = new GroupRect(SculptureWindow, paneULx+320, paneULy+0, 110, 120, color(245, 210, 200));
  SculptureWindowRects.add(ExitButtonRect);

  ExitButton = new GButton(SculptureWindow.papplet, paneULx+350, paneULy+30, 60, 60);
  ExitButton.setText("Exit");
  ExitButton.setTextBold();  
  ExitButton.setLocalColorScheme(GCScheme.RED_SCHEME);
  ExitButton.addEventHandler(this, "ExitButton_click");

  /********* The Groups ************/
        
  BlockControlsGroup = new GGroup(SculptureWindow.papplet);
  BlockControlsGroup.addControls(BlockStartSlider, BlockHeightSlider, BlockStartLabel, BlockHeightLabel);
  
  BuildSculptureButtonGroup = new GGroup(SculptureWindow.papplet);
  BuildSculptureButtonGroup.addControls(BuildSculptureButton);
  
  SculptureControlsGroup = new GGroup(SculptureWindow.papplet);
  SculptureControlsGroup.addControls(STLNameField, CostValueLabel, 
    TriangleCountValueLabel, OffsetSlider, OffsetLabel, CyclesSlider, CyclesLabel, 
    IncludeBlockCheckbox, SpeedupSlider, SpeedupLabel, 
    SculptureHeightSlider, SculptureHeightLabel, SculptureCrossSectionScaleSlider, SculptureCrossSectionScaleLabel,
    ExitButton);
    
  /********* Turn off escape to close windows ************/
  
  SculptureWindow.addKeyHandler(this, "myKeyPress");
  
  /********* Final step: add draw handlers for the windows ************/

  SculptureWindow.addDrawHandler(this, "SculptureWindow_draw1");
}

/******************* Control initialization from globals *******************/

void initSculptureUI() {
  
  setSTLName(STLFilename);
  updateSTLName();
  CostValueLabel.setText(Scost);
  OffsetSlider.setValue(Soffset);
  CyclesSlider.setValue(Scycles);
  
  IncludeBlockCheckbox.setSelected(SincludeBlock);
  BlockStartSlider.setValue(SblockStart);
  BlockHeightSlider.setValue(SblockHeight);  
  if (SincludeBlock) turnGroupOn(BlockControlsGroup);
  else turnGroupOff(BlockControlsGroup);

  SpeedupSlider.setValue(SvoxelSize);
  
  SculptureHeightSlider.setValue(Sheight);
  SculptureCrossSectionScaleSlider.setValue(ScrossSectionScale);
  
  invalidateMeasures();
}

