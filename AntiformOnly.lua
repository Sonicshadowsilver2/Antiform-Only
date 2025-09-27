local GameVersion = 0
local canExecute = false

function _OnInit()
  GameVersion = 0
end

function GetVersion() --Define anchor addresses
  if GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
    if ReadString(0x09A92F0,4) == 'KH2J' then --EGS v1.0.0.9
			GameVersion = 2
			print('EGS v1.0.0.9 Detected - AntiformOnly')
			Now  = 0x0716DF8
			Save = 0x09A92F0
			Drive = 0x2A23188
			UCM = 0x2A71998
			Obj0 = 0x2A24A70
			canExecute = true
		elseif ReadString(0x09A9330,4) == 'KH2J' then --EGS v1.0.0.10
			GameVersion = 3
			print('EGS v1.0.0.10 Detected - AntiformOnly')
			Now  = 0x0716DF8
			Save = 0x09A9330
			Drive = 0x2A231C8
			UCM = 0x2A719D8
			Obj0 = 0x2A24AB0
			canExecute = true
		elseif ReadString(0x09A9830,4) == 'KH2J' then --Steam Global v1.0.0.1
			GameVersion = 4
			print('Steam GL v1.0.0.1 Detected - AntiformOnly')
			Now  = 0x0717008
			Save = 0x09A9830
			Drive = 0x2A236C8
			UCM = 0x2A71ED8
			Obj0 = 0x2A24FB0
			canExecute = true
		elseif ReadString(0x09A8830,4) == 'KH2J' then --Steam JP v1.0.0.1
			GameVersion = 5
			print('Steam JP v1.0.0.1 Detected - AntiformOnly')
			Now  = 0x0716008
			Save = 0x09A8830
			Drive = 0x2A226C8
			UCM = 0x2A70ED8
			Obj0 = 0x2A23FB0
			canExecute = true
		elseif ReadString(0x09A98B0,4) == 'KH2J' then --Steam v1.0.0.2
			GameVersion = 6
			print('Steam v1.0.0.2 Detected - AntiformOnly')
			Now  = 0x0717008
			Save = 0x09A98B0
			Drive = 0x2A23748
			UCM = 0x2A71F58
			Obj0 = 0x2A25030
			canExecute = true
		end
	end
end

function _OnFrame()
	if GameVersion == 0 then --Get anchor addresses
		GetVersion()
		return
	end
	
	if canExecute == true then
		if ReadShort(Now+0x00) == 0x0102 and ReadByte(Now+0x08) == 0x34 then --New Game
			WriteByte(Save+0x1CD9, 0x02) --Enable Square Button actions
			WriteByte(Save+0x1CE5, 0x04) --Show Form Gauge
			WriteInt(Save+0x32F4, 0x00000047) --Antiform Keyblade & Valor LV0
			WriteShort(Save+0x32FC, 0x0000) --Remove High Jump
		end
		if ReadByte(Now+0x00) == 0x02 then --Twilight Town
			if ReadByte(Now+0x08) == 0x9D or ReadByte(Now+0x08) == 0x78 or ReadByte(Now+0x08) == 0x7D then
				WriteShort(UCM+0x009C, 0x005A) --Antiform -> Roxas
			else
				WriteShort(UCM+0x009C, 0x0059) --Roxas -> Antiform
			end
			if ReadByte(Now+0x01) == 0x1C and ReadByte(Now+0x08) == 0x01 and ReadByte(Save+0x1CE5) == 0x05 then
				WriteByte(Save+0x1CE5, 0x01)
			end
		end
		if ReadByte(Now+0x00) == 0x0A then --Pride Lands
			if ReadByte(Now+0x01) == 0x0F then --Groundshaker
				WriteShort(UCM+0x06E8, 0x028A) --Antiform -> Lion Sora
			else
				WriteShort(UCM+0x06E8, 0x0059) --Lion Sora -> Antiform
			end
		end
		if ReadShort(Now+0x00) == 0x0E12 then --Luxord
			if ReadByte(Now+0x08) == 0x3A or ReadByte(Now+0x08) == 0x65 then
				if ReadByte(Save+0x3524) == 0x00 then
					WriteByte(Save+0x3524, 0x06) --Remain in Antiform
				end
				if ReadInt(Drive+0x04) < 0x44160002 and ReadInt(Drive+0x08) > 0x44960000 then
					WriteInt(Drive+0x04, 0x45160000)
				end
			end
		end
		if ReadByte(UCM+0x00) == 0x54 then
			WriteShort(UCM+0x0000, 0x0059) --Sora (Normal) -> Antiform
			WriteShort(UCM+0x00D0, 0x0059) --Roxas (Dual-Wielded) -> Antiform
			WriteShort(UCM+0x0104, 0x0059) --Sora (KH1 Costume) -> Antiform
			WriteShort(UCM+0x0444, 0x03EA) --Sora (Halloween Town) -> Antiform (Halloween Town)
			WriteShort(UCM+0x0478, 0x095A) --Sora (Christmas Town) -> Antiform (Christmas Town)
			WriteShort(UCM+0x0680, 0x0671) --Sora (Space Paranoids) -> Antiform (Space Paranoids)
			WriteShort(UCM+0x06B4, 0x0672) --Sora (Timeless River) -> Antiform (Timeless River)
			WriteString(Obj0+0x12690,'P_EX100_HTLF\0\0\0\0\0') --Sora (On Carpet) Model -> Antiform Model
			WriteString(Obj0+0x154D0,'F_TT010_SORA.mset\0') --Skateboard (Roxas) MSET -> Skateboard (Sora) MSET
			WriteShort(Obj0+0x25B28,0x0000) --Remove Small Chests (Twilight Town)
		end
	end
end