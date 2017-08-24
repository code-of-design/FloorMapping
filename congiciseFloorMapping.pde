import processing.net.*; // 通信ライブラリ.
import deadpixel.keystone.*; // キャリブレーションライブラリ.

Server server; // サーバ.

Keystone ks; // Keystone本体
CornerPinSurface surface; // 射影変換する投影

PGraphics offscreen; // 投影するグラフィクス

float floor_width; // 床の幅.
float floor_height; // 床の高さ.
int floor_num = 9; // 床の数.
int[] floor_state = new int[floor_num*6]; // 床の状態.
String floor_state_str; // 床の状態文字列.
color floor_color; // 床の色値.
color text_color; // テキストの色値.

void setup() {
  // サーバを初期化する.
  server = new Server(this, 5555); // IPアドレス, ポート番号.
  println("StartServerAtAddress: " + server.ip());

  size(displayWidth, displayHeight, P3D);
  frameRate(30); // Kinectのフレームレート.

  // Keystoneを初期化する.
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 60);
  offscreen = createGraphics(width, height, P3D);

  // 床の状態を初期化する.
  for(int i=0; i<floor_num; i++){
    floor_state[i] = 0; // Off.
  }

  floor_width = width/3; // 床の幅.
  floor_height = height/3; // 床の高さ.
}

void draw() {
  // クライアントと接続する.
  Client c = server.available(); // クライアントを取得する.
  if(c != null){
    floor_state_str = c.readString(); // クライアントの送信文字列.
    // println(floor_state_str); // 床の状態文字列.
    floor_state = int(split(floor_state_str, ","));
    println(floor_state);

    /*
    for(int i=0; i<floor_num; i++){
      // floor_state[i] = int(floor_state_str.charAt(i)); // 床の状態を取得する.

      // ASCII文字コード.
      // 0: 48
      // 1: 49

      floor_state[i] = floor_state_str.charAt(i);
      println(floor_state_str.charAt(i));
    }
    */
  }

  // println(floor_state); // 床の状態を表示する.

  // プロジェクションマッピングを開始する.
  offscreen.beginDraw();
  offscreen.translate(width, height); // 表示を回転する.
  offscreen.rotate(PI);

  // 床を描画する
  for(int y=0; y<3; y++){
    for(int x=0; x<3; x++){
      int i = x+y+(2*y); // JSONのIndex.

      // 床の色値.
      if(floor_state[i] == 0){ // Off.
        floor_color = color(255,255,255);
        text_color = color(255,0,0);
      }
      else if(floor_state[i] == 1){ // On.
        floor_color = color(255,0,0);
        text_color = color(255,255,255);
      }

      offscreen.stroke(255, 0, 0); // 床フレームの色値.
      offscreen.strokeWeight(15); // 床フレームの幅.
      offscreen.fill(floor_color); // 床の色値.
      offscreen.rect(x+(floor_width*x), y+(floor_height*y), floor_width, floor_height); // 床を描写する.

      offscreen.textSize(200); // テキストの大きさ.
      offscreen.textAlign(CENTER);
      offscreen.fill(text_color); // テキストの色値.
      offscreen.text(i+1, x+(floor_width*x)+(floor_width/2), y+(floor_height*y)+(floor_height/2)+70); // テキストを描写する.
      // offscreen.noFill(); // テキストの色値を無効化する.
    }
  }
  offscreen.endDraw(); // プロジェクションマッピングを終了する.

  // floor_state, floor_state_strをリフレッシュする.
  for(int i=0; i<floor_num; i++){
    floor_state[i] = 0;
  }
  floor_state_str = "";

  // スクリーンに投射する.
  background(0);
  surface.render(offscreen);
}

// キャリブレーションのキー入力.
void keyPressed() {
  switch(key) {
    // キャリブレーションを調整する.
    case 'c':
    case 'C':
      ks.toggleCalibration();
    break;

    // キャリブレーションを読み込む.
    case 'l':
    case 'L':
      ks.load();
    break;

    // キャリブレーションを保存する.
    case 's':
    case 'S':
      ks.save();
    break;
  }
}
