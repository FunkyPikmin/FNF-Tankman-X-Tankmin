-- when the stage lua is created
local trainMoving = false
local trainCooldown = 0

local trainFrameTiming = 0

local startedMoving = false

local trainFinishing = false

local trainCars = 0

local tankAngle = 0
local tankSpeed = 0
local time = 0

local exponential2 = 0

function create(stage)
	print(stage .. " is our stage!")
	createSound("train", "gunSound", "shared")
end

function start(stage)
	print(stage .. " is our stage!")

	randomizeStuff(getPropertyFromClass("flixel.FlxG", "game.ticks"))

	tankAngle = math.random(-90, 45)
	tankSpeed = math.random(5, 7)

	moveDaTank()
end

-- called each frame with elapsed being the seconds between the last frame
function update(elapsed)
	time = time + elapsed
	
	moveDaTank()

	if trainMoving then
		trainFrameTiming = trainFrameTiming + elapsed
		playCharacterAnimation("boyfriend", "hey", false)

		if trainFrameTiming >= 1 / 24 then
			updateTrainPos()
			trainFrameTiming = 0
		end
	end	
end

-- everytime a beat hit is called on the song this happens
function beatHit(curBeat)
	randomizeStuff()
	
	if not trainMoving then
		trainCooldown = trainCooldown + 1
	end

	if curBeat % 8 == 4 and math.random(1,10) <= 3 and not trainMoving and trainCooldown > 8 then
		trainCooldown = math.random(-4, 0)
		startDaTrain()
	end
	
	if curBeat % 2 == 0 then
		playActorAnimation("tankman1", "bop", true)
		playActorAnimation("tankman2", "bop", true)
		playActorAnimation("tankman3", "bop", true)
		playActorAnimation("tankman4", "bop", true)
		playActorAnimation("tankman5", "bop", true)
		playActorAnimation("tankman6", "bop", true)
		playActorAnimation("watchtower", "bop", true)		
	end
end

function startDaTrain()
	trainMoving = true

	playSound("train", true)
end

function updateTrainPos()
	startedMoving = true

	if startedMoving then
		setActorX(getActorX("train") - 400, "train")

		if getActorX("train") < -2000 and not trainFinishing then
			setActorX(-1150, "train")
			trainCars = trainCars - 1

			if trainCars <= 0 then
				trainFinishing = true
			end
		end

		if getActorX("train") < -4000 and trainFinishing then
			trainReset()
		end
	end
end

function trainReset()
	setActorX(windowWidth + 300, "train")
	trainMoving = false
	trainCars = 8
	trainFinishing = false
	startedMoving = false
end

function randomizeStuff()
	local ticks = getPropertyFromClass("flixel.FlxG", "game.ticks") / 1000

	local offsetRand = songBpm + bpm + curBeat + scrollspeed + keyCount + curStep + crochet + safeZoneOffset + screenWidth + screenHeight + fpsCap
	offsetRand = offsetRand + getWindowX() + getWindowY()
	offsetRand = offsetRand + ticks
	
	math.randomseed(time + offsetRand)
end

function moveDaTank()
	local tankX = 400

	tankAngle = tankAngle + (getPropertyFromClass("flixel.FlxG", "elapsed") * tankSpeed)

	setActorAngle(tankAngle - 90 + 15, "rollingTank")
	
	local x = tankX + 1500 * math.cos(math.pi / 180 * (1 * tankAngle + 180))
	local y = 1300 + 1100 * math.sin(math.pi / 180 * (1 * tankAngle + 180))

	setActorX(x, "rollingTank")
	setActorY(y, "rollingTank")
end
-- any other functions from regular modcharts can also be put here :DDD