NWG_UKREP_ExcludeFromGathering = [
    "Sign_Arrow_Green_F",
    "Sign_Arrow_F",
    "Sign_Arrow_Yellow_F",
    "babe_helper",
    "Logic",
    "Camera",
    "Snake_random_F",
    "Kestrel_Random_F",
    "ButterFly_random",
    "Rabbit_F",
    "HoneyBee",
    "Mosquito",
    "HouseFly",
    "FxWindGrass2",
    "FxWindPollen1",
    "ModuleCurator_F",
    "#mark"
];

NWG_UKREP_GatherTheInfo =
{
    //Check
    if (isNil "nwgPlacementRoot" || {isNull nwgPlacementRoot}) exitWith
    {
        diag_log formatText ["%1(%2) [WARNING] %3", __FILE__, __LINE__, "#### nwgPlacementRoot is not set."];
    };

    //====================================================
    //Dump header and root object info
    private _rootObj = nwgPlacementRoot;
    private _rootPos = getPosWorld _rootObj;
    private _rootDir = getDir _rootObj;
    private _rootState = _rootObj call NWG_UKREP_EncodeObjectState;
    diag_log "=========GATHER INFO=========";
    diag_log "_result pushBack [  '%SETUPNAME%' ,";
    diag_log format ["%1,",[(typeOf _rootObj),_rootDir,_rootState,(_rootObj call NWG_fnc_isBuilding)]];

    //====================================================
    //Get surrounding objects
    private _buildings = [];
    private _decor = [];
    private _units = [];
    private _vehicles = [];
    private _turrets = [];
    private _mines = [];

    //Try getting from NWG environment
    private _gotFromOB = false;
    if (!isNil "NWG_OB_GetRootLayer") then
    {
        //Mission launched inside NWG environment
        //returns [_buildings,_decor,_units,_vehicles,_turrets,_mines,_groups,_triggers,_logics,_markers]
        private _layer = (call NWG_OB_GetRootLayer);
        if (isNil "_layer") exitWith {};

        _buildings  = (_layer#0) - [_rootObj];//Exclude root obj
        _decor      = (_layer#1) - [_rootObj];//Exclude root obj
        _units      = _layer#2;
        _vehicles   = _layer#3;
        _turrets    = _layer#4;
        _mines      = _layer#5;

        _gotFromOB = true;
    };
    
    //Get all mission objects
    if (!_gotFromOB) then
    {
        //Some separate empty mission
        //Get all objects
        private _missionObjects = allMissionObjects "";
        private _simpleObjects = allSimpleObjects [];
        _missionObjects = _missionObjects + _simpleObjects;

        //Fill collections
        for "_i" from 0 to ((count _missionObjects)-1) do
        {
            private _obj = _missionObjects#_i;
            private _classname  = typeOf _obj;
            private _objPos = getPosWorld _obj;
            private _offset = [
                ((_objPos#0)-(_rootPos#0)),
                ((_objPos#1)-(_rootPos#1)),
                ((_objPos#2)-(_rootPos#2))
            ];
            private _dirOffset  = (getDir _obj) - _rootDir;

            switch true do
            {
                case (_obj isEqualTo _rootObj);
                case (_classname in NWG_UKREP_ExcludeFromGathering):
                {
                    //Do nothing
                };
                case (_obj call NWG_fnc_isBuilding):
                {
                    private _state = _obj call NWG_UKREP_EncodeObjectState;
                    _buildings pushBack [_classname,_offset,_dirOffset,_state];
                };
                case (_obj isKindOf "Man"):
                {
                    //But only man onfoot
                    if ((vehicle _obj) isEqualTo _obj) then {
                        private _unitState = switch (unitPos _obj) do
                        {
                            case "Auto";
                            case "Up":    {1};
                            case "Middle":{2};
                            case "Down":  {3};
                            default       {0};
                        };
                        _units pushBack [_classname,_offset,_dirOffset,_unitState];
                    };
                };
                case (_obj call NWG_fnc_isVehicle):
                {
                    private _withCrew = (count (crew _obj)) > 0;
                    _vehicles pushBack [_classname,_offset,_dirOffset,_withCrew];
                };
                case (_obj isKindOf "StaticWeapon"):
                {
                    private _gunner = gunner _obj;
                    private _gunnerRecord = if (isNil "_gunner" || {isNull _gunner}) then {""} else {(typeOf _gunner)};
                    _turrets pushBack [_classname,_offset,_dirOffset,_gunnerRecord];
                };
                case (_obj isKindOf "TimeBombCore"):
                {
                    _mines pushBack [_classname,_offset,_dirOffset];
                };
                default
                {
                    //Some decoration
                    private _state = _obj call NWG_UKREP_EncodeObjectState;
                    _decor pushBack [_classname,_offset,_dirOffset,_state];
                };
            };
        };
    };

    //====================================================
    //Dump surrounding objects info
    private _dumper =
    {
        params ["_array",["_final", false]];

        private _lastIndex = (count _array) - 1;

        if (_lastIndex == -1) exitWith//If array is empty
        {
            if (_final) then
            {diag_log "[] ];";}
            else
            {diag_log "[],";};
        };

        for "_i" from 0 to _lastIndex do
        {
            private _prefix = if (_i == 0) then {"["} else {""};
            private _body = _array#_i;
            private _suffix = if (_i == _lastIndex) then { ["],", "] ];"] select _final} else {","};

            diag_log format ["%1%2%3", _prefix, _body, _suffix];
        };
    };

    diag_log "//BUILDINGS";
    [_buildings] call _dumper;

    diag_log "//DECOR";
    [_decor] call _dumper;

    diag_log "//UNITS";
    [_units] call _dumper;

    diag_log "//VEHICLES";
    [_vehicles] call _dumper;

    diag_log "//TURRETS";
    [_turrets] call _dumper;

    diag_log "//MINES";
    [_mines, true] call _dumper;

    //Dump footer
    diag_log "==========   END   ==========";

    //return
    "GATHERED. Check log files"
};

NWG_UKREP_EncodeObjectState =
{
    private _isHidden = isObjectHidden _this;
    if (isSimpleObject _this) exitWith {_isHidden};

    //else return
    [
        (dynamicSimulationEnabled _this),
        (simulationEnabled _this),
        _isHidden,
        (isDamageAllowed _this)
    ]
};