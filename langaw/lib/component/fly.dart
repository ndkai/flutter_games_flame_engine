import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:langaw/langaw_game.dart';
import 'package:flame/sprite.dart';

import '../view.dart';
import 'callout.dart';

class Fly { 
  Rect flyRect ;
  Paint flyPaint;
  bool isDead = false;
  bool isOffScreen = false;
  Callout callout;
  List<Sprite> flyingSprite;
  Sprite deadSprite;
  double flyingSpriteIndex = 0;

  //speed
  double get speed => game.tileSize * 3;
  Offset targetLocation;
  
  final LangawGame game;
  Fly(this.game) {
    callout = Callout(this);
    setTargetLocation();

  }

  
  void render(Canvas c) {
    if (isDead) {
      deadSprite.renderRect(c, flyRect.inflate(2));
    } else {
      flyingSprite[flyingSpriteIndex.toInt()].renderRect(c, flyRect.inflate(2));
      if (game.activeView == View.playing) {
        callout.render(c);
      }
    }

  }
  //t = 16.6 mls
  void update(double t) {
    if (isDead) {
      // make the fly fall
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);
      if (flyRect.top > game.screenSize.height) {
        isOffScreen = true;
      }
    } else {
      // flap the wings
      flyingSpriteIndex += 30 * t;
      if (flyingSpriteIndex >= 2) {
        flyingSpriteIndex -= 2;
      }

      // move the fly
      double stepDistance = speed * t;
      Offset toTarget = targetLocation - Offset(flyRect.left, flyRect.top);
      if (stepDistance < toTarget.distance) {
        Offset stepToTarget = Offset.fromDirection(toTarget.direction, stepDistance);
        flyRect = flyRect.shift(stepToTarget);
      } else {
        flyRect = flyRect.shift(toTarget);
        setTargetLocation();
      }

      // callout
      callout.update(t);
    }
  }


  void setTargetLocation() {
    double x = game.rnd.nextDouble() * (game.screenSize.width - (game.tileSize * 2.025));
    double y = game.rnd.nextDouble() * (game.screenSize.height - (game.tileSize * 2.025));
    targetLocation = Offset(x, y);
  }

  void onTapDown() {
    // isDead = true;
    // flyPaint.color = Color(0xffff4757);
    // game.spawnFly();
    if (!isDead) {
      isDead = true;
      if (game.activeView == View.playing) {
        game.score += 1;
      }
    }
    Flame.audio.play('sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
  }
}