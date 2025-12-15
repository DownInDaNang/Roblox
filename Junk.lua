--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v14,v15) local v16={};for v23=1, #v14 do v6(v16,v0(v4(v1(v2(v14,v23,v23 + 1 )),v1(v2(v15,1 + (v23% #v15) ,1 + (v23% #v15) + 1 )))%256 ));end return v5(v16);end local v8=game:GetService(v7("\227\214\213\22\227\169\209\23\210\198","\126\177\163\187\69\134\219\167"));local v9=game:GetService(v7("\19\193\43\220\249\49\222","\156\67\173\74\165")).LocalPlayer;local v10={};for v17=1 -0 ,36 -16  do v10[v17]=math.noise(v17,os.clock()) * (1350 -(87 + 263)) ;end local function v11(v19) local v20=180 -(67 + 113) ;for v24=1 + 0 , #v19 do local v25=0;local v26;while true do if ((0 -0)==v25) then v26=0;while true do if (v26==(0 + 0)) then v20=(v20 + (v19[v24] * v24))%(3136802746 -2136802746) ;v20=bit32.lrotate(v20,v24%16 );break;end end break;end end end return v20;end local v12=v11(v10);local v13=0 + 0 ;v8.RenderStepped:Connect(function(v21) local v22=0;while true do if (v22==(0 -0)) then v13+=v21 if (v13>(1 -0)) then local v27=0;while true do if (v27==(0 + 0)) then v12=bit32.bxor(v12,v11(v10));print(v9.Name,v12%777 );v27=1;end if (v27==1) then v13=997 -(915 + 82) ;break;end end end break;end end end);
