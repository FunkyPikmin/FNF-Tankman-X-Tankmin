package states;

import flixel.util.FlxTimer;
import game.Replay;
import utilities.MusicUtilities;
import lime.utils.Assets;
#if discord_rpc
import utilities.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import game.Character;
import lime.app.Application;
import modding.PolymodHandler;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class MainMenuState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'options'];

	var magenta:FlxSprite;
	var arrow:FlxSprite;
	var camFollow:FlxObject;
	var tankman:FlxSprite;
	var tankmin:FlxSprite;
	var xposMan:Float = 0;
	var yposMan:Float = 0;
	var xposMin:Float = 0;
	var yposMin:Float = 0;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('main menu/checker', 'preload'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

	override function create()
	{
		/*if(PolymodHandler.metadataArrays.length > 0)
			optionShit.push('mods');*/

		if(Replay.getReplayList().length > 0)
			optionShit.push('replays');

		if(FlxG.save.data.warplant)
			optionShit.insert(1, 'freeplay');
		
		#if !web
		//optionShit.push('multiplayer');
		#end
		
		MusicBeatState.windowNameSuffix = "";
		
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || FlxG.sound.music.playing != true)
			TitleState.playTitleMusic();

		persistentUpdate = persistentDraw = true;

		

		var bg:FlxSprite;

		if(utilities.Options.getData("menuBGs"))
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		else
			bg = new FlxSprite(-80).makeGraphic(1286, 730, FlxColor.fromString("#FDE871"), false, "optimizedMenuBG");

		bg.scrollFactor.x = 0.18;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.4));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFBDF8, 0xAAFFFDF3], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		if(utilities.Options.getData("menuBGs"))
			magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		else
			magenta = new FlxSprite(-80).makeGraphic(1286, 730, FlxColor.fromString("#E1E1E1"), false, "optimizedMenuDesat");

		magenta.scrollFactor.x = 0.18;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.4));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0 + (i * 240), 60 + (i * 240));
			menuItem.frames = Paths.getSparrowAtlas('main menu/' + optionShit[i], 'preload');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0.5, 0.5);
			menuItem.scale.set(1.5, 1.5);
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06 * (60 / Main.display.currentFPS));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 38, 0, 'Tankman X Tankmin v1.5.0', 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, 'Leather Engine 0.4.2-git', 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		arrow = new FlxSprite(-80).loadGraphic(Paths.image('main menu/arrow', 'preload'));
		arrow.scrollFactor.set(0.5, 0.5);
		arrow.screenCenter();
		arrow.antialiasing = true;
		add(arrow);

		tankman = new FlxSprite();
		tankmin = new FlxSprite();
		tankman.frames = Paths.getSparrowAtlas('main menu/tankman', 'preload');
		tankman.animation.addByPrefix('idle', "Idle", 24);
		tankman.animation.addByPrefix('down', "Down", 24);
		tankman.animation.addByPrefix('up', "Up", 24);
		tankman.animation.addByPrefix('left', "Right", 24); //Both Tankman and Tankmin are flipped.
		tankman.animation.addByPrefix('right', "Left", 24); //Both Tankman and Tankmin are flipped.
		tankman.animation.play('idle');
		tankman.x = -80;
		tankman.y = 210;	
		tankmin.frames = Paths.getSparrowAtlas('main menu/tankmin', 'preload');
		tankmin.animation.addByPrefix('idle', "Idle", 24);
		tankmin.animation.addByPrefix('down', "Down", 24);
		tankmin.animation.addByPrefix('up', "Up", 24);
		tankmin.animation.addByPrefix('left', "Right", 24); //Both Tankman and Tankmin are flipped.
		tankmin.animation.addByPrefix('right', "Left", 24); //Both Tankman and Tankmin are flipped.
		tankmin.animation.play('idle');
		tankmin.x = 900;
		tankmin.y = -60;
		tankman.flipX = true;
		tankmin.flipX = true;
		tankman.scrollFactor.set();
		tankmin.scrollFactor.set();
		//tankman.alpha = 0.6;
		//tankmin.alpha = 0.6;
		tankman.scale.set(0.6, 0.6);
		tankman.antialiasing = true;
		tankmin.antialiasing = true;
		add(tankman);
		add(tankmin);

		xposMan = tankman.x;
		yposMan = tankman.y;
		yposMin = tankmin.y;
		xposMin = tankmin.x;

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		checker.x -= 0.225;
		checker.y -= 0.08;

		FlxG.camera.followLerp = 0.06 * (60 / Main.display.currentFPS);
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1 * Math.floor(FlxG.mouse.wheel));
			}

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				tankman.animation.play('up', true);
				tankmin.animation.play('up', true);
				tankman.x = xposMan - 34 * tankman.scale.x;
				tankman.y = yposMan - 50 * tankman.scale.y;
				tankmin.x = xposMin - -6;
				tankmin.y = yposMin - -11;
				new FlxTimer().start(0.3, function(deadTime:FlxTimer)
				{
					tankman.animation.play('idle', false);
					tankmin.animation.play('idle', false);
					tankman.x = xposMan;
					tankman.y = yposMan;
					tankmin.x = xposMin;
					tankmin.y = yposMin;
				});
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				tankman.animation.play('down', true);
				tankmin.animation.play('down', true);
				tankman.x = xposMan - 60 * tankman.scale.x;
				tankman.y = yposMan - -93 * tankman.scale.y;
				tankmin.x = xposMin - 46;
				tankmin.y = yposMin - -73;
				new FlxTimer().start(0.3, function(deadTime:FlxTimer)
				{
					tankman.animation.play('idle', false);
					tankmin.animation.play('idle', false);
					tankman.x = xposMan;
					tankman.y = yposMan;
					tankmin.x = xposMin;
					tankmin.y = yposMin;
				});
			}

			if (controls.LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				tankman.animation.play('left', true);
				tankmin.animation.play('left', true);
				tankman.x = xposMan - 70 * tankman.scale.x;
				tankman.y = yposMan - -15 * tankman.scale.y;				
				tankmin.x = xposMin - 60;
				tankmin.y = yposMin - -52;
				new FlxTimer().start(0.3, function(deadTime:FlxTimer)
				{
					tankman.animation.play('idle', false);
					tankmin.animation.play('idle', false);
					tankman.x = xposMan;
					tankman.y = yposMan;
					tankmin.x = xposMin;
					tankmin.y = yposMin;
				});
			}

			if (controls.RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				tankman.animation.play('right', true);
				tankmin.animation.play('right', true);
				tankman.x = xposMan - -10 * tankman.scale.x;
				tankman.y = yposMan - -20 * tankman.scale.y;				
				tankmin.x = xposMin - 8;
				tankmin.y = yposMin - -62;
				new FlxTimer().start(0.3, function(deadTime:FlxTimer)
				{
					tankman.animation.play('idle', false);
					tankmin.animation.play('idle', false);
					tankman.x = xposMan;
					tankman.y = yposMan;
					tankmin.x = xposMin;
					tankmin.y = yposMin;
				});
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if(utilities.Options.getData("flashingLights"))
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						if(utilities.Options.getData("flashingLights"))
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(_) { fard(); });
							FlxFlicker.flicker(arrow, 1, 0.06, false, false, function(_) { fard(); });
						}
						else
							new FlxTimer().start(1, function(_) { fard(); }, 1);
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{

		});
	}

	function fard()
	{
		var daChoice:String = optionShit[curSelected];
		
		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");

			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.switchState(new OptionsMenu());

			#if sys
			case 'mods':
				FlxG.switchState(new ModsMenu());

			case 'replays':
				FlxG.switchState(new ReplaySelectorState());
			#end
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				if(menuItems.length > 2)
				{
					camFollow.setPosition(spr.getGraphicMidpoint().x * 1.5, spr.getGraphicMidpoint().y * 1.5);
				}
				arrow.x = spr.x + 500;
				arrow.y = spr.y + 95;
			}

			spr.updateHitbox();
		});
	}
}
