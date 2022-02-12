local blips = {}
local Cblips = {}
local servico = false
---------------------------------------------------------------------------------------------------------------------------
-- Iniciar Trabalho
---------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        for _,v in pairs(cfg.locs) do
            local distancia = Vdist(GetEntityCoords(ped),v.x,v.y,v.z)
            if distancia <= 5 then
                wait = 5
                DrawMarker(27,v.x,v.y,v.z-0.9,0,0,0,0.0,0,0,0.8,0.8,0.8,183,65,14,255,0,0,0,1)
                if distancia <= 1 then
                    DrawText3D(v.x,v.y,v.z,"PRESSIONE  ~r~E~w~  PARA " .. (servico and "~r~SAIR~s~ DO" or "~g~ENTRAR~s~ EM").." SERVIÇO")
                    if IsControlJustPressed(0,38)then
                        if not servico then
                            TriggerEvent("progress",2000,"Iniciando o expediente")
                            ExecuteCommand("e prancheta") 
                            Citizen.Wait(2000)                      
                            servico = true
                            cancelarfunc()--habilita o F7 para cancelar o emprego
                            vRPSend.RequestTable()
                            ClearPedTasksImmediately(ped)
                            vRP._DeletarObjeto()
                            TriggerEvent("Notify","sucesso","Trabalho iniciado.")                                
                        else
                            TriggerEvent("progress",2000,"Saindo de Serviço")
                            Citizen.Wait(2000)
                            cancelando()
                            TriggerEvent("Notify","aviso","Você saiu do Serviço")
                        end 
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)
-----------------------------------------------------------------------------------------------------------------------
--Coleta
-----------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        if servico and blips then
            for i,l in pairs(blips) do
                local distancia = Vdist(GetEntityCoords(ped),l.x,l.y,l.z)
                if distancia <= 15 then
                    wait = 5
                    DrawMarker(20,l.x,l.y,l.z-0.6,0,0,0,0.0,0,0,0.8,0.8,0.8,183,65,14,150,0,0,0,1)
                    if distancia <= 1 then
                        if IsControlJustPressed(0,38) then
                            TriggerEvent("progress",10000,"")
                            ExecuteCommand("e mecanico2")
                            Citizen.Wait(10000)
                            vRPSend.CheckPayment(i)
                            ClearPedTasksImmediately(ped)
                            TriggerEvent("Notify","sucesso","Coleta concluida, vá para outro local")
                        end
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)
----------------------------------------------------------------------------------------------
--funções
----------------------------------------------------------------------------------------------
function vRPReceiver.Deletarblips(id)
    if servico then
        if DoesBlipExist(Cblips[id]) then
            RemoveBlip(Cblips[id])
            Cblips[id] = nil
        end
        blips[id] = nil
    end
end

function vRPReceiver.CriandoBlip(table)
    blips = table
    for k,v in pairs(table) do
        Cblips[k] = AddBlipForCoord(v.x,v.y,v.z)
        SetBlipSprite(Cblips[k],1)
        SetBlipColour(Cblips[k],64)
        SetBlipScale(Cblips[k],0.5)
        SetBlipAsShortRange(Cblips[k],true)
        SetBlipRoute(Cblips[k],false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Rota de Sucata")
        EndTextCommandSetBlipName(Cblips[k] )
    end
end

function cancelando()
    for k,v in pairs(blips) do
        if DoesBlipExist(Cblips[k]) then
            RemoveBlip(Cblips[k])
            Cblips[k] = nil
        end
    end
    servico = false
    blips = {}
end

function cancelarfunc()
	Citizen.CreateThread(function()
		while true do
			wait = 1000
			if servico then
				wait = 10
				if IsControlJustPressed(0,168) then
					cancelando()
				end
			else
				break
			end
			Citizen.Wait(wait)
		end
	end)
end

function DrawText3D(x,y,z,text)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    SetTextFont(4)
    SetTextScale(0.35,0.35)
    SetTextColour(255,255,255,200)
    SetTextEntry("STRING")
    SetTextCentre(0.5)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 450
    DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,100)
end

RegisterCommand('testesucata',function(source)
    print(raro)
end)