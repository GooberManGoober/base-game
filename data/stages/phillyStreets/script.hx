import openfl.filters.ShaderFilter;

import animate.FlxAnimateFrames;
import animate.FlxAnimate;

import flixel.addons.display.FlxTiledSprite;

var skipCutscene = false;
var seenCutscene = false;
var rainShader:FlxRuntimeShader;
var rainShaderStartIntensity:Float = 0;
var rainShaderEndIntensity:Float = 0.01;
var rainTime:Float = 0;
var scrollingSky:FlxTiledSprite;
var phillyTraffic:BGSprite;
var phillyCars:BGSprite;
var phillyCars2:BGSprite;
var spraycanPile:BGSprite;
var darkenable:Array<FlxSprite> = [];

function onLoad()
{
	if (!ClientPrefs.lowQuality)
	{
		var skyImage = Paths.image('backgrounds/phillyStreets/phillySkybox');
		scrollingSky = new FlxTiledSprite(skyImage, skyImage.width + 400, skyImage.height, true, false);
		scrollingSky.antialiasing = ClientPrefs.globalAntialiasing;
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);
		add(scrollingSky);
		darkenable.push(scrollingSky);
		
		var phillySkyline:BGSprite = new BGSprite('backgrounds/phillyStreets/phillySkyline', -545, -273, 0.2, 0.2);
		add(phillySkyline);
		darkenable.push(phillySkyline);
		
		var phillyForegroundCity:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyForegroundCity', 600, 69, 0.3, 0.3);
		add(phillyForegroundCity);
		darkenable.push(phillyForegroundCity);
		
		var phillyForegroundCity2:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyForegroundCity', 1860, 185, 0.3, 0.3);
		phillyForegroundCity2.angle = 5;
		add(phillyForegroundCity2);
		darkenable.push(phillyForegroundCity2);
	}
	
	var phillyConstruction:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyConstruction', 1795, 360, 0.7, 1);
	add(phillyConstruction);
	darkenable.push(phillyConstruction);
	
	var phillyHighwayLights:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyHighwayLights', 122, 201, 1, 1);
	add(phillyHighwayLights);
	darkenable.push(phillyHighwayLights);
	
	if (!ClientPrefs.lowQuality)
	{
		var phillyHighwayLightsLightmap:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyHighwayLights_lightmap', 122, 201, 1, 1);
		phillyHighwayLightsLightmap.blend = BlendMode.ADD;
		phillyHighwayLightsLightmap.alpha = 0.6;
		add(phillyHighwayLightsLightmap);
		darkenable.push(phillyHighwayLightsLightmap);
	}
	
	var phillyHighway:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyHighway', 139, 209, 1, 1);
	add(phillyHighway);
	darkenable.push(phillyHighway);
	
	if (!ClientPrefs.lowQuality)
	{
		var phillySmog:BGSprite = new BGSprite('backgrounds/phillyStreets/phillySmog', -6, 245, 0.8, 1);
		add(phillySmog);
		darkenable.push(phillySmog);
		
		for (i in 0...2)
		{
			var car:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyCars', 1200, 818, 0.9, 1, ['car1', 'car2', 'car3', 'car4'], false);
			add(car);
			switch (i)
			{
				case 0:
					phillyCars = car;
				case 1:
					phillyCars2 = car;
			}
			darkenable.push(car);
		}
		phillyCars2.flipX = true;
		
		phillyTraffic = new BGSprite('backgrounds/phillyStreets/phillyTraffic', 1840, 608, 0.9, 1, ['redtogreen', 'greentored'], false);
		add(phillyTraffic);
		darkenable.push(phillyTraffic);
		
		var phillyTrafficLightmap:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyTraffic_lightmap', 1840, 608, 0.9, 1);
		phillyTrafficLightmap.blend = BlendMode.ADD;
		phillyTrafficLightmap.alpha = 0.6;
		add(phillyTrafficLightmap);
		darkenable.push(phillyTrafficLightmap);
	}
	
	var phillyForeground:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyForeground', 88, 317, 1, 1);
	add(phillyForeground);
	darkenable.push(phillyForeground);
	
	spraycanPile = new BGSprite('weekend1/SpraycanPile', 50, 420, 1, 1);
	spraycanPile.zIndex = 5;
	add(spraycanPile);
	darkenable.push(spraycanPile);
	
	cutsceneCan = new FlxSprite();
	cutsceneCan.frames = Paths.getSparrowAtlas('weekend1/wked1_cutscene_1_can');
	cutsceneCan.animation.addByPrefix('forward', "can kick quick", 24, false);
	cutsceneCan.animation.addByPrefix('up', "can kicked up", 24, false);
	cutsceneCan.zIndex = 4;
	// cutsceneCan.animation.play('up');
	cutsceneCan.visible = false;
	cutsceneCan.setPosition(spraycanPile.x + 60, spraycanPile.y - 320);
	add(cutsceneCan);
	darkenable.push(cutsceneCan);
	for (i in [spraycanPile, cutsceneCan])
	{
		i.x += 845;
		i.y += 630;
	}
}

