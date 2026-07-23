import openfl.filters.ShaderFilter;

import animate.FlxAnimateFrames;
import animate.FlxAnimate;

import flixel.addons.display.FlxTiledSprite;

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

var picoFade:FlxSprite;

var casingGroup:FlxSpriteGroup;
var casingFrames:FlxAtlasFrames;
var gunPrepSnd:FlxSound;
var bonkSnd:FlxSound;
var lightCanSnd:FlxSound;
var kickCanSnd:FlxSound;
var kneeCanSnd:FlxSound;

var mist0:FlxBackdrop;
var mist1:FlxBackdrop;
var mist2:FlxBackdrop;
var mist3:FlxBackdrop;
var mist4:FlxBackdrop;
var mist5:FlxBackdrop;

function onLoad()
{
	addMist();
	
	if(!ClientPrefs.lowQuality)
	{
		var skyImage = Paths.image('backgrounds/phillyStreets/erect/phillySkybox');
		scrollingSky = new FlxTiledSprite(skyImage, skyImage.width + 400, skyImage.height, true, false);
		scrollingSky.antialiasing = ClientPrefs.globalAntialiasing;
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);
		scrollingSky.zIndex = 10;
		add(scrollingSky);
		darkenable.push(scrollingSky);
	
		var phillySkyline:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillySkyline', -545, -273, 0.2, 0.2);
		phillySkyline.zIndex = 20;
		add(phillySkyline);
		darkenable.push(phillySkyline);

		var phillyForegroundCity:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyForegroundCity', 600, 69, 0.3, 0.3);
		phillyForegroundCity.zIndex = 30;
		add(phillyForegroundCity);
		darkenable.push(phillyForegroundCity);

		var phillyForegroundCity2:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyForegroundCity', 1860, 185, 0.3, 0.3);
		phillyForegroundCity2.angle = 5;
		phillyForegroundCity2.zIndex = 30;
		add(phillyForegroundCity2);
		darkenable.push(phillyForegroundCity2);
	}

	var phillyConstruction2:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyConstruction', 1795, 360, 0.7, 1);
	phillyConstruction2.zIndex = 40;
	add(phillyConstruction2);
	darkenable.push(phillyConstruction2);

	var phillyHighwayLights:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyHighwayLights', 122, 201, 0.8, 0.8);
	phillyHighwayLights.zIndex = 50;
	add(phillyHighwayLights);
	darkenable.push(phillyHighwayLights);

	if(!ClientPrefs.lowQuality)
	{
		var phillyHighwayLightsLightmap:BGSprite = new BGSprite('backgrounds/phillyStreets/phillyHighwayLights_lightmap', 122, 201, 0.8, 0.8);
		phillyHighwayLightsLightmap.blend = BlendMode.ADD;
		phillyHighwayLightsLightmap.alpha = 0.6;
		phillyHighwayLightsLightmap.zIndex = 50;
		add(phillyHighwayLightsLightmap);
		darkenable.push(phillyHighwayLightsLightmap);
	}

	var phillyHighway2:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyHighway', -23, 105, 0.8, 0.8);
	phillyHighway2.zIndex = 60;
	add(phillyHighway2);
	darkenable.push(phillyHighway2);

	if(!ClientPrefs.lowQuality)
	{
		var grey1:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/greyGradient', -388, 7, 1, 1);
		grey1.scale.set(1.3, 1.3);
		grey1.zIndex = 91;
		grey1.alpha = 0.3;
		grey1.blend = 0;
		darkenable.push(grey1);

		var grey2:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/greyGradient', -388, 7, 1, 1);
		grey2.scale.set(1.3, 1.3);
		grey2.zIndex = 91;
		grey2.alpha = 0.8;
		grey2.blend = 9;
		darkenable.push(grey2);

		for (i in 0...2)
		{
			var car:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyCars', 1200, 818, 0.9, 1, ['car1', 'car2', 'car3', 'car4'], false);
			add(car);
			switch(i)
			{
				case 0: phillyCars = car;
				case 1: phillyCars2 = car;
			}
			darkenable.push(car);
		}
		phillyCars.zIndex = 80;
		phillyCars2.flipX = true;
		phillyCars2.zIndex = 78;

		phillyTraffic = new BGSprite('backgrounds/phillyStreets/erect/phillyTraffic', 1840, 608, 0.9, 1, ['redtogreen', 'greentored'], false);
		phillyTraffic.zIndex = 90;
		add(phillyTraffic);
		darkenable.push(phillyTraffic);

		var phillyTrafficLightmap:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyTraffic_lightmap', 1840, 608, 0.9, 1);
		phillyTrafficLightmap.blend = BlendMode.ADD;
		phillyTrafficLightmap.alpha = 0.6;
		phillyTrafficLightmap.zIndex = 90;
		add(phillyTrafficLightmap);
		darkenable.push(phillyTrafficLightmap);
	}

	var phillyForeground:BGSprite = new BGSprite('backgrounds/phillyStreets/erect/phillyForeground', 88, 317, 1, 1);
	phillyForeground.zIndex = 100;
	add(phillyForeground);
	darkenable.push(phillyForeground);

	if(!ClientPrefs.lowQuality)
	{
		picoFade = new FlxSprite();
		picoFade.antialiasing = ClientPrefs.globalAntialiasing;
		picoFade.alpha = 0;
		add(picoFade);
		darkenable.push(picoFade);
	}
	
	spraycanPile = new BGSprite('backgrounds/phillyStreets/SpraycanPile', 850, 1050, 1, 1);
	spraycanPile.zIndex = 355;
	add(spraycanPile);
	darkenable.push(spraycanPile);
}

