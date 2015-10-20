import org.puredata.processing.*;

PureData pd;
color bg = color(0, 0, 255);
float x, y;
int vol = 100;
int showText = 0;

void setup()
{
  fullScreen();
  pd = new PureData(this, 44100, 0, 2);
  pd.openPatch("colordrone.pd");
  pd.start();
  x=0;
  y=0;
}

void draw()
{
  background(bg);
  if (frameCount < showText) text("Vol: "+vol, 10, 20);
}

void mouseDragged()
{
  x = map(mouseX, 0, width, 0, 1);
  y = map(mouseY, height, 0, 0, 1);
  bg = color(255 * y, 0, 255 * ( 1 - y ));
  pd.sendFloat("mod1",y);
  pd.sendFloat("mod2",x*0.5 + 0.5);
}

void keyPressed()
{
  switch (keyCode)  
  {
  case UP:
    vol += 2;
  case DOWN:
    vol -= 1;
    if (vol > 100) vol = 100;
    if (vol < 0) vol = 0;
    showText = frameCount + 60;
    pd.sendFloat("vol", vol);
  }
}