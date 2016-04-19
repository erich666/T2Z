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
How to create an animation:
 
 ###### Quick Summary for Experienced Programmers
 
 If you have experience programming, you can probably write something by adapting the
 examples.  There are a few essential things to know, though: some standard Processing
 variables won't work the way you're used to. These things are detailed below, but 
 here are the key changes:
 
 Instead of      Use
 -----------     ---------------
 frameCount      time (a float from 0 to almost 1)
 width           Awidth
 height          Aheight
 draw()          render(time)
 setup()         usually the constructor, but often restart(). use rebuild() when necessary.
 
 ###### Details
 
 Each animation is an object, in the sense of object-oriented programming. To create an
 animation, you create an animation object and then add it to the master list of animations. 
 Each animation has a name, an optional list of sliders that control some of its variables, 
 and some procedures. 
 
 A word on terminology. When you create your animation object, you can create any number
 of variables you like. These variables will be "global" throughout your object: all the
 procedures you write can read and write them (technically, these are called "instance
 variables"). But they're not really globals, because these variables only exist within
 the object. They're like local variables that you declare in a procedure: they only have
 meaning within that procedure. So if you have a bunch of animation objects, each could
 have a float variable named Radius, and there would be no confusion, because the Radius
 instance variable for each object is completely independent of any Radius instance
 variable defined in any other.
 
 All of the animations we create here are loops. So just as frame 1 leads smoothly into
 frame 2, so too does the last frame lead smoothly into the first. It would be difficult to
 use Processing's frameCount variable to help you draw your animation, because you (or your
 user) can change the length of the animation easily using a slider on the front panel.
 So instead we use the variable time, which is computed for you and passed as an argument
 into render(). Time starts at 0 and runs just short of 1, such that if it advanced just
 one more frame it would have the value 1, which in our scheme is the same as the value 0.
 This way when your animation is repeated over and over, the end smoothly links up to the
 beginning and you have a loop.  Thinking about animation in terms of time often leads to 
 code that is shorter and cleaner code than code using frameCount, but it might take some 
 practice to get used to it. If this is a new idea for you, give it a chance.
 
 Each of your instance variables can optionally be controlled by a slider on the user
 interface. Moving that slider will call a routine that you provide to assign the slider's
 new value to the corresponding instance variable, so that variable will always have the 
 value on the slider. This communication runs only in ONE direction, from the slider to the
 instance variable. It doesn't go the other way. If you change the value of the instance 
 variable in your code, the slider will not update to that new value. Such a mismatch can 
 make debugging a nightmare. So I strongly recommend that you never assign a new value to 
 any instance variable that has a corresponding slider.
 
 Here's a complete, simple animation. It draws a square that makes one full orbit around
 the center over the course of the animation loop. It offers two sliders on the user
 interface to control the red component of the square's color and the radius of the 
 circle it travels on.
 
 I've put line numbers at the start of each line to ease the discussion. Obviously your 
 code won't have line numbers, and the various parts of your program will be on different 
 lines than this example.
 
 1 class OneRotatingSquare extends Animator {
 2
 3    int Redness = 128;
 4    float CircleRadius = .34;
 5    float SquareSize = .2;
 6
 7    String RednessLabel = "Redness";
 8    String CircleRadiusLabel = "Circle Radius";
 9
 10    OneRotatingSquare() {
 11       super("One Rotating Square");               // this line MUST be the first one in the procedure
 12
 13       addSlider(sliders, RednessLabel, 0, 255, Redness, true);
 14       addSlider(sliders, CircleRadiusLabel, .0, .5, CircleRadius, false);
 15    }
 16
 17    void sliderChanged(String sliderName, int iValue, float fValue) {
 18       if (sliderName == RednessLabel) Redness = iValue;
 19       if (sliderName == CircleRadiusLabel) CircleRadius = fValue;
 20    }
 21 
 22    void rebuild() {
 23    }
 24
 25    void restart() {
 26       BackgroundColor = color(255, 205, 180); // Important! Set background color 
 27       ModelColor = color(255, 0, 0);     // model is pure red
 28       BlockColor = color(255, 255, 0);  // the block is yellow
 29    }
 30
 31    void render(float time) {
 32       background(BackgroundColor);
 33       if ((time > .4) && (time < .6)) SliceColor = color(0, 0, 255);  // middle chunk is blue
 34       noStroke();
 35       fill(Redness, 128, 128);
 36       float sideLen = SquareSize * Awidth;
 37       float circleR = CircleRadius * Awidth;
 38       pushMatrix();
 39          translate(Awidth/2., Aheight/2.);
 40          rotate(TWO_PI * time);
 41          translate(circleR, 0);
 42       rect(-sideLen/2., -sideLen/2., sideLen, sideLen);
 43       popMatrix();
 44    }
 45 }
 
 ###### LINE 1
 1 class OneRotatingSquare extends Animator {
 
 The start of my animation object. Replace "OneRotatingSquare" with the name of 
 your animation. Start with a capital letter and use only letters, numbers, and
 the underscore character. Do not use other punctuation or spaces.
 
 ###### LINES 3-5
 3     int Redness = 128;
 4     float CircleRadius = .34;
 5     float SquareSize = .2;
 
 Define the variables that will control your program. You can have as many as you
 like. These also typically start with capital letters, but they don't have to.
 Give each of your globals a sensible starting value. 
 
 ###### LINES 7-8
 7     String RednessLabel = "Redness";
 8     String CircleRadiusLabel = "Circle Radius";
 
 I'm only going to have two sliders in this program, one each for the redness
 of the square and the radius of the circle. These Strings provide the label
 that will appear next to these sliders, so the user knows what they're there
 for. Note that I haven't made a slider for SquareSize, which is fine; not every
 instance variable needs to have a slider associated with it (but every slider
 does need an instance variable to control). We will use these labels in lines 
 13-14 and again later in 18-19.
 
 ###### LINE 10
 10   OneRotatingSquare() {
 
 This is the start of the routine that creates my animation object; it is called
 the "constructor". Your constructor must have exactly the same name as you used 
 for your animation in line 1. It will be called once, when the system first 
 starts up.  Your constructor has no explicit return type, and no return statement. 
 In our setup, it also takes no arguments. 
 
 This is the place to create your sliders, and also build any data your animation
 loop might need. For example, your animation loop might start with an empty 
 cup, then water is poured into it, the cup tilts and the water pours out, and
 the cup turns upright again, ready to start the loop over. You might figure out
 the flow of the water with a complex simulation. You'd typically do that simulation
 at this point, and save the results in some instance variables. Then your drawing
 routine (line 27) can just read the data and quickly draw the appropriate picture
 for any given moment.
 
 IMPORTANT NOTE FOR ADVANCED USERS: If you use Processing's built-in 
 routine colorMode() to change the color model or the ranges of color values
 inside of your constructor, you MUST restore the default color model before 
 leaving your constructor. There are two ways to do this. One way is to explicitly 
 call colorMode(RGB, 255, 255, 255, 255) to reset everything back to the original, 
 default settings. An easier and more general way is to call pushStyle() at the 
 start of your routine, and popStyle() at the end. 
 
 If you forget to restore these defaults using one of these methods, your 
 color model will stay in effect for all the remaining animator constructors, 
 which will affect any colors they define or work with. This will probably
 cause the resulting animations to look wrong, and will likely prove to be
 a hair-pulling process to debug. So don't forget to restore the color model! 
 It is usually good programming style in Processing to always reset the
 default color mode as soon as possible after you change it, but in this
 case it's required. 
 
 All of the routines listed below will have the default color model (RGB,
 with values 0-255 for each component) in place when they're called; if 
 you call colorMode() inside of those routines, remember to use one of the 
 above methods to restore the color mode to the default before you exit.
 
 ###### LINE 11
 11     super("One Rotating Square");               // this line MUST be the first one in the procedure
 
 This call to "super" MUST be the VERY FIRST LINE of your constructor (except
 for comments). The argument is a String providing the name of your animation, 
 as you want it to appear in the drop-down list in the user interface. I almost
 always use the same name as that given in Line 1, except because this is a 
 String I can include spaces.
 
 ###### LINES 13-14
 13       addSlider(sliders, RednessLabel, 0, 255, Redness, true);
 14       addSlider(sliders, CircleRadiusLabel, .0, .5, CircleRadius, false);
 
 Here we actually create the sliders. Each slider is created by a call to the
 routine "addSlider". The first argument is the word "slider" - this refers to
 a variable we set up and maintain for you. The second argument is the string
 that should appear next to your slider. I strongly suggest that you use one of 
 the strings you created earlier (as I did in lines 7-8). The come three floats: 
 the minimum value for the slider, the maximum value, and the starting value. 
 Notice that I've used one of my instance variables for this starting value, 
 since they were created with starting values on lines 3-5. Then comes a boolean: 
 if this slider should be limited to integer values (e.g., 3, 4, 5) then set this 
 to true. If you'd like floating-point values (e.g., 3.5, 17.25) then set this 
 to false. Here my Redness variable is an int, so I've set the boolean to true,
 and CircleRadius is a float, so I set the boolean to false.
 
 There is an optional final boolean, which defaults to false. It's not used
 by either of these sliders. This boolean states whether moving this slider
 should make the animation stop, and force a call to rebuild() for this animation
 before it runs again. We provide this because some animations depend on
 complex data structures that can take a while to calculate. By setting this
 final boolean to true, you're telling the system that that slider influences
 those data structures, and when the slider is moved, the rebuild should
 happen. Rather than freeze up the whole system while this rebuilding happens,
 moving one of these specially-marked sliders stops the animation and sets a
 flag that the animation's rebuild() routine should be called the next time
 the animation starts for any reason. These sliders are drawn in red to let
 the user know that they have this property.
 
 ###### LINE 17
 17     void sliderChanged(String sliderName, int iValue, float fValue) {
 
 This is the start of the routine that gets called each time you (or your user)
 moves a slider. It must appear exactly as on this line with no changes.
 
 ###### LINES 18-19
 18       if (sliderName == RednessLabel) Redness = iValue;
 19       if (sliderName == CircleRadiusLabel) CircleRadius = fValue;
 
 Now we actually assign the slider value to our instance variable. The slider's
 value is provided in both integer and float form; it's up to you to assign the
 proper one to each variable. To determine which slider was changed, you're
 given the label describing that slider in the user interface. So I test this
 name, in sliderName, against each of my labels. When they match, I set the
 corresponding variable to the new slider value. Note that this is only called
 when you (or your user) stops moving a slider and lets go of the mouse, so 
 it's not called over and over as the user moves the slider around.
 
 ###### LINE 22
 22    void rebuild() {
 
 This routine is called for "red" sliders. See the discussion of sliders in
 lines 13-14 above. Normally this routine is empty - you can even omit it
 entirely if you like. If your animation depends on big data structures that
 can take a while to compute, put them here, and they'll be updated each 
 time a red slider moves. This routine is not called when blue sliders are 
 moved. 
 
 ###### LINE 25
 25    void restart() {
 
 This routine is called once just before each animation. That is, it's called
 just before the first call to render() when time=0 (see below). This is where
 you set the background color for your animation. If you have variables that 
 change over the course of your animation, this is a good place to give them 
 starting values. 
 
 ###### LINES 26-28
 26     BackgroundColor = color(255, 205, 180); // Important! Set background color
 27     ModelColor = color(255, 0, 0);     // model is pure red
 28     BlockColor = color(255, 255, 0);  // the block is yellow
 
 When we make the model, we don't use the colors that you draw with. Instead,
 you explicitly tell us what color each slice ought to be. 

 We begin by defining BackgroundColor. This is ** REQUIRED! **. Each time you
 draw a picture, we convert it into one "slice" of the 3D model. The first
 step in that process is to remove all the pixels that are exactly the color
 of BackgroundColor. Those turn into thin air.

 The pixels that remain will have the color given by ModelColor. If you want
 different slices to have different colors (for example, to have a blue
 section in the middle of a red model, or to make a rainbow model running
 up the length of the whole thing), you can overwrite this color on a per-slice
 basis (see SliceColor, discussed on line 33).
 
 If you choose to include a block, then it will have the color given by
 BlockColor.
 
 Keep in mind that these colors DO NOT AFFECT YOUR DRAWINGS. The idea is
 that you can draw with any colors you like, so you can make a really cool
 animation. When the picture is completed and saved, and we turn it into a
 slice of a model, then these colors define how we convert your colorful
 image into a slice of the 3D model, where all the material on that
 slice has single, constant color.
 
 So if you set the BackgroundColor to black, and the ModelColor to red,
 and you draw a frame with 3 circles that are white, yellow, and green, the 
 output image (saved as a gif animation or PNG files) will be a black 
 background with white, yellow, and green circles, and that's what you'll 
 see when  you run the animation. But the 3D model corresponding will be 
 all air, except for red material where the three circles were located.
 
 Setting BackgroundColor is REQUIRED. The other two will default to white if 
 you don't set them yourself. 
 
 Always assign these values in restart(), as shown here. Do not put them
 in your constructor or the 3D model won't be built properly.
  
 ###### LINE 31
 31     void render(float time) {
 
 This is the start of the routine that draws your picture. It must appear just
 like this, with no changes. The procedure is provided with a floating-point
 variable called "time". This is how you determine what to draw. You might be
 used to using frameCount for this purpose, but don't! Even though it's an old
 friend, frameCount doesn't work in this system the way you're used to. Instead,
 use time. 
 
 The first time "render" is called, time has the value 0. Then when it's
 called again, time has a slightly larger value. Then it will be slightly larger
 again, and so on. For the last frame of your animation, time will be almost
 (but not quite) 1. In fact, it will be one frame shy of 1 - that is, if render()
 was called once more, time would be 1. But we stop one frame short of that. This
 way, you animation will loop smoothly without a repeated frame at the end.
 
 For example, suppose you were making a five-frame animation. Then render() would
 be called five times, with values of time at 0, .2, .4, .6, and .8. When 
 your frame is drawn, you don't have to do anything - the system will take whatever
 is on-screen and use it as the contents of that frame. Similarly, you don't have
 to do anything special on your last frame. Just use the value of time to draw
 the picture corresponding to that moment, and that's it. If you're used to
 frameCount, you'll find that using time can be just as easy or even easier
 once you're used to it. Just remember it always starts at 0 and continues until
 it's just one frame short of 1.
 
 The reason we do it this way is because you (or your user) can change the length
 of your animation using one of the UI sliders. If you used frameCount you'd have
 to always figure out how far you were into the animation in order to draw the
 proper frame. Using time means you don't have to do that work.
 
 ###### LINE 32
 32       background(BackgroundColor);
 
 Clear the screen to your chosen background color. This is an important step!
 
 ###### LINE 33
 33       if ((time > .4) && (time < .6)) SliceColor = color(0, 0, 255);  // middle chunk is blue
 
 Here we decide to make the central 20 percent of the model pure blue by 
 assigning blue to SliceColor. If you don't assign anything to SliceColor
 for a given frame, it will have the default value of ModelColor. Remember
 that for each frame, SliceColor will default to ModelColor. You must change
 it for every frame you want to assign a different color to.
 
 ###### LINES 34-43
 This is where you can put any drawing stuff you want. This routine is essentially
 your draw() in a typical Processing sketch. The big differences to keep in mind
 are DO NOT USE frameCount, width, or height. They won't reflect the value of 
 your user-interface slider that controls the size of your animation. USE time,
 Awidth AND Aheight instead. If your image is smaller than the graphics window, 
 it will appear in the upper-left of the window, but your saved frames, animations, 
 and sculptures will have your desired resolution of Awidth by Aheight. Here are
 the key things to remember:
 
 INSTEAD OF     USE
 frameCount     time    (a float)
 width          Awidth  (an int)
 height         Aheight (an int)
 
 ********************************************************
 * REGISTERING YOUR ANIMATION
 ********************************************************
 
 In order for the system to "know" about your animation, you have to tell it! Do that
 by adding a line to the routine buildAnimatorList(), appearing immediately after
 this comment. To add our animation with the name OneRotatingSquare (this is the name
 you provide in line 1 of the listing above), just add this line to buildAnimatorList():
 
 AnimatorList.add(new OneRotatingSquare());
 
 Your animations will appear in the drop-down list in the same order in which
 the appear in buildAnimatorList(). If you forget to add your animation it won't
 show up in the drop-down and you won't be able to select it, so don't forget this step!
 */

// %%%%%%%%%%%%%% start of code %%%%%%%%%%%%%%

// Stuff we import from Java to support some animations
import java.util.Arrays;


void buildAnimatorList() {
  /* 
  ** IMPORTANT! **
  The drop-down list has only 11 usable slots; anything
  after that will not be selectable. So choose the 11 
  animations that you want, and comment out the others!
  */

  // basic examples
    
  //AnimatorList.add(new OneRotatingSquare());
  //AnimatorList.add(new RotatingSquares());
  //AnimatorList.add(new LissajousBall());
  //AnimatorList.add(new SpinningDial());
  //AnimatorList.add(new BallBurst());
  //AnimatorList.add(new TrailSpin());

  /* Complex, wacky, and otherwise non-basic animations.
  Note that many of these are hacks and experiments,
  and so have little documentation. Don't be afraid
  to get into the code and start mucking about!
  These are listed in the order in which they appear in
  the file. We recommend maintaining that convention, so
  if you add some new animations, put them into this list
  in the same place you put them in the file below. Probably
  the best place is at the end of the "normal" animators,
  and just before the three special ones at the end.
  */
  
  //AnimatorList.add(new DoubleChainSpin());
  AnimatorList.add(new Wobbly());
  AnimatorList.add(new HackMe());
  AnimatorList.add(new DancingCobras());
  
  AnimatorList.add(new Merge());
  AnimatorList.add(new Shift());
  //AnimatorList.add(new Vase());
  AnimatorList.add(new Dissection01());
  //AnimatorList.add(new Dissection02());
  AnimatorList.add(new Dissection03());
  //AnimatorList.add(new Dissection04());
  //AnimatorList.add(new WindSpinner());
  
  AnimatorList.add(new Ag0007());
  AnimatorList.add(new Ag0011());
  //AnimatorList.add(new Ag0012());
  //AnimatorList.add(new Ag0020());
  AnimatorList.add(new Ag0025());
  //AnimatorList.add(new Ag0033());
  //AnimatorList.add(new Ag0035());
  //AnimatorList.add(new Ag0055());
  //AnimatorList.add(new Ag0065());
  AnimatorList.add(new Sphereflake());
  AnimatorList.add(new Jephthai());

  
  /*
  The last three Animators are weird special cases that break some of the
  rules. So don't use them as the basis for your own code! They're here
  because we decided they were useful enough to include, even though they 
  cheat here and there.
  The first two read either an animated GIF or a set of PNG frames in a
  directory. The third one treats a single gif as a height field and builds
  a 3D model from it. Note that the GIF reader we're using does not 
  properly interpret all compression types for animated GIFs, so you can
  get some bad frames. If that happens, try pulling the frames apart into
  separate files using some other program, and then use the FolderOfGFrames
  animator on those images.
  */
  // AnimatorList.add(new AnimatedGifReader());
  // AnimatorList.add(new FolderOfFramesReader());
  // AnimatorList.add(new HeightField());
}

// ================= One Rotating Square

class OneRotatingSquare extends Animator {

  int Redness = 128;
  float CircleRadius = .34;
  float SquareSize = .2;

  String RednessLabel = "Redness";
  String CircleRadiusLabel = "Circle Radius";

   OneRotatingSquare() {
      super("One Rotating Square");               // this line MUST be the first one in the procedure

      addSlider(sliders, RednessLabel, 0, 255, Redness, true);
      addSlider(sliders, CircleRadiusLabel, .0, .5, CircleRadius, false);
   }

   void sliderChanged(String sliderName, int iValue, float fValue) {
      if (sliderName == RednessLabel) Redness = iValue;
      if (sliderName == CircleRadiusLabel) CircleRadius = fValue;
   }

   void restart() {
      BackgroundColor = color(255, 205, 180); // Important! Set background color
      ModelColor = color(255, 0, 0);     // model is pure red
      BlockColor = color(255, 255, 0);  // the block is yellow
   }

   void render(float time) {
      background(BackgroundColor);
      if ((time > .4) && (time < .6)) SliceColor = color(0, 0, 255);  // middle chunk is blue
      noStroke();
      fill(Redness, 128, 128);
      float sideLen = SquareSize * Awidth;
      float circleR = CircleRadius * Awidth;
      pushMatrix();
         translate(Awidth/2., Aheight/2.);
         rotate(TWO_PI * time);
         translate(circleR, 0);
      rect(-sideLen/2., -sideLen/2., sideLen, sideLen);
      popMatrix();
   }
}

// ================= Rotating Squares

class RotatingSquares extends Animator {

  int NumSquares = 5;
  float SquareRadius = .20;
  float CircleRadius = .34;

  String NumSquaresLabel = "Number of Squares";
  String SquareRadiusLabel = "Square Radius";
  String CircleRadiusLabel = "Circle Radius";

  RotatingSquares() {
    super("Rotating Squares");
    addSlider(sliders, NumSquaresLabel, 3, 20, NumSquares, true);
    addSlider(sliders, SquareRadiusLabel, .05, .5, SquareRadius, false);
    addSlider(sliders, CircleRadiusLabel, 0, .5, CircleRadius, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == NumSquaresLabel) NumSquares = iValue;
    if (sliderName == SquareRadiusLabel) SquareRadius = fValue;
    if (sliderName == CircleRadiusLabel) CircleRadius = fValue;
  }

  void restart() {
    BackgroundColor = color(255, 205, 180);
    ModelColor = color(0, 255, 255);
  }

  void render(float time) {
    background(BackgroundColor);
    stroke(0);
    fill(ModelColor);
    int numSquares = NumSquares;
    float sqSize = SquareRadius * Awidth;
    float circleR = CircleRadius * Awidth;
    for (int i=0; i<numSquares; i++) {
      float a = norm(i, 0, numSquares);
      pushMatrix();
      translate(Awidth/2., Aheight/2.);
      rotate(TWO_PI * a);
      translate(circleR, 0);
      if (i==0) rotate(-TWO_PI * time);
      else rotate(TWO_PI * time);
      rect(-sqSize/2., -sqSize/2., sqSize, sqSize);
      popMatrix();
    }
  }
}

// ================= Lissajous Ball

class LissajousBall extends Animator {

  int LissA = 3;
  int LissB = 4;
  float Radius = .19;
  float Redness = .5;

  String LissALabel = "a value";
  String LissBLabel = "b value";
  String RadiusLabel = "Radius";
  String RednessLabel = "Redness";

  LissajousBall() {
    super("Lissajous Ball");
    addSlider(sliders, LissALabel, 1, 8, LissA, true);
    addSlider(sliders, LissBLabel, 1, 8, LissB, true);
    addSlider(sliders, RadiusLabel, .1, .4, Radius, false);
    addSlider(sliders, RednessLabel, 0, 1, Redness, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == LissALabel) LissA = iValue;
    if (sliderName == LissBLabel) LissB = iValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == RednessLabel) Redness = fValue;
  }

  void restart() { 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(255*Redness, 128, 128);
  }

  void render(float time) {
    background(BackgroundColor);
    stroke(0);
    fill(ModelColor);
    pushMatrix();
    translate(Awidth/2., Aheight/2.);
    float theta = TWO_PI * time;
    float x = Awidth * .3 * sin(LissA * theta);
    float y = Aheight * .3 * sin(LissB * theta);
    float r = Awidth * Radius;
    ellipse(x, y, 2*r, 2*r);
    popMatrix();
  }
}

// ================= Spinning Dial

class SpinningDial extends Animator {
  float TriangleHeight = .49;
  float BaseRadius = .20;

  String TriangleHeightLabel = "Triangle Height";
  String BaseRadiusLabel = "Base Radius";

  SpinningDial() {
    super("Spinning Dial");
    addSlider(sliders, TriangleHeightLabel, .1, .5, TriangleHeight, false);
    addSlider(sliders, BaseRadiusLabel, .1, .5, BaseRadius, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == TriangleHeightLabel) TriangleHeight = fValue;
    if (sliderName == BaseRadiusLabel) BaseRadius = fValue;
  }

  void restart() { 
    BackgroundColor = color(50, 255, 50);
    ModelColor = color(255, 255, 0);
  }

  void render(float time) {
    background(BackgroundColor);
    fill(ModelColor);
    noStroke();
    pushMatrix();
    translate(Awidth/2., Aheight/2.);
    rotate(TWO_PI * time);
    float r = Awidth * .5 * BaseRadius;
    float h = Awidth * TriangleHeight;
    ellipse(0, 0, 2*r, 2*r);
    // offset in X
    float x = r*r / h;
    float tr = sqrt(r*r - x*x);
    triangle(-x, tr, -x, -tr, -h, 0);
    popMatrix();
  }
}

// ================= Ball Burst

class BallBurst extends Animator {
  float BallRadius = .05;
  float BurstRadius = .43;
  float BurstOffset = .1;
  int NumBalls = 8;

  String BallRadiusLabel = "Ball Radius";
  String BurstRadiusLabel = "Burst Radius";
  String BurstOffsetLabel = "Burst Offset";
  String NumBallsLabel = "Number of Balls";

  BallBurst() {
    super("Ball Burst");
    addSlider(sliders, BallRadiusLabel, .01, .5, BallRadius, false);
    addSlider(sliders, BurstRadiusLabel, .1, .5, BurstRadius, false);
    addSlider(sliders, BurstOffsetLabel, .0, .4, BurstOffset, false);
    addSlider(sliders, NumBallsLabel, 3, 30, NumBalls, true);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == BallRadiusLabel) BallRadius = fValue;
    if (sliderName == BurstRadiusLabel) BurstRadius = fValue;
    if (sliderName == BurstOffsetLabel) BurstOffset = fValue;
    if (sliderName == NumBallsLabel) NumBalls = iValue;
  }

  void restart() { 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(255, 255, 0);
  }

  void render(float time) {
    background(BackgroundColor);
    fill(ModelColor);
    noStroke();
    pushMatrix();
    translate(Awidth/2., Aheight/2.);
    float dist = (Awidth/2.) * BurstRadius * 2 * map(cos(TWO_PI * time), -1, 1, 0, 1);
    for (int ballNum=0; ballNum<NumBalls; ballNum++) { 
      float a = norm(ballNum, 0, NumBalls);
      pushMatrix();
      rotate(TWO_PI * a);
      ellipse(dist, BurstOffset * Awidth, 2*Awidth*BallRadius, Awidth*BallRadius);
      popMatrix();
    }
    popMatrix();
  }
}

// ================= Trail Spin

class TrailSpin extends Animator {

  int NumSpokes = 3;
  float TrailLen = .2;
  int SpeedChangeFactor = 1;
  float OffsetPerRing = .2;
  int NumBalls = 3;
  float BallRadius = .05;
  float InnerDistance = .2;

  String NumSpokesLabel = "Number of Spokes";
  String TrailLenLabel = "Trail Length";  
  String SpeedChangeFactorLabel = "Speed Change Factor";
  String OffsetPerRingLabel = "Offset Per Ring";
  String NumBallsLabel = "Number of balls";
  String BallRadiusLabel = "Ball Radius";
  String InnerDistanceLabel = "Inner Distaince";


   TrailSpin() {
      super("Trail Spin");               // this line MUST be the first one in the procedure

      addSlider(sliders, NumSpokesLabel, 2, 10, NumSpokes, true);
      addSlider(sliders, TrailLenLabel, 0, .5, TrailLen, false);
      addSlider(sliders, SpeedChangeFactorLabel, -3, 3, SpeedChangeFactor, true);
      addSlider(sliders, OffsetPerRingLabel, 0, 1, OffsetPerRing, false);
      addSlider(sliders, NumBallsLabel, 0, 10, NumBalls, true);
      addSlider(sliders, BallRadiusLabel, 0, .5, BallRadius, false);
      addSlider(sliders, InnerDistanceLabel, 0, .4, InnerDistance, false);
   }

   void sliderChanged(String sliderName, int iValue, float fValue) {
      if (sliderName == NumSpokesLabel) NumSpokes = iValue;
      if (sliderName == TrailLenLabel) TrailLen = fValue;
      if (sliderName == SpeedChangeFactorLabel) SpeedChangeFactor = iValue;
      if (sliderName == OffsetPerRingLabel) OffsetPerRing = fValue;
      if (sliderName == NumBallsLabel) NumBalls = iValue;
      if (sliderName == BallRadiusLabel) BallRadius = fValue;
      if (sliderName == InnerDistanceLabel) InnerDistance = fValue;
   }

   void restart() {
      BackgroundColor = color(80, 10, 75); // background is dark purple
      ModelColor = color(240, 45, 35);   // model is red
      BlockColor = color(220, 205, 145); // block is yellow-ish
   }

   void render(float time) {
      if ((time > .1) && (time < .9)) {
        SliceColor = color(64, 155, 176);
        if ((time > .1) && (time < .4)) {
          SliceColor = lerpColor(ModelColor, SliceColor, norm(time, .1, .4));
        } else if (time > .6 && time < .9) {
         SliceColor = lerpColor(SliceColor, ModelColor, norm(time, .6, .9));
        }
      }
      background(BackgroundColor);
      noStroke();
      fill(255);
      float ballr = BallRadius * Awidth;
      float minDist = InnerDistance * Awidth/2.;
      float maxDist = (Awidth/2.) - (ballr * 2);
      for (int i=0; i<NumSpokes; i++) {
        float a = norm(i, 0, NumSpokes);
        pushMatrix();
          translate(Awidth/2., Aheight/2.);
          float rsgn = 1;
          if (i%2 == 0) rsgn = SpeedChangeFactor;
          if (rsgn == 0) rsgn = 1;
          rotate(rsgn * TWO_PI * (time+a));
          
          for (int b=0; b<NumBalls; b++) {
            rotate(TWO_PI * OffsetPerRing * b);
            float ba = norm(b, 0, NumBalls-1);
            float bdist = lerp(minDist, maxDist, ba);
            int numSteps = int(TWO_PI * TrailLen * bdist / (ballr/4.));
            for (int n=0; n<numSteps; n++) {
              float na = norm(n, 0, numSteps-1);
              color rust = color(220, 110, 70);
              color paleYellow = color(240, 230, 125);
              fill(lerpColor(rust, paleYellow,a), na*255);
              pushMatrix();
                rotate(na * TWO_PI * TrailLen);
                ellipse(bdist, 0, 2*ballr, 2*ballr);
              popMatrix();
            }
          }
        popMatrix();
      }
   }
}

// ================= Double Chain Spin

class DoubleChainSpin extends Animator {

  float WireRadius = .015;
  float WidthRatio = .1;
  int HorizLinks = 3;
  int VertLinks = 3;
  int InnerRing = -1;

  String WireRadiusLabel = "Wire Radius";
  String WidthRatioLabel = "Width Ratio";
  String HorizLinksLabel = "Horizontal Links";
  String VertLinksLabel = "Vertical Links";
  String InnerRingLabel = "Inner Ring";

  DoubleChainSpin() {
    super("Double Chain Spin");
    addSlider(sliders, WireRadiusLabel, .01, .05, WireRadius, false);
    addSlider(sliders, WidthRatioLabel, 0, .3, WidthRatio, false);
    addSlider(sliders, HorizLinksLabel, 1, 5, HorizLinks, true);
    addSlider(sliders, VertLinksLabel, 1, 5, VertLinks, true);
    addSlider(sliders, InnerRingLabel, -1, 1, InnerRing, true);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == WireRadiusLabel) WireRadius = fValue;
    if (sliderName == WidthRatioLabel) WidthRatio = fValue;
    if (sliderName == HorizLinksLabel) HorizLinks = iValue;
    if (sliderName == VertLinksLabel) VertLinks = iValue;
    if (sliderName == InnerRingLabel) InnerRing = iValue;
  }

  void restart() { 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(255, 255, 0);
  }

  void render(float time) {
    background(BackgroundColor);
    fill(ModelColor);
    noStroke();
    int numHoriz = HorizLinks;
    int numVert = VertLinks;
    float Radius = WireRadius;
    float poleOffset = (0.35-Radius)*Awidth;
    float poleDist = 2*poleOffset;
    float rotation = PI * 0.5;


    float widthRatio = WidthRatio;
    float screenRadius = Radius*Awidth;
    // take the span, remove all the link wire thicknesses (radii), divide by links, then add minimal link thicknesses to join
    float innerLength = (poleDist-(8*numHoriz+6)*screenRadius)/float(2*numHoriz+1);
    float ringLength = 8.*screenRadius + innerLength;
    // just add some bit, slider controlled
    float outerWidth = widthRatio*ringLength;
    float linkWid = ringLength+outerWidth;
    // walk in from outer edge: half of outer width in, plus 1 radii out for the pole itself
    float vertReach = poleOffset - linkWid/2. + screenRadius;
    float horizReach = (ringLength-4.*screenRadius)*(numHoriz-1);

    float heightRatio = 0.8;
    float Height = heightRatio/float(numVert);
    float midStartHeight = (1.0-heightRatio)/float(numVert+1);
    float MoveOut = 0.25;
    pushMatrix();
    // parent: translate all to center of screen
    translate(Awidth/2., Aheight/2.);

    for ( int wall = 0; wall < 4; wall++ ) {
      pushMatrix();
      rotate( float(wall) * HALF_PI );
      rotate( rotation * time );
      translate( 0., poleOffset );
      // failed experiment: float startHeight = midStartHeight + ((wall % 2 == 0) ? -0.1 : 0.1) ;
      float startHeight = midStartHeight;
      float dist;
      for (int vert=0; vert<numVert; vert++) {
        int horiz;
        float a;
        // the horizontal links - must be done first, as they draw rectangle fills inside links
        for (horiz=0; horiz<numHoriz; horiz++) { 
          if ( numHoriz == 1 )
            a = 0.0;
          else
            a = map(horiz, 0, numHoriz-1, -horizReach, horizReach);
          pushMatrix();
          translate(a, 0.0);
          // NOTE: fill *must* be set going into this method; changes to background - fix this
          HorizontalLink( time, Radius, startHeight+(Height/2.0)+vert*(Height+startHeight), linkWid, screenRadius*8. );
          //fill(vert*127, horiz*127, 255);
          popMatrix();
        }
        // vertical links
        for (horiz=0; horiz<=numHoriz; horiz++) { 
          a = map(horiz, 0, numHoriz, -vertReach, vertReach);
          pushMatrix();
          translate(a, 0.0);
          //fill(vert*255/numVert, horiz/numHoriz, 0);
          VerticalLink( time, Radius, startHeight+vert*(Height+startHeight), Height, linkWid-2.*screenRadius );
          popMatrix();
        }
      }
      // support poles
      //fill(255,255,0);
      ellipse(  poleOffset, 0, 2*screenRadius, 2*screenRadius);

      // top cap, for stability
      if ( time > 1. - Radius )
      {
        rect( -poleOffset, -screenRadius, poleDist, screenRadius*2.0 );
      }

      popMatrix();
    }

    if ( InnerRing != 0 ) {
      numHoriz = abs(InnerRing);
      poleOffset = (0.15-Radius)*Awidth;
      poleDist = 2*poleOffset;

      // take the span, remove all the link wire thicknesses (radii), divide by links, then add minimal link thicknesses to join
      innerLength = (poleDist-(8*numHoriz+6)*screenRadius)/float(2*numHoriz+1);
      ringLength = 8.*screenRadius + innerLength;
      // just add some bit, slider controlled
      outerWidth = 0.05*ringLength;
      linkWid = ringLength+outerWidth;
      vertReach = poleOffset - linkWid/2. + screenRadius;
      horizReach = (ringLength-4.*screenRadius)*(numHoriz-1);

      for ( int wall = 0; wall < 4; wall++ ) {
        pushMatrix();
        rotate( float(wall) * HALF_PI );
        rotate( InnerRing * rotation * time );
        translate( 0., poleOffset );
        // failed experiment: float startHeight = midStartHeight + ((wall % 2 == 0) ? -0.1 : 0.1) ;
        float startHeight = midStartHeight;
        float dist;
        for (int vert=0; vert<numVert; vert++) {
          int horiz;
          float a;
          // the horizontal links - must be done first, as they draw rectangle fills inside links
          for (horiz=0; horiz<numHoriz; horiz++) { 
            if ( numHoriz == 1 )
              a = 0.0;
            else
              a = map(horiz, 0, numHoriz-1, -horizReach, horizReach);
            pushMatrix();
            translate(a, 0.0);
            // NOTE: fill *must* be set going into this method; changes to background - fix this
            HorizontalLink( time, Radius, startHeight+(Height/2.0)+vert*(Height+startHeight), linkWid, screenRadius*8. );
            //fill(vert*127, horiz*127, 255);
            popMatrix();
          }
          // vertical links
          for (horiz=0; horiz<=numHoriz; horiz++) { 
            a = map(horiz, 0, numHoriz, -vertReach, vertReach);
            pushMatrix();
            translate(a, 0.0);
            //fill(vert*255/numVert, horiz/numHoriz, 0);
            VerticalLink( time, Radius, startHeight+vert*(Height+startHeight), Height, linkWid-2.*screenRadius );
            popMatrix();
          }
        }
        // support poles
        //fill(255,255,0);
        ellipse(  poleOffset, 0, 2*screenRadius, 2*screenRadius);

        // top cap, for stability
        if ( time > 1. - Radius )
        {
          rect( -poleOffset, -screenRadius, poleDist, screenRadius*2.0 );
        }

        popMatrix();
      }
    }

    popMatrix();
  }

  // lwidth is width of *rectangle* - width of chain link is 2*radius*Awidth larger
  void VerticalLink(float time, float radius, float startHeight, float lHeight, float lWidth )
  {
    float rectRadius = radius;
    float ellRadius = radius;
    boolean endLink = false;
    // adjust time to be 0 to lHeight
    float myTime = time - startHeight;
    float dist;
    // draw anything at all?
    if ( myTime <= lHeight && myTime >= 0.0 )
    {
      if ( myTime <= radius )
      {
        // bottom of bottom link: 1 to 0
        endLink = true;
        dist = (radius - myTime)/radius;
        rectRadius = ellRadius = radius*sqrt(1.-dist*dist);
      } else if ( myTime <= 2.*radius )
      {
        // top of bottom link: 0 to 1
        endLink = true;
        dist = (myTime-radius)/radius;
        rectRadius = radius*sqrt(1.-dist*dist);
      } else if ( myTime >= lHeight-radius )
      {
        // top of top link: 1 to 0
        endLink = true;
        dist = map(myTime, lHeight-radius, lHeight, 0, 1);
        rectRadius = ellRadius = radius*sqrt(1.-dist*dist);
      } else if ( myTime >= lHeight-2.*radius )
      {
        // bottom of top link
        endLink = true;
        dist = map(myTime, lHeight-2.*radius, lHeight-radius, 1, 0);
        rectRadius = radius*sqrt(1.-dist*dist);
      }
      if ( endLink )
      {
        rect(-lWidth/2., -Awidth*rectRadius, lWidth, 2*Awidth*rectRadius);
      }
      ellipse(-lWidth/2., 0, 2*Awidth*ellRadius, 2*Awidth*ellRadius);
      ellipse( lWidth/2., 0, 2*Awidth*ellRadius, 2*Awidth*ellRadius);
    }
  }

  void HorizontalLink(float  time, float radius, float startHeight, float lLength, float lWidth )
  {
    // simple square link for now
    float myTime = time - startHeight;
    float dist;
    float rectRadius = radius;
    // draw anything at all?
    if ( myTime >= -radius && myTime <= radius )
    {
      if ( myTime <= 0 )
      {
        // bottom of bottom link: 1 to 0
        dist = -myTime/radius;
        rectRadius = radius*sqrt(1.-dist*dist);
      } else
      {
        // top of bottom link: 0 to 1
        dist = myTime/radius;
        rectRadius = radius*sqrt(1.-dist*dist);
      }
      rectRadius *= Awidth;
      //rectRadius = radius*Awidth;
      rect(-lLength/2., -lWidth/2., lLength, lWidth);
      fill(BackgroundColor);
      if ( lLength-4.*rectRadius > 0 )
        rect(-lLength/2.+2.*rectRadius, -lWidth/2.+2.*rectRadius, lLength-4.*rectRadius, lWidth-4.*rectRadius);
      fill(255, 255, 0);
    }
  }
}

// ================= Hack Me

class HackMe extends Animator {
  int Rings = 2;
  float Radius = 0.07;
  int Mode = 0;

  String RingsLabel = "rings";
  String RadiusLabel = "radius";
  String ModeLabel = "mode";

  HackMe() {
    super("Hack Me");
    // arguments: sliders, String label, minimum, maximum, variable to change, is integer?
    addSlider(sliders, RingsLabel, 1, 4, Rings, true);  // "true" - it's an integer
    addSlider(sliders, RadiusLabel, .01, .3, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, ModeLabel, 0, 3, Mode, true);  // "true" - it's an integer
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == RingsLabel) Rings = iValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == ModeLabel) Mode = iValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(0, 139, 126);
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    // The RGB color you'll fill objects with. 
    fill(ModelColor);
    // Set this so that objects don't have outline edges. Edge thickness can be a bit tough
    // to control if you use "scale" at all.
    noStroke();

    // This "final" translation moves everything to the middle of the screen, and is used
    // on all objects. I wouldn't touch it if I were you...
    translate(Awidth/2., Aheight/2.);

    for (int ringNum=0; ringNum < Rings; ringNum++) { 
      // "norm" says to take ringNum and "map" the range 0 to Rings to 0 to 1.
      // For example, norm( 7, 0, 10 ) would return 7/10, i.e., 0.7.
      // By adding +1 to ringNum we always have a bit of offset for each ring
      float ringOffset = norm(ringNum+1, 0, Rings);
      
      // Draw 3 different objects
      for (int objNum=0; objNum < 3; objNum++ ) {
 
        // Isolate each object's transforms: apply them, draw the object, then pop to remove them.
        pushMatrix();
        
          // Rotate the object around a center point, depending on the time and the object number itself.
          float objOffset = norm(objNum, 0, 3);
          rotate(TWO_PI * (time + objOffset));
          
          // fancy code: for the outer ring, have it travel in a square. Get the sin and cos
          // of the rotation and extend the object outwards by the inverse of the larger during
          // translation.
          float scaleOffset = 1.0;
          
          // use Mode to choose whether to use this feature
          if ( Mode % 2 == 1)
          {
            if ( ringNum == Rings-1 )
            {
              float sinVal = abs( sin(TWO_PI * (time + objOffset) ) );
              float cosVal = abs( cos(TWO_PI * (time + objOffset) ) );
              scaleOffset = ( cosVal > sinVal ) ? 1. / cosVal : 1. / sinVal;
            }
          }
          
          // Move the object out from the origin.
          // Multiply by 0.47 (or less) times the frame width (a number of pixels) to keep the objects inside the frame.
          translate( ringOffset * scaleOffset * (0.47-Radius) * Awidth, 0.0 );
  
          // Draw a different object depending on the object number.
          // Find more basic objects at https://processing.org/examples/shapeprimitives.html
          switch ( objNum ) {
          case 0:
            // circle: x & y location, x & y diameter
            ellipse(0.0, 0.0, Awidth*2.*Radius, Awidth*2.*Radius);
            break;
    
          case 1:
            // get fancy: spin the rectangle itself around its center
            if ( (Mode/2) % 2 == 1 )
            {
              rotate(TWO_PI * 2.0 * (time + objOffset));
            }

            // rectangle: x & y upper corner, x & y dimensions
            rect(-(Awidth*Radius)/2., -(Awidth*Radius), Awidth*Radius, Awidth*Radius*2.);
            break;
    
          case 2:
            // polygon - in this case, a pentagon
            // x,y location, radius, number of points
            polygon( 0, 0, Awidth*Radius, 5 );
            break;
        } // end of object draw switch
        
        // Remove the operations we did to the object, except the translate at the start,
        // which we want to apply to everything.
        popMatrix();
      } // end of for loop
    } // end of ring
  }
}

// a simple subroutine to draw a regular polygon
// found at https://processing.org/examples/regularpolygon.html
void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

// ================= Dancing Cobras

class DancingCobras extends Animator {
  int Cobras = 8;
  float Radius = 0.05;
  float Swing = 0.445;
  int Mode = 0;

  String CobrasLabel = "cobras";
  String RadiusLabel = "radius";
  String SwingLabel = "swing";
  String ModeLabel = "mode";

  DancingCobras() {
    super("Dancing Cobras");
    // arguments: sliders, String label, minimum, maximum, variable to change, is integer?
    addSlider(sliders, CobrasLabel, 1, 16, Cobras, true);  // "true" - it's an integer
    addSlider(sliders, RadiusLabel, .01, .3, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, SwingLabel, .0, .5, Swing, false);  // "false" - it's a floating point number
    addSlider(sliders, ModeLabel, 0, 4, Mode, true);  // "true" - it's an integer
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == CobrasLabel) Cobras = iValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == SwingLabel) Swing = fValue;
    if (sliderName == ModeLabel) Mode = iValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(0, 139, 126);
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);

    // Set this so that objects don't have outline edges. Edge thickness can be a bit tough
    // to control if you use "scale" at all.
    noStroke();

    // This "final" translation moves everything to the middle of the screen, and is used
    // on all objects. I wouldn't touch it if I were you...
    translate(Awidth/2., Aheight/2.);

    for (int cobra=0; cobra < Cobras; cobra++) { 
      // The RGB color you'll fill objects with. 
      fill((cobra*123531+192)%255,(cobra*8233+31)%255,(cobra*2933+73)%255);
      // Isolate each object's transforms: apply them, draw the object, then pop to remove them.
      pushMatrix();
      float objOffset = norm(cobra, 0, Cobras);

      // Rotate the object around a center point, depending on the object number itself.
      rotate(PI * objOffset);
 
      // Move the object out from the origin.
      // Multiply by 0.47 (or less) times the frame width (a number of pixels) to keep the objects inside the frame.
      translate( Swing * Awidth * cos(PI * (objOffset + 2.0 * time) ), 0.0 );

      // Draw a different object depending on the mode number.
      // Find more basic objects at https://processing.org/examples/shapeprimitives.html
      switch ( Mode ) {
      case 0:
        // circle: x & y location, x & y diameter
        ellipse(0.0, 0.0, Awidth*2.*Radius, Awidth*2.*Radius);
        break;

      case 1:
        // circle: x & y location, x & y diameter
        // widen it so the cross-section is actually a circle
        float angle = PI * (objOffset + 2.0 * time);
        ellipse(0.0, 0.0, sqrt(1.+sin(angle)*sin(angle) ) * Awidth*2.*Radius, Awidth*2.*Radius);
        break;

      case 2:
        // get fancy: spin the square itself around its center
        rotate(PI * objOffset);

        // rectangle: x & y upper corner, x & y dimensions
        rect(-(Awidth*Radius), -(Awidth*Radius), Awidth*Radius*2., Awidth*Radius*2.);
        break;

      case 3:
        // get fancy: spin the rectangle itself around its center, thicken it in the direction of travel

        // rectangle: x & y upper corner, x & y dimensions
        angle = PI * (objOffset + 2.0 * time);
        float widthThick = (Awidth*Radius) * sqrt(1.+sin(angle)*sin(angle));
        rect(-widthThick, -(Awidth*Radius), widthThick*2., Awidth*Radius*2.);
        break;

      case 4:
        // polygon - in this case, a pentagon
        // x,y location, radius, number of points
        polygon( 0, 0, Awidth*Radius, max(Cobras,3) );
        break;
      } // end of object draw switch
        
      // Remove the operations we did to the object, except the translate at the start,
      // which we want to apply to everything.
      popMatrix();
    } // end of cobra loop
  }
}


