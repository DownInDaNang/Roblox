--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 63) then
					if (Enum <= 31) then
						if (Enum <= 15) then
							if (Enum <= 7) then
								if (Enum <= 3) then
									if (Enum <= 1) then
										if (Enum == 0) then
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
										elseif (Inst[2] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum == 2) then
										local A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
									else
										Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
									end
								elseif (Enum <= 5) then
									if (Enum > 4) then
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									else
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									end
								elseif (Enum > 6) then
									Stk[Inst[2]] = #Stk[Inst[3]];
								elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 11) then
								if (Enum <= 9) then
									if (Enum == 8) then
										Stk[Inst[2]] = Inst[3];
									elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 10) then
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								elseif (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 13) then
								if (Enum == 12) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								end
							elseif (Enum > 14) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A]();
							end
						elseif (Enum <= 23) then
							if (Enum <= 19) then
								if (Enum <= 17) then
									if (Enum == 16) then
										local A = Inst[2];
										local T = Stk[A];
										local B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									else
										local A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Top));
										end
									end
								elseif (Enum > 18) then
									local A = Inst[2];
									local Index = Stk[A];
									local Step = Stk[A + 2];
									if (Step > 0) then
										if (Index > Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
									elseif (Index < Stk[A + 1]) then
										VIP = Inst[3];
									else
										Stk[A + 3] = Index;
									end
								else
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
								end
							elseif (Enum <= 21) then
								if (Enum == 20) then
									local NewProto = Proto[Inst[3]];
									local NewUvals;
									local Indexes = {};
									NewUvals = Setmetatable({}, {__index=function(_, Key)
										local Val = Indexes[Key];
										return Val[1][Val[2]];
									end,__newindex=function(_, Key, Value)
										local Val = Indexes[Key];
										Val[1][Val[2]] = Value;
									end});
									for Idx = 1, Inst[4] do
										VIP = VIP + 1;
										local Mvm = Instr[VIP];
										if (Mvm[1] == 103) then
											Indexes[Idx - 1] = {Stk,Mvm[3]};
										else
											Indexes[Idx - 1] = {Upvalues,Mvm[3]};
										end
										Lupvals[#Lupvals + 1] = Indexes;
									end
									Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum == 22) then
								Stk[Inst[2]] = Upvalues[Inst[3]];
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							end
						elseif (Enum <= 27) then
							if (Enum <= 25) then
								if (Enum > 24) then
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								else
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								end
							elseif (Enum > 26) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 29) then
							if (Enum > 28) then
								if (Stk[Inst[2]] <= Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum > 30) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							Stk[Inst[2]] = Inst[3] / Inst[4];
						end
					elseif (Enum <= 47) then
						if (Enum <= 39) then
							if (Enum <= 35) then
								if (Enum <= 33) then
									if (Enum > 32) then
										local A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									else
										local A = Inst[2];
										local Cls = {};
										for Idx = 1, #Lupvals do
											local List = Lupvals[Idx];
											for Idz = 0, #List do
												local Upv = List[Idz];
												local NStk = Upv[1];
												local DIP = Upv[2];
												if ((NStk == Stk) and (DIP >= A)) then
													Cls[DIP] = NStk[DIP];
													Upv[1] = Cls;
												end
											end
										end
									end
								elseif (Enum > 34) then
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								else
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								end
							elseif (Enum <= 37) then
								if (Enum > 36) then
									Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
								else
									local A = Inst[2];
									local Step = Stk[A + 2];
									local Index = Stk[A] + Step;
									Stk[A] = Index;
									if (Step > 0) then
										if (Index <= Stk[A + 1]) then
											VIP = Inst[3];
											Stk[A + 3] = Index;
										end
									elseif (Index >= Stk[A + 1]) then
										VIP = Inst[3];
										Stk[A + 3] = Index;
									end
								end
							elseif (Enum == 38) then
								Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
							else
								Stk[Inst[2]] = Inst[3] / Inst[4];
							end
						elseif (Enum <= 43) then
							if (Enum <= 41) then
								if (Enum == 40) then
									if (Stk[Inst[2]] <= Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 42) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Stk[Inst[2]] <= Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 45) then
							if (Enum > 44) then
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
							end
						elseif (Enum == 46) then
							local A = Inst[2];
							Top = (A + Varargsz) - 1;
							for Idx = A, Top do
								local VA = Vararg[Idx - A];
								Stk[Idx] = VA;
							end
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
						end
					elseif (Enum <= 55) then
						if (Enum <= 51) then
							if (Enum <= 49) then
								if (Enum == 48) then
									if (Stk[Inst[2]] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									local Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								end
							elseif (Enum == 50) then
								Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
							else
								Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
							end
						elseif (Enum <= 53) then
							if (Enum == 52) then
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
							elseif not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 54) then
							do
								return Stk[Inst[2]]();
							end
						else
							Stk[Inst[2]] = #Stk[Inst[3]];
						end
					elseif (Enum <= 59) then
						if (Enum <= 57) then
							if (Enum == 56) then
								if (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							end
						elseif (Enum > 58) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum <= 61) then
						if (Enum > 60) then
							do
								return;
							end
						else
							do
								return Stk[Inst[2]]();
							end
						end
					elseif (Enum > 62) then
						if (Inst[2] < Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
					end
				elseif (Enum <= 95) then
					if (Enum <= 79) then
						if (Enum <= 71) then
							if (Enum <= 67) then
								if (Enum <= 65) then
									if (Enum > 64) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
									elseif (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 66) then
									if (Stk[Inst[2]] <= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
								end
							elseif (Enum <= 69) then
								if (Enum > 68) then
									local A = Inst[2];
									Stk[A] = Stk[A]();
								else
									local A = Inst[2];
									do
										return Stk[A](Unpack(Stk, A + 1, Top));
									end
								end
							elseif (Enum > 70) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								do
									return;
								end
							end
						elseif (Enum <= 75) then
							if (Enum <= 73) then
								if (Enum > 72) then
									Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
								else
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								end
							elseif (Enum > 74) then
								local A = Inst[2];
								do
									return Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							else
								local A = Inst[2];
								local Step = Stk[A + 2];
								local Index = Stk[A] + Step;
								Stk[A] = Index;
								if (Step > 0) then
									if (Index <= Stk[A + 1]) then
										VIP = Inst[3];
										Stk[A + 3] = Index;
									end
								elseif (Index >= Stk[A + 1]) then
									VIP = Inst[3];
									Stk[A + 3] = Index;
								end
							end
						elseif (Enum <= 77) then
							if (Enum > 76) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								local A = Inst[2];
								local Cls = {};
								for Idx = 1, #Lupvals do
									local List = Lupvals[Idx];
									for Idz = 0, #List do
										local Upv = List[Idz];
										local NStk = Upv[1];
										local DIP = Upv[2];
										if ((NStk == Stk) and (DIP >= A)) then
											Cls[DIP] = NStk[DIP];
											Upv[1] = Cls;
										end
									end
								end
							end
						elseif (Enum == 78) then
							if not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							Top = (A + Varargsz) - 1;
							for Idx = A, Top do
								local VA = Vararg[Idx - A];
								Stk[Idx] = VA;
							end
						end
					elseif (Enum <= 87) then
						if (Enum <= 83) then
							if (Enum <= 81) then
								if (Enum == 80) then
									do
										return Stk[Inst[2]];
									end
								else
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
								end
							elseif (Enum > 82) then
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
							else
								local A = Inst[2];
								do
									return Unpack(Stk, A, Top);
								end
							end
						elseif (Enum <= 85) then
							if (Enum > 84) then
								Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
							else
								local A = Inst[2];
								do
									return Unpack(Stk, A, Top);
								end
							end
						elseif (Enum > 86) then
							local A = Inst[2];
							local Index = Stk[A];
							local Step = Stk[A + 2];
							if (Step > 0) then
								if (Index > Stk[A + 1]) then
									VIP = Inst[3];
								else
									Stk[A + 3] = Index;
								end
							elseif (Index < Stk[A + 1]) then
								VIP = Inst[3];
							else
								Stk[A + 3] = Index;
							end
						else
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum <= 91) then
						if (Enum <= 89) then
							if (Enum == 88) then
								VIP = Inst[3];
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum == 90) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 93) then
						if (Enum == 92) then
							Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
						end
					elseif (Enum == 94) then
						Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
					else
						local A = Inst[2];
						local T = Stk[A];
						local B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
						end
					end
				elseif (Enum <= 111) then
					if (Enum <= 103) then
						if (Enum <= 99) then
							if (Enum <= 97) then
								if (Enum > 96) then
									local B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										Stk[Inst[2]] = B;
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum > 98) then
								Upvalues[Inst[3]] = Stk[Inst[2]];
							else
								local A = Inst[2];
								local T = Stk[A];
								for Idx = A + 1, Top do
									Insert(T, Stk[Idx]);
								end
							end
						elseif (Enum <= 101) then
							if (Enum > 100) then
								Upvalues[Inst[3]] = Stk[Inst[2]];
							else
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							end
						elseif (Enum == 102) then
							Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
						else
							Stk[Inst[2]] = Stk[Inst[3]];
						end
					elseif (Enum <= 107) then
						if (Enum <= 105) then
							if (Enum == 104) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
							end
						elseif (Enum == 106) then
							Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
						else
							Stk[Inst[2]] = Inst[3] ~= 0;
							VIP = VIP + 1;
						end
					elseif (Enum <= 109) then
						if (Enum > 108) then
							Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
						else
							Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
						end
					elseif (Enum > 110) then
						Stk[Inst[2]] = Stk[Inst[3]];
					else
						local B = Stk[Inst[4]];
						if not B then
							VIP = VIP + 1;
						else
							Stk[Inst[2]] = B;
							VIP = Inst[3];
						end
					end
				elseif (Enum <= 119) then
					if (Enum <= 115) then
						if (Enum <= 113) then
							if (Enum > 112) then
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
							else
								local A = Inst[2];
								local T = Stk[A];
								for Idx = A + 1, Top do
									Insert(T, Stk[Idx]);
								end
							end
						elseif (Enum == 114) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 117) then
						if (Enum == 116) then
							if (Stk[Inst[2]] < Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum == 118) then
						local A = Inst[2];
						local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
						local Edx = 0;
						for Idx = A, Inst[4] do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
					else
						local A = Inst[2];
						local T = Stk[A];
						for Idx = A + 1, Inst[3] do
							Insert(T, Stk[Idx]);
						end
					end
				elseif (Enum <= 123) then
					if (Enum <= 121) then
						if (Enum > 120) then
							Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum == 122) then
						Stk[Inst[2]] = Env[Inst[3]];
					else
						Stk[Inst[2]] = Inst[3] ~= 0;
					end
				elseif (Enum <= 125) then
					if (Enum > 124) then
						do
							return Stk[Inst[2]];
						end
					else
						local NewProto = Proto[Inst[3]];
						local NewUvals;
						local Indexes = {};
						NewUvals = Setmetatable({}, {__index=function(_, Key)
							local Val = Indexes[Key];
							return Val[1][Val[2]];
						end,__newindex=function(_, Key, Value)
							local Val = Indexes[Key];
							Val[1][Val[2]] = Value;
						end});
						for Idx = 1, Inst[4] do
							VIP = VIP + 1;
							local Mvm = Instr[VIP];
							if (Mvm[1] == 103) then
								Indexes[Idx - 1] = {Stk,Mvm[3]};
							else
								Indexes[Idx - 1] = {Upvalues,Mvm[3]};
							end
							Lupvals[#Lupvals + 1] = Indexes;
						end
						Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
					end
				elseif (Enum == 126) then
					Stk[Inst[2]] = Inst[3];
				else
					Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!153Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E7365727403083Q00746F6E756D62657203043Q00677375622Q033Q0072657003043Q006D61746803053Q006C6465787003073Q0067657466656E76030C3Q007365746D6574617461626C6503053Q007063612Q6C03063Q0073656C65637403063Q00756E7061636B032Q082Q004C4F4C21304433513Q3033303633512Q303733373437323639364536373033303433512Q3036333638363137323033303433512Q3036323739373436353251302Q33512Q303733373536323033303533512Q303632363937343Q332Q3251302Q33512Q303632363937343033303433512Q3036323738364637323033303533512Q30373436313632364336353033303633512Q303633364636453633363137343033303633512Q303639364537333635373237343033303533512Q30364436313734363336383033303833512Q30373436463645373536443632363537323033303533512Q30373036333631325136432Q30323433512Q30312Q323633513Q303133512Q303230334235513Q30322Q30312Q32363Q30313Q303133512Q30323033423Q30313Q30313Q30332Q30312Q32363Q30323Q303133512Q30323033423Q30323Q30323Q30342Q30312Q32363Q30333Q303533513Q303631383Q30333Q30413Q30313Q30313Q3034302Q33513Q30413Q30312Q30312Q32363Q30333Q303633512Q30323033423Q30343Q30333Q30372Q30312Q32363Q30353Q303833512Q30323033423Q30353Q30353Q30392Q30312Q32363Q30363Q303833512Q30323033423Q30363Q30363Q30413Q303632343Q303733513Q30313Q303632512Q302Q3133513Q303634512Q302Q3138512Q302Q3133513Q302Q34512Q302Q3133513Q303134512Q302Q3133513Q303234512Q302Q3133513Q303533512Q30312Q32363Q30383Q303133512Q30323033423Q30383Q30383Q30422Q30312Q32363Q30393Q304333512Q30312Q32363Q30413Q304433513Q303632343Q30423Q30313Q30313Q303532512Q302Q3133513Q303734512Q302Q3133513Q303934512Q302Q3133513Q303834512Q302Q3133513Q304134512Q302Q3133513Q304236513Q30433Q304234513Q30313Q30433Q303134512Q30334Q304336512Q302Q3233513Q303133513Q303233513Q303233513Q303236512Q3046303346303236512Q303730342Q302Q323634513Q30393Q303235512Q30312Q32433Q30333Q303134512Q3031373Q303435512Q30312Q32433Q30353Q303133513Q303430443Q30332Q3032313Q303132512Q30314Q303738513Q30383Q303234512Q30314Q30393Q303134512Q30314Q30413Q303234512Q30314Q30423Q303334512Q30314Q30433Q303436513Q304438513Q30453Q303633512Q30323031453Q30463Q30363Q303132512Q3032313Q30433Q304634512Q3031343Q304233513Q302Q32512Q30314Q30433Q303334512Q30314Q30443Q303436513Q30453Q303134512Q3031373Q30463Q303134512Q3031363Q30463Q30363Q30462Q30313031423Q30463Q30313Q304632512Q3031372Q30314Q303134512Q3031362Q30314Q30362Q30313Q30313031422Q30314Q30312Q30313Q30323031452Q30313Q30314Q303132512Q3032313Q30442Q30313034512Q3032373Q304336512Q3031343Q304133513Q30322Q30323032393Q30413Q30413Q302Q32512Q3033313Q30393Q304134512Q3033383Q303733513Q30313Q3034324Q30333Q30353Q303132512Q30314Q30333Q303536513Q30343Q303234513Q30383Q30333Q302Q34512Q30334Q303336512Q302Q3233513Q303137513Q303433513Q303237512Q30342Q3033303533512Q30334132353634324233413251302Q33512Q30323536343242303236512Q30463033462Q30314333513Q3036323435513Q30313Q303132512Q30324438512Q30314Q30313Q303134512Q30314Q30323Q303234512Q30314Q30333Q303234513Q30393Q303436512Q30314Q30353Q303336513Q302Q36513Q30433Q30373Q303734512Q3032313Q30353Q303734512Q3033393Q303433513Q30312Q30323033423Q30343Q30343Q30312Q30312Q32433Q30353Q303234512Q3032413Q30333Q30353Q30322Q30312Q32433Q30343Q303334512Q3032313Q30323Q302Q34512Q3031343Q303133513Q30322Q30323632353Q30312Q3031383Q30313Q30343Q3034302Q33512Q3031383Q303134513Q303136513Q30393Q303236513Q30383Q30313Q303234512Q30334Q303135513Q3034302Q33512Q3031423Q303132512Q30314Q30313Q302Q34513Q30313Q30313Q303134512Q30334Q303136512Q302Q3233513Q303133513Q303133513Q303433513Q3033303533512Q30373037323639364537343251302Q33512Q304644454346373033303833512Q303745423141332Q423435383644424137303236512Q30463033463031304233513Q3036313233513Q30393Q303133513Q3034302Q33513Q30393Q30312Q30312Q32363Q30313Q303134512Q30314Q303235512Q30312Q32433Q30333Q303233512Q30312Q32433Q30343Q303334512Q3032313Q30323Q302Q34512Q3033383Q303133513Q30313Q3034302Q33513Q30413Q30312Q30323033423Q303133513Q303432512Q302Q3233513Q303137512Q30004A3Q00127A3Q00013Q00203B5Q000200127A000100013Q00203B00010001000300127A000200013Q00203B00020002000400127A000300053Q0006350003000A0001000100042D3Q000A000100127A000300063Q00203B00040003000700127A000500083Q00203B00050005000900127A000600083Q00203B00060006000A00067C00073Q000100062Q00673Q00064Q00678Q00673Q00044Q00673Q00014Q00673Q00024Q00673Q00053Q00127A0008000B3Q00127A000900013Q00203B00090009000300127A000A00013Q00203B000A000A000200127A000B00013Q00203B000B000B000400127A000C00013Q00203B000C000C000C00127A000D00013Q00203B000D000D000D00127A000E00083Q00203B000E000E000900127A000F00083Q00203B000F000F000A00127A0010000E3Q00203B00100010000F00127A001100103Q0006350011002B0001000100042D3Q002B0001000248001100013Q00127A001200113Q00127A001300123Q00127A001400133Q00127A001500143Q000635001500330001000100042D3Q0033000100127A001500083Q00203B00150015001400127A0016000B3Q00067C001700020001000D2Q00673Q000C4Q00673Q000B4Q00673Q00074Q00673Q00094Q00673Q00084Q00673Q000A4Q00673Q000D4Q00673Q00104Q00673Q000E4Q00673Q00144Q00673Q00154Q00673Q00124Q00673Q000F4Q006F001800173Q00127E001900154Q006F001A00114Q0045001A000100022Q002E001B6Q001100186Q005400186Q00463Q00013Q00033Q00023Q00026Q00F03F026Q00704002264Q007300025Q00127E000300014Q000700045Q00127E000500013Q0004570003002100012Q004100076Q006F000800024Q0041000900014Q0041000A00024Q0041000B00034Q0041000C00044Q006F000D6Q006F000E00063Q002071000F000600012Q0059000C000F4Q0017000B3Q00022Q0041000C00034Q0041000D00044Q006F000E00014Q0007000F00014Q0055000F0006000F00106C000F0001000F2Q0007001000014Q005500100006001000106C0010000100100020710010001000012Q0059000D00106Q000C6Q0017000A3Q0002002043000A000A00022Q003A0009000A4Q002F00073Q000100044A0003000500012Q0041000300054Q006F000400024Q0021000300044Q005400036Q00463Q00017Q00013Q0003043Q005F454E5600033Q00127A3Q00014Q007D3Q00024Q00463Q00017Q00043Q00026Q00F03F026Q00144003023Q001E0B03073Q00D330251C435ABF024A3Q00127E000300014Q0068000400044Q004100056Q0041000600014Q006F00075Q00127E000800024Q001F0006000800022Q0041000700023Q00127E000800033Q00127E000900044Q001F00070009000200067C00083Q000100062Q00163Q00034Q00673Q00044Q00163Q00044Q00163Q00014Q00163Q00054Q00163Q00064Q001F0005000800022Q006F3Q00053Q000248000500013Q00067C00060002000100032Q00163Q00034Q00678Q00673Q00033Q00067C00070003000100032Q00163Q00034Q00678Q00673Q00033Q00067C00080004000100032Q00163Q00034Q00678Q00673Q00033Q00067C00090005000100032Q00673Q00084Q00673Q00054Q00163Q00073Q00067C000A0006000100072Q00673Q00084Q00163Q00014Q00678Q00673Q00034Q00163Q00054Q00163Q00034Q00163Q00084Q006F000B00083Q00067C000C0007000100012Q00163Q00093Q00067C000D0008000100072Q00673Q00084Q00673Q00064Q00673Q00094Q00673Q000A4Q00673Q00054Q00673Q00074Q00673Q000D3Q00067C000E0009000100072Q00673Q000C4Q00163Q00094Q00163Q000A4Q00673Q000E4Q00163Q000B4Q00163Q00024Q00163Q000C4Q006F000F000E4Q006F0010000D4Q00450010000100022Q007300116Q006F001200014Q001F000F001200022Q002E00106Q0011000F6Q0054000F6Q00463Q00013Q000A3Q00063Q00027Q0040025Q00405440026Q00F03F034Q00026Q003040028Q00012D4Q004100016Q006F00025Q00127E000300014Q001F000100030002002640000100110001000200042D3Q001100012Q0041000100024Q0041000200034Q006F00035Q00127E000400033Q00127E000500034Q0059000200054Q001700013Q00022Q0063000100013Q00127E000100044Q007D000100023Q00042D3Q002C00012Q0041000100044Q0041000200024Q006F00035Q00127E000400054Q0059000200044Q001700013Q00022Q0041000200013Q00061A0002002B00013Q00042D3Q002B000100127E000200064Q0068000300033Q000E38000600260001000200042D3Q002600012Q0041000400054Q006F000500014Q0041000600014Q001F0004000600022Q006F000300044Q0068000400044Q0063000400013Q00127E000200033Q0026400002001C0001000300042D3Q001C00012Q007D000300023Q00042D3Q001C000100042D3Q002C00012Q007D000100024Q00463Q00017Q00033Q00028Q00026Q00F03F027Q004003253Q00061A0002001400013Q00042D3Q0014000100127E000300014Q0068000400043Q002640000300040001000100042D3Q000400010020320005000100020010260005000300052Q002300053Q00050020320006000200020020320007000100022Q00530006000600070020710006000600020010260006000300062Q00550004000500060020430005000400022Q00530005000400052Q007D000500023Q00042D3Q0004000100042D3Q0024000100127E000300014Q0068000400043Q002640000300160001000100042D3Q001600010020320005000100020010260004000300052Q00390005000400042Q005500053Q0005000642000400210001000500042D3Q0021000100127E000500023Q000635000500220001000100042D3Q0022000100127E000500014Q007D000500023Q00042D3Q001600012Q00463Q00017Q00013Q00026Q00F03F000A4Q00418Q0041000100014Q0041000200024Q0041000300024Q001F3Q000300022Q0041000100023Q0020710001000100012Q0063000100024Q007D3Q00024Q00463Q00017Q00023Q00027Q0040026Q007040000D4Q00418Q0041000100014Q0041000200024Q0041000300023Q0020710003000300012Q00563Q000300012Q0041000200023Q0020710002000200012Q0063000200023Q00205E0002000100022Q0039000200024Q007D000200024Q00463Q00017Q00073Q00028Q00026Q00F03F026Q007041026Q00F040026Q007040026Q000840026Q001040001D3Q00127E3Q00014Q0068000100043Q0026403Q000B0001000200042D3Q000B000100205E00050004000300205E0006000300042Q003900050005000600205E0006000200052Q00390005000500062Q00390005000500012Q007D000500023Q000E380001000200013Q00042D3Q000200012Q004100056Q0041000600014Q0041000700024Q0041000800023Q0020710008000800062Q00560005000800082Q006F000400084Q006F000300074Q006F000200064Q006F000100054Q0041000500023Q0020710005000500072Q0063000500023Q00127E3Q00023Q00042D3Q000200012Q00463Q00017Q000E3Q00028Q00026Q00F03F026Q003440026Q00F041027Q0040026Q003540026Q003F40026Q002Q40026Q00F0BF026Q000840025Q00FC9F402Q033Q004E614E025Q00F88F40026Q003043004A3Q00127E3Q00014Q0068000100063Q0026403Q000B0001000100042D3Q000B00012Q004100076Q00450007000100022Q006F000100074Q004100076Q00450007000100022Q006F000200073Q00127E3Q00023Q0026403Q00160001000200042D3Q0016000100127E000300024Q0041000700014Q006F000800023Q00127E000900023Q00127E000A00034Q001F0007000A000200205E0007000700042Q003900040007000100127E3Q00053Q0026403Q00290001000500042D3Q002900012Q0041000700014Q006F000800023Q00127E000900063Q00127E000A00074Q001F0007000A00022Q006F000500074Q0041000700014Q006F000800023Q00127E000900084Q001F000700090002002640000700270001000200042D3Q0027000100127E000700093Q000661000600280001000700042D3Q0028000100127E000600023Q00127E3Q000A3Q0026403Q00020001000A00042D3Q00020001002640000500350001000100042D3Q00350001002640000400320001000100042D3Q0032000100205E0007000600012Q007D000700023Q00042D3Q0040000100127E000500023Q00127E000300013Q00042D3Q00400001002640000500400001000B00042D3Q004000010026400004003D0001000100042D3Q003D00010030270007000200012Q00790007000600070006350007003F0001000100042D3Q003F000100127A0007000C4Q00790007000600072Q007D000700024Q0041000700024Q006F000800063Q00203200090005000D2Q001F00070009000200206D00080004000E2Q00390008000300082Q00790007000700082Q007D000700023Q00042D3Q000200012Q00463Q00017Q00033Q00028Q00034Q00026Q00F03F01293Q0006353Q00090001000100042D3Q000900012Q004100026Q00450002000100022Q006F3Q00023Q0026403Q00090001000100042D3Q0009000100127E000200024Q007D000200024Q0041000200014Q0041000300024Q0041000400034Q0041000500034Q0039000500053Q0020320005000500032Q001F0002000500022Q006F000100024Q0041000200034Q0039000200024Q0063000200034Q007300025Q00127E000300034Q0007000400013Q00127E000500033Q0004570003002400012Q0041000700044Q0041000800054Q0041000900014Q006F000A00014Q006F000B00064Q006F000C00064Q00590009000C6Q00086Q001700073Q00022Q001800020006000700044A0003001900012Q0041000300064Q006F000400024Q0021000300044Q005400036Q00463Q00017Q00013Q0003013Q002300094Q007300016Q002E00026Q006200013Q00012Q004100025Q00127E000300014Q002E00048Q00026Q005400016Q00463Q00017Q00073Q00026Q00F03F028Q00027Q0040026Q000840026Q001040026Q00F040026Q00184000B24Q00738Q007300016Q007300026Q0073000300044Q006F00046Q006F000500014Q0068000600064Q006F000700024Q00100003000400012Q004100046Q00450004000100022Q007300055Q00127E000600014Q006F000700043Q00127E000800013Q0004570006002900012Q0041000A00014Q0045000A000100022Q0068000B000B3Q002640000A001C0001000100042D3Q001C00012Q0041000C00014Q0045000C00010002002640000C001A0001000200042D3Q001A00012Q006B000B6Q007B000B00013Q00042D3Q00270001002640000A00220001000300042D3Q002200012Q0041000C00024Q0045000C000100022Q006F000B000C3Q00042D3Q00270001002640000A00270001000400042D3Q002700012Q0041000C00034Q0045000C000100022Q006F000B000C4Q001800050009000B00044A0006001000012Q0041000600014Q004500060001000200105A00030004000600127E000600014Q004100076Q004500070001000200127E000800013Q000457000600A600012Q0041000A00014Q0045000A000100022Q0041000B00044Q006F000C000A3Q00127E000D00013Q00127E000E00014Q001F000B000E0002002640000B00A50001000200042D3Q00A5000100127E000B00024Q0068000C000E3Q002640000B004A0001000400042D3Q004A00012Q0041000F00044Q006F0010000D3Q00127E001100043Q00127E001200044Q001F000F00120002002640000F00480001000100042D3Q0048000100203B000F000E00052Q007F000F0005000F00105A000E0005000F2Q00183Q0009000E00042D3Q00A50001002640000B007E0001000100042D3Q007E00012Q0073000F00044Q0041001000054Q00450010000100022Q0041001100054Q00450011000100022Q0068001200134Q0010000F000400012Q006F000E000F3Q002640000C00620001000200042D3Q0062000100127E000F00023Q002640000F00570001000200042D3Q005700012Q0041001000054Q004500100001000200105A000E000400102Q0041001000054Q004500100001000200105A000E0005001000042D3Q007D000100042D3Q0057000100042D3Q007D0001002640000C00680001000100042D3Q006800012Q0041000F6Q0045000F0001000200105A000E0004000F00042D3Q007D0001002640000C006F0001000300042D3Q006F00012Q0041000F6Q0045000F00010002002032000F000F000600105A000E0004000F00042D3Q007D0001002640000C007D0001000400042D3Q007D000100127E000F00023Q002640000F00720001000200042D3Q007200012Q004100106Q004500100001000200203200100010000600105A000E000400102Q0041001000054Q004500100001000200105A000E0005001000042D3Q007D000100042D3Q0072000100127E000B00033Q000E38000300950001000B00042D3Q009500012Q0041000F00044Q006F0010000D3Q00127E001100013Q00127E001200014Q001F000F00120002002640000F008A0001000100042D3Q008A000100203B000F000E00032Q007F000F0005000F00105A000E0003000F2Q0041000F00044Q006F0010000D3Q00127E001100033Q00127E001200034Q001F000F00120002002640000F00940001000100042D3Q0094000100203B000F000E00042Q007F000F0005000F00105A000E0004000F00127E000B00043Q000E380002003C0001000B00042D3Q003C00012Q0041000F00044Q006F0010000A3Q00127E001100033Q00127E001200044Q001F000F001200022Q006F000C000F4Q0041000F00044Q006F0010000A3Q00127E001100053Q00127E001200074Q001F000F001200022Q006F000D000F3Q00127E000B00013Q00042D3Q003C000100044A00060031000100127E000600014Q004100076Q004500070001000200127E000800013Q000457000600B00001002032000A000900012Q0041000B00064Q0045000B000100022Q00180001000A000B00044A000600AB00012Q007D000300024Q00463Q00017Q00033Q00026Q00F03F027Q0040026Q00084003123Q00203B00033Q000100203B00043Q000200203B00053Q000300067C00063Q0001000C2Q00673Q00034Q00673Q00044Q00673Q00054Q00168Q00163Q00014Q00163Q00024Q00673Q00014Q00163Q00034Q00673Q00024Q00163Q00044Q00163Q00054Q00163Q00064Q007D000600024Q00463Q00013Q00013Q00463Q00026Q00F03F026Q00F0BF03013Q0023028Q00026Q003D40026Q002C40026Q001840027Q0040026Q000840026Q001040026Q001440026Q002440026Q002040026Q001C40026Q002240026Q002840026Q00264000026Q002A40026Q003540026Q003140026Q002E40026Q003040026Q003340026Q00324003073Q0023761E7683F10403063Q00947C297718E7030A3Q002EBD23A0C0188C29A0CF03053Q00B771E24DC5026Q003440026Q003940026Q003740026Q003640026Q003840026Q003B40026Q003A40026Q003C40026Q004640026Q004240026Q002Q40026Q003E40026Q003F40026Q004140025Q00802Q40025Q0080414003073Q007F66BCD2445CAD03043Q00BC2039D5030A3Q00CB3F435E01FD0E495E0E03053Q007694602D3B026Q004440026Q004340025Q00804240025Q00804340026Q004540025Q00804440025Q00804540025Q00804940025Q00804740025Q00804640026Q004740025Q00804840026Q004840026Q004940025Q00804B40025Q00804A40026Q004A40026Q004B40025Q00804C40026Q004C40026Q004D40002Q043Q004100016Q0041000200014Q0041000300024Q0041000400033Q00127E000500013Q00127E000600024Q007300076Q007300086Q002E00096Q006200083Q00012Q0041000900043Q00127E000A00034Q002E000B6Q001700093Q00020020320009000900012Q0073000A6Q0073000B5Q00127E000C00044Q006F000D00093Q00127E000E00013Q000457000C002000010006420003001C0001000F00042D3Q001C00012Q00530010000F00030020710011000F00012Q007F0011000800112Q001800070010001100042D3Q001F00010020710010000F00012Q007F0010000800102Q0018000B000F001000044A000C001500012Q0053000C00090003002071000C000C00012Q0068000D000E3Q00127E000F00043Q002640000F00290001000400042D3Q002900012Q007F000D0001000500203B000E000D000100127E000F00013Q002640000F00240001000100042D3Q0024000100261D000E00D62Q01000500042D3Q00D62Q0100261D000E00DE0001000600042D3Q00DE000100261D000E00850001000700042D3Q0085000100261D000E004B0001000800042D3Q004B000100261D000E003A0001000400042D3Q003A000100203B0010000D000800203B0011000D00092Q007F0011000B00112Q0018000B0010001100042D3Q00FF0301000E3F000100460001000E00042D3Q0046000100203B0010000D00082Q007F0011000B00102Q0041001200054Q006F0013000B3Q0020710014001000012Q006F001500064Q0059001200154Q001700113Q00022Q0018000B0010001100042D3Q00FF030100203B0010000D00082Q007F0010000B00102Q0036001000014Q005400105Q00042D3Q00FF030100261D000E00580001000A00042D3Q00580001000E3F000900560001000E00042D3Q0056000100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q007F0011001100122Q0018000B0010001100042D3Q00FF030100203B0005000D000900042D3Q00FF0301002640000E007B0001000B00042D3Q007B000100127E001000044Q0068001100133Q002640001000740001000100042D3Q007400010020710014001100082Q007F0013000B0014000E3F0004006B0001001300042D3Q006B00010020710014001100012Q007F0014000B0014000630001400680001001200042D3Q0068000100203B0005000D000900042D3Q00FF03010020710014001100092Q0018000B0014001200042D3Q00FF03010020710014001100012Q007F0014000B0014000630001200710001001400042D3Q0071000100203B0005000D000900042D3Q00FF03010020710014001100092Q0018000B0014001200042D3Q00FF0301000E380004005C0001001000042D3Q005C000100203B0011000D00082Q007F0012000B001100127E001000013Q00042D3Q005C000100042D3Q00FF030100203B0010000D00082Q007F0011000B00102Q0041001200054Q006F0013000B3Q00207100140010000100203B0015000D00092Q0059001200154Q001100116Q005400115Q00042D3Q00FF030100261D000E00A90001000C00042D3Q00A9000100261D000E009B0001000D00042D3Q009B0001000E3F000E00950001000E00042D3Q0095000100203B0010000D00082Q007F0011000B00102Q0041001200054Q006F0013000B3Q00207100140010000100203B0015000D00092Q0059001200154Q001100116Q005400115Q00042D3Q00FF030100203B0010000D000800203B0011000D00092Q007F0011000B00112Q0007001100114Q0018000B0010001100042D3Q00FF0301002640000E00A10001000F00042D3Q00A1000100203B0010000D00082Q007300116Q0018000B0010001100042D3Q00FF030100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q007F0012000B00122Q00550011001100122Q0018000B0010001100042D3Q00FF030100261D000E00B90001001000042D3Q00B90001002640000E00B20001001100042D3Q00B2000100203B0010000D00082Q007F0010000B00102Q0036001000014Q005400105Q00042D3Q00FF030100203B0010000D000800203B0011000D000900127E001200013Q000457001000B80001002012000B0013001200044A001000B6000100042D3Q00FF0301002640000E00DC0001001300042D3Q00DC000100127E001000044Q0068001100133Q002640001000D50001000100042D3Q00D500010020710014001100082Q007F0013000B0014000E3F000400CC0001001300042D3Q00CC00010020710014001100012Q007F0014000B0014000630001400C90001001200042D3Q00C9000100203B0005000D000900042D3Q00FF03010020710014001100092Q0018000B0014001200042D3Q00FF03010020710014001100012Q007F0014000B0014000630001200D20001001400042D3Q00D2000100203B0005000D000900042D3Q00FF03010020710014001100092Q0018000B0014001200042D3Q00FF0301002640001000BD0001000400042D3Q00BD000100203B0011000D00082Q007F0012000B001100127E001000013Q00042D3Q00BD000100042D3Q00FF03012Q00463Q00013Q00042D3Q00FF030100261D000E00872Q01001400042D3Q00872Q0100261D000E001A2Q01001500042D3Q001A2Q0100261D000E000D2Q01001600042D3Q000D2Q0100127E001000044Q0068001100133Q000E38000400EC0001001000042D3Q00EC000100203B0011000D00080020710014001100082Q007F0012000B001400127E001000013Q002640001000052Q01000800042D3Q00052Q01000E3F000400F80001001200042D3Q00F800010020710014001100012Q007F0014000B0014000642001300FF0301001400042D3Q00FF030100203B0005000D00090020710014001100092Q0018000B0014001300042D3Q00FF03010020710014001100012Q007F0014000B0014000642001400FF0301001300042D3Q00FF030100127E001400043Q000E38000400FD0001001400042D3Q00FD000100203B0005000D00090020710015001100092Q0018000B0015001300042D3Q00FF030100042D3Q00FD000100042D3Q00FF0301000E38000100E60001001000042D3Q00E600012Q007F0014000B00112Q00390013001400122Q0018000B0011001300127E001000083Q00042D3Q00E6000100042D3Q00FF0301000E3F001700142Q01000E00042D3Q00142Q0100203B0010000D000800203B0011000D00092Q007F0011000B00112Q0018000B0010001100042D3Q00FF030100203B0010000D00082Q0041001100063Q00203B0012000D00092Q007F0011001100122Q0018000B0010001100042D3Q00FF030100261D000E006D2Q01001800042D3Q006D2Q01002640000E00262Q01001900042D3Q00262Q0100203B0010000D00082Q007F0010000B001000061A001000242Q013Q00042D3Q00242Q0100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF030100127E001000044Q0068001100133Q0026400010002E2Q01000400042D3Q002E2Q0100203B0014000D00092Q007F0011000200142Q0068001200123Q00127E001000013Q002640001000522Q01000800042D3Q00522Q0100127E001400013Q00203B0015000D000A00127E001600013Q0004570014004A2Q010020710005000500012Q007F00180001000500203B001900180001002640001900402Q01001500042D3Q00402Q010020320019001700012Q0073001A00024Q006F001B000B3Q00203B001C001800092Q0010001A000200012Q001800130019001A00042D3Q00462Q010020320019001700012Q0073001A00024Q0041001B00063Q00203B001C001800092Q0010001A000200012Q001800130019001A2Q00070019000A3Q0020710019001900012Q0018000A0019001300044A001400342Q0100203B0014000D00082Q0041001500074Q006F001600114Q006F001700124Q0041001800084Q001F0015001800022Q0018000B0014001500042D3Q006B2Q01002640001000282Q01000100042D3Q00282Q012Q007300146Q006F001300144Q0041001400094Q007300156Q007300163Q00022Q00410017000A3Q00127E0018001A3Q00127E0019001B4Q001F00170019000200067C00183Q000100012Q00673Q00134Q00180016001700182Q00410017000A3Q00127E0018001C3Q00127E0019001D4Q001F00170019000200067C00180001000100012Q00673Q00134Q00180016001700182Q001F0014001600022Q006F001200143Q00127E001000083Q00042D3Q00282Q012Q004C00105Q00042D3Q00FF0301000E3F001E00772Q01000E00042D3Q00772Q0100203B0010000D00082Q0041001100054Q006F0012000B4Q006F001300104Q006F001400064Q0021001100144Q005400115Q00042D3Q00FF030100127E001000044Q0068001100113Q002640001000792Q01000400042D3Q00792Q0100203B0011000D00082Q007F0012000B00112Q0041001300054Q006F0014000B3Q0020710015001100012Q006F001600064Q0059001300164Q001700123Q00022Q0018000B0011001200042D3Q00FF030100042D3Q00792Q0100042D3Q00FF030100261D000E00AD2Q01001F00042D3Q00AD2Q0100261D000E009B2Q01002000042D3Q009B2Q01002640000E00952Q01002100042D3Q00952Q0100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q007F0012000B00122Q00550011001100122Q0018000B0010001100042D3Q00FF030100203B0010000D000800203B0011000D00092Q007F0011000B00112Q0007001100114Q0018000B0010001100042D3Q00FF0301000E3F002200A52Q01000E00042D3Q00A52Q0100203B0010000D00082Q007F0010000B0010000635001000A32Q01000100042D3Q00A32Q0100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF030100203B0010000D00082Q007F0010000B0010000635001000AB2Q01000100042D3Q00AB2Q0100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF030100261D000E00BA2Q01002300042D3Q00BA2Q01000E3F002400B82Q01000E00042D3Q00B82Q0100203B0010000D000800203B0011000D000900203B0012000D000A2Q007F0012000B00122Q00390011001100122Q0018000B0010001100042D3Q00FF030100203B0005000D000900042D3Q00FF0301002640000E00C02Q01002500042D3Q00C02Q0100203B0010000D000800203B0011000D00092Q0018000B0010001100042D3Q00FF030100203B0010000D00082Q006F001100044Q007F0012000B00102Q0041001300054Q006F0014000B3Q00207100150010000100203B0016000D00092Q0059001300166Q00126Q007600113Q00122Q003900130012001000203200060013000100127E001300044Q006F001400104Q006F001500063Q00127E001600013Q000457001400D52Q010020710013001300012Q007F0018001100132Q0018000B0017001800044A001400D12Q0100042D3Q00FF030100261D000E00F40201002600042D3Q00F4020100261D000E00860201002700042D3Q0086020100261D000E00170201002800042D3Q0017020100261D000E00E52Q01002900042D3Q00E52Q0100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q00390011001100122Q0018000B0010001100042D3Q00FF0301002640000E00EE2Q01002A00042D3Q00EE2Q0100203B0010000D000800203B0011000D000900127E001200013Q000457001000ED2Q01002012000B0013001200044A001000EB2Q0100042D3Q00FF030100127E001000044Q0068001100133Q002640001000F62Q01000400042D3Q00F62Q0100203B0011000D00080020710014001100082Q007F0012000B001400127E001000013Q0026400010000F0201000800042D3Q000F0201000E3F000400070201001200042D3Q000702010020710014001100012Q007F0014000B0014000642001300FF0301001400042D3Q00FF030100127E001400043Q002640001400FF2Q01000400042D3Q00FF2Q0100203B0005000D00090020710015001100092Q0018000B0015001300042D3Q00FF030100042D3Q00FF2Q0100042D3Q00FF03010020710014001100012Q007F0014000B0014000642001400FF0301001300042D3Q00FF030100203B0005000D00090020710014001100092Q0018000B0014001300042D3Q00FF0301002640001000F02Q01000100042D3Q00F02Q012Q007F0014000B00112Q00390013001400122Q0018000B0011001300127E001000083Q00042D3Q00F02Q0100042D3Q00FF030100261D000E00330201002B00042D3Q00330201002640000E00310201002C00042D3Q0031020100203B0010000D00082Q006F001100044Q007F0012000B00102Q0041001300054Q006F0014000B3Q00207100150010000100203B0016000D00092Q0059001300166Q00126Q007600113Q00122Q003900130012001000203200060013000100127E001300044Q006F001400104Q006F001500063Q00127E001600013Q0004570014003002010020710013001300012Q007F0018001100132Q0018000B0017001800044A0014002C020100042D3Q00FF03012Q00463Q00013Q00042D3Q00FF0301002640000E003E0201002D00042D3Q003E020100203B0010000D00082Q007F0011000B00102Q0041001200054Q006F0013000B3Q0020710014001000012Q006F001500064Q0059001200154Q002F00113Q000100042D3Q00FF030100127E001000044Q0068001100133Q002640001000460201000400042D3Q0046020100203B0014000D00092Q007F0011000200142Q0068001200123Q00127E001000013Q0026400010006B0201000800042D3Q006B020100127E001400013Q00203B0015000D000A00127E001600013Q0004570014006302010020710018000500010020710005001800042Q007F00180001000500203B001900180001002640001900590201001500042D3Q005902010020320019001700012Q0073001A00024Q006F001B000B3Q00203B001C001800092Q0010001A000200012Q001800130019001A00042D3Q005F02010020320019001700012Q0073001A00024Q0041001B00063Q00203B001C001800092Q0010001A000200012Q001800130019001A2Q00070019000A3Q0020710019001900012Q0018000A0019001300044A0014004C020100203B0014000D00082Q0041001500074Q006F001600114Q006F001700124Q0041001800084Q001F0015001800022Q0018000B0014001500042D3Q00840201002640001000400201000100042D3Q004002012Q007300146Q006F001300144Q0041001400094Q007300156Q007300163Q00022Q00410017000A3Q00127E0018002E3Q00127E0019002F4Q001F00170019000200067C00180002000100012Q00673Q00134Q00180016001700182Q00410017000A3Q00127E001800303Q00127E001900314Q001F00170019000200067C00180003000100012Q00673Q00134Q00180016001700182Q001F0014001600022Q006F001200143Q00127E001000083Q00042D3Q004002012Q004C00105Q00042D3Q00FF030100261D000E00CC0201003200042D3Q00CC020100261D000E009B0201003300042D3Q009B0201000E3F003400920201000E00042D3Q0092020100203B0010000D00082Q0041001100083Q00203B0012000D00092Q007F0011001100122Q0018000B0010001100042D3Q00FF030100203B0010000D00082Q007F0010000B001000203B0011000D000A000609001000990201001100042D3Q0099020100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF0301002640000E00C60201003500042D3Q00C6020100127E001000044Q0068001100143Q000E38000800AF0201001000042D3Q00AF02012Q006F001500114Q006F001600063Q00127E001700013Q000457001500AE020100127E001900043Q002640001900A60201000400042D3Q00A602010020710014001400012Q007F001A001200142Q0018000B0018001A00042D3Q00AD020100042D3Q00A6020100044A001500A5020100042D3Q00FF0301000E38000100B50201001000042D3Q00B502012Q003900150013001100203200060015000100127E001400043Q00127E001000083Q0026400010009F0201000400042D3Q009F020100203B0011000D00082Q006F001500044Q007F0016000B00112Q0041001700054Q006F0018000B3Q0020710019001100012Q006F001A00064Q00590017001A6Q00166Q007600153Q00162Q006F001300164Q006F001200153Q00127E001000013Q00042D3Q009F020100042D3Q00FF030100203B0010000D00082Q0041001100083Q00203B0012000D00092Q007F0011001100122Q0018000B0010001100042D3Q00FF030100261D000E00E70201003600042D3Q00E70201002640000E00D70201003700042D3Q00D7020100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q00550011001100122Q0018000B0010001100042D3Q00FF030100127E001000044Q0068001100113Q002640001000D90201000400042D3Q00D9020100203B0011000D00082Q007F0012000B00112Q0041001300054Q006F0014000B3Q00207100150011000100203B0016000D00092Q0059001300164Q001700123Q00022Q0018000B0011001200042D3Q00FF030100042D3Q00D9020100042D3Q00FF0301000E3F003800ED0201000E00042D3Q00ED020100203B0010000D000800203B0011000D00092Q0018000B0010001100042D3Q00FF030100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q00390011001100122Q0018000B0010001100042D3Q00FF030100261D000E00850301003900042D3Q0085030100261D000E00370301003A00042D3Q0037030100261D000E2Q000301003B00042D4Q00030100203B0010000D00082Q0041001100063Q00203B0012000D00092Q007F0011001100122Q0018000B0010001100042D3Q00FF0301002640000E000E0301003C00042D3Q000E030100203B0010000D00082Q007F0011000B00100020710012001000012Q006F001300063Q00127E001400013Q0004570012000D03012Q00410016000B4Q006F001700114Q007F0018000B00152Q006000160018000100044A00120008030100042D3Q00FF030100127E001000044Q0068001100143Q002640001000160301000100042D3Q001603012Q003900150013001100203200060015000100127E001400043Q00127E001000083Q002640001000250301000400042D3Q0025030100203B0011000D00082Q006F001500044Q007F0016000B00112Q0041001700054Q006F0018000B3Q0020710019001100012Q006F001A00064Q00590017001A6Q00166Q007600153Q00162Q006F001300164Q006F001200153Q00127E001000013Q002640001000100301000800042D3Q001003012Q006F001500114Q006F001600063Q00127E001700013Q00045700150034030100127E001900043Q000E380004002C0301001900042D3Q002C03010020710014001400012Q007F001A001200142Q0018000B0018001A00042D3Q0033030100042D3Q002C030100044A0015002B030100042D3Q00FF030100042D3Q0010030100042D3Q00FF030100261D000E006B0301003D00042D3Q006B0301000E3F003E005D0301000E00042D3Q005D030100127E001000044Q0068001100143Q002640001000490301000400042D3Q0049030100203B0011000D00082Q006F001500044Q007F0016000B00110020710017001100012Q007F0017000B00172Q003A001600174Q007600153Q00162Q006F001300164Q006F001200153Q00127E001000013Q002640001000550301000800042D3Q005503012Q006F001500114Q006F001600063Q00127E001700013Q0004570015005403010020710019001400010020710014001900042Q007F0019001200142Q0018000B0018001900044A0015004F030100042D3Q00FF03010026400010003D0301000100042D3Q003D03012Q003900150013001100203200060015000100127E001400043Q00127E001000083Q00042D3Q003D030100042D3Q00FF030100127E001000044Q0068001100113Q0026400010005F0301000400042D3Q005F030100203B0011000D00082Q0041001200054Q006F0013000B4Q006F001400114Q006F001500064Q0021001200154Q005400125Q00042D3Q00FF030100042D3Q005F030100042D3Q00FF0301002640000E007D0301003F00042D3Q007D030100127E001000044Q0068001100113Q0026400010006F0301000400042D3Q006F030100203B0011000D00082Q007F0012000B00112Q0041001300054Q006F0014000B3Q00207100150011000100203B0016000D00092Q0059001300164Q001700123Q00022Q0018000B0011001200042D3Q00FF030100042D3Q006F030100042D3Q00FF030100203B0010000D00082Q007F0010000B001000061A0010008303013Q00042D3Q0083030100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF030100261D000E00CB0301004000042D3Q00CB030100261D000E00B90301004100042D3Q00B90301000E3F004200B20301000E00042D3Q00B2030100127E001000044Q0068001100143Q0026400010009D0301000800042D3Q009D03012Q006F001500114Q006F001600063Q00127E001700013Q0004570015009C030100127E001900043Q002640001900940301000400042D3Q009403010020710014001400012Q007F001A001200142Q0018000B0018001A00042D3Q009B030100042D3Q0094030100044A00150093030100042D3Q00FF0301002640001000AA0301000400042D3Q00AA030100203B0011000D00082Q006F001500044Q007F0016000B00110020710017001100010020710017001700042Q007F0017000B00172Q003A001600174Q007600153Q00162Q006F001300164Q006F001200153Q00127E001000013Q0026400010008D0301000100042D3Q008D03012Q003900150013001100203200060015000100127E001400043Q00127E001000083Q00042D3Q008D030100042D3Q00FF030100203B0010000D000800203B0011000D000900203B0012000D000A2Q007F0012000B00122Q00390011001100122Q0018000B0010001100042D3Q00FF0301000E3F004300C40301000E00042D3Q00C4030100203B0010000D00082Q007F0010000B001000203B0011000D000A000609001000C20301001100042D3Q00C2030100207100050005000100042D3Q00FF030100203B0005000D000900042D3Q00FF030100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q00550011001100122Q0018000B0010001100042D3Q00FF030100261D000E00F30301004400042D3Q00F30301002640000E00DE0301004500042D3Q00DE030100127E001000044Q0068001100113Q002640001000D10301000400042D3Q00D1030100203B0011000D00082Q007F0012000B00112Q0041001300054Q006F0014000B3Q0020710015001100012Q006F001600064Q0059001300164Q002F00123Q000100042D3Q00FF030100042D3Q00D1030100042D3Q00FF030100127E001000044Q0068001100123Q002640001000EC0301000100042D3Q00EC03010020710013001100012Q006F001400063Q00127E001500013Q000457001300EB03012Q00410017000B4Q006F001800124Q007F0019000B00162Q006000170019000100044A001300E6030100042D3Q00FF0301002640001000E00301000400042D3Q00E0030100203B0011000D00082Q007F0012000B001100127E001000013Q00042D3Q00E0030100042D3Q00FF0301000E3F004600FC0301000E00042D3Q00FC030100203B0010000D000800203B0011000D00092Q007F0011000B001100203B0012000D000A2Q007F0011001100122Q0018000B0010001100042D3Q00FF030100203B0010000D00082Q007300116Q0018000B0010001100207100050005000100042D3Q0023000100042D3Q0024000100042D3Q002300012Q00463Q00013Q00043Q00023Q00026Q00F03F027Q004002074Q004100026Q007F00020002000100203B00030002000100203B0004000200022Q007F0003000300042Q007D000300024Q00463Q00017Q00033Q00028Q00026Q00F03F027Q0040030C3Q00127E000300014Q0068000400043Q000E38000100020001000300042D3Q000200012Q004100056Q007F00040005000100203B00050004000200203B0006000400032Q001800050006000200042D3Q000B000100042D3Q000200012Q00463Q00017Q00033Q00028Q00026Q00F03F027Q0040020C3Q00127E000200014Q0068000300033Q000E38000100020001000200042D3Q000200012Q004100046Q007F00030004000100203B00040003000200203B0005000300032Q007F0004000400052Q007D000400023Q00042D3Q000200012Q00463Q00017Q00023Q00026Q00F03F027Q004003064Q004100036Q007F00030003000100203B00040003000100203B0005000300022Q00180004000500022Q00463Q00017Q00", GetFEnv(), ...);
