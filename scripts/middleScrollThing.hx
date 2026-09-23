function onCreatePost()
{
    if (ClientPrefs.middleScroll)
    {
        modManager.setValue("opponentSwap", 0.5, 0);

        modManager.setValue("transformX", -600, 1);
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
        if (iconP1.characterName == boyfriend.healthIcon) iconP1.changeIcon('bf-old');
        else iconP1.changeIcon(boyfriend.healthIcon, true);
    }
}