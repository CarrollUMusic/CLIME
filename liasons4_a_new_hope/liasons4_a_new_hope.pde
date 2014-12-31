import oscP5.*;
import netP5.*;

final boolean DEBUG = false;
final float VOLUME_THRESHOLD = 0.05;
final float ROTATION_SPEED = 0.002;
final float NODE_SIZE = 10;
final float EDGE_LENGTH = 25;
final float EDGE_STRENGTH = 0.2;
final float SPACER_STRENGTH = 1000;
final int maxParticles = 300;
final float EASE_AMT = 0.05;
ParticleSystem physics;
float centroidX = 0;
float centroidY = 0;
float easeRX, easeRY, easeRZ; // rotation smoothing

final color playerColor[] = {
  #7947ef, #f04869, #bdf048, #48f0ce
};

boolean invert = true;
boolean render3D = true;

// PROCESSING /////////////////////////////////////

int numPlayers = 4;
float particleSize[], particleGrowth[];
color particleFill[];
boolean boxParticle[];
int numParticles = 0;
int sign = -1;
boolean acceptingNewParticles = true;
EasyOSC osc;
float easeCX, easeCY, easeScale;

void setup()
{
  if (render3D)
    size( displayWidth, displayHeight, P3D );
  else
    size( displayWidth, displayHeight, P2D );
  smooth();
  if (render3D) strokeWeight(1);
  else strokeWeight( 2 );
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

  osc = new EasyOSC();
  osc.setListener("127.0.0.1", 12001);
  osc.setListenerTag("/liasons");

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
  ambientLight(100,100,100);
  directionalLight(255,255,255, 0, 2, 0);
  physics.tick(); 
  if ( physics.numberOfParticles() > 1 )
    updateCentroid();
  if (invert) background(0);
  else background(255);
  //text( "" + physics.numberOfParticles() + " PARTICLES\n" + (int)frameRate + " FPS", 10, 20 );
  if (render3D)
    translate( width/2, height/2, 0 );
  else
    translate( width/2, height/2 );
  if (!render3D) rotate(sqrt(frameCount*numParticles/10000.0)*sign);
  else
  {
    easeRX += (noise(frameCount*ROTATION_SPEED, 0)-0.5)*ROTATION_SPEED;
    easeRY += (noise(frameCount*ROTATION_SPEED, 1)-0.5)*ROTATION_SPEED;
    easeRZ += (noise(frameCount*ROTATION_SPEED, 2)-0.5)*ROTATION_SPEED;
    rotateX (easeRX*TWO_PI);
    rotateY (easeRY*TWO_PI);
    rotateZ (easeRZ*TWO_PI);
  }
  scale( easeScale );
  translate( -easeCX, -easeCY );
  drawNetwork();

  if (osc.incoming())
  {
    int a = osc.getPlayerNum();
    int b = osc.getPitchNum();
    float c = osc.getLoudness();
    if (DEBUG && c >= VOLUME_THRESHOLD)
    {
      if (a > numPlayers) a=0;
      println("player: "+a+" pitch: "+b+" loudness: "+c);
      b=b%12;
      switch (b)
      {
      case 0:
        initialize(c);
        //addNode(0, 1, false);
        //addNode(1, c, false);
        addNode(2, c, false);
        addNode(3, c, false);
        break;
      case 2:
      case 4:
      case 5:
      case 7:
      case 9:
      case 11:
        addNode(a, c, false);
        break;
      default:
        addNode(a, c, true);
        break;
      }
    }
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
    if (render3D)
    {
      pushMatrix();
      translate( v.position.x, v.position.y, v.position.z );
      if (boxParticle[i]) box(radius/3, radius/3, radius/3);
      else sphere(radius/3);
      popMatrix();
    } else ellipse( v.position.x, v.position.y, radius, radius );
  }

  // draw edges
  if (invert) stroke(255);
  else stroke(0);
  beginShape( LINES );
  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Spring e = physics.getSpring( i );
    Particle a = e.getOneEnd();
    Particle b = e.getTheOtherEnd();
    if (render3D)
    {
      vertex( a.position.x, a.position.y, a.position.z);
      vertex( b.position.x, b.position.y, b.position.z);
    } else
    {
      vertex( a.position.x, a.position.y);
      vertex( b.position.x, b.position.y);
    }
  }
  endShape();
}

void mousePressed()
{
  if (mouseButton==LEFT)
    addNode(int(random(4)), random(0, 1.0), true);
  else if (mouseButton==RIGHT)
    addNode(int(random(4)), random(0, 1.0), false);
}

void mouseDragged()
{
  if (mouseButton==LEFT)
    addNode(int(random(4)), random(0, 1.0), true);
  else if (mouseButton==RIGHT)
    addNode(int(random(4)), random(0, 1.0), false);
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
    addNode(int(random(4)), random(0, 1.0), true);
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

void addNode(int pnum, float psize, boolean addp)
{ 
  numParticles++;
  particleSize[numParticles%maxParticles] = psize;
  particleGrowth[numParticles%maxParticles] = 0;
  boxParticle[numParticles%maxParticles] = (pnum%2==0);
  particleFill[numParticles%maxParticles] = playerColor[int(random(4))];
  while (physics.numberOfParticles () > maxParticles-1) killParticle();


  if (numParticles < maxParticles)
  {
    Particle p = physics.makeParticle();
    Particle q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    while ( q == p )
      q = physics.getParticle( (int)random( 0, physics.numberOfParticles()-1) );
    addSpacersToNode( p, q );
    makeEdgeBetween( p, q );
    if (render3D)
      p.position.set( q.position.x + random( -1, 1 ), q.position.y + random( -1, 1 ), q.position.z + random(-1, 1) );
    else
      p.position.set( q.position.x + random( -1, 1 ), q.position.y + random( -1, 1 ), 0 );
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
  /*
  else if (physics.numberOfSprings()>0)
   {
   int die = (int) random(0,physics.numberOfSprings());
   physics.removeSpring(die);
   }
   else if (physics.numberOfParticles()>0)
   killParticle();
   */
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
