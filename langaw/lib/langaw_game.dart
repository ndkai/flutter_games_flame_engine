import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:langaw/component/fly.dart';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:langaw/view.dart';
import 'component/agile_fly.dart';
import 'component/backyarn.dart';
import 'component/core_display.dart';
import 'component/drooler_fly.dart';
import 'component/hourse_fly.dart';
import 'component/hungry_fly.dart';
import 'component/macho_fly.dart';
import 'component/view/credits_button.dart';
import 'component/view/credits_view.dart';
import 'component/view/help_button.dart';
import 'component/view/help_view.dart';
import 'component/view/home_view.dart';
import 'component/view/lostview.dart';
import 'package:audioplayers/audioplayers.dart';
import 'component/view/start_button.dart';
import 'controller/spawner.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Backyard background;
  Random rnd;

  //views
  View activeView = View.home;
  HomeView homeView;
  StartButton startButton;
  LostView lostView;
  HelpView helpView;
  CreditsView creditsView;
  HelpButton helpButton;
  CreditsButton creditsButton;
  ScoreDisplay scoreDisplay;

  //controller
  FlySpawner spawner;

  int score;
  //audio
  AudioPlayer homeBGM;
  AudioPlayer playingBGM;
  
  LangawGame() {
    initialize();
  }
  
  void render(Canvas canvas) {
    //vẽ background
    background.render(canvas);
    //vẽ object
    flies.forEach((Fly fly) => fly.render(canvas));
    if(activeView == View.lost || activeView == View.home){
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
    if (activeView == View.lost) lostView.render(canvas);
    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
    if (activeView == View.home) homeView.render(canvas);
    if (activeView == View.playing) scoreDisplay.render(canvas);
    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
    }


  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }
    if (!isHandled) {
      bool didHitAFly = false;
      try{
        flies.forEach((Fly fly) {
          if (fly.flyRect.contains(d.globalPosition)) {
            fly.onTapDown();
            isHandled = true;
            didHitAFly = true;
          }
        });
      } catch(e){
        print("eeeee ${e}");
      }
      if (activeView == View.playing && !didHitAFly) {
        activeView = View.lost;
        Flame.audio.play('sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
      }
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // help button
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    // credits button
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    
  }

  void update(double t) {
    spawner.update(t);
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    if (activeView == View.playing) scoreDisplay.update(t);

  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - tileSize);
    double y = rnd.nextDouble() * (screenSize.height - tileSize);
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
    
  }

  void initialize() async {
    flies = List<Fly>();
    rnd = Random();

    resize(await Flame.util.initialDimensions());
    background = Backyard(this);
    homeView = HomeView(this);
    startButton = StartButton(this);
    lostView = LostView(this);
    spawner = FlySpawner(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    score = 0;
    scoreDisplay = ScoreDisplay(this);
    homeBGM = await Flame.audio.loop('bgm/home.mp3', volume: .25);
    homeBGM.pause();
    playingBGM = await Flame.audio.loop('bgm/playing.mp3', volume: .25);
    playingBGM.pause();

    playHomeBGM();
    spawnFly();

  }

  void playHomeBGM() {
    playingBGM.pause();
    playingBGM.seek(Duration.zero);
    homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    homeBGM.seek(Duration.zero);
    playingBGM.resume();
  }
}