function addMist()
{
    mist0 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistMid'), 0x01);
    mist0.setPosition(-650, -100);
    mist0.scrollFactor.set(1.2, 1.2);
    mist0.zIndex = 1000;
    mist0.blend = 0;
    mist0.color = 0xFF5c5c5c;
    mist0.alpha = 0.6;
    mist0.velocity.x = 172;

    add(mist0);

    mist1 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistMid'), 0x01);
    mist1.setPosition(-650, -100);
    mist1.scrollFactor.set(1.1, 1.1);
    mist1.zIndex = 1000;
    mist1.blend = 0;
    mist1.color = 0xFF5c5c5c;
    mist1.alpha = 0.6;
    mist1.velocity.x = 150;

    add(mist1);

    mist2 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistBack'), 0x01);
    mist2.setPosition(-650, -100);
    mist2.scrollFactor.set(1.2, 1.2);
    mist2.zIndex = 1001;
    mist2.blend = 0;
    mist2.color = 0xFF5c5c5c;
    mist2.alpha = 0.8;
    mist2.velocity.x = -80;

    add(mist2);

    mist3 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistMid'), 0x01);
    mist3.setPosition(-650, -100);
    mist3.scrollFactor.set(0.95, 0.95);
    mist3.zIndex = 99;
    mist3.blend = 0;
    mist3.color = 0xFF5c5c5c;
    mist3.alpha = 0.5;
    mist3.velocity.x = -50;
    mist3.scale.set(0.8, 0.8);

    add(mist3);

    mist4 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistBack'), 0x01);
    mist4.setPosition(-650, -100);
    mist4.scrollFactor.set(0.8, 0.8);
    mist4.zIndex = 88;
    mist4.blend = 0;
    mist4.color = 0xFF5c5c5c;
    mist4.alpha = 1;
    mist4.velocity.x = 40;
    mist4.scale.set(0.7, 0.7);

    add(mist4);

    mist5 = new FlxBackdrop(Paths.image('backgrounds/phillyStreets/erect/mistMid'), 0x01);
    mist5.setPosition(-650, -100);
    mist5.scrollFactor.set(0.5, 0.5);
    mist5.zIndex = 39;
    mist5.blend = 0;
    mist5.color = 0xFF5c5c5c;
    mist5.alpha = 1;
    mist5.velocity.x = 20;
    mist5.scale.set(1.1, 1.1);

    add(mist5);
}

