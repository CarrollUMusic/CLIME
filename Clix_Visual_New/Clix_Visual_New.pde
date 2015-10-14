import netP5.*;
import oscP5.*;

OscP5 oscP5;
final int port = 13033;
final boolean DEBUG = false;
final float VOLUME_THRESHOLD = 0.05;
final float ROTATION_SPEED = 0.002;
final float NODE_SIZE = 9;
final float EDGE_LENGTH = 35;
final float EDGE_STRENGTH = 0.2;
final float SPACER_STRENGTH = 1000;
final int maxParticles = 100;
final float EASE_AMT = 0.25;
ParticleSystem physics;
float centroidX = 0;
float centroidY = 0;
float easeRX, easeRY, easeRZ; // rotation smoothing

color playerColor[];
//  #7947ef, #f04869, #bdf048, #48f0ce
//};

int globalPNUM, globalASCII = 0;
boolean newNode = false;

// PROCESSING /////////////////////////////////////

int numPlayers = 0;
float particleSize[], particleGrowth[];
color particleFill[];
boolean boxParticle[];
int numParticles = 0;
int sign = -1;
boolean acceptingNewParticles = true;
float easeCX, easeCY, easeScale;

void setup()
{
  size( 640, 480, P3D );
  //fullScreen(P3D);
  smooth();
  playerColor = new color[256];
  for (int i=0; i<playerColor.length; i++)
  {
    playerColor[i] = color (i, 150, 200);
    println(playerColor[i]);
  }
  oscP5 = new OscP5(this, port);
  strokeWeight(1);
  ellipseMode( CENTER );
  strokeCap( ROUND );

  particleSize = new float[maxParticles];
  particleGrowth = new float[maxParticles];
  particleFill = new color[maxParticles];
  boxParticle = new boolean[maxParticles];
  for (int ii=0; ii<maxParticles; ii++)
  {
    particleSize[ii] = 0.1;
    particleGrowth[ii] = 0;
    particleFill[ii] = playerColor[0];
    boxParticle[ii] = false;
  }
  physics = new ParticleSystem( 0, 0.1 );
  //physics.setIntegrator( ParticleSystem.MODIFIED_EULER ); 
  physics.setDrag( 1.5 );

  initialize(1);

  easeCX = 0;
  easeCY = 0;
  easeScale = 20;
  easeRX = noise(0, 0);
  easeRY = noise(0, 1);
  easeRZ = noise(0, 2);
}

void draw()
{
  noLights();
  ambientLight(100, 100, 100);
  directionalLight(255, 255, 255, 0, 2, 0);
  physics.tick(); 
  if ( physics.numberOfParticles() > 1 )
    updateCentroid();
  background(0);
  translate( width/2, height/2, 0 );
  easeRX += (noise(frameCount*ROTATION_SPEED, 0)-0.5)*ROTATION_SPEED;
  easeRY += (noise(frameCount*ROTATION_SPEED, 1)-0.5)*ROTATION_SPEED;
  easeRZ += (noise(frameCount*ROTATION_SPEED, 2)-0.5)*ROTATION_SPEED;
  rotateX (easeRX*TWO_PI);
  rotateY (easeRY*TWO_PI);
  rotateZ (easeRZ*TWO_PI);
  scale( easeScale );
  translate( -easeCX, -easeCY );
  drawNetwork();
  if (newNode)
  {
    newNode = false;
    addNode(globalPNUM, globalASCII, false);
  }
}

void drawNetwork()
{      
  // draw vertices
  noStroke();
  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle v = physics.getParticle( i );
    float radius = NODE_SIZE * sqrt(particleSize[i]) * (3 + (numParticles*2.0/maxParticles)) * particleGrowth[i];
    fill(particleFill[i]);
    pushMatrix();
    translate( v.position.x, v.position.y, v.position.z );
    if (boxParticle[i]) box(radius, radius, radius);
    else sphere(radius/3);
    popMatrix();
  }

  // draw edges
  stroke(255);
  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Spring e = physics.getSpring( i );
    Particle a = e.getOneEnd();
    Particle b = e.getTheOtherEnd();
    line( a.position.x, a.position.y, a.position.z, b.position.x, b.position.y, b.position.z);
  }
}

void mousePressed()
{
  if (mouseButton==LEFT)
    addNode(int(random(4)), (int)random(256), true);
  else if (mouseButton==RIGHT)
    addNode(int(random(4)), (int)random(256), false);
}

void mouseDragged()
{
  if (mouseButton==LEFT)
    addNode(int(random(4)), (int)random(256), true);
  else if (mouseButton==RIGHT)
    addNode(int(random(4)), (int)random(256), false);
}

