import openfl.filters.ShaderFilter;
import funkin.game.shaders.RainShader;

var startIntensity:Float = 0.6;
var endIntensity:Float = 0.8;

var rainShader:RainShader;
var rainTimeScale:Float = 1;

var scrollingSky:FlxTiledSprite;
var skyAdditive:BGSprite;
var lightning:BGSprite;
var foregroundMultiply:BGSprite;
var additionalLighten:FlxSprite;

var ending:FunkinVideoSprite;

var lightningTimer:Float = 3.0;

var endingSong:Bool = false;

function onLoad() 
{
	function setupScale(spr:BGSprite)
	{
		spr.scale.set(1.75, 1.75);
		spr.updateHitbox();
	}

	if(!ClientPrefs.lowQuality)
	{
		var skyImage = Paths.image('backgrounds/phillyBlazin/skyBlur');
		scrollingSky = new FlxTiledSprite(skyImage, Std.int(skyImage.width * 1.1) + 475, Std.int(skyImage.height / 1.1), true, false);
		scrollingSky.antialiasing = ClientPrefs.globalantialiasing;
		scrollingSky.setPosition(-500, -120);
		scrollingSky.scrollFactor.set();
		add(scrollingSky);

		skyAdditive = new BGSprite('backgrounds/phillyBlazin/skyBlur', -600, -175, 0.0, 0.0);
		setupScale(skyAdditive);
		skyAdditive.visible = false;
		add(skyAdditive);
		
		lightning = new BGSprite('backgrounds/phillyBlazin/lightning', -50, -300, 0.0, 0.0, ['lightning0'], false);
		setupScale(lightning);
		lightning.visible = false;
		add(lightning);
	}
	
	var phillyForegroundCity:BGSprite = new BGSprite('backgrounds/phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
	setupScale(phillyForegroundCity);
	add(phillyForegroundCity);
	
	if(!ClientPrefs.lowQuality)
	{
		foregroundMultiply = new BGSprite('backgrounds/phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
		setupScale(foregroundMultiply);
		foregroundMultiply.blend = BlendMode.MULTIPLY;
		foregroundMultiply.visible = false;
		add(foregroundMultiply);
		
		additionalLighten = new FlxSprite(-600, -175).makeGraphic(1, 1, FlxColor.WHITE);
		additionalLighten.scrollFactor.set();
		additionalLighten.scale.set(2500, 2500);
		additionalLighten.updateHitbox();
		additionalLighten.blend = BlendMode.ADD;
		additionalLighten.visible = false;
		add(additionalLighten);
	}

	for (i in 1...4)
	{
		Paths.sound('weekend1/lightning/Lightning$i');
	}
}

function onCreatePost() {
	snapCamToPos(getCharacterCameraPos(dad).x + 250, getCharacterCameraPos(dad).y + 350, true);
	modManager.setValue("alpha", 1, 1);
	modManager.setValue("opponentSwap", 0.5);

	rainShader = new RainShader();
	rainShader.scale = FlxG.height / 200;
	rainShader.intensity = 0.5;
	FlxG.camera.filters = [new ShaderFilter(rainShader)];

	boyfriendGroup.zIndex = 3000;
	dadGroup.zIndex = 2000;
	playHUD.visible = false;

	gfGroup.x += 950;
	gfGroup.y += 1110;

	dad.setPosition(750, 1425);
	boyfriendGroup.setPosition(805, 740);

	dad.canDance = boyfriend.canDance = false;

	FlxG.camera.focusOn(camFollow.getPosition());
	FlxG.camera.fade(FlxColor.BLACK, 1.5, true, null, true);

	for (character in boyfriendGroup.members)
	{
		if(character == null) continue;
		character.color = 0xFFDEDEDE;
	}
	for (character in dadGroup.members)
	{
		if(character == null) continue;
		character.color = 0xFFDEDEDE;
	}
	for (character in gfGroup.members)
	{
		if(character == null) continue;
		character.color = 0xFF888888;
	}

	var unspawnNotes:Array<Note> = game.queueNotes;
	for (note in unspawnNotes)
	{
		if(note == null) continue;

		//override animations for note types
		note.noAnimation = true;
		note.noMissAnimation = true;
	}

	if(!isStoryMode) return;
    songEndCallback = blazin_end;
}

function onUpdate(elapsed) {
	if(scrollingSky != null) scrollingSky.scrollX -= elapsed * 35;

	if(rainShader != null)
	{
		rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
		rainShader.update(elapsed * rainTimeScale);
		rainTimeScale = FlxMath.lerp(0.02, Math.min(1, rainTimeScale), Math.exp(-elapsed / (1/3)));
	}

	lightningTimer -= elapsed;
	if (lightningTimer <= 0)
	{
		applyLightning();
		lightningTimer = FlxG.random.float(7, 15);
	}
}

function applyLightning():Void
{
	if(ClientPrefs.lowQuality || endingSong) return;

	final LIGHTNING_FULL_DURATION = 1.5;
	final LIGHTNING_FADE_DURATION = 0.3;

	skyAdditive.visible = true;
	skyAdditive.alpha = 0.7;
	FlxTween.tween(skyAdditive, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {onComplete: function(_)
	{
		skyAdditive.visible = false;
		lightning.visible = false;
		foregroundMultiply.visible = false;
		additionalLighten.visible = false;
	}});

	foregroundMultiply.visible = true;
	foregroundMultiply.alpha = 0.64;
	FlxTween.tween(foregroundMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION);

	additionalLighten.visible = true;
	additionalLighten.alpha = 0.3;
	FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

	lightning.visible = true;
	lightning.animation.play('lightning0', true);

	if(FlxG.random.bool(65))
		lightning.x = FlxG.random.int(-250, 280);
	else
		lightning.x = FlxG.random.int(780, 900);

	// Darken characters
	FlxTween.color(boyfriend, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
	FlxTween.color(dad, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
	FlxTween.color(gf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

	// Sound
	FlxG.sound.play(Paths.soundRandom('weekend1/lightning/Lightning', 1, 3));
}

function blazin_end(){
	ending = new FunkinVideoSprite();
	ending.onFormat(() -> {
		camGame.visible = false;
		camHUD.alpha = 0;
		endingSong = true;
        ending.camera = camOther;
		ending.screenCenter();
        ending.setGraphicSize(1280);
	});
	ending.load(Paths.video('blazinCutscene'));
	ending.onEnd(endEnding);
	add(ending);

    ending.play();
}

function endEnding()
{
    if(ending == null) return;
        
    ending.stop();
    ending.destroy();
    endSong();
    ending = null;
}

function goodNoteHit(note)
{
	//trace('hit note! ${note.noteType}');
	rainTimeScale += 0.7;
}