var noteTypes:Array<String> = [];
function onCreatePost()
{
	precache();
	
	var unspawnNotes:Array<Note> = game.queueNotes;
	for (note in unspawnNotes)
	{
		if(note == null) continue;

		//override animations for note types
		switch(note.noteType)
		{
			case 'firegun':
				note.blockHit = true;
		}
		if(!noteTypes.contains(note.noteType)) noteTypes.push(note.noteType);
	}
	
	switch (PlayState.SONG.song.toLowerCase())
	{
		case 'darnell':
			rainShaderStartIntensity = 0;
			rainShaderEndIntensity = 0.1;
		case 'lit up':
			rainShaderStartIntensity = 0.1;
			rainShaderEndIntensity = 0.2;
		case '2hot':
			rainShaderStartIntensity = 0.2;
			rainShaderEndIntensity = 0.4;
	}
	
	rainShader = newShader('rain');
	rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
	rainShader.setFloat('uTime', 0);
	rainShader.setFloat('uScale', FlxG.height / 300);
	rainShader.setFloat('uIntensity', rainShaderStartIntensity);
	FlxG.camera.filters = [new ShaderFilter(rainShader)];

	colorShader = newShader('adjustColor');
    colorShader.setFloat('hue', -5);
    colorShader.setFloat('saturation', -40);
    colorShader.setFloat('contrast', -25);
    colorShader.setFloat('brightness', -20);

	dad.shader = gf.shader = boyfriend.shader = colorShader;

	if(!isStoryMode) return;
    if (PlayState.SONG.song.toLowerCase() == "2hot") songEndCallback = blazin_intro;
}

var neneTimer = 0;
var _timer:Float = 0;

