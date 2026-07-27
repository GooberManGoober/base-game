import funkin.game.shaders.DropShadowShader;

using StringTools;

function onLoad()
{
  GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
	GameOverSubstate.loopSoundName = 'gameOver-pixel';
	GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
	GameOverSubstate.characterName = 'bf-pixel-dead';

  var bgSky:BGSprite = new BGSprite('backgrounds/weeb/erect/weebSky', -626, -78, 0.2, 0.2);
  bgSky.zIndex = 10;
  bgSky.setScale(6, 6, true);
	add(bgSky);
	bgSky.antialiasing = false;

  var bgSchool:BGSprite = new BGSprite('backgrounds/weeb/erect/weebSchool', -816, -38, 0.75, 0.75);
  bgSchool.zIndex = 20;
  bgSchool.setScale(6, 6, true);
	add(bgSchool);
	bgSchool.antialiasing = false;

  var backTrees:BGSprite = new BGSprite('backgrounds/weeb/erect/weebBackTrees', -842, -80, 0.5, 0.5);
  backTrees.zIndex = 15;
  backTrees.setScale(6, 6, true);
	add(backTrees);
	backTrees.antialiasing = false;

  var bgStreet:BGSprite = new BGSprite('backgrounds/weeb/erect/weebStreet', -662, 6, 1, 1);
  bgStreet.zIndex = 30;
  bgStreet.setScale(6, 6, true);
	add(bgStreet);
	bgStreet.antialiasing = false;

  if (!ClientPrefs.lowQuality)
	{
		var fgTrees:BGSprite = new BGSprite('backgrounds/weeb/erect/weebTreesBack', -500, 6, 1, 1);
    fgTrees.zIndex = 40;
    fgTrees.setScale(6, 6, true);
		add(fgTrees);
		fgTrees.antialiasing = false;
	}
	
	var bgTrees:FlxSprite = new FlxSprite(-806, -1050);
	bgTrees.frames = Paths.getPackerAtlas('backgrounds/weeb/erect/weebTrees');
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);
  bgTrees.zIndex = 60;
  bgTrees.setScale(6, 6, true);
	add(bgTrees);
	bgTrees.antialiasing = false;

  if (!ClientPrefs.lowQuality)
	{
		var treeLeaves:BGSprite = new BGSprite('backgrounds/weeb/erect/petals', -20, -40, 0.85, 0.85, ['PETALS ALL'], true);
    treeLeaves.zIndex = 70;
		treeLeaves.setScale(6, 6, true);
		add(treeLeaves);
		treeLeaves.antialiasing = false;
	}
}

function onCreatePost()
{
  initScript('data/scripts/pixelUI');
  
  addShaderToCharacter(dad);
  addShaderToCharacter(boyfriend);
  addShaderToCharacter(gf);
}

function addShaderToCharacter(char:Character)
{
  var rim = new DropShadowShader();
  rim.setAdjustColor(-66, -10, 24, -23);
  rim.color = 0xFF52351d;
  rim.antialiasAmt = 0;
  rim.attachedSprite = char;
  rim.distance = 5;
  
  switch (char)
  {
    case boyfriend:
      rim.angle = 90;
      boyfriend.shader = rim;

      if (boyfriend.curCharacter == 'pico-pixel')
      {
        rim.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/picoPixel_mask'));
      }
      else
      {
        rim.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/bfPixel_mask'));
      }

      rim.maskThreshold = 1;
      rim.useAltMask = true;

      boyfriend.animation.onFrameChange.add(function()
      {
        rim.updateFrameInfo(boyfriend.frame);
      });

    case gf:
      rim.setAdjustColor(-42, -10, 5, -25);
      rim.angle = 90;
      gf.shader = rim;
      rim.distance = 3;
      rim.threshold = 0.3;

      if (gf.curCharacter == 'nene-pixel')
      {
        rim.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/nenePixel_mask'));
      }
      else
      {
        rim.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/gfPixel_mask'));
      }

      rim.maskThreshold = 1;
      rim.useAltMask = true;

      gf.animation.onFrameChange.add(function()
      {
        rim.updateFrameInfo(gf.frame);
      });

    case dad:
      rim.angle = 90;
      dad.shader = rim;

      rim.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/senpai_mask'));
      rim.maskThreshold = 1;
      rim.useAltMask = true;

      dad.animation.onFrameChange.add(function()
      {
        if (dad != null)
        {
          rim.updateFrameInfo(dad.frame);
        }
      });
  }
}