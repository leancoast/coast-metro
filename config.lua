
biletucret				= 25		-- Change to any value YOU think is suitable for a Metro Ticket in your (RP) Server

local metroyakinkontrol = false
local oyuncumetroicindemi = false
local biletkontrol = false
local makinekullanmaevent = false

-- if you can find the model name for the other ticket machines to make them all work, let me know
local biletmakine = {'prop_train_ticket_02', 'prop_train_ticket_02_tu', 'v_serv_tu_statio3_'}
local anim = "mini@atmenter"

local metroistasyonlari = {
	-- Example {title="", colour=, id=, x=, y=, z=},
	{title="METRO: LS Terminal 4", colour=1, id=78, x=-1088.627, y=-2709.362, z=-7.137033},
	{title="METRO: LS Park", colour=1, id=78, x=-889.2755, y=-2311.825, z=-11.45941},
	{title="METRO: Little Seoul", colour=1, id=78, x=-545.3138, y=-1280.548, z=27.09238},
	{title="METRO: Strawberry", colour=1, id=78, x=270.2029, y=-1210.818, z=39.25398},
	{title="METRO: Burton", colour=1, id=78, x=-286.3837, y=-318.877, z=10.33625},
	{title="METRO: Portola Drive", colour=1, id=78, x=-826.3845, y=-134.7151, z=20.22362},
	{title="METRO: Del Perro", colour=1, id=78, x=-1351.282, y=-481.2916, z=15.318},
	{title="METRO: Little Seoul", colour=1, id=78, x=-496.0209, y=-681.0325, z=12.08264},
	{title="METRO: Pillbox South", colour=1, id=78, x=-218.2868, y=-1031.54, z=30.51112},
	{title="METRO: Davis", colour=1, id=78, x=112.3714, y=-1729.233, z=30.24097},
}

