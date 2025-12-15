--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v13,v14) local v15={};for v20=1, #v13 do v6(v15,v0(v4(v1(v2(v13,v20,v20 + 1 )),v1(v2(v14,1 + (v20% #v14) ,1 + (v20% #v14) + 1 )))%256 ));end return v5(v15);end local v8=game:GetService(v7("\225\207\218\60\227\169\212","\126\177\163\187\69\134\219\167"));local v9=game:GetService(v7("\17\216\36\246\249\49\219\35\198\249","\156\67\173\74\165"));local v10=v8.LocalPlayer;local v11=1891 -(1242 + 649) ;local function v12(v16) print(v7("\15\180\69\31\185\40\82\9","\38\84\215\41\118\220\70"),v16);end v12(v7("\92\25\35\22\251\84\86\36\29\236\16","\158\48\118\66\114")   .. v10.Name );v8.PlayerAdded:Connect(function(v17) v12(v17.Name   .. v7("\235\46\31\63\125\160\255","\155\203\68\112\86\19\197") );end);v8.PlayerRemoving:Connect(function(v18) v12(v18.Name   .. v7("\6\209\51\250\84","\152\38\189\86\156\32\24\133") );end);v9.Heartbeat:Connect(function(v19) v11+=v19 if (v11>=(13 -8)) then v12(v7("\253\91\174\80\249\23","\38\156\55\199")   .. math.floor(os.clock()) );v11=0 + 0 ;end end);
