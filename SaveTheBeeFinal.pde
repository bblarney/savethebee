//SAVE THE BEE//
//BRETT LARNEY//
//WINTER 2012//


//IMPORTS, VARIABLE DECLARATION
import ddf.minim.*;

AudioPlayer player;
Minim minim;

PImage r,u,b,main, b1, b2, b3, b4, b5, imgWin, imgLose, main2, cloudleft, cloudright, flowerpic, introscreen, loadingscreen, finalscreen;

final int DISPLAY_DURATION = 5000;
int level = 1;
int xPlayer, yPlayer;
int playerSpeed = 10;
final int radius = 5;
int rainMinSpeed = 2;
int rainMaxSpeed = 4;
int umbMinSpeed = 1;
int umbMaxSpeed = 3;
int numberOfDrops = 20;
int beeCount = 0;
int flowerCount = 3;
int flowersCaught = 0;
int cloudleftx = 0;
int cloudlefty = 0;
int cloudrightx = 250;
int cloudrighty = 0;
int lives = 3;

Raindrop raindrops[], tempdrop;
Umbrella umbrellas[];
Flower flowers[];

boolean cont = false;;
boolean menu = false;
boolean safe = false;
boolean splash = true;

//FLOWER, RAINDROP, UMBRELLA CLASSES
class Flower {
  float x, y;
   
  Flower (float p1, float p2) {
    x = p1;
    y = p2;
  }
}

class Raindrop {
  float x, y;		
  float speed;	
  boolean alive;	
 
  Raindrop(float p1, int p2, float p3, boolean p4) {
    x = p1;
    y = p2;
    speed = p3;
    alive = p4;
  }
}

class Umbrella {
  float x, y;		
  float speed;	
  boolean alive;	

  Umbrella(float p1, int p2, float p3, boolean p4) {
    x = p1;
    y = p2;
    speed = p3;
    alive = p4;
  }
}

//SETUP METHOD
void setup() {
  menu = false;
  loadImages();
  size(500, 700);
  minim=new Minim(this);
  player = minim.loadFile("mino-happypeople.mp3", 2048);
  //PLAY MUSIC FILE
  //player.play();
  begin();
}

//BEGIN METHOD, CREATES VALUES IN THE UMBRELLA, FLOWER AND RAINDROP ARRAYS
void begin() {
  
  //SETS THE STARTING LOCATION OF THE PLAYER
  xPlayer = width/2;
  yPlayer = height-25;

  //INITIALIZING UMBRELLAS
  umbrellas = new Umbrella[10];
  
  for (int i=0; i < 10; i++) {
    int randY = int(random(-500, -50));
    umbrellas[i] = new Umbrella(random(width), randY, int(random(umbMinSpeed, umbMaxSpeed)), true);
  }

  //INITIALIZING RAINDROPS
  raindrops = new Raindrop[numberOfDrops];

  for (int i=0; i < numberOfDrops; i++) {
    int randY = int(random(-500, -50));
    raindrops[i] = new Raindrop(random(width), randY, int(random(rainMinSpeed, rainMaxSpeed)), true);
  }
  
  //INITIALIZING FLOWERS
  flowers = new Flower[flowerCount];
  
  for (int k=0; k < flowerCount; k++) {
    flowers[k] = new Flower(random(width)-5, random(100, height));
  }
  
}

//DRAW METHOD, DRAWS THE PLAYING SCREEN, UPDATING LOCATIONS OF OBJECTS
void draw() {
  //IF THE SPLASH SCREEN MUST RUN, IT RUNS INSTEAD OF THE DRAW METHOD
  if(splash) { 
    introScreen();
  }
  else {
    
  //CHANGES THE BACKGROUND ACCORDING TO WHICH LEVEL YOU ARE ON
  if (level == 1){
    b = b1;
  }
  else if (level == 2) {
    b = b2;
  }
  else if (level == 3) {
    b = b3;
  }
  else if (level == 4) {
    b = b5;
  }
  else if (level == 5) {
    b = b4;
  }
  else {
    gameWon();
  }

  background(b);
  
  //TEXT FOR CURRENT LEVEL AND AMOUNT OF LIVES REMAINING
  fill(0);
  text("Level: "+level,10,height-12);
  text("Lives: " + lives, width - 50, height - 12);

  //CALLS THE SEPERATE DRAW METHODS FOR EACH ONSCREEN OBJECT
  drawBee(xPlayer, yPlayer);
  drawUmbrellas();
  drawDrops();
  drawCloudsFlowers();
  }

}

