import funkin.objects.BGSprite;
import funkin.states.substates.GameOverSubstate;
import funkin.objects.stageobjects.TankmenBG;
import funkin.data.Chart;
import funkin.objects.Bopper;
import flixel.addons.display.FlxTiledSprite;
import flixel.math.FlxAngle;

import flixel.util.FlxSort;

import haxe.ds.ArraySort;

var clouds:FlxTiledSprite;
var watchtower:BGSprite;
var tankRolling:FlxSprite;
var tankmanRun:FlxTypedGroup;
var anims:Array<String> = ['shoot1', 'shoot2', 'shoot3', 'shoot4'];
var boppers:Array<FlxSprite> = [];

// pico stuff
var picoAnims:Array<CrowdAnim> = [];
var chart:Song = null;

typedef CrowdAnim =
{
	var time:Float;
	var data:Int;
	var length:Int;
}

function onLoad()
{
	var sky:FlxSprite = new FlxSprite(-1000, -400).loadGraphic(Paths.image('backgrounds/tank/tankSky'));
	sky.setScale(3000, 1, true);
	sky.scrollFactor.set(0, 0);
	sky.zIndex = 10;
	add(sky);

	var solid:FlxSprite = new FlxSprite(-500, -1000).makeGraphic(2400, 2000, FlxColor.fromString('#E3A26D'));
	solid.scrollFactor.set(0, 0);
	solid.setScale(2400, 2000, true);
	add(solid);

	if (!ClientPrefs.lowQuality)
	{
		var mountains:FlxSprite = new FlxSprite(-500, -35).loadGraphic(Paths.image('backgrounds/tank/mountains2'));
		mountains.scrollFactor.set(0.2, 0.2);
		mountains.setScale(1.2, 1.2, true);
		mountains.zIndex = 11;
		add(mountains);

		clouds = new FlxTiledSprite(Paths.image('backgrounds/tank/tankClouds'), 3200, 235, true, false);
		clouds.setPosition(-1100, 20);
		clouds.scrollFactor.set(0.25, 0.25);
		clouds.zIndex = 12;
		clouds.velocity.x = 8;
		add(clouds);

		var buildings:FlxSprite = new FlxSprite(-260, -35).loadGraphic(Paths.image('backgrounds/tank/tankBuildings'));
		buildings.scrollFactor.set(0.3, 0.3);
		buildings.setScale(1.1, 1.1, true);
		buildings.zIndex = 13;
		add(buildings);
	}

	var ruins:FlxSprite = new FlxSprite(-200, 150).loadGraphic(Paths.image('backgrounds/tank/cityruins2'));
	ruins.scrollFactor.set(0.35, 0.35);
	ruins.setScale(1.1, 1.1, true);
	ruins.zIndex = 13;
	add(ruins);

	var clouds2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/tank/tankClouds'));
	clouds2.scrollFactor.set(0.4, 0.4);
	clouds2.zIndex = 11;
	clouds2.alpha = 0;
	add(clouds2);

	if (!ClientPrefs.lowQuality)
	{
		var smokeLeft:FlxSprite = new FlxSprite(-380, -40);
		smokeLeft.frames = Paths.getSparrowAtlas('backgrounds/tank/smokeLeft');
		smokeLeft.animation.addByPrefix('smokeLeft', 'SmokeBlurLeft', 24, true);
		smokeLeft.animation.play('smokeLeft');
		smokeLeft.scrollFactor.set(0.4, 0.4);
		smokeLeft.zIndex = 14;
		add(smokeLeft);

		var smokeRight:FlxSprite = new FlxSprite(1050, -35);
		smokeRight.frames = Paths.getSparrowAtlas('backgrounds/tank/smokeRight');
		smokeRight.animation.addByPrefix('smokeRight', 'SmokeRight', 24, true);
		smokeRight.animation.play('smokeRight');
		smokeRight.scrollFactor.set(0.4, 0.4);
		smokeRight.zIndex = 15;
		add(smokeRight);

		watchtower = new BGSprite('backgrounds/tank/tankWatchtower', -35, 110, 0.5, 0.5, ['watchtower gradient color']);
		watchtower.setScale(0.85, 0.85, true);
		watchtower.zIndex = 21;
		add(watchtower);
	}

	tankRolling = new FlxSprite(300, 300);
	tankRolling.frames = Paths.getSparrowAtlas('backgrounds/tank/tankRolling');
	tankRolling.animation.addByPrefix('roll', 'BG tank w lighting', 24, true);
	tankRolling.animation.play('roll');
	tankRolling.scrollFactor.set(0.5, 0.5);
	tankRolling.zIndex = 22;
	add(tankRolling);

	tankmanRun = new FlxTypedGroup();
	tankmanRun.zIndex = 30;
	add(tankmanRun);

	var tankGround:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('backgrounds/tank/tankGround'));
	tankGround.scrollFactor.set(1, 1);
	tankGround.setScale(1.15, 1.15, true);
	tankGround.zIndex = 40;
	add(tankGround);
	moveTank();

	var tankBricks:FlxSprite = new FlxSprite(438, 715).loadGraphic(Paths.image('backgrounds/tank/bricksGround'));
	tankBricks.scrollFactor.set(1, 1);
	tankBricks.setScale(1.15, 1.15, true);
	tankBricks.zIndex = 101;
	add(tankBricks);

	var tankmanAudience0 = new BGSprite('backgrounds/tank/tank0', -500, 650, 1.7, 1.5, ['fg tankhead far right instance 1']);
	tankmanAudience0.zIndex = 1000;
	add(tankmanAudience0);
	
	var tankAudience2 = new BGSprite('backgrounds/tank/tank2', 360, 980, 1.5, 1.5, ['foreground man 3 instance 1']);
	tankAudience2.zIndex = 1002;
	add(tankAudience2);
	
	var tankAudience4 = new BGSprite('backgrounds/tank/tank4', 1200, 900, 1.5, 1.5, ['fg tankman bobbin 3 instance 1']);
	tankAudience4.zIndex = 1004;
	add(tankAudience4);
	
	boppers = [tankmanAudience0, tankAudience2, tankAudience4];

	if (!ClientPrefs.lowQuality)
	{
		var tankAudience3 = new BGSprite('backgrounds/tank/tank3', 1050, 1240, 3.5, 2.5, ['fg tankhead 4 instance 1']);
		tankAudience3.zIndex = 1016;
		add(tankAudience3);
		boppers.push(tankAudience3);

		var tankmanAudience1 = new BGSprite('backgrounds/tank/tank1', -300, 750, 2, 0.2, ['fg tankhead 5 instance 1']);
		tankmanAudience1.zIndex = 1100;
		add(tankmanAudience1);
		boppers.push(tankmanAudience1);
		
		var tankmanAudience5 = new BGSprite('backgrounds/tank/tank5', 1550, 700, 1.5, 1.5, ['fg tankhead far right instance 1']);
		tankmanAudience5.zIndex = 1003;
		add(tankmanAudience5);
		boppers.push(tankmanAudience5);
	}

	tankAngle = FlxG.random.int(-90, 45);
    tankSpeed = FlxG.random.float(5, 7);

	GameOverSubstate.resetVariables();
}

