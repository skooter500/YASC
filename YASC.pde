import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import ddf.minim.*;
import de.ilu.movingletters.*;

float timeDelta = 0;
ArrayList<Ship> players = new ArrayList<Ship>();
ArrayList<BigStar> stars = new ArrayList<BigStar>();
ArrayList<PVector> spawnPoints = new ArrayList<PVector>();
ArrayList<PVector> hudPositions = new ArrayList<PVector>();

boolean[] keys = new boolean[526];
ArrayList<GameObject> children = new ArrayList<GameObject>();
HashMap<ControlDevice, ControlDevice> devices = new HashMap<ControlDevice, ControlDevice>();

GameObject[] splashPowerups = {new ShieldPowerup(), new LivesPowerup(), new AmmoPowerup(), new HyperspacePowerup()};  
String[] splashPowerupText = {"Shields", "Lives", "Ammo", "Hyperspace" };

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
ControlIO controll;

Minim minim;//audio context
AudioPlayer soundtrack;
AudioPlayer explosion;
AudioPlayer powerupSound;
MovingLetters[] letters = new MovingLetters[3];
PFont[] fonts = new PFont[3];

boolean devMode = true;

String hudTest = "Player: X Hyperdrive: XX Lives: XX  Ammo: XX";
float hudWidth;

void addGameObject(GameObject o)
{
  children.add(o);
}


void setup()
{
  //size(800, 600, P3D);
  
  fullScreen(P3D);
  //smooth();
  noCursor();
  
  for (font_size size:font_size.values())
  {
    letters[size.index] = new MovingLetters(this, size.size, 1, 0);
  }
 
  minim = new Minim(this);  
  controll = ControlIO.getInstance(this);
  
  fonts[0] = createFont("Hyperspace Bold.otf", 24);
  fonts[1] = createFont("Hyperspace Bold.otf", 32);
  fonts[2] = createFont("Hyperspace Bold.otf", 48);
  
  spawnPoints.add(new PVector(50, 50));
  spawnPoints.add(new PVector(width - 50, height- 50));
  spawnPoints.add(new PVector(50, height - 50));
  spawnPoints.add(new PVector(width - 50, 50));
  
  hudWidth = calcHudWidth();
  hudPositions.add(new PVector(10, 20));
  hudPositions.add(new PVector(width - hudWidth, height - 5));
  hudPositions.add(new PVector(10, height - 5));
  hudPositions.add(new PVector(width - hudWidth, 40));
  
  explosion = minim.loadFile("Explosion4.wav");
  powerupSound = minim.loadFile("powerup.wav");
  soundtrack = minim.loadFile("soundtrack.mp3");  
     
}

float calcHudWidth()
{
  textFont(fonts[font_size.small.index]);
  return textWidth(hudTest);
}

void printText(String text, font_size size, float x, float y)
{
  textFont(fonts[size.index]);
  /*
  if (x == CENTRED)
  {
    x = (width / 2) - (int) (size.size * (float) text.length() / 2.5f);
  }
  letters[size.index].text(text, x, y);
  */
  
  if (x == CENTRED)
  {
    x = (width / 2) - (textWidth(text) / 2);
  }  
    
  text(text, x, y);
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
  
  printText("YASC - Yet Another Spacewar Clone", font_size.large, CENTRED, 100);  
  printText("A spacewar game for 4 players with XBOX 360 controllers", font_size.medium, CENTRED, 200);  
  printText("Programmed by Bryan Duggan, Music by Paul Bloof", font_size.medium, CENTRED, 300);
  printText("Press Start to spawn", font_size.small, CENTRED, 400);
  printText("Left stick to steer, Trigger to apply thrust", font_size.small, CENTRED, 450);
  printText("A to shoot, B to Hyprerspace", font_size.small, CENTRED, 500);
  
  for(int i = 0 ; i < splashPowerups.length ; i ++)
  {
    int x = (width / 2) - 80;
    int y = 600 + (i * 50);
    splashPowerups[i].position.x = x;
    splashPowerups[i].position.y = y; 
    splashPowerups[i].update();
    splashPowerups[i].draw();
    stroke(255);  
    printText(splashPowerupText[i], font_size.small, x + 50, y + 10);
  }
  
  stroke(255);  
  if (frameCount / 60 % 2 == 0)
  {
    printText("Press START to play", font_size.large, CENTRED, height - 100);  
  }
  if (checkForStart())
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
  fill(colours[winnerIndex]);
  if (frameCount / 60 % 2 == 0)
  {
    printText("Winner!", font_size.large, CENTRED, 400);
  }
  fill(255);  
  printText("Press START to play again", font_size.large, CENTRED, height - 100);  
  if (checkForStart())
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
  sound.rewind();
  if (loop)
  {
    sound.loop();
    if (sound.isPlaying())
    {
      return;
    }
  }    
  
  sound.play(); 
}

boolean checkForStart()
{
  // Add all the xbox controllers
  for(int i = 0; i < controll.getNumberOfDevices(); i++){
    ControlDevice device = controll.getDevice(i);
    if (device.getName().toUpperCase().indexOf("XBOX 360") != -1)
    {
      if (device.getButton(7).pressed())
      {
        return true;
      }        
    }    
  }
  return false;
}

boolean checkForNewControlers()
{
  boolean start = false;
  // Add all the xbox controllers
  int controllerIndex = 0;
  for(int i = 0; i < controll.getNumberOfDevices(); i++){
    ControlDevice device = controll.getDevice(i);
    if (device.getName().toUpperCase().indexOf("XBOX 360") != -1)
    {
      controllerIndex ++;
      if (!devices.containsKey(device))
      {        
        if (device.getButton(7).pressed())
        {
          println("New player joined");
          start = true;
          devices.put(device, device);        
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
          player.shootSound = minim.loadFile("Laser" + j + ".wav");
          player.hyperDriveSound = minim.loadFile("hyper" + j + ".wav");
          playSound(player.hyperDriveSound);
          children.add(player);
          players.add(player);
          controllerIndex ++;
        }        
      }
    }    
  }
  return start;
}

void enumerate()
{
  for (int i = 0 ; i < devices.size() ; i ++)
  {
    ControlDevice device = devices.get(i);
    for (int j = 0 ; j < device.getNumberOfButtons() ; j ++)
    {
      ControlButton button = device.getButton(j);
      println(j + " " + button.pressed());
    }
  }
}

void game(boolean update)
{  
  
  if (update)
  {
    checkForNewControlers();
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
    fill(player.colour);
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
long last = 0;

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
  strokeWeight(2);
  
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
  long now = millis();
  timeDelta = (now - last) / 1000.0f;
  last = now;
}

void controllerTest()
{
  for(int i = 0; i < controll.getNumberOfDevices(); i++) 
  {
    ControlDevice device = controll.getDevice(i);
    if (device.getName().toUpperCase().indexOf("XBOX 360") != -1)
    {
      print(i + " " + device.getName() + " ");
      println (device.getButton(7).pressed());
    }
  }
  println("===");
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