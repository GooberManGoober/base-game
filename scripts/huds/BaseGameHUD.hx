import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextFormat;

import funkin.objects.Bar;
import funkin.objects.HealthIcon;

import funkin.FunkinAssets;
import funkin.utils.MathUtil;

public var healthBar:Bar;
public var iconP1:HealthIcon;
public var iconP2:HealthIcon;
public var scoreTxt:FlxText;

var healthLerp:Float = 1;

var pixelZoom:Float = 6; // idgaf

// TODO: Make combo shit change for week 6, the ground work is already there so incase someone else wants to come on in and mess w it.
function onLoad()
{
    name = 'BASE GAME';

    ratingPrefix = Paths.RATINGS_PREFIX;
    comboPrefix = Paths.COMBO_PREFIX;
    
    final healthGraphic = FunkinAssets.exists(Paths.mods('images/${Paths.UI_PREFIX}healthBar')) ? '${Paths.UI_PREFIX}healthBar' : 'UI/healthBar';
    
    healthBar = new Bar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), healthGraphic, function() return healthLerp, parent.healthBounds.min, parent.healthBounds.max);
    healthBar.screenCenter(FlxAxes.X);
    healthBar.leftToRight = false;
    healthBar.scrollFactor.set();
    healthBar.visible = !ClientPrefs.hideHud;
    healthBar.alphaMultipler = ClientPrefs.healthBarAlpha;
    
    reloadHealthBarColors();
    add(healthBar);
    
    iconP1 = new HealthIcon(parent.boyfriend.healthIcon, true);
    iconP1.y = healthBar.y - 75;
    iconP1.visible = !ClientPrefs.hideHud;
    iconP1.alphaMultipler = ClientPrefs.healthBarAlpha;
    iconP1.frameCount = parent.boyfriend.iconFrames;
    add(iconP1);
    
    iconP2 = new HealthIcon(parent.dad.healthIcon, false);
    iconP2.y = healthBar.y - 75;
    iconP2.visible = !ClientPrefs.hideHud;
    iconP2.alphaMultipler = ClientPrefs.healthBarAlpha;
    iconP2.frameCount = parent.dad.iconFrames;
    add(iconP2);
    
    scoreTxt = new FlxText(healthBar.x + 50, healthBar.y + 30, Std.int(healthBar.width - 100), "", 16);
    scoreTxt.setFormat(Paths.DEFAULT_FONT, 16, FlxColor.WHITE, "right", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    scoreTxt.scrollFactor.set();
    scoreTxt.borderSize = 1.25;
    scoreTxt.visible = !ClientPrefs.hideHud;
    add(scoreTxt);
    
    ratingGraphic = new FlxSprite();
    ratingGraphic.alpha = 0;
    add(ratingGraphic);
    
    ratingNumGroup = new FlxTypedGroup();
    add(ratingNumGroup);
    
    onUpdateScore(0, 0, 0);
    
    parent.scripts.set('healthBar', healthBar);
    parent.scripts.set('iconP1', iconP1);
    parent.scripts.set('iconP2', iconP2);
    parent.scripts.set('scoreTxt', scoreTxt);
    
    if (comboOffsets == null) comboOffsets = ClientPrefs.comboOffset;
}

function onUpdateScore(?score:Int = 0, ?accuracy:Float = 0, ?misses:Int = 0, ?missed:Bool = false)
{   
    scoreTxt.text = 'Score: ${FlxStringUtil.formatMoney(score, false)}\n';
}

public function updateIconsPosition()
{
    if (!updateIconPos) return;
    
    final iconOffset:Int = 26;
    if (!healthBar.leftToRight)
    {
        iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
        iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
    }
    else
    {
        iconP1.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
        iconP2.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
    }
}

public function updateIconsScale(elapsed:Float)
{
    if (!updateIconScale) return;
    
    final mult:Float = MathUtil.decayLerp(iconP1.scale.x, 1, 9, elapsed);
    iconP1.scale.set(mult, mult);
    iconP1.updateHitbox();
    
    final mult:Float = MathUtil.decayLerp(iconP2.scale.x, 1, 9, elapsed);
    iconP2.scale.set(mult, mult);
    iconP2.updateHitbox();
}

public function updateIconsAnimation()
{
    iconP1.updateIconAnim(healthBar.percent * 0.01);
    iconP2.updateIconAnim((100 - healthBar.percent) * 0.01);
}

function updateHealthBar() healthLerp = FlxMath.lerp(healthLerp, parent.health, .2 / (ClientPrefs.framerate / 60));

public function reloadHealthBarColors()
{
    if (!healthBar.leftToRight) healthBar.setColors(0xFFFF0000, 0xFF66FF33);
    else healthBar.setColors(0xFF66FF33, 0xFFFF0000);
}

public function flipBar()
{
    healthBar.leftToRight = !healthBar.leftToRight;
    iconP1.flipX = !iconP1.flipX;
    iconP2.flipX = !iconP2.flipX;
}