// ================= Wobbly

class Wobbly extends Animator {
  int objectModes = 3;
  int wobbleModes = 3;
  int rotationModes = 4;
  int outerModes = 5;
  int phaseModes = 2;

  int BurstMode = 153;
  float BallRadius = .07;
  float BurstRadius = 0.7;
  float BurstOffset = .2;
  float Wobble = 3.;
  float RadialVariance = 1.5;
  int NumBalls = 8;

  String BurstModeLabel = "Burst Mode";
  String BallRadiusLabel = "Ball Radius";
  String BurstRadiusLabel = "Burst Radius";
  String BurstOffsetLabel = "Burst Offset";
  String WobbleLabel = "Wobble";
  String RadialVarianceLabel = "Radial Variance";
  String NumBallsLabel = "Number of Elements";

  Wobbly() {
    super("Wobbly");
    addSlider(sliders, BurstModeLabel, 0, objectModes*wobbleModes*phaseModes*rotationModes*outerModes-1, BurstMode, true);
    addSlider(sliders, BallRadiusLabel, .01, .3, BallRadius, false);
    addSlider(sliders, BurstRadiusLabel, .0, 1., BurstRadius, false);
    addSlider(sliders, BurstOffsetLabel, .0, 0.3, BurstOffset, false);
    addSlider(sliders, WobbleLabel, .0, 6.0, Wobble, false);
    addSlider(sliders, RadialVarianceLabel, 0., 8.0, RadialVariance, false);
    addSlider(sliders, NumBallsLabel, 1, 300, NumBalls, true);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == BurstModeLabel) BurstMode = iValue;
    if (sliderName == BallRadiusLabel) BallRadius = fValue;
    if (sliderName == BurstRadiusLabel) BurstRadius = fValue;
    if (sliderName == BurstOffsetLabel) BurstOffset = fValue;
    if (sliderName == WobbleLabel) Wobble = fValue;
    if (sliderName == RadialVarianceLabel) RadialVariance = fValue;
    if (sliderName == NumBallsLabel) NumBalls = iValue;
  }

  void restart() { 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(0, 139, 126);
  }

  void render(float time) {
    int divisor = 1;
    int objectState = BurstMode % 3;
    divisor *= objectModes;
    int wobbleState = ( BurstMode / divisor ) % wobbleModes ;
    divisor *= wobbleModes;
    int rotationState = ( BurstMode / divisor ) % rotationModes ;
    divisor *= rotationModes;
    int outerState = ( BurstMode / divisor ) % outerModes ;
    divisor *= outerModes;
    int phaseState = ( BurstMode / divisor ) % phaseModes ;
    divisor *= phaseModes;

    background(BackgroundColor);
    fill(ModelColor);
    noStroke();
    float temp1, burstRadius1, burstRadius2;
    // modes:
    //         0  1  2  3
    // rotate1 0  1  1  1
    // rotate2 X  X -1  1
    float rotate1 = rotationState;
    float rotate2 = rotate1;
    rotate1 = (rotate1 > 1.) ? 0. : 1.;
    rotate2 -= 2.;
    pushMatrix();
    translate(Awidth/2., Aheight/2.);
    //float dist = (Awidth/2.) * A3_BurstRadius * 2 * map(cos(TWO_PI * time), -1, 1, 0, 1);
    for (int ballNum=0; ballNum<NumBalls; ballNum++) { 
      float burstRadius = BurstRadius;
      float a = norm(ballNum, 0, NumBalls);
      float newTime = (phaseState==1 ? a : 0.) + time;
      // if newTime > 1.0, make the object disappear
      //if ( newTime <= 1.0 )
      //{
      newTime = time % 1.0;
      switch ( outerState ) {
      case 0:
        // nada - no movement
        break;

      case 1:
        // sine with a hole
        burstRadius *= (0.5+0.5*sin(newTime*PI));
        // sphere - sphere is evil, actually, as it moves too fast at poles,
        // making a thin sheet.
        //temp1 = 2.*(newTime-0.5);
        //burstRadius *= sqrt(1. - temp1*temp1);
        break;

      case 2:
        // sawtooth
        burstRadius *= 1. - abs(2.*(newTime-0.5));
        break;

      case 3:
        // sine
        burstRadius *= sin(newTime*PI);
        break;

      case 4:
        // full cosine
        burstRadius *= (1. - cos(newTime*TWO_PI))*0.5;
        break;

        /* 
                     // hi/lo - basically /-\ sort of a shape (with hyphen moved up to top)
                     temp1 = 0.3;
                     if ( newTime > 1. - temp1 )
                       burstRadius *= (1.-newTime)/temp1;
                     else if ( newTime < temp1 )
                       burstRadius *= newTime/temp1;
                     break;
                     */
      }
      //} else {
      //  burstRadius = 0.;
      //}

      burstRadius1 = burstRadius2 = burstRadius;
      switch ( wobbleState ) {
      case 0:
        // nada
        break;

      case 1:
        // wobble out
        burstRadius1 += BurstRadius*sin(Wobble*time*PI)/3.;
        burstRadius2 -= BurstRadius*sin(Wobble*time*PI)/3.;
        break;

      case 2:
        // phased wobble, offset by ball number
        temp1 = 
          burstRadius1 += BallRadius*sin(Wobble*(a+time)*PI)*2.;
        burstRadius2 -= BallRadius*sin(Wobble*(a+time)*PI)*2.;
      }
      float dist = (Awidth/2.) * burstRadius1;
      pushMatrix();
      rotate(TWO_PI * (a + time*rotate1 - BurstOffset*cos(2.0*TWO_PI*time)));
      //float radius = BallRadius * ( 1. + amp + amp * abs(cos(5.*TWO_PI * (time + float(ballNum)/float(NumBalls)))) );
      float radius = BallRadius * 0.5 * (1. + 0.5*RadialVariance * (1.0-sin(3.0*newTime*PI)));
      switch ( objectState ) {
      case 0:
        // circle
        ellipse(dist, 0.0, Awidth*radius, Awidth*radius);
        break;

      case 1:
        // square
        rect(dist-(Awidth*radius)/2., -(Awidth*radius)/2., Awidth*radius, Awidth*radius);
        break;

      case 2:
        // triangle
        // up the radius a little to make the object more solid
        //radius *= 1.4;
        triangle(dist-(Awidth*radius)/sqrt(3.), -(Awidth*radius), 
        dist-(Awidth*radius)/sqrt(3.), (Awidth*radius), 
        dist+(Awidth*radius)*2./sqrt(3.), 0.);
      }
      popMatrix();
      dist = (Awidth/2.) * burstRadius2;
      pushMatrix();
      if (rotate2 > -2.)
      {
        rotate(TWO_PI * a + rotate2 * PI * time + BurstOffset*cos(2.0*TWO_PI*time));
        //float radius = BallRadius * ( 1. + amp + amp * abs(cos(5.*TWO_PI * (time + float(ballNum)/float(NumBalls)))) );
        radius = BallRadius * 0.5 * (1. + 0.5*RadialVariance * (1.0-sin(3.0*newTime*PI)));
        switch ( objectState ) {
        case 0:
          // circle
          ellipse(dist, 0.0, Awidth*radius, Awidth*radius);
          break;

        case 1:
          // square
          rect(dist-(Awidth*radius)/2., -(Awidth*radius)/2., Awidth*radius, Awidth*radius);
          break;

        case 2:
          // triangle
          // up the radius a little to make the object more solid
          //radius *= 1.4;
          triangle(dist-(Awidth*radius)/sqrt(3.), -(Awidth*radius), 
          dist-(Awidth*radius)/sqrt(3.), (Awidth*radius), 
          dist+(Awidth*radius)*2./sqrt(3.), 0.);
        }
      }
      popMatrix();
    }
    popMatrix();
  }
}

