import processing.video.*;

import netP5.*;
import oscP5.*;

Capture video;

OscP5 oscP5;
NetAddress myRemoteLocation;

color trackColor;

ArrayList<Blob> blobs = new ArrayList<Blob>();

float colorThreshold;
float distanceThreshold=65;

int loc;

float x=50000;
float x_inc;
float y;
float y_inc;
float r=30;
float rightWall;
float leftWall=0;
float ballFill=150;
float strokeCol=0;
float catchX=10000;
float catchY=10000;

int net=30;

void settings(){
  fullScreen();
}

void setup(){
  frameRate(600);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this,cameras[0]);
  video.start();
  trackColor=color(-855053);
  ellipseMode(RADIUS);
}

void captureEvent(Capture video){
  video.read();
}

void draw() {
  if(x==50000){
    x=random(width/2-r*2)+r;
    y=random(height/2-r*2)+r;
    x_inc=random(width*.005, width*.02);
    y_inc=random(height*.005,height*.02);
    rightWall=width/2;
  }
  colorTracking();
  //crossingLines();
}

void colorTracking(){
  video.loadPixels();
  pushMatrix();
  scale(-1,1);
  image(video,-width,0, width,height);
  //noStroke();
  //fill(150);
  //rect(-width,0,width/2,height);
  //fill(0);
  //rect(-width/2,0,width/2,height);
  
  blobs.clear();
  
  colorThreshold = 80;
  
  for(int x=0; x<video.width; x++){
    for(int y=0; y<video.height; y++){
      loc = x+y*video.width;
      
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      
      float d = distSq(r1,g1,b1,r2,g2,b2);
      
      if(d < colorThreshold*colorThreshold){  
        boolean found=false;
        for(Blob b : blobs){
          if(b.isNear(x,y)){
            b.add(x,y);
            found=true;
            break;
          }
        }
        if(!found){
          Blob b = new Blob(x,y);
          blobs.add(b);
        }
      }
    }
  }
  
  for(Blob b : blobs){
    translate(-width,0);
    b.show();
  }
    //float normX=normalize(coloAvgX, 0, video.width, 0, width);
    //float normY=normalize(coloAvgY, 0, video.height, 0, height);

    //avgX=screenX(normX, normY);
    //avgY=screenY(normX, normY);
    //releaseBall();
  popMatrix();
}

float distSq(float x1, float y1,float x2, float y2){
  float d=(x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2){
  float d=(x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
  return d;
}

float normalize(float val, float valLo, float valHi, float outLo, float outHi){
   if (val < valLo){
      val = valLo;
   } else if (val > valHi){
      val = valHi;
   }
   float valDiff = valHi - valLo;
   float outDiff = outHi - outLo;
   float percent = (val - valLo) / valDiff;
   return outLo + (percent * outDiff);
}

void crossingLines(){
  //catchX=abs(avgX-x);
  //catchY=abs(avgY-y);
  fill(ballFill);
  stroke(strokeCol);
  ellipse(x,y, r,r);
  x+=x_inc;
  y+=y_inc;
  if(x+r>rightWall){
    x_inc=-x_inc;
  }
  if(x-r<leftWall){
    x_inc=random(width*.005,width*.02);
  }
  if(y+r>height){
    y_inc=-y_inc;
  }
  if(y-r<0){
    y_inc=random(height*.005,height*.02);
  }
  //if(catchX<net && catchY<net){
  //  x=avgX;
  //  y=avgY;
  //  holdBall();
  //  println(net);
  //  println(x_inc,y_inc);
  //}
}


void holdBall(){
  if(net==30){
    net=500;
    x_inc=0;
    y_inc=0;
  }
}

void releaseBall(){
  if(net==500){
    if(x<width/2){
      rightWall=width/2;
      leftWall=0;
      ballFill=150;
      strokeCol=0;
    }else{
      rightWall=width;
      leftWall=width/2;
      ballFill=0;
      strokeCol=255;
    }
    net=30;
    float chanceX=random(100);
    if(chanceX>50){
      x_inc=random(-width*.02,-width*.005);
    }else{
      x_inc=random(width*.005,width*.02);
    }
    float chanceY=random(100);
    if(chanceY>50){
      y_inc=random(-height*.02,-height*.005);
    }else{
      y_inc=random(height*.005,height*.02);
    }
  }
}