function onUpdate(elapsed)
{
    updateIconsPosition();
    updateIconsScale(elapsed);
    updateIconsAnimation();
    updateHealthBar();

    if (FlxG.keys.justPressed.NINE && parent.canAccessEditors)
    {
        if (iconP1.characterName == parent.boyfriend.healthIcon) iconP1.changeIcon('bf-old');
        else iconP1.changeIcon(parent.boyfriend.healthIcon, true);
    }

    if (!parent.startingSong && !parent.paused && parent.updateTime && !parent.endingSong)
    {
        var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
        parent.songPercent = (curTime / parent.songLength);
        
        var songCalc:Float = (parent.songLength - curTime);
        if (ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;
        
        var secondsTotal:Int = Math.floor(songCalc / 1000);
        if (secondsTotal < 0) secondsTotal = 0;
    }
}

function onBeatHit()
{
    if (!updateIconScale) return;
    
    iconP1.scale.set(1.2, 1.2);
    iconP2.scale.set(1.2, 1.2);
    
    iconP1.updateHitbox();
    iconP2.updateHitbox();
}

function onCharacterChange()
{
    reloadHealthBarColors();

    iconP1.changeIcon(parent.boyfriend.healthIcon);
    iconP1.frameCount = parent.boyfriend.iconFrames;

    iconP2.changeIcon(parent.dad.healthIcon);
    iconP2.frameCount = parent.dad.iconFrames;
}

function onHealthChange(health)
{
    final newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
    healthBar.percent = (newPercent != null ? newPercent : 0);
}

function onPopUpScore(daRating, combo, note)
{
    final ratingImage = daRating.image;
		
    final posX = FlxG.width * 0.35;
    
    if (ClientPrefs.hideHud) return;
    
    parent.scripts.call('onPopUpScore', [note, daRating, ratingGraphic, ratingNumGroup]);
    
    if (showRating)
    {
        FlxTween.cancelTweensOf(ratingGraphic, ['scale.x', 'scale.y', 'alpha']);
        ratingGraphic.alpha = 1;
        ratingGraphic.loadGraphic(Paths.image(ratingPrefix + ratingImage + ratingSuffix));
        ratingGraphic.screenCenter();
        ratingGraphic.x = posX - 40;
        ratingGraphic.y -= 60;
        ratingGraphic.x += comboOffsets[0];
        ratingGraphic.y -= comboOffsets[1];
        
        if (comboTween)
        {
            ratingGraphic.scale.set(0.785, 0.785);
            FlxTween.tween(ratingGraphic.scale, {x: 0.7, y: 0.7}, 0.5, {ease: FlxEase.expoOut});
        }
        ratingGraphic.updateHitbox();
        FlxTween.tween(ratingGraphic, {alpha: 0}, 0.5, {startDelay: Conductor.stepCrotchet * 0.01, ease: FlxEase.expoOut});
    }
    
    if (showRatingNum)
    {
        for (i in ratingNumGroup)
        {
            if (i.alive)
            {
                i.kill();
            }
        }
        
        var seperatedScore:Array<Int> = [];
        
        if (combo >= 1000)
        {
            seperatedScore.push(Math.floor(combo / 1000) % 10);
        }
        seperatedScore.push(Math.floor(combo / 100) % 10);
        seperatedScore.push(Math.floor(combo / 10) % 10);
        seperatedScore.push(combo % 10);
        
        var daLoop:Int = 0;
        for (i in seperatedScore)
        {
            var numScore:FlxSprite = ratingNumGroup.recycle(FlxSprite);
            FlxTween.cancelTweensOf(numScore);
            
            numScore.loadGraphic(Paths.image(comboPrefix + 'num' + Std.int(i) + ratingSuffix));
            numScore.alpha = 1;
            numScore.screenCenter();
            numScore.x = posX + (43 * daLoop) - 90;
            numScore.y += 80;
            numScore.x += comboOffsets[2];
            numScore.y -= comboOffsets[3];
            
            if (comboTween)
            {
                numScore.scale.set(0.6, 0.6);
                FlxTween.cancelTweensOf(numScore, ['scale.x', 'scale.y']);
                FlxTween.tween(numScore.scale, {x: 0.5, y: 0.5}, 0.5, {ease: FlxEase.expoOut});
            }
            numScore.updateHitbox();
            ratingNumGroup.add(numScore);
            FlxTween.tween(numScore, {alpha: 0}, 0.5, {startDelay: Conductor.stepCrotchet * 0.01, ease: FlxEase.expoOut});
            
            daLoop++;
        }
    }
    
    parent.scripts.call('onPopUpScorePost', [note, daRating, ratingGraphic, ratingNumGroup]);
}

function cachePopUpScore()
{
    var ratings = ["sick", "good", "bad", "shit"];
    if (ClientPrefs.useEpicRankings) ratings.push('epic');
    
    for (rating in ratings) ratingGraphic.loadGraphic(Paths.image('$ratingPrefix$rating$ratingSuffix'));
    
    for (i in 0...10) Paths.image('${comboPrefix}num$i$ratingSuffix');
}