// ================= Merge

// Note that this one uses the Shift classes above

class Merge extends Animator {
  float Radius = 0.04;
  float Scale = 1.0;
  float StartScale = 0.128;
  int NumObjects = 7;  // different rendering primitives
  int Mode = 19;
  int Elements = 6;
  float Hold = 0.2;

  color FillColor = color(182,106,113); // color(240,110,200);
  
  // set to Steps-1 to show last transform
  int BeginningStep = 0;
  int Steps = 8;

  String RadiusLabel = "radius";
  String ScaleLabel = "scale";
  String HoldLabel = "hold";
  String ModeLabel = "mode";
  String ElementsLabel = "elements";

  Merge() {
    super("Merge");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?    //addSlider(sliders, SpokesLabel, 1, 50, Spokes, true);  // "true" - it's an integer
    addSlider(sliders, ModeLabel, 0, NumObjects*4-1, Mode, true);  // "true" - it's an integer
    addSlider(sliders, HoldLabel, .0, 1.0, Hold, false);  // "false" - it's a floating point number
    addSlider(sliders, RadiusLabel, .02, .3, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, ScaleLabel, .01, 2., Scale, false);  // "false" - it's a floating point number
    //addSlider(sliders, ElementsLabel, 0, 6, Elements, true);  // "true" - it's an integer
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == ModeLabel) Mode = iValue;
    if (sliderName == HoldLabel) Hold = fValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == ScaleLabel) Scale = fValue;
    if (sliderName == ElementsLabel) Elements = iValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(243,207,9); //color(180, 205, 255);
    ModelColor = FillColor;
    
    color strokeColor = color(0,0,0);
        
    //set the various transforms
    ElementShiftList = new ElementShift[6];
    float xmult;
    for (int i=0; i<ElementShiftList.length; i++) {
      if ( i == 0 || i == 3 || i == 5 ) {
        xmult = 1;
      } else if ( i == 1 || i == 4 ) {
        xmult = 2;
      } else {
        xmult = 3;
      }
      float xloc = sqrt(3.0)/2.0 * xmult;
      float yloc;
      if ( i == 0 ) {
        yloc = 5.;
      } else if ( i == 1 ) {
        yloc = 4.;
      } else if ( i == 2 || i == 3 ) {
        yloc = 3.;
      } else if ( i == 4 ) {
        yloc = 2.;
      } else {
        yloc = 1.;
      }
      yloc = yloc / 2.;

      /* for debugging:
      color myFill = color(0);
      switch (i) {
        case 0: myFill = color(255,0,0); break;
        case 1: myFill = color(0,255,0); break;
        case 2: myFill = color(0,0,255); break;
        case 3: myFill = color(0,0,0); break;
        case 4: myFill = color(128,128,128); break;
        case 5: myFill = color(255,255,255); break;
      }
      */
      // randomish: myFill = color((i*60+72)%256,(i*138+140)%256,(i*198+33)%256);
      ElementShiftList[i] = new ElementShift(xloc*StartScale, yloc*StartScale, strokeColor, FillColor);
    }
    
    XFormLL = new XFormList[Steps];
    
    int numStep = 0;
    int direction;

    // little rotate
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 5;
      } else if ( i == 2 ) {
        direction = 4;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 1;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // counter rotate
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 6;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 3;
      } else if ( i == 4 ) {
        direction = 4;
      } else {
        direction = 6;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // subrotate 3
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 3;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 4;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 6;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // subrotate 6
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 3;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 5;
      } else if ( i == 3 ) {
        direction = 1;
      } else if ( i == 4 ) {
        direction = 5;
      } else {
        direction = 1;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // rotate right
    XFormLL[numStep] = new XFormList();
    // rotate right
    for (int i=0; i<6; i++) {
      if ( i == 0 || i == 1 || i == 3 ) {
        direction = 3;
      } else {
        direction = 4;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }
    numStep++;

    // flippy floppy
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 4;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 1;
      } else if ( i == 4 ) {
        direction = 5;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // wiper
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 6;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 4;
      } else {
        direction = 4;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // come on home
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 5;
      } else if ( i == 2 ) {
        direction = 1;  // or 3
      } else if ( i == 3 ) {
        direction =    4;
      } else if ( i == 4 ) {
        direction = 4;
      } else {
        direction = 6;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    // The RGB color you'll fill objects with. 
    fill(FillColor);
    // Set this so that objects don't have outline edges. Edge thickness can be a bit tough
    // to control if you use "scale" at all.
    noStroke();

    float newTime = time*(float)Steps;
    int anim = (int)newTime;
    newTime -= (float)anim;
    newTime = newTime/(1.0-Hold);
    if (newTime > 1.0 ) {
      newTime = 1.0;
    }
    else
    {
      // if lowest bit of mode is on, use sine
      if ( Mode % 2 == 1 )
      {
        newTime = -cos(newTime * PI)*0.5 + 0.5;
      }
    }

    // This "final" translation moves everything to the middle of the screen, and is used
    // on all objects. I wouldn't touch it if I were you...
    translate(Awidth/2., Aheight/2.);

    scale(Scale);

    // center stays immobile - note it won't be connected to anything, so a base would be needed
    if ( Mode >= NumObjects*2 ) {
      DrawObjectType( (Mode / 2) % NumObjects, Awidth*2.*Radius );
    }
    
    for (int ang=0; ang<6; ang++) {
    //for (int ang=0; ang<1; ang++) {
      pushMatrix();
        rotate( (float)ang * TWO_PI / 6. );
        for (int i=0; i<Elements; i++) {
          // to play last step: anim = Steps-1;
          // translate by all previous moves first, so retaining position
          float tx = 0.;
          float ty = 0.;
          for ( int tr = 0; tr < anim; tr++ ) {
            int direction = XFormLL[tr].ele[i].direction;
            tx += ElementShiftList[i].dirX(direction)*StartScale;
            ty += ElementShiftList[i].dirY(direction)*StartScale;
          }
          pushMatrix();
            translate(Awidth*tx,Awidth*ty);
           
            ElementShiftList[i].render(newTime, XFormLL[anim].ele[i].direction, Radius, StartScale, Mode, NumObjects, false, true);
          popMatrix();
        }
      popMatrix();
    }
  }
}

