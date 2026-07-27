using StringTools;

var heyTimer:Float;
var upperBoppers:BGSprite;
var bottomBoppers:BGSprite;
var santa:BGSprite;

var hasPlayedCutscene:Bool = false;
var cutsceneSkipped:Bool = false;
var canSkipCutscene:Bool = false;
var santaSound:FunkinSound;
var shootSound:FunkinSound;

var controls = Controls.instance;

function onLoad()
{
	var bgWalls:BGSprite = new BGSprite('backgrounds/christmas/erect/bgWalls', -726, -566, 0.2, 0.2);
	bgWalls.setGraphicSize(Std.int(bgWalls.width * 0.9));
	bgWalls.updateHitbox();
	bgWalls.zIndex = 10;
	add(bgWalls);

	if (!ClientPrefs.lowQuality) {
		upperBoppers = new BGSprite('backgrounds/christmas/erect/upperBop', -374, -98, 0.28, 0.28, ['upperBop']);
		upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		upperBoppers.updateHitbox();
		upperBoppers.zIndex = 20;
		add(upperBoppers);

		var bgEscalator:BGSprite = new BGSprite('backgrounds/christmas/erect/bgEscalator', -1100, -540, 0.3, 0.3);
		bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		bgEscalator.updateHitbox();
		bgEscalator.zIndex = 30;
		add(bgEscalator);
	}

	var christmasTree:BGSprite = new BGSprite('backgrounds/christmas/erect/christmasTree', 370, -250, 0.40, 0.40);
	christmasTree.zIndex = 40;
	add(christmasTree);

	bottomBoppers = new FunkinSprite(-300, 140).loadAtlas("backgrounds/christmas/erect/bottomBop");
	bottomBoppers.addAnimByPrefix("idle", "BOPPERS_EXPORT", 24, false);
	bottomBoppers.scrollFactor.set(0.9, 0.9);
	bottomBoppers.zIndex = 50;
	add(bottomBoppers);

	var fog:BGSprite = new BGSprite('backgrounds/christmas/erect/white', -1000, 100, 0.85, 0.85);
	fog.zIndex = 49;
	// add(fog);

	var fgSnow:BGSprite = new BGSprite('backgrounds/christmas/fgSnow', -600, 700);
	fgSnow.scale.set(1.1, 1);
	fgSnow.zIndex = 60;
	add(fgSnow);
	
	var snowUnder:FlxSprite = new FlxSprite(-1500, 800).makeGraphic(5700, 3000, 0xFFF3F4F5);
	snowUnder.zIndex = 59;
	add(snowUnder);

	santa = new BGSprite('backgrounds/christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
	santa.zIndex = 210;
	add(santa);

	if (songName.toLowerCase().replace(' ', '-') == "eggnog-erect") songEndCallback = startCutscene;
}

function onCreatePost()
{
	// Create a single color shader and reuse it.
    colorShader = newShader('adjustColor');
    colorShader.setFloat('hue', 5);
    colorShader.setFloat('saturation', 20);

    santa.shader = colorShader;
	dad.shader = colorShader;
	gf.shader = colorShader;
	boyfriend.shader = colorShader;

    var colorShaderBoppers = newShader('adjustColor');
    colorShaderBoppers.setFloat('hue', 15);
    colorShaderBoppers.setFloat('brightness', 20);
    bottomBoppers.shader = colorShaderBoppers;
}

function onCountdownTick()
{
	if (!ClientPrefs.lowQuality) upperBoppers.dance(true);

	bottomBoppers.playAnim("idle", true);
	santa.dance(true);
}

function onBeatHit()
{
	if (!ClientPrefs.lowQuality) upperBoppers.dance(true);

	bottomBoppers.playAnim("idle", true);
	santa.dance(true);
}

var skipText:FlxText;

function startCutscene()
{
	camFollowTween.cancel();
	FlxTween.cancelTweensOf(FlxG.camera, ["zoom"]);
	
	skipText = new FlxText(821, 618, 0, 'Skip [ ACCEPT ]', 20);

	skipText.setFormat(Paths.font('vcr.ttf'), 40, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	skipText.scrollFactor.set();
	skipText.borderSize = 2;
	skipText.alpha = 0;
	add(skipText);

	skipText.cameras = [camOther];

	santa.visible = false;

	var santaDead:FunkinSprite = new FunkinSprite(0, 0).loadAtlas("backgrounds/christmas/santa_speaks_assets");
	santaDead.addAnimByPrefix("die", "santa whole scene");
	santaDead.x = -1300;
	santaDead.y = 100;
	santaDead.zIndex = santa.zIndex - 1;
	santaDead.shader = santa.shader;
	santaDead.playAnim("die", true);
	add(santaDead);

	dad.visible = false;

	var parentsShoot:FunkinSprite = new FunkinSprite(0, 0).loadAtlas("backgrounds/christmas/parents_shoot_assets");
	parentsShoot.addAnimByPrefix("shoot", "parents whole scene");
	parentsShoot.playAnim("shoot", true);
	parentsShoot.x = -602;
	parentsShoot.y = -3.5;
	parentsShoot.zIndex = santaDead.zIndex - 1;
	parentsShoot.shader = santa.shader;

	add(parentsShoot);
	refreshZ(); // Apply z-index.

	canPause = false;
	FlxTween.tween(camHUD, {alpha: 0}, 1);

	inCutscene = true;
	hasPlayedCutscene = true;

	isCameraOnForcedPos = true;
	camZooming = false;

	FlxTween.tween(camFollowPoint, {x: santaDead.x + 1200, y: santaDead.y + 300}, 2.8, {ease: FlxEase.expoOut});
	FlxTween.tween(FlxG.camera, {zoom: 0.73}, 2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) 
		{
			defaultCamzoom = 0.73;
		}
	});

	santaSound = FunkinSound.load(Paths.sound('week5/santa_emotion'), 1);
	santaSound.volume = 1;
	santaSound.play(false);

	shootSound = FunkinSound.load(Paths.sound('week5/santa_shot_n_falls'), 1);
	shootSound.volume = 1;

	new FlxTimer().start(2.8, function(tmr)
	{
		FlxTween.tween(camFollowPoint, {x: santaDead.x + 1050, y: santaDead.y + 300}, 9, {ease: FlxEase.quartInOut});
		FlxTween.tween(FlxG.camera, {zoom: 0.79}, 9, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) 
			{
				defaultCamzoom = 0.79;
			}
		});
	});

	new FlxTimer().start(11.375, function(tmr)
	{
		if (!cutsceneSkipped) shootSound.play(false);
	});

	new FlxTimer().start(12.83, function(tmr)
	{
		camGame.shake(0.005, 0.2);
		FlxTween.tween(camFollowPoint, {x: santaDead.x + 1060, y: santaDead.y + 380}, 5, {ease: FlxEase.expoOut});
	});

	new FlxTimer().start(14, function(tmr)
	{
		camOther.fade(0xFF000000, 1, false, null, true);
	});

	new FlxTimer().start(16, function(tmr)
	{
		if (!cutsceneSkipped)
		{
			endSong();
		}
	});
}

function onUpdate(elapsed)
{
	if (skipText != null)
	{
		if (controls.ACCEPT && !cutsceneSkipped)
		{
			if (!canSkipCutscene)
			{
				FlxTween.tween(skipText, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
				new FlxTimer().start(0.5, _ ->
				{
					canSkipCutscene = true;
				});
			}
		}
	
		if (controls.ACCEPT && canSkipCutscene && !cutsceneSkipped)
		{
			camOther.fade(0xFF000000, 0.5, false, null, true);
			FlxTween.tween(skipText, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			cutsceneSkipped = true;
			santaSound.stop();
			shootSound.stop();
			new FlxTimer().start(0.5, function(tmr)
			{
				endSong();
			});
		}
	}
}
