-- I have two thermostats in Domoticz, one for day, another for night heating modes
-- but only one dispayed on a tablet interface, together with day/night mode switch. 
-- This script updates correct thermostat based on the day/night selector and vice versa

-- Set basic devices

local temp_day = 'Termostat: Dzień'             -- Thermostat used in day mode
local temp_night = 'Termostat: Noc'             -- Thermostat used in night mode
local temp_indicator = 'Termostat: Wskazanie'   -- Thermostat displayed on the tablet
local mode_switch = 'Ogrzewanie: Dzień/Noc'     -- Heating mode selector day/night

-- Domoticz indexes for the devices above (updating thermostat directly does not work correctly at the moment)
local temp_day_idx = 82
local temp_night_idx = 94
local temp_indicator_idx = 459

-- Debug logging function
function debuglog (s)
	if uservariables["Debug"] == 1 then print("SETPOINT: " .. s) end
	return true
end

commandArray = {}

-- If user updates indicated thermostat and heating mode is day, update the day thermostat
if (devicechanged[temp_indicator] and otherdevices[mode_switch] == 'On') then
	debuglog('Indicated temperature changed, updating day thermostat')
	commandArray['OpenURL'] = 'http://localhost:8080/json.htm?type=command&param=udevice&idx=' .. tostring(temp_day_idx) .. '&nvalue=0&svalue=' .. tostring(otherdevices_svalues[temp_indicator])
-- If user updates indicated thermostat and heating mode is night, update the night thermostat
elseif (devicechanged[temp_indicator] and otherdevices[mode_switch] == 'Off') then
	debuglog('Indicated temperature changed, updating night thermostat')
	commandArray['OpenURL'] = 'http://localhost:8080/json.htm?type=command&param=udevice&idx=' .. tostring(temp_night_idx) .. '&nvalue=0&svalue=' .. tostring(otherdevices_svalues[temp_indicator])
-- If user changes the day/night mode
elseif (devicechanged[mode_switch]) then
	-- Day mode selected, set indicated thermostat to day value
	if (otherdevices[mode_switch] == 'On' and otherdevices_svalues[temp_day] ~= otherdevices_svalues[temp_indicator]) then
		debuglog('Mode selected - day, updating indicator')
		commandArray['OpenURL'] = 'http://localhost:8080/json.htm?type=command&param=udevice&idx=' .. tostring(temp_indicator_idx) .. '&nvalue=0&svalue=' .. tostring(otherdevices_svalues[temp_day])
	-- Night mode selected, set indicated thermostat to night value
	elseif (otherdevices[mode_switch] == 'Off' and otherdevices_svalues[temp_night] ~= otherdevices_svalues[temp_indicator]) then
		debuglog('Mode selected - night, updating indicator')
		commandArray['OpenURL'] = 'http://localhost:8080/json.htm?type=command&param=udevice&idx=' .. tostring(temp_indicator_idx) .. '&nvalue=0&svalue=' .. tostring(otherdevices_svalues[temp_night])
	end
end

return commandArray
