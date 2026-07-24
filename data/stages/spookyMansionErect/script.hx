import funkin.game.shaders.RainShader;

import funkin.objects.stageobjects.ABotVis;
import funkin.backend.Conductor;

import animate.FlxAnimateFrames;
import animate.FlxAnimate;

var abotSpeakerLight:FlxAnimate;
var pupilLight:FlxAnimate;
var abotVisLight:ABotVis;
var abotLight:FlxSpriteGroup;
var started = false;

var lightningStrikeBeat:Int = 0;
var lightningStrikeOffset:Int = 8;

var bfLight:Character;
var dadLight:Character;
var gfLight:Character;

var rain:RainShader;

function onCreatePost()
{
	shader = new RainShader();
	shader.scale = FlxG.height / 200 * 2;
	shader.intensity = 0.4;
	shader.spriteMode = true;
	bgTrees.shader = shader;
	
	bfLight = new Character(0, 0, boyfriend.curCharacter == "pico-dark" ? 'pico-playable' : 'bf', true);
	bfLight.flipX = false;
	bfLight.alpha = 0.0001;
	bfLight.danceEveryNumBeats = boyfriend.danceEveryNumBeats;
	boyfriendGroup.addChar(bfLight);
	
	playerStrums.singers = [boyfriend, bfLight];
	
	dadLight = new Character(0, 0, 'spooky', false);
	dadLight.danceEveryNumBeats = dad.danceEveryNumBeats;
	dadLight.danceIdle = true;
	dadLight.alpha = 0.0001;
	dadGroup.addChar(dadLight);
	
	opponentStrums.singers = [dad, dadLight];
	
	gfLight = new Character(0, 0, gf.curCharacter == "nene-dark" ? 'nene' : 'gf', false);
	gfLight.danceEveryNumBeats = gf.danceEveryNumBeats;
	gfLight.danceIdle = true;
	gfLight.alpha = 0.0001;
	gfGroup.addChar(gfLight);

	if (gf.curCharacter == "nene-dark")
	{
		aBotLight = new FlxSpriteGroup();
		
		eyeWhitesLight = new FlxSprite(-120, 200).makeGraphic(160, 60, FlxColor.WHITE);
		
		stereoBGLight = new FlxSprite(-20, -20).loadGraphic(Paths.image('characters/abot/stereoBG'));
		stereoBGLight.color = 0xFF616785;
		
		pupilLight = new FlxAnimate(-125, 190);
		pupilLight.frames = FlxAnimateFrames.fromAnimate((Paths.textureAtlas('characters/abot/systemEyes')));
		pupilLight.anim.addBySymbol('left', 'abot eyes 2', 24, false);
		pupilLight.anim.addBySymbol('right', 'abot eyes', 24, false);
		pupilLight.anim.addBySymbolIndices('lookin left', 'a bot eyes lookin', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
		pupilLight.anim.addBySymbolIndices('lookin right', 'a bot eyes lookin', [22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
		pupilLight.anim.play('lookin left');
		pupilLight.antialiasing = true;
		
		abotSpeakerLight = new FlxAnimate(-175, -50);
		abotSpeakerLight.frames = FlxAnimateFrames.fromAnimate((Paths.textureAtlas('characters/abot/abotSystem')));
		abotSpeakerLight.anim.addBySymbol('sys', 'Abot System', 24, false);
		abotSpeakerLight.anim.play('sys');
		abotSpeakerLight.antialiasing = true;
		
		abotVisLight = new ABotVis(audio.inst, false);
		abotVisLight.x += 30;
		abotVisLight.y += 35;
		
		aBotLight.setPosition(55, 365);
		aBotLight.zIndex = gfGroup.zIndex - 2;
		// add(aBot);
		gfGroup.add(aBotLight);
		refreshZ(stage);
		
		aBotLight.add(eyeWhitesLight);
		aBotLight.add(stereoBGLight);
		aBotLight.add(pupilLight);
		aBotLight.add(abotVisLight);
		
		aBotLight.add(abotSpeakerLight);

		tempAnalyzer();
	}
}

function onUpdate(elapsed)
{
	shader?.updateFrameInfo(bgTrees.frame);
	shader?.update(elapsed);
}

function doLightningStrike(playSound:Bool, beat:Int):Void
{
	if (playSound) FunkinSound.play(Paths.sound('week2/thunder_' + FlxG.random.int(1, 2)), 1.0);
	
	bgLight.alpha = 1;
	stairsLight.alpha = 1;
	
	bfLight.alpha = 1;
	gfLight.alpha = 1;
	dadLight.alpha = 1;
	
	new FlxTimer().start(0.12, _ ->
	{
		bgLight.alpha = 1;
		stairsLight.alpha = 1;
		
		FlxTween.tween(bgLight, {alpha: 0}, 1.5);
		FlxTween.tween(stairsLight, {alpha: 0}, 1.5);
		FlxTween.tween(bfLight, {alpha: 0}, 1.5);
		FlxTween.tween(gfLight, {alpha: 0}, 1.5);
		FlxTween.tween(dadLight, {alpha: 0}, 1.5);
	});
	
	lightningStrikeBeat = beat;
	lightningStrikeOffset = FlxG.random.int(8, 24);
	
	if (boyfriend != null && boyfriend.hasAnim('scared') && boyfriend.animation.name != 'cheer') boyfriend.playAnim('scared', true, true);
	if (bfLight != null && bfLight.hasAnim('scared') && bfLight.animation.name != 'cheer') bfLight.playAnim('scared', true, true);
	
	if (gf.hasAnim('scared')) gf.playAnim('scared', true, true);
	if (gfLight.hasAnim('scared')) gfLight.playAnim('scared', true, true);
}

function onBeatHit()
{
	// Play lightning on sync at the start of this specific song.
	// TODO: Rework this after chart format redesign.
	
	dadLight?.onBeatHit(curBeat);
	bfLight?.onBeatHit(curBeat);
	gfLight?.onBeatHit(curBeat);
	
	if (curBeat == 4 && PlayState.SONG.song.toLowerCase() == "spookeez erect") doLightningStrike(false, curBeat);
	
	// Play lightning at random intervals.
	if (FlxG.random.bool(10) && curBeat > (lightningStrikeBeat + lightningStrikeOffset)) doLightningStrike(true, curBeat);

	if (abotSpeakerLight != null && gf.curCharacter == "nene-dark")
	{
		abotSpeakerLight.anim.play('sys', true);
	}
	
	if (ClientPrefs.streamedMusic) speakerBump();
}

function onCountdownTick(swagCounter)
{
	dadLight?.onBeatHit(swagCounter);
	bfLight?.onBeatHit(swagCounter);
	gfLight?.onBeatHit(swagCounter);
}

var shit = [5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5];

function tempAnalyzer()
{
	if (started) return;
	
	var fuck = -1;
	for (i in abotVisLight.members)
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
	if (gf.curCharacter == "nene-dark")
	{
		started = true;
		
		if (ClientPrefs.streamedMusic) speakerBump();
		else
		{
			abotVisLight.snd = audio.inst;
			abotVisLight.initAnalyzer();
			abotVisLight.analyzer.fftN = 2048;
		}
	}
}

function onDestroy()
{
	if (gf.curCharacter == "nene-dark") abotVisLight.dumpSound();
}

function onEndSong()
{
	if (gf.curCharacter == "nene-dark") abotVisLight.dumpSound();
}

var left = true;

function speakerBump()
{
	final initVol = [4, 3, 1, 0, 1, 2, 3];
	var fuck = -1;
	for (i in abotVisLight.members)
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

var prevSec = PlayState.SONG.notes[0];

function onSectionHit()
{
	if (gf.curCharacter == "nene-dark")
	{
		if (pupilLight != null)
		{
			var sec = PlayState.SONG.notes[curSection];
			
			if (sec != null)
			{
				if (curSection > 0) prevSec = PlayState.SONG.notes[curSection - 1];
				if (sec.mustHitSection != prevSec.mustHitSection)
				{
					pupilLight.anim.play('lookin ' + (sec.mustHitSection ? 'right' : 'left'));
				}
			}
		}
	}
}

var readyToKill = false;

function onUpdatePost()
{
	if (gf.curCharacter == "nene-dark")
	{
		for (aBotShitLight in [eyeWhitesLight, stereoBGLight, pupilLight, abotVisLight, abotSpeakerLight])
			aBotShitLight.alpha = gfLight.alpha;
	}
}
