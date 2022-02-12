local locblips = {}
local raro = {}

Citizen.CreateThread(function() 
	locblips = cfg.locais
	raridade()

end)

function vRPReceiver.RequestTable()
	local source = source
	local user_id = vRP.getUserId(source)		
	if user_id then
		vRPSend.CriandoBlip(source,locblips)
	end
end

function vRPReceiver.CheckPayment(id)
	local source = source
	local user_id = vRP.getUserId(source)		
	if user_id then
		local itemf = cfg.itens[math.random(1,3)]
		local quant = math.random(1,3)
		if raro[id] then
			local item = cfg.itensraro[math.random(#cfg.itensraro)]
			TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>1</b> "..vRP.itemNameList(item)..".")
			vRP.giveInventoryItem(user_id,item,1)
		else
			local item = cfg.itens[math.random(#cfg.itens)]
			TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>1</b> "..vRP.itemNameList(item)..".")
			vRP.giveInventoryItem(user_id,item,1)
		end
		TriggerClientEvent("vrp_sound:source",source,'coins',0.3)
		TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>"..quant.." </b>"..vRP.itemNameList(itemf)..".")
		vRP.giveInventoryItem(user_id,itemf,quant)
		if locblips[id] then
			locblips[id] = nil --apaga a linha do blip na tabeloa pelo id recebido
		end
		vRPSend.Deletarblips(-1,id)--apaga o blip especifico no client de geral
		local itemf = 0
		local quant = 0
	end
end


--restaura os blips depois de 120 minutos
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(120*60000)
		locblips = cfg.locais
		raridade()
	end
end)

function raridade()
	raro = {}
	for i = 1,15 do
		local random = math.random(#cfg.locais)
		if raro[random] == nil then
			raro[random] = true
		else
			raro[math.random(#cfg.locais)] = true
		end

	end

end