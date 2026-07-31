import funkin.objects.FunkinSprite;
import flixel.util.FlxTimerManager;

import funkin.objects.stageobjects.PhillyGlow.PhillyGlowGradient;
import funkin.objects.stageobjects.PhillyGlow.PhillyGlowParticle;

var phillyLightsColors:Array<FlxColor> = [0xFFB66F43, 0xFF329A6D, 0xFF932C28, 0xFF2663AC, 0xFF502D64];
var phillyLightsColorsEvent:Array<FlxColor> = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
var phillyWindow:FlxSprite;
var phillyCityLightsGlow:FlxSprite;

var phillyStreet:FlxSprite;
var phillyTrain:FlxSprite;
var blammedLightsBlack:FlxSprite;
var phillyWindowEvent:FlxSprite;
var trainSound:FlxSound;
var colorShader:FlxRuntimeShader;

var trainEnabled:Bool = true;

var phillyGlowGradient:PhillyGlowGradient;
var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;

var curLight:Int = -1;
var curLightEvent:Int = -1;

var hasPlayedInGameCutscene = true;
var cutsceneSkipped:Bool = false;
var canSkipCutscene:Bool = false;

var controls = Controls.instance;

/**
* Replay the cutscene after leaving the song.
*/
function onLoad()
{
	colorShader = newShader('adjustColor');
	colorShader.setFloat('hue', -26);
	colorShader.setFloat('saturation', -16);
	colorShader.setFloat('contrast', 0);
	colorShader.setFloat('brightness', -5);

	var sky:FlxSprite = new FlxSprite(-100, 0).loadGraphic(Paths.image("backgrounds/philly/erect/sky"));
	sky.zIndex = 10;
	sky.scrollFactor.set(0.1, 0.1);
	add(sky);

	var city:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image("backgrounds/philly/erect/city"));
	city.zIndex = 20;
	city.setScale(0.9, 0.9, true);
	city.scrollFactor.set(0.3, 0.3);
	add(city);

	phillyWindow = new FlxSprite(-184, 155).loadGraphic(Paths.image("backgrounds/philly/window"));
	phillyWindow.zIndex = 30;
	phillyWindow.setScale(0.9, 0.9, true);
	phillyWindow.scrollFactor.set(0.3, 0.3);
	add(phillyWindow);

	phillyCityLightsGlow = new FlxSprite(-255, 45).loadGraphic(Paths.image("backgrounds/philly/windowWhiteGlow"));
	phillyCityLightsGlow.setScale(0.9, 0.9, true);
	phillyCityLightsGlow.scrollFactor.set(0.3, 0.3);
	phillyCityLightsGlow.blend = BlendMode.ADD;
	phillyCityLightsGlow.alpha = 0;
	phillyCityLightsGlow.zIndex = 31;
	add(phillyCityLightsGlow);

	randomizeLights();

	var behindTrain:FlxSprite = new FlxSprite(-299, 144).loadGraphic(Paths.image("backgrounds/philly/erect/behindTrain"));
	behindTrain.zIndex = 50;
	add(behindTrain);

	phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image("backgrounds/philly/train"));
	phillyTrain.zIndex = 60;
	phillyTrain.shader = colorShader;
	add(phillyTrain);

	phillyStreet = new FlxSprite(-299, 144).loadGraphic(Paths.image("backgrounds/philly/erect/street"));
	phillyStreet.zIndex = 70;
	add(phillyStreet);

	trainSound = new FlxSound().loadEmbedded(Paths.sound('week3/train_passes'));
	FlxG.sound.list.add(trainSound);
}

var cutsceneMusic:FunkinSound;

var picoPlayer:FunkinSprite;
var picoOpponent:FunkinSprite;
var bloodPool:FunkinSprite;
var cigarette:FlxSprite;

var skipText:FlxText;

var extendBloodPool:Bool = false;

var can = true;

var canDoPicoShit:Bool = false;
var playerShoot:Bool = FlxG.random.bool(50);
var explode:Bool = FlxG.random.bool(8);

var shooterCamPos:Array<Float>;
var cigarHolderCamPos:Array<Float>;

var cutsceneTimerManager:FlxTimerManager;