function onCreatePost()
{
	switch (PlayState.SONG.song.toLowerCase())
	{
		case 'darnell':
			startIntensity = 0;
			endIntensity = 0.1;
		case 'lit-up':
			startIntensity = 0.1;
			endIntensity = 0.2;
		case '2hot':
			startIntensity = 0.2;
			endIntensity = 0.4;
	}
	
	rainShader = newShader('rain');
	rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
	rainShader.setFloat('uTime', 0);
	rainShader.setFloat('uScale', FlxG.height / 300);
	rainShader.setFloat('uIntensity', startIntensity);
	FlxG.camera.filters = [new ShaderFilter(rainShader)];
}

var neneTimer = 0;

function onUpdate(elapsed)
{
	if (scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 22;
	
	rainTime += elapsed;
	rainTime += 1;
	
	var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, startIntensity, endIntensity);
	
	rainShader.setFloatArray('uCameraBounds', [
		camGame.scroll.x + camGame.viewMarginX,
		camGame.scroll.y + camGame.viewMarginY,
		camGame.scroll.x + camGame.viewMarginX + camGame.width,
		camGame.scroll.y + camGame.viewMarginY + camGame.height
	]);
	rainShader.setFloat('uTime', rainTime);
	rainShader.setFloat('uIntensity', remappedIntensityValue);
	
	if (!skipCutscene && !seenCutscene)
	{
		neneTimer += elapsed;
		if (neneTimer >= 0.6)
		{
			neneTimer = 0;
			gf.dance();
		}
	}
}

var lightsStop:Bool = false;
var lastChange:Int = 0;
var changeInterval:Int = 8;
var carWaiting:Bool = false;
var carInterruptable:Bool = true;
var car2Interruptable:Bool = true;

function onBeatHit()
{
	if (ClientPrefs.lowQuality) return;
	
	if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true)
	{
		if (lightsStop == false) driveCar(phillyCars);
		else driveCarLights(phillyCars);
	}
	
	if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false) driveCarBack(phillyCars2);
	
	if (curBeat == (lastChange + changeInterval)) changeLights(curBeat);
}

function changeLights(beat:Int):Void
{
	lastChange = beat;
	lightsStop = !lightsStop;
	
	if (lightsStop)
	{
		phillyTraffic.animation.play('greentored');
		changeInterval = 20;
	}
	else
	{
		phillyTraffic.animation.play('redtogreen');
		changeInterval = 30;
		
		if (carWaiting == true) finishCarLights(phillyCars);
	}
}

function finishCarLights(sprite:BGSprite):Void
{
	carWaiting = false;
	var duration:Float = FlxG.random.float(1.8, 3);
	var rotations:Array<Int> = [-5, 18];
	var offset:Array<Float> = [306.6, 168.3];
	var startdelay:Float = FlxG.random.float(0.2, 1.2);
	
	var path:Array<FlxPoint> = [
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
		FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
	];
	
	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay});
	FlxTween.quadPath(sprite, path, duration, true, {ease: FlxEase.sineIn, startDelay: startdelay, onComplete: function(_) carInterruptable = true});
}

function driveCarLights(sprite:BGSprite):Void
{
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	var extraOffset = [0, 0];
	var duration:Float = 2;
	
	switch (variant)
	{
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.9, 1.5);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	var rotations:Array<Int> = [-7, -5];
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	
	var path:Array<FlxPoint> = [
		FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
		FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
	];
	
	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut});
	FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				carWaiting = true;
				if (lightsStop == false) finishCarLights(phillyCars);
			}
		});
}