//DRAWS EACH RAINDROP
void drawDrops() {

  for (int i=0; i < numberOfDrops; i++)
  {
    fill(0, 0, 255);
    ellipseMode(RADIUS);
    image(r,raindrops[i].x, raindrops[i].y, 4*radius, 4*radius);  

    raindrops[i].y = raindrops[i].y + raindrops[i].speed; 

    if (raindrops[i].y >= height) {
      raindrops[i].y = int(random(-1000, -100));
      raindrops[i].x = (random(width));
    }
    //IF THE PLAYER COLLIDES WITH THE RAINDROP..
    if ((xPlayer+10 >= raindrops[i].x-radius && xPlayer-10 <= raindrops[i].x+radius) && (yPlayer+10 >= raindrops[i].y-radius && yPlayer-10 <= raindrops[i].y+radius)) {
      lives--;
      if (lives == 0) { 
        gameOver();
        break;
      }
      else {
        //RETURN RAINDROP TO TOP OF THE SCREEN
        raindrops[i].y = int(random(-1000, -100));
        raindrops[i].x = (random(width));
        playerSpeed-=3;
      }
    }
    //CHECK FOR COLLISION BETWEEN RAINDROP AND UMBRELLAS
    checkCollision();
  }
}

//DRAWS EACH UMBRELLA
void drawUmbrellas() {

  for (int i=0; i < 10; i++)
  {
    image(u,umbrellas[i].x, umbrellas[i].y, 75, 50);   

    umbrellas[i].y = umbrellas[i].y + umbrellas[i].speed;

    if (umbrellas[i].y >= height) {
      umbrellas[i].y = int(random(-5000, -50));
      umbrellas[i].x = (random(width));
    }  
    //IF THE PLAYER COLLIDES WITH A RAINDROP
    if ((yPlayer <= umbrellas[i].y+25 && yPlayer >= umbrellas[i].y-10) && (xPlayer >= umbrellas[i].x-10 && xPlayer <= umbrellas[i].x+75)) {
      yPlayer = (int)(umbrellas[i].y+5);
      //WHEN SAFE IS TRUE, THE PLAYER CANNOT MOVE UPWARDS
      safe = true;
    }
    else {
      safe = false;
    }
    //CHECK FOR COLLISION BETWEEN UMBRELLA AND RAINDROPS
    checkCollision();
  }
}

//DRAWS THE BEE ON SCREEN
void drawBee(int x, int y) {
  x=xPlayer;
  y=yPlayer;

  //SIMPLE CODE TO CHANGE THE BEE IMAGE, EVERY TIME THE BEE IS DRAWN BEECOUNT IS ADDED TO, IF THE COUNT IS UNDER 5 ONE IMAGE IS SHOWN, OR ELSE A DIFFERENT ONE IS SHOWN. COUNT IS RESET AT 10.
  if (beeCount >= 5) {
    image(main2,xPlayer, yPlayer, 30, 30);
  }
  else {
    image(main, xPlayer, yPlayer, 30, 30);
  }
  beeCount++;
  if (beeCount >=10) {
    beeCount = 0;
  }
  
  //IF PLAYER MAKES IT OFF THE SCREEN AT THE TOP, NEXT LEVEL BEGINS
  if (yPlayer <= 0) {
    nextLevel();
  }
  //IF PLAYER MAKES IT OFF SCREEN AT THE BOTTOM, THE GAME ENDS.
  if (yPlayer >height) {
    gameOver();
  } 
}

//CLOUDS AND FLOWERS DRAW METHOD
void drawCloudsFlowers() {
  
  image(cloudleft, cloudleftx, cloudlefty, 250, 75);
  image(cloudright, cloudrightx, cloudrighty, 250,75);
  
  for (int i=0; i<flowerCount; i++) {
    
    image(flowerpic, flowers[i].x, flowers[i].y, 25,25);  
    
    //IF THE PLAYER MOVES OVER A FLOWER, IT IS CONSIDERED CAUGHT, AND IS MOVED OFFSCREEN TO HIDE IT
    if (dist(xPlayer, yPlayer, flowers[i].x, flowers[i].y) <= 25) {    
      flowers[i].x = -50;
      flowers[i].y = -50;
      flowersCaught++;
    }
  }
  
  //IF ALL FLOWERS HAVE NOT BEEN CAUGHT, PLAYER CANNOT MOVE PAST THE CLOUDS
  if (checkFlowerCount() != true) {
    if (yPlayer <= 50) {
      yPlayer+=10;
    }
  }
  //IF ALL FLOWERS HAVE BEEN CAUGHT, THE CLOUDS SEPERATE
  else {
    cloudleftx-=3;
    cloudrightx+=3;
  }
}

