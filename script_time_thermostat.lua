-- A thermostat script that I use to control my gas boiler. It uses data
-- from a 433,92MHz temperature sensor and a few other inputs to regulate temperature
-- It is based on a script by Martin Rourke:
-----------------------------------------------------------------------------------------------
-- Heating Control
-- Version 0.4.1
-- Author - Martin Rourke

-- This library is free software: you can redistribute it and/or modify it under the terms of 
-- the GNU Lesser General Public License as published by the Free Software Foundation, either 
-- version 3 of the License, or (at your option) any later version. This library is distributed
-- in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
-- Public License for more details. You should have received a copy of the GNU Lesser General 
-- Public License along with this library.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------------------------



-- Set basic variables
local threshold_low = 0.2 -- How much temperature has to drop below setpoint before heating turns on
local threshold_high = 0.0	-- How much temperature has to raise above setpoint before heating turns off
local sensor = 'Temp: Pokój'	-- Sensor to derive room temperature
local switch = 'Ogrzewanie: Kocioł'	-- Physical switch to operate (boiler switch)
local mode = 'Ogrzewanie: Dzień/Noc' -- Day/Night mode switch

-- Thermostats to use for day, night and holiday temperature setting
local thermostat_day = 'Termostat: Dzień' -- Day
local thermostat_night = 'Termostat: Noc' -- Night
local thermostat_holiday = 'Termostat: Wakacje' -- Holidays
local thermostat_select = thermostat_night	-- Default thermostat

local presence = 'Ogólne: Obecność'	-- Presence indicator switch
local holiday = 'Ogólne: Wakacje'	-- Holiday indicator switch
local command = 'Off' -- Default command

local minupdateint = 60	-- Minimum time interval between switch operations to avoid switching device too often
local retransmit = 900  -- Retransmit command minimum interval (failsafe for switches that do not report status)

function timedifference (s)
	year = string.sub(s, 1, 4)
	month = string.sub(s, 6, 7)
	day = string.sub(s, 9, 10)
	hour = string.sub(s, 12, 13)
	minutes = string.sub(s, 15, 16)
	seconds = string.sub(s, 18, 19)
	t1 = os.time()
	t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
	difference = os.difftime (t1, t2)
	return difference
end

function debuglog (s)
	if uservariables["Debug"] == 1 then print("THERMOSTAT: " .. s) end
	return true
end

function getsetpoint()
	local setpoint
	-- Select correct thermostat setting based on holiday and presence
	-- Could use more variables like time of day, day of week, etc.
	if (otherdevices[holiday] == 'On') then
		debuglog ('Holiday')
		thermostat_select = thermostat_holiday
	elseif (otherdevices[mode] == 'On') then
		debuglog ('Heating mode: day')
		thermostat_select = thermostat_day
	else
		debuglog ('Heating mode: night')
		thermostat_select = thermostat_night
	end

	setpoint = otherdevices_svalues[thermostat_select]
	debuglog ('Selected setting: '.. thermostat_select)
	return setpoint
end

function updatedevice(cmd)
	-- Transmits new command if different from current status and time 'minupdateint' since last update has elapsed
	-- If command is the same as current status, retransmit the same command if time 'retransmit' interval has elapsed
	if (otherdevices[switch] == cmd and timedifference(otherdevices_lastupdate[switch]) > retransmit) then
		debuglog ('Retransmitting: ' .. cmd)
		commandArray[switch] = cmd
	elseif ( otherdevices[switch] ~= cmd and timedifference(otherdevices_lastupdate[switch]) > minupdateint) then
		debuglog ('Transmit new command: ' .. cmd)
		commandArray[switch] = cmd
	else
		debuglog ('Transmission time not reached')
	end
end
	
commandArray = {}

-- Get current room temperature
local temperature = tonumber(string.gmatch(otherdevices_svalues[sensor], '([^;]+)')(1))

-- Get requested room temperature (thermostat setpoint)
local settemp = getsetpoint()
debuglog ('Actual temp: '.. temperature)
debuglog ('Setpoint   :' .. settemp)

-- Decide whether to turn the heating on or off
if (temperature < (settemp - threshold_low)) then
	debuglog ('Temperature low, heating on')
	updatedevice('On')
elseif (temperature > (settemp + threshold_high)) then
	debuglog ('Temperature high, heating off')
	updatedevice('Off')
else
	debuglog ('No need to do anything')
	updatedevice(otherdevices[switch])
end

return commandArray
