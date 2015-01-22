import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 
import hypermedia.net.*; 
import java.net.Inet4Address; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CLIMEchat_server extends PApplet {





Server chatServer;
Server pdServer;
UDP chatBroadcast, pdBroadcast;
String myip;

public void setup()
{
  size(300, 150);
  chatServer = new Server (this, 13032);
  pdServer = new Server (this, 13033);
  pdBroadcast = new UDP(this, 13036);
  chatBroadcast = new UDP(this, 13037);
  pdBroadcast.listen(false);
  chatBroadcast.listen(false);
  myip = pdBroadcast.address();
  try {
    myip=java.net.InetAddress.getLocalHost().getHostAddress()+";\n";
  } 
  catch(Exception e)
  {
  }
  if (myip==null || myip.equals("127.0.1.1;\n") || myip.equals("127.0.0.1;\n"))
  {
    String[] lines = loadStrings(System.getProperty("user.home")+"/.myip");
    String[] temp_ips = split(lines[0], ' ');
    myip = temp_ips[0]+";\n";
  }
  println(myip);
  textAlign(CENTER);
  noStroke();
}

public void draw()
{
  background(0);
  fill(255);
  text("CLIME Chat Server", width/2, height/2);
  text("running", width/2, height/2 + 20);
  Client thisClient = chatServer.available();
  if (thisClient != null)
  {
    if (thisClient.available() > 0)
    {
      fill(255, 0, 0);
      ellipse(width-30, height-30, 20, 20);
      String chatMsg = thisClient.readString();
      //println("message from: " + thisClient.ip() + " : " + chatMsg);
      chatServer.write(chatMsg);
    }
  }
  thisClient = pdServer.available();
  if (thisClient != null)
  {
    if (thisClient.available() > 0)
    {
      fill(0, 255, 0);
      ellipse(65, height-30, 20, 20);
      String pdMsg = thisClient.readString();
      //println("PD message from: " + thisClient.ip() + " : " + pdMsg);
      pdServer.write(pdMsg);
    }
  }

  if (frameCount%600==0)
  {
    pdBroadcast.send(myip, "255.255.255.255", 13034);
    chatBroadcast.send(myip, "255.255.255.255", 13035);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CLIMEchat_server" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