Citizen.CreateThread(function()
	
	for _, info in pairs(metroistasyonlari) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.7)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end

	alinmisbiletyardim = false
	metrodanindikontrol = false
	tickettarih = false
	while true do
		Wait(10)

		if yakindakimakinekontrol then
			if (not makinekullanmaevent and not biletkontrol) then
				if not alinmisbiletyardim then
					DisplayHelpText("Metro bileti satın almak için ~INPUT_CONTEXT~ ".." ($" .. biletucret .. ")")
					alinmisbiletyardim = true
				end
			else
				if not alinmisbiletyardim then
					DisplayHelpText("Zaten bir biletiniz var, metronun gelmesini bekleyin.")
					alinmisbiletyardim = true
				end
				ClearAllHelpMessages()
				DisableControlAction(0, 201, true)
				DisableControlAction(1, 201, true)
			end

			if IsControlJustPressed(0, 51) and biletkontrol then
				SMS_Message("CHAR_LS_TOURIST_BOARD", "Los Santos Ulaşım", "Bilgilendirme", "Zaten geçerli bir Metro Biletiniz var, lütfen istasyonlardan birine gidin ve Metroya binin.", true)
				Wait(3500) -- To avoid people 'spamming themselves' with the message popup (3500ms is 'just enough' to take the fun out of it :P)
			end

			if IsControlJustPressed(0, 51) and not biletkontrol then
				makinekullanmaevent = true
				RequestAnimDict("mini@atmbase")
				RequestAnimDict(anim)
				while not HasAnimDictLoaded(anim) do
					Wait(1)
				end

				SetCurrentPedWeapon(playerPed, GetHashKey("weapon_unarmed"), true)
				TaskLookAtEntity(playerPed, mevcutmakine, 2000, 2048, 2)
				Wait(500)
				TaskGoStraightToCoord(playerPed, biletX, biletY, biletZ, 0.1, 4000, GetEntityHeading(mevcutmakine), 0.5)
				Wait(2000)
				TaskPlayAnim(playerPed, anim, "enter", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
				RemoveAnimDict(animDict)
				Wait(4000)
				TaskPlayAnim(playerPed, "mini@atmbase", "base", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
				RemoveAnimDict("mini@atmbase")
				Wait(500)
				PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				RequestAnimDict("mini@atmexit")
				while not HasAnimDictLoaded("mini@atmexit") do
					Wait(1)
				end
				TaskPlayAnim(playerPed, "mini@atmexit", "exit", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
				RemoveAnimDict("mini@atmexit")
				Wait(500)

				bankapara = 10000    --StatGetInt("BANK_BALANCE",-1)
				nakitpara = 10000  --StatGetInt("MP0_WALLET_BALANCE",-1)

				if PayWithBank == 1 then
					oyuncusahippara = bankapara
				else
					oyuncusahippara = nakitpara
				end

				--===================================================================
				-- Please note, that despite if you make your players pay with
				-- cash or by bank, it will always show the selected bank popup
				-- if the player doesn't have enough cash (this is NOT a bug!)
				-- if you want/need it differently you can adapt the code bellow ;)
				--==================================================================
				if oyuncusahippara < biletucret then
					if UserBankIDi == 1 then		  		-- Maze Bank
						BankIcon = "CHAR_BANK_MAZE"
						BankName = "Merkez Bankası"
					end
					if UserBankIDi == 2 then				-- Bank Of Liberty
						BankIcon = "CHAR_BANK_BOL"
						BankName = "Liberty Bankası"
					end

					if UserBankIDi == 3 then		  		-- Fleeca (Default Fallback to!)
						BankIcon = "CHAR_BANK_FLEECA"
						BankName = "Fleeca Bankası"
					end
					SMS_Message(BankIcon, BankName, "İşlem Bilgilendirme",  "Transfer Başarısız, yeterli miktarda paranız bulunmamakta.", true)
				else
					if PayWithBank == 1 then
					end

					SMS_Message("CHAR_LS_TOURIST_BOARD", "Los Santos Ulaşım", "Bilgi", "Satın aldığınız için teşekkür ederiz, biletiniz metroda bir seferlik geçerli olacaktır.", true)
					metrodanindikontrol = false
					tickettarih = false
					biletkontrol = true
				end

				makinekullanmaevent = false
			end
		else
			alinmisbiletyardim = false
		end
	end
end)


Citizen.CreateThread(function()
	--=======================================================================================
	-- Note only do this 'check' every 550ms to prevent
	-- to much load in the game (taking in account many other scripts also running of course)
	--=======================================================================================
	while true do
		Wait(550)
		playerPed = PlayerPedId()
		oyuncumetroicindemi = IsPedInAnyTrain( playerPed )
		-- We only have to check this part if the player is NOT on the metro.
		if not oyuncumetroicindemi then
			metrodanindikontrol = false
			IsPlayerInVehicle = IsPedInAnyVehicle(playerPed, true)

			-- And then ONLY check it if the player isn't in a vehicle either
			-- Note: The way i'm using the metro, the game doesn't recognize it as being
			-- on/in a vehicle.
			if not IsPlayerInVehicle then

				if biletkontrol then
					if not ShowedEToEnterMetro then
						DisplayHelpText("Biletiniz mevcut. Metroya binebilirsiniz.")
						ShowedEToEnterMetro = true
					end
				end

				-- Only show the "Press [E] to buy...." message near the ticket machine if the player does NOT own a ticket already
				-- Do note that it IS possible to 'activate' the ticket machine again though (but will give a different message ;) )
				x,y,z = table.unpack(GetEntityCoords(playerPed, true))
				-- And then only need to keep checking (scanning cords) if the player is not near the Ticket Machine (anymore)
				if not yakindakimakinekontrol then
					for k,v in pairs(biletmakine) do
						biletmakinesi = GetClosestObjectOfType(x, y, z, 0.75, GetHashKey(v), false)
						if DoesEntityExist(biletmakinesi) then
							mevcutmakine = biletmakinesi
							biletX, biletY, biletZ = table.unpack(GetOffsetFromEntityInWorldCoords(biletmakinesi, 0.0, -.85, 0.0))
							yakindakimakinekontrol = true
						end
					end
				else
					if not DoesEntityExist(mevcutmakine) then
						yakindakimakinekontrol = false -- If for some (weird) reasons the ticked machine (suddenly)
					else								  --doesn't exist anymore, tell the script that the player isn't near one anymore
						if GetDistanceBetweenCoords(x,y,z, biletX, biletY, biletZ, true) > 2.0 then
							yakindakimakinekontrol = false -- And do the same if the player is more than a radius of 2.0 away from the ticket machine
						end
					end
				end
			end
		else
			if biletkontrol then
				--good to ride
				if metrodanindikontrol == false then
					SMS_Message("CHAR_LS_TOURIST_BOARD", "Los Santos Ulaşım", "Bilgi", "Bugün LSTI ile yolculuk yaptığınız için teşekkür ederiz.", true)
					Wait(500)
					SMS_Message("CHAR_LS_TOURIST_BOARD", "Los Santos Ulaşım", "Bilgi", "Metrodan çıktığınızda biletiniz iptal edilecektir.", true)
					metrodanindikontrol = true
					tickettarih = true
					biletkontrol = false
				end
			else
				if tickettarih == false then
					--no ticket but on train anyway
					--only show this every 3.5 seconds to make it annoying but not horrible
					SMS_Message("CHAR_LS_TOURIST_BOARD", "Los Santos Ulaşım", "Bilgi", "Metroya binmek için biletiniz yok. Lütfen çıkıp bilet alın.", true)
					Wait(3500) 
				end
			end
		end
	end
	
end)

function SMS_Message(NotiPic, SenderName, Subject, MessageText, PlaySound)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(MessageText)
    SetNotificationBackgroundColor(140)
    SetNotificationMessage(NotiPic, NotiPic, true, 4, SenderName, Subject, MessageText)
    DrawNotification(false, true)
	if PlaySound then
		PlaySoundFrontend(GetSoundId(), "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
	end
end

-- This is the text 'helper' which is used at the top left for messages like 'Press [E] to buy ticket ($25)'
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
	EndTextCommandDisplayHelp(0, 0, true, 2000)
end


