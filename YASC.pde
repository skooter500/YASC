// Uses the following Processing libraries:
// http://www.foobarquarium.de/blog/processing/MovingLetters/
// http://creativecomputing.cc/p5libs/procontroll/

import ddf.minim.*;
import procontroll.*;
import de.ilu.movingletters.*;

float timeDelta = 1.0f / 60.0f;
ArrayList<Ship> players = new ArrayList<Ship>();
ArrayList<BigStar> stars = new ArrayList<BigStar>();
ArrayList<PVector> spawnPoints = new ArrayList<PVector>();
ArrayList<PVector> hudPositions = new ArrayList<PVector>();

boolean[] keys = new boolean[526];
ArrayList<GameObject> children = new ArrayList<GameObject>();
ArrayList<ControllDevice> devices = new ArrayList<ControllDevice>();

int winnerIndex = 0;

color[] colours = {
  color(12, 245, 209)
  ,color(0, 255,0)
  ,color(255, 255,0)
  ,color(255, 192, 203)
};

int gameState = 0;
int numStars = 100;
float spawnInterval = 5.0f;

int CENTRED = -1;
boolean gameBegun;
ControllIO controll;

Minim minim;//audio context
AudioPlayer soundtrack;
AudioPlayer explosion;
AudioPlayer powerupSound;
MovingLetters[] letters = new MovingLetters[3];

boolean devMode = false;
 
boolean sketchFullScreen() {
  return ! devMode;
}

void addGameObject(GameObject o)
{
  children.add(o);
}


void setup()
{
  if (devMode)
  {
    size(800, 600);
  }
  else
  {
    size(displayWidth, displayHeight);
  }
  smooth();
  noCursor();
  
  for (font_size size:font_size.values())
  {
    letters[size.index] = new MovingLetters(this, size.size, 1, 0);
  }
 
  minim = new Minim(this);  
  controll = ControllIO.getInstance(this);
  
  spawnPoints.add(new PVector(50, 50));
  spawnPoints.add(new PVector(width - 50, height- 50));
  spawnPoints.add(new PVector(50, height - 50));
  spawnPoints.add(new PVector(width - 50, 50));
  
  hudPositions.add(new PVector(10, 10));
  hudPositions.add(new PVector(width - 480, height - 30));
  hudPositions.add(new PVector(10, height - 30));
  hudPositions.add(new PVector(width - 480, 10));
  
  explosion = minim.loadFile("Explosion4.wav");
  powerupSound = minim.loadFile("powerup.wav");
  soundtrack = minim.loadFile("soundtrack.mp3");  
}

void printText(String text, font_size size, int x, int y)
{
  if (x == CENTRED)
  {
    x = (width / 2) - (int) (size.size * (float) text.length() / 2.5f);
  }
  letters[size.index].text(text, x, y);  
}

void applyGravity()
{
  for (int i = 0 ; i < stars.size() ; i ++)
  {
    BigStar star = stars.get(i);
    for (int j = 0 ; j < children.size() ; j ++)
    {
      GameObject child = children.get(j);
      if (child instanceof Lazer || child instanceof Ship || child instanceof Powerup)
      {
        PVector toStar = PVector.sub(star.position, child.position);
        float dist = toStar.mag();
        toStar.normalize();
        PVector gravity = PVector.mult(toStar, (10000.0f / dist));
        child.force.add(gravity);
      }
    }
  }
}

void reset()
{
  children.clear();
  players.clear();
  devices.clear();
  gameBegun = false;
  
  BigStar star = new BigStar();
  children.add(star);
  
  stars.add(star);      
  for (int i = 0 ; i < 100 ; i ++)
  {
     children.add(new SmallStar());
  }
  soundtrack.setGain(14);
  playSound(soundtrack, true);
}

void splash()
{
  background(0);
  stroke(255);
  
  printText("YASC", font_size.large, CENTRED, 100);  
  printText("Yet Another Spacewar Clone", font_size.large, CENTRED, 200);  
  printText("Programmed by Bryan Duggan", font_size.large, CENTRED, 300);
  printText("Music by Paul Bloof", font_size.large, CENTRED, 400);
  if (frameCount / 60 % 2 == 0)
  {
    printText("Press SPACE to play", font_size.large, CENTRED, height - 100);  
  }
  if (checkKey(' '))
  {
    reset();
    gameState = 1;
  }
}

void gameOver()
{
  fill(255);
  stroke(255);
  
  printText("YASC", font_size.large, CENTRED, 100);  
  printText("Yet Another Spacewar Clone", font_size.large, CENTRED, 200);  
  printText("Game Over", font_size.large, CENTRED, 300);
  stroke(colours[winnerIndex]);
  if (frameCount / 60 % 2 == 0)
  {
    printText("Winner!", font_size.large, CENTRED, 400);
  }
  stroke(255);  
  printText("Press SPACE to play again", font_size.large, CENTRED, height - 100);  
  if (checkKey(' '))
  {
    reset();
    gameState = 1;
  }
}

void playSound(AudioPlayer sound)
{
  playSound(sound, false);
}

void playSound(AudioPlayer sound, boolean loop)
{
  if (sound == null)
  {
    return;
  }
  sound.setGain(14);
  if (!loop)
  {
    sound.rewind();
  }
  else
  {
    sound.loop();
    if (sound.isPlaying())
    {
      return;
    }
  }    
  
  sound.play(); 
}

