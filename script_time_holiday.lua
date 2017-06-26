-- Enable holiday switch if there is noone home in the evening
-- This assumes that if noone is home by 10pm then probably they
-- won't be coming back tonight. If they are, there is another script
-- that will turn off the holiday switch if someone decides to return

local socket = 'Ogrzewanie: Dzień/Noc'  -- Heating mode day/night
local alarm = 'Arm 1 partition'         -- Alarm system arm status
local holiday = 'Ogólne: Wakacje'       -- Holiday switch

time = os.date("*t")
commandArray = {}

if (time.hour >= 22 and time.min == 0 and otherdevices[alarm] == 'On') then
	commandArray[socket] = 'Off'
	commandArray[holiday] = 'On'
end

return commandArray