function onCreatePost()
{
	if (curSong.toLowerCase() == 'stress')
	{
		GameOverSubstate.characterName = 'bf-holding-gf-dead';
		
		gf.skipDance = true;
		chart = Chart.fromPath(Paths.json('stress/charts/picospeaker'));
		if (chart != null)
		{
			for (section in chart.notes)
			{
				for (note in section.sectionNotes)
				{
					picoAnims.push(
						{
							time: note[0],
							data: Math.floor(note[1] % 4),
							length: note[2]
						});
				}
			}
		}
		
		ArraySort.sort(picoAnims, (a, b) -> {
			if (a.time < b.time) return -1;
			else if (a.time > b.time) return 1;
			return 0;
		});
		
		gf.playAnim("shoot1");
		
		if (!ClientPrefs.lowQuality)
		{
			var firstTank:TankmenBG = new TankmenBG(20, 500, true);
			firstTank.resetShit(20, 600, true);
			firstTank.strumTime = 10;
			tankmanRun.add(firstTank);
			
			for (i in 0...picoAnims.length)
			{
				if (FlxG.random.bool(16))
				{
					var tankBih = tankmanRun.recycle(TankmenBG);
					tankBih.strumTime = picoAnims[i].time;
					tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), picoAnims[i].data < 2);
					tankmanRun.add(tankBih);
				}
			}
		}
	}
}

function onUpdate(elapsed)
{
	moveTank(elapsed);
	updatePicoChart();
}

function updatePicoChart()
{
	if (picoAnims.length != 0 && picoAnims[0].time <= Conductor.songPosition)
	{
		var data = picoAnims[0];
		
		var animToPlay:String = anims[data.data];
		gf.holdTimer = 0;
		gf.playAnim(animToPlay, true);
		var holdingTime = Conductor.songPosition - data.time;
		if (data.length == 0 || data.length < holdingTime) picoAnims.shift();
	}
}

var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankX:Float = 400;

