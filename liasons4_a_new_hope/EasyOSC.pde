class EasyOSC
{
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  String rcvIP = "127.0.0.1";
  int rcvPort = 12000;
  String sendIP = "127.0.0.1";
  int sendPort = 6449;
  String sendTag = "/pd";
  String rcvTag = "/proc";
  int playerNum = 0;
  int pitchNum = 0;
  float loudness = 0;
  boolean msgRcvd = false;

  EasyOSC()
  {
    connect();
  }

  EasyOSC(int rp)
  {
    rcvPort = rp;
    connect();
  }

  EasyOSC(String rip, int rp)
  {
    rcvIP = rip;
    rcvPort = rp;
    connect();
  }

  private void connect()
  {
    oscP5 = new OscP5(this,rcvPort);
    myRemoteLocation = new NetAddress(sendIP,sendPort);
  }

  void setListener(int p)
  {
    rcvPort = p;
    connect();
  }

  void setListener(String ip)
  {
    rcvIP = ip;
    connect();
  }

  void setListener(String ip, int p)
  {
    rcvIP = ip;
    rcvPort = p;
    connect();
  }

  void setListenerTag(String t)
  {
    rcvTag = t;
  }

  void setDestinationTag(String t)
  {
    sendTag = t;
  }

  void oscEvent(OscMessage theOscMessage)
  {
    //print("### received an osc message.");
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //println(" typetag: "+theOscMessage.typetag());
    if (theOscMessage.checkAddrPattern(rcvTag))
    {
      if (theOscMessage.checkTypetag("iif"))
      {
        playerNum = theOscMessage.get(0).intValue();
        pitchNum = theOscMessage.get(1).intValue();
        loudness = theOscMessage.get(2).floatValue();
      }
      else if (theOscMessage.checkTypetag("fff"))
      {
        playerNum = (int)theOscMessage.get(0).floatValue();
        pitchNum = (int)theOscMessage.get(1).floatValue();
        loudness = theOscMessage.get(2).floatValue();
      }
      msgRcvd = true;
    }
  }

  boolean incoming()
  {
    return msgRcvd;
  }

  int getPitchNum()
  {
    msgRcvd = false;
    return pitchNum;
  }

  int getPlayerNum()
  {
    msgRcvd = false;
    return playerNum;
  }
  
  float getLoudness()
  {
    msgRcvd = false;
    return loudness;
  }

  void setDestinationPort(int p)
  {
    sendPort = p;
    myRemoteLocation = new NetAddress(sendIP,sendPort);
  }

  void setDestinationIP (String ip)
  {
    sendIP = ip;
    myRemoteLocation = new NetAddress(sendIP,sendPort);
  }

  void send()
  {
    OscMessage myMessage = new OscMessage(sendTag);
    oscP5.send(myMessage, myRemoteLocation);
  }

  void send(int x)
  {
    OscMessage myMessage = new OscMessage(sendTag);
    myMessage.add(x);
    myMessage.add(0.0);
    oscP5.send(myMessage, myRemoteLocation);
  }

  void send(float y)
  {
    OscMessage myMessage = new OscMessage(sendTag);
    myMessage.add(0);
    myMessage.add(y);
    oscP5.send(myMessage, myRemoteLocation);
  }

  void send(int x, float y)
  {
    OscMessage myMessage = new OscMessage(sendTag);
    myMessage.add(x);
    myMessage.add(y);
    oscP5.send(myMessage, myRemoteLocation);
  }
}
