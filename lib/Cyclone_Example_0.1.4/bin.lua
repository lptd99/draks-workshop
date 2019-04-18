--Cyclone_Example_Bin

--The bin table that will be added
local example_bin = {}

--The name that will be used when calling the command
example_bin.name = "example"

--The command that will be called.
--Takes the arguments in a table where 0 is the command name
--And rawinput which is the entirety of the command string including the name
example_bin.call = function(args, rawinput)
	--If the first argument of the command is echo print the full command to both ML console and Cyclone terminal
	if args[1] == "echo" then
		print("Rawinput : " .. rawinput)
		Cyclone.terminal.write("Rawinput : " .. rawinput)
	end
end

--Adds it to the terminal
Cyclone.terminal.add(example_bin)