// ================= Shift

ElementShift[] ElementShiftList;
XFormList[] XFormLL;

class Shift extends Animator {
  float Radius = 0.04;
  float Scale = 1.0;
  int Mode = 1;
  int Elements = 6;
  float StartScale = 0.14;
  int NumObjects = 7;  // different rendering primitives
  float Hold = 0.2;
  
  color FillColor = color(0, 139, 126); // color(240,110,200);
  
  // set to Steps-1 to show last transform
  int BeginningStep = 0;
  int Steps = 7;

  String RadiusLabel = "radius";
  String ScaleLabel = "scale";
  String HoldLabel = "hold";
  String ModeLabel = "mode";
  String ElementsLabel = "elements";

  Shift() {
    super("Shift");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?    //addSlider(sliders, SpokesLabel, 1, 50, Spokes, true);  // "true" - it's an integer
    addSlider(sliders, ModeLabel, 0, NumObjects*4-1, Mode, true);  // "true" - it's an integer
    addSlider(sliders, HoldLabel, .0, 1.0, Hold, false);  // "false" - it's a floating point number
    addSlider(sliders, RadiusLabel, .02, .3, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, ScaleLabel, .01, 2., Scale, false);  // "false" - it's a floating point number
    //addSlider(sliders, ElementsLabel, 0, 6, Elements, true);  // "true" - it's an integer
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == ModeLabel) Mode = iValue;
    if (sliderName == HoldLabel) Hold = fValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == ScaleLabel) Scale = fValue;
    if (sliderName == ElementsLabel) Elements = iValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(250,240,200); //color(180, 205, 255);
    ModelColor = FillColor;
    
    color strokeColor = color(0,0,0);
        
    //set the various transforms
    ElementShiftList = new ElementShift[6];
    float xmult;
    for (int i=0; i<ElementShiftList.length; i++) {
      if ( i == 0 || i == 3 || i == 5 ) {
        xmult = 1;
      } else if ( i == 1 || i == 4 ) {
        xmult = 2;
      } else {
        xmult = 3;
      }
      float xloc = sqrt(3.0)/2.0 * xmult;
      float yloc;
      if ( i == 0 ) {
        yloc = 5.;
      } else if ( i == 1 ) {
        yloc = 4.;
      } else if ( i == 2 || i == 3 ) {
        yloc = 3.;
      } else if ( i == 4 ) {
        yloc = 2.;
      } else {
        yloc = 1.;
      }
      yloc = yloc / 2.;

      ElementShiftList[i] = new ElementShift(xloc*StartScale, yloc*StartScale, strokeColor, FillColor);
    }
    
    XFormLL = new XFormList[Steps];
    
    int numStep = 0;
    int direction;

    // little rotate
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 5;
      } else if ( i == 2 ) {
        direction = 4;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 1;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // rotate right
    XFormLL[numStep] = new XFormList();
    // rotate right
    for (int i=0; i<6; i++) {
      if ( i == 0 || i == 1 || i == 3 ) {
        direction = 3;
      } else {
        direction = 4;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }
    numStep++;

    // counter rotate
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 6;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 3;
      } else if ( i == 4 ) {
        direction = 4;
      } else {
        direction = 6;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // subrotate 3
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 3;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 4;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 6;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // subrotate 6
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 3;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 5;
      } else if ( i == 3 ) {
        direction = 1;
      } else if ( i == 4 ) {
        direction = 5;
      } else {
        direction = 1;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // flippy floppy
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 4;
      } else if ( i == 1 ) {
        direction = 3;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 1;
      } else if ( i == 4 ) {
        direction = 5;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;

    // wiper
    XFormLL[numStep] = new XFormList();
    for (int i=0; i<6; i++) {
      if ( i == 0 ) {
        direction = 6;
      } else if ( i == 1 ) {
        direction = 6;
      } else if ( i == 2 ) {
        direction = 6;
      } else if ( i == 3 ) {
        direction = 4;
      } else if ( i == 4 ) {
        direction = 4;
      } else {
        direction = 2;
      }
      XFormLL[numStep].ele[i] = new XForm(direction);
    }    
    numStep++;
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    // The RGB color you'll fill objects with. 
    fill(FillColor);
    // Set this so that objects don't have outline edges. Edge thickness can be a bit tough
    // to control if you use "scale" at all.
    noStroke();

    float newTime = time*(float)(Steps-BeginningStep);
    int anim = (int)newTime;
    newTime -= (float)anim;
    newTime = newTime/(1.0-Hold);
    if (newTime > 1.0 ) {
      newTime = 1.0;
    } else {
      // if lowest bit of mode is on, use sine
      if ( Mode % 2 == 1 )
      {
        newTime = -cos(newTime * PI)*0.5 + 0.5;
      }
    }

    // This "final" translation moves everything to the middle of the screen, and is used
    // on all objects. I wouldn't touch it if I were you...
    translate(Awidth/2., Aheight/2.);

    scale(Scale);

    // center stays immobile - note it won't be connected to anything, so a base would be needed
    if ( Mode >= NumObjects*2 ) {
      DrawObjectType( (Mode / 2) % NumObjects, Awidth*2.*Radius );
    }
    
    for (int ang=0; ang<6; ang++) {
    //for (int ang=0; ang<1; ang++) {
      pushMatrix();
        rotate( (float)ang * TWO_PI / 6. );
        for (int i=0; i<Elements; i++) {
          ElementShiftList[i].render(newTime, XFormLL[BeginningStep+anim].ele[i].direction, Radius, StartScale, Mode, NumObjects, false, true);
        }
      popMatrix();
    }
  }
}

class ElementShift {
  float xloc, yloc;
  color strokeColor, fillColor;
  
  ElementShift(float _xloc, float _yloc, color _strokeColor, color _fillColor) {
    xloc = _xloc;
    yloc = _yloc;
    strokeColor = _strokeColor;
    fillColor = _fillColor;
  }
  
  // time is 0.0 to 1.0, moving from current location in xform'ed direction
  void render(float time, int direction, float radius, float dirScale, int mode, int numObjs, boolean doStroke, boolean doFill) {
    noStroke();
    if (doStroke) stroke(strokeColor);
    noFill();
    if (doFill) fill(fillColor);
    pushMatrix();
      float tx = time*dirX(direction)*dirScale;
      float ty = time*dirY(direction)*dirScale;
      translate( Awidth*(tx+xloc), Awidth*(ty+yloc) );
      DrawObjectType( (mode / 2) % numObjs, Awidth*2.*radius );
    popMatrix();
  }

  float dirX(int dir) {
    switch ( dir ) {
      case 1:
      case 4:
      return 0;
      case 2:
      case 3:
      return sqrt(3.)/2.;
      case 5:
      case 6:
      return -sqrt(3.)/2.;
    }
    return 0.;
  }
  float dirY(int dir) {
    switch ( dir ) {
      case 1:
      return 1.0;
      case 4:
      return -1.0;
      case 2:
      case 6:
      return 0.5;
      case 3:
      case 5:
      return -0.5;
    }
    return 0.;
  }
}

class XForm {
  int direction;
  
  XForm( int _dir ) {
    direction = _dir;
  }
}
class XFormList {
  XForm[] ele;
  
  XFormList(){
    ele = new XForm[6];
  }
}

// A simple method to draw one of a variety of elements of a given size (in pixels), at the origin.
// The elements are not necessarily equally scaled, e.g., the hot-dogs are not.
// You want them in a different location? Use translate() before calling this method. This was cleaner
// and more efficient than calling pushMatrix/translate/popMatrix in this method, as the application
// can then control when to push and pop.
void DrawObjectType( int mode, float size )
{
  switch( mode ) {
    default:
    case 0: 
      ellipse(0.0, 0.0, size, size);
    break;

    case 1:
      // triangle
      triangle( -size/2., size/sqrt(3.),
      -size/2., -size/sqrt(3.),
      size/2., 0. );
      break;
      
    case 2:
      // double-triangle (Star of David)
      translate(0.,size/8.);
      triangle( 0.75*size/sqrt(3.), -0.75*size/2.,
      -0.75*size/sqrt(3.), -0.75*size/2.,
      0., 0.75*size/2. );
      translate(0.,-size/4.);
      triangle( 0.75*size/sqrt(3.), 0.75*size/2.,
      -0.75*size/sqrt(3.), 0.75*size/2.,
      0., -0.75*size/2. );
      // just to be safe, in case a pop doesn't happen, translate back to origin
      translate(0.,size/8.);
      break;
      
    case 3:
      // hexagon
      polygon(0,0,size/2., 6);
      break;
      
    case 4:
      // square
      rect(-size/2., -size/2., size, size);
      break;

    case 5:
      // hot dog / capsule
      rect(-size, -size/2., 2.*size, size);
      ellipse(-size, 0.0, size, size);
      ellipse(size, 0.0, size, size);
      break;

    case 6:
      // vertical hot dog / capsule
      rect(-size/2., -size, size, 2.*size);
      ellipse(0., -size, size, size);
      ellipse(0., size, size, size);
      break;

  }
}

// ================= Vase

class Vase extends Animator {
  //int Spokes = 16;
  //float InnerRadius = 0.07;
  //float Thickness = 0.03;
  //float Minimum = 0.05;
  //float Slope = 0.2;
  //float Wobbles = 3.;
  //float WobbleMag = 0.1;
  //float Scale = 1.25;
  //int Mode = 0;
  
  int Spokes = 16;
  float InnerRadius = 0.07;
  float Thickness = 0.03;
  float Minimum = 0.05;
  float Slope = 0.2;
  float Wobbles = 3.;
  float WobbleMag = 0.1;
  float Scale = 1.25;
  int Mode = 0;

  String SpokesLabel = "spokes";
  String ModeLabel = "mode";
  String InnerRadiusLabel = "radius";
  String ThicknessLabel = "thickness";
  String MinimumLabel = "minimum";
  String SlopeLabel = "slope";
  String WobblesLabel = "wobbles";
  String WobbleMagLabel = "wobble mag";
  String ScaleLabel = "scale";
  //String ModeLabel = "mode";

  Vase() {
    super("Vase");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?
    //addSlider(sliders, SpokesLabel, 1, 50, Spokes, true);  // "true" - it's an integer
    addSlider(sliders, ModeLabel, 0, 3, Mode, true);  // "true" - it's an integer
    addSlider(sliders, InnerRadiusLabel, .05, .3, InnerRadius, false);  // "false" - it's a floating point number
    //addSlider(sliders, ThicknessLabel, .01, .3, Thickness, false);  // "false" - it's a floating point number
    addSlider(sliders, MinimumLabel, .0, .3, Minimum, false);  // "false" - it's a floating point number
    addSlider(sliders, SlopeLabel, .0, 1., Slope, false);  // "false" - it's a floating point number
    addSlider(sliders, WobblesLabel, .0, 6., Wobbles, false);  // "false" - it's a floating point number
    addSlider(sliders, WobbleMagLabel, .0, .2, WobbleMag, false);  // "false" - it's a floating point number
    addSlider(sliders, ScaleLabel, .01, 2., Scale, false);  // "false" - it's a floating point number
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == SpokesLabel) Spokes = iValue;
    if (sliderName == ModeLabel) Mode = iValue;
    if (sliderName == InnerRadiusLabel) InnerRadius = fValue;
    if (sliderName == MinimumLabel) Minimum = fValue;
    if (sliderName == ThicknessLabel) Thickness = fValue;
    if (sliderName == SlopeLabel) Slope = fValue;
    if (sliderName == WobblesLabel) Wobbles = fValue;
    if (sliderName == WobbleMagLabel) WobbleMag = fValue;
    if (sliderName == ScaleLabel) Scale = fValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(180, 205, 255);
    ModelColor = color(0, 139, 126);
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    // The RGB color you'll fill objects with. 
    fill(ModelColor);
    // Set this so that objects don't have outline edges. Edge thickness can be a bit tough
    // to control if you use "scale" at all.
    noStroke();

    // This "final" translation moves everything to the middle of the screen, and is used
    // on all objects. I wouldn't touch it if I were you...
    translate(Awidth/2., Aheight/2.);

    ellipse(0.0, 0.0, Awidth*2.*InnerRadius, Awidth*2.*InnerRadius);
    // time > 0.02 so there's a solid bottom
    if ( InnerRadius > Thickness && time > 0.02 )
    {
      fill(BackgroundColor);
      ellipse(0.0, 0.0, Awidth*2.*(InnerRadius-Thickness), Awidth*2.*(InnerRadius-Thickness));
      fill(0, 139, 126);
    }
      