function onUpdate(elapsed)
{
	if (scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 22;
	
	rainTime += elapsed;
	
	var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, rainShaderStartIntensity, rainShaderEndIntensity);
	
	rainShader.setFloatArray('uCameraBounds', [
		camGame.scroll.x + camGame.viewMarginX,
		camGame.scroll.y + camGame.viewMarginY,
		camGame.scroll.x + camGame.viewMarginX + camGame.width,
		camGame.scroll.y + camGame.viewMarginY + camGame.height
	]);
	rainShader.setFloat('uTime', rainTime);
	rainShader.setFloat('uIntensity', remappedIntensityValue);

	_timer += elapsed;
	mist0.y = 660 + (Math.sin(_timer * 0.35) * 70);
    mist1.y = 500 + (Math.sin(_timer * 0.3) * 80);
    mist2.y = 540 + (Math.sin(_timer * 0.4) * 60);
    mist3.y = 230 + (Math.sin(_timer * 0.3) * 70);
    mist4.y = 170 + (Math.sin(_timer * 0.35) * 50);
    mist5.y = -80 + (Math.sin(_timer * 0.08) * 100);
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

function driveCarBack(sprite:BGSprite):Void
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

function cutsceneSpraycan()
{
	var explosion = new FlxSprite(1000, 200);
	explosion.frames = Paths.getSparrowAtlas('backgrounds/phillyStreets/SpraypaintExplosion');
	explosion.animation.addByPrefix("idle", "Explosion 1 movie", 24, false);
	explosion.animation.play("idle");
	explosion.animation.finishCallback = () -> {
		explosion.kill();
	}
	stage.add(explosion);
	explosion.zIndex = 999;
	refreshZ(stage);
}

function precache()
{
	var didCreateCan = false;
	function createCan()
	{
		if(didCreateCan) return;

		lightCanSnd = new FlxSound();
		FlxG.sound.list.add(lightCanSnd);
		lightCanSnd.loadEmbedded(Paths.sound('weekend1/Darnell_Lighter'));
		
		kickCanSnd = new FlxSound();
		FlxG.sound.list.add(kickCanSnd);
		kickCanSnd.loadEmbedded(Paths.sound('weekend1/Kick_Can_UP'));

		kneeCanSnd = new FlxSound();
		FlxG.sound.list.add(kneeCanSnd);
		kneeCanSnd.loadEmbedded(Paths.sound('weekend1/Kick_Can_FORWARD'));
		didCreateCan = true;
	}

	var didCreateCasing = false;
	function precacheCasing()
	{
		if(didCreateCasing) return;
		if(!ClientPrefs.lowQuality)
		{
			casingFrames = Paths.getSparrowAtlas('backgrounds/phillyStreets/PicoBullet'); //precache
			casingGroup = new FlxSpriteGroup();
			add(casingGroup);
		}
		
		gunPrepSnd = new FlxSound();
		FlxG.sound.list.add(gunPrepSnd);
		gunPrepSnd.loadEmbedded(Paths.sound('weekend1/Gun_Prep'));
		didCreateCasing = true;
	}

	for (noteType in noteTypes)
	{
		switch(noteType)
		{
			case 'kickcan':
				createCan();
			case 'cockgun':
				precacheCasing();
			case 'firegun':
				bonkSnd = new FlxSound();
				FlxG.sound.list.add(bonkSnd);
				bonkSnd.loadEmbedded(Paths.sound('weekend1/Pico_Bonk'));
		}
	}
	
	createCan();
	precacheCasing();

	for (i in 1...5)
		Paths.sound('weekend1/shots/shot$i');
}

function goodNoteHit(note:te)
{
	switch(note.noteType)
	{
		case 'cockgun': // HE'S PULLING HIS COCK OUT
			boyfriend.holdTimer = 0;
			boyfriend.playAnim('cock', true);
			boyfriend.specialAnim = true;
			gunPrepSnd.play();

			boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
			{
				switch(name)
				{
					case 'cock':
						if(frameNumber == 3)
						{
							boyfriend.animation.callback = null;
							createCasing();
						}
					default: boyfriend.animation.callback = null;
				}
			}

			notes.forEachAlive(function(note:Note)
			{
				if(note.noteType == 'firegun')
					note.blockHit = false;
			});
			showPicoFade();

		case 'firegun':
			boyfriend.holdTimer = 0;
			boyfriend.playAnim('shoot', true);
			boyfriend.specialAnim = true;
			FlxG.sound.play(Paths.soundRandom('weekend1/shots/shot', 1, 4));
			cutsceneCan.visible = false;
			cutsceneSpraycan();

			new FlxTimer().start(1/24, function(tmr)
			{
				darkenStageProps();
			});
	}
}

function createCasing()
{
	if(ClientPrefs.lowQuality) return;

	var casing:FlxSprite = new FlxSprite(boyfriend.x + 250, boyfriend.y + 100);
	casing.frames = casingFrames;
	casing.animation.addByPrefix('pop', 'Pop0', 24, false);
	casing.animation.addByPrefix('idle', 'Bullet0', 24, true);
	casing.animation.play('pop', true);
	
	casing.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
	{
		if (name == 'pop' && frameNumber == 40)
		{
			// Get the end position of the bullet dynamically.
			casing.x = casing.x + casing.frame.offset.x - 1;
			casing.y = casing.y + casing.frame.offset.y + 1;
	
			casing.angle = 125.1; // Copied from FLA
	
			// Okay this is the neat part, we can set the velocity and angular acceleration to make it roll without editing update().
			var randomFactorA:Float = FlxG.random.float(3, 10);
			var randomFactorB:Float = FlxG.random.float(1.0, 2.0);
			casing.velocity.x = 20 * randomFactorB;
			casing.drag.x = randomFactorA * randomFactorB;
	
	
			casing.angularVelocity = 100;
			// Calculated to ensure angular acceleration is maintained through the whole roll.
			casing.angularDrag = (casing.drag.x / casing.velocity.x) * 100;
	
			casing.animation.play('idle');
			casing.animation.callback = null; // Save performance.
		}
	};
	casingGroup.add(casing);
}

function opponentNoteHit(note)
{
	var sndTime:Float = note.strumTime - Conductor.songPosition;
	switch(note.noteType)
	{
		case 'lightcan':
			dad.holdTimer = 0;
			dad.playAnim('lightCan', true);
			dad.specialAnim = true;
			lightCanSnd.play(true, sndTime - 65);
			
			isCameraOnForcedPos = true;
			defaultCamZoom += 0.1;
			moveCamera(true);
			game.cameraSpeed = 2;
			camFollow.x -= 100;
		case 'kickcan':
			dad.holdTimer = 0;
			dad.playAnim('kickCan', true);
			dad.specialAnim = true;
			kickCanSnd.play(true, sndTime - 50);
			cutsceneCan.animation.play('up');
			cutsceneCan.visible = true;
			camFollow.x += 500;
			cameraSpeed = 1.5;
			defaultCamZoom -= 0.1;
			
			new FlxTimer().start(1.1, function(_) {
				isCameraOnForcedPos = false;
				moveCameraSection();
				cameraSpeed = 1;
			});
		case 'kneecan':
			dad.holdTimer = 0;
			dad.playAnim('kneeCan', true);
			dad.specialAnim = true;
			kneeCanSnd.play(true, sndTime - 22);
			cutsceneCan.animation.play('forward');
	}
}

var picoFlicker:FlxTimer = null;
function noteMiss(note)
{
	switch(note.noteType)
	{
		case 'firegun':
			boyfriend.playAnim('shootMISS', true);
			boyfriend.specialAnim = true;
			bonkSnd.play();
			
			if(picoFlicker != null)
			{
				picoFlicker.cancel();
				picoFlicker.destroy();
			}
			picoFlicker = null;

			boyfriend.animation.finishCallback = function(name:String)
			{
				if (name == 'shootMISS' && game.health > 0.0 && !game.practiceMode && game.gameOverTimer == null)
				{
					//FlxFlicker was crashing so fuck it, FlxTimer all the way
					picoFlicker = new FlxTimer().start(1 / 30, function(tmr:FlxTimer)
					{
						boyfriend.visible = !boyfriend.visible;
						if(tmr.loopsLeft == 0)
						{
							boyfriend.visible = true;
							picoFlicker = new FlxTimer().start(1 / 60, function(tmr2:FlxTimer)
							{
								boyfriend.visible = !boyfriend.visible;
								if(tmr2.loopsLeft == 0)
								{
									boyfriend.visible = true;
									//trace('test 2');
								}
							}, 30);
						}
					}, 30);
					//trace('test');
				}
				boyfriend.animation.finishCallback = null;
			}
			
			health -= 0.4;
	}
}

function showPicoFade()
{
	if (ClientPrefs.lowQuality) return;

	picoFade.setPosition(boyfriend.x, boyfriend.y);
	picoFade.frames = boyfriend.frames;
	picoFade.frame = boyfriend.frame;
	picoFade.alpha = 0.3;
	picoFade.scale.set(1, 1);
	picoFade.updateHitbox();
	picoFade.visible = true;

	FlxTween.cancelTweensOf(picoFade.scale);
	FlxTween.cancelTweensOf(picoFade);
	FlxTween.tween(picoFade.scale, {x: 1.3, y: 1.3}, 0.4);
	FlxTween.tween(picoFade, {alpha: 0}, 0.4, {onComplete: (_) -> (picoFade.visible = false)});
}

function darkenStageProps()
{
	// Darken the background, then fade it back.
	for (sprite in darkenable)
	{
		// If not excluded, darken.
		sprite.color = 0xFF111111;
		new FlxTimer().start(1/24, (tmr) ->
		{
			sprite.color = 0xFF222222;
			FlxTween.color(sprite, 1.4, 0xFF222222, 0xFFFFFFFF);
		});
	}
}
