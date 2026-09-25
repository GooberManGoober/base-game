import funkin.objects.Bopper;
import funkin.game.shaders.DropShadowShader;
import funkin.data.Chart;
import funkin.objects.stageobjects.TankmenBG;

import flixel.util.FlxTimerManager;

import haxe.ds.ArraySort;

using StringTools;

var bg:FlxSprite;
var sniper:FlxSprite;
var guy:FlxSprite;
var tankBricks:FlxSprite;

var anims:Array<String> = ['shoot1', 'shoot2', 'shoot3', 'shoot4'];
var otisAnims:Array<CrowdAnim> = [];
var chart:Song = null;

var hasPlayedInGameCutscene = true;
var cutsceneSkipped:Bool = false;
var canSkipCutscene:Bool = false;

var cutsceneMusic:FunkinSound;
var can = true;
var skipText:FlxText;
var cutsceneAnim:Bopper;
var cutsceneTimerManager:FlxTimerManager;

typedef CrowdAnim =
{
	var time:Float;
	var data:Int;
	var length:Int;
}

function onLoad()
{
	bg = new FlxSprite(-985, -805);
	bg.loadGraphic(Paths.image("backgrounds/tank/erect/bg"));
	bg.scale.set(1.15, 1.15);
	bg.scrollFactor.set(1, 1);
	bg.antialiasing = true;
	add(bg);

	function onSniperAnimFinish(animName:String)
	{
		if (animName == "sip") sniper.dance();
	}
	
	sniper = new Bopper(-300, 200).loadAtlas('backgrounds/tank/erect/sniper');
	sniper.addAnimByPrefix("idle", "Idle", 24, false);
	sniper.addAnimByPrefix("sip", "Sip", 24, false);
	sniper.playAnim("idle");
	sniper.onAnimationFinish.add(onSniperAnimFinish);
	sniper.scale.set(1.15, 1.15);
	sniper.scrollFactor.set(1, 1);
	sniper.antialiasing = true;
	add(sniper);

	sniper.onAnimationFinish.dispatch("sip");
	
	tankmanRun = new FlxTypedGroup();
	add(tankmanRun);
	
	guy = new Bopper(1175, 280).loadAtlas('backgrounds/tank/erect/rando');
	guy.addAnimByPrefix("idle", "rando", 24, true);
	guy.playAnim("idle");
	guy.scale.set(1.15, 1.15);
	guy.scrollFactor.set(1, 1);
	guy.antialiasing = true;
	add(guy);
	
	tankBricks = new FlxSprite(250, 650);
	tankBricks.loadGraphic(Paths.image("backgrounds/tank/erect/bricksGround"));
	tankBricks.setScale(1.15, 1.15, true);
	tankBricks.scrollFactor.set(1, 1);
	tankBricks.flipX = true;
	tankBricks.antialiasing = true;
	add(tankBricks);
	
	bg.zIndex = 10;
	sniper.zIndex = 20;
	guy.zIndex = 20;
	tankmanRun.zIndex = 30;
	tankBricks.zIndex = 101;

	if (songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)") songEndCallback = loadEndcutscene;
}

function makeRimForSpr(spr, angle:Float = 0)
{
	if (spr.animateAtlas != null) spr.animateAtlas.useRenderTexture = true;
	
	rim = new DropShadowShader();
	rim.setAdjustColor(-46, -38, -25, -20);
	rim.color = 0xFFDFEF3C;
	rim.angle = angle;
	rim.attachedSprite = spr;
	spr.shader = rim;
	
	return rim;
}

