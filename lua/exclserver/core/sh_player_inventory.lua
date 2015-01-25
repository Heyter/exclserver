local PLAYER = FindMetaTable("Player");
function PLAYER:ESHasItem(name,itemtype)
	if type(name) ~= "string" or type(itemtype) ~= "number" then return Error("Invalid arguments passed to function PLAYER.ESHasItem."); end

	if itemtype == ES.ITEM_TRAIL and type(self._es_inventory_trail)=="table" then
		return table.HasValue(self._es_inventory_trails,name);
	elseif itemtype == ES.ITEM_MELEE and type(self._es_inventory_meleeweapons)=="table" then
		return table.HasValue(self._es_inventory_meleeweapons,name);
	elseif itemtype == ES.ITEM_MODEL and type(self._es_inventory_models)=="table" then
		return table.HasValue(self._es_inventory_models,name);
	elseif itemtype == ES.ITEM_AURA and type(self._es_inventory_auras)=="table" then
		return table.HasValue(self._es_inventory_auras,name);
	elseif itemtype == ES.ITEM_PROP and type(self._es_inventory_props)=="table" then
		return table.HasValue(self._es_inventory_props,name);
	end

	ES.DebugPrint("Couldn't verify item in invetory; '"..name.."'@["..tostring(itemtype).."]");

	return false;
end
