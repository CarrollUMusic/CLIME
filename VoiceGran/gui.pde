void createGui()
{
  gui.addSlider("mastervol")
    .setLabel("Vol")
    .setPosition(0, 0)
    .setSize(20, height)
    .setRange(0, 100)
    .setValue(75)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.BOTTOM)
    ;
    
    gui.getController("mastervol")
    .getValueLabel()
    .hide()
    ;

  Group g1 = gui.addGroup("Controls")
    .setLabel("Controls - Click to open")
    .setPosition(20, 15)
    .setBarHeight(15)
    .setBackgroundHeight(170)
    .setBackgroundColor(color(100))
    .setWidth(width-20)
    .close()
    ;

  g1.getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addBang ("loadbang")
    .setLabel("Load audio file")
    .setPosition(10, 10)
    .setSize(width-40, 30)
    .setGroup(g1)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER)
    ;

  gui.addSlider("pitchslider")
    .setLabel("Pitch smoothing")
    .setPosition(10, 65)
    .setSize(width-40, 15)
    .setGroup(g1)
    .setRange(0.1, 10)
    .setValue(0.276)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER)
    ;

  gui.addSlider("timeslider")
    .setLabel("Time smoothing")
    .setPosition(10, 90)
    .setSize(width-40, 15)
    .setGroup(g1)
    .setRange(0.1, 10)
    .setValue(1.411)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER)
    ;

  gui.addSlider("grainwidth")
    .setLabel("Grain width")
    .setPosition(10, 115)
    .setSize(width-40, 15)
    .setGroup(g1)
    .setRange(30.0, 800)
    .setValue(450)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER)
    ;

  gui.addSlider("graintime")
    .setLabel("Grain time")
    .setPosition(10, 140)
    .setSize(width-40, 15)
    .setGroup(g1)
    .setRange(5, 150)
    .setValue(150)
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER)
    ;
}

public void mastervol (float val)
{
  pd.sendFloat("mastervol", val);
}

public void pitchslider (float val)
{
  pd.sendFloat("pitch-smoothing", val);
}

public void timeslider (float val)
{
  pd.sendFloat("time-smoothing", val);
}

public void grainwidth (float val)
{
  pd.sendFloat("grain-width", val);
}

public void graintime (float val)
{
  pd.sendFloat("grain-time", val);
}

public void loadbang ()
{
  selectInput("Select an uncompressed audio file.", "loadCallback");
}