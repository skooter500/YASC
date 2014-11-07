import ddf.minim.*;
import procontroll.*;
 
PFont font;
int textY;

float timeDelta = 1.0f / 60.0f;
ArrayList<Ship> players = new ArrayList<Ship>();
ArrayList<BigStar> stars = new ArrayList<BigStar>();
ArrayList<PVector> spawnPoints = new ArrayList<PVector>();

boolean[] keys = new boolean[526];
ArrayList<GameObject> children = new ArrayList<GameObject>();
ArrayList<ControllDevice> devices = new ArrayList<ControllDevice>();

color[] colours = {
  color(255, 0,0)
  ,color(0, 255,0)
  ,color(255, 255,0)
  ,color(0, 255,255)
};

int gameState = 0;
int winner = 0;
int numStars = 100;

SpaceWars instance;
ControllIO controll;

Minim minim;//audio context
AudioPlayer explosion;

void addGameObject(GameObject o)
{
  children.add(o);
}

boolean sketchFullScreen() {
  return false;
}

void setup()
{
  size(800, 600);
  noCursor();
  minim = new Minim(this);  
  instance = this;
  
  controll = ControllIO.getInstance(this);
  
  spawnPoints.add(new PVector(50, height / 2));
  spawnPoints.add(new PVector(width - 50, height / 2));
  spawnPoints.add(new PVector(width - 50, height / 2));
  spawnPoints.add(new PVector(width - 50, height / 2));
   
  BigStar star = new BigStar();
  children.add(star);
  
  stars.add(star);    
  
  for (int i = 0 ; i < 100 ; i ++)
  {
     children.add(new SmallStar());
  }
  
  font = loadFont("Checkbook-48.vlw");    
  explosion = minim.loadFile("Explosion4.wav");
}

void applyGravity()
{
  for (int i = 0 ; i < stars.size() ; i ++)
  {
    BigStar star = stars.get(i);
    for (int j = 0 ; j < children.size() ; j ++)
    {
      GameObject child = children.get(j);
      if (child instanceof Lazer || child instanceof Ship)
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
  for (int i = 0 ; i < children.size() ; i ++)
  {
      GameObject child = children.get(i);
      if (child instanceof Ship)
      {
        Ship player = (Ship) children.get(i);
        player.position = spawnPoints.get(i).get();
        player.lives = 5;
        player.theta = 0.0f;
        player.velocity.setMag(0);
        player.resetShield();      
      }
      if (child instanceof Lazer)
      {
        child.alive = false;
      }
  }
  
  textY = 20;
}

void splash()
{
  background(0);
  fill(255);
  printText("Yet Another SpaceWar Clone (YASC)!", 48, 100);  
  printText("Programmed by Bryan Duggan", 32, 200);
  printText("Press SPACE to play", 32, 300);  
  if (checkKey(' '))
  {
    reset();
    gameState = 1;
  }
}

void gameOver()
{
  background(0);
  fill(255);
  printText("Yet Another SpaceWar Clone (YASC)!", 48, 200);
  printText("Game Over", 48, 350);  
  fill(players.get(winner).colour);
  printText("Player " + (winner + 1) + " is the winner", 32, 500);    
  fill(255);  
  printText("Press SPACE to play", 32, 650);  
  if (checkKey(' '))
  {
    gameState = 0;
  }
}

void checkForNewControllers()
{
  // Add all the xbox controllers
  for(int i = 0; i < controll.getNumberOfDevices(); i++){
    ControllDevice device = controll.getDevice(i);
    if (device.getName().indexOf("XBOX") != -1)
    {
      if (! devices.contains(device))
      {
        devices.add(device);
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

void checkForNewPlayers()
{
  for (int i = 0 ; i < devices.size() ; i ++)
  {
    if (i > players.size() - 1)
    {
      Ship player = new Ship();
      player.colour = colours[i];
      player.position = spawnPoints.get(i);
      children.add(player);
      players.add(player);
    }
  }
}

void game()
{  
  checkForNewControllers();
  checkForNewPlayers();
  //enumerate();
  //  applyGravity();
  for (int i = children.size()-1; i >= 0; i--) 
  {
    GameObject entity = children.get(i);
    entity.update();
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
          player.lives --;
          player.resetShield();
          player.position = spawnPoints.get(j).get();
          explosion.rewind();
          explosion.play();
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
          player.lives --;
          player.resetShield();
          player.position = spawnPoints.get(j).get();
          explosion.rewind();
          explosion.play();
        }
      }
    } 
  }  
  
  // Check for a winner and print the score...
  int th = 50;
  for (int i = 0 ; i < players.size() ; i ++)
  {
    Ship player = players.get(i);
    fill(player.colour);
    printText("Player: " + (i + 1) + " Hyperdrive: " + player.hyper + " Lives: " + player.lives, 32, th * (i + 1));
    if (player.lives == 0)
    {
      gameState = 2;
      winner = 1 - i;
      break;
    }
  }   
  
}



void printText(String text, int size, int y)
{
  textFont(font, size);
  int tw = (int) textWidth(text);
  int x = (width / 2) - (tw / 2);
  text(text, x, y);
}

void draw()
{
  background(0);
  
  switch (gameState)
  {
    case 0:
      splash();
      break;
    case 1:
      game();
      break;
    case 2:
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

