-- This script automates relationship between
-- holiday mode and people present at the house
-- It is mainly used to automatically disable holiday mode
-- upon detecting that there are actually people in the house

local presence = 'Ogólne: Obecność'           -- Switch indicating presence
local holiday = 'Ogólne: Wakacje'             -- Switch indicating holidays
local heatingmode = 'Ogrzewanie: Dzień/Noc'   -- Switch that select Day/Night heating mode

commandArray = {}

-- Disable holiday mode if presence detected
if (devicechanged[presence] == 'On') then
  commandArray[holiday] = 'Off'
end

-- Disable heating and presence if holiday mode selected manually
if (devicechanged[holiday] == 'On') then
	commandArray[heatingmode] = 'Off'
	commandArray[presence] = 'Off'
end

return commandArray