function onStartCountdown()
{
	if (can && boyfriend.curCharacter == 'pico-playable')
	{
		canDoPicoShit = true;
		camHUD.alpha = 0;

		skipText = new FlxText(821, 618, 0, 'Skip [ ACCEPT ]', 20);

		skipText.setFormat(Paths.font('vcr.ttf'), 40, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		skipText.scrollFactor.set();
		skipText.borderSize = 2;
		skipText.alpha = 0;
		add(skipText);

		skipText.cameras = [camOther];

		cutsceneTimerManager = new FlxTimerManager();

		cameraSpeed = 1.5;
		defaultCamZoom = 0.9;

		hasPlayedInGameCutscene = false;

		bloodPool = new FunkinSprite(0, 0).loadAtlas('backgrounds/philly/erect/bloodPool');
		bloodPool.addAnimByPrefix("bloodPool", "bloodPool", 24, false);
		bloodPool.alpha = 0;

		picoPlayer = new FunkinSprite(boyfriend.x - 537, boyfriend.y - 209).loadAtlas('backgrounds/philly/erect/pico_doppleganger');
		picoPlayer.addAnimByPrefix("shoot", "shootPlayer", 24, false);
		picoPlayer.addAnimByPrefix("cigarette", "cigarettePlayer", 24, false);
		picoPlayer.addAnimByPrefix("explode", "explodePlayer", 24, false);
		// picoPlayer.addAnimByPrefix("explodeLoop", "loopPlayer", 24, false);
		picoPlayer.scrollFactor.set(1, 1);
		picoPlayer.antialiasing = true;

		picoOpponent = new FunkinSprite(dad.x - 501, dad.y - 209).loadAtlas('backgrounds/philly/erect/pico_doppleganger');
		picoOpponent.addAnimByPrefix("shoot", "shootOpponent", 24, false);
		picoOpponent.addAnimByPrefix("cigarette", "cigaretteOpponent", 24, false);
		picoOpponent.addAnimByPrefix("explode", "explodeOpponent", 24, false);
		// picoOpponent.addAnimByPrefix("explodeLoop", "loopOpponent", 24, false);
		picoOpponent.scrollFactor.set(1, 1);
		picoOpponent.antialiasing = true;

		cigarette = new FlxSprite(0, 0);

		picoPlayer.zIndex = boyfriendGroup.zIndex + 1;

		if (playerShoot)
		{
			picoOpponent.zIndex = picoPlayer.zIndex - 1;
			bloodPool.zIndex = picoOpponent.zIndex - 1;
			cigarette.zIndex = dadGroup.zIndex - 2;
			
			bloodPool.setPosition(dadGroup.x - 190, dadGroup.y + 690);
			
			cigarette.setPosition(boyfriendGroup.x - 125, boyfriendGroup.y + 510);
			cigarette.flipX = true;
		}
		else
		{
			picoOpponent.zIndex = picoPlayer.zIndex + 1;
      		bloodPool.zIndex = picoOpponent.zIndex - 1;
      		cigarette.zIndex = dadGroup.zIndex - 1;
			
			bloodPool.setPosition(1300, 780);
			cigarette.setPosition(dadGroup.x - 25, boyfriendGroup.y + 510);
		}

		cigarette.frames = Paths.getSparrowAtlas('backgrounds/philly/erect/cigarette');
		cigarette.animation.addByPrefix('cigarette spit', 'cigarette spit', 24, false);
		cigarette.alpha = 0;

		add(cigarette);
		add(picoPlayer);
		add(picoOpponent);
		add(bloodPool);
		refreshZ();

		picoPlayer.shader = colorShader;
		picoOpponent.shader = colorShader;
	 	bloodPool.shader = colorShader;

		boyfriend.alpha = 0;
		dad.alpha = 0;

		if (!explode) cutsceneMusic = FunkinSound.load(Paths.music("week3/cutscene/cutscene"), 1);
		else cutsceneMusic = FunkinSound.load(Paths.music("week3/cutscene/cutscene2"), 1);
		cutsceneMusic.play(false);

		if (playerShoot)
		{
			cigarHolderCamPos = [getCharacterCameraPos(dad).x - 50, getCharacterCameraPos(dad).y];
			shooterCamPos = [getCharacterCameraPos(boyfriend).x, getCharacterCameraPos(boyfriend).y];
			
			if (picoPlayer != null)
				picoPlayer.playAnim("shoot", true, false, false);

			if (picoOpponent != null) 
			{
				if (explode) picoOpponent.playAnim("explode", true, false, false);
				else picoOpponent.playAnim("cigarette", true, false, false);
			}
		}
		else
		{
			shooterCamPos = [getCharacterCameraPos(dad).x - 50, getCharacterCameraPos(dad).y];
			cigarHolderCamPos = [getCharacterCameraPos(boyfriend).x, getCharacterCameraPos(boyfriend).y];
			
			if (picoOpponent != null) picoOpponent.playAnim("shoot", true, false, false);

			if (picoPlayer != null)
			{
				if (explode) picoPlayer.playAnim("explode", true, false, false);
				else picoPlayer.playAnim("cigarette", true, false, false);
			}
		}

		camFollowTween.cancel();
		snapCamToPos(675, 525, true);

		new FlxTimer(cutsceneTimerManager).start(0.3, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoGasp'), 1.0);
			FlxG.sound.play(Paths.sound('week3/cutscene/picoGasp'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(3.7, () -> {
			if (!explode) FlxG.sound.play(Paths.sound('week3/cutscene/picoCigarette'), 1.0);
			else FlxG.sound.play(Paths.sound('week3/cutscene/picoCigarette2'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(4, () -> {
			camFollowTween = FlxTween.tween(camFollowPoint, {
				x: cigarHolderCamPos[0],
				y: cigarHolderCamPos[1]
			}, 1.9, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {
					camFollowTween = null;
				}
			});
		});

		new FlxTimer(cutsceneTimerManager).start(6.29, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoShoot'), 1.0);
			
			camFollowTween = FlxTween.tween(camFollowPoint, {
				x: shooterCamPos[0],
				y: shooterCamPos[1]
			}, 1.9, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {
					camFollowTween = null;
				}
			});
		});

		new FlxTimer(cutsceneTimerManager).start(8.75, () -> {
			if (explode) FlxG.sound.play(Paths.sound('week3/cutscene/picoExplode'), 1.0);
			cutsceneSkipped = true;
			canSkipCutscene = false;
			FlxTween.tween(skipText, {alpha: 0}, 0.5, {
				ease: FlxEase.quadIn,
				onComplete: _ ->
				{
					skipText.visible = false;
				}
			});
			// cutting off skipping here. really dont think its needed after this point and it saves problems from happening

			camFollowTween = FlxTween.tween(camFollowPoint, {
				x: cigarHolderCamPos[0],
				y: cigarHolderCamPos[1]
			}, 1.9, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {
					camFollowTween = null;
				}
			});
			if (explode)
			{
				gf.playAnim('drop70', true);
				hasPlayedInGameCutscene = true;
			}
		});

		new FlxTimer(cutsceneTimerManager).start(10.33, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoSpin'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(11.2, _ ->
		{
			if (explode)
			{
				bloodPool.playAnim("bloodPool", true);
				bloodPool.alpha = 1;
				extendBloodPool = true;

				// if (playerShoot) picoOpponent.playAnim("explodeLoop", true, false, false);
				// else picoPlayer.playAnim("explodeLoop", true, false, false);
			}
		});

		new FlxTimer(cutsceneTimerManager).start(11.5, () -> {
			if (!explode)
			{
				cigarette.alpha = 1;
				cigarette.animation.play('cigarette spit');
			}
		});

		new FlxTimer(cutsceneTimerManager).start(13, () -> {
			if (explode)
			{
				if (playerShoot)
				{	
					modManager.setValue("alpha", 1, 1);
					opponentStrums.singers = [];
					canPause = true;
					picoPlayer.alpha = 0;
					boyfriend.alpha = 1;
					hasPlayedInGameCutscene = true;
					cameraSpeed = 1;
					FlxTween.tween(camHUD, {alpha: 1}, 0.6);
					can = false;
					startCountdown();

					camFollowTween = FlxTween.tween(camFollowPoint, {
						x: getCharacterCameraPos(boyfriend).x,
						y: getCharacterCameraPos(boyfriend).y
					}, 1.9, {
						ease: FlxEase.sineInOut,
						onComplete: function(twn:FlxTween)
						{
							camFollowTween = null;
						}
					});

					camChangeZoom(1.1, 1.9, FlxEase.sineInOut);
				}
				else
				{
					picoOpponent.alpha = 0;
					dad.alpha = 1;

					new FlxTimer().start(1, function(tmr)
					{
						camOther.fade(0xFF000000, 1, false, null, true);
					});

					new FlxTimer().start(2, function(tmr)
					{
						endSong();
					});
				}
			}
			else
			{
				canPause = true;
				picoPlayer.alpha = 0;
				boyfriend.alpha = 1;
				picoOpponent.alpha = 0;
				dad.alpha = 1;
				hasPlayedInGameCutscene = true;
				cameraSpeed = 1;
				FlxTween.tween(camHUD, {alpha: 1}, 0.6);
				can = false;
				startCountdown();

				camFollowTween = FlxTween.tween(camFollowPoint, {
					x: getCharacterCameraPos(boyfriend).x,
					y: getCharacterCameraPos(boyfriend).y
				}, 1.9, {
					ease: FlxEase.sineInOut,
					onComplete: function(twn:FlxTween)
					{
						camFollowTween = null;
					}
				});

				camChangeZoom(1.1, 1.9, FlxEase.sineInOut);
			}
			cutsceneMusic.stop();
		});

		return ScriptConstants.STOP_FUNC;
	}
}

function skipCutscene()
{
	cutsceneSkipped = true;
	explode = false;
	hasPlayedCutscene = true;
	camOther.fade(0xFF000000, 0.5, false, null, true);
	cutsceneMusic.fadeOut(0.5, 0);

	new FlxTimer().start(0.5, _ ->
	{
		camOther.fade(0xFF000000, 0.5, true, null, true);
		camFollowPoint.x = getCharacterCameraPos(boyfriend).x;
		camFollowPoint.y = getCharacterCameraPos(boyfriend).y;
		
		cutsceneTimerManager.clear();
		cutsceneMusic.stop();

		skipText.visible = false;
      	picoPlayer.visible = false;
      	picoOpponent.visible = false;

		canDoPicoShit = false;

		defaultCamZoom = 1.1;

		canPause = true;
		picoPlayer.alpha = 0;
		boyfriend.alpha = 1;
		picoOpponent.alpha = 0;
		dad.alpha = 1;
		hasPlayedInGameCutscene = true;
		cameraSpeed = 1;
		FlxTween.tween(camHUD, {alpha: 1}, 0.6);
		can = false;
		startCountdown();
	});
}

function onSpawnNotePost(note)
{
	if (note.owner == dad && (explode && playerShoot) && canDoPicoShit) note.noAnimation = true;
}

function opponentNoteHitPre(note, ID)
{
	if (explode && playerShoot && canDoPicoShit)
	{
		audio.opponentVolume = 0;
	}
}

var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;

function trainStart():Void
{
	trainMoving = true;
	if (!trainSound.playing)
	trainSound.play(true);
}

var startedMoving:Bool = false;

function updateTrainPos():Void
{
	if (trainSound.time >= 4700)
	{
		startedMoving = true;
		if (gf != null)
		{
			gf.canDance = false;
			if (gf.curCharacter == "nene") gf.playAnim(health <= 0.6 ? 'hairBlowKnife' : 'hairBlowNormal');
			else gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}
	}

	if (startedMoving)
	{
		phillyTrain.x -= 400;

		if (phillyTrain.x < -2000 && !trainFinishing)
		{
			phillyTrain.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
			trainFinishing = true;
		}

		if (phillyTrain.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainReset():Void
{
	if (gf != null)
	{
		gf.danced = false; // Sets head to the correct position once the animation ends
		if (gf.curCharacter == "nene") gf.playAnim(health <= 0.6 ? 'hairFallKnife' : 'hairFallNormal');
		else gf.playAnim('hairFall');
		gf.canDance = true;
		gf.specialAnim = true;
	}
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

var neneTimer = 0;
var winTimer = 0;

function onUpdate(elapsed)
{
	if (cutsceneTimerManager != null) cutsceneTimerManager.update(elapsed);

	if (trainMoving)
	{
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24)
		{
			updateTrainPos();
			trainFrameTiming = 0;
		}
	}

	phillyCityLightsGlow.alpha = FlxMath.lerp(phillyCityLightsGlow.alpha, 0, FlxMath.bound(elapsed * 3.2, 0, 1));

	if(phillyGlowParticles != null)
	{
		var i:Int = phillyGlowParticles.members.length-1;
		while (i > 0)
		{
			var particle = phillyGlowParticles.members[i];
			if(particle.alpha < 0)
			{
				particle.kill();
				phillyGlowParticles.remove(particle, true);
				particle.destroy();
			}
			--i;
		}
	}

	if (!hasPlayedInGameCutscene)
	{
		neneTimer += elapsed;
		if (neneTimer >= 0.6)
		{
			neneTimer = 0;
			gf.dance();
		}

		winTimer += elapsed;
		if (winTimer >= 0.72)
		{
			winTimer = 0;
			// Switch to a different light
			randomizeLights();
		}

		if (controls.ACCEPT && !cutsceneSkipped)
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
		if (controls.ACCEPT && !cutsceneSkipped && canSkipCutscene)
		{
			skipCutscene();
		}
	}

	if (extendBloodPool)
    {
    	var extendFactor:Float = 0.02 * elapsed;
    	bloodPool.setScale(bloodPool.scale.x + extendFactor, bloodPool.scale.y + extendFactor);
    }
}

function onCreatePost()
{
	for (character in [gf, dad, boyfriend])
		character.shader = colorShader;
}

function onEventPush(event)
{
	if (event.event == "Philly Glow")
	{
		blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blammedLightsBlack.visible = false;
		blammedLightsBlack.zIndex = 61;
		add(blammedLightsBlack);

		phillyWindowEvent = new FlxSprite(phillyWindow.x, phillyWindow.y).loadGraphic(Paths.image("backgrounds/philly/window"));
		phillyWindowEvent.zIndex = 30;
		phillyWindowEvent.setScale(0.9, 0.9, true);
		phillyWindowEvent.scrollFactor.set(0.3, 0.3);
		phillyWindowEvent.visible = false;
		phillyWindowEvent.zIndex = 62;
		add(phillyWindowEvent);

		phillyGlowGradient = new PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
		phillyGlowGradient.visible = false;
		phillyGlowGradient.zIndex = 63;
		add(phillyGlowGradient);
		if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

		phillyGlowParticles = new FlxTypedGroup();
		phillyGlowParticles.visible = false;
		phillyGlowParticles.zIndex = 64;
		add(phillyGlowParticles);
	}
}

function onEvent(eventName, value1, value2)
{
	if (eventName == "Philly Glow")
	{
		var lightId:Int = Std.parseInt(value1);
		if(Math.isNaN(lightId)) lightId = 0;

		var doFlash:Void->Void = function()
		{
			var color:FlxColor = FlxColor.WHITE;

			FlxG.camera.flash(color, 0.15, null, true);
		};

		var chars:Array<Character> = [boyfriend, gf, dad];
		switch(lightId)
		{
			case 0:
				if(phillyGlowGradient.visible)
				{
					doFlash();
					if(ClientPrefs.camZooms) uiBop(0.5, 0.1);

					blammedLightsBlack.visible = false;
					phillyWindowEvent.visible = false;
					phillyGlowGradient.visible = false;
					phillyGlowParticles.visible = false;
					curLightEvent = -1;

					for (who in chars)
					{
						who.color = FlxColor.WHITE;
						who.shader = colorShader;
					}
					phillyStreet.color = FlxColor.WHITE;
				}

			case 1: //turn on
				curLightEvent = FlxG.random.int(0, phillyLightsColorsEvent.length-1, [curLightEvent]);
				var color:FlxColor = phillyLightsColorsEvent[curLightEvent];

				if(!phillyGlowGradient.visible)
				{
					doFlash();
					if(ClientPrefs.camZooms)
					{
						FlxG.camera.zoom += 0.5;
						camHUD.zoom += 0.1;
					}

					blammedLightsBlack.visible = true;
					blammedLightsBlack.alpha = 1;
					phillyWindowEvent.visible = true;
					phillyGlowGradient.visible = true;
					phillyGlowParticles.visible = true;
				}

				var charColor:FlxColor = color;

				for (who in chars)
				{
					who.color = charColor;
					who.shader = null;
				}
				phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle)
				{
					particle.color = color;
				});
				phillyGlowGradient.color = color;
				phillyWindowEvent.color = color;

				phillyStreet.color = color;

			case 2: // spawn particles
				if(!ClientPrefs.lowQuality)
				{
					var particlesNum:Int = FlxG.random.int(8, 12);
					var width:Float = (2000 / particlesNum);
					var color:FlxColor = phillyLightsColorsEvent[curLightEvent];
					for (j in 0...3)
					{
						for (i in 0...particlesNum)
						{
							var particle:PhillyGlowParticle = new PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
							phillyGlowParticles.add(particle);
						}
					}
				}
				phillyGlowGradient.bop();
		}
	}
}

function randomizeLights()
{
	curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
	
	phillyWindow.color = phillyLightsColors[curLight];
	phillyCityLightsGlow.color = phillyLightsColors[curLight];
	FlxTween.cancelTweensOf(phillyCityLightsGlow);
	phillyCityLightsGlow.alpha = 0.9;
}

function onBeatHit()
{
	if (!trainMoving)
		trainCooldown += 1;

	// Update phillyWindow
	if (curBeat % 4 == 0)
	{
		randomizeLights();
	}

	if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
	{
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}
}