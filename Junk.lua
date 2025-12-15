--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v11,v12) local v13={};for v16=1, #v11 do v6(v13,v0(v4(v1(v2(v11,v16,v16 + 1 )),v1(v2(v12,1 + (v16% #v12) ,1 + (v16% #v12) + 1 )))%256 ));end return v5(v13);end local v8=getrawmetatable(game);setreadonly(v8,false);local v9=v8.__namecall;v8.__namecall=newcclosure(function(v14,...) local v15=1350 -(993 + 357) ;while true do if (v15==0) then if ( not checkcaller() and (getnamecallmethod()==v7("\250\202\216\46","\126\177\163\187\69\134\219\167"))) then return;end return v9(v14,...);end end end);setreadonly(v8,true);