    for (int spokeNum=0; spokeNum < Spokes; spokeNum++) { 
      float spokeAngle = norm(spokeNum, 0, Spokes);
      
      // Isolate each object's transforms: apply them, draw the object, then pop to remove them.
      pushMatrix();
        
        // Rotate the object around a center point, depending on the time and the object number itself.
        if ( Mode % 2 == 0)
        {
          rotate(TWO_PI * (time + spokeAngle));
        }
        else
        {
          // make time instead go from 0.0 to the time where we repeat
          float adjTime = (( time * Wobbles / 2. ) % 1. ) * ( 2./Wobbles);
          if ( adjTime < 1./Wobbles )
          {
            rotate(TWO_PI * (adjTime + spokeAngle));
          }
          else
          {
            rotate(TWO_PI * ((2./Wobbles)-adjTime + spokeAngle));
          }
        }
          
        translate(-Awidth*(InnerRadius-Thickness/2.0), 0.);
            // circle: x & y location, x & y diameter
            //ellipse(0.0, 0.0, Awidth*2.*Radius, Awidth*2.*Radius);
            
        float length;
        if ( (Mode/2) % 2 == 0 )
        {
          length = Scale * ( WobbleMag * ((sin(time * Wobbles * TWO_PI )+1.)/2.) + Slope * (1.-time) + Minimum) ;
        } else {
          length = Scale * ( (WobbleMag + (Slope*(1.-time))) * ((sin(((time * Wobbles)-0.25) * TWO_PI )+1.)/2.) + Minimum) ;
        }

        // rectangle: x & y upper corner, x & y dimensions
        rect( -(Awidth*length), -(Awidth*Thickness/2.), Awidth*length, Awidth*Thickness);
        ellipse(-(Awidth*length), 0.0, Awidth*Thickness, Awidth*Thickness);

      // Remove the operations we did to the object, except the translate at the start,
      // which we want to apply to everything.
      popMatrix();

    } // end of spoke loop
  }
}

// ================= Dissection01 - Ag0015, http://imaginary-institute.com/GifLoops/ag0015edg.gif

/* 
This animator demonstrates the use of a Stepper323 object to control a multi-step animation
Create a Stepper323 by giving it an array of floats. The number of floats is implicitly
the number of steps. The floats give the relative duractions of the phases. They don't have
to add up to 1. So if you want 3 phases of relative lengths 1:3:2, you could use the
array {1,3,2} or {2,6,4} or {.3,.9,.6}. Just stick to numbers > 0. Later we hand the
Stepper a floating-point time value, and we get back the step number we're in (starting 
with 0) and the "alfa" value telling us where in the interval we are (this runs 0-1),
by handing the value of time to getStepNum() and getAlfa() respectively. You may pre-shape 
the alfa value using curves from the AU library. By default, we apply a smooth S curve, so 
at the start of each step the alfa parameter starts out slowly from 0, picks up speed, then 
slows down again to 1 at the end. You can change this "easing curve" on a per-step
basis using setEases(). You can also set assign a new value to all the steps at once with
setAllEases(). An important curve to know is AULib.EASE_LINEAR, which does no shaping.
*/

class Dissection01 extends Animator {

  float Size = .19;
  float S, S2;  // Size times Awidth, and half that value
  float Cx, Cy; // Center of the frame
  Stepper323 Stepper;  // determine where we are in the animation
  
  String SizeLabel = "Size";
  
  Dissection01() {
    super("Dissection 01");
    addSlider(sliders, SizeLabel, 0, .5, Size, false);
  }
  
  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == SizeLabel)  Size = fValue;
  }
   
  void rebuild() {
  }
  
  void restart() {
    BackgroundColor = color(140, 65, 60); // Important! Set background color
    ModelColor = color(220, 165, 65);
    Cx = Awidth/2.;
    Cy = Aheight/2.;
    
    float[] stepLengths = { 1, 1.2 }; 
    Stepper = new Stepper323(stepLengths);
     
    // Here I'll set all the eases to linear. Uncoment the next line to see the effect.
    //Stepper.setAllEases(AULib.EASE_LINEAR);
    
    // Here I'll set the first to be the default S-shape, the second a little antipate-move-bounce
    int[] easeTypes = { AULib.EASE_IN_OUT_CUBIC, AULib.EASE_ANTICIPATE_ELASTIC };   
    // Uncomment the next line to set these eases to the different steps.
    //Stepper.setEases(easeTypes);
  }
  
  void render(float time) {
    background(BackgroundColor);
    fill(ModelColor);
    stroke(220, 165, 65); // make sure pieces don't disconnect
    S = Awidth * Size;
    S2 = S/2.;  // we use this so much, it's nice to have it around in a variable
    int stepNum = Stepper.getStepNum(time);  // find out our step number (here, 0 or 1)
    float alfa = Stepper.getAlfa(time);      // where are we in [0,1) in this step?
    switch (stepNum) {
      case 0: drawStep0(alfa); break;
      case 1: drawStep1(alfa); break;
    }
  }
  
  void drawStep0(float alfa) { 
    rect(Cx-S2, Cy-S2, S, S);
    for (int i=0; i<4; i++) {
      pushMatrix();
        translate(Cx, Cy);
        rotate(-alfa * HALF_PI);
        rotate(i * HALF_PI);
        triangle(-S2, -S2, -S2, -(S2+S), S2, -S2);
        translate(S2, -S2);
        rotate(HALF_PI * alfa);
        triangle(0, 0, -S, -S, 0, -S);
      popMatrix();
    }
  }
  
  void drawStep1(float alfa) { 
    rect(Cx-S2, Cy-S2, S, S);
    for (int i=0; i<4; i++) {
    pushMatrix();
      translate(Cx, Cy);
      rotate(-alfa * HALF_PI);
      rotate(i * HALF_PI);
      triangle(-S2, -S2, -S2, -(S2+S), S2, -S2);
      translate(S+S2, -S2);
      PVector a = new PVector(-S, 0);
      PVector b = new PVector(0, -S);
      PVector ra = rotPt(a, alfa*6*PI/4.);
      PVector rb = rotPt(b, alfa*5*PI/4.);
      float bscl = lerp(1, sqrt(2.), alfa);
      rb.mult(bscl);
      triangle(0, 0, ra.x, ra.y, rb.x, rb.y);
    popMatrix();
    }
  }
  
  // a little utility to rotate a point in 2D about the origin
  PVector rotPt(PVector p, float angle) {
    float x = (p.x * cos(angle)) - (p.y * sin(angle));
    float y = (p.x * sin(angle)) + (p.y * cos(angle));
    return new PVector(x, y);
  }
}

// ================= Dissection02 - Ag0018, http://imaginary-institute.com/GifLoops/ag0018iyd.gif

class Dissection02 extends Animator {

  float Size = 1.16;
  float S;  // Size times Awidth
  float Cx, Cy; // Center of the frame
  float H, V;
  Stepper323 Stepper;
  
  String SizeLabel = "Size";
  
  Dissection02() {
    super("Dissection 02");
    addSlider(sliders, SizeLabel, 0.01, 2.0, Size, false);
  }
  
  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == SizeLabel)  Size = fValue;
  }
   
  void rebuild() {
  }
  
  void restart() {
    BackgroundColor = color(255); // Important! Set background color
    // model color is not black, as a black model is hard to discern in most viewers
    ModelColor = color(128,128,128);
    Cx = Awidth/2.;
    Cy = Aheight/2.;
    S = Awidth * .4;
    H = (S/4.)*sqrt(2);
    V = .5*(S/2.)*sqrt(2);
    /*
    We rebuild the Stepper here, rather than in rebuild, because we have to update when the
    FrameCount and Snapshots sliders change, and changes to those don't trigger a rebuild.
    */
    float[] stepLengths = { 10, 50, 10, 120, 10, 50, 10, 50 };
    Stepper = new Stepper323(stepLengths);

  }
  
  void render(float time) {
    background(BackgroundColor);
    fill(0);
    noStroke();
    int stepNum = Stepper.getStepNum(time);
    float alfa = Stepper.getAlfa(time);
    translate(Cx, Cy);
    scale( Size );
    pushMatrix();
      switch (stepNum) {
        case 0: drawPhase0(alfa); break;
        case 1: drawPhase1(alfa); break;
        case 2: drawPhase1(1); break;
        case 3: drawPhase3(alfa); break;
        case 4: drawPhase3(1); break;
        case 5: drawPhase5(alfa); break;
        case 6: drawPhase5(1); break;
        case 7: drawPhase7(alfa); break;
      }
    popMatrix();
  }
  
  void drawPhase0(float beta) {
    float a = S/sqrt(2.);
    quad(-a, 0, 0, -a, a, 0, 0, a);
  }
   
  void drawPhase1(float beta) {
    quad(-V, -V, V, -V, V, V, -V, V);
    float del = beta * V;
    for (int i=0; i<4; i++) {
      pushMatrix();
      rotate(i*HALF_PI);
      triangle(V+del+H, 0, V+del, -V, V+del, V);
      popMatrix();
    }
  }
   
  void drawPhase3(float beta) {
    float dV = (1-beta)*V;
    quad(-dV, -dV, dV, -dV, dV, dV, -dV, dV);
    float del = V;
    for (int i=0; i<4; i++) {
      pushMatrix();
      rotate(i*HALF_PI);
      translate(V+del, 0);
      rotate(beta*PI);
      triangle(H, 0, 0, -V, 0, V);
      popMatrix();
    }
  }
   
  void drawPhase5(float beta) {
    float del = (1-beta)*V;
    for (int i=0; i<4; i++) {
      pushMatrix();
      rotate(i*HALF_PI);
      translate(V+del, 0);
      rotate(PI);
      triangle(H, 0, 0, -V, 0, V);
      popMatrix();
    }
  }
   
  void drawPhase6(float beta) {
    float del = lerp(V, H, beta);
    for (int i=0; i<4; i++) {
      pushMatrix();
      rotate(i*HALF_PI);
      translate(V+del, 0);
      rotate(beta*PI);
      triangle(H, 0, 0, -V, 0, V);
      popMatrix();
    }
  }
   
  void drawPhase7(float beta) {
    float a = S/sqrt(2.);
    float b = lerp(S/2, a, beta);
    pushMatrix();
    rotate(-QUARTER_PI*(1-beta));
    quad(-b, 0, 0, -b, b, 0, 0, b);
    popMatrix();
  }
}

// ================= Dissection03 - Ag0032, http://imaginary-institute.com/GifLoops/ag0032aww.gif

class Dissection03 extends Animator {

  float Size = 0.93;
  float D;
  float Cx, Cy; // Center of the frame
  Stepper323 Stepper;
  color clr1 = color(240, 185, 155); // tan
  color clr2 = color(90, 55, 35);  // dark brown
  color clr3 = color(190, 105, 85); //muddy red
  
  
  String SizeLabel = "Size";
  
  Dissection03() {
    super("Dissection 03");
    addSlider(sliders, SizeLabel, 0.01, 2.0, Size, false);
  }
  
  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == SizeLabel)  Size = fValue;
  }
   
  void rebuild() {
  }
  
  void restart() {
    BackgroundColor = color(255); // Important! Set background color
    Cx = Awidth/2.;
    Cy = Aheight/2.;
    D = Awidth * .7;
    /*
    We rebuild the Stepper here, rather than in rebuild, because we have to update when the
    FrameCount and Snapshots sliders change, and changes to those don't trigger a rebuild.
    */
    float[] stepLengths = { 144, 96, 12 }; // relative lengths
    Stepper = new Stepper323(stepLengths);
    ModelColor = clr1;
  }
  
  void render(float time) { 
    background(BackgroundColor);
    fill(0, 0, 0, 128);
    noStroke();
        translate(Cx, Cy);
    scale(Size);
        translate(-Cx, -Cy);
    pushMatrix();
    int stepNum = Stepper.getStepNum(time);
    float alfa = Stepper.getAlfa(time);
    switch (stepNum) {
       case 0: phase0(alfa); break;
       case 1: phase1(alfa); break;
       case 2: phase2(alfa); break;
    }
    popMatrix();
  }

  void phase0(float alfa) {
    SliceColor = lerpColor(clr1, clr2, alfa);
    for (int i=0; i<4; i++) {
      pushMatrix();
        translate(Cx, Cy);
        rotate(HALF_PI * i);
        arc(lerp(-Cx, 0, alfa), lerp(-Cy, 0, alfa), D, D, 0, HALF_PI);
      popMatrix();
    }
  }
   
  void phase1(float alfa) {
    SliceColor = lerpColor(clr2, clr3, alfa);
    float rotAngle = TWO_PI * lerp(0, 3./8., bias(alfa, .8));
    float cAngle = TWO_PI * lerp(3./8., 4./8., alfa);
    float dr = mag(Cx, Cy);
    float fx = width + (dr * cos(cAngle));
    float fy = dr * sin(cAngle);
    fx = lerp(fx, 0, alfa)-Cx;
    fy = lerp(fy, 0, alfa)-Cy;
    for (int i=0; i<8; i++) {
      pushMatrix();
        translate(Cx, Cy);
        float q = HALF_PI * int(i/2);
        rotate(q);
        if (i%2 == 1) scale(-1, 1);
        translate(fx, fy);
        rotate(rotAngle);
        arc(0, 0, D, D, TWO_PI*5./8., TWO_PI*6./8.);
      popMatrix();
    }
  }
   
  void phase2(float alfa) {   
    phase1(1.0);
    SliceColor = lerpColor(clr3, clr1, alfa);
  }
   
  float ease(float t) {
    return(map(cos(t*PI), 1, -1, 0, 1));
  }
   
  float bias(float t, float bias) {
    return t/((((1.0/bias)-2)*(1.0-t))+1);
  }
}  

// ================= Dissection04 - Ag0027, http://imaginary-institute.com/GifLoops/ag0027ooc.gif

class Dissection04 extends Animator {

  float Size = 1.10;
  float BezR = 4.*(sqrt(2.)-1.)/3.;  // bezier control for circle-ish arc
  float Cx, Cy; // Center of the frame
  float RingR, RingW, RingT;
  float BoxR, BoxW, BoxH;
  Stepper323 Stepper;
  
  String SizeLabel = "Size";
  
  Dissection04() {
    super("Dissection 04");
    addSlider(sliders, SizeLabel, 0.01, 2.0, Size, false);
  }
  
  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == SizeLabel)  Size = fValue;
  }
   
  void rebuild() {
  }
  
  void restart() {
    BackgroundColor = color(90, 50, 30); // Important! Set background color
    ModelColor = color(255, 155, 45);
    Cx = Awidth/2.;
    Cy = Aheight/2.;
 
    RingR = Awidth * .2;
    RingW = Awidth * .1;
    RingT = Awidth * .1;
   
    BoxR = Awidth * .2;
    BoxH = Awidth * .1;
    BoxW = Awidth * .03;

    /*
    We rebuild the Stepper here, rather than in rebuild, because we have to update when the
    FrameCount and Snapshots sliders change, and changes to those don't trigger a rebuild.
    */
    float[] stepLengths = { 1, 1, 1, 1, 1, 1}; // relative lengths
    Stepper = new Stepper323(stepLengths);
  }
  
  void render(float time) {
    background(BackgroundColor);
    fill(ModelColor);
    stroke(255, 155, 45);
        translate(Cx, Cy);
    scale(Size);
        translate(-Cx, -Cy);
    pushMatrix();
    switch (Stepper.getStepNum(time)) {
       case 0: drawStep0(Stepper.getAlfa(time)); break;
       case 1: drawStep1(Stepper.getAlfa(time)); break;
       case 2: drawStep2(Stepper.getAlfa(time)); break;
       case 3: drawStep3(Stepper.getAlfa(time)); break;
       case 4: drawStep4(Stepper.getAlfa(time)); break;
       case 5: drawStep5(Stepper.getAlfa(time)); break;
    }
    popMatrix();
  }

  // circle spreads apart
  void drawStep0(float alfa) { 
    float r0 = RingR;
    float r1 = RingR + RingW;
    for (int i=0; i<4; i++) {
      float a = norm(i, 0, 4);
      float theta = TWO_PI * a;
      pushMatrix();
        translate(Cx, Cy);
        rotate(theta);
        translate(alfa*RingT, -alfa*RingT);
        beginShape();
          vertex(0, -r0);
          vertex(0, -r1);
          bezierVertex(BezR*r1, -r1, r1, -r1*BezR, r1, 0);
          vertex(r0, 0);
          bezierVertex(r0, -r0*BezR, r0*BezR, -r0, 0, -r0);
        endShape(CLOSE);
      popMatrix();
    }
  }
   
  // form rings
  void drawStep1(float alfa) { 
    float r0 = RingR * lerp(1, .5, alfa);
    float r1 = (RingR + RingW) * lerp(1, .5, alfa);
          float pushRing = RingT * lerp(1, 2.5, alfa);
    for (int i=0; i<4; i++) {
      float a = norm(i, 0, 4);
      float theta = TWO_PI * a;
      pushMatrix();
        translate(Cx, Cy);
        rotate(theta);
        translate(pushRing, -pushRing);
        for (int j=0; j<4; j++) {
          pushMatrix();
            switch (j) {
              case 0: break;
              case 1: rotate(alfa*HALF_PI); break;
              case 2: rotate(-alfa*HALF_PI); break;
              case 3: rotate(-alfa*PI); break;
            }
            beginShape();
              vertex(0, -r0);
              vertex(0, -r1);
              bezierVertex(BezR*r1, -r1, r1, -r1*BezR, r1, 0);
              vertex(r0, 0);
              bezierVertex(r0, -r0*BezR, r0*BezR, -r0, 0, -r0);
            endShape(CLOSE);
          popMatrix();
        }
      popMatrix();
    }
  }
   
  // pinch rings
  void drawStep2(float alfa) { 
    float r0 = RingR * .5;
    float r1 = (RingR + RingW) * .5;
    float pushRing = RingT * 2.5;
    float bezR = BezR * lerp(1, 2.1, alfa);
    for (int i=0; i<4; i++) {
      float a = norm(i, 0, 4);
      float theta = TWO_PI * a;
      pushMatrix();
        translate(Cx, Cy);
        rotate(theta);
        translate(pushRing, -pushRing);
        for (int j=0; j<4; j++) {
          pushMatrix();
            switch (j) {
              case 0: break;
              case 1: rotate(HALF_PI); break;
              case 2: rotate(-HALF_PI); break;
              case 3: rotate(-PI); break;
            }
            beginShape();
              vertex(0, -r0);
              vertex(0, -r1);
              bezierVertex(bezR*r1, -r1, r1, -r1*bezR, r1, 0);
              vertex(r0, 0);
              bezierVertex(r0, -r0*bezR, r0*bezR, -r0, 0, -r0);
            endShape(CLOSE);
          popMatrix();
        }
      popMatrix();
    }
  }
   
  // rotate the four rings
  void drawStep3(float alfa) { 
    float r0 = RingR * .5;
    float r1 = (RingR + RingW) * .5;
    float pushRing = RingT * 2.5;
    float bezR = BezR * 2.1;
    for (int i=0; i<4; i++) {
      float a = norm(i, 0, 4);
      float theta = TWO_PI * a;
      pushMatrix();
        translate(Cx, Cy);
        rotate(theta);
        translate(pushRing, -pushRing);
        switch (i) {
          case 0: rotate(alfa * QUARTER_PI); break;
          case 1: rotate(alfa * QUARTER_PI); break;
          case 2: rotate(-alfa * QUARTER_PI); break;
          case 3: rotate(-alfa * QUARTER_PI); break;
        }
        for (int j=0; j<4; j++) {
          pushMatrix();
            switch (j) {
              case 0: break;
              case 1: rotate(HALF_PI); break;
              case 2: rotate(-HALF_PI); break;
              case 3: rotate(-PI); break;
            }
            //rotate(alfa * QUARTER_PI);
            beginShape();
              vertex(0, -r0);
              vertex(0, -r1);
              bezierVertex(bezR*r1, -r1, r1, -r1*bezR, r1, 0);
              vertex(r0, 0);
              bezierVertex(r0, -r0*bezR, r0*bezR, -r0, 0, -r0);
            endShape(CLOSE);
          popMatrix();
        }
      popMatrix();
    }
  }
   
  // grow center ring
  void drawStep4(float alfa) { 
    float r0 = RingR * .5;
    float r1 = (RingR + RingW) * .5;
    float pushRing = RingT * 2.5;
    float bezR = BezR * 2.1; 
    drawStep3(1);
    pushMatrix();
      translate(Cx, Cy);
      rotate(QUARTER_PI);
      scale(alfa * 1);
      for (int i=0; i<4; i++) {
        pushMatrix();
          rotate(i * HALF_PI);
          beginShape();
            vertex(0, -r0);
            vertex(0, -r1);
            bezierVertex(bezR*r1, -r1, r1, -r1*bezR, r1, 0);
            vertex(r0, 0);
            bezierVertex(r0, -r0*bezR, r0*bezR, -r0, 0, -r0);
          endShape(CLOSE);
        popMatrix();
      }
    popMatrix();
  }
   
  // merge all rings
  void drawStep5(float alfa) { 
    float r0 = RingR * lerp(.5, 1, alfa);
    float r1 = (RingR + RingW) * lerp(.5, 1, alfa);
    float pushRing = RingT * lerp(2.5, 0, alfa);
    float bezR = BezR * lerp(2.1, 1, alfa);
    for (int i=0; i<4; i++) {
      float a = norm(i, 0, 4);
      float theta = TWO_PI * a;
      pushMatrix();
        translate(Cx, Cy);
        rotate(theta);
        translate(pushRing, -pushRing);
        switch (i) {
          case 0: rotate(-alfa * .5 * PI); break;
          case 1: rotate(alfa * .5 * PI); break;
          case 2: rotate(-alfa * .5 * PI); break;
          case 3: rotate(alfa * .5 * PI); break;
        }
        for (int j=0; j<4; j++) {
          pushMatrix();
            switch (j) {
              case 0: break;
              case 1: rotate(HALF_PI); break;
              case 2: rotate(-HALF_PI); break;
              case 3: rotate(-PI); break;
            }
            rotate(QUARTER_PI);
            beginShape();
              vertex(0, -r0);
              vertex(0, -r1);
              bezierVertex(bezR*r1, -r1, r1, -r1*bezR, r1, 0);
              vertex(r0, 0);
              bezierVertex(r0, -r0*bezR, r0*bezR, -r0, 0, -r0);
            endShape(CLOSE);
          popMatrix();
        }
      popMatrix();
    }
    pushMatrix();
      translate(Cx, Cy);
      rotate(QUARTER_PI);
      for (int i=0; i<4; i++) {
        pushMatrix();
          rotate(alfa * HALF_PI);
          rotate(i * HALF_PI);
          beginShape();
            vertex(0, -r0);
            vertex(0, -r1);
            bezierVertex(bezR*r1, -r1, r1, -r1*bezR, r1, 0);
            vertex(r0, 0);
            bezierVertex(r0, -r0*bezR, r0*bezR, -r0, 0, -r0);
          endShape(CLOSE);
        popMatrix();
      }
    popMatrix();
  }
}

