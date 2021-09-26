NWG_UKREP_ExcludeFromGathering = [
    "Sign_Arrow_Green_F",
    "Sign_Arrow_F",
    "Sign_Arrow_Yellow_F",
    "Logic",
    "babe_helper",
    "Snake_random_F",
    "Rabbit_F",
    "FxWindGrass2",
    "FxWindPollen1",
    "ModuleCurator_F"
];

NWG_UKREP_GatherTheInfo =
{
    //Check
    if (isNil "nwgPlacementRoot" || {isNull nwgPlacementRoot}) exitWith
    {
        diag_log formatText ["%1(%2) [WARNING] %3", __FILE__, __LINE__, "#### nwgPlacementRoot is not set."];
    };

    //Get variables
    private _rootObj = nwgPlacementRoot;
    private _objects = nil;
    private _missionObjects = localNamespace getVariable "NWG_MIS_SER_missionObjects";

    if (!isNil "_missionObjects") then
    {
        //Mission inside NWG environment
        _objects = (_missionObjects#0)#0;//Objects of the first collection
    }
    else
    {
        //Separate mission
        _objects = allMissionObjects "All";
        _simpleObjects = allSimpleObjects [];
        _objects = _objects + _simpleObjects;
    };
    
    private _rootDir = getDir _rootObj;
    private _rootState = _rootObj call NWG_UKREP_EncodeObjectState;
    
    //Dump header and root object info
    diag_log "=========GATHER INFO=========";
    diag_log "_result pushBack [  '%SETUPNAME%' ,";
    diag_log format ["%1,",[(typeOf _rootObj), _rootState]];

    //Prepare collections
    private _units =[];
    private _vehicles = [];
    private _statWeapons = [];
    private _decorations = [];

    //Fill collections
    {
        if (_x isEqualTo _rootObj) then
        {
            continue;//Exclude root obj
        };

        private _classname = typeOf _x;

        if (_classname in NWG_UKREP_ExcludeFromGathering) then
        {
            continue;//Exclude system objects
        };

        private _offset = _rootObj worldToModel ASLToAGL getPosWorld _x;
        private _dirOffset = (getDir _x) - _rootDir;

        if (_x isKindOf "Man") then
        {
            if ((vehicle _x) isEqualTo _x) then //Man onfoot
            {
                private _unitStance = unitPos _x;
                private _unitState = 0;

                switch (_unitStance) do
                {
                    case "Auto";
                    case "Up":    {_unitState = 1};
                    case "Middle":{_unitState = 2};
                    case "Down":  {_unitState = 3};
                };

                _units pushBack [_classname, _offset, _dirOffset, _unitState];
            };

            continue;
        };
        
        if (_x call NWG_fnc_isVehicle) then
        {
            _vehicles pushBack [_classname, _offset, _dirOffset];
            continue;
        };

        if (_x isKindOf "StaticWeapon") then
        {
            private _gunner = gunner _x;
            private _gunnerRecord = if (isNil "_gunner" || {isNull _gunner}) then {""} else {(typeOf _gunner)};
            _statWeapons pushBack [_classname, _offset, _dirOffset, _gunnerRecord];
            continue;
        };

        //else
            private _state = _x call NWG_UKREP_EncodeObjectState;
            _decorations pushBack [_classname, _offset, _dirOffset, _state];

    } forEach _objects;

    private _dumper =
    {
        params ["_array", ["_final", false]];

        private _lastIndex = (count _array) - 1;

        if (_lastIndex == -1) exitWith { diag_log "[]," };//If array is empty

        for "_i" from 0 to _lastIndex do
        {
            private _prefix = if (_i == 0) then {"["} else {""};
            private _body = _array#_i;
            private _suffix = if (_i == _lastIndex) then { ["],", "] ];"] select _final} else {","};

            diag_log format ["%1%2%3", _prefix, _body, _suffix];
        };
    };

    diag_log "//DECORATIONS";
    [_decorations] call _dumper;

    diag_log "//STATIC WEAPONS";
    [_statWeapons] call _dumper;

    diag_log "//VEHICLES";
    [_vehicles] call _dumper;

    diag_log "//UNITS";
    [_units, true] call _dumper;

    //Dump footer
    diag_log "==========   END   ==========";
};

NWG_UKREP_EncodeObjectState =
{
    private _isHidden = isObjectHidden _this;
    if (isSimpleObject _this) exitWith {_isHidden};

    //else
    private _stateFlags = [false, false, false, false];

    _stateFlags set [0, (dynamicSimulationEnabled _this)];
    _stateFlags set [1, (simulationEnabled _this)];
    _stateFlags set [2, _isHidden];
    _stateFlags set [3, (isDamageAllowed _this)];

    //return
    _stateFlags
};