import funkin.objects.stageobjects.ABotVis;
import funkin.backend.Conductor;
import funkin.game.shaders.DropShadowShader;

var aBotPixelBody:FlxSprite;
var abotHead:FlxSprite;
var aBotPixelSpeaker:FlxSprite;
var abotVis:ABotVis;
var abot:FlxSpriteGroup;
var started = false;

function onCreatePost()
{
	dadGroup.zIndex += 1;
	boyfriendGroup.zIndex += 1;
	gfGroup.zIndex += 1;
	
	aBot = new FlxSpriteGroup();
	
	stereoBG = new FlxSprite(-50, -110).loadGraphic(Paths.image('characters/abotPixel/aBotPixelBack'));
	stereoBG.setScale(6.1, 6, true);
	stereoBG.antialiasing = false;
	
	abotHead = new FlxSprite(-205, -30);
	abotHead.frames = Paths.getSparrowAtlas('characters/abotPixel/abotHead');
	abotHead.animation.addByPrefix('left', 'left', 24, false);
	abotHead.animation.addByPrefix('right', 'right', 24, false);
	abotHead.animation.addByPrefix('lookin left', 'toleft', 24, false);
	abotHead.animation.addByPrefix('lookin right', 'toright', 24, false);
	abotHead.animation.play('left');
	abotHead.antialiasing = false;
	abotHead.setScale(6, 6, true);
	
	aBotPixelBody = new FlxSprite(190, 0);
	aBotPixelBody.frames = Paths.getSparrowAtlas('characters/abotPixel/aBotPixelBody');
	aBotPixelBody.scale.set(6, 6);
	aBotPixelBody.antialiasing = false;
	aBotPixelBody.animation.addByPrefix('sys', 'bop', 24, false);
	aBotPixelBody.animation.play('sys');

	aBotPixelSpeaker = new FlxSprite(111.5, 11.5);
	aBotPixelSpeaker.frames = Paths.getSparrowAtlas('characters/abotPixel/aBotPixelSpeaker');
	aBotPixelSpeaker.scale.set(6, 6);
	aBotPixelSpeaker.antialiasing = false;
	aBotPixelSpeaker.animation.addByPrefix('sys', 'bop', 24, false);
	aBotPixelSpeaker.animation.play('sys');
	
	abotVis = new ABotVis(audio.inst, true);
	abotVis.x += 30;
	abotVis.y += 35;
	
	aBot.setPosition(gf.x + 125, gf.y + 425);
	aBot.zIndex = gfGroup.zIndex - 1;
	// add(aBot);
	stage.add(aBot);
	refreshZ(stage);

	aBot.add(abotHead);
	aBot.add(aBotPixelSpeaker);
	aBot.add(stereoBG);
	aBot.add(abotVis);
	aBot.add(aBotPixelBody);
	
	tempAnalyzer();
	addSunsetShaders();
}

function addSunsetShaders()
{
	var abotSpeakerShader = new DropShadowShader();
	abotSpeakerShader.setAdjustColor(-66, -10, 24, -23);
	abotSpeakerShader.angle = 90;
	abotSpeakerShader.color = 0xFF52351d;
	abotSpeakerShader.distance = 5;
	abotSpeakerShader.antialiasAmt = 0;
	abotSpeakerShader.threshold = 1;

	abotSpeakerShader.attachedSprite = aBotPixelSpeaker;
	aBotPixelSpeaker.animation.onFrameChange.add(function()
	{
		abotSpeakerShader.updateFrameInfo(aBotPixelSpeaker.frame);
	});

	abotSpeakerShader.loadAltMask(Paths.image('backgrounds/weeb/erect/masks/aBotPixelSpeaker_mask'));
	abotSpeakerShader.maskThreshold = 0;
	abotSpeakerShader.useAltMask = true;

	var noRimShader = newShader('adjustColor');
	noRimShader.setFloat('hue', -10);
	noRimShader.setFloat('saturation', -23);
	noRimShader.setFloat('brightness', -66);
	noRimShader.setFloat('contrast', 24);

	aBotPixelBody.shader = noRimShader;
	stereoBG.shader = noRimShader;
	abotHead.shader = noRimShader;
	abotVis.shader = noRimShader;
	aBotPixelSpeaker.shader = abotSpeakerShader;
}

var shit = [5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5];

function tempAnalyzer()
{
	if (started) return;
	
	var fuck = -1;
	for (i in abotVis.members)
	{
		fuck += 1;
		i.visible = true;
		i.animation.curAnim.curFrame = shit[fuck];
	}
	
	shit = shiftRight(shit);
	
	FlxTimer.wait(0.045, tempAnalyzer);
}

function shiftRight(arr)
{
	if (arr.length <= 1) return arr;
	
	var last = arr.pop(); // remove last element
	arr.unshift(last); // add it to the front
	
	return arr;
}

function onSongStart()
{
	started = true;
	
	if (ClientPrefs.streamedMusic) speakerBump();
	else
	{
		abotVis.snd = audio.inst;
		abotVis.initAnalyzer();
		abotVis.analyzer.fftN = 2048;
	}
}

function onDestroy()
{
	abotVis.dumpSound();
}

function onEndSong()
{
	abotVis.dumpSound();
}

var left = true;

function onCountdownTick()
{
	if (aBotPixelBody != null) aBotPixelBody.animation.play('sys', true);
	if (aBotPixelSpeaker != null) aBotPixelSpeaker.animation.play('sys', true);
}

function onBeatHit()
{
	if (aBotPixelBody != null) aBotPixelBody.animation.play('sys', true);
	if (aBotPixelSpeaker != null) aBotPixelSpeaker.animation.play('sys', true);
	
	if (ClientPrefs.streamedMusic) speakerBump();

	if (abotHead.animation.curAnim.name != 'lookin ' + (camCurTarget == boyfriend ? 'right' : 'left'))
		abotHead.animation.play('lookin ' + (camCurTarget == boyfriend ? 'right' : 'left'));
}

function speakerBump()
{
	final initVol = [4, 3, 1, 0, 1, 2, 3];
	var fuck = -1;
	for (i in abotVis.members)
	{
		fuck += 1;
		final choice = initVol[fuck];
		
		i.animation.curAnim.curFrame = choice;
		FlxTween.num(choice, 6, Conductor.stepCrotchet / 500,
			{
				onUpdate: (t) -> {
					i.animation.curAnim.curFrame = t.value;
				}
			});
	}
}

var readyToKill = false;

function onUpdatePost()
{
	for (member in aBot.members) member.alpha = gf.alpha;
	
	if (health <= 0.6 && !readyToKill)
	{
		gf.stunned = true;
		readyToKill = true;
		gf.playAnim('raiseKnife', true);
		FlxTimer.wait(0.36, () -> {
			gf.playAnim('idleKnife', true);
		});
	}
	else if (health > 0.6 && readyToKill)
	{
		gf.stunned = false;
		readyToKill = false;
		gf.playAnimForDuration('lowerKnife', 0.3, true);
	}
}
