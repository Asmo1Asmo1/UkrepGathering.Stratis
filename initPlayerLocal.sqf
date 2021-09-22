//Emulate some functions
NWG_fnc_isVehicle =
{
    if  (_this isKindOf "Car"   ||
    {_this isKindOf "Tank"}     ||
    {_this isKindOf "Helicopter"} ||
    {_this isKindOf "Plane"}    ||
    {_this isKindOf "Ship"} ) exitWith { true };

    //else return
    false
};

//Init ukrep gathering and placement
call (compileFinal preprocessFileLineNumbers "ukrepGathering.sqf");