// ================= WindSpinner 

class WindSpinner_spinner {
  PVector center; 
  float t0, t1, dt, radius;
  float poleRadius;
  float startTheta;
  color clr;
  
  WindSpinner_spinner(PVector _center, float _t0, float _t1, float _dt, float _radius, float _poleRadius, float _startTheta, color _clr) {
    center = _center.get();
    t0 = _t0;  // time of start of expansion
    t1 = _t1;  // time of final constraction
    dt = _dt;  // transition window at both ends (percentage of t1-t0)
    radius = _radius;
    poleRadius = _poleRadius;
    startTheta = _startTheta;
    clr = _clr;
  }

  void render(float time) {
    pushMatrix();
      pushStyle();
        fill(clr);
        noStroke();
        translate(center.x, center.y);
        rotate(startTheta + (TWO_PI * time));
        float prs2 = poleRadius / sqrt(2.);
        if ((time > t0) && (time < t1)) {    
          float a = 1;
          if (time < t0+dt) {
            a = map(cos(PI * norm(time, t0, t0+dt)), 1, -1, 0, 1);
          } else if (time > t1-dt) {
            a = map(cos(PI * norm(time, t1-dt, t1)), 1, -1, 1, 0);
          }
          float r = radius * a;
          float rs2 = r/sqrt(2.);
          float sqSize = lerp(prs2, rs2*.25, a);
          // triangle hack version
          pushMatrix();
            translate(a*(r-sqSize), 0);
            rect(-sqSize, -sqSize, 2*sqSize, 2*sqSize);
          popMatrix();
          pushMatrix();
            translate(-a*(r-sqSize), 0);
            rect(-sqSize, -sqSize, 2*sqSize, 2*sqSize);
          popMatrix();
        } else {        
          // draw the support pole
          fill(clr);
          rect(-prs2, -prs2, 2*prs2, 2*prs2);
        }
      popStyle();
    popMatrix();
  }
}  
  

class WindSpinner extends Animator {

  int NumSpinners = 6;
  float SphereRadiusStart = .37;
  int RandomSeed = 25;
  ArrayList<WindSpinner_spinner> spinnerList;

  String NumSpinnersLabel = "Number of spinners";
  String SphereRadiusStartLabel = "Starting radius";
  String RandomSeedLabel = "Random seed";

  WindSpinner() {
    super("WindSpinner");
    addSlider(sliders, NumSpinnersLabel, 3, 50, NumSpinners, true, true);
    addSlider(sliders, SphereRadiusStartLabel, .05, .5, SphereRadiusStart, false, true);
    addSlider(sliders, RandomSeedLabel, 1, 100, RandomSeed, true, true);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == NumSpinnersLabel) NumSpinners = iValue;
    if (sliderName == SphereRadiusStartLabel) SphereRadiusStart = fValue;
    if (sliderName == RandomSeedLabel) RandomSeed = iValue;
  }

  void rebuild() {
    spinnerList = new ArrayList<WindSpinner_spinner>();
    randomSeed(RandomSeed);
      
    float thisR = Awidth * SphereRadiusStart;
    int numTries = 1000;
    while (spinnerList.size() < NumSpinners) {
      int tryCount = 0;
      boolean packed = false;
      while ((!packed) && (tryCount++ < numTries)) {
        PVector center = new PVector(random(thisR, Awidth-thisR), random(thisR, Aheight-thisR));
        float poleRadius = Awidth*.02;//max(Awidth*.005, thisR*.2);
        boolean canPack = packable(center, thisR, poleRadius);
        if (canPack) {
          packed = true;
          float startTheta = random(0, HALF_PI);
          color clr = color(random(100,255), random(100,255), random(100,255));
          float t0 = random(.01, .2);
          float t1 = random(.8, .99);
          float dt = random(.2, .3);
          spinnerList.add(new WindSpinner_spinner(center, t0, t1, dt, thisR, poleRadius, startTheta, clr));
        }
      }
      if (!packed) {
        thisR *= .99;
      }
    }
    for (int i=0; i<spinnerList.size(); i++) {
      WindSpinner_spinner spinner = spinnerList.get(i);
    }
  }
  
  boolean packable(PVector center, float radius, float poleRadius) {
    for (int i=0; i<spinnerList.size(); i++) {
      WindSpinner_spinner spinner = spinnerList.get(i);
      float d = dist(center.x, center.y, spinner.center.x, spinner.center.y);
      float rsum = radius + spinner.radius;
      if (d < rsum) return false;
    }
    return true;
  }
  
  void restart() {     
    BackgroundColor = color(255, 205, 180);
    ModelColor = color(255);
  }

  void render(float time) {
    background(BackgroundColor);
    for (int i=0; i<spinnerList.size(); i++) {
      WindSpinner_spinner spinner = spinnerList.get(i);
      spinner.render(time);
    }
  }
}


// ================= Ag0007

class Ag0007 extends Animator {
  
  String AspectLabel = "Aspect";
  String ScaleLabel = "Scale";

  float Aspect = 1.0;
  float Scale = 1.06;
  
  Stepper323 Stepper;

  Ag0007() {
    super("Ag0007 - Rookery");
    addSlider(sliders, AspectLabel, 0., 2., Aspect, false);
    addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == ScaleLabel)
    {
      Scale = fValue;
      // no reason to reevaluate everything
      return;
    }
    if (sliderName == AspectLabel) Aspect = fValue;
    if (sliderName == ScaleLabel) Scale = fValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(255);
    ModelColor = color(0);
    float[] stepLengths = { 35, 35, 35, 35 }; 
    Stepper = new Stepper323(stepLengths);
  }

  void render(float time) {
    background(BackgroundColor);
    noStroke();
    if ( Aspect != 0.0 & Aspect != 2.0 ) {
      // there's a gap; things look better if strokes are on, but 3D printing is worse;
      // comment out this next line for a better print:
      stroke(ModelColor);
    } else {
      noStroke();
    }
    fill(ModelColor);
    int stepNum = Stepper.getStepNum(time);
    float alfa = Stepper.getAlfa(time);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale( Scale );
      switch (stepNum) {
        case 0: 
        drawBoxes007(alfa); 
        break;
        case 1:
        pushMatrix();
          rotate(lerp(0, QUARTER_PI, alfa));
          drawBoxes007(1.);
        popMatrix();
        break;
        case 2:
        pushMatrix();
          rotate(QUARTER_PI);
          drawBoxes007(1-alfa);
        popMatrix();
        break;
        case 3:
        pushMatrix();
          rotate(lerp(QUARTER_PI, HALF_PI, alfa));
          drawBoxes007(0.);
        popMatrix();
        break;
      }
    popMatrix();
  }
  
  void drawBoxes007(float alfa) {
    float R = 150;
    float s = 70;
    float beta = atan2(s, R);
    float m = sqrt(sq(R)+sq(s))-R;
    for (int i=0; i<4; i++) {
      pushMatrix();
        rotate(i*HALF_PI);
        rect(0, -(R+s), s*(2-Aspect)/2., s); // 12 o'clock
        rect(R, 0, s, -s*(2-Aspect)/2.);     // 3 o'clock
        
        pushMatrix();  // 1 o'clock to 12
        rotate(lerp(-QUARTER_PI, (-HALF_PI)+beta, alfa));
        translate(R+lerp(0, m, alfa), 0);
        rotate(lerp(0, -beta, alfa));
        rect(0, -Aspect*s/2., s, Aspect*s/2.);
        popMatrix();
   
        pushMatrix();  // 1 o'clock to 3
        rotate(lerp(-QUARTER_PI, -beta, alfa));
        translate(R+lerp(0, m, alfa), 0);
        rotate(lerp(0, beta, alfa));
        rect(0, 0, s, Aspect*s/2.);
        popMatrix();
      popMatrix();
    }
  }
}

// ================= Ag0011

class Ag0011 extends Animator {
  
  Element11[] Element11List;
  int NumFrames11 = 360;
  int NumElement11s = 16;


  String NumElement11sLabel = "Number of Elements";
  String OverlapLabel = "Overlap";
  String AspectLabel = "Aspect";
  String ScaleLabel = "Scale";

  color Ecolor = color(150, 35, 0, 75);
  float Overlap = 3.8;
  float Aspect = 3.5;
  float Scale = 0.8;

  Ag0011() {
    super("Ag0011 - Flippers");
    addSlider(sliders, NumElement11sLabel, 1, 30, NumElement11s, true);
    addSlider(sliders, OverlapLabel, 0., 6., Overlap, false);
    addSlider(sliders, AspectLabel, 0., 6., Aspect, false);
    addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == ScaleLabel)
    {
      Scale = fValue;
      // no reason to reevaluate everything
      return;
    }
    if (sliderName == NumElement11sLabel) NumElement11s = iValue;
    if (sliderName == OverlapLabel) Overlap = fValue;
    if (sliderName == AspectLabel) Aspect = fValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(170, 210, 200);
    ModelColor = color(Ecolor);
    float CircleR11 = Awidth * .3;
    Element11List = new Element11[NumElement11s];
    for (int i=0; i<Element11List.length; i++) {
      float theta = map(i, 0, Element11List.length, 0, TWO_PI);
      float cx = (Awidth/2.) + (CircleR11 * cos(theta));
      float cy = (Aheight/2.) + (CircleR11 * sin(theta));
      float rx = (1+Overlap) * (CircleR11/Element11List.length);
      float ry = rx * Aspect;
      float phase = theta;
      float speed = NumFrames11;
      color sclr = color(0);
      color fclr = Ecolor;
      Element11 e = new Element11(cx, cy, rx, ry, phase, speed, sclr, fclr);
      Element11List[i] = e;
    }
  }

  void render(float time) {
    background(BackgroundColor);
    // make smaller
    translate(Awidth/2., Aheight/2.);
    scale(Scale);
    translate(-Awidth/2., -Aheight/2.);
    for (int i=0; i<Element11List.length; i++) {
      Element11List[i].render(time, true, false, NumFrames11);
    }
    for (int i=0; i<Element11List.length; i++) {
      Element11List[i].render(time, false, true, NumFrames11);
    }
  }
}

class Element11 {
  float cx, cy, rx, ry;
  float phase, speed;
  color sclr, fclr;
  
  Element11(float acx, float acy, float arx, float ary, float aphase, float aspeed, color asclr, color afclr) {
    cx = acx;
    cy = acy;
    rx = arx;
    ry = ary;
    phase = aphase;
    speed = aspeed;
    sclr = asclr;
    fclr = afclr;
  }
  
  void render(float time, boolean doFill, boolean doStroke, int NumFrames11) {
    float angle = phase + (TWO_PI * time*NumFrames11/speed);
    noFill();
    if (doFill) fill(fclr);
    noStroke();
    if (doStroke) stroke(sclr);
    pushMatrix();
      translate(cx, cy);
      rotate(angle);
      ellipse(0, 0, 2*rx, 2*ry);
    popMatrix();
  }
}


// ================= Ag0012
// TODO: should delete or fix. This one does NOT scale properly when the Frame Size is reduced.
// Note also that this one appears to get "crashy" when the Speedup value is set > 1.

class Ag0012 extends Animator {
  int NumElement12s = 36;
  Element12[] Element12List;
  int NumFrames12 = 360;
   
  color Ecolor = color(40, 35, 100, 192);

  float Overlap = 3.8;
  float Aspect = 1.;

  String NumElement12sLabel = "Number of Elements";
  String OverlapLabel = "Overlap";
  String AspectLabel = "Aspect";

  Ag0012() {
    super("Ag0012 - Weave");
    addSlider(sliders, NumElement12sLabel, 1, 70, NumElement12s, true);
    addSlider(sliders, OverlapLabel, .0, 10., Overlap, false);
    addSlider(sliders, AspectLabel, .1, 6., Aspect, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == NumElement12sLabel) NumElement12s = iValue;
    if (sliderName == OverlapLabel) Overlap = fValue;
    if (sliderName == AspectLabel) Aspect = fValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(235, 235, 255);
    ModelColor = color(Ecolor);
    float CircleR12 = Awidth * .1;
    Element12List = new Element12[NumElement12s];
    for (int i=0; i<Element12List.length; i++) {
      float theta = map(i, 0, Element12List.length, 0, TWO_PI);
      float cx = (Awidth/2.) + (CircleR12 * cos(theta));
      float cy = (Aheight/2.) + (CircleR12 * sin(theta));
      float rx = (1+Overlap) * (CircleR12/Element12List.length);
      float ry = rx * Aspect;
      float phase = theta;
      float speed = NumFrames12;
      color sclr = color(0);
      color fclr = Ecolor;
      Element12 e = new Element12(cx, cy, rx, ry, phase, speed, sclr, fclr);
      Element12List[i] = e;
    }
  }

  void render(float time) {
    background(BackgroundColor);
    for (int i=0; i<Element12List.length; i++) {
      Element12List[i].render(time, NumFrames12);
    }
  }
}

class Element12 {
  float cx, cy, rx, ry;
  float phase, speed;
  color sclr, fclr;
  
  Element12(float acx, float acy, float arx, float ary, float aphase, float aspeed, color asclr, color afclr) {
    cx = acx;
    cy = acy;
    rx = arx;
    ry = ary;
    phase = aphase;
    speed = aspeed;
    sclr = asclr;
    fclr = afclr;
  }
  
  void render(float time, int NumFrames12) {
    float a = time*NumFrames12/speed;
    float angle = phase + (TWO_PI * a);
    float sina = map(sin(angle),-1,1,0,1);
    fill(fclr);
    stroke(sclr);
    pushMatrix();
      translate(cx, cy);
      translate(0, -.2*height);
      scale(.75);
      rotate(angle);
      //ellipse(0, 0, 2*rx, 2*ry);
      ellipse(lerp(-cx,cx,sina), .25*lerp(-cy, cy, sina), 5*rx, 5*ry);
    popMatrix();
  }
}

// ================= Ag0020

class Ag0020 extends Animator {
  Leaf0020[] LeafList;
  int numLeafs = 13;
  float Radius = 0.26;
  float LeafRadius = 1.6;

  String LeafLabel = "Leaves";
  String RadiusLabel = "Ring Radius";
  String LeafRadiusLabel = "Leaf Radius";

  Ag0020() {
    super("Ag0020 - Leaves");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?
    addSlider(sliders, LeafLabel, 1,30, numLeafs, true);  // "true" - it's an integer
    addSlider(sliders, RadiusLabel, .01, .6, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, LeafRadiusLabel, .1, 4., LeafRadius, false);  // "false" - it's a floating point number
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == LeafLabel) numLeafs = iValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == LeafRadiusLabel) LeafRadius = fValue;
    restart();
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(47,3,2);
    ModelColor = color(255);
    makeLeafs();
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    for (Leaf0020 leaf: LeafList) {
      leaf.render(time);
    }
  }
   
  void makeLeafs() {
    randomSeed(5);
    float ringR = Awidth * Radius;
    float LeafR = LeafRadius * TWO_PI * ringR / numLeafs;
    LeafList = new Leaf0020[numLeafs];
    for (int i=0; i<LeafList.length; i++) {
      float a = norm(i, 0, LeafList.length);
      float theta = TWO_PI * a;
      float cx = (Awidth/2.) + (ringR * cos(theta));
      float cy = (Aheight/2.) + (ringR * sin(theta));
      float r = LeafR;
      float angle = TWO_PI * a;
      float spinSpeed = 1;
      colorMode(HSB);
      int opacity = 128;
      color clr = color(random(10,50), random(150,200), random(200,255), opacity);
      colorMode(RGB);
      LeafList[i] = new Leaf0020(cx, cy, r, angle, spinSpeed, clr);
    }
  }
}