function onCreatePost()
{
	var dadrim = makeRimForSpr(dad, 25);
	dadrim.threshold = 0.3;
	dad.animation.onFrameChange.add(() -> {
		dadrim.updateFrameInfo(dad.frame);
	});
	
	var bfRim = makeRimForSpr(boyfriend, 90);
	boyfriend.animation.onFrameChange.add(() -> {
		bfRim.updateFrameInfo(boyfriend.frame);
	});
	
	var gfRim = makeRimForSpr(gf, 90);
	gf.animation.onFrameChange.add(() -> {
		gfRim.updateFrameInfo(gf.frame);
	});

	rim.loadAltMask(Paths.image('backgrounds/tank/erect/masks/neneTankmen_mask'));
	rim.maskThreshold = 0.4;
	rim.useAltMask = true;
	
	for (i in [dad, gf, boyfriend])
	{
		i.shader.distance = 0;
		FlxTween.tween(i.shader, {distance: 15}, 1);
		
	}
	
	if (songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)")
	{
		chart = Chart.fromPath(Paths.json('stress-(pico-mix)/charts/picospeaker'));
		if (chart != null)
		{
			for (section in chart.notes)
			{
				for (note in section.sectionNotes)
				{
					otisAnims.push(
						{
							time: note[0],
							data: Math.floor(note[1] % 4),
							length: note[2]
						});
				}
			}
		}
		
		ArraySort.sort(otisAnims, (a, b) -> {
			if (a.time < b.time) return -1;
			else if (a.time > b.time) return 1;
			return 0;
		});
		
		if (!ClientPrefs.lowQuality)
		{
			var firstTank:TankmenBG = new TankmenBG(20, 500, true);
			firstTank.resetShit(-200, 600, true);
			firstTank.strumTime = 10;
			firstTank.visible = false;
			tankmanRun.add(firstTank);
			
			for (i in 0...otisAnims.length)
			{
				final goingRight = otisAnims[i].data < 2;
				
				if (FlxG.random.bool(20))
				{
					var tankBih = tankmanRun.recycle(TankmenBG);
					tankBih.strumTime = otisAnims[i].time;
					tankBih.setScale(1, 1);
					tankBih.resetShit(0, 130, goingRight);
					tankBih.endingOffset = goingRight ? 160 : 10;
					tankBih.endAnimOffset = goingRight ? [300, 200] : [270, 200];
					tankBih.visible = true;
					
					var rim = makeRimForSpr(tankBih, 90);
					rim.distance = 10;
					tankBih.animation.onFrameChange.add(() -> {
						rim.updateFrameInfo(tankBih.frame);
					});
					
					tankmanRun.add(tankBih);
				}
			}
		}
	}
}

function onStepHit()
{
	if (songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)")
	{
		if (curStep >= 763)
		{
			dad.animSuffix = '-bloody';
			iconP2.changeIcon('tankman-bloody');
		}
	}
}

function onBeatHit()
{
	if (FlxG.random.bool(2)) sniper.playAnim('sip', true);

	if (sniper.getAnimName() != "sip") sniper.onBeatHit(curBeat);
}

function updateOtisCharts()
{
	if (otisAnims.length != 0 && otisAnims[0].time <= Conductor.songPosition)
	{
		var data = otisAnims[0];
		
		var animToPlay:String = anims[data.data];
		gf.holdTimer = 0;
		gf.playAnim(animToPlay, true);
		var holdingTime = Conductor.songPosition - data.time;
		if (data.length == 0 || data.length < holdingTime) otisAnims.shift();
	}
}