//METHOD FOR ENDING THE GAME, SHOWS THE END GAME BACKGROUND
void gameOver() {
  noLoop();
  background(imgLose);
  menu = true;
  
  for (int i=1; i<numberOfDrops; i++) {
    raindrops[i].speed = 0;
  }
  for (int j=0; j<10; j++) {
    umbrellas[j].speed = 0;
    umbrellas[j].x = -100;
  }
  for (int k=0; k<flowerCount; k++) {
    flowers[k].x = -50;
  }
  cloudleftx = -500;
  cloudrightx = -500;
  
  minim.stop();
   
  if (mousePressed == true) {
    exit();
  }
}

//METHOD TO GO TO NEXT LEVEL
void nextLevel() {
  
  background(imgWin);
  menu = true;
  minim.stop();
  
  for (int i=1; i<numberOfDrops; i++) {
    raindrops[i].speed = 0;
    raindrops[i].x = -50;
  }
  for (int j=0; j<10; j++) {
    umbrellas[j].speed = 0;
    umbrellas[j].x = -100;
  }

  if (mousePressed == true) {
    level++;
    lives = 3;
    rainMinSpeed++;
    rainMaxSpeed++;
    numberOfDrops+=5;
    cloudleftx = 0;
    cloudrightx = 250;
    flowerCount++;
    flowersCaught = 0;
    playerSpeed = 10;
    menu = false;
    begin();
  }
}

void gameWon() {
  noLoop();
  background(finalscreen);
  menu = true;
  
  for (int i=1; i<numberOfDrops; i++) {
    raindrops[i].speed = 0;
  }
  for (int j=0; j<10; j++) {
    umbrellas[j].speed = 0;
    umbrellas[j].x = -100;
  }
  for (int k=0; k<flowerCount; k++) {
    flowers[k].x = -50;
  }
  cloudleftx = -500;
  cloudrightx = -500;
  
  minim.stop();
   
  if (mousePressed == true) {
    exit();
  }
}
  

//CHECKS FOR COLLISION BETWEEN RAINDROP AND UMBRELLA, RETURNS RAINDROP TO THE TOP IF TRUE
void checkCollision() {
  for (int i=0; i<10; i++){
    for (int j=0; j<numberOfDrops; j++) {
          if (dist(raindrops[j].x+10, raindrops[j].y+10, umbrellas[i].x+32, umbrellas[i].y+32) < 35) {
          raindrops[j].y = int(random(-1000, -100));
          raindrops[j].x = (random(width));
        }
      }
  }
}

//IF PLAYER HAS CAUGHT THE AMOUNT OF FLOWERS ON THE SCREEN, RETURNS TRUE
boolean checkFlowerCount() {
  if (flowersCaught == flowerCount) {
    return true;
  }
  else {
    return false;
  }
}

//SHOWS THE INTRO SCREEN
void introScreen() {
  background(introscreen);
  if (mousePressed == true) {
    instructions();
  }
}

//SHOWS THE SECOND SCREEN
void instructions() {
  background(loadingscreen);
    splash = false;
}

//LOADS ALL IMAGES USED IN THE GAME. ONLY CALLED ONCE THE ENTIRE TIME THE GAME IS RUNNING IN ORDER TO REDUCE LAG
void loadImages() {
  b1=loadImage("backgroundsunny.png");
  b2=loadImage("backgroundcloudy.png");
  b3=loadImage("backgroundcloudy2.png");
  b4=loadImage("backgroundlightning.png");
  b5=loadImage("backgroundverycloudy.png");
  
  u = loadImage("umbrella.png");
  r=loadImage("raindrop.png");  
  
  main=loadImage("bee.png");
  main2 = loadImage("bee2.png"); 
  
  imgLose = loadImage("youlose.png");
  imgWin = loadImage("youwin.png");
  
  cloudleft = loadImage("topcloudleft.png");
  cloudright = loadImage("topcloudright.png");
  
  flowerpic = loadImage("flower.png");
  
  introscreen = loadImage("introscreenfinal.png");
  loadingscreen = loadImage("loading.png");
  finalscreen = loadImage("finalscreen.png");
  
}

//KEYPRESS METHOD FOR ARROW KEYS, IF PLAYER IS AT A MENU THEY CANNOT BE USED, OR IF PLAYER IS 'SAFE' THE UP ARROW CANNOT BE USED
void keyPressed() {
  if ((key==CODED) && (menu == false)) {
    if ((keyCode==UP) && (safe == false))
      yPlayer-=playerSpeed;
    if (keyCode==DOWN)
      yPlayer+=playerSpeed;
    if (keyCode==LEFT)
      xPlayer-=playerSpeed;
    if (keyCode==RIGHT)
      xPlayer+=playerSpeed;
  }
}
  
  
  

