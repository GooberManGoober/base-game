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
	
	tankBricks = new FlxSprite(465, 760);
	tankBricks.loadGraphic(Paths.image("backgrounds/tank/erect/bricksGround"));
	tankBricks.scale.set(1.15, 1.15);
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
}

var can = true;

function onStartCountdown()
{
	if (can && songName.toLowerCase().replace(' ', '-') == "stress-(pico-mix)")
	{
		camHUD.alpha = 0;
		
		var anim = new Bopper(-320, -885).loadAtlas('cutscenes/stress-pico-mix');
		anim.addAnimByPrefix('play', 'full scene ', 24, false);
		anim.playAnim('play');
		anim.zIndex = 99999;
		// anim.angularVelocity = 200;
		stage.add(anim);
		
		var rim = makeRimForSpr(anim, 90);
		rim.threshold = 0.3;
		rim.distance = 0;
		
		dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = false;

		camFollowTween.cancel();
		isCameraOnForcedPos = true;
		camFollowPoint.set(getCharacterCameraPos(dad).x + 350, getCharacterCameraPos(dad).y);
		FlxG.camera.snapToTarget();
		
		anim.onAnimationFrameChange.add((anim, frame) -> {
			switch (frame)
			{
				case 151:
					camChangeZoom(1.2, 0.5, FlxEase.quartInOut);
					FlxTween.tween(camFollowPoint, {y: camFollowPoint.y - 120}, 0.5 * 1.5, {ease: FlxEase.quartInOut});
				case 205:
					FlxTween.tween(camFollowPoint, {x: camFollowPoint.x - 40}, 1.9, {ease: FlxEase.expoOut});
				case 270:
					cameraSpeed = 0.3;
					
					camChangeZoom(0.74, 2.8, FlxEase.quartInOut);
					FlxTween.tween(camFollowPoint, {y: camFollowPoint.y - 200}, 2.8, {ease: FlxEase.quartInOut});
				case 326:
					cameraSpeed = 1;
					
					FlxTween.cancelTweensOf(camGame);
					FlxTween.cancelTweensOf(camFollowPoint);
					camChangeZoom(0.9125, 0.4 * 1.5, FlxEase.bounceOut);
					FlxTween.tween(camFollowPoint, {x: getCharacterCameraPos(boyfriend).x, y: getCharacterCameraPos(boyfriend).y}, 1.9, {ease: FlxEase.expoOut});
				case 579:
					FlxTween.cancelTweensOf(camGame);
					camChangeZoom(0.8, 0.7, FlxEase.quartInOut);
					FlxTween.tween(camFollowPoint, {x: getCharacterCameraPos(dad).x, y: camFollowPoint.y - 50}, 0.7 * 1.5, {ease: FlxEase.quartInOut});
				case 669:
					FlxTween.tween(camFollowPoint, {x: camFollowPoint.x - 30}, 1.9 * 1.5, {ease: FlxEase.expoOut});
					camGame.shake(0.05, 0.01);
				case 750:
					final pos = getCharacterCameraPos(dad);
					
					FlxTween.cancelTweensOf(camGame);
					camChangeZoom(0.7, 0.7, FlxEase.quadInOut);
					FlxTween.tween(camFollowPoint, {x: pos.x + 440, y: pos.y}, 0.7 * 1.5, {ease: FlxEase.quadInOut});
				case 790:
					FlxTween.tween(camHUD, {alpha: 1}, 0.6);
					can = false;
					startCountdown();
			}
		});
		
		anim.onAnimationFinish.add(() -> {
			anim.visible = false;
			dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = true;
			
			for (i in [dad, gf, boyfriend])
			{
				i.shader.distance = 0;
				
				FlxTween.tween(i.shader, {distance: 15}, 1);
			}
		});
		
		FlxG.sound.play(Paths.sound('week7/stressPicoCutscene'));
		
		return ScriptConstants.STOP_FUNC;
	}
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

	FlxTween.tween(camFollowPoint, {x: tankmanPos[0] + 320, y: tankmanPos[1] - 70}, 2.8, {ease: FlxEase.expoOut});
	FlxTween.tween(FlxG.camera, {zoom: 0.65}, 2, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {	
			defaultCamZoom = FlxG.camera.zoom;
		}
	});

	dad.playAnim('stressPicoEnding', true);
	FlxG.sound.play(Paths.sound('week7/erect/endCutscene'), 1.0);

	new FlxTimer().start(176 / 24, _ ->
	{
		boyfriend.playAnim('laughEnd', true);
	});

	new FlxTimer().start(270 / 24, _ ->
	{
		FlxTween.tween(camFollowPoint, {x: tankmanPos[0] + 320, y: tankmanPos[1] - 370}, 2, {ease: FlxEase.quadInOut});
		FlxTween.tween(bgSprite, {alpha: 1}, 2);
	});

	new FlxTimer().start(320 / 24, _ ->
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
