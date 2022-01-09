//Emulate some functions
NWG_fnc_isVehicle =
{
	(_this isKindOf "Car"        ||
	{_this isKindOf "Tank"       ||
	{_this isKindOf "Helicopter" ||
	{_this isKindOf "Plane"      ||
	{_this isKindOf "Ship"}}}})
};

NWG_fnc_isBuilding =
{
	if (_this isKindOf "Building" && {"_Structures_" in (getText(configOf _this >> "editorCategory"))}) exitWith
	{
		private _probablyBuilding = true;

		//Check subcategory
		private _subCat = (getText(configOf _this >> "editorSubCategory"));
		private _subCatExceptions = localNamespace getVariable "NWG_fnc_isBuilding_subCatExceptions";
		if (isNil "_subCatExceptions") then
		{
			_subCatExceptions = ["EdSubcat_ConstructionSites","EdSubcat_Lamps","EdSubcat_Obstacles"];
			localNamespace setVariable ["NWG_fnc_isBuilding_subCatExceptions",_subCatExceptions];
		};
		for "_i" from 0 to ((count _subCatExceptions)-1) do {
			if ((_subCatExceptions#_i) isEqualTo _subCat) exitWith {_probablyBuilding = false;};
		};
		if (!_probablyBuilding) exitWith {false};

		//Check type exceptions inside subcategory
		private _type = typeOf _this;
		private _exceptions = localNamespace getVariable "NWG_fnc_isBuilding_exceptions";
		if (isNil "_exceptions") then
		{
			_exceptions = ["Sandbag","Tent_01_floor","Windsock_01_F","_Grave_","_TreeBin_","_Water_source_","DragonsTeeth","StorageBladder"];
			localNamespace setVariable ["NWG_fnc_isBuilding_exceptions",_exceptions];
		};
		for "_i" from 0 to ((count _exceptions)-1) do {
			if ((_exceptions#_i) in _type) exitWith {_probablyBuilding = false;};
		};

		//return
		_probablyBuilding
	};

	//else
	false
};

//Init ukrep gathering
call (compileFinal preprocessFileLineNumbers "ukrepGathering.sqf");