import funkin.objects.FunkinSprite;
import funkin.objects.Bopper;
import flixel.util.FlxTimerManager;

var lightColors:Array<FlxColor> = [0xFFB66F43, 0xFF329A6D, 0xFF932C28, 0xFF2663AC, 0xFF502D64];

var trainSound:FlxSound;
var colorShader:FlxRuntimeShader;

var trainEnabled:Bool = true;

var hasPlayedInGameCutscene = true;
var cutsceneSkipped:Bool = false;
var canSkipCutscene:Bool = false;

var controls = Controls.instance;

/**
* Replay the cutscene after leaving the song.
*/
function onLoad()
{
	trainSound = new FlxSound().loadEmbedded(Paths.sound('week3/train_passes'));
	FlxG.sound.list.add(trainSound);

	colorShader = newShader('adjustColor');
	colorShader.setFloat('hue', -26);
	colorShader.setFloat('saturation', -16);
	colorShader.setFloat('contrast', 0);
	colorShader.setFloat('brightness', -5);
	train.shader = colorShader;

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

var playerShoot:Bool = FlxG.random.bool(50);
var explode:Bool = FlxG.random.bool(8);

var shooterCamPos:Array<Float>;
var cigarHolderCamPos:Array<Float>;

var cutsceneTimerManager:FlxTimerManager;

function onStartCountdown()
{
	if (can && boyfriend.curCharacter == 'pico-playable')
	{
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

		hasPlayedInGameCutscene = false;

		bloodPool = new FunkinSprite(0, 0).loadAtlas('backgrounds/philly/erect/bloodPool');
		bloodPool.addAnimByPrefix("bloodPool", "bloodPool", 24, false);
		bloodPool.alpha = 0;

		picoPlayer = new FunkinSprite(boyfriend.x - 537, boyfriend.y - 209).loadAtlas('backgrounds/philly/erect/pico_doppleganger');
		picoPlayer.addAnimByPrefix("shoot", "shootPlayer", 24, false);
		picoPlayer.addAnimByPrefix("cigarette", "cigarettePlayer", 24, false);
		picoPlayer.addAnimByPrefix("explode", "explodePlayer", 24, false);
		picoPlayer.scrollFactor.set(1, 1);
		picoPlayer.antialiasing = true;

		picoOpponent = new FunkinSprite(dad.x - 501, dad.y - 209).loadAtlas('backgrounds/philly/erect/pico_doppleganger');
		picoOpponent.addAnimByPrefix("shoot", "shootOpponent", 24, false);
		picoOpponent.addAnimByPrefix("cigarette", "cigaretteOpponent", 24, false);
		picoOpponent.addAnimByPrefix("explode", "explodeOpponent", 24, false);
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

		if (!explode) cutsceneMusic = FunkinSound.load(Paths.music("week3/cutscene/cutscene"), true);
		else cutsceneMusic = FunkinSound.load(Paths.music("week3/cutscene/cutscene2"), true);
		cutsceneMusic.volume = 1;
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
		snapCamToPos(675, 575, true);

		new FlxTimer(cutsceneTimerManager).start(0.3, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoGasp'), 1.0);
			FlxG.sound.play(Paths.sound('week3/cutscene/picoGasp'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(6.29, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoShoot'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(10.33, () -> {
			FlxG.sound.play(Paths.sound('week3/cutscene/picoSpin'), 1.0);
		});

		new FlxTimer(cutsceneTimerManager).start(3.7, () -> {
			if (!explode) FlxG.sound.play(Paths.sound('week3/cutscene/picoCigarette'), 1.0);
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

		new FlxTimer(cutsceneTimerManager).start(6.3, () -> {
			camFollowTween = FlxTween.tween(camFollowPoint, {
				x: shooterCamPos[0],
				y: shooterCamPos[1]
			}, 1.9, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween) {
					camFollowTween = null;
				}
			});
		});

		new FlxTimer(cutsceneTimerManager).start(8.75, () -> {
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

		new FlxTimer(cutsceneTimerManager).start(11.2, _ ->
		{
			if (explode)
			{
				bloodPool.playAnim("bloodPool", true);
				bloodPool.alpha = 1;
				extendBloodPool = true;
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
					cameraSpeed = 1.5;
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
				cameraSpeed = 1.5;
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
		isCameraOnForcedPos = false;
		
		cutsceneTimerManager.clear();
		cutsceneMusic.stop();

		skipText.visible = false;
      	picoPlayer.visible = false;
      	picoOpponent.visible = false;

		canPause = true;
		picoPlayer.alpha = 0;
		boyfriend.alpha = 1;
		picoOpponent.alpha = 0;
		dad.alpha = 1;
		hasPlayedInGameCutscene = true;
		cameraSpeed = 1.5;
		FlxTween.tween(camHUD, {alpha: 1}, 0.6);
		can = false;
		startCountdown();
	});
}

function onSpawnNotePost(note)
{
	if (note.owner == dad && (explode && playerShoot)) note.noAnimation = true;
}

function opponentNoteHitPre(note, ID)
{
	if (explode && playerShoot)
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
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}
	}

	if (startedMoving)
	{
		train.x -= 400;

		if (train.x < -2000 && !trainFinishing)
		{
			train.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
			trainFinishing = true;
		}

		if (train.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainReset():Void
{
	if (gf != null)
	{
		gf.danced = false; // Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
	}
	train.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

var neneTimer = 0;

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

	lights.alpha = FlxMath.lerp(lights.alpha, 0, FlxMath.bound(elapsed * 3.2, 0, 1));

	if (!hasPlayedInGameCutscene)
	{
		neneTimer += elapsed;
		if (neneTimer >= 0.6)
		{
			neneTimer = 0;
			gf.dance();
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
    	bloodPool.scale.set(bloodPool.scale.x + extendFactor, bloodPool.scale.y + extendFactor);
    }
}

function onCreatePost()
{
	for (character in [gf, dad, boyfriend])
		character.shader = colorShader;
}

function onBeatHit()
{
	if (!trainMoving)
		trainCooldown += 1;

	// Update lights
	if (curBeat % 4 == 0)
	{
		// Switch to a different light
		curLight = FlxG.random.int(0, lightColors.length - 1);
		lights.color = lightColors[curLight];
		lights.alpha = 1;
	}

	if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
	{
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}
}