class Leaf0020 {
  float cx, cy, r;
  float angle, spinSpeed;
  color clr;
  
  Leaf0020(float _cx, float _cy, float _r, float _angle, float _spinSpeed, color _clr) {
    cx = _cx;
    cy = _cy;
    r = _r;
    angle = _angle;
    spinSpeed = _spinSpeed;
    clr = _clr;
  }
  
  void render(float t) {
    float tr = r * map(sin(t*TWO_PI), -1, 1, .7, 1.1);
    float a = .3 * tr;
    float b = .3 * tr;
    float c = .5 * tr;
    float d = .9 * tr;
    float h = tr;
    noStroke();
    fill(clr);
    pushMatrix();
      translate(cx, cy);
      rotate(angle + (TWO_PI * t * spinSpeed));
      beginShape();
        vertex(0, -h);
        bezierVertex(0, (-h)+a, -c, -b, -c, 0);
        
        bezierVertex(-c, b, 0, h-d, 0, h);
        bezierVertex(0, h-d, c, b, c, 0);
        
        //bezierVertex(-c, b, 0, h-a, 0, h);
        //bezierVertex(0, h-a, c, b, c, 0);
        bezierVertex(c, -b, 0, (-h)+a, 0, -h);
      endShape();
    popMatrix();
  }
}

// ================= Ag0025

class Ag0025 extends Animator {
  
  String ScaleLabel = "Scale";

  float Scale = 1.0;
  
  Stepper323 Stepper;

  Ag0025() {
    super("Ag0025 - The H");
    addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == ScaleLabel)
    {
      Scale = fValue;
      // no reason to reevaluate everything
      return;
    }
    if (sliderName == ScaleLabel) Scale = fValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(255, 245, 210);
    ModelColor = color(165, 80, 10);
    float[] stepLengths = { 1.5, .2, 1, 1.5, 1, .2};
    Stepper = new Stepper323(stepLengths);
  }

  void render(float time) {
    background(BackgroundColor);
    noStroke();
    fill(ModelColor);
    int stepNum = Stepper.getStepNum(time);
    float alfa = Stepper.getAlfa(time);
    pushMatrix();
      switch (stepNum) {
      case 0: barToH(alfa); break;
      case 1: barToH(1); break;
      case 2: HtoPuzzle(alfa); break;
      case 3: GrowPuzzle(alfa); break;
      case 4: PuzzleToBar(alfa); break;
      case 5: PuzzleToBar(1); break;
      }
    popMatrix();
  }
  
  void barToH(float alfa) {
    background(BackgroundColor);
    float p1 = width * .1;
    float p3 = 3*p1;
    float sclx = lerp(5, 1, alfa);
    float scly = lerp(3, 1, alfa);
    fill(ModelColor);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale( Scale );
      scale(sclx, scly);
      beginShape();
        vertex(-p3, -p3);
        vertex(-p1, -p3);
        vertex(-p1, -p1);
        vertex( p1, -p1);
        vertex( p1, -p3);
        vertex( p3, -p3);
        vertex( p3,  p3);
        vertex( p1,  p3);
        vertex( p1,  p1);
        vertex( -p1, p1);
        vertex(-p1,  p3);
        vertex(-p3,  p3);
      endShape(CLOSE);
    popMatrix();
  }
  
  void HtoPuzzle(float alfa) {
    background(BackgroundColor);
    float p1 = width * .1;
    float p3 = 3*p1;
    float m = p3 - (p1 * lerp(2, 1, alfa));
    float h = p3 - (p1 * lerp(0, 1, alfa));
    fill(ModelColor);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale( Scale );
      beginShape();
        vertex(-p3, -p3);
        vertex(-p1, -p3);
        vertex(-p1, -m);
        vertex( p1, -m);
        vertex( p1, -p3);
        vertex( p3, -p3);
        vertex( p3, -p1);
        vertex(  h, -p1);
        vertex(  h,  p1);
        vertex( p3,  p1);
        vertex( p3,  p3);
        vertex( p1,  p3);
        vertex( p1,   m);
        vertex(-p1,   m);
        vertex(-p1,  p3);
        vertex(-p3,  p3);
        vertex(-p3,  p1);
        vertex( -h,  p1);
        vertex( -h, -p1);
        vertex(-p3, -p1);
      endShape(CLOSE);
    popMatrix(); 
  }
  
  void GrowPuzzle(float alfa) {
    background(BackgroundColor);
    float p1 = width * .1;
    
    float a = p1 * lerp(2, 3, alfa);
    float b = p1 * lerp(1, 2, alfa);
    float c = p1 * lerp(3, 6, alfa);
    fill(ModelColor);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale( Scale );
      beginShape();
        rotate(alfa * HALF_PI);
        vertex(-c, -c);
        vertex(-b, -c);
        vertex(-b, -a);
        vertex( b, -a);
        vertex( b, -c);
        vertex( c, -c);
        vertex( c, -b);
        vertex( a, -b);
        vertex( a,  b);
        vertex( c,  b);
        vertex( c,  c);
        vertex( b,  c);
        vertex( b,  a);
        vertex(-b,  a);
        vertex(-b,  c);
        vertex(-c,  c);
        vertex(-c,  b);
        vertex(-a,  b);
        vertex(-a, -b);
        vertex(-c, -b);
        vertex(-c, -a);
      endShape(CLOSE);
    popMatrix();
  }
  
  void PuzzleToBar(float alfa) {
    background(ModelColor);
    float p1 = width * .1;
    
    float tleft = p1 * lerp(-2, -5, alfa);
    float twid = p1 * lerp(4, 10, alfa);
    float lleft = p1 * lerp(-5, -7, alfa);
    float rleft = p1 * lerp(3, 5, alfa);
    fill(BackgroundColor);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale( Scale );
      rect(tleft, -5*p1, twid, 2*p1);
      rect(tleft,  3*p1, twid, 2*p1);
      rect(lleft, -2*p1, 2*p1, 4*p1);
      rect(rleft, -2*p1, 2*p1, 4*p1);
    popMatrix();
  }
}


// ================= Ag0033

class Ag0033 extends Animator {
  Element0033[] ElementList;
  float CircleR;
  color StrokeColor = color(0);
  color ElementColor = color(140, 30, 10, 128);
  int NumFrames = 500;

  int NumElements = 55;
  float Overlap = 8.;
  float Aspect = 7.5;
  float Scale = 0.85;

  String NumElementsLabel = "Number of Elements";
  String OverlapLabel = "Overlap";
  String AspectLabel = "Aspect";
  String ScaleLabel = "Scale";

  Ag0033() {
    super("Ag0033 - Laurels");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?
    addSlider(sliders, NumElementsLabel, 1, 150, NumElements, true);
    addSlider(sliders, OverlapLabel, .0, 20., Overlap, false);
    addSlider(sliders, AspectLabel, .1, 20., Aspect, false);
    addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == ScaleLabel)
    {
      Scale = fValue;
      // no reason to reevaluate everything
      return;
    }
    if (sliderName == NumElementsLabel) NumElements = iValue;
    if (sliderName == OverlapLabel) Overlap = fValue;
    if (sliderName == AspectLabel) Aspect = fValue;
    restart();
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(255, 255, 255);
    ModelColor = color(ElementColor);
    CircleR = Awidth * .3;
    ElementList = new Element0033[NumElements];
    for (int i=0; i<ElementList.length; i++) {
      float xr = .1 * Overlap * (TWO_PI * CircleR / NumElements);
      float yr = Aspect * xr;
      float phase = TWO_PI * norm(i, 0, ElementList.length);
      ElementList[i] = new Element0033(xr, yr, phase, StrokeColor, ElementColor);
    }
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    pushMatrix();
      translate(Awidth/2., Aheight/2.);
      scale(Scale);
      for (int i=0; i<ElementList.length; i++) {
        ElementList[i].render(time, CircleR, false, true);
      }
      for (int i=0; i<ElementList.length; i++) {
        ElementList[i].render(time, CircleR, true, false);
      }
    popMatrix();
  }
}

class Element0033 {
  float xr, yr, phase;
  color strokeColor, fillColor;
  
  Element0033(float _xr, float _yr, float _phase, color _strokeColor, color _fillColor) {
    xr = _xr;
    yr = _yr;
    phase = _phase;
    strokeColor = _strokeColor;
    fillColor = _fillColor;
  }
  
  void render(float time, float radius, boolean doStroke, boolean doFill) {
    noStroke();
    if (doStroke) stroke(strokeColor);
    noFill();
    if (doFill) fill(fillColor);
    pushMatrix();
      float angle = PI + phase + (TWO_PI * time);
      rotate(angle);
      translate(0, radius);
      float theta = phase + (2 * TWO_PI * time);
      float px = xr * cos(theta);
      float py = yr * sin(theta);
      rotate(theta);
      ellipse(0, 0, 2*xr, 2*yr);
      //ellipse(px, py, xr, xr);
    popMatrix();
  }
}


// ================= Ag0035

class Ag0035 extends Animator {

  Ag0035() {
    super("Ag0035 - Not so printable");
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(255, 255, 255);
    ModelColor = color(125, 85, 45);  // dark brown
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    float fFrameCount = time * 120.;
    drawRing(140, 250, 90, 30, .5*PI, TWO_PI*fFrameCount/120.0,
            color(255, 0, 0), color(255));
    drawRing(360, 250, 90, 30, .5*PI, PI+(TWO_PI*fFrameCount/120.0),
            color(0, 0, 255), color(255));
    float ballSpeed = 110.0/30.0; // pixels per frame
    float ballgap = 120*ballSpeed; // distance between balls
    float ballD = 30;
    
    float xstartFrame = 60-(35*ballSpeed);
    float xthisFrame = (fFrameCount-xstartFrame) % 240;
    float cx = ballSpeed * xthisFrame;
    fill(ModelColor);  // dark brown
    ellipse(cx, 230, ballD, ballD);
    ellipse(cx-ballgap, 230, ballD, ballD);
    ellipse(cx+ballgap, 230, ballD, ballD);
    //fill(135, 175, 40); // pea green
    ellipse(Awidth-cx, 280, ballD, ballD);
    ellipse(Awidth-(cx+ballgap), 280, ballD, ballD);
    ellipse(Awidth-(cx-ballgap), 280, ballD, ballD);
    
    float ystartFrame = 105-(145*ballSpeed);
    ystartFrame -= 120;
    float ythisFrame = (fFrameCount-ystartFrame) % 240;
    float cy = ballSpeed * ythisFrame;
    fill(55, 185, 130);  // dark cyan
    ellipse(160, cy, ballD, ballD);
    ellipse(160, cy-ballgap, ballD, ballD);
    ellipse(160, cy+ballgap, ballD, ballD);
    //fill(255, 140, 20);  // orange
    ellipse(340, Aheight-cy, ballD, ballD);
    ellipse(340, Aheight-(cy-ballgap), ballD, ballD);
    ellipse(340, Aheight-(cy+ballgap), ballD, ballD);
  }

  void drawRing(float cx, float cy, float cr, float thickness, 
                float gap, float angle, color ringColor, color bgColor) {
    float bigR = cr + (thickness/2.);
    float smallR = cr - (thickness/2.);
    noStroke();
    fill(ringColor);
    pushMatrix();
      translate(cx, cy);
      ellipse(0, 0, 2*bigR, 2*bigR);
      fill(bgColor);
      ellipse(0, 0, 2*smallR, 2*smallR);
      rotate(angle+PI);
      arc(0, 0, 2+(2*bigR), 2+(2*bigR), PI-(gap/2.), PI+(gap/2.));
     popMatrix();
  }
}

// ================= Ag0055

class Ag0055 extends Animator {
  
  String ScaleLabel = "Scale";
  String ShrinkLabel = "Gap Shrink";

  float Scale = 1.28;
  float Side, Gap, Wid, Hgt, Angle, GapNow;
  float GapShrink = 0.5;
  
  Stepper323 Stepper;

  Ag0055() {
    super("Ag0055 - Equality");
    addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
    addSlider(sliders, ShrinkLabel, -0.5, 2.0, GapShrink, false);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == ScaleLabel) Scale = fValue;
    if (sliderName == ShrinkLabel) GapShrink = fValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(255);
    ModelColor = color(0);
    float[] stepLengths = { 2, 4, 2, 1 }; // relative lengths
    Stepper = new Stepper323(stepLengths);
    Side = Awidth*0.3;
    Gap = Side*0.8;
  }

  void render(float time) {
    background(BackgroundColor);
    noStroke();
    fill(ModelColor);
    int stepNum = Stepper.getStepNum(time);
    float alfa = Stepper.getAlfa(time);
    pushMatrix();
      switch (stepNum) {
        case 0: 
          Wid = 2*Side; 
          Hgt = Side/2; 
          GapNow = lerp(0, Gap, alfa); 
          Angle = 0;
          drawBoxes0055(); 
          break;
        case 1: 
          Wid = Side * lerp(2, 1, alfa); 
          Hgt = Side * lerp(.5, 1, alfa);
          GapNow = Gap*lerp(1, GapShrink, alfa); 
          Angle = HALF_PI*alfa; 
          drawBoxes0055();
          break;
        case 2: 
          Wid = Side; 
          Hgt = Side; 
          GapNow = Gap * lerp(GapShrink, 0, alfa); 
          Angle = HALF_PI;
          drawBoxes0055();
          break;
        case 3: 
          Wid = 2*Side; 
          Hgt = Side/2; 
          GapNow = 0; 
          Angle = 0;
          drawBoxes0055(); 
          break;
        default:
      }
    popMatrix();
  }
  
  void drawBoxes0055() {
    float left = -Wid/2.;
    float top = -((GapNow/2.)+Hgt);
    translate(Awidth/2., Aheight/2.);
    scale( Scale );
    rotate(Angle);
    rect(left, top, Wid, Hgt);
    rect(left, top+Hgt+GapNow, Wid, Hgt);
  }
}

// ================= Ag0065

class Ag0065 extends Animator {
  
  String ScaleLabel = "Scale";
  String StrokeWidthLabel = "Stroke Width";
  String BigRadiusLabel = "Big Radius";
  String SmallRadiusLabel = "Small Radius";
  String BigFrequencyLabel = "Big Cycles";
  String SmallFrequencyLabel = "Small Cycles";
  String BigAmplitudeLabel = "Big Amplitude";
  String SmallAmplitudeLabel = "Small Amplitude";
  String NumDotsLabel = "Number of Dots";

  float Scale = 1;
  float StrokeWidth = 50;
  float BigR = 0.44;
  float SmallR = 0.22;
  float BigF = 3;  // cycles per second
  float SmallF = 2;
  float BigA = 0.5; // amplitude on each side of 0
  float SmallA = 0.7;
  float NumDots = 15;

  Ag0065() {
    super("Ag0065 derivations");
    //addSlider(sliders, ScaleLabel, 0.1, 1.5, Scale, false);
    //addSlider(sliders, StrokeWidthLabel, 1, 200, StrokeWidth, true);
    addSlider(sliders, BigRadiusLabel, 0.0, 0.5, BigR, false);
    addSlider(sliders, SmallRadiusLabel, 0.0, 0.5, SmallR, false);
    addSlider(sliders, BigFrequencyLabel, 1, 5, BigF, true);
    addSlider(sliders, SmallFrequencyLabel, 1, 5, SmallF, true);
    addSlider(sliders, BigAmplitudeLabel, 0.0, 2.0, BigA, false);
    addSlider(sliders, SmallAmplitudeLabel, 0.0, 2.0, SmallA, false);
    addSlider(sliders, NumDotsLabel, 1, 40, NumDots, true);
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    if (sliderName == ScaleLabel) Scale = fValue;
    if (sliderName == StrokeWidthLabel) StrokeWidth = iValue;
    if (sliderName == BigRadiusLabel) BigR = fValue;
    if (sliderName == SmallRadiusLabel) SmallR = fValue;
    if (sliderName == BigFrequencyLabel) BigF = iValue;
    if (sliderName == SmallFrequencyLabel) SmallF = iValue;
    if (sliderName == BigAmplitudeLabel) BigA = fValue;
    if (sliderName == SmallAmplitudeLabel) SmallA = fValue;
    if (sliderName == NumDotsLabel) NumDots = iValue;
    restart();
  }

  void restart() {     
    BackgroundColor = color(255);
    ModelColor = color(0);
  }

  void render(float time) {
    background(BackgroundColor);
    strokeWeight(StrokeWidth);
    fill(ModelColor);
    stroke(ModelColor);
    pushMatrix();
      for (int i=0; i<NumDots; i++) {
        float alfa = map(i, 0, NumDots, 0, 1);
        float smallT = (alfa*TWO_PI) + (SmallA * PI * sin(TWO_PI * SmallF * time));
        float bigT = (alfa*TWO_PI) + (BigA * PI * sin(TWO_PI * BigF * time));
        float sx = (width/2.) + Scale * (SmallR * Awidth * cos(smallT));
        float sy = (height/2.) + Scale * (SmallR * Awidth * sin(smallT));
        float bx = (width/2.) + Scale * (BigR * Awidth * cos(bigT));
        float by = (height/2.) + Scale * (BigR * Awidth * sin(bigT));
        line(sx, sy, bx, by);
      }
    popMatrix();
  }
}

// ================= Sphereflake

class Sphereflake extends Animator {
  int numLevels = 4;
  float Radius = 0.27;
  float Overlap = 0.38;
  float Reduction = 0.3333;
  int spheresPerLevel = 12;
  Sphere[] sphereList;

  
  int numSpheres;
  color clr = color(59,92,136);
  int sphereCount;
  PVector[] axis12 = new PVector[12];
  PVector zAxis = new PVector(0.,0.,1.);

  String NumLevelsLabel = "Levels";
  String RadiusLabel = "Sphere Radius";
  String OverlapLabel = "Overlap";
  String ReductionLabel = "Size Retained";
  String NumSpheresLabel = "Spheres per Level";

  Sphereflake() {
    super("Sphereflake");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?
    addSlider(sliders, NumLevelsLabel, 0,6, numLevels, true);  // "true" - it's an integer
    addSlider(sliders, RadiusLabel, .01, .6, Radius, false);  // "false" - it's a floating point number
    addSlider(sliders, OverlapLabel, .0, 1., Overlap, false);  // "false" - it's a floating point number
    addSlider(sliders, ReductionLabel, .1, 1., Reduction, false);  // "false" - it's a floating point number
    addSlider(sliders, NumSpheresLabel, 1,12, spheresPerLevel, true);  // "true" - it's an integer
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == NumLevelsLabel) numLevels = iValue;
    if (sliderName == RadiusLabel) Radius = fValue;
    if (sliderName == OverlapLabel) Overlap = fValue;
    if (sliderName == ReductionLabel) Reduction = fValue;
    if (sliderName == NumSpheresLabel) spheresPerLevel = iValue;
    restart();
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(244,183,80);
    ModelColor = color(59,92,136);
    makeSpheres();
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    fill(ModelColor);