function onUpdate(elapsed)
{
	if (songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)") updateOtisCharts();

	if (cutsceneTimerManager != null) cutsceneTimerManager.update(elapsed);
	
	if (!hasPlayedInGameCutscene)
	{
		if ((controls.ACCEPT || FlxG.keys.justPressed.Z) && !cutsceneSkipped)
		{
			if (!canSkipCutscene)
			{
				if (skipText != null)
				{
					FlxTween.tween(skipText, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
					new FlxTimer().start(0.5, _ ->
					{
						canSkipCutscene = true;
					});
				}
			}
		}
		if ((controls.ACCEPT || FlxG.keys.justPressed.Z) && !cutsceneSkipped && canSkipCutscene)
		{
			skipCutscene();
		}
	}
}

function onStartCountdown()
{
	if (can && songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)")
	{
		cutsceneMusic = FunkinSound.load(Paths.sound('week7/stressPicoCutscene'), 1);
		
		camHUD.alpha = 0;

		cutsceneTimerManager = new FlxTimerManager();

		skipText = new FlxText(936, 618, 0, 'Skip [ Z ]', 20);

		skipText.setFormat(Paths.font('vcr.ttf'), 40, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		skipText.scrollFactor.set();
		skipText.borderSize = 2;
		skipText.alpha = 0;
		add(skipText);

		skipText.cameras = [camOther];

		hasPlayedInGameCutscene = false;
		
		cutsceneAnim = new Bopper(-320, -885).loadAtlas('cutscenes/stress-pico-mix');
		cutsceneAnim.addAnimByPrefix('play', 'full scene ', 24, false);
		cutsceneAnim.zIndex = 99999;
		// cutsceneAnim.angularVelocity = 200;
		stage.add(cutsceneAnim);
		
		var rim = makeRimForSpr(cutsceneAnim, 90);
		rim.threshold = 0.3;
		rim.distance = 0;
		
		dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = false;

		camFollowTween.cancel();
		isCameraOnForcedPos = true;
		camFollowPoint.set(getCharacterCameraPos(dad).x + 350, getCharacterCameraPos(dad).y);
		FlxG.camera.snapToTarget();

		new FlxTimer(cutsceneTimerManager).start(0.01, () -> {
			cutsceneMusic.play(false);
			cutsceneAnim.playAnim('play');
		});

		new FlxTimer(cutsceneTimerManager).start(6.308, () -> {
			camChangeZoom(1.2, 0.5, FlxEase.quartInOut);
			focusCamera("position", camFollowPoint.x, camFollowPoint.y - 120, 0.75, "quartInOut", true);
		});

		new FlxTimer(cutsceneTimerManager).start(8.559, () -> {
			focusCamera("position", camFollowPoint.x - 40, camFollowPoint.y, 1.9, "expoOut", true);
		});

		new FlxTimer(cutsceneTimerManager).start(11.159, () -> {
			cameraSpeed = 0.3;
					
			camChangeZoom(0.74, 2.8, FlxEase.quartInOut);
			focusCamera("position", camFollowPoint.x, camFollowPoint.y - 200, 2.8, "quartInOut", true);
		});

		new FlxTimer(cutsceneTimerManager).start(13.639, () -> {
			cameraSpeed = 1;
					
			camChangeZoom(0.9125, 0.4 * 1.5, FlxEase.bounceOut);
			focusCamera("player", 0, 0, 4, "CLASSIC", true);
		});

		new FlxTimer(cutsceneTimerManager).start(24.119, () -> {
			camChangeZoom(0.8, 0.7, FlxEase.quartInOut);
			focusCamera("opponent", 0, 0, 0.7 * 1.5, "quartInOut", true);
		});

		new FlxTimer(cutsceneTimerManager).start(27.889, () -> {
			focusCamera("position", camFollowPoint.x - 30, camFollowPoint.y, 1.9 * 1.5, "expoOut", true);
			camGame.shake(0.05, 0.01);

			cutsceneSkipped = true;
			canSkipCutscene = false;
			FlxTween.tween(skipText, {alpha: 0}, 0.5, {
				ease: FlxEase.quadIn,
				onComplete: _ ->
				{
					skipText.visible = false;
				}
			});
		});

		new FlxTimer(cutsceneTimerManager).start(31.378, () -> {
			camChangeZoom(0.7, 0.7, FlxEase.quadInOut);
			focusCamera("opponent", 440, 0, 0.7 * 1.5, "quadInOut", true);
		});

		new FlxTimer(cutsceneTimerManager).start(33.047, () -> {
			FlxTween.tween(camHUD, {alpha: 1}, 0.6);
			can = false;
			hasPlayedInGameCutscene = true;
			startCountdown();
			cutsceneMusic.stop();
		});
		
		cutsceneAnim.onAnimationFinish.add(() -> {
			cutsceneAnim.visible = false;
			dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = true;
			
			for (i in [dad, gf, boyfriend])
			{
				i.shader.distance = 0;
				
				FlxTween.tween(i.shader, {distance: 15}, 1);
			}
		});
		
		return ScriptConstants.STOP_FUNC;
	}
}

function skipCutscene()
{
	cutsceneSkipped = true;
	hasPlayedCutscene = true;
	camOther.fade(0xFF000000, 0.5, false, null, true);
	cutsceneMusic.fadeOut(0.5, 0);

	new FlxTimer().start(0.5, _ ->
	{
		camOther.fade(0xFF000000, 0.5, true, null, true);
		camFollowPoint.x = getCharacterCameraPos(dad).x;
		camFollowPoint.y = getCharacterCameraPos(dad).y;
		
		cutsceneTimerManager.clear();
		cutsceneMusic.stop();

		skipText.visible = false;

		canDoPicoShit = false;

		defaultCamZoom = 0.7;

		canPause = true;
		
		cutsceneAnim.visible = false;
		dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = true;
		
		for (i in [dad, gf, boyfriend])
		{
			i.shader.distance = 0;
			
			FlxTween.tween(i.shader, {distance: 15}, 1);
		}

		cameraSpeed = 1;
		FlxTween.tween(camHUD, {alpha: 1}, 0.6);
		can = false;
		hasPlayedInGameCutscene = true;
		startCountdown();
	});
}

var bgSprite:FlxSprite;

function loadEndcutscene()
{
	// trace('Adding black background behind cutscene over UI');
	bgSprite = new FlxSprite(0, 0).makeGraphic(2000, 2500, 0xFF000000);
	bgSprite.cameras = [camOther]; // Show over the HUD but below the video.
	// this
	bgSprite.zIndex = -10000;
	add(bgSprite);
	bgSprite.alpha = 0;

	startEndCutscene();
}

function startEndCutscene()
{
	var picoPos:Array<Float> = [getCharacterCameraPos(boyfriend).x, getCharacterCameraPos(boyfriend).y];
	var otisPos:Array<Float> = [getGFCameraPos().x, getGFCameraPos().y];
	var tankmanPos:Array<Float> = [getCharacterCameraPos(dad).x, getCharacterCameraPos(dad).y];

	// Disable player input during cutscene, so you can't get a gameover during cutscene
	inCutscene = true;
	camHUD.visible = false;

	focusCamera("position", tankmanPos[0] + 320, tankmanPos[1] - 70, 2.8, "expoOut", true);
	camChangeZoom(0.65, 2, FlxEase.expoOut);

	new FlxTimer().start(0.1, _ ->
	{
		dad.playAnim('stressPicoEnding', true);
		FlxG.sound.play(Paths.sound('week7/erect/endCutscene'), 1.0);
	});

	new FlxTimer().start(7.433333333, _ ->
	{
		boyfriend.playAnim('laughEnd', true);
	});

	new FlxTimer().start(11.35, _ ->
	{
		focusCamera("position", tankmanPos[0] + 320, tankmanPos[1] - 370, 2, "quadInOut", true);
		FlxTween.tween(bgSprite, {alpha: 1}, 2);
	});

	new FlxTimer().start(13.1, _ ->
	{
		endSong();
	});
}

function deathAnimStart(volume)
{
	FlxG.sound.music.volume = 0.2;
	var exclude:Array<Int> = [];
	// if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

	var path:String = 'week7/jeffGameover/jeffGameover-';
	if (boyfriend.curCharacter.startsWith('pico')) path = 'week7/jeffGameover-pico/jeffGameover-';

	var maxArray = 25;
	if (boyfriend.curCharacter.startsWith('pico')) maxArray = 10;
	
	FlxG.sound.play(Paths.sound(path + FlxG.random.int(1, maxArray, exclude)), 1, false, null, true, function() {
		if (!GameOverSubstate.instance.isEnding) FlxTween.tween(FlxG.sound.music, {volume: 1}, 6);
	});
}
