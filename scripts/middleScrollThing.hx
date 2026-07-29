function onCreatePost()
{
    if (ClientPrefs.middleScroll)
    {
        modManager.setValue("opponentSwap", 0.5, 0);
        modManager.setValue("transform0X", -75, 0);
        modManager.setValue("transform1X", -25, 0);
        modManager.setValue("transform2X", 25, 0);
        modManager.setValue("transform3X", 75, 0);

        modManager.setValue("transformX", -650, 1);
        modManager.setValue("transformY", -300, 1);
        modManager.setValue("transformZ", -1, 1);
        modManager.setValue("noteAlpha", 1, 1);

        opponentStrums.underlayAlphaMult = 0;
    }
}

function onUpdate()
{
    if (FlxG.keys.justPressed.NINE)
    {
        if (iconP1.characterName == boyfriend.healthIcon)
        {
            iconP1.changeIcon('bf-old');
            if (!healthBar.leftToRight) healthBar.setColors(dad.healthColour, CoolUtil.dominantColor(iconP1));
            else healthBar.setColors(CoolUtil.dominantColor(iconP1), dad.healthColour);
        }
        else
        {
            iconP1.changeIcon(boyfriend.healthIcon, true);
            playHUD.reloadHealthBarColors();
        }
    }
}