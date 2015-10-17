import controlP5.*;

/**
 * A sample Processing applet using libpd, illustrating all major features.
 * 
 * Based on RJ Marsan's YayProcessingPD (https://github.com/rjmarsan/YayProcessingPD).
 * 
 * @author Peter Brinkmann (peter.brinkmann@gmail.com)
 */

import org.puredata.processing.PureData;

PureData pd;
ControlP5 gui;

void setup() {
  size (640, 480);
  gui = new ControlP5(this);
  pd = new PureData(this, 44100, 0, 2);
  pd.openPatch("voicegran.pd");
  pd.start();
  createGui();
}

void draw() {
  background(255);
  fill(200, 0, 0);
  stroke(255, 0, 0);
  ellipseMode(CENTER);
  ellipse(mouseX, mouseY, 20, 20);
  if (mouseX>20)
  {
    pd.sendFloat("time", map(mouseX,20,width,0,1)); // Send float message to symbol "pitch" in Pd.
    pd.sendFloat("pitch", map(mouseY, height, 15, 10, 55));
  }
}

void keyPressed()
{
  if (key=='l')
  {
    selectInput("Select an uncompressed audio file.", "loadCallback");
  }
}

void loadCallback (File selection)
{
  if (selection != null)
  {
    pd.sendSymbol("filename", selection.getAbsolutePath());
  }
}

void pdPrint(String s) {
  // Handle string s, printed by Pd
  println(s);
}

void receiveFloat(String source, float x) {
  println("source: "+source+" | value: "+x);
  // Handle float x sent to symbol source in Pd
}