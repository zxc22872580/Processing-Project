import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer audio;
AudioPlayer touchTrash;
AudioPlayer touchFish;
AudioPlayer touchGar;
PImage[] hp = new PImage[5];
PImage gmst;
PImage gmct;

PImage bg;
PImage fishMan;
PImage[] fish = new PImage[3];
PImage[] trashImages = new PImage[3];

boolean isFirstFishHooked = false;
float firstFishY;
float lineLength = 50; // 初始釣線長度
float springiness = 0.1; // 釣線的彈性
boolean isReleasing = false; // 是否正在釣線向下
boolean isPulling = false;

int trashType;
int fishType;

int fishx = -10;
int fishy ;
int fishSpeedx ;
int fishSpeedy ;

Fish[] fishes = new Fish[4];
Trash trash;

ArrayList<Fish> hookedFishes = new ArrayList<Fish>();

int lastClearTime = 0;

int decrease = 3;
int score=0;
boolean gameStarted = false;
void setup() {
  size(1000, 615);
  bg = loadImage("bg.jpg");
  fishMan = loadImage("fisherman.png");
  
  for(int i = 0 ;i<3 ;i++){
      fish[i] = loadImage("fish"+i+".png");
      trashImages[i] = loadImage("trash"+i+".png");
    }
    minim =new Minim(this);
    audio = minim.loadFile("bgm.mp3");  
    touchTrash = minim.loadFile("touchTrash.wav");
    touchFish = minim.loadFile("touchFish.wav");
    touchGar = minim.loadFile("touchGar.wav");
    gmst = loadImage("gamestart.png");
    gmct = loadImage("gamecon.png");
    for(int i = 0 ;i<5 ;i++){
      hp[i] = loadImage("heart.png");
    }
    generateTrash();
}

void draw() {
  image(bg,0,0);
  
  //if (gameStarted==true) {
  //   if(decrease >0){
       
  image(fishMan,380,-30);
  drawFishingLine(420,20, lineLength);
  if (isReleasing) {
    releaseFishingLine();
  }else if(isPulling){
    returnFishingLine();
  }
    
  for (int i = 0; i < fishes.length; i++) {
    if (fishes[i] == null || fishes[i].isOffscreen()) { // 如果魚不存在或超出畫面範圍
      fishes[i] = new Fish(fishx, floor(random(150,500)), floor(random(1,3)), fish[int(random(fish.length))]); 
    }
    fishes[i].update(); // 更新魚的位置
    fishes[i].display(); // 顯示魚
    if (!fishes[i].isHooked && fishes[i].x < 420 && fishes[i].x > 380 && lineLength >= fishes[i].y) {
      isReleasing = false; // 停止釣線延長
      isPulling = true; // 啟動回收釣線
      fishes[i].isHooked = true; // 標記魚已被釣到
      hookedFishes.add(fishes[i]); // 將被釣到的魚加入釣到的魚的列表
      lineLength = fishes[i].y; // 使釣線長度等於被釣到的魚的y座標
      fishes[i] = null;
      //score++;
      //touchFish.cue(0);
      //touchFish.play();
    }
  }
  
  if (isPulling) {
    returnFishingLine();
  }
  
  if (trash != null) {
    trash.update(); // 更新垃圾的位置
    if (!trash.isOffscreen()) { // 檢查垃圾是否超出邊界
      trash.display(); // 顯示垃圾
    } else {
      trash = null; // 如果垃圾超出邊界，將其設置為null
      //touchTrash.cue(0);
      //touchTrash.play();
      //decrease--;
      lastClearTime = millis(); // 記錄清除垃圾的時間
    }
  }
  
  // 檢查是否需要生成新的垃圾
  if (millis() - lastClearTime > 2000 && trash == null) {
    generateTrash(); // 產生新的垃圾物品
  }else{}
  //for(int i =0;i<decrease;i++){
  //     image(hp[i],50*i,10);
  //    }
      
  //    fill(255);
  //    textSize(30);
  //    textAlign(CENTER);
  //    text("Score: " + score, 900,50);
  //}else{
  //     image(bg,0,0);
  //     fill(255);
  //     textSize(100);
  //     textAlign(CENTER);
  //     text("Score: " + score, 460,200);
  //     image(gmct,460,300);
  //     if(mousePressed){
  //       gameStarted = false;
  //       decrease=3;
  //       score=0;
  //     }
  //   }
  //}else{
  //   audio.play();
  //   image(gmst,CENTER+80,CENTER+100);
  //   }
}

////////////////////////////////////////////////////////////////////釣線
void drawFishingLine(float x, float y, float length) {
  float angle = radians(90); 

  float endX = x + length * cos(angle);
  float endY = y + length * sin(angle);
  
  line(x, y, endX, endY);
}


void mouseClicked() {
  isReleasing = true;
}

void releaseFishingLine() {
  if (lineLength < 600) {
    lineLength += 2; 
  } else {
    isReleasing = false;
    isPulling = true;
  }
}

void returnFishingLine() {
  if (lineLength > 50) {
    lineLength -= 2; 
  }else {
    isPulling = false;
  }
}
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////魚
class Fish {
  float x, y; // 魚的位置
  float speed; // 魚的速度
  PImage img; // 魚的圖片
  boolean isHooked = false;
  
  Fish(float x, float y, float speed, PImage img) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.img = img;
  }
  
  void update() {
    x += speed; // 更新魚的位置
  }
  
  void display() {
    image(img, x, y); // 顯示魚的圖片
  }
  
  boolean isOffscreen() {
    return x > width; // 如果魚超出畫面右邊界，返回 true
  }
}
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////垃圾
// 產生垃圾物品
void generateTrash() {
  PImage img = trashImages[int(random(trashImages.length))];
  trash = new Trash(0, 100, random(1, 3), img); // 產生新的垃圾物品
}

class Trash {
  float x, y; // 垃圾的位置
  float speed; // 垃圾的速度
  PImage img; // 垃圾的圖片
  
  Trash(float x, float y, float speed, PImage img) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.img = img;
  }
  
  void update() {
    x += speed; // 更新垃圾的位置
  }
  
  void display() {
    image(img, x, y); // 顯示垃圾的圖片
  }
  
  boolean isOffscreen() {
    return x > width; // 檢查垃圾是否超出畫面右邊界
  }
}
//void mousePressed() {
//  gameStarted = true; 
//}
void keyPressed() {
  if (millis() - lastClearTime > 2000) { // 如果距離上次清除垃圾的時間超過兩秒
    if (trash != null && abs(trash.x - width/2) < 50) { // 如果垃圾靠近畫面中間
      trash = null; // 清除垃圾
      //touchGar.cue(0);
      //touchGar.play();
      //score++;
      lastClearTime = millis(); // 記錄清除垃圾的時間
    }
  }
}
////////////////////////////////////////////////////////////////////////////////////
