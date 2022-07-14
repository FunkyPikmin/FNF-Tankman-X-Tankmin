function onEvent(name, position, argument1, argument2)
    if string.lower(name) == "unfreeze" then
		setCharacterShouldDance("dad", true)
    end
end