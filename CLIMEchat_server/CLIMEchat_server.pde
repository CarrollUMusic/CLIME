import processing.net.*;
import hypermedia.net.*;
import java.net.Inet4Address;
import java.io.*;

Server chatServer;
Server pdServer;
UDP chatBroadcast, pdBroadcast;
String myip;
int broadcastCue = 0;

void setup()
{
  size(300, 150);
  chatServer = new Server (this, 13032);
  pdServer = new Server (this, 13033);
  pdBroadcast = new UDP(this, 13036);
  chatBroadcast = new UDP(this, 13037);
  pdBroadcast.listen(false);
  chatBroadcast.listen(false);
  myip = pdBroadcast.address();
  if (match("Linux", System.getProperty("os.name")) != null)
  {
    try
    {
      ProcessBuilder pb = new ProcessBuilder("sh", dataPath("hostname.sh"));
      Process p = pb.start();
      InputStream is = p.getInputStream();
      BufferedReader br = new BufferedReader(new InputStreamReader(is));
      String line = null;
      while ((line = br.readLine()) != null)
      {
        myip = split(line,' ')[0]+";\n";
      }
      int r = p.waitFor();
    } 
    catch (Exception e)
    {
      e.printStackTrace();
    }
  } else
  {
    try {
      myip=java.net.InetAddress.getLocalHost().getHostAddress()+";\n";
    } 
    catch(Exception e)
    {
      e.printStackTrace();
    }
  }
  println(myip);
  textAlign(CENTER);
  noStroke();
  frameRate(1000);
}

void draw()
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

  if (millis()/5000 > broadcastCue)
  {
    broadcastCue++;
    println(myip);
    pdBroadcast.send(myip, "255.255.255.255", 13034);
    chatBroadcast.send(myip, "255.255.255.255", 13035);
  }
}