import funkin.game.shaders.WiggleEffect;
import funkin.game.shaders.WiggleEffect.WiggleEffectType;

var wiggleBack:WiggleEffect;
var wiggleSchool:WiggleEffect;
var wiggleGround:WiggleEffect;
var wiggleSpike:WiggleEffect;

function onLoad()
{
  wiggleBack = new WiggleEffect();
  wiggleBack.waveSpeed = 2 * 0.8;
  wiggleBack.waveFrequency = 4 * 0.4;
  wiggleBack.waveAmplitude = 0.011;
  wiggleBack.effectType = WiggleEffectType.DREAMY;

  wiggleSchool = new WiggleEffect();
  wiggleSchool.waveSpeed = 2;
  wiggleSchool.waveFrequency = 4;
  wiggleSchool.waveAmplitude = 0.017;
  wiggleSchool.effectType = WiggleEffectType.DREAMY;

  wiggleSpike = new WiggleEffect();
  wiggleSpike.waveSpeed = 2;
  wiggleSpike.waveFrequency = 4;
  wiggleSpike.waveAmplitude = 0.01;
  wiggleSpike.effectType = WiggleEffectType.DREAMY;

  wiggleGround = new WiggleEffect();
  wiggleGround.waveSpeed = 2;
  wiggleGround.waveFrequency = 4;
  wiggleGround.waveAmplitude = 0.007;
  wiggleGround.effectType = WiggleEffectType.DREAMY;
  
  var solid:FlxSprite = new FlxSprite(-500, -1000).makeGraphic(2400, 2000, "#000000");
  solid.scrollFactor.set();
  add(solid);

  var school:FlxSprite = new FlxSprite(-816, -38).loadGraphic(Paths.image("backgrounds/weeb/erect/evil/weebSchool"));
  school.setScale(6, 6, true);
  school.zIndex = 20;
  school.scrollFactor.set(0.75, 0.75);
  add(school);

  var backSpike:FlxSprite = new FlxSprite(1416, 464).loadGraphic(Paths.image("backgrounds/weeb/erect/evil/backSpike"));
  backSpike.setScale(6, 6, true);
  backSpike.zIndex = 25;
  backSpike.scrollFactor.set(0.85, 0.85);
  add(backSpike);

  var weebBackSpikes:FlxSprite = new FlxSprite(-842, -180).loadGraphic(Paths.image("backgrounds/weeb/erect/evil/weebBackSpikes"));
  weebBackSpikes.setScale(6, 6, true);
  weebBackSpikes.zIndex = 15;
  weebBackSpikes.scrollFactor.set(0.5, 0.5);
  add(weebBackSpikes);

  var evilstreet:FlxSprite = new FlxSprite(-662, 6).loadGraphic(Paths.image("backgrounds/weeb/erect/evil/weebStreet"));
  evilstreet.setScale(6, 6, true);
  evilstreet.zIndex = 30;
  evilstreet.scrollFactor.set(1, 1);
  add(evilstreet);

  for (i in stage.members)
    i.antialiasing = false;

  school.shader = wiggleSchool;
  evilstreet.shader = wiggleGround;
  weebBackSpikes.shader = wiggleBack;
  backSpike.shader = wiggleSpike;
}

function onCreatePost()
{
  initScript('data/scripts/pixelUI');
}