import netP5.*;
import oscP5.*;
import controlP5.*;
import org.puredata.processing.PureData;

PureData pd;
ControlP5 gui;
OscP5 oscP5;

void setup() {
  size (640, 480);
  surface.setResizable(true);
  oscP5 = new OscP5 (this, 12000);
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
}

void mouseMoved()
{
  if (mouseX>20)
  {
    pd.sendFloat("time", map(mouseX, 20, width, 0, 1)); // Send float message to symbol "pitch" in Pd.
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
  println(s);
}

void receiveFloat(String source, float x) {
  println("source: "+source+" | value: "+x);
}

// Listen for OSC messages on port 12000. Messages should be sent
// to address /gran and be two floats in the range 0-1.
void oscEvent (OscMessage msg)
{
  if (msg.checkAddrPattern("/gran"))
  {
    if (msg.checkTypetag("ff"))
    {
      float timeValue = msg.get(0).floatValue();
      float pitchValue = msg.get(1).floatValue();
      mouseX = (int)map(timeValue,0,1,20,width);
      mouseY = (int)map(pitchValue,1,0,15,height);
      pd.sendFloat("time", timeValue); // Send float message to symbol "pitch" in Pd.
      pd.sendFloat("pitch", 10 + (45*pitchValue));
    }
  }
}