    for (Sphere Sphere: sphereList) {
      Sphere.render(time);
    }
  }
   
  void makeSpheres() {
    numSpheres = 1;
    for ( int i = 1; i <= numLevels; i++ ) {
      numSpheres += pow(spheresPerLevel,i);
    }
    sphereList = new Sphere[numSpheres];
    colorMode(RGB);
    sphereCount = 0;
    sphereList[sphereCount++] = new Sphere(0., 0., 0.5, Radius, clr);
    // to rest on ground:
    //sphereList[sphereCount++] = new Sphere(0., 0., Radius, Radius, clr);
    if ( numLevels > 0 )
    {
      makeAxes();
      PVector axis = new PVector(0.,0.,1.);
      makeChildren( sphereList[0], axis, Radius*(1.+Reduction*(1.-Overlap)), numLevels-1 );
    }
  }
  void makeAxes()
  {
    PVector yAxis = new PVector(0.,1.,0.);
    for ( int i = 0; i < spheresPerLevel; i++ )
    {
      axis12[i] = new PVector( 1.,0.,0.);
      // for first 6, we rotate 2*PI/6 - first one really needs no rotation
      if ( i < 6 )
      {
        axis12[i].rotate( float(i)*TWO_PI/6. );
      }
      else if ( i < 9 )
      {
        // first rotate along Y axis by asin(sqrt(6)/3) - sphere packing distance
        axis12[i] = rotateVert( axis12[i], -asin(sqrt(6.)/3.), yAxis );
        // then rotate along Z axis by offset
        axis12[i] = rotateVert( axis12[i], (float(i)+0.25)*TWO_PI/3., zAxis );
      }
      else
      {
        // first rotate along Y axis by asin(sqrt(6)/3) - sphere packing distance
        axis12[i] = rotateVert( axis12[i], asin(sqrt(6.)/3.), yAxis );
        // then rotate along Z axis by offset
        axis12[i] = rotateVert( axis12[i], (float(i)+0.25)*TWO_PI/3., zAxis );
      }
    }
  }
  
  // angle is in radians
  PVector rotateVert(PVector vert, float angle, PVector axis){
    PVector clone = new PVector(vert.x,vert.y,vert.z);
    PVector dst = new PVector();
    //rotate using a matrix
    PMatrix3D rMat = new PMatrix3D();
    rMat.rotate(angle,axis.x,axis.y,axis.z);
    rMat.mult(clone,dst);
    return dst;
  }
  
  void makeChildren( Sphere sphere, PVector axis, float scale, int levels ) {
    PVector loc = new PVector();
    PVector subaxis = new PVector();
    PVector rotaxis = new PVector();
    // rotate each ball placement axis so that it's relative to the passed in axis treated as +Z.
    // In other words, rotate each axis from a +Z orientation to the passed in axis orientation.
    float angle = -PVector.angleBetween( zAxis, axis );
    if ( angle != 0. )
    {
      rotaxis.set(axis.y,-axis.x,0.);
      rotaxis.normalize();
    }
    for ( int i = 0; i < spheresPerLevel; i++ )
    //for ( int i = 0; i < 1; i++ )
    {
      // initialize the 12 locations compared to the origin
      loc.set( axis12[i].x, axis12[i].y, axis12[i].z );
      if ( angle != 0. )
      {
        loc = rotateVert( loc, angle, rotaxis);
      }
      subaxis.set( loc.x, loc.y, loc.z );
      loc.mult( scale );
      loc.add( sphere.cx, sphere.cy, sphere.cz );
      // check axis passed in compared to +Z: rotate angle axis compare to this
      sphereList[sphereCount] = new Sphere(loc.x,loc.y,loc.z, sphere.r*Reduction, clr);
      if ( levels > 0 )
      {
        makeChildren( sphereList[sphereCount++], subaxis, sphere.r*Reduction*(1.+Reduction*(1.-Overlap)), levels-1 );
      }
      else
      {
        // simply note this one's used.
        sphereCount++;
      }
    }
  }
}

class Sphere {
  float cx, cy, cz, r;
  color clr;
  
  Sphere(float _cx, float _cy, float _cz, float _r, color _clr) {
    cx = _cx;
    cy = _cy;
    cz = _cz;
    r = _r;
    clr = _clr;
  }
  
  void render(float t) {
    // is sphere visible? Note we don't allow spheres to overlap the 0 or 1 time border
    float radius = abs( cz - t );
    if ( radius <= r )
    {
      radius = sqrt(r*r - radius*radius);
      noStroke();
      fill(clr);
      // move to origin
      ellipse((cx+0.5)*Awidth,(cy+0.5)*Aheight,2.*radius*Awidth,2.*radius*Aheight);
    }
  }
}

// ================= Jephthai Blob, from http://joshstone.us/blob/, used with permission

class Jephthai extends Animator {
  int Duration = 800;
  float Scale = 1.0;
  float Retention = 0.2;
  float RotationVelocity = 60.;
  float SpinVelocity = 20.;
  float SkewSine = 50.;
  float SkewCosine = 50.;
  float ColorVelocity = 1.6;
  

  String DurationLabel = "Duration";
  String ScaleLabel = "Scale";
  String RetentionLabel = "Retention";
  String RotationVelocityLabel = "Rotation Velocity";
  String SpinVelocityLabel = "Spin Velocity";
  String SkewSineLabel = "Skew Sine";
  String SkewCosineLabel = "Skew Cosine";
  String ColorVelocityLabel = "Color Velocity";

  // From https://www.reddit.com/r/processing/comments/3dt69p/i_love_simple_code_that_makes_complicated_shapes/
  Jephthai() {
    super("Jephthai's Blob");
    // arguments: sliders, String label, minimum, maximum, variable to change, integer?
    addSlider(sliders, DurationLabel, 1, 2000, Duration, true);  // "true" - it's an integer
    addSlider(sliders, ScaleLabel, 0.2, 3.0, Scale, false);  // "false" - it's a float
    addSlider(sliders, RetentionLabel, 0.0, 1.0, Retention, false);  // "false" - it's a float
    addSlider(sliders, RotationVelocityLabel, 40., 60., RotationVelocity, false);  // "false" - it's a float
    addSlider(sliders, SpinVelocityLabel, 10., 25., SpinVelocity, false);  // "false" - it's a float
    addSlider(sliders, SkewSineLabel, 30., 60., SkewSine, false);  // "false" - it's a float
    addSlider(sliders, SkewCosineLabel, 30., 60., SkewCosine, false);  // "false" - it's a float
    //addSlider(sliders, ColorVelocityLabel, 1.2, 2.2, ColorVelocity, false);  // "false" - it's a float
  }

  void sliderChanged(String sliderName, int iValue, float fValue) {
    // for each slider above, add a line here with the label, variable name, and integer/float value.
    if (sliderName == DurationLabel) Duration = iValue;
    if (sliderName == ScaleLabel) Scale = fValue;
    if (sliderName == RetentionLabel) Retention = fValue;
    if (sliderName == RotationVelocityLabel) RotationVelocity = fValue;
    if (sliderName == SpinVelocityLabel) SpinVelocity = fValue;
    if (sliderName == SkewSineLabel) SkewSine = fValue;
    if (sliderName == SkewCosineLabel) SkewCosine = fValue;
    if (sliderName == ColorVelocityLabel) ColorVelocity = fValue;
  }

  void restart() {
    // the background color: 0-255 for red, green, and blue 
    BackgroundColor = color(0);
  }

  // This gets called to make a frame. Time goes from 0.0 to 1.0 (well, 0.9999999...)
  void render(float time) {
    // Set the background color. For sculpture output this identifies the "outside" color.
    // Note that you can also draw with this color to "carve" out elements from an animation.
    background(BackgroundColor);
    colorMode( HSB, 360, 100, 100, 100 );
    // stroke doesn't 3D print well
    //stroke(0);
    noStroke();

    translate(Awidth/2., Aheight/2.);
    scale( Scale, Scale );

    int count = (int)(time * Duration);
    int startTime = (int)(count - (1.-time) * Duration * Retention);
    if ( startTime < 0 )
      startTime = 0;
    for ( int newTime = startTime; newTime < count; newTime++ )
    {
      pushMatrix();
      rotate(newTime / RotationVelocity);
      translate( Awidth * 150/600, 0);
      rotate(newTime / SpinVelocity);
      scale( (Awidth / 500.) * sin(newTime / SkewSine) + 0.2, (Awidth / 500.) * cos(newTime / SkewCosine) + 0.2);
      float factor = (Awidth / 500.) * sin(newTime / 1000.0);
      scale( factor, factor);
      fill(((newTime * ColorVelocity) % 360), 50, 100, 20);
      SliceColor = color(((newTime * ColorVelocity) % 360), 50, 100);
      ellipse(0, 0, 300, 300);
      popMatrix();
    }
  }
}

// ================= GIF reader

/* 
Warning! This animator breaks many of the conventions of the system. In particular,
it over-writes system variables that are set by the sliders, without updating the
sliders to reflect that. This is really just a hack to provide a back-door into 
the program, to enable you to create 3D models from GIF files. The name of the file
is embedded in the constructor (it should be in the UI, but again, this is a
non-standard Animator, and really just a hack).

Also BE WARNED: there seems to be little agreement on the file structure for
animationed GIFs. Many GIFs that seem to play fine on browsers are, in fact, 
messed up internally. The GIF decoder provided in the gifAnimation library seems
to be a little more attentive to the file structure than some browsers, with the
result that frames can end up having all kinds of unplesant artifacts. I don't
know how to correct for that; I consider such GIFs as just inaccessible for now.

Another caveat: The rest of the program uses the FrameSize and NumFrames 
sliders to determine the size and length of the animation. But of course
animated gifs have their own built-in values for these numbers. The program
will respect the sliders, not the values in the file. So for best results, set
your FrameSize and NumFrames sliders to match the values from the file. Don't
sweat it if you can't dial these in exactly; within a few frames or pixels is
usually fine. I print out the file's values to help you set these properly.
*/

class AnimatedGifReader extends Animator {
  
  String gifFileName = "inputGifs/looij01.gif"; 
  PImage[] gifFrames; 
  color gifBackgroundColor; 
  int gifNumFrames, gifWidth, gifHeight;
  
   AnimatedGifReader() {
      super("Animated Gif Reader");
   }

   void sliderChanged(String sliderName, int iValue, float fValue) {
     // no sliders
   }
   
   void rebuild() {    
      gifFrames = Gif.getPImages(ThisApplet, gifFileName);
      assert gifFrames != null : "Gif input failed, no file found"; 
      assert gifFrames.length > 0 : "Gif input failed, no frames found"; 
      assert gifFrames[0].width > 0 : "Gif input failed, image width = 0"; 
      assert gifFrames[0].height > 0 : "Gif input failed, image height = 0"; 
      gifFrames[0].loadPixels();
      gifBackgroundColor = gifFrames[0].pixels[0]; // Background color is upper-left pixel
      BackgroundColor = gifBackgroundColor;
      gifNumFrames = gifFrames.length;
      gifWidth = gifFrames[0].width;
      gifHeight = gifFrames[0].height;
      println("I read in animated gif "+gifFileName+" with "+gifNumFrames+" images, size "+gifWidth+" by "+gifHeight);
   }

   void restart() {
      BackgroundColor = gifBackgroundColor;
      ModelColor = color(128);
      if (gifNumFrames != AnumFrames) {
        String warning = "The gif contains "+gifNumFrames+" frames but your Number of Frame slider is set to "+AnumFrames+". See message on console for details.";
        reportWarning("AnimatedGifReader restart", warning);
        println("  Your input gif contains "+gifNumFrames+" frames, but your Number of Frame slider is set to "+AnumFrames+".");
        println("  This means we'll treat your gif as though it was "+AnumFrames+" frames long.");
        println("  It would be a good idea to set the Number of Frames slider to "+gifNumFrames+" and run again.");
      }      
      if ((Awidth != gifWidth) || (Aheight != gifHeight)) {
        String warning = "The gif has resolution width="+gifWidth+" by height="+gifHeight+", but your image size is a square of size "+Awidth+". See message on console for details.";
        reportWarning("AnimatedGifReader restart", warning);
        println("  Your input gif has resolution width="+gifWidth+" by height="+gifHeight+", but your Frame Size slider is set to "+Awidth+".");
        println("  This means we'll draw your gif into the upper-left of the graphics window, and then use the contents of a square of size "+Awidth+" in the upper left.");
        println("  It would be a good idea to set the Frame Size slider to "+gifWidth+" and run again.");
        if (gifWidth != gifHeight) {
          println("  We realize your gif animation isn't a square, so use the larger of the two dimensions and ignore this warning");
        }
      }      
   }

   void render(float time) {
      BackgroundColor = gifBackgroundColor;  
      background(BackgroundColor);
      image(gifFrames[AframeCount % gifNumFrames], 0, 0);
  }
}

// ================= Folder Of FramesReader

/* 
Warning! This code breaks many of the conventions of the system. In particular,
it over-writes system variables that are set by the sliders, without updating the
sliders to reflect that. This is really just a hack to provide a back-door into 
the program, to enable you to create 3D models from folders of image files. The 
name of the folder is embedded in the constructor (it should be in the UI, but 
again, this is a non-standard Animator, and really just a hack).

Another caveat: The rest of the program uses the FrameSize and NumFrames 
sliders to determine the size and length of the animation. But of course
these folders, and the images inside them, have their own built-in values for 
these numbers. The program will respect the sliders. So for best results, set
your FrameSize and NumFrames sliders to match the values that get printed
out for you when you read in the folder. As with the animated gif reader
above, don't worry about setting the sliders to exactly these values;
getting within a few frames or pixels is usually just fine.
*/


class FolderOfFramesReader extends Animator {
  
  ArrayList<String> fileNames;
  String folderPath; 
  color fileBackgroundColor; 
  int fileNumFrames, fileWidth, fileHeight;
  
   FolderOfFramesReader() {
      super("Folder Of Frames Reader");
      folderPath = SketchPath+"inputFrames/ag0085-pngFrames";
      File f = new File(folderPath);
      assert f != null : "FolderOfFramesReader could not open folder "+folderPath;
      fileNames = new ArrayList<String>(Arrays.asList(f.list()));
      assert fileNames != null : "FolderOfFramesReader found no input files";
      fileNumFrames = fileNames.size();
      PImage img = loadImage(folderPath+"/"+fileNames.get(0));
      img.loadPixels();
      fileBackgroundColor = img.pixels[0]; // Background color is upper-left pixel
      BackgroundColor = fileBackgroundColor;
      fileWidth = img.width;
      fileHeight = img.height;
      println("I read in folder "+folderPath);
      println("Inside, I found "+fileNumFrames+" images, size "+fileWidth+" by "+fileWidth);

   }

   void sliderChanged(String sliderName, int iValue, float fValue) {
     // no sliders
   }
   
   void rebuild() {         
   }

   void restart() {
      BackgroundColor = fileBackgroundColor;      
      ModelColor = color(128);
      if (fileNumFrames != AnumFrames) {
        String warning = "The folder contains "+fileNumFrames+" frames but your Number of Frame slider is set to "+AnumFrames+". See message on console for details.";
        reportWarning("FolderOfFramesReader restart", warning);
        println("  Your input gif contains "+fileNumFrames+" frames, but your Number of Frame slider is set to "+AnumFrames+".");
        println("  This means we'll treat your gif as though it was "+AnumFrames+" frames long.");
        println("  It would be a good idea to set the Number of Frames slider to "+fileNumFrames+" and run again.");
      }      
      if ((Awidth != fileWidth) || (Aheight != fileHeight)) {
        String warning = "The gif has resolution width="+fileWidth+" by height="+fileHeight+", but your image size is a square of size "+Awidth+". See message on console for details.";
        reportWarning("FolderOfFramesReader restart", warning);
        println("  Your input gif has resolution width="+fileWidth+" by height="+fileHeight+", but your Frame Size slider is set to "+Awidth+".");
        println("  This means we'll draw your gif into the upper-left of the graphics window, and then use the contents of a square of size "+Awidth+" in the upper left.");
        println("  It would be a good idea to set the Frame Size slider to "+fileHeight+" and run again.");
        if (fileWidth != fileHeight) {
          println("  We realize your gif animation isn't a square, so use the larger of the two dimensions and ignore this warning");
        }
      }      
   }

   void render(float time) {
      BackgroundColor = fileBackgroundColor;  
      background(BackgroundColor);
      PImage img = loadImage(folderPath+"/"+fileNames.get(AframeCount % fileNames.size()));
      image(img, 0, 0);
  }
}

// ================= HeightField

/*
Warning!
This animation is a total hack, and should not be used as a basis for anything else! 
We read in just one image at the given path, and build a height field from that. 
It's your responsibility to set the number of frames to 256 (or more), or your 
sculpture may appear to be missing some off the top.
*/

class HeightField extends Animator {

  ArrayList<String> fileNames;
  AUField heightField;
  PImage outputImg;

   HeightField() {
      super("Height Field");
      String folderPath = SketchPath+"heightFields/heights001.png";
      File f = new File(folderPath);
      assert f != null : "FolderOfFramesReader could not open folder "+folderPath;
      PImage inputImg = loadImage(folderPath);
      heightField = new AUField(ThisApplet, inputImg.width, inputImg.height);
      heightField.fromPixels(AUField.FIELD_LUM, inputImg);
      outputImg = createImage(heightField.w, heightField.h, RGB);
      BackgroundColor = color(0);
   }

   void sliderChanged(String sliderName, int iValue, float fValue) {
     // no sliders
   }

   void rebuild() {
   }

   void restart() {
      BackgroundColor = color(0);
      ModelColor = color(255);
      if (256 > AnumFrames) {
        String warning = "Your Number of Frame slider is set to "+AnumFrames+", but it should be 256 or more. See message on console for details.";
        reportWarning("HeightField restart", warning);
        println("  Your Number of Frame slider is set to "+AnumFrames+".");
        println("  You should move this slider to 256 (larger than that is okay, too)");
      }
   }

   void render(float time) {
    outputImg.loadPixels();
    background(BackgroundColor);
    int tval = AframeCount;
      for (int y=0; y<heightField.h; y++) {
        for (int x=0; x<heightField.w; x++) {
          int index = (y * outputImg.width) + x;
          if (heightField.z[y][x] > tval) {
            outputImg.pixels[index] = color(255);
          } else {
            outputImg.pixels[index] = BackgroundColor;
          }
        }
      }
      outputImg.updatePixels();
      image(outputImg, 0, 0);
  }
}

