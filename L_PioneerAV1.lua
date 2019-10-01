-- L_PioneerAV1.lua

local socket = require "socket"
local tcp = assert(socket.tcp())
local debug
local tmp

local ipAddress = nil
local ipPort = nil

local Pioneer_SID   = "urn:shward1-com:serviceId:PioneerNavigation1"
local Switch_SID    = "urn:upnp-org:serviceId:SwitchPower1"
local Upnp_SID      = "urn:upnp-org:serviceId:RenderingControl1"

local minVol = 0
local maxVol = 161

inputUser = {
  [04] = "DVD",
  [25] = "BD",
  [05] = "TV",
  [06] = "SAT/CBL",
  [15] = "DVR/BDR",
  [10] = "Video 1",
  [14] = "Video 2",
  [19] = "HDMI1",
  [20] = "HDMI2",
  [21] = "HDMI3",
  [22] = "HDMI4",
  [23] = "HDMI5",
  [26] = "Internet",
  [17] = "iPod/USB",
  [18] = "XM Radio",
  [01] = "CD",
  [03] = "CD-R/Tape",
  [02] = "Tuner",
  [00] = "Phono"
}

inputMain = {
  [04] = "DVD",
  [25] = "BD",
  [05] = "TVSAT",
  [06] = "SATCBL",
  [15] = "DVRBDR",
  [10] = "Video1",
  [14] = "Video2",
  [19] = "HDMI1",
  [20] = "HDMI2",
  [21] = "HDMI3",
  [22] = "HDMI4",
  [23] = "HDMI5",
  [26] = "Internet",
  [17] = "IpodUSB",
  [18] = "XMRadio",
  [01] = "CD",
  [03] = "CDRTape",
  [02] = "Tuner",
  [00] = "Phono"
}

local function log(stuff)
    luup.log("PioneerAV: " .. stuff)
end

local function sendCommand(cmd)
  log("Sending Command: " .. cmd)
  local fail = luup.variable_get("urn:micasaverde-com:serviceId:HaDevice1","CommFailure",lul_device)
  local result = luup.io.write(cmd)
  local result2
    if not result then
          log("Cannot send command " .. cmd .. " communications error, retrying")
          Reconnect(lul_device)
          result2 = luup.io.write(cmd)
          if not result2 and (fail == "false" or fail =="0") then
            log("Cannot send command " .. cmd .. " communications error")
            luup.set_failure(true)
            return false
          elseif fail=="true" or fail == "1" then
            luup.set_failure(false)
            return true
          end
    elseif fail=="true" or fail == "1" then
        luup.set_failure(false)
        return true
    end
end

local function setVolume(code)
    local code = string.format("%03d" ,(math.floor(((maxVol-minVol)*code)/100+minVol+1)))
    sendCommand(code .. "VL")
end

local function get_dev_and_socket (device)
  local devNo = tonumber (device) or scheduler.current_device()
  local dev = devNo and luup.devices [devNo]
  return dev, (dev or {io = {}}).io.socket, devNo
end

function setIfChanged(serviceId, name, value, deviceId)
  local curValue = luup.variable_get(serviceId, name, deviceId)
  if ((value ~= curValue) or (curValue == nil)) then
    luup.variable_set(serviceId, name, value, deviceId)
    return true
  else
    return false
  end
end

local function handleEncodedResponse(func, code, data)
  if(func == "CLV") then
    --
  elseif(func == "VSB") then
    --
  elseif(func == "VHT") then
    --
  elseif(func == "FL") then
    --
  else
    --
  end
end

local function handleInputNames(func, code, data)
  log("Handling RGB")
  local inNum = data:sub(4, 5)
  local inName = data:sub(7)
  inputUser[tonumber(inNum)] = inName
  log("RGB - Input Num: " .. inNum .. ", Input Name: " .. inName)

      if(inNum == "04") then
        setIfChanged(Pioneer_SID, "04_DVD", inName, lul_device)
      elseif(inNum == "25") then
        setIfChanged(Pioneer_SID, "25_BD", inName, lul_device)
      elseif(inNum == "05") then
        setIfChanged(Pioneer_SID, "05_TVSAT", inName, lul_device)
      elseif(inNum == "06") then
        setIfChanged(Pioneer_SID, "06_SATCBL", inName, lul_device)
      elseif(inNum == "15") then
        setIfChanged(Pioneer_SID, "15_DVRBDR", inName, lul_device)
      elseif(inNum == "10") then
        setIfChanged(Pioneer_SID, "10_Video1", inName, lul_device)
      elseif(inNum == "14") then
        setIfChanged(Pioneer_SID, "14_Video2", inName, lul_device)
      elseif(inNum == "19") then
        setIfChanged(Pioneer_SID, "19_HDMI1", inName, lul_device)
      elseif(inNum == "20") then
        setIfChanged(Pioneer_SID, "20_HDMI2", inName, lul_device)
      elseif(inNum == "21") then
        setIfChanged(Pioneer_SID, "21_HDMI3", inName, lul_device)
      elseif(inNum == "22") then
        setIfChanged(Pioneer_SID, "22_HDMI4", inName, lul_device)
      elseif(inNum == "23") then
        setIfChanged(Pioneer_SID, "23_HDMI5", inName, lul_device)
      elseif(inNum == "26") then
        setIfChanged(Pioneer_SID, "26_Internet", inName, lul_device)
      elseif(inNum == "17") then
        setIfChanged(Pioneer_SID, "17_IpodUSB", inName, lul_device)
      elseif(inNum == "18") then
        setIfChanged(Pioneer_SID, "18_XMRadio", inName, lul_device)
      elseif(inNum == "01") then
        setIfChanged(Pioneer_SID, "01_CD", inName, lul_device)
      elseif(inNum == "03") then
        setIfChanged(Pioneer_SID, "03_CDRTape", inName, lul_device)
      elseif(inNum == "02") then
        setIfChanged(Pioneer_SID, "02_Tuner", inName, lul_device)
      elseif(inNum == "00") then
        setIfChanged(Pioneer_SID, "00_Phono", inName, lul_device)
      else
        --
      end