function driveCar(sprite:BGSprite):Void
{
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	
	var extraOffset = [0, 0];
	var duration:Float = 2;
	switch (variant)
	{
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	// random arbitrary values for getting the cars in place
	// could just add them to the points but im LAZY!!!!!!
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	// start/end rotation
	var rotations:Array<Int> = [-8, 18];
	// the path to move the car on
	var path:Array<FlxPoint> = [
		FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
		FlxPoint.get(3102 - offset[0], 1187 - offset[1] + 40)
	];
	
	FlxTween.angle(sprite, rotations[0], rotations[1], duration);
	FlxTween.quadPath(sprite, path, duration, true, {onComplete: function(_) carInterruptable = true});
}

function driveCarBack(sprite:FlxSprite):Void
{
	car2Interruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	
	var extraOffset = [0, 0];
	var duration:Float = 2;
	switch (variant)
	{
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	
	var rotations:Array<Int> = [18, -8];
	var path:Array<FlxPoint> = [
		FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
		FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)
	];
	
	FlxTween.angle(sprite, rotations[0], rotations[1], duration);
	FlxTween.quadPath(sprite, path, duration, true, {onComplete: function(_) car2Interruptable = true});
}

function onStartCountdown()
{
	if (!skipCutscene && !seenCutscene)
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'darnell':
				Paths.getSparrowAtlas('weekend1/spraypaintExplosionEZ');
				Paths.getSparrowAtlas('weekend1/SpraypaintExplosion');
				
				FunkinSound.playMusic(Paths.music('darnellCanCutscene/darnellCanCutscene'));
				snapCamToPos(getCharacterCameraPos(boyfriend).x + 250, getCharacterCameraPos(boyfriend).y + 80, true);
				
				playHUD.visible = false;
				camGame.visible = false;
				cameraSpeed = 5;
				camGame.zoom = 1.3;
				camHUD.alpha = 0;
				dad.canDance = false;
				boyfriend.canDance = false;
				boyfriend.playAnim('intro1', true);
				
				FlxTimer.wait(0.5, () -> {
					camGame.flash(FlxColor.BLACK, 3);
					camGame.visible = true;
					FlxTween.tween(camGame, {zoom: 0.75}, 5, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(2, () -> {
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x + 350, y: getCharacterCameraPos(dad).y}, 2.5, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(5, () -> {
					dad.playAnim('lightCan', true);
					FlxG.sound.play(Paths.sound('Darnell_Lighter'));
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x + 150}, 0.5, {ease: FlxEase.quadInOut});
					FlxTween.tween(camGame, {zoom: 0.9}, 0.625, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(6, () -> {
					boyfriend.playAnim('cock', true);
					FlxG.sound.play(Paths.sound('Gun_Prep'));
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x + 500, y: getCharacterCameraPos(dad).y}, 0.4, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(6.4, () -> {
					dad.playAnim('kickCan', true);
					FlxG.sound.play(Paths.sound('Kick_Can_UP'));
					cutsceneCan.animation.play('up');
					cutsceneCan.visible = true;
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x + 350, y: getCharacterCameraPos(dad).y}, 0.5, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(6.9, () -> {
					dad.playAnim('kneeCan', true);
					FlxG.sound.play(Paths.sound('Kick_Can_FORWARD'));
					cutsceneCan.animation.play('forward');
					FlxTween.tween(camGame, {zoom: 0.7}, 0.325, {ease: FlxEase.quadInOut});
				});
				
				FlxTimer.wait(7.1, () -> {
					boyfriend.playAnim('intro2', true);
					FlxG.sound.play(Paths.sound('shot' + FlxG.random.int(1, 4)));
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x + 100, y: getCharacterCameraPos(dad).y - 25}, 2.5, {ease: FlxEase.quadInOut});
					cutsceneCan.visible = false;
					cutsceneSpraycan();
					
					for (i in darkenable)
						FlxTween.color(i, 1, 0xFF3F3F3F, FlxColor.WHITE);
				});
				
				FlxTimer.wait(7.9, () -> {
					dad.playAnim('laughCutscene', true);
					FlxG.sound.play(Paths.sound('cutscene/darnell_laugh'), 0.6);
				});
				
				FlxTimer.wait(8.2, () -> {
					seenCutscene = true;
					
					gf.canDance = false;
					gf.playAnim('laughCutscene', true);
					FlxG.sound.play(Paths.sound('cutscene/nene_laugh'), 0.6);
				});
				
				FlxTimer.wait(10, () -> {
					FlxTween.tween(camGame, {zoom: 0.77}, 2, {ease: FlxEase.sineInOut});
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x, y: getCharacterCameraPos(dad).y}, 2,
						{
							ease: FlxEase.sineInOut,
							onComplete: () -> {
								isCameraOnForcedPos = false;
							}
						});
					FlxG.sound.music.stop();
					cameraSpeed = 1;
					
					playHUD.visible = true;
					for (i in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2, playHUD.scoreTxt])
					{
						var ogPos = i.y;
						i.y += (ClientPrefs.downScroll ? -250 : 250);
						FlxTween.tween(i, {y: ogPos}, 1, {ease: FlxEase.quintOut, startDelay: 1});
					}
					
					FlxTween.tween(camHUD, {alpha: 1}, 2);
					
					dad.canDance = true;
					boyfriend.canDance = true;
					gf.canDance = true;
					startCountdown();
				});
			default:
				// has no cutscene
				seenCutscene = true;
				startCountdown();
		}
		return Function_Stop;
	}
}

// to do: add the spraycan stuff to 2hot and use this with it
function explodeSpraycan()
{
	var explosion = new FlxSprite(800);
	explosion.frames = Paths.getSparrowAtlas('weekend1/spraypaintExplosionEZ');
	explosion.animation.addByPrefix("idle", "explosion round 1 short0", 24, false);
	explosion.animation.play("idle");
	explosion.animation.finishCallback = () -> {
		explosion.kill();
	}
	stage.add(explosion);
	explosion.zIndex = 999;
	refreshZ(stage);
}

function cutsceneSpraycan()
{
	var explosion = new FlxSprite(1000, 200);
	explosion.frames = Paths.getSparrowAtlas('weekend1/SpraypaintExplosion');
	explosion.animation.addByPrefix("idle", "Explosion 1 movie", 24, false);
	explosion.animation.play("idle");
	explosion.animation.finishCallback = () -> {
		explosion.kill();
	}
	stage.add(explosion);
	explosion.zIndex = 999;
	refreshZ(stage);
}