void checkForNewControllers()
{
  // Add all the xbox controllers
  for(int i = 0; i < controll.getNumberOfDevices(); i++){
    ControllDevice device = controll.getDevice(i);
    if (device.getName().toUpperCase().indexOf("XBOX 360") != -1)
    {
      if (! devices.contains(device))
      {        
        if (device.getButton(7).pressed())
        {
          println("New player joined");
          devices.add(device);        
          int j = players.size();
          if (j == 1)
          {
            gameBegun = true;            
          }                    
          Ship player = new Ship(device);
          player.spawnIndex = j;
          player.colour = colours[j];
          player.position = spawnPoints.get(j).get();
          player.pointAtSun();          
          player.resetShield(10);
          player.shootSound = minim.loadFile("laser" + j + ".wav");
          player.hyperDriveSound = minim.loadFile("hyper" + j + ".wav");
          playSound(player.hyperDriveSound);
          children.add(player);
          players.add(player);
        }        
      }
    }    
  }
}

void enumerate()
{
  for (int i = 0 ; i < devices.size() ; i ++)
  {
    ControllDevice device = devices.get(i);
    for (int j = 0 ; j < device.getNumberOfButtons() ; j ++)
    {
      ControllButton button = device.getButton(j);
      println(j + " " + button.pressed());
    }
  }
}

void game(boolean update)
{  
  
  if (update)
  {
    checkForNewControllers();
    applyGravity();
  }
  
  if (players.size() == 1 && gameBegun)
  {
   soundtrack.pause();
   winnerIndex = players.get(0).spawnIndex;
   gameState = 2;
  } 
  
  for (int i = children.size()-1; i >= 0; i--) 
  {
    GameObject entity = children.get(i);
    if (update)
    {
      entity.update();
    }
    entity.draw();
    if (! entity.alive) 
    {
      children.remove(i);
    }
  }
  
  // Check for collisions
  for (int i = 0 ; i < children.size() ; i ++)
  {
    GameObject entity = children.get(i);
    if (entity instanceof Lazer)
    {
      Lazer lazer = (Lazer) entity;
      for (int j = 0 ; j < players.size() ; j ++)
      {
        Ship player = players.get(j);
        if ((lazer.colour != player.colour) && ! player.shield && player.collides(lazer))
        {
          addGameObject(new Explosion(player.vertices, player.position, player.colour));
          player.lives --;
          player.resetShield(5);
          player.theta = 0;
          player.velocity.x = player.velocity.y = 0;
          player.position = spawnPoints.get(player.spawnIndex).get();           
          player.pointAtSun();
          playSound(explosion);
        }
      }      
    } 
    if (entity instanceof Powerup)
    {
      Powerup powerup = (Powerup) entity;
      for (int j = 0 ; j < players.size() ; j ++)
      {
        Ship player = players.get(j);
        if (player.collides(entity))
        {
          powerup.applyTo(player);
          entity.alive = false;
          playSound(powerupSound);
        }
      }
    }
    if (entity instanceof BigStar)
    {
      for (int j = 0 ; j < players.size() ; j ++)
      {
        Ship player = players.get(j);
        if (! player.shield && player.collides(entity))
        {
          addGameObject(new Explosion(player.vertices, player.position, player.colour));
          player.velocity.x = player.velocity.y = 0;
          player.lives --;
          player.resetShield(5);
          player.position = spawnPoints.get(player.spawnIndex).get();
          player.pointAtSun();          
          playSound(explosion);
        }
      }
      
      // Check for powerups & BigStar
      for (int j = 0 ; j < children.size() ; j ++)
      {
        if (children.get(j) instanceof Powerup)
        {
          if (children.get(j).collides(entity))
          {
            children.get(j).alive = false;
            addGameObject(new Explosion(children.get(j).vertices, children.get(j).position, children.get(j).colour));
            playSound(explosion);
          }          
        }        
      }       
    } 
  }  
  
  spawnPowerup();
  
  // Check for a winner and print the score...
  int th = 25;
  for (int i = 0 ; i < players.size() ; i ++)
  {
    Ship player = players.get(i);
    stroke(player.colour);
    printText("Player: " + (i + 1) + " Hyperdrive: " + player.hyper + " Lives: " + player.lives + " Ammo: " + player.ammo, font_size.small, (int)hudPositions.get(player.spawnIndex).x, (int)hudPositions.get(player.spawnIndex).y);
    if (player.lives == 0)
    {      
      children.remove(player);
      players.remove(player);      
      break;
    }
  }    
}

void spawnPowerup()
{
  if ((players.size() > 0) &&  (frameCount % ((int) spawnInterval * 60) == 0))
  {
    int i = (int) random(0, 5);
    GameObject powerup = null;    
    switch (i)
    {
      case 0:
        powerup = new LivesPowerup();           
        break;   
      case 1:      
        powerup = new HyperspacePowerup();
        break;
      case 2:      
        powerup = new ShieldPowerup();
        break;
      default:        
        powerup = new AmmoPowerup();
        break;
    }    
    children.add(powerup);
  }
}


boolean muteToggle = true;

void draw()
{
  if (checkKey('M') )
  {
    if (muteToggle)
    {
      if (soundtrack.isMuted())
      {
        soundtrack.unmute();
      }
      else
      {
        soundtrack.mute();
      }
    }
    muteToggle = false;
  }
  else
  {
    muteToggle = true;
  }
  background(0);
  
  switch (gameState)
  {
    case 0:
      splash();
      break;
    case 1:
      game(true);
      break;
    case 2:
      game(true);
      gameOver();
      break;  
  }
}

boolean checkKey(int k)
{
  if (keys.length >= k) 
  {
    return keys[k] || keys[Character.toUpperCase(k)];  
  }
  return false;
}

void mousePressed()
{
}

void keyPressed()
{ 
  keys[keyCode] = true;
}
 
void keyReleased()
{
  keys[keyCode] = false; 
}