end

local function handleResponse(func, code, data)
      if(func == "VOL") then
        codeDB = (tonumber(code) - 161) * .5
            code =  math.floor((tonumber(code)/(maxVol-minVol))*100)
            setIfChanged(Upnp_SID, "Volume", code, lul_device)
        setIfChanged(Pioneer_SID, "currentVolumeDB", codeDB, lul_device)
        elseif(func == "PWR") then
                if(code == "0") then
                    tmp = "1"
                else
                    tmp = "0"
                end
            setIfChanged(Switch_SID, "Status", tmp, lul_device)
      elseif(func == "FN") then
        tmp = tonumber(code)
        tmp = inputUser[tmp]
        setIfChanged(Pioneer_SID, "inputStatus", tmp, lul_device)
        tmp = tonumber(code)
        tmp = inputMain[tmp]
        setIfChanged(Pioneer_SID, "MainInput", tmp, lul_device)
      elseif(func == "MUT") then
        if(code == "0") then
          tmp = "On"
        elseif(code == "1") then
          tmp = "Off"
        else
          tmp = "Unknown"
        end
        setIfChanged(Pioneer_SID, "muteStatus", tmp, lul_device)
      end
end

function getInputNames()
  sendCommand("?P")
  sendCommand("?V")
  sendCommand("?M")
  sendCommand("?RGB04")
  sendCommand("?RGB25")
  sendCommand("?RGB05")
  sendCommand("?RGB06")
  sendCommand("?RGB15")
  sendCommand("?RGB10")
  sendCommand("?RGB14")
  sendCommand("?RGB19")
  sendCommand("?RGB20")
  sendCommand("?RGB21")
  sendCommand("?RGB22")
  sendCommand("?RGB23")
  sendCommand("?RGB26")
  sendCommand("?RGB17")
  sendCommand("?RGB18")
  sendCommand("?RGB01")
  sendCommand("?RGB03")
  sendCommand("?RGB02")
  sendCommand("?RGB00")
end

function Connect(lul_device)

local ip = luup.devices[lul_device].ip

if (ip == nil) or (#ip == 0) then
  luup.task("ip address not entered!", 2, "yourplugin", -1)
  luup.log("yourplugin: ip address not set.")
return false
end

ip = string.gsub(ip," ","")
ipAddress, ipPort = string.match(ip,"(%d+%.%d+%.%d+%.%d+)%:?(%d*)")
if (ipAddress == nil) or (#ipAddress == 0) then
  luup.task("Invalid ip address: " .. ip, 2, "PioneerAV", -1)
  luup.log("PioneerAV: Invalid ip address: " .. ip)
  return false
end

if (ipPort == nil) or (#ipPort == 0) then
  ipPort = 23
  luup.attr_set("ip",ipAddress .. ":" .. ipPort,lul_device)
  luup.log("PioneerAV: Port not specified, " .. ipPort .. " assumed.")
end

local debSV = luup.variable_get(Pioneer_SID,"Debug", lul_device)
if debSV == nil then
  debSV = "0"
  luup.variable_set(Pioneer_SID,"Debug",debSV,lul_device)
end
debug = (tonumber(debSV) > 0)
luup.io.open(lul_device, ipAddress, ipPort)
end

function Pioneer_incoming(lul_data)
  local data = tostring(lul_data)
  local func = data:match("^%a+")
  code = data:match("%d+")

  log("Response - Function:" .. func .. ", Code: " .. code .. ", Raw: " .. data)
    if((func == "CLV") or (func == "VSB") or (func == "VHT") or (func == "FL"))  then
     handleEncodedResponse(func, code, data)
     log("handleEncodedResponse")
    elseif(func == "RGB") then
     handleInputNames(func, code, data)
    else
     handleResponse(func, code, data)
     log("handleResponse")
    end
end

function Reconnect(lul_device)
    local dev, sock = get_dev_and_socket(lul_device)
    if dev and sock then
        Connect(device)
    end
end

function PioneerAVStartup(lul_device)
Connect(lul_device)
log("Running I_PioneerAV1.xml on  " .. ipAddress .. " for lul_device " .. ":" .. lul_device)
luup.call_delay("getInputNames", 5)
end
