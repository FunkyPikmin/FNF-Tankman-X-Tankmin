function onEvent(name, position, argument1, argument2)
    if string.lower(name) == "tankman" then
		setCharacterShouldDance("dad", false)
		playCharacterAnimation("dad", "prettygood", true)
    end
end