void keyPressed()
{
  if (key == 'x')
  {
    saveFrame();
  }
  if ( key == 'c' )
  {
    initialize(1);
    addNode(1, 1, false);
    addNode(2, 1, false);
    addNode(3, 1, false);
  }

  if ( key == ' ' )
  {
    addNode((int)random(256), (int)random(256), true);
    return;
  }
}

// ME ////////////////////////////////////////////

void updateCentroid()
{
  float 
    xMax = Float.NEGATIVE_INFINITY, 
    xMin = Float.POSITIVE_INFINITY, 
    yMin = Float.POSITIVE_INFINITY, 
    yMax = Float.NEGATIVE_INFINITY;

  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle p = physics.getParticle( i );
    xMax = max( xMax, p.position.x );
    xMin = min( xMin, p.position.x );
    yMin = min( yMin, p.position.y );
    yMax = max( yMax, p.position.y );
    particleGrowth[i] += (1-particleGrowth[i])*EASE_AMT;
  }
  float deltaX = xMax-xMin;
  float deltaY = yMax-yMin;

  centroidX = xMin + 0.5*deltaX;
  centroidY = yMin +0.5*deltaY;
  easeCX += (centroidX - easeCX) * EASE_AMT;
  easeCY += (centroidY - easeCY) * EASE_AMT;
  easeScale += ((.5*width/max(deltaX, deltaY))-easeScale)*EASE_AMT;
}

void addSpacersToNode( Particle p, Particle r )
{
  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle q = physics.getParticle( i );
    if ( p != q && p != r )
      physics.makeAttraction( p, q, -SPACER_STRENGTH, 20 );
  }
}

void makeEdgeBetween( Particle a, Particle b )
{
  physics.makeSpring( a, b, EDGE_STRENGTH, EDGE_STRENGTH, EDGE_LENGTH );
}

void initialize(float c)
{
  sign *= -1;
  physics.clear();
  numParticles = 0;
  acceptingNewParticles = true;
  physics.makeParticle();
  particleSize[0] = c;
}

void addNode(int pnum, int ascii, boolean addp)
{ 
  float psize = ascii/255.0;
  numParticles++;
  particleSize[numParticles%maxParticles] = psize;
  particleGrowth[numParticles%maxParticles] = 0;
  boxParticle[numParticles%maxParticles] = (ascii<91);
  particleFill[numParticles%maxParticles] = playerColor[pnum];
  while (physics.numberOfParticles () > maxParticles-1) killParticle();


  if (numParticles < maxParticles)
  {
    Particle p = physics.makeParticle();
    Particle q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    while ( q == p )
      q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    addSpacersToNode( p, q );
    makeEdgeBetween( p, q );
    p.position.set( q.position.x + random( -1, 1 ), q.position.y + random( -1, 1 ), q.position.z + random(-1, 1) );
  }

  if (numParticles >=maxParticles || (!addp && numParticles >3))
  {
    for (int zzz = 0; zzz<1; zzz++)
    {
      Particle pp = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
      for (int ii=0; ii<physics.numberOfSprings (); ii++)
      {
        Spring testSpring = physics.getSpring( ii );
        if ( (pp == testSpring.getOneEnd()) )
        {
          physics.removeSpring(ii);
          ii = physics.numberOfSprings();
        }
      }
      Particle qq = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
      while ( qq == pp )
        qq = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
      addSpacersToNode( pp, qq );
      makeEdgeBetween( pp, qq );
    }
  }
}

void killParticle()
{
  Particle doomed = physics.getParticle( (int) random ( 0, physics.numberOfParticles()-1) );
  for (int ii=0; ii<physics.numberOfSprings (); ii++)
  {
    Spring testSpring = physics.getSpring( ii );
    if ( (doomed == testSpring.getOneEnd()) || (doomed == testSpring.getTheOtherEnd()) )
    {
      physics.removeSpring(ii);
    }
  }
  physics.removeParticle (doomed);
}

void oscEvent (OscMessage clixMessage)
{
  if (clixMessage.checkAddrPattern("/clix"))
  {
    String IP = clixMessage.netAddress().address();
    int pnum = int (split(IP, '.')[3]);
    int ascii = (int)clixMessage.get(0).floatValue();
    //println("IP: "+IP+", pnum: "+pnum+", ascii: "+ascii);
    if (ascii==27)
      initialize(1);
    else
    {
      // OSC messages come asyncronously, so we add particles globally in the draw routine to prevent nutso array overruns.
      globalPNUM = pnum;
      globalASCII = ascii;
      newNode = true;
    }
  }
}