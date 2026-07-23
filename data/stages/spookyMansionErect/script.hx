var lightningStrikeBeat:Int = 0;
var lightningStrikeOffset:Int = 8;

var bfLight:Character;
var dadLight:Character;
var gfLight:Character;

function onCreatePost()
{
	bfLight = new Character(0, 0, boyfriend.curCharacter == "pico" ? 'pico-dark' : 'bf', true);
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
	
	gfLight = new Character(0, 0, gf.curCharacter == "nene" ? 'nene-dark' : 'gf', false);
	gfLight.danceEveryNumBeats = gf.danceEveryNumBeats;
	gfLight.danceIdle = true;
	gfLight.alpha = 0.0001;
	gfGroup.addChar(gfLight);
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
}

function onCountdownTick(swagCounter)
{
	dadLight?.onBeatHit(swagCounter);
	bfLight?.onBeatHit(swagCounter);
	gfLight?.onBeatHit(swagCounter);
}