function moveTank(?elapsed:Float = 0)
{
	if (!inCutscene)
	{
		var daAngleOffset:Float = 1;
		tankAngle += elapsed * tankSpeed;

		tankRolling.angle = tankAngle - 90 + 15;
		tankRolling.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
		tankRolling.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
	}
}

function onBeatHit()
{
	watchtower.dance();
	
	for (i in boppers)
	{
		if (i != null) i.dance();
	}
}

function deathAnimStart(volume)
{
	FlxG.sound.music.volume = 0.2;
	var exclude:Array<Int> = [];
	// if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];
	
	FlxG.sound.play(Paths.sound('week7/jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
		if (!GameOverSubstate.instance.isEnding) FlxTween.tween(FlxG.sound.music, {volume: 1}, 6);
	});
}

var allowCountdown:Bool = !PlayState.isStoryMode;

function onStartCountdown()
{
	if (!allowCountdown)
	{
		tankIntro();
		return Function_Stop;
	}
}

function tankIntro()
{
	var songName:String = curSong.toLowerCase();
	dadGroup.alpha = 0.00001;
	camHUD.visible = false;
	snapCamToPos(dad.x + 280, dad.y + 170, true);
	
	var tankman = new Character(dad.x, dad.y, 'tankman-cutscene');
	tankman.zIndex = 102;
	stage.add(tankman);
	
	switch (songName)
	{
		case 'ugh':
			// dad.alpha = 1;
			
			tankman.playAnim('ugh1');
			// tankman.alpha = 0.5;
			// tankman.anim.pause();
			
			// FlxG.sound.play(Paths.music('DISTORTO'));
			FunkinSound.playMusic(Paths.music('week7/DISTORTO'));
			FlxG.sound.play(Paths.sound('week7/wellWellWell'));
			
			defaultCamZoom *= 1.2;
			
			FlxTimer.wait(3, () -> {
				focusCamera("position", camFollowPoint.x + 550, camFollowPoint.y + 50, 1.9, "expoOut", true);
			});
			
			FlxTimer.wait(4.5, () -> {
				boyfriend.playAnim('singUP', true);
				boyfriend.specialAnim = true;
				FlxG.sound.play(Paths.sound('week7/bfBeep'));
			});
			
			FlxTimer.wait(6, () -> {
				focusCamera("position", camFollowPoint.x - 550, camFollowPoint.y - 50, 1.9, "expoOut", true);
				
				tankman.playAnim('ugh2');
				FlxG.sound.play(Paths.sound('week7/killYou'));
			});
			
			FlxTimer.wait(12, () -> {
				tankman.visible = false;
				tankman.destroy();
				endScene();
			});
		case 'guns':
			tankman.playAnim('guns');
			FlxG.sound.play(Paths.sound('week7/tankSong2'));
			FunkinSound.playMusic(Paths.music('week7/DISTORTO'));

			camChangeZoom(defaultCamZoom * 1.2, 4, FlxEase.quadInOut);
			
			FlxTimer.wait(4, () -> {
				camChangeZoom(defaultCamZoom * 1.2, 0.5, FlxEase.quadInOut);
				gf.playAnim('sad', true);
				gf.animation.finishCallback = function(name:String) {
					gf.playAnim('sad', true);
				};
			});

			FlxTimer.wait(4.5, () -> {
				camChangeZoom(defaultCamZoom / 1.2, 1, FlxEase.quadInOut);
			});
			
			tankman.onAnimationFinish.add((spr) -> {
				tankman.visible = false;
				tankman.kill();
				endScene();
			});
		case 'stress':
			gfGroup.alpha = 0.00001;
			boyfriendGroup.alpha = 0.00001;
			
			var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
			
			var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
			
			if (!ClientPrefs.lowQuality)
			{
				gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
				gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
				gfDance.animation.play('dance', true);
				gfDance.zIndex = 100;
				stage.add(gfDance);
			}
			
			gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
			gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
			gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
			gfCutscene.animation.play('dieBitch', true);
			gfCutscene.animation.pause();
			gfCutscene.alpha = 0;
			gfCutscene.zIndex = 100;
			stage.add(gfCutscene);
			
			picoCutscene = new Bopper(gf.x - 849, gf.y - 264).loadAtlas('cutscenes/stressPico');
			picoCutscene.addAnimByPrefix('anim', 'PicoAtlas', 24, false);
			picoCutscene.alpha = 0;
			picoCutscene.zIndex = 100;
			stage.add(picoCutscene);
			
			var boyfriendCutscene:Bopper = new Bopper(boyfriend.x + 5, boyfriend.y + 20).loadAtlas('characters/bf');
			boyfriendCutscene.addAnimByPrefix('idle', 'BF idle dance', 24, false);
			boyfriendCutscene.playAnim('idle', true);
			boyfriendCutscene.animation.curAnim.finish();
			boyfriendCutscene.zIndex = 102;
			stage.add(boyfriendCutscene);
			
			/* gfDance.zIndex = 1;
			gfCutscene.zIndex = 2;
			picoCutscene.zIndex = 3;
			boyfriendCutscene.zIndex = 5;
			gfGroup.zIndex = 6;
			tankman.zIndex = 7;
			dadGroup.zIndex = 8;
			boyfriendGroup.zIndex = 9; */
			refreshZ();
			
			var stressScene = new FlxSound().loadEmbedded(Paths.sound('week7/stressCutscene'));
			FlxG.sound.list.add(stressScene);
			
			// FunkinSound.playMusic(Paths.music('klaskii-romper'), 0.2);
			// FlxG.sound.music.fadeIn(2, 0.0125, 0.1);
			
			FlxTimer.wait(0.1, () -> {
				stressScene.play();
				tankman.playAnim('stress1');
			});
			snapCamToPos(dad.x + 400, dad.y + 170);

			camChangeZoom(0.9 * 1.2, 1, FlxEase.quadInOut);
			
			FlxTimer.wait(15.2, () -> {
				FlxTween.tween(camFollowPoint, {x: 650, y: 300}, 1.9, {ease: FlxEase.expoOut});
				camChangeZoom(0.9 * 1.2 * 1.2, 2.25, FlxEase.quadInOut);
				gfDance.visible = false;
				gfCutscene.alpha = 1;
				gfCutscene.animation.play('dieBitch', true);
				gfCutscene.animation.finishCallback = function(name:String) {
					if (name == 'dieBitch') // Next part
					{
						gfCutscene.animation.play('getRektLmao', true);
						gfCutscene.offset.set(224, 445);
					}
					else
					{
						gfCutscene.visible = false;
						picoCutscene.alpha = 1;
						picoCutscene.playAnim('anim');
						
						boyfriendGroup.alpha = 1;
						boyfriendCutscene.visible = false;
						boyfriend.playAnim('bfCatch', true);
						boyfriend.animation.finishCallback = function(name:String) {
							if (name != 'idle')
							{
								boyfriend.playAnim('idle', true);
								boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
							}
						};
						
						picoCutscene.onAnimationFinish.add(() -> {
							picoCutscene.visible = false;
							gfGroup.alpha = 1;
						});
						gfCutscene.animation.finishCallback = null;
					}
				}
			});
			
			FlxTimer.wait(17.5, zoomBack);
			FlxTimer.wait(19.5, () -> {
				tankman.playAnim('stress2', true);
			});
			FlxTimer.wait(20, () -> {
				if (camFollowTween != null) camFollowTween.cancel();
				camFollowTween = FlxTween.tween(camFollowPoint, {
					x: dad.x + 500,
					y: dad.y + 170
				}, 1.9, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {
						camFollowTween = null;
					}
				});
			});
			FlxTimer.wait(31.2, () -> {
				boyfriend.playAnim('singUPmiss', true);
				boyfriend.animation.finishCallback = function(name:String) {
					if (name == 'singUPmiss')
					{
						boyfriend.playAnim('idle', true);
						boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
					}
				};
				
				camFollowPoint.set(boyfriend.x + 280, boyfriend.y + 200);
				cameraSpeed = 12;
				camChangeZoom(1.25, 0.25, FlxEase.elasticOut);
			});
			FlxTimer.wait(32.2, () -> {
				snapCamToPos(630, 425);
				defaultCamZoom = 0.8;
			});
			
			FlxTimer.wait(35, () -> {
				for (i in [tankman, gfDance, gfCutscene, boyfriendCutscene])
				{
					i.visible = false;
					i.destroy();
				}
				endScene();
			});
	}
}

function endScene()
{
	isCameraOnForcedPos = false;
	camZooming = true;
	camChangeZoom(stage.stageData.defaultZoom, 1, FlxEase.sineInOut);
	dadGroup.alpha = 1;
	FlxG.sound.music.stop();
	camHUD.visible = true;
	allowCountdown = true;
	cameraSpeed = 1;
	startCountdown();
}

var calledTimes:Int = 0;

function zoomBack()
{
	var camPosX:Float = 630;
	var camPosY:Float = 425;
	camFollowPoint.set(camPosX, camPosY);
	defaultCamZoom = 0.8;
	cameraSpeed = 1;
	
	calledTimes += 1;
}
