import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 
import java.awt.event.KeyEvent; 
import hypermedia.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CLIMEchat extends PApplet {





UDP udp;
Client chatClient;

//PFont font;
String[] lines;
String currentMessage = "";
String lastMessage = "";
String nextMessage = "";
String remainder = "";
String name = "";
boolean nameEntered = false;
boolean connected = false;
String serverIP = null;

public void setup()
{
  size(400, 200);
  smooth();
  udp = new UDP(this,13035);
  udp.listen(true);
  udp.log(true);
  //chatClient = new Client (this, "matthys-mpc", 13032);
  //font = createFont("sans_serif", 60, true);
  noStroke();
  fill(255, 255, 0);
  frameRate(10);
  lines = new String[9];
  for (int i=0; i<lines.length; i++) lines[i]="";
}

public void draw()
{
  background(0, 0, 64);
  if (!connected && serverIP != null)
  {
    chatClient = new Client (this, serverIP, 13032);
    connected = true;
  }
    
  if (nameEntered)
  {
    textAlign(LEFT);
    textSize(16);
    stroke(128);
    line(0, height-30, width, height-30);
    noStroke();
    fill(255, 255, 0);
    text("> "+currentMessage+"|"+remainder, 10, height-10);
    for (int i=0; i<lines.length; i++)
    {
      float redness = map(i, 0, lines.length, 0, 255);
      float y = map(i, 0, lines.length, 15, height-20);
      fill(redness, 255, 0);
      text(lines[i], 5, y);
    }
  } else
  {
    stroke(255);
    fill(0);
    rect(width/6, height/3, width*2/3, height/3);
    textAlign(CENTER);
    noStroke();
    textSize(18);
    fill(255, 255, 0);
    text("Enter your name:", width/2, (height/2)-8);
    fill(255);
    text(currentMessage+"|"+remainder, width/2, height/2+15);
  }
  if (connected && chatClient.available() > 0)
  {
    addToList(chatClient.readString());
  }
}

public void keyPressed()
{
  if (key==CODED && keyCode == KeyEvent.VK_HOME)
  {
    chatClient = new Client (this, serverIP, 13032);
    addToList ("***ATTEMPTING TO RECONNECT TO SERVER***");
  }
  if (key==ENTER || key==RETURN)
  {
    if (nameEntered)
    {
      String msg = name+": "+currentMessage+remainder;
      if (connected) chatClient.write(msg);
      lastMessage = currentMessage;
      currentMessage = "";
      remainder = "";
    } else
    {
      name = currentMessage;
      currentMessage = "";
      remainder = "";
      nameEntered = true;
    }
  } else if (keyCode==BACKSPACE)
  {
    currentMessage = currentMessage.substring(0, (int)max(currentMessage.length()-1, 0));
  } else if (keyCode==UP)
  {
    nextMessage = currentMessage;
    currentMessage=lastMessage;
  } else if (keyCode==DOWN)
  {
    lastMessage = currentMessage;
    currentMessage = nextMessage;
  } else if (keyCode==LEFT && currentMessage.length()>0)
  {
    remainder = currentMessage.substring((int)currentMessage.length()-1) + remainder;
    currentMessage = currentMessage.substring(0, currentMessage.length()-1);
  } else if (keyCode==RIGHT && remainder.length()>0)
  {
    currentMessage = currentMessage + remainder.substring(0, 1);
    remainder = remainder.substring(1, remainder.length());
  } else if (keyCode==DELETE)
  {
    nameEntered=false;
  } else if (key==CODED)
  {
    // do nothing
  } else
  {
    currentMessage+= key;
  }
  if (textWidth(name+": "+currentMessage)>width-15)
  {
    String msg = name+": "+currentMessage;
    if (connected) chatClient.write(msg);
    lastMessage = currentMessage;
    currentMessage = "";
  }
}

public void addToList (String msg)
{
  int i;
  for (i=0; i<lines.length-1; i++)
  {
    lines[i] = lines[i+1];
  }
  lines[i] = msg;
}

public void receive( byte[] data, String ip, int port )
{
  serverIP = ip;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CLIMEchat" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
