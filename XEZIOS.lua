----------------------------------
ADMIN_MODE = false
----------------------------------

project = {
	pName		= 'XEZIOS',
	pType		= 'Project',
	pTag		= '{9d00ff}CHRISMAS HOTFIX',
}

script_name(string.format(project.pName..' '..project.pType))
script_version(2.92)

--------------------------------------------------

--[[ underchat imgui
local ffi = require("ffi")
local hook = require("hooks")
do
    local org_addEventHandler = addEventHandler
    local hkPresentQueueu = {}
    function hkPresent(pDevice, pSourceRect, pDestRect, hDestWindowOverride, pDirtyRegion)
        for i, f in ipairs(hkPresentQueueu) do
            f()
        end
        return hkPresent(pDevice, pSourceRect, pDestRect, hDestWindowOverride, pDirtyRegion)
    end
    local D3D9Device = hook.vmt.new(ffi.cast('intptr_t*', 0xC97C28)[0]) --эти строчки вынести в main или куда там хотите чтобы хукалось самым последним
    hkPresent = D3D9Device.hookMethod('long(__stdcall*)(void*, void*, void*, void*, void*)', hkPresent, 17) --эти строчки вынести чтобы хукалось самым последним
    function addEventHandler(event, func)
        if event == "onD3DPresent" then
            table.insert(hkPresentQueueu, func)
        else
            return org_addEventHandler(event, func)
        end
    end
end
--]]

-- Libraries
local raknet = require 'samp.raknet' -- in lib folder 
local imgui = require 'imgui' -- in lib folder 
local http = require 'xezios.libraries.copas.http'
local copas = require 'xezios.libraries.copas'
local os = require 'os'
local dlstatus = require('xezios.libraries.moonloader').download_status 
local sampfuncs = require 'xezios.libraries.sampfuncs'
local weapons = require 'xezios.libraries.game.weapons'
local fa = require 'xezios.libraries.faIcons'
local memory = require 'xezios.libraries.memory'
local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local font_flag = require('moonloader').font_flag
local key = require 'xezios.libraries.vkeys'
local samp = require "xezios.libraries.samp.events"
local bs_io = require 'xezios.libraries.samp.events.bitstream_io'
local handler = require 'xezios.libraries.samp.events.handlers'
local extra_types = require 'xezios.libraries.samp.events.extra_types'
local broadcaster = import('lib/broadcaster.lua')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

require "xezios.libraries.moonloader"
require 'xezios.libraries.sampfuncs'
require "lfs"

-- Imgui addons
--imgui.ToggleButton_alpha = require('xezios.libraries.imgui_addons').ToggleButton
--[[ imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar  --]]
-- music
as_action = require('xezios.libraries.moonloader').audiostream_state
musicselected = 1 
hookselected = 1 
-- raknet
stats1 = ("nil")
stats2 = ("nil")
-- crasher
sync = false
-- anims
pAnimationWalk = {'WALK_PLAYER', 'GUNCROUCHFWD', 'GUNCROUCHBWD', 'GUNMOVE_BWD', 'GUNMOVE_FWD', 'GUNMOVE_L', 'GUNMOVE_R', 'RUN_GANG1', 'JOG_FEMALEA', 'JOG_MALEA', 'RUN_CIVI', 'RUN_CSAW', 'RUN_FAT', 'RUN_FATOLD', 'RUN_OLD', 'RUN_ROCKET', 'RUN_WUZI', 'SPRINT_WUZI', 'WALK_ARMED', 'WALK_CIVI', 'WALK_CSAW', 'WALK_DRUNK', 'WALK_FAT', 'WALK_FATOLD', 'WALK_GANG1', 'WALK_GANG2', 'WALK_OLD', 'WALK_SHUFFLE', 'WALK_START', 'WALK_START_ARMED', 'WALK_START_CSAW', 'WALK_START_ROCKET', 'WALK_WUZI', 'WOMAN_WALKBUSY', 'WOMAN_WALKFATOLD', 'WOMAN_WALKNORM', 'WOMAN_WALKOLD', 'WOMAN_RUNFATOLD', 'WOMAN_WALKPRO', 'WOMAN_WALKSEXY', 'WOMAN_WALKSHOP', 'RUN_1ARMED', 'RUN_ARMED', 'RUN_PLAYER', 'WALK_ROCKET', 'CLIMB_IDLE', 'MUSCLESPRINT', 'CLIMB_PULL', 'CLIMB_STAND', 'CLIMB_STAND_FINISH', 'SWIM_BREAST', 'SWIM_CRAWL', 'SWIM_DIVE_UNDER', 'SWIM_GLIDE', 'MUSCLERUN', 'WOMAN_RUN', 'WOMAN_RUNBUSY', 'WOMAN_RUNPANIC', 'WOMAN_RUNSEXY', 'SPRINT_CIVI', 'SPRINT_PANIC', 'SWAT_RUN', 'FATSPRINT'}
pAnimationDeagle = {'PYTHON_CROUCHFIRE', 'PYTHON_FIRE', 'PYTHON_FIRE_POOR'}
pOverdoseAnimations = {'CRCKIDLE4', 'CRCKIDLE2', 'CRCKDETH2'}
pGunsAnimations = {'PYTHON_CROUCHFIRE', 'PYTHON_FIRE', 'PYTHON_FIRE_POOR', 'PYTHON_CROCUCHRELOAD', 'RIFLE_CROUCHFIRE', 'RIFLE_CROUCHLOAD', 'RIFLE_FIRE', 'RIFLE_FIRE_POOR', 'RIFLE_LOAD', 'SHOTGUN_CROUCHFIRE', 'SHOTGUN_FIRE', 'SHOTGUN_FIRE_POOR', 'SILENCED_CROUCH_RELOAD', 'SILENCED_CROUCH_FIRE', 'SILENCED_FIRE', 'SILENCED_RELOAD', 'TEC_crouchfire', 'TEC_crouchreload', 'TEC_fire', 'TEC_reload', 'UZI_crouchfire', 'UZI_crouchreload', 'UZI_fire', 'UZI_fire_poor', 'UZI_reload', 'idle_rocket', 'Rocket_Fire', 'run_rocket', 'walk_rocket', 'WALK_start_rocket', 'WEAPON_sniper'}
packet_animation = {'WALK_PLAYER', 'GUNCROUCHFWD', 'GUNCROUCHBWD', 'GUNMOVE_BWD', 'GUNMOVE_FWD', 'GUNMOVE_L', 'GUNMOVE_R', 'RUN_GANG1', 'JOG_FEMALEA', 'JOG_MALEA', 'RUN_CIVI', 'RUN_CSAW', 'RUN_FAT', 'RUN_FATOLD', 'RUN_OLD', 'RUN_ROCKET', 'RUN_WUZI', 'SPRINT_WUZI', 'WALK_ARMED', 'WALK_CIVI', 'WALK_CSAW', 'WALK_DRUNK', 'WALK_FAT', 'WALK_FATOLD', 'WALK_GANG1', 'WALK_GANG2', 'WALK_OLD', 'WALK_SHUFFLE', 'WALK_START', 'WALK_START_ARMED', 'WALK_START_CSAW', 'WALK_START_ROCKET', 'WALK_WUZI', 'WOMAN_WALKBUSY', 'WOMAN_WALKFATOLD', 'WOMAN_WALKNORM', 'WOMAN_WALKOLD', 'WOMAN_RUNFATOLD', 'WOMAN_WALKPRO', 'WOMAN_WALKSEXY', 'WOMAN_WALKSHOP', 'RUN_1ARMED', 'RUN_ARMED', 'RUN_PLAYER', 'WALK_ROCKET', 'CLIMB_IDLE', 'MUSCLESPRINT', 'CLIMB_PULL', 'CLIMB_STAND', 'CLIMB_STAND_FINISH', 'SWIM_BREAST', 'SWIM_CRAWL', 'SWIM_DIVE_UNDER', 'SWIM_GLIDE', 'MUSCLERUN', 'WOMAN_RUN', 'WOMAN_RUNBUSY', 'WOMAN_RUNPANIC', 'WOMAN_RUNSEXY', 'SPRINT_CIVI', 'SPRINT_PANIC', 'SWAT_RUN', 'FATSPRINT'}
-- requests
-- ***********************************************************************************************************

ffi.cdef([[
    void Sleep(int ms);

    int poll(struct pollfd *fds, unsigned long nfds, int timeout);

    typedef unsigned long DWORD;

    struct d3ddeviceVTBL {
        void *QueryInterface;
        void *AddRef;
        void *Release;
        void *TestCooperativeLevel;
        void *GetAvailableTextureMem;
        void *EvictManagedResources;
        void *GetDirect3D;
        void *GetDeviceCaps;
        void *GetDisplayMode;
        void *GetCreationParameters;
        void *SetCursorProperties;
        void *SetCursorPosition;
        void *ShowCursor;
        void *CreateAdditionalSwapChain;
        void *GetSwapChain;
        void *GetNumberOfSwapChains;
        void *Reset;
        void *Present;
        void *GetBackBuffer;
        void *GetRasterStatus;
        void *SetDialogBoxMode;
        void *SetGammaRamp;
        void *GetGammaRamp;
        void *CreateTexture;
        void *CreateVolumeTexture;
        void *CreateCubeTexture;
        void *CreateVertexBuffer;
        void *CreateIndexBuffer;
        void *CreateRenderTarget;
        void *CreateDepthStencilSurface;
        void *UpdateSurface;
        void *UpdateTexture;
        void *GetRenderTargetData;
        void *GetFrontBufferData;
        void *StretchRect;
        void *ColorFill;
        void *CreateOffscreenPlainSurface;
        void *SetRenderTarget;
        void *GetRenderTarget;
        void *SetDepthStencilSurface;
        void *GetDepthStencilSurface;
        void *BeginScene;
        void *EndScene;
        void *Clear;
        void *SetTransform;
        void *GetTransform;
        void *MultiplyTransform;
        void *SetViewport;
        void *GetViewport;
        void *SetMaterial;
        void *GetMaterial;
        void *SetLight;
        void *GetLight;
        void *LightEnable;
        void *GetLightEnable;
        void *SetClipPlane;
        void *GetClipPlane;
        void *SetRenderState;
        void *GetRenderState;
        void *CreateStateBlock;
        void *BeginStateBlock;
        void *EndStateBlock;
        void *SetClipStatus;
        void *GetClipStatus;
        void *GetTexture;
        void *SetTexture;
        void *GetTextureStageState;
        void *SetTextureStageState;
        void *GetSamplerState;
        void *SetSamplerState;
        void *ValidateDevice;
        void *SetPaletteEntries;
        void *GetPaletteEntries;
        void *SetCurrentTexturePalette;
        void *GetCurrentTexturePalette;
        void *SetScissorRect;
        void *GetScissorRect;
        void *SetSoftwareVertexProcessing;
        void *GetSoftwareVertexProcessing;
        void *SetNPatchMode;
        void *GetNPatchMode;
        void *DrawPrimitive;
        void* DrawIndexedPrimitive;
        void *DrawPrimitiveUP;
        void *DrawIndexedPrimitiveUP;
        void *ProcessVertices;
        void *CreateVertexDeclaration;
        void *SetVertexDeclaration;
        void *GetVertexDeclaration;
        void *SetFVF;
        void *GetFVF;
        void *CreateVertexShader;
        void *SetVertexShader;
        void *GetVertexShader;
        void *SetVertexShaderConstantF;
        void *GetVertexShaderConstantF;
        void *SetVertexShaderConstantI;
        void *GetVertexShaderConstantI;
        void *SetVertexShaderConstantB;
        void *GetVertexShaderConstantB;
        void *SetStreamSource;
        void *GetStreamSource;
        void *SetStreamSourceFreq;
        void *GetStreamSourceFreq;
        void *SetIndices;
        void *GetIndices;
        void *CreatePixelShader;
        void *SetPixelShader;
        void *GetPixelShader;
        void *SetPixelShaderConstantF;
        void *GetPixelShaderConstantF;
        void *SetPixelShaderConstantI;
        void *GetPixelShaderConstantI;
        void *SetPixelShaderConstantB;
        void *GetPixelShaderConstantB;
        void *DrawRectPatch;
        void *DrawTriPatch;
        void *DeletePatch;
    };

    struct d3ddevice {
        struct d3ddeviceVTBL** vtbl;
    };

    struct stServerPresets
    {
        uint8_t     byteCJWalk;
        int         m_iDeathDropMoney;
        float        fWorldBoundaries[4];
        bool        m_bAllowWeapons;
        float        fGravity;
        uint8_t     byteDisableInteriorEnterExits;
        uint32_t    ulVehicleFriendlyFire;
        bool        m_byteHoldTime;
        bool        m_bInstagib;
        bool        m_bZoneNames;
        bool        m_byteFriendlyFire;
        int            iClassesAvailable;
        float        fNameTagsDistance;
        bool        m_bManualVehicleEngineAndLight;
        uint8_t     byteWorldTime_Hour;
        uint8_t     byteWorldTime_Minute;
        uint8_t     byteWeather;
        uint8_t     byteNoNametagsBehindWalls;
        int         iPlayerMarkersMode;
        float        fGlobalChatRadiusLimit;
        uint8_t     byteShowNameTags;
        bool        m_bLimitGlobalChatRadius;
    }__attribute__ ((packed));
]])

-- **************************************[ DX9 DEVICE ]*******************************************************

--if ffi.os == "Windows" then function sleep(time) ffi.C.Sleep(time * 1000) end
--else function sleep(time) ffi.C.poll(nil, 0, time * 1000) end end
local pDevice = ffi.cast("struct d3ddevice*", 0xC97C28)
local SetTextureStageState = ffi.cast("long(__stdcall*)(void*, unsigned long, unsigned long, unsigned long)", pDevice.vtbl[0].SetTextureStageState)
local GetTextureStageState = ffi.cast("long(__stdcall*)(void*, unsigned long, unsigned long, unsigned int*)", pDevice.vtbl[0].GetTextureStageState)
local dwConstant = ffi.new("unsigned int[1]")
local dwARG0 = ffi.new("unsigned int[1]")
local dwARG1 = ffi.new("unsigned int[1]")
local dwARG2 = ffi.new("unsigned int[1]")
local cast = ffi.cast("void(__thiscall*)(void*)", 0x59F180)
local ChamsQuery = {}

function AddPlayerToChamsQuery(handle, color)
    ChamsQuery[handle] = color
end
function RemoveFromChamsQuery(handle)
    ChamsQuery[handle] = nil
end

function onD3DPresent()
    
	--[[
	if not isSampLoaded() then return end
    if isCharOnFoot(playerPed) then
        if getCharSpeed(playerPed) ~= 0 then
            local cPedSpeed = getCharSpeed(playerPed)
            callFunction(0x007030A0, 1, 1, representFloatAsInt(cPedSpeed / 8))
        end
    end
    if isCharInAnyCar(playerPed) then
        local fCarSpeed = getCarSpeed(storeCarCharIsInNoSave(playerPed))
        callFunction(0x007030A0, 1, 1, representFloatAsInt(fCarSpeed / 35))
    end
	--]]
	
	if not sampIsScoreboardOpen() and not isPauseMenuActive() then
        for key, color in pairs(ChamsQuery) do
            local pPed = getCharPointer(key)
            if pPed ~= 0 then
                if script.chamstype.v == 0 then
                    GetTextureStageState(pDevice, 0, 32, dwConstant)
                    GetTextureStageState(pDevice, 0, 26, dwARG0)
                    GetTextureStageState(pDevice, 0, 3,  dwARG2)
                    SetTextureStageState(pDevice, 0, 32, color)
                    SetTextureStageState(pDevice, 0, 26, 6)
                    SetTextureStageState(pDevice, 0, 3, 6) 
                    cast(ffi.cast("void*", pPed))
                    SetTextureStageState(pDevice, 0, 32, dwConstant[0])
                    SetTextureStageState(pDevice, 0, 26, dwARG0[0])
                    SetTextureStageState(pDevice, 0, 3,  dwARG2[0])        
			   else
                    GetTextureStageState(pDevice, 0, 32, dwConstant)
                    GetTextureStageState(pDevice, 0, 26, dwARG0)
                    GetTextureStageState(pDevice, 0, 2,  dwARG1)
                    GetTextureStageState(pDevice, 0, 3,  dwARG2)
                    SetTextureStageState(pDevice, 0, 32, color)
                    SetTextureStageState(pDevice, 0, 26, 6)
                    SetTextureStageState(pDevice, 0, 2,  6)
                    SetTextureStageState(pDevice, 0, 3,  6)
                    cast(ffi.cast("void*", pPed))
                    SetTextureStageState(pDevice, 0, 32, dwConstant[0])
                    SetTextureStageState(pDevice, 0, 26, dwARG0[0])
                    SetTextureStageState(pDevice, 0, 2,  dwARG1[0])
                    SetTextureStageState(pDevice, 0, 3,  dwARG2[0])
                end
            end
        end
    end
end

-- ***********************************************************************************************************

local packets = {}

packets[207] = {
    recv = {
        {'leftRightKeys', 'int16', true},
        {'upDownKeys', 'int16', true},
        {'keysData', 'int16', false},
        {'position', 'vector3d', false},
        {'quaternion', 'normQuat', false},
        {'health/armor', 'decompressHealthAndArmor', false},
        {'weapon', 'int8', false},
        {'specialAction', 'int8', false},
        {'moveSpeed', 'compressedVector', false},
        {
            {'surfingVehicleId', 'surfingOffsets'}, {'int16', 'vector3d'}, true
        },
        {
            {'animationId', 'animationFlags'}, {'int16', 'int16'}, true
        }
    },
    send = {
        {'leftRightKeys', 'int16', false},
        {'upDownKeys', 'int16', false},
        {'keysData', 'int16', false},
        {'position', 'vector3d', false},
        {'quaternion', 'floatQuat', false},
        {'health', 'int8', false},
        {'armor', 'int8', false},
        {'weapon', 'int8', false},
        {'specialAction', 'int8', false},
        {'moveSpeed', 'vector3d', false},
        {'surfingOffsets', 'vector3d', false},
        {'surfingVehicleId', 'int16', false},
        {'animationId', 'int16', false},
        {'animationFlags', 'int16', false},
    }
}

packets[200] = {
    recv = {
        {'vehicleId', 'int16', false},
        {'leftRightKeys', 'int16', false},
        {'upDownKeys', 'int16', false},
        {'keysData', 'int16', false},
        {'quaternion', 'normQuat', false},
        {'position', 'vector3d', false},
        {'moveSpeed', 'compressedVector', false},
        {'vehicleHealth', 'int16', false},
        {'playerHealth/armor', 'decompressHealthAndArmor', false},
        {'weapon', 'int8', false},
        {'siren', 'bool', false},
        {'landingGear', 'bool', false},
        {'trainSpeed', 'float', true},
        {'trailerId', 'int16', true}
    },
    send = {
        {'vehicleId', 'int16', false},
        {'leftRightKeys', 'int16', false},
        {'upDownKeys', 'int16', false},
        {'keysData', 'int16', false},
        {'quaternion', 'floatQuat', false},
        {'position', 'vector3d', false},
        {'moveSpeed', 'vector3d', false},
        {'vehicleHealth', 'float', false},
        {'playerHealth', 'int8', false},
        {'armor', 'int8', false},
        {'weapon', 'int8', false},
        {'siren', 'int8', false},
        {'landingGearState', 'int8', false},
        {'trailerId', 'int16', false},
        {'trainSpeed', 'float', false},
    }
}

packets[211] = {
    {'vehicleId', 'int16', false},
    {'seatId', 'int8', false},
    {'weapon', 'int8', false},
    {'health', 'int8', false},
    {'armor', 'int8', false},
    {'leftRightKeys', 'int16', false},
    {'upDownKeys', 'int16', false},
    {'keysData', 'int16', false},
    {'position', 'vector3d', false},
}

packets[210] = {
    {'trailerId', 'int16', false},
    {'position', 'vector3d', false},
    {'roll', 'vector3d', false},
    {'direction', 'vector3d', false},
    {'speed', 'vector3d', false},
    {'unk', 'int32', false}
}

packets[209] = {
    {'vehicleId', 'int16', false},
    {'seatId', 'int8', false},
    {'roll', 'vector3d', false},
    {'direction', 'vector3d', false},
    {'position', 'vector3d', false},
    {'moveSpeed', 'vector3d', false},
    {'turnSpeed', 'vector3d', false},
    {'vehicleHealth', 'float', false},
}

packets[203] = {
    {'camMode', 'int8', false},
    {'camFront', 'vector3d', false},
    {'camPos', 'vector3d', false},
    {'aimZ', 'float', false},
    {'camExtZoom', 'int8', false},
    {'weaponState', 'int8', false},
    {'unk', 'int8', false},
}

packets[206] = {
    {'targetType', 'int8', false},
    {'targetId', 'int16', false},
    {'origin', 'vector3d', false},
    {'target', 'vector3d', false},
    {'center', 'vector3d', false},
    {'weapon', 'int8', false},
}

local rpc = {outcoming = {}, incoming = {}}

-- OUTCOMING RPC
rpc.outcoming[26] = {
    {'vehicleId', 'int16', false},
    {'passenger', 'bool8', false},
}

rpc.outcoming[23] = {
    {'playerId', 'int16', false},
    {'source', 'int8', false}
}

rpc.outcoming[25] = {
    {'version', 'int32', false},
    {'mod', 'int8', false},
    {'nickname', 'string8', false},
    {'challengeResponse', 'int32', false},
    {'joinAuthKey', 'int8', false},
    {'clientVer', 'string8', false},
    {'unk', 'int32', false},
}

rpc.outcoming[27] = {
    {'type', 'int32', false},
    {'objectId', 'int16', false},
    {'model', 'int32', false},
    {'position', 'vector3d', false}
}

rpc.outcoming[50] = {
    {'command', 'string32', false}
}

rpc.outcoming[52] = {} -- пустая таблица, в логах просто отобразиться уведомление об RPC
rpc.outcoming[53] = {
    {'reason', 'int8', false},
    {'killerId', 'int16', false},
}

rpc.outcoming[62] = {
    {'dialogId', 'int16', false},
    {'button', 'int8', false},
    {'listBoxId', 'int16', false},
    {'input', 'string8', false},
}

rpc.outcoming[83] = {
    {'textDrawId', 'int16', false}
}

rpc.outcoming[96] = {
    {'vehicleId', 'int32', false},
    {'param1', 'int32', false},
    {'param2', 'int32', false},
    {'event', 'int32', false}
}

rpc.outcoming[101] = {
    {'message', 'string8', false}
}

rpc.outcoming[103] = {
    {'flags', 'int8', false},
    {'unk1', 'int32', false},
    {'unk2', 'int8', false},
}

rpc.outcoming[106] = {
    {'vehicleId', 'int16', false},
    {'panelDmg', 'int32', false},
    {'doorDmg', 'int32', false},
    {'lights', 'int8', false},
    {'tires', 'int8', false}
}

rpc.outcoming[116] = {
    {'response', 'int32', false},
    {'index', 'int32', false},
    {'model', 'int32', false},
    {'bone', 'int32', false},
    {'position', 'vector3d', false},
    {'rotation', 'vector3d', false},
    {'scale', 'vector3d', false},
    {'color1', 'int32', false},
    {'color2', 'int32', false}
}

rpc.outcoming[117] = {
    {'playerObject', 'bool', false},
    {'objectId', 'int16', false},
    {'response', 'int32', false},
    {'position', 'vector3d', false},
    {'rotation', 'vector3d', false},
}

rpc.outcoming[118] = {
    {'interior', 'int8', false}
}

rpc.outcoming[119] = {
    {'position', 'vector3d', false}
}

rpc.outcoming[128] = {
    {'classId', 'int32', false},
}

rpc.outcoming[129] = {}

rpc.outcoming[131] = {
    {'pickupId', 'int32', false}
}

rpc.outcoming[132] = {
    {'row', 'int8', false}
}

rpc.outcoming[136] = {
    {'vehicleId', 'int16', false}
}

rpc.outcoming[140] = {}

rpc.outcoming[154] = {
    {'vehicleId', 'int16', false}
}

rpc.outcoming[155] = {}

rpc.outcoming[115] = {
    {'take', 'bool', false},
    {'playerId', 'int16', false},
    {'damage', 'float', false},
    {'weapon', 'int32', false},
    {'bodyPart', 'int32', false},
}

-- INCOMING RPC
rpc.incoming[139] = { -- onInitGame
    {'zoneNames', 'bool', false},
    {'useCJWalk', 'bool', false},
    {'allowWeapons', 'bool', false},
    {'limitGlobalChatRadius', 'bool', false},
    {'globalChatRadius', 'float', false},
    {'nametagDrawDist', 'float', false},
    {'disableEnterExits', 'bool', false},
    {'nametagLOS', 'bool', false},
    {'tirePopping', 'bool', false},
    {'classesAvailable', 'int32', false},
    {'playerId', 'int16', false},
    {'showPlayerTags', 'bool', false},
    {'playerMarkersMode', 'int32', false},
    {'worldTime', 'int8', false},
    {'worldWeather', 'int8', false},
    {'gravity', 'float', false},
    {'lanMode', 'bool', false},
    {'deathMoneyDrop', 'int32', false},
    {'instagib', 'bool', false},
    {'normalOnfootSendrate', 'int32', false},
    {'normalIncarSendrate', 'int32', false},
    {'normalFiringSendrate', 'int32', false},
    {'sendMultiplier', 'int32', false},
    {'lagCompMode', 'int32', false},
    {'hostname', 'string8', false},
    {'vehicleModels', 'GameVehicleModels', false},
    {'unknown', 'int32', false}
}

rpc.incoming[137] = {
    {'playerId', 'int16', false},
    {'color', 'int32', false},
    {'isNPC', 'bool8', false},
    {'nickname', 'string8', false},
}

rpc.incoming[138] = {
    {'playerId', 'int16', false},
    {'reason', 'int8', false}
}

rpc.incoming[128] = {
    {'canSpawn', 'bool8', false},
    {'team', 'int8', false},
    {'skin', 'int32', false},
    {'unk', 'int8', false},
    {'position', 'vector3d', false},
    {'rotation', 'float', false},
    {'weapons', 'Int32Array3', false},
    {'ammo', 'Int32Array3', false},
}

rpc.incoming[129] = {
    {'response', 'bool8', false}
}

rpc.incoming[11] = {
    {'playerId', 'int16', false},
    {'nickname', 'string8', false},
    {'success', 'bool8', false},
}

rpc.incoming[12] = {
    {'position', 'vector3d', false},
}

rpc.incoming[13] = {
    {'position', 'vector3d', false}
}

rpc.incoming[14] = {
    {'health', 'float', false}
}

rpc.incoming[15] = {
    {'controllable', 'bool8', false}
}

rpc.incoming[16] = {
    {'soundId', 'int32', false},
    {'position', 'vector3d', false}
}

rpc.incoming[17] = {
    {'maxX', 'float', false},
    {'minX', 'float', false},
    {'maxY', 'float', false},
    {'minY', 'float', false},
}

rpc.incoming[18] = {
    {'money', 'int32', false}
}

rpc.incoming[19] = {
    {'angle', 'float', false}
}

rpc.incoming[20] = {}
rpc.incoming[21] = {}

rpc.incoming[22] = {
    {'weaponId', 'int32', false},
    {'ammo', 'int32', false}
}

rpc.incoming[28] = {}
rpc.incoming[29] = {
    {'hour', 'int8', false},
    {'minute', 'int8', false}
}

rpc.incoming[30] = {
    {'state', 'bool8', false}
}

rpc.incoming[32] = {
    {'playerId', 'int16', false},
    {'team', 'int8', false},
    {'model', 'int32', false},
    {'positon', 'vector3d', false},
    {'rotation', 'float', false},
    {'color', 'int32', false},
    {'fightingStyle', 'int8', false},
}

rpc.incoming[33] = {
    {'name', 'string256', false}
}

rpc.incoming[34] = {
    {'playerId', 'int16', false},
    {'skill', 'int32', false},
    {'level', 'int16', false},
}

rpc.incoming[35] = {
    {'drunkLevel', 'int32', false}
}

rpc.incoming[36] = {
    {'id', 'int16', false},
    {'color', 'int32', false},
    {'position', 'vector3d', false},
    {'distance', 'float', false},
    {'testLOS', 'bool8', false},
    {'attachedPlayerId', 'int16', false},
    {'attachedVehicleId', 'int16', false},
    {'text', 'encodedString4096', false}
}

rpc.incoming[37] = {}

rpc.incoming[38] = {
    {'type', 'int8', false},
    {'position', 'vector3d', false},
    {'nextPosition', 'vector3d', false},
    {'size', 'float', false}
}

rpc.incoming[39] = {}
rpc.incoming[40] = {}

rpc.incoming[41] = {
    {'url', 'string8', false},
    {'position', 'vector3d', false},
    {'radius', 'float', false},
    {'usePosition', 'bool8', false},
}

rpc.incoming[42] = {}

rpc.incoming[43] = {
    {'modelId', 'int32', false},
    {'position', 'vector3d', false},
    {'radius', 'float', false}
}

rpc.incoming[44] = { -- onCreateObject
    {'objectId', 'int16', false},
    {'model', 'int32', false},
    {'position', 'vector3d', false},
    {'rotation', 'vector3d', false},
    {'drawDistance', 'float', false},
    {'noCameraCol', 'bool8', false},
    {'attachData', 'objectAttachData', false},
    {'texturesCount', 'int8', false},
    {'materialData', 'objectMaterialData', false},
}

rpc.incoming[45] = {
    {'objectId', 'int16', false},
    {'position', 'vector3d', false},
}

rpc.incoming[46] = {
    {'objectId', 'int16', false},
    {'rotation', 'vector3d', false},
}

rpc.incoming[47] = {
    {'objectId', 'int16', false}
}

rpc.incoming[55] = {
    {'killerId', 'int16', false},
    {'victimId', 'int16', false},
    {'weapon', 'int8', false}
}

rpc.incoming[56] = {
    {'iconId', 'int8', false},
    {'position', 'vector3d', false},
    {'type', 'int8', false},
    {'color', 'int32', false},
    {'style', 'int8', false}
}

rpc.incoming[57] = {
    {'vehicleId', 'int16', false},
    {'componentId', 'int16', false},
}

rpc.incoming[58] = {
    {'textLabelId', 'int16', false}
}

rpc.incoming[59] = {
    {'playerId', 'int16', false},
    {'color', 'int32', false},
    {'distance', 'float', false},
    {'duration', 'int32', false},
    {'message', 'string8', false}
}

rpc.incoming[60] = {
    {'time', 'int32', false}
}

rpc.incoming[61] = {
    {'dialogId', 'int16', false},
    {'style', 'int8', false},
    {'title', 'string8', false},
    {'button1', 'string8', false},
    {'button2', 'string8', false},
    {'text', 'encodedString4096', false}
}

rpc.incoming[63] = {
    {'id', 'int32', false}
}

rpc.incoming[65] = {
    {'vehicleId', 'int16', false},
    {'interiorId', 'int8', false},
}

rpc.incoming[66] = {
    {'armour', 'float', false}
}

rpc.incoming[67] = {
    {'weaponId', 'int32', false}
}

rpc.incoming[68] = {
    {'team', 'int8', false},
    {'skin', 'int32', false},
    {'unk', 'int8', false},
    {'position', 'vector3d', false},
    {'rotation', 'float', false},
    {'weapons', 'Int32Array3', false},
    {'ammo', 'Int32Array3', false}
}

rpc.incoming[69] = {
    {'playerId', 'int16', false},
    {'teamId', 'int8', false}
}

rpc.incoming[70] = {
    {'vehicleId', 'int16', false},
    {'seatId', 'int8', false}
}

rpc.incoming[71] = {}

rpc.incoming[72] = {
    {'playerId', 'int16', false},
    {'color', 'int32', false}
}

rpc.incoming[73] = {
    {'style', 'int32', false},
    {'time', 'int32', false},
    {'text', 'string32', false}
}

rpc.incoming[74] = {}

rpc.incoming[75] = {
    {'objectId', 'int16', false},
    {'playerId', 'int16', false},
    {'offsets', 'vector3d', false},
    {'rotation', 'vector3d', false},
}

rpc.incoming[76] = { -- onInitMenu
    {'menuId', 'int8', false},
    {'twoColumns', 'bool32', false},
    {'menuTitle', 'string256', false},
    {'X/Y', 'vector2d', false},
    {'colWidth', 'vector2d', false},
    {'menu', 'int32', false},
    -- rows и columns убраны из-за того что их сложно реализовать (P.S Весь onInitMenu нужно реализовывать в одном пункте...)
}

rpc.incoming[77] = {
    {'menuId', 'int8', false}
}

rpc.incoming[78] = {
    {'menuId', 'int8', false}
}

rpc.incoming[79] = {
    {'position', 'vector3d', false},
    {'style', 'int32', false},
    {'radius', 'float', false}
}

rpc.incoming[80] = {
    {'playerId', 'int16', false},
    {'show', 'bool8', false},
}

rpc.incoming[81] = {
    {'objectId', 'int16', false}
}

rpc.incoming[82] = {
    {'setPos', 'bool', false},
    {'fromPos', 'vector3d', false},
    {'destPos', 'vector3d', false},
    {'time', 'int32', false},
    {'mode', 'int8', false},
}

rpc.incoming[85] = {
    {'zone', 'int16', false}
}

rpc.incoming[86] = {
    {'playerId', 'int16', false},
    {'animLib', 'string8', false},
    {'animName', 'string8', false},
    {'loop', 'bool', false},
    {'lockX', 'bool', false},
    {'lockY', 'bool', false},
    {'freeze', 'bool', false},
    {'time', 'int32', false},
}

rpc.incoming[87] = {
    {'playerId', 'int16', false},
}

rpc.incoming[88] = {
    {'actionId', 'int8', false},
}

rpc.incoming[89] = {
    {'playerId', 'int16', false},
    {'styleId', 'int8', false},
}

rpc.incoming[90] = {
    {'velocity', 'vector3d', false}
}

rpc.incoming[91] = {
    {'turn', 'bool8', false},
    {'velocity', 'vector3d', false},
}

rpc.incoming[93] = {
    {'color', 'int32', false},
    {'message', 'string32', false}
}

rpc.incoming[94] = {
    {'hour', 'int8', false},
}

rpc.incoming[95] = {
    {'id', 'int32', false},
    {'model', 'int32', false},
    {'pickupType', 'int32', false},
    {'position', 'vector3d', false},
}

rpc.incoming[99] = {
    {'objectId', 'int16', false},
    {'fromPos', 'vector3d', false},
    {'destPos', 'vector3d', false},
    {'speed', 'float', false},
    {'rotation', 'vector3d', false},
}

rpc.incoming[104] = {
    {'state', 'bool', false}
}

rpc.incoming[105] = {
    {'id', 'int16', false},
    {'text', 'string16', false},
}

rpc.incoming[107] = {
    {'position', 'vector3d', false},
    {'radius', 'float', false},
}

rpc.incoming[108] = {
    {'zoneId', 'int16', false},
    {'squareStart', 'vector2d', false},
    {'squareEnd', 'vector2d', false},
    {'color', 'int32', false}
}

rpc.incoming[112] = {
    {'suspectId', 'int16', false},
    {'unk', 'Int32Array3', false},
    {'crime', 'int32', false},
    {'coordinates', 'vector3d', false},
}

rpc.incoming[120] = {
    {'zoneId', 'int16', false},
}

rpc.incoming[121] = {
    {'zoneId', 'int16', false},
    {'color', 'int32', false}
}

rpc.incoming[122] = {
    {'objectId', 'int16'}
}

rpc.incoming[123] = {
    {'vehicleId', 'int16', false},
    {'text', 'string8', false}
}

rpc.incoming[124] = {
    {'state', 'bool32', false},
}

rpc.incoming[126] = {
    {'playerId', 'int16', false},
    {'camType', 'int8', false},
}

rpc.incoming[127] = {
    {'vehicleId', 'int16', false},
    {'camType', 'int8', false},
}

rpc.incoming[134] = {
    {'textDrawId', 'int16', false},
    {'flags', 'int8', false},
    {'letterWidth', 'float', false},
    {'letterHeight', 'float', false},
    {'letterColor', 'int32', false},
    {'lineWidth', 'float', false},
    {'lineHeight', 'float', false},
    {'boxColor', 'int32', false},
    {'shadow', 'int8', false},
    {'outline', 'int8', false},
    {'bgColor', 'int32', false},
    {'style', 'int8', false},
    {'selectable', 'int8', false},
    {'position', 'vector2d', false},
    {'modelId', 'int16', false},
    {'rotation', 'vector3d', false},
    {'zoom', 'float', false},
    {'color', 'int32', false},
    {'text', 'string16', false},
}

rpc.incoming[133] = {
    {'wantedLevel', 'int8', false},
}

rpc.incoming[135] = {
    {'textDrawId', 'int16', false},
}

rpc.incoming[144] = {
    {'iconId', 'int8', false},
}

rpc.incoming[145] = {
    {'weaponId', 'int8', false},
    {'ammo', 'int16', false},
}

rpc.incoming[146] = {
    {'gravity', 'float', false}
}

rpc.incoming[147] = {
    {'vehicleId', 'int16', false},
    {'health', 'float', false},
}

rpc.incoming[148] = {
    {'trailerId', 'int16', false},
    {'vehicleId', 'int16', false},
}

rpc.incoming[149] = {
    {'vehicleId', 'int16', false}
}

rpc.incoming[152] = {
    {'weatherId', 'int8', false}
}

rpc.incoming[153] = {
    {'playerId', 'int16', false},
    {'skinId', 'int32', false},
}

rpc.incoming[156] = {
    {'interior', 'int8', false}
}

rpc.incoming[157] = {
    {'camPos', 'vector3d', false},
}

rpc.incoming[158] = {
    {'lookAtPos', 'vector3d', false},
    {'cutType', 'int8', false},
}

rpc.incoming[159] = {
    {'vehicleId', 'int16', false},
    {'position', 'vector3d', false}
}

rpc.incoming[160] = {
    {'vehicleId', 'int16', false},
    {'angle', 'float', false}
}

rpc.incoming[161] = {
    {'vehicleId', 'int16', false},
    {'objective', 'bool8', false},
    {'doorsLocked', 'bool8', false},
}

rpc.incoming[162] = {}

rpc.incoming[101] = {
    {'playerId', 'int16', false},
    {'text', 'string8', false}
}

rpc.incoming[130] = {
    {'reason', 'int8', false}
}

rpc.incoming[163] = {
    {'playerId', 'int16', false}
}

rpc.incoming[164] = {
    {'vehicleId', 'int16', false},
    {'type', 'int32', false},
    {'position', 'vector3d', false},
    {'rotation', 'float', false},
    {'interiorColor1', 'int8', false},
    {'interiorColor2', 'int8', false},
    {'health', 'float', false},
    {'interiorId', 'int8', false},
    {'doorDamageStatus', 'int32', false},
    {'panelDamageStatus', 'int32', false},
    {'lightDamageStatus', 'int8', false},
    {'addSiren', 'int8', false},
    {'modSlots', 'vehicleModSlots', false},
    {'paintJob', 'int8', false},
    {'bodyColor1', 'int32', false},
    {'bodyColor2', 'int32', false},
    {'unk', 'int8', false},
}

rpc.incoming[165] = {
    {'vehicleId', 'int16', false}
}

rpc.incoming[166] = {
    {'playerId', 'int16', false},
}

rpc.incoming[26] = {
    {'playerId', 'int16', false},
    {'vehicleId', 'int16', false},
    {'passenger', 'bool8', false}
}

rpc.incoming[155] = {
   -- {'playerList', 'PlayerScorePingMap', false} -- я думаю при вызове все умрет, но хз
}

rpc.incoming[84] = {
    {'objectId', 'int16', false},
    {'materialData', 'objectMaterialDataSet', false}
}

rpc.incoming[171] = {
    {'actorId', 'int16', false},
    {'skinId', 'int32', false},
    {'position', 'vector3d', false},
    {'rotation', 'float', false},
    {'health', 'float', false},
}

rpc.incoming[83] = {
    {'state', 'bool', false},
    {'hovercolor', 'int32', false,}
}

rpc.incoming[24] = {
    {'vehicleId', 'int16', false},
    {'engine', 'int8', false},
    {'lights', 'int8', false},
    {'alarm', 'int8', false},
    {'doors', 'int8', false},
    {'bonnet', 'int8', false},
    {'boot', 'int8', false},
    {'objective', 'int8', false},
    {'unk', 'int8', false},
    {'driver', 'int8', false},
    {'passenger', 'int8', false},
    {'backleft', 'int8', false},
    {'backright', 'int8', false},
    {'windows_driver', 'int8', false},
    {'windows_passenger', 'int8', false},
    {'windows_backleft', 'int8', false},
    {'windows_backright', 'int8', false},
}

rpc.incoming[113] = {
    {'playerId', 'int16', false},
    {'index', 'int32', false},
    {'create', 'bool', false},
    {'modelId', 'int32', false},
    {'bone', 'int32', false},
    {'offset', 'vector3d', false},
    {'rotation', 'vector3d', false},
    {'scale', 'vector3d', false},
    {'color1', 'int32', false},
    {'color2', 'int32', false},
}

-- ***********************************************000***NOPS PACK*********************************************

-- Thank you, Musaigen (Copyed from script "RakLogger++" - https://blast.hk/threads/36665/)
local filter_packets_incoming = {}
local filter_packets_outcoming = {}
local filter_rpc_incoming = {}
local filter_rpc_outcoming = {}

function check_has_in_filter(name, t)
    for key, value in pairs(t) do
        if value[1]:gsub('##.+', '') == name then return value[2].v end
    end
end

function render_nops_filter(num, t, f) -- f = фильтр
  if script.nops_page == num  then
    for key, value in pairs(t) do
        if #f.v > 0 then
            if string.find(string.lower(value[1]), string.lower(f.v), 1, true) then
                imgui.Checkbox(value[1], value[2])
            end
        else
            imgui.Checkbox(value[1], value[2])
        end
    end
  end
end

function ReadNopsData()
	for i = 200, 212 do
		if raknetGetPacketName(i) ~= nil then
			if packets[i] ~= nil then
				filter_packets_incoming[i] = {raknetGetPacketName(i), imgui.ImBool(false)}
				filter_packets_outcoming[i] = {raknetGetPacketName(i) ..'##1', imgui.ImBool(false)}
			end
		end
	end
	for i = 1, 166 do
		if raknetGetRpcName(i) ~= nil then
			if rpc.incoming[i] ~= nil then
				filter_rpc_incoming[i] = {raknetGetRpcName(i), imgui.ImBool(false)}
			end
			if rpc.outcoming[i] ~= nil then
				filter_rpc_outcoming[i] = {raknetGetRpcName(i) .. '##1', imgui.ImBool(false)}
			end
		end
	end
end

ReadNopsData()

-- ***********************************************************************************************************
-- ***********************************************************************************************************
-- ***********************************************************************************************************

requests = require('requests')
effil = require 'effil' 

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function (method, url, args)
		local requests = require 'requests'
		local track_result, track_response = pcall(requests.request, method, url, args)
		if track_result then
			track_response.json, track_response.xml = nil, nil
			return true, track_response
		else
			return false, track_response
		end
	end)(method, url, args)
	if not resolve then resolve = function() end end
	if not reject then reject = function() end end
	lua_thread.create(function()
		local runner = request_thread
		while true do
			local status, track_err = runner:status()
			if not track_err then
			if status == 'completed' then
				local track_result, track_response = runner:get()
				if track_result then
				  resolve(track_response)
				else
				  reject(track_response)
				end
				return
			elseif status == 'canceled' then
				return reject(status)
			end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end

version_status = 'checking...'

function SendRequests()	
	if not ADMIN_MODE then
		CleanChat()
	end
	
	sampAddChatMessage('{b700d4}[XEZIOS]: {B9C9BF}SAMP 0.3.7 {ffffff}Started', 0xb700d4)
	sampAddChatMessage('{b700d4}[XEZIOS]: {B9C9BF}Loading. Checking for updates...', 0xb700d4)
	
	if ADMIN_MODE then
		version_status = 'uptodate'
	else
		asyncHttpRequest('GET', 'https://sadfi2259x.github.io/xezios-project/version.json', nil, function (response) --kson method
			if type(tonumber(decodeJson(response.text)['version'])) == 'number' then
				version_check = decodeJson(response.text)['version']
				if tonumber((thisScript().version)) == tonumber(version_check) then
					version_status = 'uptodate'
				elseif tonumber(thisScript().version) < tonumber(version_check) then
					version_status = 'missupdate'
				else
					version_status = "error"
					update_error_reason = "Failed to get updates"
				end
			else
				version_check = '-1'
				if version_check == '-1' then
					version_status = "error"
					update_error_reason = "Failed to get updates"
				end
			end
		end,
		function (err)
			print(err)
			version_check = '-1'
			if version_check == '-1' then
				version_status = "error"
				update_error_reason = "Connection Failed"
			end
		end)
	end
end

function getSAMPMasterList()
    local masterList = {}
	asyncHttpRequest('GET', 'http://lists.sa-mp.com/0.3.7/internet', nil, function (response)
		if (response.text) ~= nil then
			for str in string.gmatch((response.text),"([^\n\r]+)") do
				table.insert(masterList, str)
			end
		end
			
	end)
    return masterList
end

--[[
asyncHttpRequest('GET', 'https://sadfi2259x.github.io/xezios-project/ads.txt', nil, function (response)
	ad_result = response.text
end)
]]

-- model finder
-- ini cfg
inicfg = require("inicfg")

objectfinder_table_inputs = {
	{1550, ""},
	{19941, ""},
	{11745, ""},
	{2919, ""},
	{1276, ""},
	{19320, ""},
	{19473, ""}
}

ObjectFinder_Table = {}

MainSettingsdirectIni = 'XEZIOS\\XEZIOS_SETTINGS.ini'
ObjectFinderDirectIni = 'XEZIOS\\XEZIOS_OBJ'

ini = inicfg.load(inicfg.load({
	license =  {
		Agree		= false
	},
	WATER_RPG = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },
	functions = {
		GM 					= false,
		NoFall 				= false,
		DeathF 				= false,
		InfinityRun 		= false,
		MegaJump	 		= false,
		AntiStun	 		= false,
		AntiAfk	 			= false,
		InfO2	 			= false,
		Chams	 			= false,
		Fugga	 			= false,
		Invisible	 		= false,
		InvertPlayer2021	= false,
		CrazyPlayer2021		= false,
		FastWalk			= false,
		FastRotation			= false,
		AirBreak			= false,
		
		InfinityAmmo		= false,
		FullSkills			= false,
		NoReload			= false,
		bell				= false,
		Cbug				= false,
		NoSpread			= false,
		SensFix				= false,
		AimBot				= false,
		aimbotproSkipDead	= false,
		aimbotdisabledOnAnim		= false,
		aimbotdisabledIfFriend		= false,
		aimbotdisabledOnAFk			= false,
		aimbotskipDead		= false,
		aimbotteam_ignore	= false,
		aimbotsafeZone		= (1),
		aimbotjobRadius		= (80),
		aimbotsmoothSpeed	= (5),
		aimbotaddSmoothSpeed	= (1),
		SilentAim			= false,
		noCamRestore		= false,
		Rapid				= false,
		--damager				= false,
		--cdamage				= false,
		gtavaim				= false,
		
		GMCar				= false,
		GMWheels				= false,
		Fbike				= false,
		FC					= false,
		Tmode				= false,
		InfinityFuel		= false,
		NoRadio				= false,
		Water				= false,
		CarShot				= false,
		CarJump				= false,
		driftInCar				= false,
		bmx					= false,
		Nitro				= false,
		altspeed			= false,
		InvertVeh2021		= false,
		CrazyVeh2021		= false,
		NameTags			= false,
		
		SkeletalWallHack	= false,
		DisableChangeColorUnderWater	= false,
		DisableUnderWaterEffects	= false,
		DisableWater		= false,
		SUN					= true,
		blur				= false,
		fpsboost			= false,
		fixwater			= true,
		--anticrasher			= false,
		fmoney				= false,
		lmap				= false,
		MEMORY				= false,
		CMEM				= false,
		DrawDist			= false,
		FogDist 			= false,
		LogDist 			= false,
		Time 				= false,
		Weather				= false,
		Fovedit				= false,
		camshake			= false,
		objectwallhack		= false,
		objtraser			= false,
		WaterX				= false,
		driveUnderWater		= false,
		rWater				= false,
		trigger				= false,
		esplines			= false,
		espbox			= false,
		bypass_tp			= false,
		
		imgClickInfState	= false,
		imgSliderInfFov 	= false,
		imgClickInfObj  	= true,
		imgClickInfObj  	= true,
		imgClickInfLine  	= true,
		imgSliderInfBlood  	= (100.0),
		imgSliderInfRand  	= (100.0),
		imgClickinfClist  	= false,
		imgClickinfTorso  	= true,
		imgClickinfGroin  	= false,
		imgClickinfHead  	= false,
		
		fastwalk 		= (1),
		AirBreakSpeed 	= (0.25),
		lengthJump 		= (0.5),
		RapidSpeed		= (1),
		altspeedhack 	= (100),
		pMemory 		= (512),
		pMemSize 		= (50),
		pDrawEdit 		= (800),
		pFogEdit 		= (200),
		pTime			= (1),
		pWeather 		= (1),
		pFovedit 		= (70),
		pCamshake 		= (10),
		pLogEdit 		= (500),
		pspam 			= (0),
		volume 			= (1),
		pWaterSpeed 	= (1),
		weapon_ammo 	= (100),
		
		activekey 		= (0),
		
		chamstype 		= (0),
		radio_cbug 		= (0),
		aimbot_type 		= (0),
		
		receive_sound 	= false,
		sms_in_chat 	= false,
		clean_on_sent 	= false,
		
		ObjectCollision			 = false,
		rvanka					 = false,
		RPName					 = false,
		BlockDrugsAnimation		 = false,
		OVERHP					 = false,
		
	}
}, MainSettingsdirectIni))
inicfg.save(ini, MainSettingsdirectIni)

WATER_RPG = imgui.ImFloat4(ini.WATER_RPG.r, ini.WATER_RPG.g, ini.WATER_RPG.b, ini.WATER_RPG.a)

function settings_ini_save()
	ini.WATER_RPG.r, ini.WATER_RPG.g, ini.WATER_RPG.b, ini.WATER_RPG.a = WATER_RPG.v[1], WATER_RPG.v[2], WATER_RPG.v[3], WATER_RPG.v[4]
	ini.functions.GM = GG_GM.v
	ini.functions.NoFall = GG_NoFall.v
	ini.functions.DeathF = GG_DeathF.v
	ini.functions.InfinityRun = GG_InfinityRun.v
	ini.functions.MegaJump = GG_MegaJump.v
	ini.functions.AntiStun = GG_AntiStun.v
	ini.functions.AntiAfk = GG_AntiAfk.v
	ini.functions.InfO2 = GG_InfO2.v
	ini.functions.Chams = GG_Chams.v
	ini.functions.Fugga = GG_Fugga.v
	ini.functions.Invisible = GG_Invisible.v
	ini.functions.InvertPlayer2021 = GG_InvertPlayer2021.v
	ini.functions.CrazyPlayer2021 = GG_CrazyPlayer2021.v
	ini.functions.AirBreak = GG_AirBreak.v
	ini.functions.FastRotation = GG_FastRotation.v
	
	ini.functions.InfinityAmmo = GG_InfinityAmmo.v
	ini.functions.FullSkills = GG_FullSkills.v
	ini.functions.NoReload = GG_NoReload.v
	ini.functions.bell = GG_bell.v
	ini.functions.Cbug = GG_Cbug.v
	ini.functions.NoSpread = GG_NoSpread.v
	ini.functions.SensFix = GG_SensFix.v
	ini.functions.AimBot = GG_AimBot.v
	ini.functions.aimbotteam_ignore = aimbot.team_ignore.v
	ini.functions.aimbotskipDead = aimbot.skipDead.v
	ini.functions.aimbotdisabledOnAnim = aimbot.disabledOnAnim.v
	ini.functions.aimbotdisabledIfFriend = aimbot.disabledIfFriend.v
	ini.functions.aimbotdisabledOnAFk = aimbot.disabledOnAFk.v
	ini.functions.aimbotproSkipDead = aimbot.proSkipDead.v
	ini.functions.aimbotsafeZone = aimbot.safeZone.v
	ini.functions.aimbotjobRadius = aimbot.jobRadius.v
	ini.functions.aimbotsmoothSpeed = aimbot.smoothSpeed.v
	ini.functions.aimbotaddSmoothSpeed = aimbot.addSmoothSpeed.v
	ini.functions.SilentAim = GG_SilentAim.v
	ini.functions.noCamRestore = GG_noCamRestore.v
	ini.functions.Rapid = GG_Rapid.v
	--ini.functions.damager = GG_damager.v
	--ini.functions.cdamage = GG_cdamage.v
	ini.functions.gtavaim = GG_gtavaim.v
	
	ini.functions.GMCar = GG_GMCar.v
	ini.functions.GMWheels = GG_GMWheels.v
	ini.functions.Fbike = GG_Fbike.v
	ini.functions.FC = GG_FC.v
	ini.functions.Tmode = GG_Tmode.v
	ini.functions.InfinityFuel = GG_InfinityFuel.v
	ini.functions.NoRadio = GG_NoRadio.v
	ini.functions.Water = GG_Water.v
	ini.functions.CarShot = GG_CarShot.v
	ini.functions.CarJump = GG_CarJump.v
	ini.functions.driftInCar = GG_driftInCar.v
	ini.functions.bmx = GG_bmx.v
	ini.functions.Nitro = GG_Nitro.v
	ini.functions.altspeed = GG_altspeed.v
	ini.functions.InvertVeh2021 = GG_InvertVeh2021.v
	ini.functions.CrazyVeh2021 = GG_CrazyVeh2021.v
	ini.functions.NameTags = GG_NameTags.v
	
	ini.functions.SkeletalWallHack = GG_SkeletalWallHack.v
	ini.functions.DisableChangeColorUnderWater = GG_DisableChangeColorUnderWater.v
	ini.functions.DisableUnderWaterEffects = GG_DisableUnderWaterEffects.v
	ini.functions.DisableWater = GG_DisableWater.v
	ini.functions.SUN = GG_SUN.v
	ini.functions.blur = GG_blur.v
	ini.functions.fpsboost = GG_fpsboost.v
	ini.functions.fixwater = GG_fixwater.v
	--ini.functions.anticrasher = GG_anticrasher.v
	ini.functions.fmoney = GG_fmoney.v
	ini.functions.lmap = GG_lmap.v
	ini.functions.MEMORY = GG_MEMORY.v
	ini.functions.CMEM = GG_CMEM.v
	ini.functions.DrawDist = GG_DrawDist.v
	ini.functions.FogDist = GG_FogDist.v
	ini.functions.LogDist = GG_LogDist.v
	ini.functions.Time = GG_Time.v
	ini.functions.Weather = GG_Weather.v
	ini.functions.Fovedit = GG_Fovedit.v
	ini.functions.camshake = GG_camshake.v
	
	ini.functions.objectwallhack = GG_objectwallhack.v
	ini.functions.objtraser = GG_objtraser.v
	ini.functions.WaterX = GG_WaterX.v
	ini.functions.driveUnderWater = GG_driveUnderWater.v
	ini.functions.rWater = GG_rWater.v
	ini.functions.trigger = GG_trigger.v
	ini.functions.esplines = GG_esplines.v
	ini.functions.espbox = GG_espbox.v
	ini.functions.bypass_tp = GG_bypass_tp.v
	
	ini.functions.imgClickInfState = imgClickInfState.v
	ini.functions.imgSliderInfFov = imgSliderInfFov.v
	ini.functions.imgClickInfObj = imgClickInfObj.v
	ini.functions.imgClickInfLine = imgClickInfLine.v
	ini.functions.imgSliderInfBlood = imgSliderInfBlood.v
	ini.functions.imgSliderInfRand = imgSliderInfRand.v
	ini.functions.imgClickinfClist = imgClickinfClist.v
	ini.functions.imgClickinfTorso = imgClickinfTorso.v
	ini.functions.imgClickinfGroin = imgClickinfGroin.v
	ini.functions.imgClickinfHead = imgClickinfHead.v
	
	ini.functions.fastwalk 			= script.fastwalk.v
	ini.functions.AirBreakSpeed 	= script.AirBreakSpeed.v
	ini.functions.lengthJump 		= script.lengthJump.v
	ini.functions.RapidSpeed		= script.RapidSpeed.v
	ini.functions.altspeedhack 		= script.altspeedhack.v
	ini.functions.pMemory	 		= script.pMemory.v
	ini.functions.pMemSize	 		= script.pMemSize.v
	ini.functions.pDrawEdit 		= script.pDrawEdit.v
	ini.functions.pFogEdit 			= script.pFogEdit.v
	ini.functions.pTime				= script.pTime.v
	ini.functions.pWeather 			= script.pWeather.v
	ini.functions.pFovedit 			= script.pFovedit.v
	ini.functions.pCamshake 		= script.pCamshake.v
	ini.functions.pLogEdit 			= script.pLogEdit.v
	ini.functions.pspam 			= script.pspam.v
	ini.functions.volume 			= script.volume.v
	ini.functions.pWaterSpeed 		= script.pWaterSpeed.v
	ini.functions.chamstype 		= script.chamstype.v
	ini.functions.radio_cbug 		= script.radio_cbug.v
	ini.functions.aimbot_type 		= script.aimbot_type.v
	ini.functions.weapon_ammo 		= script.weapon_ammo.v
	
	ini.functions.ObjectCollision 	= GG_ObjectCollision.v
	ini.functions.RPName 			= GG_RPName.v
	ini.functions.rvanka 			= GG_rvanka.v
	ini.functions.BlockDrugsAnimation 	= GG_BlockDrugsAnimation.v
	ini.functions.OVERHP 			= GG_OVERHP.v
	
    inicfg.save(ini, MainSettingsdirectIni)
end

function settings_ini_load()
	WATER_RPG.v[1], WATER_RPG.v[2], WATER_RPG.v[3], WATER_RPG.v[4] = ini.WATER_RPG.r, ini.WATER_RPG.g, ini.WATER_RPG.b, ini.WATER_RPG.a
	GG_GM.v = ini.functions.GM
	GG_NoFall.v = ini.functions.NoFall
	GG_DeathF.v = ini.functions.DeathF
	GG_InfinityRun.v = ini.functions.InfinityRun
	GG_MegaJump.v = ini.functions.MegaJump
	GG_AntiAfk.v = ini.functions.AntiAfk
	GG_InfO2.v = ini.functions.InfO2
	GG_Chams.v = ini.functions.Chams
	GG_InvertPlayer2021.v = ini.functions.InvertPlayer2021
	GG_CrazyPlayer2021.v = ini.functions.CrazyPlayer2021
	GG_FastWalk.v = ini.functions.FastWalk
	GG_AirBreak.v = ini.functions.AirBreak
	GG_FastRotation.v = ini.functions.FastRotation
	
	GG_InfinityAmmo.v = ini.functions.InfinityAmmo
	GG_FullSkills.v = ini.functions.FullSkills
	GG_NoReload.v = ini.functions.NoReload
	GG_bell.v = ini.functions.bell
	GG_Cbug.v = ini.functions.Cbug
	GG_NoSpread.v = ini.functions.NoSpread
	GG_SensFix.v = ini.functions.SensFix
	GG_AimBot.v = ini.functions.AimBot
	aimbot.team_ignore.v = ini.functions.aimbotteam_ignore
	aimbot.proSkipDead.v = ini.functions.aimbotproSkipDead
	aimbot.skipDead.v = ini.functions.aimbotskipDead
	aimbot.disabledOnAnim.v = ini.functions.aimbotdisabledOnAnim
	aimbot.disabledIfFriend.v = ini.functions.aimbotdisabledIfFriend
	aimbot.disabledOnAFk.v = ini.functions.aimbotdisabledOnAFk
	aimbot.safeZone.v = ini.functions.aimbotsafeZone
	aimbot.jobRadius.v = ini.functions.aimbotjobRadius
	aimbot.smoothSpeed.v = ini.functions.aimbotsmoothSpeed
	aimbot.addSmoothSpeed.v = ini.functions.aimbotaddSmoothSpeed
	GG_SilentAim.v = ini.functions.SilentAim
	GG_noCamRestore.v = ini.functions.noCamRestore
	GG_Rapid.v = ini.functions.Rapid
	--GG_damager.v = ini.functions.damager
	--GG_cdamage.v = ini.functions.cdamage
	GG_gtavaim.v = ini.functions.gtavaim
	
	GG_GMCar.v = ini.functions.GMCar
	GG_GMWheels.v = ini.functions.GMWheels
	GG_Fbike.v = ini.functions.Fbike
	GG_FC.v = ini.functions.FC
	GG_Tmode.v = ini.functions.Tmode
	GG_InfinityFuel.v = ini.functions.InfinityFuel
	GG_NoRadio.v = ini.functions.NoRadio
	GG_Water.v = ini.functions.Water
	GG_CarShot.v = ini.functions.CarShot
	GG_CarJump.v = ini.functions.CarJump
	GG_driftInCar.v = ini.functions.driftInCar
	GG_bmx.v = ini.functions.bmx
	GG_Nitro.v = ini.functions.Nitro
	GG_altspeed.v = ini.functions.altspeed
	GG_InvertVeh2021.v = ini.functions.InvertVeh2021
	GG_CrazyVeh2021.v = ini.functions.CrazyVeh2021
	GG_NameTags.v = ini.functions.NameTags
	
	GG_SkeletalWallHack.v = ini.functions.SkeletalWallHack
	GG_DisableChangeColorUnderWater.v = ini.functions.DisableChangeColorUnderWater
	GG_DisableUnderWaterEffects.v = ini.functions.DisableUnderWaterEffects
	GG_DisableWater.v = ini.functions.DisableWater
	GG_SUN.v = ini.functions.SUN
	GG_blur.v = ini.functions.blur
	GG_fpsboost.v = ini.functions.fpsboost
	GG_fixwater.v = ini.functions.fixwater
	--GG_anticrasher.v = ini.functions.anticrasher
	GG_fmoney.v = ini.functions.fmoney
	GG_lmap.v = ini.functions.lmap
	GG_MEMORY.v = ini.functions.MEMORY
	GG_CMEM.v = ini.functions.CMEM
	GG_DrawDist.v = ini.functions.DrawDist
	GG_FogDist.v = ini.functions.FogDist
	GG_LogDist.v = ini.functions.LogDist
	GG_Weather.v = ini.functions.Weather
	GG_Fovedit.v = ini.functions.Fovedit
	GG_camshake.v = ini.functions.camshake
	
	GG_objectwallhack.v = ini.functions.objectwallhack
	GG_objtraser.v = ini.functions.objtraser
	GG_WaterX.v = ini.functions.WaterX
	GG_driveUnderWater.v = ini.functions.driveUnderWater
	GG_rWater.v = ini.functions.rWater
	GG_trigger.v = ini.functions.trigger
	GG_esplines.v = ini.functions.esplines
	GG_espbox.v = ini.functions.espbox
	GG_bypass_tp.v = ini.functions.bypass_tp
	
	imgClickInfState.v = ini.functions.imgClickInfState
	imgSliderInfFov.v = ini.functions.imgSliderInfFov
	imgClickInfObj.v = ini.functions.imgClickInfObj
	imgClickInfLine.v = ini.functions.imgClickInfLine
	imgSliderInfBlood.v = ini.functions.imgSliderInfBlood
	imgSliderInfRand.v = ini.functions.imgSliderInfRand
	imgClickinfClist.v = ini.functions.imgClickinfClist
	imgClickinfTorso.v = ini.functions.imgClickinfTorso
	imgClickinfGroin.v = ini.functions.imgClickinfGroin
	imgClickinfHead.v = ini.functions.imgClickinfHead
	
	script.fastwalk.v = ini.functions.fastwalk
	script.AirBreakSpeed.v = ini.functions.AirBreakSpeed 
	script.lengthJump.v = ini.functions.lengthJump 
	script.RapidSpeed.v = ini.functions.RapidSpeed
	script.altspeedhack.v = ini.functions.altspeedhack
	script.pMemory.v = ini.functions.pMemory
	script.pMemSize.v = ini.functions.pMemSize
	script.pDrawEdit.v = ini.functions.pDrawEdit
	script.pFogEdit.v = ini.functions.pFogEdit
	script.pTime.v = ini.functions.pTime
	script.pWeather.v = ini.functions.pWeather
	script.pFovedit.v = ini.functions.pFovedit
	script.pCamshake.v = ini.functions.pCamshake
	script.pLogEdit.v = ini.functions.pLogEdit
	script.pspam.v = ini.functions.pspam
	script.volume.v = ini.functions.volume
	script.chamstype.v = ini.functions.chamstype
	script.radio_cbug.v = ini.functions.radio_cbug
	script.aimbot_type.v = ini.functions.aimbot_type
	script.pWaterSpeed.v = ini.functions.pWaterSpeed
	script.weapon_ammo.v = ini.functions.weapon_ammo
	
	GG_ObjectCollision.v = ini.functions.ObjectCollision 
	GG_RPName.v = ini.functions.RPName 
	GG_rvanka.v = ini.functions.rvanka 
	GG_BlockDrugsAnimation.v = ini.functions.BlockDrugsAnimation 		
	GG_OVERHP.v = ini.functions.OVERHP 
end

function GetActiveKey()
	script.activekey.v = ini.functions.activekey
end

function GetSMSsettings()
	script.receive_sound.v = ini.functions.receive_sound
	script.sms_in_chat.v = ini.functions.sms_in_chat
	script.clean_on_sent.v = ini.functions.clean_on_sent
end

imgClickInfState = imgui.ImBool(false)
imgSliderInfFov = imgui.ImFloat(100.0)
imgClickInfObj = imgui.ImBool(true)
imgClickInfVeh = imgui.ImBool(true)
imgClickInfLine = imgui.ImBool(true)
imgSliderInfBlood = imgui.ImFloat(100.0)
imgSliderInfRand = imgui.ImFloat(100.0)
imgClickinfClist = imgui.ImBool(false)

imgClickinfTorso = imgui.ImBool(true)
imgClickinfGroin = imgui.ImBool(false)
imgClickinfHead = imgui.ImBool(false)

function DisableAllBody(tr, gr, hd)
    imgClickinfTorso.v = tr
	imgClickinfGroin.v = gr
 	imgClickinfHead.v = hd
end

function StartInKey()
    tarPed = -1
	imgClickInfState.v = not imgClickInfState.v
end

function samp.onSendAimSync(data)
    camMode = data.camMode
	if imgClickInfState.v then
	
	weap = getCurrentCharWeapon(PLAYER_PED)
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	
	if weap ~= nil and GetWeaponOkay(weap) and not isCharDead(PLAYER_PED) and not sampIsPlayerPaused(id) then
	    camX = data.camPos.x
		camY = data.camPos.y
		camZ = data.camPos.z
		
		frontX = data.camFront.x
		frontY = data.camFront.y
		frontZ = data.camFront.z
		CheckTarget()
	end
	end
end

function samp.onSendBulletSync(data)
 	if imgClickInfState.v and tarPed ~= -1 and stopwork ~= 1 and data.targetType ~= 1 and data.weaponId ~= nil and GetWeaponOkay(data.weaponId) then
    local result, id = sampGetPlayerIdByCharHandle(tarPed)

	if result then
	    respol = 0
	    if imgClickinfClist.v then
	        local _, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	 	    color0 = sampGetPlayerColor(mid)
	 	    color1 = sampGetPlayerColor(id)
	 	    if color0 ~= nil and color1 ~= nil and color0 == color1 then respol = 1 end
	 	end
	    if respol == 0 then
			local posX, posY, posZ = getCharCoordinates(tarPed)
			local mposX, mposY, mposZ = getCharCoordinates(PLAYER_PED)
			
			dist = getDistanceBetweenCoords3d(mposX, mposY, mposZ, posX, posY, posZ)
			wdist = GetWeaponDist(data.weaponId)

            rand = imgSliderInfRand.v
		    if rand ~= nil and dist ~= nil and wdist ~= nil and dist > 0 and dist < wdist and math.random(100) < rand and isCharDead(tarPed) == false and sampIsPlayerPaused(id) == false then

				randX = RandomFloat(-0.25, 0.25)
				randY = RandomFloat(-0.25, 0.25)
				randZ = RandomFloat(-0.80, 0.80)
				
				if math.abs(randX) < 0.01 then randX = 0.01 end
				if math.abs(randY) < 0.01 then randY = 0.01 end
				if math.abs(randZ) < 0.01 then randZ = 0.01 end

				data.targetType = 1
				data.targetId = id
				data.origin = {x = mposX + randX, y = mposY + randY, z = mposZ + randZ}
			    data.target = {x = posX + randX, y = posY + randY, z = posZ + randZ}
				data.center = {x = randX, y = randY, z = randZ}

				local body
				local diff
				if imgClickinfHead.v then body = 9 diff = RandomFloat(0.7, 0.8)
				elseif imgClickinfGroin.v then body = 4 diff = RandomFloat(-0.3, -0.2)
				else body = 3 diff = RandomFloat(-0.1, 0.6) end
				
				sampSendGiveDamage(id, GetWeaponDamage(data.weaponId), data.weaponId, body)
				if imgClickInfLine.v then fireSingleBullet(mposX, mposY, mposZ + RandomFloat(0.5, 0.7), posX + randX, posY + randY, posZ + diff, 1) end
				if imgSliderInfBlood.v > 0 then addBlood(posX + randX, posY + randY, posZ + diff, 0.0, 0.0, 0.0, imgSliderInfBlood.v, tarPed) end
			end
		end
	end
	end
end

function CheckTarget()
	mped = getAllChars()
	local mposX, mposY, mposZ = getCharCoordinates(PLAYER_PED)
	
	tdist = imgSliderInfFov.v
	weap = getCurrentCharWeapon(PLAYER_PED)
    wdist = GetWeaponDist(weap)
    
    if tdist == nil or weap == nil or wdist == nil then return end
    
	tarPed = -1
	for _, ped in pairs(mped) do
	if ped ~= PLAYER_PED then
	
		local posX, posY, posZ = getCharCoordinates(ped)
		if isLineOfSightClear(mposX, mposY, mposZ, posX, posY, posZ, not imgClickInfObj.v, not imgClickInfVeh.v, false, not imgClickInfObj.v, false) then

		local result, id = sampGetPlayerIdByCharHandle(ped)
		if result then
		
		ndist = FacingToCoords(posX, posY, tdist)
		dist = getDistanceBetweenCoords3d(mposX, mposY, mposZ, posX, posY, posZ)

		if ndist ~= nil and dist ~= nil and ndist < tdist and dist and dist < wdist and not isCharDead(ped) and not sampIsPlayerPaused(id) then
		    tarPed = ped
		    tdist = ndist
		end
		end
		end
	end
	end
end

function RandomFloat(low, great)
    return low + math.random() * (great - low)
end

function VectorySize(amount1, amount2, amount3)
	return math.sqrt(amount1 * amount1 + amount2 * amount2, amount3 * amount3)
end

function GetWeaponOkay(weap)
	if weap >= 22 and weap <= 34 or weap == 38 then return 1 end
	return 0
end

function GetWeaponName(weap)
	namearray =
	{
	    [22] = "9mm",
	    [23] = "Silenced 9mm",
	    [24] = "Desert Eagle",
	    [25] = "Shotgun",
	    [26] = "Sawnoff Shotgun",
	    [27] = "Combat Shotgun",
	    [28] = "Micro SMG/Uzi",
	    [29] = "MP5",
	    [30] = "AK-47",
	    [31] = "M4",
	    [32] = "Tec-9",
	    [33] = "Country Rifle",
	    [34] = "Sniper Rifle",
	    [38] = "Minigun"
	}
	return namearray[weap]
end

function GetWeaponDamage(weap)
    dmgarray =
    {
        [22] = 8.25,
        [23] = 13.2,
        [24] = 46.2,
        [25] = 3.3,
        [26] = 3.3,
        [27] = 4.95,
        [28] = 6.6,
        [29] = 8.25,
        [30] = 9.9,
        [31] = 9.9,
        [32] = 6.6,
        [33] = 24.75,
        [34] = 41.25,
        [38] = 46.2
    }
    return dmgarray[weap]
end

function GetWeaponDist(weap)
	distarray =
	{
		[22] = 35.0,
		[23] = 35.0,
		[24] = 35.0,
		[25] = 40.0,
		[26] = 35.0,
		[27] = 40.0,
		[28] = 35.0,
		[29] = 45.0,
		[30] = 70.0,
		[31] = 90.0,
		[32] = 35.0,
		[33] = 95.0,
        [34] = 320.0,
        [38] = 75.0
	}
	return distarray[weap]
end

function FacingToCoords(posX, posY, ang)
    local vecX = camX + (frontX * 50.0)
    local vecY = camY + (frontY * 50.0)
    local mposX, mposY, mposZ = getCharCoordinates(PLAYER_PED)
    
    dist = VectorySize(mposX - posX, mposY - posY, 0.0)
    ndist = 7.0 - (dist / 5)
    if ndist < 0.0 then ndist = 0.0 end
    
    uang = math.atan2(mposX - vecX, mposY - vecY)
	tang = math.atan2(mposX - posX, mposY - posY)
	ugrad = math.deg(uang) + ndist
	tgrad = math.deg(tang)

	if tgrad - ang < ugrad and tgrad + ang > ugrad then
        if ugrad > tgrad then return ugrad - tgrad
        else return tgrad - ugrad end
	end
    return nil
end

function CalculateQuat(rotX, rotY, rotZ)
    b = rotX * math.pi / 360.0
    h = rotY * math.pi / 360.0
    a = rotZ * math.pi / 360.0
    
    local c1, c2, c3 = math.cos(h), math.cos(a), math.cos(b)
    local s1, s2, s3 = math.sin(h), math.sin(a), math.sin(b)
    
    qw = c1 * c2 * c3 - s1 * s2 * s3
    qx = s1 * s2 * c3 + c1 * c2 * s3
    qy = s1 * c2 * c3 + c1 * s2 * s3
    qz = c1 * s2 * c3 - s1 * c2 * s3
    return qw, qx, qy, qz
end
-- RUN BOT

--[[ EXAMPLE
local result = locateCharAnyMeans2d(PLAYER_PED, -172.8133, 363.1907, 6.5, 4.0, false)
if not result then
	BeginToPoint(1388,  1517,  10, 0.7, -255, true)
end
--]]

function BeginToPoint(x, y, z, radius, move_code, isSprint) -- 
    repeat
        local posX, posY, posZ = GetCoordinates()
        dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        setAngle(x, y, dist, 0.08)
        MovePlayer(move_code, isSprint)
        wait(0)
    until dist < radius
end

function MovePlayer(move_code, isSprint)
    setGameKeyState(1, move_code)
    --[[255 - обычный бег назад
       -255 - обычный бег вперед
      65535 - идти шагом вперед
    -65535 - идти шагом назад]]
    if isSprint then setGameKeyState(16, 255) end
end

function setAngle(x, y, distance, speed)
    source_x = fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))
    source_z = fix(representIntAsFloat(readMemory(0xB6F258, 4, false))) + math.pi
    angle = GetAngleBeetweenTwoPoints(x,y) - source_z - math.pi

    if distance > 1.8 then
        if angle > -0.1 and angle < 0.03 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -5.7 and angle > -5.93 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -6.0 and angle > -6.4 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle > 0.04 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        elseif angle < -3.5 and angle > -5.67 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        else setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))-speed)
        end
    else setCameraPositionUnfixed(source_x, GetAngleBeetweenTwoPoints(x,y)) end
end

function GetCoordinates()
    if isCharInAnyCar(playerPed) then
        car = storeCarCharIsInNoSave(playerPed)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(playerPed)
    end
end

function GetAngleBeetweenTwoPoints(x2,y2)
    local x1, y1, z1 = getCharCoordinates(playerPed)
    plus = 0.0
    mode = 1
    if x1 < x2 and y1 > y2 then plus = math.pi/2; mode = 2; end
    if x1 < x2 and y1 < y2 then plus = math.pi; end
    if x1 > x2 and y1 < y2 then plus = math.pi*1.5; mode = 2; end
    local lx = x2 - x1
    local ly = y2 - y1
    lx = math.abs(lx)
    ly = math.abs(ly)
    if mode == 1 then ly = ly/lx;
    else ly = lx/ly; end 
    ly = math.atan(ly)
    ly = ly + plus
    return ly
end
-- injection
injectfiletype = '.dll'
--------------------------------------------------

function message(text)
	return sampAddChatMessage(text, 0xFF0000)
end

sampanim =
{
	["PISS"]           						= "68",
	["JETPACK"]           					= "2",
	["DANCE1"]           					= "5",
	["DANCE2"]           					= "8",
	["HANDSUP"]           					= "10",
	["USE_PHONE"]           				= "11",
	["GET BEER"]           					= "20",
	["GET WINE"]          					= "22",
	["GET SPRUNK"]           				= "23",
	["GET SIGAR"]           				= "21",
	["CUFFED"]           					= "24",
	["CARRY"]           					= "25",
}

ToggleButtons = {
	{"GM"},
	{"NoFall"},
	{"DeathF"},
	{"InfinityRun"},
	{"MegaJump"},
	{"AntiStun"},
	{"AntiAfk"},
	{"Fugga"},
	{"InfO2"},
	{"Chams"},
	{"Invisible"},
	{"InvertPlayer2021"},
	{"CrazyPlayer2021"},
	{"FastWalk"},
	{"FastRotation"},
	{"AirBreak"},
	{"InfinityAmmo"},
	{"FullSkills"},
	{"NoReload"},
	{"bell"},
	{"Cbug"},
	{"NoSpread"},
	{"SensFix"},
	{"AimBot"},
	{"noCamRestore"},
	{"SilentAim"},
	{"Rapid"},
	{"damager"},
	{"cdamage"},
	{"gtavaim"},
	{"GMCar"},
	{"GMWheels"},
	{"Fbike"},
	{"Fbike"},
	{"FC"},
	{"Tmode"},
	{"InfinityFuel"},
	{"NoRadio"},
	{"driveUnderWater"},
	{"Water"},
	{"CarShot"},
	{"CarJump"},
	{"bmx"},
	{"Nitro"},
	{"driftInCar"},
	{"altspeed"},
	{"InvertVeh2021"},
	{"CrazyVeh2021"},
	{"NameTags"},
	{"SkeletalWallHack"},
	{"DisableChangeColorUnderWater"},
	{"DisableUnderWaterEffects"},
	{"DisableWater"},
	{"SUN"},
	{"FPS"},
	{"blur"},
	{"fpsboost"},
	{"fixwater"},
	{"anticrasher"},
	{"fmoney"},
	{"lmap"},
	{"MEMORY"},
	{"CMEM"},
	{"DrawDist"},
	{"FogDist"},
	{"LogDist"},
	{"Time"},
	{"Weather"},
	{"Fovedit"},
	{"camshake"},
	{"spam"},
	{"bspam"},
	{"objectwallhack"},
	{"objtraser"},
	{"WaterX"},
	{"rWater"},
	{"trigger"},
	{"esplines"},
	{"espbox"},
	{"bypass_tp"},
	{"WetRoads"},
	{"SandParticle"},
	{"BladeCollision"},
	{"SpeedLimit"},
	{"RailsResistance"},
	{"SpawnFix"},
	{"PauseMenuFix"},
	{"AirCraftExplosionFix"},
	{"HydraSniper"},
	{"ClickMap"},
	{"MainTheme"},
	{"ObjectCollision"},
	{"BlockDrugsAnimation"},
	{"RPName"},
	{"rvanka"},
	{"OVERHP"},
}

for k, v in pairs(ToggleButtons) do
    _G['GG_'..v[1]] = imgui.ImBool(false)
end

local CPed_stat = {70, 71, 72, 76, 77, 78, 79}
local trigger_osclock = os.clock()

UpdateLog = { 
	--[[
	"- Advanced Aim (Bot, Pro, Smooth)\n", 
	"- Advanced +C (auto, falst, helper)\n", 
	"- New Visual Functions (chams, esp box)\n", 
	"- Fixed Anti AFK\n", 
	"- Fixed Infinity Run\n", 
	"- Fixed Vehicle SpeedHack\n", 
	"- Fixed Update Checker\n", 
	"- New Rvanka\n", 
	"- New InfinityRun Oxygen\n", 
	"- New Drift function\n", 
	"- New Wheels God Mode\n", 
	"- New No Camera Restore\n", 
	"- Better update system\n", 
	"- New Animated Gui", 
	]]
	"- Fixed,Improuved & Advanced Update system\n", 
	"- New settings panel", 
}

script =
{
	start_updating  = false,
	discord_url     = ("https://bit.ly/xeziosdiscord"),
	update_url     	= ("https://sadfi2259x.github.io/xezios-project/xezios.rar"),
	site_url	    = ("https://sadfi2259x.github.io/xezios-project/"),
	window 			= imgui.ImBool(false),
	admin_panel 	= imgui.ImBool(ADMIN_MODE),
	sms_window		= imgui.ImBool(false),
	iHUD 			= imgui.ImBool(false),
	vHUD 			= imgui.ImBool(false),
	cHUD 			= imgui.ImBool(false),
	StaminaHUD 		= imgui.ImBool(false),
	page			= 8,
	sadfi_avatar 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\about\\devlopers\\30\\sadfi.png"),
	remi_avatar 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\about\\devlopers\\30\\remi.png"),
	chapo_avatar 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\about\\devlopers\\30\\chapo.png"),
	icon_check	 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\icons\\check.png"),
	icon_out	 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\icons\\out.png"),
	icon_error	 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\icons\\error.png"),
	icon_unknow	 	= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\icons\\unknow.png"),
	fastwalk 		= imgui.ImInt(1),
	lengthJump 	= imgui.ImFloat(0.25),
	AirBreakSpeed 	= imgui.ImFloat(0.25),
	RapidSpeed		= imgui.ImInt(1),
	altspeedhack 	= imgui.ImInt(100),
	pMemory 		= imgui.ImInt(512),
	pMemSize 		= imgui.ImInt(50),
	pDrawEdit 		= imgui.ImInt(800),
	pFogEdit 		= imgui.ImInt(200),
	pTime			= imgui.ImInt(1),
	pWeather 		= imgui.ImInt(1),
	pFovedit 		= imgui.ImInt(70),
	pCamshake 		= imgui.ImInt(10),
	pLogEdit 		= imgui.ImInt(500),
	ip1 			= imgui.ImBuffer(50),
	name1 			= imgui.ImBuffer(25),
	port1 			= imgui.ImBuffer(10),
	pspam 			= imgui.ImInt(0),
	textspam   	    = imgui.ImBuffer(1000),
	volume 			= imgui.ImInt(1),
	radio_button    = imgui.ImInt(0),
	radio_cbug      = imgui.ImInt(0),
	aimbot_type      = imgui.ImInt(0),
	healthimg 		= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\icons\\health.png"),
	armourimg		= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\icons\\armour.png"),
	sprintimg 		= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\icons\\sprint.png"),
	breathimg 		= imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\icons\\breath.png"),
	pWaterSpeed 	= imgui.ImInt(1),
	injectortype 	= imgui.ImInt(0),
	chamstype   	= imgui.ImInt(0),
	activekey	 	= imgui.ImInt(0),
	weapon_ammo 	= imgui.ImInt(100),
	unlock_carID 	= imgui.ImBuffer(11),
	warp_carID 		= imgui.ImBuffer(11),
	get_carID 		= imgui.ImBuffer(11),
	explode_carID	= imgui.ImBuffer(11),
	weapons_path	= (getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\picker\\weapons\\"),
	peds_path 		= (getGameDirectory() .. "\\moonloader\\XEZIOS\\textures\\hud\\picker\\peds\\"),
	NextStep 		= imgui.ImInt(1),
	-- sms
	message_input		= imgui.ImBuffer(80),
	handle_input		= imgui.ImBuffer(21),
	clean_on_sent		= imgui.ImBool(false),
	receive_sound		= imgui.ImBool(false),
	sms_in_chat			= imgui.ImBool(false),
	messages_color 		= imgui.ImInt(0),
	readdy 				= false,
	nops_page 			= 1,
	nops_filter	 		= imgui.ImBuffer(256),
	bypass 				= false,
	Skin_Editor			= false,
	SettingsLEFT		= false,
	skins_filter	 	= imgui.ImBuffer(256),
}

local lastsmooth = -1
aimbot = {
	team_ignore 		= imgui.ImBool(false),
	proSkipDead 		= imgui.ImBool(false),
	skipDead 			= imgui.ImBool(false),
	disabledOnAnim 		= imgui.ImBool(false),
	disabledIfFriend 	= imgui.ImBool(false),
	disabledOnAFk 		= imgui.ImBool(false),
	safeZone 			= imgui.ImFloat(1.0),
	jobRadius 			= imgui.ImFloat(80.0),
	smoothSpeed			= imgui.ImFloat(5.0),
	addSmoothSpeed 		= imgui.ImFloat(1.0)
}

weapons_pictures = {}
ped_pictures = {}

--[[ 

vertical_Slider = imgui.ImInt(5)
imgui.VSliderInt('vertical slider', imgui.ImVec2(50, 200), script.vertical_Slider, 0, 10)

--]]

keys =
{
	quick_teleport1 = 0x58,  -- X
	quick_teleport2 = 0x59,  -- Y
}

teleporter =
{
	quick_teleport = imgui.ImBool(false),
	current_btn    = 1,
	current_coords = imgui.ImBool(false),
	auto_z		   = imgui.ImBool(false),
	show           = imgui.ImBool(false),
	shotcut 	   = imgui.ImBool(false),
	coords  	   = imgui.ImBuffer(10000), --24
	location_name  = imgui.ImBuffer(24),
	search_text    = imgui.ImBuffer(60),
	radio_button   = imgui.ImInt(0),
}

function LoadJson(filename)
    full_path = getWorkingDirectory() .."/XEZIOS/config/teleport/".. filename .. ".json"
    if doesFileExist(full_path) then
        file = io.open(full_path, "r")
        local table = decodeJson(file:read("*a"))
        file:close()
        return table
    end
    return {}
end

function SaveJson(filename,table)
    full_path = getWorkingDirectory() .. "/XEZIOS/config/teleport/".. filename .. ".json"
    local file = assert(io.open(full_path, "w"))
    file:write(encodeJson(table))
    file:close()
end

coordinates = LoadJson("Teleporter")

function Teleport(x, y, z,interior_id)
	if GG_bypass_tp.v then
		if script.bypass == false then
			lua_thread.create(function()
				script.bypass = true
				
				wait(500)
				
				if interior_id == nil then interior_id = 0 end

				if x == nil then
					_, x,y,z = getTargetBlipCoordinates()
					interior_id = 0
				end

				if interior_id == 0 then
					z = z + 3
				end

				if teleporter.auto_z.v then
					z = getGroundZFor3dCoord(x,y,z)
				end

				setCharInterior(PLAYER_PED,interior_id)
				setInteriorVisible(interior_id)
				clearExtraColours(true)
				requestCollision(x,y)
				activateInteriorPeds(true)
				setCharCoordinates(PLAYER_PED,x,y,z)
				loadScene(x,y,z)
				
				wait(500)
				
				script.bypass = false
			end)
		elseif script.bypass == true then
			if interior_id == nil then interior_id = 0 end

			if x == nil then
				_, x,y,z = getTargetBlipCoordinates()
				interior_id = 0
			end

			if interior_id == 0 then
				z = z + 3
			end

			if teleporter.auto_z.v then
				z = getGroundZFor3dCoord(x,y,z)
			end

			setCharInterior(PLAYER_PED,interior_id)
			setInteriorVisible(interior_id)
			clearExtraColours(true)
			requestCollision(x,y)
			activateInteriorPeds(true)
			setCharCoordinates(PLAYER_PED,x,y,z)
			loadScene(x,y,z)
		end
	else
		if interior_id == nil then interior_id = 0 end

		if x == nil then
			_, x,y,z = getTargetBlipCoordinates()
			interior_id = 0
		end

		if interior_id == 0 then
			z = z + 3
		end

		if teleporter.auto_z.v then
			z = getGroundZFor3dCoord(x,y,z)
		end

		setCharInterior(PLAYER_PED,interior_id)
		setInteriorVisible(interior_id)
		clearExtraColours(true)
		requestCollision(x,y)
		activateInteriorPeds(true)
		setCharCoordinates(PLAYER_PED,x,y,z)
		loadScene(x,y,z)
	end
end

function ShowEntry(label, x, y, z,interior_id)
	if imgui.MenuItem(label, "", false, true) then
		Teleport(x, y, z,interior_id)
	end
	imgui.Hint("Right click over any of these entries to remove them")
	if imgui.IsItemClicked(1) then
		coordinates[label] = nil
		SaveJson("Teleporter",coordinates)
		coordinates = LoadJson("Teleporter")
		--printHelpString("Entry ~r~removed")
	end
end

function TeleportBtn()
	local x, y, z = getCharCoordinates(PLAYER_PED)
	imgui.Text(string.format("Player coordinates: %d"..",".." %d"..",".." %d ",  math.floor(x) ,  math.floor(y) ,  math.floor(z)))
	imgui.Text("Player location: "..calculateZone(x, y, z))
	imgui.Separator()
	imgui.Columns(2, nil, false)
	imgui.Checkbox("Quick teleport",  teleporter.quick_teleport)
	imgui.HintTooltip("Teleport to marker using (X + Y) key combinartion")
	imgui.Checkbox("Get ground coord",  teleporter.auto_z)
	imgui.HintTooltip("Get Z ground coordinates of your coordinates")
	imgui.NextColumn()
	imgui.Checkbox("ByPass teleport",  GG_bypass_tp)
	imgui.HintTooltip("bypass the anticheat when teleport")
	imgui.Checkbox("Insert coordinates",  teleporter.current_coords)
	imgui.HintTooltip("Automatically inserts coordinates in the text field")
	imgui.Columns(1)

	if imgui.InputText("Coordinates", teleporter.coords) then
	end
	if teleporter.current_coords.v then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		teleporter.coords.v = string.format("%d,  %d,  %d",  math.floor(x) ,  math.floor(y) ,  math.floor(z))
	end
	imgui.HintTooltip("Enter XYZ coordinates.\nFormat : X, Y, Z")

	if imgui.Button(fa.ICON_MAP.." Teleport to coord", imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 30)) then
		x,y,z = teleporter.coords.v:match("([^,]+),([^,]+),([^,]+)")
		Teleport(x,y,z,nil)
	end
	imgui.SameLine()
	if imgui.Button(fa.ICON_MAP_MARKER.." Teleport to marker", imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 30)) then
		Teleport()
	end
	goto_list()
end

function goto_list()
	imgui.BeginChild("teleport_list", imgui.ImVec2(0, 0), true)
		imgui.TextColoredRGB("Warp to player (You can't warp to a NPC)")
		imgui.Separator()
		for i = 0, sampGetMaxPlayerId(false) do
			if local_player_id ~= i and sampIsPlayerConnected(i) then
				tp_color = sampGetPlayerColor(i)
				local tp_aa, tp_rr, tp_gg, tp_bb = explode_argb(tp_color)
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4((tp_rr / 255), (tp_gg / 255), (tp_bb / 255), (tp_aa / 255)))
				if imgui.MenuItem("["..i.."] "..sampGetPlayerNickname(i),nil,false,true) then 
					local result, posXwarp, posYwarp, posZwarp = sampGetStreamedOutPlayerPos(i)  
					if GG_bypass_tp.v then
						if script.bypass == false then
							lua_thread.create(function()
								script.bypass = true
								wait(500)
								setCharCoordinates(PLAYER_PED, posXwarp, posYwarp, posZwarp)
								wait(500)
								script.bypass = false
							end)
						elseif script.bypass == true then
							setCharCoordinates(PLAYER_PED, posXwarp, posYwarp, posZwarp)
						end
					else
						setCharCoordinates(PLAYER_PED, posXwarp, posYwarp, posZwarp)
					end
				end ; imgui.NextColumn()
				imgui.PopStyleColor(1)
			end
		end
	imgui.EndChild()	
end

function SearchBtn()
	imgui.InputText("##Search..", teleporter.search_text)
	imgui.SameLine()
	imgui.BeginGroup()
	if teleporter.search_text.v == '' then
		imgui.SetCursorPosX(10)
		imgui.TextDisabled('Search')
	end
	imgui.EndGroup()
	imgui.Separator()
	imgui.Spacing()
	if imgui.BeginChild("##teleport_Entries", true) then
		for name, coord in pairs(coordinates) do
			local interior_id, x, y, z = coord:match("([^, ]+), ([^, ]+), ([^, ]+), ([^, ]+)")
			if teleporter.search_text.v == "" then
				ShowEntry(name, tonumber(x), tonumber(y), tonumber(z),interior_id)
			else
				if string.find(string.lower(name), string.lower(teleporter.search_text.v), 1, true) then
				
				--if string.upper(name):find(string.upper(teleporter.search_text.v)) ~= nil  then
					ShowEntry(name, tonumber(x), tonumber(y), tonumber(z),interior_id)
				end
			end
		end
		imgui.EndChild()
	end
end

function CustomBtn()
	imgui.Columns(1)
	if imgui.InputText("Location name", teleporter.location_name) then end
	if imgui.InputText("Coordinates", teleporter.coords) then end
	imgui.HintTooltip("Enter XYZ coordinates.\nFormat : X,Y,Z")
	if teleporter.current_coords.v == true then
		local x,y,z = getCharCoordinates(PLAYER_PED)			
		teleporter.coords.v = string.format("%d, %d, %d", math.floor(x) , math.floor(y) , math.floor(z))
	end
	if imgui.Button("Save location", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then
		coordinates[teleporter.location_name.v] = string.format("%d, %s",getActiveInterior(), teleporter.coords.v)   
		SaveJson("Teleporter",coordinates)
		coordinates = LoadJson("Teleporter")
		--printHelpString("Entry ~g~added")
	end
	imgui.Separator()
	imgui.TextWrapped("Go to 'Search' and right-click on the coordinate that you want remove it")
end

function ChangerSkinNewEdition(skin_id)
	requestModel(skin_id)
	loadAllModelsNow()
	setPlayerModel(PLAYER_HANDLE, skin_id)
end

smallversiontext = nil
titlefont = nil
descfont = nil
inputfont = nil
connectfont = nil
chatinsertfont = nil
leftbar_size = nil
fontsize = nil
titlesize = nil
timefont = nil
TermFont = nil
AnswerFont = nil
QueFont = nil
ToggleButton_Font = nil
fa_size = nil
fa_font = nil
fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
		if doesFileExist(getWorkingDirectory() .."/XEZIOS/fonts/fontawesome-webfont.ttf") then
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .."/XEZIOS/fonts/fontawesome-webfont.ttf", 14.0, font_config, fa_glyph_ranges)
		else
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 14.0, font_config, fa_glyph_ranges)
		end
	end
	if fa_size == nil then
		if doesFileExist(getWorkingDirectory().."/lib/fontawesome-webfont.ttf") then
			fa_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory().."/lib/fontawesome-webfont.ttf", 32, nil, fa_glyph_ranges)
		end
	end
	if leftbar_size == nil then
        leftbar_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 31, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 19.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if titlesize == nil then
        titlesize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if timefont == nil then
        timefont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if QueFont == nil then
        QueFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if TermFont == nil then
        TermFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 16, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if AnswerFont == nil then
        AnswerFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 14, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if ToggleButton_Font == nil then
        ToggleButton_Font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if titlefont == nil then
        titlefont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 35.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if smallversiontext == nil then
        smallversiontext = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 12.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if descfont == nil then
        descfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 16.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if inputfont == nil then
        inputfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 47.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if connectfont == nil then
        connectfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
	if chatinsertfont == nil then
        chatinsertfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end

function imgui.OnDrawFrame()
	local iScreenWidth, iScreenHeight = getScreenResolution()
	if script.window.v or script.sms_window.v then
		if script.iHUD.v then
			imgui.ShowCursor = true
		end
		if script.vHUD.v then
			imgui.ShowCursor = true
		end
		if script.cHUD.v then
			imgui.ShowCursor = true
		end
		if script.StaminaHUD.v then
			imgui.ShowCursor = true
		end
		if script.admin_panel.v then
			imgui.ShowCursor = true
		end
	else
		imgui.ShowCursor = false
	end
	
	if script.admin_panel.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth - imgui.GetStyle().ItemSpacing.x , iScreenHeight - imgui.GetStyle().ItemSpacing.x ), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(350, 450), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.50))
		imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 1.00))
		imgui.Begin('##admin_tool', nil,1+2+4+32+128)
			imgui.CenterText("XEZIOS SADFI2259X'S TESTING PANEL")
			imgui.BeginChild("#ADMIN_PANEL#", imgui.ImVec2(0, 0), true)
				
				if imgui.Button("Game freezes like when in menu : ON", imgui.ImVec2(-0.1, 0)) then
					memory.write(0xB7CB49, 1, 1, true)
				end
				if imgui.Button("Game freezes like when in menu : OFF", imgui.ImVec2(-0.1, 0)) then
					memory.write(0xB7CB49, 0, 1, true)
				end
				imgui.Separator()
				if imgui.Button("Remove Tracers : ON", imgui.ImVec2(-0.1, 0)) then
					RemoveTracers(true)
				end
				if imgui.Button("Remove Tracers : OFF", imgui.ImVec2(-0.1, 0)) then
					RemoveTracers(false)
				end
				imgui.Separator()
				if imgui.Button("TEST", imgui.ImVec2(-0.1, 0)) then
					
				end
				
				
				
			imgui.EndChild()
		imgui.End()
		imgui.PopStyleColor(2)
	end
	
	if version_status == 'checking...' then
		if script.window.v then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(310, 240), imgui.Cond.FirstUseEver)
			imgui.Begin('##Settings#updates#loaddingup', nil, 1+2+32+128+2048)
			
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			imgui.Spacing()
			
			imgui.SetCursorPosX(imgui.GetWindowWidth()/2-(128/2))
			
				imgui.Spinner("##spinner", 64, 10, imgui.GetColorU32(imgui.ImVec4(rainbow32(5, 255, 120))))
				
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.TitleText('Checking for updates...')
				
			imgui.End()
		end
	else
		--if tonumber((thisScript().version)) == tonumber(version_check) then
		if version_status == 'uptodate' then
			if script.window.v then
				if script.Skin_Editor then
					imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth - 4, -iScreenHeight), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
					imgui.SetNextWindowSize(imgui.ImVec2(350, iScreenHeight - 8), imgui.Cond.FirstUseEver)
					imgui.Begin('##skineditor', script.window,1+2+4+32)
						imgui.InputText("skins filter##skinsearch", script.skins_filter)
						imgui.Separator()
						ped_ret = 0
						for peds_index, ped_pic in ipairs(ped_pictures) do
							
							if string.find(string.lower(getSkinNamebyModel(ped_pic.id)..'('..(ped_pic.id)..')'), string.lower(script.skins_filter.v), 1, true) then
							
							--if (tostring(ped_pic.id)):match(tostring(script.skins_filter.v)) then -- Crash on ()
								if imgui.ImageButton(ped_pic.tex,imgui.ImVec2(36.6, 74),imgui.ImVec2(0,0),imgui.ImVec2(1,1),3,imgui.ImVec4(0,0,0,0),imgui.ImVec4(1,1,1,1)) then 
									if ped_pic.id then 
										ChangerSkinNewEdition(ped_pic.id)
									end
								end 
								imgui.Hint(getSkinNamebyModel(ped_pic.id)..'('..(ped_pic.id)..')')
								ped_ret = ped_ret + 1
								if ped_ret <= 6 then imgui.SameLine() else ped_ret = 0 end
							end
						end
					imgui.End()
				end
				
				if script.SettingsLEFT then
					--renderDrawBox(0, 0, iScreenWidth, iScreenHeight, 0x90000000, 0, 0x90000000)
					imgui.SetNextWindowPos(imgui.ImVec2(0, 0), imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
					imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth, iScreenHeight), imgui.Cond.FirstUseEver)
					imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 0)
					imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.50))
					imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
						imgui.Begin('##settings_leftbar', script.window,1+2+4+32+128)
							imgui.SetCursorPosX(imgui.GetWindowSize().x - (350 + imgui.GetStyle().ItemSpacing.y))
							imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.89, 0.85, 0.92, 0.30))
							imgui.BeginChild("##setings", imgui.ImVec2(350, 126), true)
								imgui.Text('')
								imgui.SameLine(7)
								imgui.PushFont(fa_size)
									imgui.Text(fa.ICON_COG)
								imgui.PopFont()
								imgui.SameLine()
								imgui.PushFont(leftbar_size)
								imgui.Text("SETTINGS")
								imgui.PopFont()
								imgui.SameLine(imgui.GetWindowSize().x - (30 + imgui.GetStyle().ItemSpacing.y + 2))
								imgui.SetCursorPosY(imgui.GetStyle().ItemSpacing.y + 2)
								imgui.BeginGroup()
									imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 50)
									imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 0.50))
									imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
									if imgui.Button("  "..fa.ICON_TIMES, imgui.ImVec2(30, 30)) then 
										script.SettingsLEFT = not script.SettingsLEFT
									end
									imgui.PopStyleColor(4)
									imgui.PopStyleVar()
								imgui.EndGroup()
								
								imgui.CustomSeparator(height, width)
								if imgui.Button(fa.ICON_FLOPPY_O..' Save current settings', imgui.ImVec2(-0.1, 0)) then settings_ini_save() end
								if imgui.Button(fa.ICON_RETWEET..' Load last saved settings', imgui.ImVec2(-0.1, 0)) then settings_ini_load() end
								imgui.Separator()
								if imgui.Combo('Active key', script.activekey, {"INSERT", "DELETE", "HOME", "END"}) then ini.functions.activekey = script.activekey.v  inicfg.save(ini, MainSettingsdirectIni) end
							imgui.EndChild()
							imgui.PopStyleColor()
						imgui.End()
					imgui.PopStyleColor(2)
					imgui.PopStyleVar()
				end
				
				--[[
				imgui.SetNextWindowPos(imgui.ImVec2(4, -iScreenHeight), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
				imgui.SetNextWindowSize(imgui.ImVec2(64, iScreenHeight - 8), imgui.Cond.FirstUseEver)
				imgui.Begin('##sidebar', script.window,1+2+4+32)
					imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
					imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 50)
					imgui.PushFont(fa_size)
						imgui.Button(fa.ICON_PLAY, imgui.ImVec2(imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2), imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2)))		
						imgui.Button(fa.ICON_COG, imgui.ImVec2(imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2), imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2)))		
					imgui.PopFont()
					imgui.PopStyleVar(2)
				imgui.End()
				--]]
				
				--[[
				imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(200, 400), imgui.Cond.FirstUseEver)
				imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 8)
				imgui.Begin('##update_log', script.window,1+2+32+128+2048)
					
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 26)
					imgui.BeginGroup()
						imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.20, 0.20, 0.20, 0.5))
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
						imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
						if imgui.Button(" "..fa.ICON_TIMES, imgui.ImVec2(22, 22)) then 
							script.window.v = not script.window.v
						end
						imgui.PopStyleColor(4)
						imgui.PopStyleVar()
					imgui.EndGroup()
					imgui.PushFont(titlefont)
						imgui.CenterText('XEZIOS')
					imgui.PopFont()
					imgui.PushFont(smallversiontext)
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.61, 0.62, 0.63, 1.00))
							imgui.CenterText('V'..thisScript().version)
						imgui.PopStyleColor()
					imgui.PopFont()
					-- Do spacing 
					imgui.PushFont(chatinsertfont)
						imgui.TextColoredRGB('{3E82E5}News')
					imgui.PopFont()
					imgui.TextColoredRGB('- news 1')
					imgui.TextColoredRGB('- news 2')
					imgui.TextColoredRGB('- news 3')
					imgui.TextColoredRGB('- etc...')
					
					imgui.PushFont(chatinsertfont)
						imgui.TextColoredRGB('{ED4245}Fixes')
					imgui.PopFont()
					imgui.TextColoredRGB('- fix 1')
					imgui.TextColoredRGB('- fix 2')
					imgui.TextColoredRGB('- fix 3')
					imgui.TextColoredRGB('- etc...')
				imgui.End()
				imgui.PopStyleVar()
				--]]
				if ini.license.Agree == false then
					local width = imgui.GetWindowWidth()
					imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
					imgui.Begin('##main_menu-license', script.window,1+2+32+128+2048)
					if script.NextStep.v == 1 then
						imgui.Spacing()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0.25))
								imgui.SetCursorPosY(130)
									imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(24, 24))
								imgui.PopStyleColor(2)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
						imgui.SameLine()
						imgui.BeginChild('##main', imgui.ImVec2(424, 260), false)
						imgui.Spacing()
						imgui.Spacing()
						imgui.TitleText('Term of Service')
						imgui.Spacing()
						imgui.Spacing()
						imgui.PushFont(TermFont)
						imgui.TextWrapped(string.format("XEZIOS is a free mod menu that you will find at any time, with all the functions you may need."))
						imgui.Text(' ')
						imgui.TextWrapped(string.format("XEZIOS is a very easy to use mod menu, with a convenient user interface (ImGui), lots of options, promising future versions, stable in all its glory and with a team of experienced developers. This menu has a very convenient and special interface, with many options for vehicles, weapons, internet, players, customization, redemption and much more."))
						imgui.Text(' ')
						imgui.TextWrapped(string.format("That's all you need to get started"))
						imgui.PopFont()
						imgui.EndChild()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.SetCursorPosY(130)
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								if imgui.Button(fa.ICON_CHEVRON_RIGHT, imgui.ImVec2(24, 24)) then
									script.NextStep.v = 2
								end
								imgui.PopStyleColor(1)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
					elseif script.NextStep.v == 2 then
						imgui.Spacing()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								imgui.SetCursorPosY(130)
								if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(24, 24)) then
									script.NextStep.v = 1
								end
								imgui.PopStyleColor(1)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
						imgui.SameLine()
						imgui.BeginChild('##main', imgui.ImVec2(424, 260), false)
							imgui.Spacing()
							imgui.Spacing()
							imgui.TitleText('Information & FAQ')
							imgui.Spacing()
							imgui.Spacing()
							imgui.QueText('When did work on this project start ?')
							imgui.AnswerText('Started on: 4/28/2022\nLast Release on: 6/3/2022')
							imgui.QueText('Senior devlopers')
							imgui.AnswerText('SADFI2259X: CEO & Founder')
							imgui.AnswerText('REMINKO: Partner')
							imgui.AnswerText('CHAPO: Contributor Opcodes')
							imgui.QueText('Contributors')
							imgui.AnswerText("FireByte: Crosshair stuff\nMr.XyZz: SAMP Events and Bypass stuff\nTechiecious: Suppot and advertisement")
						imgui.EndChild()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.SetCursorPosY(130)
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								if imgui.Button(fa.ICON_CHEVRON_RIGHT, imgui.ImVec2(24, 24)) then
									script.NextStep.v = 3
								end
								imgui.PopStyleColor(1)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
					elseif script.NextStep.v == 3 then 
					
					
					
						imgui.Spacing()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								imgui.SetCursorPosY(130)
								if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(24, 24)) then
									script.NextStep.v = 2
								end
								imgui.PopStyleColor(1)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
						imgui.SameLine()
						imgui.BeginChild('##main', imgui.ImVec2(424, 260), false)
						
						
							imgui.Spacing()
							imgui.Spacing()
							imgui.TitleText('Note')
							imgui.Spacing()
							imgui.Spacing()
						
						imgui.SetCursorPosY(106)
						imgui.PushFont(TermFont)
						imgui.TextWrapped("You cheated not only the game, but yourself. You didn't grow. You didn't improve. You took a shortcut and gained nothing. You experienced a hollow victory. Nothing was risked and nothing was gained. It's sad that you don't know the difference.")
						imgui.PopFont()
						
						
						imgui.EndChild()
						imgui.SameLine()
							imgui.BeginGroup()
								imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
								imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
								imgui.SetCursorPosY(130)
								imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
								if imgui.Button(fa.ICON_CHECK, imgui.ImVec2(24, 24)) then
									ini.license.Agree = true  inicfg.save(ini, MainSettingsdirectIni)
								end
								imgui.PopStyleColor(1)
								imgui.PopStyleVar(2)
							imgui.EndGroup()
					end
						imgui.SetCursorPosX((width/2)+30)
						imgui.SetCursorPosY(274)
						imgui.BeginGroup()
							imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
							imgui.CircleButton('##1', script.NextStep, 1)
							imgui.SameLine()
							imgui.CircleButton('##2', script.NextStep, 2)
							imgui.SameLine()
							imgui.CircleButton('##3', script.NextStep, 3)
							imgui.PopStyleColor(1)
						imgui.EndGroup()
					
					imgui.End()
				else
					musiclist = getMusicList()
					hooklist = getHookList()
					imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(596, 401), imgui.Cond.FirstUseEver) --581, 401
					WindowBg()
					imgui.Begin('##main_menu', script.window,1+2+32+128+2048)
					imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.89, 0.85, 0.92, 0.30))
					
					imgui.BeginGroup()

					imgui.BeginChild('##header', imgui.ImVec2(0, 30), true)
					imgui.PushFont(fontsize)
					imgui.TextColoredRGB(' '..thisScript().name..' '..'v'..thisScript().version..' '..(project.pTag))
					imgui.PopFont()
					
					imgui.SameLine(imgui.GetWindowSize().x - 53)
					
					if imgui.Button(" "..fa.ICON_COG, imgui.ImVec2(22, 22)) then 
						script.SettingsLEFT = not script.SettingsLEFT
					end
					
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
					if imgui.Button(" "..fa.ICON_TIMES, imgui.ImVec2(22, 22)) then 
						script.window.v = not script.window.v
					end
					imgui.PopStyleColor(3)
					imgui.EndChild()
					
					menu_btn = imgui.ImVec2(23, 23)
					imgui.BeginChild('##left-navigation', imgui.ImVec2(31, 0), true)
						if script.page == 1 then
							imgui.LeftButtonHovered(fa.ICON_USER, menu_btn)
						else
							imgui.LeftButton(fa.ICON_USER, menu_btn, 1)
						end
						imgui.Hint("Player Functions")
						if script.page == 2 then
							imgui.LeftButtonHovered(fa.ICON_DATABASE, menu_btn)
						else
							imgui.LeftButton(fa.ICON_DATABASE, menu_btn, 2)
						end
						imgui.Hint("DataBase Functions")
						if script.page == 3 then
							imgui.LeftButtonHovered(fa.ICON_CROSSHAIRS, menu_btn)
						else
							imgui.LeftButton(fa.ICON_CROSSHAIRS, menu_btn, 3)
						end
						imgui.Hint("Aiming Functions")
						if script.page == 4 then
							imgui.LeftButtonHovered(fa.ICON_CAR, menu_btn)
						else
							imgui.LeftButton(fa.ICON_CAR, menu_btn, 4)
						end
						imgui.Hint("Vehicle Functions")
						if script.page == 5 then
							imgui.LeftButtonHovered(fa.ICON_EYE, menu_btn)
						else
							imgui.LeftButton(fa.ICON_EYE, menu_btn, 5)
						end
						imgui.Hint("Visual Functions")
						if script.page == 6 then
							imgui.LeftButtonHovered(fa.ICON_MAP_MARKER, menu_btn)
						else
							imgui.LeftButton(fa.ICON_MAP_MARKER, menu_btn, 6)
						end
						imgui.Hint("Teleport Functions")
						if script.page == 7 then
							imgui.LeftButtonHovered(fa.ICON_GAMEPAD, menu_btn)
						else
							imgui.LeftButton(fa.ICON_GAMEPAD, menu_btn, 7)
						end
						imgui.Hint("Game Functions")
						if script.page == 9 then
							imgui.LeftButtonHovered(fa.ICON_SERVER, menu_btn)
						else
							imgui.LeftButton(fa.ICON_SERVER, menu_btn, 9)
						end
						imgui.Hint("Server Functions")
						if script.page == 10 then
							imgui.LeftButtonHovered(fa.ICON_MUSIC, menu_btn)
						else
							imgui.LeftButton(fa.ICON_MUSIC, menu_btn, 10)
						end
						imgui.Hint("MP3 Player")
						if script.page == 11 then
							imgui.LeftButtonHovered(fa.ICON_PIE_CHART, menu_btn)
						else
							imgui.LeftButton(fa.ICON_PIE_CHART, menu_btn, 11)
						end
						imgui.Hint("Player Stats")
						if script.page == 12 then
							imgui.LeftButtonHovered(fa.ICON_FILE_CODE_O, menu_btn)
						else
							imgui.LeftButton(fa.ICON_FILE_CODE_O, menu_btn, 12)
						end
						imgui.Hint("Hook Injector")
						if script.page == 8 then
							imgui.LeftButtonHovered(fa.ICON_HANDSHAKE_O, menu_btn)
						else
							imgui.LeftButton(fa.ICON_HANDSHAKE_O, menu_btn, 8)
						end
						imgui.Hint("Credits")
						imgui.Separator()
						if imgui.Button(" "..fa.ICON_COMMENTING, menu_btn) then 
							script.sms_window.v = not script.sms_window.v
							script.window.v = not script.window.v
						end
					imgui.EndChild()
					imgui.SameLine()
					imgui.BeginGroup()
					imgui.BeginChild('##right-options##GGgo!!!', imgui.ImVec2(0, 328), true)
							if script.page == 1 then
							
							imgui.BeginChild("##header_player", imgui.ImVec2(0, 60), true)
								if imgui.Button(" " .. fa.ICON_FROWN_O .. " Suicide", imgui.ImVec2((imgui.GetWindowWidth()-10)/2, 24)) then
									setCharHealth(PLAYER_PED,0)
								end
								imgui.SameLine()
								if imgui.Button(" " .. fa.ICON_REFRESH .. " Respawn", imgui.ImVec2((imgui.GetWindowWidth()-15)/2, 24)) then
									sampSpawnPlayer()
								end
								
								if imgui.Button(" " .. fa.ICON_HEART .. " Reset Healh", imgui.ImVec2((imgui.GetWindowWidth()-10)/2, 24)) then
									if GG_OVERHP.v then
										setCharHealth(PLAYER_PED,160)	
									else
										setCharHealth(PLAYER_PED,100)	
									end
								end
								imgui.SameLine()
								local parmour = getCharArmour(PLAYER_PED)
								if parmour > 1 then
									if imgui.Button(" " .. fa.ICON_SHIELD .. " Reset Armour", imgui.ImVec2((imgui.GetWindowWidth()-15)/2, 24)) then
										addArmourToChar(playerPed, 100)
									end
								else
									if imgui.Button(" " .. fa.ICON_SHIELD .. " Get Armour", imgui.ImVec2((imgui.GetWindowWidth()-15)/2, 24)) then
										addArmourToChar(playerPed, 100)
									end
								end
							imgui.EndChild()
							imgui.BeginChild("##playerpage1", imgui.ImVec2(264, 0), true)
								imgui.BeginChild("##mainplayerfunctions", imgui.ImVec2(0, 169), false)
									imgui.ToggleButton("toggle1##1", "God Mode", 212, GG_GM)
									imgui.ToggleButton("toggle1##2", "No Fall ", 212, GG_NoFall)
									imgui.ToggleButton("toggle1##rotation", "Fast Rotation ", 212, GG_FastRotation)
									imgui.ToggleButton("toggle1##3", "Death Flood", 212, GG_DeathF)
									imgui.ToggleButton("toggle1##4", "Infinity Run", 212, GG_InfinityRun)
									imgui.ToggleButton("toggle1##5", "Mega Jump", 212, GG_MegaJump)
									imgui.ToggleButton("toggle1##6", "Anti Stun", 212, GG_AntiStun)
									--imgui.ToggleButton("toggle1##7", "Fugga", 212, GG_Fugga)
									imgui.ToggleButton("toggle1##8", "Anti Afk", 212, GG_AntiAfk)
									imgui.ToggleButton("toggle1##inf02", "Infinity Oxygen", 212, GG_InfO2)
									imgui.ToggleButton("toggle1##9", "Invisible [OnFoot]", 212, GG_Invisible)
								imgui.EndChild()
							imgui.Separator()
							imgui.Checkbox("Rvanka", GG_rvanka)
							imgui.Checkbox("Invert Mode", GG_InvertPlayer2021)
							imgui.Checkbox("Crazy Mode", GG_CrazyPlayer2021)
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild("##playerpage2", imgui.ImVec2(0, 0), true)
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
							if not script.iHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.98, 0.85, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.98, 0.85, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.98, 0.82, 1.00))
								if imgui.Button("Show player and server stats on screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then script.iHUD.v = not script.iHUD.v end
								imgui.PopStyleColor(3)
							elseif script.iHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
								if imgui.Button("Hide player and server stats from screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then script.iHUD.v = not script.iHUD.v end
								imgui.PopStyleColor(3)
							end
							if not script.vHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.98, 0.85, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.98, 0.85, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.98, 0.82, 1.00))
								if imgui.Button("Show vehicle stats on screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 25)) then script.vHUD.v = not script.vHUD.v end
								imgui.PopStyleColor(3)
							elseif script.vHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
								if imgui.Button("Hide vehicle stats from screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then script.vHUD.v = not script.vHUD.v end
								imgui.PopStyleColor(3)
							end
							if not script.cHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.98, 0.85, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.98, 0.85, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.98, 0.82, 1.00))
								if imgui.Button("Show custom hud on screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then script.cHUD.v = not script.cHUD.v end
								imgui.PopStyleColor(3)
							elseif script.cHUD.v then	
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
								if imgui.Button("Hide custom hud from screen", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 26)) then script.cHUD.v = not script.cHUD.v end
								imgui.PopStyleColor(3)
							end
							imgui.PopStyleVar()
							imgui.Separator()
							imgui.Checkbox("Fast Walk", GG_FastWalk)
							imgui.SliderInt("run speed", script.fastwalk, 1, 10)
							imgui.Separator()
							imgui.Checkbox("AirBreak", GG_AirBreak)
							imgui.SameLine()
							imgui.HintTooltipQuestion('Enable: Right Shift \nMoving: '..fa.ICON_ARROW_CIRCLE_UP..', '..fa.ICON_ARROW_CIRCLE_DOWN..', '..fa.ICON_ARROW_CIRCLE_RIGHT..', '..fa.ICON_ARROW_CIRCLE_LEFT)
							imgui.SliderFloat('Speed.', script.AirBreakSpeed, 0.25, 2)
							imgui.Separator()
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
							if script.Skin_Editor then
								if imgui.Button(fa.ICON_MALE.."  Close Player Skin Editor  "..fa.ICON_FEMALE, imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 47)) then
									--imgui.OpenPopup('PlayerSkin')
									script.Skin_Editor = not script.Skin_Editor
								end
							else
								if imgui.Button(fa.ICON_MALE.."  Open Player Skin Editor  "..fa.ICON_FEMALE, imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 47)) then
									--imgui.OpenPopup('PlayerSkin')
									script.Skin_Editor = not script.Skin_Editor
								end
							end
							imgui.PopStyleVar()
							
							--[[
							if imgui.BeginPopup('PlayerSkin') then
								ped_ret = 0
								for peds_index, ped_pic in ipairs(ped_pictures) do
									if imgui.ImageButton(ped_pic.tex,imgui.ImVec2(28, 56),imgui.ImVec2(0,0),imgui.ImVec2(1,1),3,imgui.ImVec4(0,0,0,0),imgui.ImVec4(1,1,1,1)) then 
										if ped_pic.id then 
											ChangerSkinNewEdition(ped_pic.id)
										end
									end 
									imgui.Hint(getSkinNamebyModel(ped_pic.id)..'('..(ped_pic.id)..')')
									ped_ret = ped_ret + 1
									if ped_ret <= 6 then imgui.SameLine() else ped_ret = 0 end
								end
								
								imgui.EndPopup()
							end
							--]]
						imgui.EndChild()
						end
						if script.page == 2 then
						imgui.BeginChild("##raknetpage1", imgui.ImVec2(109, 0), true)
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
							if imgui.Button("CLEAN TASK", imgui.ImVec2(-0.1, 0)) then sampSetSpecialAction(0) clearCharTasksImmediately(PLAYER_PED) end
							imgui.PopStyleVar()
							imgui.PopStyleColor(3)
							imgui.Separator()
							
							for name, anim_ids in pairs(sampanim) do
								anim_id = anim_ids:match("([^, ]+)")
								show_anim(name, anim_id)
							end
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild("##raknetpage2", imgui.ImVec2(0, 0), true)
							imgui.TextColoredRGB("{ff0000}NOTE: {ffffff}Use 'Fake_Spawn' before login/register")
							imgui.Separator()
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.35))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.59, 0.98, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.53, 0.98, 1.00))
							if imgui.Button('Fake_Spawn',imgui.ImVec2(-0.1, 0)) then fake_spawn() end
							imgui.PopStyleColor(3)
							imgui.Hint("Use this button before login/register")
							imgui.Separator()
							
							if script.bypass == false then
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.98, 0.85, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.98, 0.85, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.06, 0.98, 0.82, 1.00))
								if imgui.Button('Turn ByPass ON',imgui.ImVec2(-0.1, 0)) then script.bypass = true end
								imgui.PopStyleColor(3)
							else
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
								if imgui.Button('Turn ByPass OFF',imgui.ImVec2(-0.1, 0)) then script.bypass = false end
								imgui.PopStyleColor(3)
							end
							imgui.Separator()
							if imgui.CollapsingHeader("SAMP Advanced") then
								imgui.Checkbox("Block SAMP Collision", GG_ObjectCollision)
								imgui.Checkbox("Block Drug Effect", GG_BlockDrugsAnimation)
								imgui.Checkbox("Set Max Health to 160HP", GG_OVERHP)
								imgui.Checkbox("RP Name tag", GG_RPName) imgui.HintTooltip("Remove the '_' from the player's name \n{ff0000}Note: {ffffff}require for restart after disable")
							end
							imgui.BeginChild("nops patch", imgui.ImVec2(0, 0), true)
							if imgui.Button(' Incoming RPC ') then script.nops_page = 1 end
							imgui.SameLine()
							if imgui.Button(' Outcoming RPC ') then script.nops_page = 2 end
							imgui.SameLine()
							if imgui.Button('Incoming Packets') then script.nops_page = 3 end
							imgui.SameLine()
							if imgui.Button('Outcoming Packets') then script.nops_page = 4 end
							imgui.Separator()
							imgui.InputText("filter", script.nops_filter)
							imgui.BeginChild("nops_patch_list", imgui.ImVec2(0, 0), true)
							render_nops_filter(1, filter_rpc_incoming, script.nops_filter)
							render_nops_filter(2, filter_rpc_outcoming, script.nops_filter)
							render_nops_filter(3, filter_packets_incoming, script.nops_filter)
							render_nops_filter(4, filter_packets_outcoming, script.nops_filter)
							imgui.EndChild()
							imgui.EndChild()
						imgui.EndChild()
						end
						if script.page == 3 then
						imgui.BeginChild("##weaponspage1", imgui.ImVec2(264, 0), true)
							if imgui.Button(fa.ICON_TRASH..' Remove All Weapons', imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 23)) then
								removeAllCharWeapons(PLAYER_PED)
							end 
							
							current_weapon_name = weapons.get_name(getCurrentCharWeapon(PLAYER_PED))
							if current_weapon_name == nil then current_weapon_name = 'Unknow' end
							
							if imgui.Button(fa.ICON_TRASH..' Remove Current Weapon ('..current_weapon_name..')', imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 23)) then
								removeWeaponFromChar(PLAYER_PED, getCurrentCharWeapon(PLAYER_PED))
							end
							imgui.Separator()
							imgui.PushStyleVar(imgui.StyleVar.ChildWindowRounding, 0)
							imgui.BeginChild("aimfunctions xD", imgui.ImVec2(0, 150),false)
								imgui.ToggleButton("toggle2##camrestor", "No Cam Restore", 211, GG_noCamRestore) --230
								imgui.ToggleButton("toggle2##1", "Infinity Ammo", 211, GG_InfinityAmmo)
								imgui.ToggleButton("toggle2##2", "Full Skills", 211, GG_FullSkills)
								imgui.ToggleButton("toggle2##3", "No Reload", 211, GG_NoReload)
								imgui.ToggleButton("toggle2##4", "Bell Sound", 211, GG_bell)
								imgui.ToggleButton("toggle2##6", "No Spread", 211, GG_NoSpread)
								imgui.ToggleButton("toggle2##7", "SensFix", 211, GG_SensFix)
								imgui.ToggleButton("toggle2##12", "GTA V Aim System", 211, GG_gtavaim)
							imgui.EndChild()
							imgui.PopStyleVar()
							imgui.Separator()
							--[[
							
							imgui.ToggleButton("toggle2##8", "AimBot", 230, GG_AimBot)
							
							imgui.Button(fa.ICON_COG, imgui.ImVec2(18, 18))
							imgui.SameLine()
							imgui.PushFont(ToggleButton_Font)
							imgui.Text("SilentAim")
							imgui.PopFont()
							imgui.SameLine(230)
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.192, 0.815, 0.000, 1.0000)) -- ON
							imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.333, 0.507, 0.279, 1.000)) -- ON
							if imgui.ToggleButton_alpha("toggle2##9", imgClickInfState) then tarPed = -1 end
							imgui.PopStyleColor(2) --]]
							
							imgui.Checkbox("Cbug", GG_Cbug)
							imgui.SameLine()
							if imgui.Button(" "..fa.ICON_COG.." Settings##cbug") then
								imgui.OpenPopup('cbug')
							end
							
							if imgui.BeginPopup('cbug') then
								imgui.RadioButton("+C Helper ", script.radio_cbug, 0)
								imgui.RadioButton("Auto +C ", script.radio_cbug, 1)
								imgui.RadioButton("Rapid +C ", script.radio_cbug, 2)
								imgui.EndPopup()
							end
							
							imgui.Checkbox("TriggerBot", GG_trigger)
							
							imgui.Checkbox("Aim (Bot, Pro, Smooth)", GG_AimBot)
							imgui.SameLine()
							if imgui.Button(" "..fa.ICON_COG.." Settings##AB") then
								imgui.OpenPopup('aimbotsettings')
							end
							
							if imgui.BeginPopup('aimbotsettings') then
								imgui.Text("Type:")
								imgui.RadioButton("Normal AimBot ", script.aimbot_type, 0)
								imgui.RadioButton("Pro AimBot ", script.aimbot_type, 1)
								imgui.RadioButton("Smooth AimBot ", script.aimbot_type, 2)
								imgui.Text("Config:")
								if script.aimbot_type.v == 0 then
									imgui.Checkbox('Ignore players with my color ##aimbot', aimbot.team_ignore)
								elseif script.aimbot_type.v == 1 then
									imgui.Checkbox('Skip Dead ##proaim', aimbot.proSkipDead)
									imgui.SliderFloat("The area from the crosshair, in which the search for the enemy will be ignored", aimbot.safeZone, 1.0, 300.0, "%.1f")
									imgui.SliderFloat("The maximum distance from the scope at which the enemy will be found", aimbot.jobRadius, 1.0, 300.0, "%.1f")
								else
									imgui.Checkbox('Skip Dead (smoothaim) ##smoothaim', aimbot.skipDead)
									imgui.Checkbox("Don't aim while playing animations ##smoothaim", aimbot.disabledOnAnim)
									imgui.Checkbox("Doesn't target if clist is equal to your ##smoothaim", aimbot.disabledIfFriend)
									imgui.Checkbox("Don`t aim while player is AFK ##smoothaim", aimbot.disabledOnAFk)
									imgui.SliderFloat("Smooth aiming", aimbot.smoothSpeed, 1.0, 30.0, "%.1f")
									imgui.SliderFloat("Increase the smoothness of the aiming", aimbot.addSmoothSpeed, 1.0, 30.0, "%.1f")
								end
								
								imgui.EndPopup()
							end
							
							if imgui.Checkbox("SilentAim", imgClickInfState) then tarPed = -1 end
							imgui.SameLine()
							if imgui.Button(" "..fa.ICON_COG.." Settings") then
								imgui.OpenPopup('silentsettings')
							end
							
							if imgui.BeginPopup('silentsettings') then
								imgui.Text('Body parts:')
								if imgui.Checkbox(u8'Head ', imgClickinfHead) then DisableAllBody(false, false, true) end
								if imgui.Checkbox(u8'Torso', imgClickinfTorso) then DisableAllBody(true, false, false) end
								if imgui.Checkbox(u8'Groin', imgClickinfGroin) then DisableAllBody(false, true, false) end
								imgui.Text("dist:")
								imgui.SliderFloat('Fov', imgSliderInfFov, 0.0, 80.0)
								imgui.SliderFloat('Hit', imgSliderInfRand, 0.0, 100.0) 
								imgui.Text("Config:")
								imgui.Checkbox(u8'Ignore objects ', imgClickInfObj)
								imgui.Checkbox(u8'Ignore transport ', imgClickInfVeh)
								imgui.Checkbox(u8'Ignore players with my color ', imgClickinfClist)
								imgui.Checkbox(u8'Draw lines' , imgClickInfLine)
								imgui.SliderFloat(u8'Blood Density ', imgSliderInfBlood, 0.0, 100.0)
								
								imgui.EndPopup()
							end
							
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild("##weaponspage2", imgui.ImVec2(0, 0), true)
							imgui.ToggleButton("toggle2##10", "Send damage", 241, GG_damager)
							imgui.ToggleButton("toggle2##11", "Minigun damager", 241, GG_cdamage)
							imgui.Separator()
							imgui.Checkbox("Rapid Fire", GG_Rapid)
							imgui.SliderInt('Rapid Speed', script.RapidSpeed, 1, 15)
							imgui.BeginChild("##weaponspage3", imgui.ImVec2(0, 0), true)
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
							imgui.InputInt("Ammo",script.weapon_ammo,1,10,0)
							imgui.PopStyleVar()
							ret = 0
							for index, pic in ipairs(weapons_pictures) do
								if imgui.ImageButton(pic.tex,imgui.ImVec2(25,25),imgui.ImVec2(0,0),imgui.ImVec2(1,1),3,imgui.ImVec4(0,0,0,0),imgui.ImVec4(1,1,1,1)) then 
									if pic.id then 
										give_weapon_to_char(PLAYER_PED,pic.id,script.weapon_ammo.v)
									end
								end 
								ret = ret + 1
								if ret <= 6 then imgui.SameLine() else ret = 0 end
							end
							imgui.EndChild()
						imgui.EndChild()
						end
						if script.page == 4 then
						imgui.BeginChild("##vehiclepage1", imgui.ImVec2(264, 0), true)
							imgui.ToggleButton("toggle4##1", "GodMode Car", 230, GG_GMCar)
							imgui.ToggleButton("toggle4##wheels", "GodMode Wheels", 230, GG_GMWheels)
							imgui.ToggleButton("toggle4##2", "No Fall Of Bike", 230, GG_Fbike)
							imgui.ToggleButton("toggle4##3", "Flood Comp", 230, GG_FC)
							imgui.ToggleButton("toggle4##4", "Tank Mode", 230, GG_Tmode)
							imgui.ToggleButton("toggle4##5", "Infinity Fuel", 230, GG_InfinityFuel)
							imgui.ToggleButton("toggle4##6", "No Radio", 230, GG_NoRadio)
							imgui.ToggleButton("toggle4##7", "Rid on wather", 230, GG_Water)
							imgui.ToggleButton("toggle4##underwater", "Drive Under Water", 230, GG_driveUnderWater)
							imgui.ToggleButton("toggle4##8", "Car Shot", 230, GG_CarShot)
							imgui.ToggleButton("toggle4##9", "High BMX jump", 230, GG_bmx)
							imgui.ToggleButton("toggle4##10", "Nitro Mode (press Num0)", 230, GG_Nitro)
							imgui.Separator()
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.4))
							if imgui.Button('Explode your Vehicle', imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 20)) and isCharInAnyCar(PLAYER_PED) then 
								veh = storeCarCharIsInNoSave(PLAYER_PED)
								setCarHealth(veh, 1.0)
							end
							imgui.SameLine()
							if imgui.Button('Repair vehicle', imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 20)) and  isCharInAnyCar(PLAYER_PED) then
								veh = storeCarCharIsInNoSave(PLAYER_PED)
								setCarHealth(veh, 1000.0)
								--addOneOffSound(0.0, 0.0, 0.0, 1136)
							end
							if imgui.Button('Add Hydraulics', imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 20)) and  isCharInAnyCar(PLAYER_PED) then
								veh = storeCarCharIsInNoSave(PLAYER_PED)
								setCarHydraulics(veh, true)
							end
							imgui.SameLine()
							if imgui.Button('Remove Hydraulics', imgui.ImVec2((imgui.GetWindowWidth()-13)/2, 20)) and  isCharInAnyCar(PLAYER_PED) then
								veh = storeCarCharIsInNoSave(PLAYER_PED)
								setCarHydraulics(veh, false)
							end 
							imgui.PopStyleVar()
							imgui.EndChild()
							imgui.SameLine()
							imgui.BeginChild("##vehiclepage2", imgui.ImVec2(0, 0), true)
							imgui.Checkbox("Car Jump (press left shift)", GG_CarJump)
							imgui.SliderFloat('jump length', script.lengthJump, 0.1, 1.5)
							imgui.Separator()
							imgui.Checkbox("SpeedHack (press ALT)", GG_altspeed)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Speeds up your car.')
							imgui.SliderInt('Max speed', script.altspeedhack, 100, 800)
							imgui.Separator()
							imgui.ToggleButton("toggle4##drift", "Drift Mode (press left ctrl)", 241, GG_driftInCar)
							imgui.Separator()
							imgui.ToggleButton("toggle4##11", "Invert Mode Veh", 241, GG_InvertVeh2021)
							imgui.ToggleButton("toggle4##12", "Crazy Mode Veh", 241, GG_CrazyVeh2021)
							imgui.Separator()
							
							if imgui.CollapsingHeader("Unlock any vehicle !") then
								imgui.TextColoredRGB("{ff0000}NOTE: {ffffff}Type {0037ff}/dl {ffffff}in the chat to see vehicle IDs")
								imgui.Separator()
								imgui.InputText("vehicle's ID",script.unlock_carID, 1)
								if imgui.Button(fa.ICON_UNLOCK.." Unlock") then
									openVehicle(script.unlock_carID.v)
								end
								imgui.Separator()
							end
							
							if imgui.CollapsingHeader("Vehicles troll") then
								imgui.Text("     ")
								imgui.SameLine()
								imgui.BeginGroup()
									imgui.TextColoredRGB("{ff0000}NOTE: {ffffff}Type {0037ff}/dl {ffffff}in the chat to see vehicle \nIDs")
									imgui.Separator()
									if imgui.CollapsingHeader("Warp to vehicle by ID") then
										imgui.PushItemWidth(150)
										imgui.InputText("vehicle ID##warpto",script.warp_carID, 1)
										if imgui.Button("Warp to vehicle##lol", imgui.ImVec2(-0.1, 0)) then 
											WarpToVehicle(script.warp_carID.v)
										end
										imgui.Separator()
									end
									if imgui.CollapsingHeader("Warp vehicle to you by ID") then
										imgui.PushItemWidth(150)
										imgui.InputText("vehicle ID##getvehicle",script.get_carID, 1)
										if imgui.Button("Warp vehicle to you##lol", imgui.ImVec2(-0.1, 0)) then 
											GetVehicle(script.get_carID.v)
										end
										imgui.Separator()
									end
									if imgui.CollapsingHeader("explode vehicle") then
										imgui.TextColoredRGB("{ff0000}WARN: {ffffff}Use on empty vehicles")
										imgui.Separator()
										imgui.PushItemWidth(150)
										imgui.InputText("vehicle ID##explode",script.explode_carID, 1)
										if imgui.Button("Explode vehicle", imgui.ImVec2(-0.1, 0)) then 
											ExplodeVehicle(script.explode_carID.v)
										end
									end
								imgui.EndGroup()
							end
							
							imgui.EndChild()
						end
						if script.page == 5 then
						imgui.BeginChild("##visualpage1", imgui.ImVec2(264, 92), true)
							imgui.ToggleButton("toggle5##1", "ESP Names", 230, GG_NameTags)
							imgui.ToggleButton("toggle5##2", "ESP Bones", 230, GG_SkeletalWallHack)
							imgui.ToggleButton("toggle5##9", "ESP Box",   230, GG_espbox)
							imgui.ToggleButton("toggle5##7", "ESP Lines", 230, GG_esplines)
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild("##visualpage2", imgui.ImVec2(0, 92), true)
							imgui.ToggleButton("toggle5##4", "Disable Change Color Under Water", 241, GG_DisableChangeColorUnderWater)
							imgui.ToggleButton("toggle5##5", "Disable Under Water Effects", 241, GG_DisableUnderWaterEffects)
							imgui.ToggleButton("toggle5##6", "Disable Water", 241, GG_DisableWater)
						imgui.EndChild()
						
						imgui.Checkbox("Chams", GG_Chams)
						imgui.Combo('Chams style', script.chamstype, {"Highlighted", "Painted over"})
						
						
						imgui.BeginChild("##visualpage3", imgui.ImVec2(0, 0), true)
						imgui.BeginGroup()
							imgui.Checkbox(u8("ESP Models Finder"), GG_objectwallhack)
							imgui.BeginGroup()
								imgui.Spacing()
								imgui.Text(fa.ICON_CHEVRON_RIGHT)
							imgui.EndGroup()
							imgui.SameLine()
							imgui.Checkbox(u8("Draw Lines"), GG_objtraser)
							if imgui.Button(u8("Add models")) then
								table.insert(ObjectFinder_Table, {imgui.ImInt(#ObjectFinder_Table + 1), imgui.ImBuffer("", 20)})
								table.insert(inputs, {#inputs + 1, ""})
								inicfg.save(inputs, ObjectFinderDirectIni)
							end
							if #inputs > 0 then
								if imgui.Button(u8("Remove last added model")) then
									table.remove(ObjectFinder_Table, #ObjectFinder_Table)
									table.remove(inputs, #inputs)
									inicfg.save(inputs, ObjectFinderDirectIni)
								end
							end
							imgui.Text("You can find a model is id on")
							--imgui.SameLine()
							imgui.UrlLink('dev.prineside.com', 'https://dev.prineside.com/en/gtasa_samp_model_id/')
						imgui.EndGroup()
						imgui.SameLine()
						imgui.BeginChild("inputs", imgui.ImVec2(0, 0), true)
							for i, val in ipairs(ObjectFinder_Table) do
								if imgui.InputInt("##input"..i, val[1], 0, -1) then
									inputs[i][1] = ObjectFinder_Table[i][1].v
									inicfg.save(inputs, ObjectFinderDirectIni)
								end
								imgui.SameLine()
								imgui.HintTooltip(u8("Model ID"))
								--imgui.NewLine()
							end
						imgui.EndChild()
						imgui.EndChild()
						end
						if script.page == 6 then
							imgui.Columns(3, nil, false)
							imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
							imgui.CustomRadioButton("Teleport", script.radio_button, 0, imgui.ImVec2((imgui.GetWindowWidth()-23)/3, 21))
							imgui.NextColumn()
							imgui.CustomRadioButton("Search", script.radio_button, 1, imgui.ImVec2((imgui.GetWindowWidth()-22)/3, 21))
							imgui.NextColumn()
							imgui.CustomRadioButton("Custom", script.radio_button, 2, imgui.ImVec2((imgui.GetWindowWidth()-23)/3, 21))
							imgui.PopStyleVar()
							imgui.Columns(1)
							imgui.Separator()
							
							if script.radio_button.v == 0 then
								TeleportBtn()
							elseif script.radio_button.v == 1 then
								SearchBtn()
							elseif script.radio_button.v == 2 then
								CustomBtn()
							end
						end
						if script.page == 7 then
						if imgui.Button(fa.ICON_TRASH .. " Clean Memory", imgui.ImVec2(-0.1, 0)) then
							CleanMemory()
						end
						imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.1, 0.1, 0.1, 1.0))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.50))
						imgui.BeginChild("##gamepage1", imgui.ImVec2(172, 136), true)
							imgui.ToggleButton("toggle7##9", "Wet Roads", 140, GG_WetRoads)
							imgui.ToggleButton("toggle7##11", "Blade Collision", 140, GG_BladeCollision)
							imgui.ToggleButton("toggle7##10", "Sand Particle", 140, GG_SandParticle)
							imgui.ToggleButton("toggle7##2", "Unlock FPS", 140, GG_FPS)
							imgui.ToggleButton("toggle7##14", "Spawn Fix", 140, GG_SpawnFix)
							imgui.ToggleButton("toggle7##15", "Pause Menu Fix", 140, GG_PauseMenuFix)
						imgui.EndChild()
						imgui.PopStyleColor(2)
						imgui.Hint(fa.ICON_LOCK.." You can't edit anything here \nDon't worry, these options can't ban, crash, or drop fps. Everything is safe here")
						imgui.SameLine()
						imgui.BeginChild("##gamepage2", imgui.ImVec2(185, 136), true)
							imgui.ToggleButton("toggle7##1", "Sun FIX", 152, GG_SUN)
							imgui.ToggleButton("toggle7##5", "Water square Fix", 152, GG_fixwater)
							imgui.ToggleButton("toggle7##3", "FIX Motion Blur", 152, GG_blur)
							imgui.ToggleButton("toggle7##4", "FPS Booster", 152, GG_fpsboost)
							imgui.ToggleButton("toggle7##7", "No money anim", 152, GG_fmoney)
							imgui.ToggleButton("toggle7##8", "Light Map", 152, GG_lmap)
						imgui.EndChild()
						imgui.SameLine()
						imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.1, 0.1, 0.1, 1.0))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.50))
						imgui.BeginChild("##gamepage3", imgui.ImVec2(0, 136), true)
							imgui.ToggleButton("toggle7##17", "Hydra Sniper", 144, GG_HydraSniper)
							imgui.ToggleButton("toggle7##18", "ClickMap", 144, GG_ClickMap)
							imgui.ToggleButton("toggle7##6", "Anti-crasher", 144, GG_anticrasher)
							imgui.ToggleButton("toggle7##12", "Speed Limit", 144, GG_SpeedLimit)
							imgui.ToggleButton("toggle7##13", "Rails Resistance", 144, GG_RailsResistance)
							imgui.ToggleButton("toggle7##16", "AirCraft Explosion Fix", 144, GG_AirCraftExplosionFix)
						imgui.EndChild()
						imgui.PopStyleColor(2)
						imgui.Hint(fa.ICON_LOCK.." You can't edit anything here \nDon't worry, these options can't ban, crash, or drop fps. Everything is safe here")
						imgui.BeginChild("##gamepage4", imgui.ImVec2(0, 0), true)
							imgui.Checkbox("Change memory size", GG_MEMORY)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'change game memory size')
							imgui.SliderInt('Memory value', script.pMemory, 512, 2048)
							imgui.Separator()
							imgui.Checkbox("Auto memory cleaner", GG_CMEM)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'limit memory by auto clean it')
							imgui.SliderInt('memory limiter', script.pMemSize, 50, 512)
							imgui.Separator()
							imgui.Checkbox("Draw Distance Changer", GG_DrawDist)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Change game Draw Distance.')
							imgui.SliderInt('Draw Distance', script.pDrawEdit, 100, 3000)
							imgui.Separator()
							imgui.Checkbox("Fog Distance Changer", GG_FogDist)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Change game Fog Distance.')
							imgui.SliderInt('Fog Distance', script.pFogEdit, 100, 500)
							imgui.Separator()
							imgui.Checkbox("Lod Distance Changer", GG_LogDist)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Change game Lod Distance.')
							imgui.SliderInt('lod Distance', script.pLogEdit, 10, 500)
							imgui.Separator()
							imgui.Checkbox("Change Time", GG_Time)
							imgui.SameLine()
							if imgui.Button(fa.ICON_REFRESH .. " default server time",imgui.ImVec2(-0.1, 0)) then
								memory.setint8(0xB70153, oldtime, true) 
							end
							imgui.SliderInt('Time', script.pTime, 0, 23)
							imgui.Separator()
							imgui.Checkbox("Change Weather", GG_Weather)
							imgui.SameLine()
							if imgui.Button(fa.ICON_REFRESH .. " default server weather",imgui.ImVec2(-0.1, 0)) then
								memory.setint8(0xC81320, oldweather, true) 
							end
							imgui.SliderInt('Weather', script.pWeather, 0, 91)
							imgui.Separator()
							imgui.Checkbox("Change FOV", GG_Fovedit)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Change camera Fov.')	
							imgui.SameLine()
							imgui.HintTooltipError(u8'Enabling this Feature will crashed Sniper-Zoom System.')	
							imgui.SliderInt('Fov', script.pFovedit, 70, 100)
							imgui.Separator()
							imgui.Checkbox("Camera Shake", GG_camshake)
							imgui.SameLine()
							imgui.HintTooltipQuestion(u8'Change camera shake value.')	
							imgui.SliderInt('shake', script.pCamshake, 0, 100)
							imgui.Separator()
							imgui.Checkbox("Water Color", GG_WaterX)
							if GG_WaterX.v then
								imgui.SameLine()
								imgui.Checkbox("Rainbow Water", GG_rWater) 
								--settings_ini_load()
							end 
						imgui.ColorEdit4('Water color', WATER_RPG, imgui.ColorEditFlags.NoAlpha) -- imgui.ColorEditFlags.NoInputs +
						imgui.SliderInt('Water Speed', script.pWaterSpeed, 1, 15)
						imgui.EndChild()
						end
						if script.page == 8 then
							
							imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.45, 0, 0.17, 1))
							imgui.BeginChild('##owners', imgui.ImVec2(0, 114), true)
							imgui.Image(script.sadfi_avatar, imgui.ImVec2(30, 30))
							imgui.SameLine()
							imgui.Text("Name: SADFI2259X \nRole: Menu design and codes collection")
							imgui.Separator()
							imgui.Image(script.remi_avatar, imgui.ImVec2(30, 30))
							imgui.SameLine()
							imgui.Text("Name: REMINKO \nRole: function ideas")
							imgui.Separator()
							imgui.Image(script.chapo_avatar, imgui.ImVec2(30, 30))
							imgui.SameLine()
							imgui.Text("Name: CHAPO \nRole: opcodes & resources")
							imgui.EndChild()
							imgui.PopStyleColor(1)
							
							imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.09, 0, 0.11, 1))
							imgui.BeginChild('##infos', imgui.ImVec2(0, 0), true)
							imgui.TextColoredRGB("{ff0000}Contributors:")
							imgui.SameLine()
							imgui.AnswerText("FireByte: Crosshair stuff\nMr.XyZz: SAMP Events and Bypass stuff\nTechiecious: Suppot and advertisement\nMusaigen: RakLogger++")
							imgui.Separator()
							imgui.TextColoredRGB("{ff0000}Special thanks to:")
							imgui.SameLine()
							imgui.UrlLink('BlastHack', 'http://blast.hk')
							imgui.SameLine()
							imgui.Text(',')
							imgui.SameLine()
							imgui.UrlLink('GitHub', 'https://github.com/')
							imgui.Separator()
							imgui.TextColoredRGB("Please make sure that you have visited our")
							imgui.SameLine()
							imgui.UrlLink('website', script.site_url)
							imgui.SameLine()
							imgui.TextColoredRGB("to get last news and updates")
							imgui.Text("To contact us please join our")
							imgui.SameLine()
							imgui.UrlLink('Discord', script.discord_url)
							imgui.SameLine()
							imgui.TextColoredRGB("server")
							imgui.Separator()
							imgui.TextColoredRGB("{ff0000}License: {BABABA}This client is free software | Copyright ")
							imgui.SameLine()
							imgui.TextColoredRGB('{BABABA}'..fa.ICON_COPYRIGHT)
							imgui.SameLine()
							imgui.TextColoredRGB(" {BABABA}2021-2023 XEZIOS Project")
							imgui.Separator()
							imgui.TextColoredRGB("{ff0000}UPDATE LOG: ")
							imgui.SameLine()
							imgui.TextWrapped(table.concat(UpdateLog))
							imgui.EndChild()
							imgui.PopStyleColor(1)
						end
						if script.page == 9 then
							local ip, port = sampGetCurrentServerAddress()
							
							if imgui.Button(fa.ICON_REFRESH.." Reconnect", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 31)) then
								sampDisconnectWithReason(0) 
								sampSetGamestate(1) 
							end
							if imgui.Button(fa.ICON_TRASH.." Clean Chat", imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 30)) then
								CleanChat()
							end
							imgui.Separator()
							imgui.TextColoredRGB("Disconnect With Reason:")
							if imgui.Button(fa.ICON_CLOCK_O.." Timeout", imgui.ImVec2(-0.1, 0)) then 
									sampDisconnectWithReason(true)
									sampAddChatMessage("{4D4D4F}Disconnect from the server by reason: Timeout")
									sampConnectToServer(ip, port)
								end
							if imgui.Button(fa.ICON_SIGN_OUT.." Leaving", imgui.ImVec2(-0.1, 0)) then 
								sampDisconnectWithReason(false)
								sampAddChatMessage("{4D4D4F}Disconnect from the server by reason: Leaving")
								sampConnectToServer(ip, port)
							end
							imgui.Separator()
							imgui.InputText("Nick Name", script.name1)
							imgui.InputText("IP", script.ip1, 1)
							imgui.InputText("Port", script.port1, 1)
							if imgui.Button(fa.ICON_SIGN_IN.." Connect", imgui.ImVec2(-0.1, 0)) then
								sampSetLocalPlayerName(script.name1.v)
								sampConnectToServer(script.ip1.v, script.port1.v)
							end
							imgui.Separator()
							imgui.Checkbox("Chat Flood "..fa.ICON_COMMENTING, GG_spam)
							imgui.SameLine() 
							imgui.Checkbox("Random spam ", GG_bspam)
							imgui.InputText("text", script.textspam)
							imgui.SliderInt('time (ms)', script.pspam, 0, 10000)
						end
						if script.page == 10 then
							imgui.BeginChild('##left', imgui.ImVec2(300, 0), true)
							for num, name in pairs(musiclist) do
								--name = name:gsub('.mp3', '')
								--if imgui.Selectable(u8(name), false) then musicselected = num end
								if imgui.Selectable(fa.ICON_FILE_AUDIO_O..(u8(' '..name)), false) then musicselected = num end
							end
							imgui.EndChild()
							imgui.SameLine()
							imgui.BeginChild('##right', imgui.ImVec2(0, 0), true)
							imgui.SameLine()
							for num, name in pairs(musiclist) do
								if num == musicselected then
									--namech = name:gsub('.mp3', '')
									imgui.Text(u8('Selected: '..name))
									imgui.Separator()
									imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
									if imgui.Button('' .. fa.ICON_HAND_O_UP  .. ' Play this song '..fa.ICON_HAND_O_UP, imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 30)) then
										if playsound ~= nil then setAudioStreamState(playsound, as_action.STOP) playsound = nil end
										playsound = loadAudioStream(getWorkingDirectory() ..'/'..project.pName..'/music/'..name)
										setAudioStreamState(playsound, as_action.PLAY)
										setAudioStreamVolume(playsound, math.floor(script.volume.v))
									end
									imgui.Separator()
									if imgui.Button('   ' .. fa.ICON_PAUSE .. ' Pause', imgui.ImVec2((imgui.GetWindowWidth()-8)/2, 30)) then if playsound ~= nil then setAudioStreamState(playsound, as_action.PAUSE) end end
									imgui.SameLine()
									if imgui.Button(' ' .. fa.ICON_PLAY .. ' Proceed', imgui.ImVec2((imgui.GetWindowWidth()-18)/2, 30)) then if playsound ~= nil then setAudioStreamState(playsound, as_action.RESUME) end end
									imgui.PopStyleVar()
									imgui.Separator()
									imgui.SliderInt(u8'Volume', script.volume, 0, 2)
									imgui.Separator()
									imgui.TextWrapped("Music Directory: "..getWorkingDirectory().."\\XEZIOS\\music")
									if playsound ~= nil then setAudioStreamVolume(playsound, math.floor(script.volume.v)) end
								end
							end
							imgui.EndChild()
						end
						if script.page == 11 then
							show_stats()
						end
						if script.page == 12 then
							imgui.BeginChild('##left', imgui.ImVec2(300, 0), true)
							imgui.Combo('Type', script.injectortype, {".DLL", ".ASI"})
							imgui.Separator()
							for num, name in pairs(hooklist) do
								--local name = name:gsub('.dll', '')
								if imgui.Selectable(fa.ICON_FILE..(u8(' '..name)), false) then hookselected = num end
							end
							imgui.EndChild()
							imgui.SameLine()
							imgui.BeginChild('##right', imgui.ImVec2(0, 0), true)
							imgui.SameLine()
							for num, name in pairs(hooklist) do
								if num == hookselected then
									imgui.Text(u8('Selected: '..name))
									imgui.Separator()
									if imgui.Button('   ' .. fa.ICON_HAND_O_UP  .. '    Inject the Selected file', imgui.ImVec2((imgui.GetWindowWidth()-8)/1, 30)) then
										injectDll(getWorkingDirectory() ..'\\'..project.pName..'\\injector\\'..name)
									end
									imgui.Separator()
									imgui.TextColoredRGB("{ff0000}WARN:")
									imgui.SameLine()
									imgui.TextWrapped("Don't inject the same file 2 times")
								end
							end
							imgui.EndChild()
						end
					imgui.EndChild()
					imgui.BeginChild('##downer', imgui.ImVec2(0, 0), true)
						imgui.TaskBarText(" {ff0000}License: {BABABA}This client is free software - Copyright © 2021-2023 XEZIOS PROJECT")
					imgui.EndChild()
					imgui.EndGroup()
					imgui.EndGroup()
					imgui.SameLine()
					imgui.PopStyleColor(1)
					imgui.End()
					imgui.PopStyleColor(2)
				end
			end  -- if (thisScript().version) < (version_check) then
		--elseif tonumber(thisScript().version) < tonumber(version_check) then
		elseif version_status == 'missupdate' then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(193, 234), imgui.Cond.FirstUseEver)
			imgui.Begin('##Settings#updates#new', script.settings, 1+2+32+128+2048)
			
			imgui.SetCursorPosX(imgui.GetWindowWidth()/2-(128/2))
			imgui.Image(script.icon_out, imgui.ImVec2(128, 128))
			imgui.PushFont(fontsize)
			imgui.CenterText('You use an old version')
			imgui.Text("Current version: "..(thisScript().version))
			imgui.Text("Latest version: "..(version_check))
			imgui.PopFont()
			imgui.Separator()
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
			if script.start_updating then
				HoveredClr()
					imgui.Button('Downloading...', imgui.ImVec2(-0.1, 0))
				imgui.PopStyleColor(4)
				downloadUrlToFile('https://sadfi2259x.github.io/xezios-project/update/XEZIOS.luac', getWorkingDirectory()..'\\XEZIOS.luac', function (id, status, p1, p2)
					if status == dlstatus.STATUSEX_ENDDOWNLOAD then
						thisScript():reload()
					end
				end)
			else
				if imgui.Button('Update now !', imgui.ImVec2(-0.1, 0)) then
					script.start_updating = true
				end
			end
			imgui.PopStyleVar()
			imgui.End()
		elseif version_status == 'error' then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(236, 242), imgui.Cond.FirstUseEver)
			imgui.Begin('##Settings#updates#error_crash', script.settings, 1+2+32+128+2048)
			
			imgui.SetCursorPosX(imgui.GetWindowWidth()/2-(128/2))
			imgui.Image(script.icon_error, imgui.ImVec2(128, 128))
			imgui.TitleText("ERROR !")
			imgui.PushFont(fontsize)
			imgui.CenterText(("Error loading the project\nReson: "..update_error_reason) or "Error loading the project\nReson: Failed to get updates")
			imgui.PopFont()
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.07, 0.07, 0.07, 1.00))		
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
			imgui.Spacing()
			if imgui.Button('Check website', imgui.ImVec2(-0.1, 0)) then
				os.execute('explorer "'..script.site_url..'"')
			end
			imgui.PopStyleVar()
			--[[
			imgui.BeginChild('##error_list', imgui.ImVec2(0, 0), true)
			imgui.TextWrapped(tostring(ad_result))
			imgui.EndChild()
			--]]
			imgui.PopStyleColor(1)
			imgui.End()
		end
		if script.sms_window.v then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(808, 420), imgui.Cond.FirstUseEver) -- 790, 350
			WindowBg()
			imgui.Begin('SMS', script.sms_window, 1+2+32+128+2048)
			imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.89, 0.85, 0.92, 0.30))
			
			imgui.BeginChild('##header', imgui.ImVec2(0, 30), true)
			imgui.PushFont(fontsize)
			imgui.TextColoredRGB(' XEZIOS SMS - Best Free Private Messaging For SA-MP')
			imgui.PopFont()
			
			imgui.SameLine(imgui.GetWindowSize().x - 26)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.98, 0.06, 0.06, 1.00))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.98, 0.26, 0.26, 1.00))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.98, 0.26, 0.26, 0.40))
			if imgui.Button(" "..fa.ICON_TIMES, imgui.ImVec2(22, 22)) then 
				script.sms_window.v = not script.sms_window.v
			end
			imgui.PopStyleColor(3)
			imgui.EndChild()
			
			imgui.BeginChild('##main', imgui.ImVec2(0, 0), true)
			
			local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			if script.readdy == true then 
				imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.02, 0.02, 0.02, 1))
				imgui.BeginChild('##head', imgui.ImVec2(0, 145), true)
					imgui.BeginGroup()
						imgui.TextColoredRGB("Name: {"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")
						imgui.TextColoredRGB(string.format('{ffffff}Room handle: {949494}'..broadcaster_handle))
					imgui.EndGroup()
					imgui.SameLine(717)
					imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
					if imgui.Button(fa.ICON_TRASH..'##clean', imgui.ImVec2(33, 33)) then 
						CleanMessages()
					end
					imgui.Hint('Clean messages for you')
					imgui.SameLine()
					if imgui.Button(fa.ICON_POWER_OFF..'##Disconnect', imgui.ImVec2(33, 33)) then 
						DisconnectDromHandle(broadcaster_handle)
						CleanMessages()
					end
					imgui.Hint('Disconnect')
					imgui.PopStyleVar()
					imgui.Separator()
					if imgui.Checkbox('Play the sound when you receive the message and this window is closed', script.receive_sound) then ini.functions.receive_sound = script.receive_sound.v  inicfg.save(ini, MainSettingsdirectIni) end
					if imgui.Checkbox('Show messages sent in chat when this window is closed', script.sms_in_chat) then ini.functions.sms_in_chat = script.sms_in_chat.v  inicfg.save(ini, MainSettingsdirectIni) end
					if imgui.Checkbox('Clean chat input when send message', script.clean_on_sent) then ini.functions.clean_on_sent = script.clean_on_sent.v  inicfg.save(ini, MainSettingsdirectIni) end
					imgui.Combo('##message_color', script.messages_color, {"White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple"})
					imgui.SameLine()
					imgui.TextColoredRGB('{'..sms_hex_color..'}Your messages color')
				imgui.EndChild()
				imgui.PopStyleColor(1)
				DrawMessages()
				imgui.PushItemWidth(750)
				imgui.BeginGroup()
				imgui.PushFont(chatinsertfont)
				imgui.InputText("##message-input", script.message_input)
				imgui.EndGroup()
				imgui.SameLine()
				if imgui.Button('Send') then
					broadcaster_send(("{"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")..' ('..my_id..'): {'..sms_hex_color..'}'..script.message_input.v)
					if script.clean_on_sent.v then	
						script.message_input.v = ''
					end
				end
				imgui.PopFont()
			else
				imgui.PushFont(titlefont)
				imgui.Text('Connect with your friends !')
				imgui.PopFont()
				imgui.PushFont(descfont)
				imgui.Text('Enjoy privacy, No more limits !')
				imgui.TextColoredRGB('>> Insert any numbers to start private chat')
				imgui.TextColoredRGB('Maximum handle numbers that can be inserted: 20')
				imgui.TextColoredRGB('Maximum number of chat characters that can be sent: 79')
				imgui.PopFont()
				imgui.Separator()
				imgui.BeginGroup()
				imgui.PushItemWidth(530)
				imgui.PushFont(inputfont)
				imgui.InputText("Room handle", script.handle_input, 1+2+8)
				imgui.PopFont()
				imgui.EndGroup()
				imgui.PushFont(connectfont)
				if imgui.Button('Connect##sms', imgui.ImVec2(-0.1, 0)) then 
					if script.handle_input.v == '' then
						sampAddChatMessage('{9808cc}[SMS]: {B9C9BF}Error. You have to insert a handle', 0xB9C9BF)
					else
						ConnectToHandle(script.handle_input.v) 
						script.readdy = true 
						sampAddChatMessage('{9808cc}[SMS]: {B9C9BF}Connecting. Joining the room...', 0xB9C9BF)
						AddHistory('[LOG]: You have connected to: '..broadcaster_handle)
					end
				end
				DrawHistory()
				imgui.PopFont()
			end
			imgui.EndChild()
			
			imgui.PopStyleColor(1)
			imgui.End()
			imgui.PopStyleColor(2)
		end
		if script.iHUD.v then
			imgui.SetNextWindowSize(imgui.ImVec2(165, 113), imgui.Cond.FirstUseEver)
			imgui.Begin('INFO HUD', script.iHUD, 1+2+32+128+2048)
			
			show_stats(true)
			
			imgui.End()
		end
		if script.vHUD.v then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth -100, iScreenHeight - 44), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(170, 58), imgui.Cond.FirstUseEver)
			imgui.Begin('VEHICLE HUD', script.vHUD, 1+2+32+128+2048)
			
			if isCharInAnyCar(PLAYER_PED) then
				
				local result, vID = sampGetVehicleIdByCarHandle(pCarHandle)
				pCarHandle = storeCarCharIsInNoSave(PLAYER_PED)
				
				imgui.TextColoredRGB("Vehicle Name: {9e9e9e}"..getCarNamebyModel(getCarModel(pCarHandle)).."")
				imgui.TextColoredRGB("Vehicle Speed: {ff9f30}"..(math.floor((getCarSpeed(pCarHandle))*2)).."")
				imgui.TextColoredRGB("Vehicle Health: {ff3030}"..getCarHealth(pCarHandle).."")
				
			end
			
			if not isCharInAnyCar(PLAYER_PED) then
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.SetCursorPosX(170 / 2 - imgui.CalcTextSize('You must be driving').x / 2)
				imgui.Text('You must be driving') 
			end
			
			imgui.End()
		end 
		if script.cHUD.v then
			stamina = getSprintLocalPlayer()
			displayHud(false)
			if stamina < 100 then
				if script.StaminaHUD.v == false then
					script.StaminaHUD.v = true
				end
			else
				script.StaminaHUD.v = false
			end
			
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth - 240, iScreenHeight / 6.1 ), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(394, 127), imgui.Cond.FirstUseEver) --365
			imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 1))
			imgui.Begin('##CUSTOM HUD', script.cHUD, 1+2+32+128+2048)
			imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.89, 0.85, 0.92, 0.30))
			
			local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			phealth = sampGetPlayerHealth(my_id)
			parmour = getCharArmour(PLAYER_PED)
			money = getPlayerMoney(Player)
			pnick = sampGetPlayerNickname(my_id)
			wanted = memory.getuint8(0x58DB60)
			clist = string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")
			
			ProgressBar_size = imgui.ImVec2(241, 26)
			--imgui.BeginChild('##left', imgui.ImVec2(72, 0), true)
			imgui.BeginGroup()
			weaponname2 = getCurrentCharWeapon(PLAYER_PED)
			weaponXXX = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\xezios\\textures\\hud\\weapons\\"..weaponname2..".jpg")
			imgui.Image(weaponXXX, imgui.ImVec2(101, 101))
			weaponId = getCurrentCharWeapon(PLAYER_PED)
			Wammo = getAmmoInCharWeapon(PLAYER_PED, tostring(weaponId))
			weap = getCurrentCharWeapon(PLAYER_PED)
			if weap == 16 or weap == 17 or weap == 18 or weap == 22 or weap == 23 or weap == 24 or weap == 25 or weap == 26 or weap == 27 or weap == 28 or weap == 29 or weap == 30 or weap == 31 or weap == 32 or weap == 33 or weap == 34 or weap == 35 or weap == 36 or weap == 37 or weap == 38 or weap == 39 or weap == 41 or weap == 42 or weap == 43 then
				imgui.Text(getAmmoInClip()..' / '..Wammo)
			else
				imgui.Text("No Ammo")
			end
			imgui.EndGroup()
			--imgui.EndChild()
			imgui.SameLine()	
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.07, 0.07, 0.07, 1.00))		
			imgui.BeginChild('##right', imgui.ImVec2(0, 0), true)
			
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.02, 0.02, 0.02, 1.00))		
			imgui.BeginChild('##nick', imgui.ImVec2(272, 23), true)
			imgui.TextColoredRGB(u8('{'..clist..'}'..pnick..' ['..my_id..']'))
			--imgui.Spacing()
			imgui.EndChild()
			imgui.PopStyleColor(1)
			
			imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(1, 0, 0, 1))
			imgui.Image(script.healthimg, imgui.ImVec2(26, 26))
			imgui.SameLine()
			imgui.ProgressBar(phealth / 100, ProgressBar_size)
			imgui.PopStyleColor(1)
			
			imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.68, 0.68, 0.68, 1))
			imgui.Image(script.armourimg, imgui.ImVec2(26, 26))
			imgui.SameLine()
			imgui.ProgressBar(parmour / 100, ProgressBar_size)
			imgui.PopStyleColor(1)
				
			--[[
			if isCharInWater(playerPed) then
				imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.19, 0.85, 1, 1))
				imgui.Image(script.breathimg, imgui.ImVec2(26, 26))
				imgui.SameLine()
				imgui.ProgressBar(memory.getfloat(0xB7CDE0) / 39.97000244 / 100, imgui.ImVec2(241, 27))
				imgui.PopStyleColor(1)
			end --]]
	
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.02, 0.02, 0.02, 1.00))		
			imgui.BeginChild('##moneyandstars', imgui.ImVec2(272, 23), true)
			imgui.Columns(2, nil, false)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.07, 0.84, 0, 1))
			imgui.TextColoredRGB(money.."$")
			imgui.PopStyleColor(1)
			imgui.NextColumn()		
			wanted = memory.getuint8(0x58DB60)
			imgui.SameLine(55)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.84, 0.6, 0, 1))
			if wanted == 0 then 
				imgui.Text(fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O)
			elseif wanted == 1 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O)
			elseif wanted == 2 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O)
			elseif wanted == 3 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR_O..fa.ICON_STAR_O..fa.ICON_STAR_O)
			elseif wanted == 4 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR_O..fa.ICON_STAR_O)
			elseif wanted == 5 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR_O)
			elseif wanted == 6 then
				imgui.Text(fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR..fa.ICON_STAR)
			end
			imgui.PopStyleColor(1)
			imgui.Columns(1)
			imgui.EndChild()
			imgui.PopStyleColor(1)
	
			imgui.EndChild()
			imgui.PopStyleColor(1)
			imgui.PopStyleColor(1)
			imgui.End()
			imgui.PopStyleColor(2)
		else
			if script.StaminaHUD.v == true then
				script.StaminaHUD.v = false
			end
			displayHud(true)
		end
		if script.StaminaHUD.v then
			imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight - 30 ), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(280, 34), imgui.Cond.FirstUseEver)
			imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.43, 0.43, 0.50, 0.50))
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 1))
			imgui.Begin('##STAMINA HUD', script.StaminaHUD, 1+2+32+128+2048)
			
			stamina = getSprintLocalPlayer()
			
			imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(1, 0.62, 0.19, 1))
			imgui.Image(script.sprintimg, imgui.ImVec2(26, 26))
			imgui.SameLine()
			imgui.ProgressBar(stamina / 100, imgui.ImVec2(241, 26))
			imgui.PopStyleColor(1)
			
			imgui.End()
			imgui.PopStyleColor(2)
		end
	end
end

function imgui.AnimProgressBar(label,int,duration,size)
local function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then; local count = timer / (duration / 100); return from + (count * (to - from) / 100),timer,false
    end; return (timer > duration) and to or from,timer,true
end
    if int > 100 then imgui.TextColored(imgui.ImVec4(1,0,0,0.7),'error func imgui.AnimProgressBar(*),int > 100') return end
    if IMGUI_ANIM_PROGRESS_BAR == nil then IMGUI_ANIM_PROGRESS_BAR = {} end
    if IMGUI_ANIM_PROGRESS_BAR ~= nil and IMGUI_ANIM_PROGRESS_BAR[label] == nil then
        IMGUI_ANIM_PROGRESS_BAR[label] = {int = (int or 0),clock = 0}
    end
    local mf = math.floor
    local p = IMGUI_ANIM_PROGRESS_BAR[label];
    if (p['int']) ~= (int) then
        if p.clock == 0 then; p.clock = os.clock(); end
        local d = {bringFloatTo(p.int,int,p.clock,(duration or 2.25))}
        if d[1] > int  then
            if ((d[1])-0.01) < (int) then; p.clock = 0; p.int = mf(d[1]-0.01); end
        elseif d[1] < int then
            if ((d[1])+0.01) > (int) then; p.clock = 0; p.int = mf(d[1]+0.01); end
        end
        p.int = d[1];
    end
    imgui.PushStyleVar(6,15)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0,0,0,0))
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(1, 1, 1, 0.20)) -- background color progress bar
    imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(1, 1, 1, 0.30)) -- fill color progress bar
    imgui.ProgressBar(p.int / 100,size or imgui.ImVec2(-1,15))
    imgui.PopStyleColor(3)
    imgui.PopStyleVar()
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.CenterTextXY(text)
    local width = imgui.GetWindowWidth()
    local height = imgui.GetWindowSize().y
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.SetCursorPosY( height / 2 - calc.y / 2 )
    imgui.Text(text)
end

function imgui.CenterColoredText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.TitleText(text)
	imgui.PushFont(titlesize)
	imgui.CenterColoredText(text)
	imgui.PopFont()
end

function imgui.TaskBarText(text)
	imgui.PushFont(timefont)
	imgui.TextColoredRGB(text)
	imgui.PopFont()
end

function imgui.QueText(text)
	imgui.PushFont(QueFont)
	imgui.TextColoredRGB(text)
	imgui.PopFont()
end

function imgui.AnswerText(text)
	imgui.PushFont(AnswerFont)
	imgui.Text(text)
	imgui.PopFont()
end
function imgui.CircleButton(text, bool, number)
    if bool.v == number then
        imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 15)
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.00, 0.16, 0.16, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.00, 0.16, 0.16, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 0.16, 0.16, 1.00))
        local button = imgui.Button(text, imgui.ImVec2(10, 10))
        imgui.PopStyleColor(3)
        imgui.PopStyleVar(1)
        return button
    else
        if imgui.Button(text, imgui.ImVec2(10, 10)) then
            bool.v = number
            return true
        end
    end
end

function Sun()
    callFunction(7325088, 0, 0, -1)
end

function CleanChat()
	memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
	memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
	memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function load_settings()
	GG_SUN.v = true
	GG_fixwater.v = true
end

function static_settings()
	GG_WetRoads.v = true
	GG_SandParticle.v = true
	GG_BladeCollision.v = true
	GG_SpeedLimit.v = true
	GG_RailsResistance.v = true
	GG_SpawnFix.v = true
	GG_PauseMenuFix.v = true
	GG_AirCraftExplosionFix.v = true
	GG_HydraSniper.v = true
	GG_ClickMap.v = true
	GG_FPS.v = true
	GG_anticrasher.v = true
end

function DrawTheMenu()
	if not script.SettingsLEFT then	
		script.window.v = not script.window.v 
	elseif script.SettingsLEFT then	
		script.window.v = not script.window.v 
		script.SettingsLEFT = not script.SettingsLEFT 
	end
end

function CBUG()
	lua_thread.create(function()
	while true do 
		if GG_Cbug.v then	
			if script.radio_cbug.v == 0 then
				if isKeyDown(VK_RBUTTON) then
					if getCurrentCharWeapon(playerPed) == 24 then
						if isKeyJustPressed(VK_LBUTTON) then
							wait(70)
							setVirtualKeyDown(VK_C, true)
							wait(98)
							setVirtualKeyDown(VK_C, false)
						end
					end
				end
			elseif script.radio_cbug.v == 1 then
				if isKeyDown(VK_RBUTTON) then
					if getCurrentCharWeapon(playerPed) == 24 then
						if isKeyDown(VK_LBUTTON) or isKeyJustPressed(VK_LBUTTON) then
							wait(240)
							setVirtualKeyDown(VK_C, true)
							setVirtualKeyDown(VK_C, false)
							wait(40)
							clearCharTasksImmediately(playerPed)
						end
					end
				end
			else
				result, ped = getCharPlayerIsTargeting(playerHandle)
				current_weapon = getCurrentCharWeapon(playerPed)
				if isCharShooting(playerPed) then
					if current_weapon == 24 or current_weapon == 25 or current_weapon == 33 then   	
						wait(100)				
						clearCharTasks(playerPed)
					end
				end
			end
		end
		wait(0)
	end
	end)
end

function SMS_FUNCTIONS()
	lua_thread.create(function()
	while true do 
		if script.messages_color.v == 0 then
			sms_hex_color = 'ffffff'
		elseif script.messages_color.v == 1 then
			sms_hex_color = 'ff0000'
		elseif script.messages_color.v == 2 then
			sms_hex_color = 'F87C02'
		elseif script.messages_color.v == 3 then
			sms_hex_color = 'FFEE00'
		elseif script.messages_color.v == 4 then
			sms_hex_color = '65B339'
		elseif script.messages_color.v == 5 then
			sms_hex_color = '04ABDF'
		elseif script.messages_color.v == 6 then
			sms_hex_color = '6E38A9'
		end
		wait(0)
	end
	end)
end

function CheckFiles()
	--if not doesFileExist('moonloader\\config\\Custom NameTags\\fa5.ttf') then downloadUrlToFile('https://www.dropbox.com/s/zcevp4ryna0obvy/fa%205.ttf?dl=1', 'moonloader\\config\\Custom NameTags\\fa5.ttf') end
end

function memory_bool(arg)
    if arg then return 1 else return 0 end
end

function main()

	--[[
	if not isSampLoaded() then return end
    local blur = require("ffi").cast("void (*)(float)", 0x7030A0)
    addEventHandler("onD3DPresent", function()
        blur(true)
    end)
	--]]

	ApplySyle()
	var_teleport = 0
	font = renderCreateFont("Arial", 7, 4)
	search_weapons_pictures()
	search_ped_pictures()
    while not isSampAvailable() do wait(100) end
	SendRequests()
	--
	CBUG()
	Spam()
	SMS_FUNCTIONS()
	load_settings()
	GetActiveKey()
	GetSMSsettings()
	--
	if not doesDirectoryExist('moonloader/'..project.pName..'/music') then createDirectory('moonloader/'..project.pName..'/music') end
	if not doesDirectoryExist('moonloader/'..project.pName..'/injector') then createDirectory('moonloader/'..project.pName..'/injector') end
	pSpreadValue = memory.getfloat(0x8D2E64)
	pFloatX = readMemory(0xB6EC1C, 4, false)
    pFloatY = readMemory(0xB6EC18, 4, false)
	oldtime = memory.getint8(0xB70153, true)
	oldweather = memory.getint8(0xC81320, true)
	writeMemory(5499541, 4, 12044272, true)--removal of protection
    writeMemory(8381985, 4, 13213544, true)--removal of protection
	
    for i = 1, 7 do
        for k,v in ipairs(CPed_stat) do
            _G['C'..i] = getIntStat(v)
        end
    end
	
	if not doesDirectoryExist("config\\XEZIOS") then
		createDirectory("config\\XEZIOS")
		inicfg.save(objectfinder_table_inputs, ObjectFinderDirectIni) -- This will automatic save the object finder list
	end
	inputs = inicfg.load(nil, ObjectFinderDirectIni)
	if inputs == nil then
		inicfg.save(objectfinder_table_inputs, ObjectFinderDirectIni)
		inputs = inicfg.load(nil, ObjectFinderDirectIni)
	end
	for i, val in ipairs(inputs) do
		table.insert(ObjectFinder_Table,{imgui.ImInt(val[1]), imgui.ImBuffer((tostring(u8:decode(u8(val[2])))), 20)})
	end
	
	sampRegisterChatCommand('xezios',function()
		DrawTheMenu()
    end)
	
	while true do
		static_settings()
		
		local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		
		pPlayerPosX, pPlayerPosY, pPlayerPosZ = getCharCoordinates(PLAYER_PED)
		
        memory.setint8(0x96916E, memory_bool(GG_InfO2.v))
		setCharProofs(playerPed, GG_GM.v, GG_GM.v, GG_GM.v, GG_GM.v, GG_GM.v)
        setPlayerNeverGetsTired(playerHandle, GG_InfinityRun.v)
		ToggleNameTag(GG_NameTags.v)
		
		if isCharInAnyCar(PLAYER_PED) then
			pCarHandle = storeCarCharIsInNoSave(PLAYER_PED)
			
            memory.setint8(0x969161, memory_bool(GG_bmx.v))
			memory.setuint8(0x6C2759, memory_bool(GG_driveUnderWater.v), false)
			memory.setuint8(9867602, memory_bool(GG_Water.v), false)
			if isCharOnAnyBike(playerPed) then
				if GG_Fbike.v  then
					setCharCanBeKnockedOffBike(PLAYER_PED, true)
				else
					setCharCanBeKnockedOffBike(PLAYER_PED, false)
				end
			end
			if GG_GMWheels.v then
				setCanBurstCarTires(pCarHandle, true)
			else
				setCanBurstCarTires(pCarHandle, false)
			end
			if GG_GMCar.v then
				setCarProofs(pCarHandle, true, true, true, true, true)
			elseif not GG_GMCar.v then
				setCarProofs(pCarHandle, false, false, false, false, false)
			end
			if GG_FC.v and not isCharOnAnyBike(PLAYER_PED) then
				for i = 0, 5 do fixCarDoor(pCarHandle, i) end
				for i = 0, 6 do fixCarPanel(pCarHandle, i) end
				wait(50)
				for i = 0, 5 do popCarDoor(pCarHandle, i, true) end
				for i = 0, 6 do popCarPanel(pCarHandle, i, true) end
			end
			if GG_Tmode.v then
				setCarHeavy(pCarHandle, true)
			end
			if GG_InfinityFuel.v then
				setCarEngineOn(pCarHandle, true)
			end
			if GG_NoRadio.v and getRadioChannel(playerPed) < 12 then
				setRadioChannel(12)
			end
			if GG_CarShot.v then
				local pCamCoordX, pCamCoordY, pCamCoordZ = getActiveCameraCoordinates()
				local pTargetCamX, pTargetCamY, pTargetCamZ = getActiveCameraPointAt()
				setCarHeading(pCarHandle, getHeadingFromVector2d(pTargetCamX - pCamCoordX, pTargetCamY - pCamCoordY))
				if isKeyDown(VK_Z) then
					setCarForwardSpeed(pCarHandle, 100)
				elseif isKeyDown(VK_S) then
					setCarForwardSpeed(pCarHandle, 0.0)
				elseif isKeyDown(VK_SPACE) then
					applyForceToCar(pCarHandle, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0)
				end
			end
			if GG_Nitro.v and isKeyJustPressed(0x60) then
				giveNonPlayerCarNitro(pCarHandle)
			end
			if GG_driftInCar.v then
				if isKeyDown(VK_LCONTROL) then 
					if getCarSpeed(pCarHandle) > 3.0 then
						if isKeyDown(VK_A) or isKeyDown(VK_Q) then
							addToCarRotationVelocity(pCarHandle, 0, 0, 0.1)
						elseif isKeyDown(VK_D) or isKeyDown(VK_E) then
							addToCarRotationVelocity(pCarHandle, 0, 0, -0.1)
						end
					end
				end
			end
			if GG_altspeed.v then
				--[[
				if isKeyDown(VK_LMENU) then
					setCarForwardSpeed(pCarHandle, script.altspeedhack.v)
				end
				--]]
				if isKeyDown(VK_LMENU) then
                        if getCarSpeed(pCarHandle) * 2.01 <= script.altspeedhack.v then
                            local cVecX, cVecY, cVecZ = getCarSpeedVector(pCarHandle)
                            local heading = getCarHeading(pCarHandle)
                            local turbo = representIntAsFloat(readMemory(0xB7CB5C, 4, false)) / 85
                            local xforce, yforce, zforce = turbo, turbo, turbo
                            local Sin, Cos = math.sin(-math.rad(heading)), math.cos(-math.rad(heading))
                            if cVecX > -0.01 and cVecX < 0.01 then xforce = 0.0 end
                            if cVecY > -0.01 and cVecY < 0.01 then yforce = 0.0 end
                            if cVecZ < 0 then zforce = -zforce end
                            if cVecZ > -2 and cVecZ < 15 then zforce = 0.0 end
                            if Sin > 0 and cVecX < 0 then xforce = -xforce end
                            if Sin < 0 and cVecX > 0 then xforce = -xforce end
                            if Cos > 0 and cVecY < 0 then yforce = -yforce end
                            if Cos < 0 and cVecY > 0 then yforce = -yforce end
                            applyForceToCar(pCarHandle, xforce * Sin, yforce * Cos, zforce / 2, 0.0, 0.0, 0.0)
                        end
                    end
				
			end
			if GG_CarJump.v then
				if isKeyJustPressed(key.VK_LSHIFT) then
                    local cVecX, cVecY, cVecZ = getCarSpeedVector(pCarHandle)
                    if cVecZ < 7.0 then applyForceToCar(pCarHandle, 0.0, 0.0, script.lengthJump.v, 0.0, 0.0, 0.0) end
                end
			end
		end
		if GG_FastRotation.v then
			memory.write(getCharPointer(playerPed) + 0x560, 1096816768, 4, 0)
		else
			memory.write(getCharPointer(playerPed) + 0x560, 1089570464, 4, 0)
		end
		
		if GG_rvanka.v then
            local closestId = getClosestPlayerId()
			local result, handle = sampGetCharHandleBySampPlayerId(closestId)
			if result then
				closestPlayer = handle
            end
		end
		
		if GG_Chams.v then
            for k,v in ipairs(getAllChars()) do
                if v ~= PLAYER_PED then
                    if ChamsQuery[v] then
                        if not isCharOnScreen(v) then			
                            RemoveFromChamsQuery(v)
                        end
                    elseif isCharOnScreen(v) then
                        local _, id = sampGetPlayerIdByCharHandle(v)
                        AddPlayerToChamsQuery(v, sampGetPlayerColor(id))
                    end
                end
            end
        else
            for k,v in pairs(getAllChars()) do
                RemoveFromChamsQuery(v)
            end
        end
		
		if GG_NoFall.v then
    		if isCharPlayingAnim(PLAYER_PED, 'KO_SKID_BACK') or isCharPlayingAnim(playerPed, 'FALL_COLLAPSE') then
                clearCharTasksImmediately(PLAYER_PED)
            end
    	end
		if GG_DeathF.v then
			for i = 0, sampGetMaxPlayerId(false) do
				if sampGetPlayerIdByCharHandle(PLAYER_PED) ~= i and sampIsPlayerConnected(i) then
					sampSendDeathByPlayer(i, 0)
				end
			end
		end
		if GG_MegaJump.v then
    		memory.setint8(0x96916C, 1)
    	elseif not GG_MegaJump.v then
    		memory.setint8(0x96916C, 0)
    	end
    	if GG_AntiStun.v then
    		setCharUsesUpperbodyDamageAnimsOnly(PLAYER_PED, 1)
    	elseif not GG_AntiStun.v then
    		setCharUsesUpperbodyDamageAnimsOnly(PLAYER_PED, 0)
    	end
		if GG_AntiAfk.v then
        	memory.setuint8(7634870, 1, false)
            memory.setuint8(7635034, 1, false)
            memory.fill(7623723, 144, 8, false)
            memory.fill(5499528, 144, 6, false)
        elseif not GG_AntiAfk.v then
        	memory.setuint8(7634870, 0, false)
            memory.setuint8(7635034, 0, false)
            memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
            memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
        end
		if GG_FastWalk.v then
    		for k,v in pairs(pAnimationWalk) do
                setCharAnimSpeed(PLAYER_PED, v, script.fastwalk.v)
            end
    	elseif not GG_FastWalk.v then
    		for k,v in pairs(pAnimationWalk) do
    			setCharAnimSpeed(PLAYER_PED, v, 1.0)
    		end
    	end
		if GG_AirBreak.v then
			if wasKeyPressed(0xA1) then
				airbreak = not airbreak
			end
			if airbreak then
				local charCoordinates = {getCharCoordinates(PLAYER_PED)}
				local ViewHeading = getCharHeading(PLAYER_PED)
				Coords = {charCoordinates[1], charCoordinates[2], charCoordinates[3], 0.0, 0.0, ViewHeading}
				local MainHeading = getCharHeading(PLAYER_PED)
				local Camera = {getActiveCameraCoordinates()}
				local Target = {getActiveCameraPointAt()}
				local RotateHeading = getHeadingFromVector2d(Target[1] - Camera[1], Target[2] - Camera[2])
				if isKeyDown(0x26) then
					Coords[1] = Coords[1] + script.AirBreakSpeed.v * math.sin(-math.rad(RotateHeading))
					Coords[2] = Coords[2] + script.AirBreakSpeed.v * math.cos(-math.rad(RotateHeading))
					setCharHeading(PLAYER_PED, RotateHeading)
				elseif isKeyDown(0x28) then
					Coords[1] = Coords[1] - script.AirBreakSpeed.v * math.sin(-math.rad(MainHeading))
					Coords[2] = Coords[2] - script.AirBreakSpeed.v * math.cos(-math.rad(MainHeading))
				end
				if isKeyDown(0x25) then
					Coords[1] = Coords[1] - script.AirBreakSpeed.v * math.sin(-math.rad(MainHeading - 90))
					Coords[2] = Coords[2] - script.AirBreakSpeed.v * math.cos(-math.rad(MainHeading - 90))
				elseif isKeyDown(0x27) then
					Coords[1] = Coords[1] - script.AirBreakSpeed.v * math.sin(-math.rad(MainHeading + 90))
					Coords[2] = Coords[2] - script.AirBreakSpeed.v * math.cos(-math.rad(MainHeading + 90))
				end
				if isKeyDown(0x20) then Coords[3] = Coords[3] + script.AirBreakSpeed.v / 1.5 end
				if isKeyDown(0xA0) and Coords[3] > -95.0 then Coords[3] = Coords[3] - script.AirBreakSpeed.v / 1.5 end
				setCharCoordinates(PLAYER_PED, Coords[1], Coords[2], Coords[3] - 1)
			end
		end
		if GG_InfinityAmmo.v then
    		memory.write(0x969178, 1, 1, true)
    	elseif not GG_InfinityAmmo.v then
    		memory.write(0x969178, 0, 1, true)
    	end
		if GG_FullSkills.v then
			for k,v in ipairs(CPed_stat) do
                registerIntStat(v, 1000)
            end
		elseif not GG_FullSkills.v then
			for k,v in ipairs(CPed_stat) do
                for i = 1, 7 do
                    registerIntStat(v, (k == i and _G['C'..i]))
                end
            end
		end
		if GG_noCamRestore.v then
			memory.write(0x5109AC, 235, 1, true)
            memory.write(0x5109C5, 235, 1, true)
            memory.write(0x5231A6, 235, 1, true)
            memory.write(0x52322D, 235, 1, true)
            memory.write(0x5233BA, 235, 1, true)
        else
            memory.write(0x5109AC, 122, 1, true)
            memory.write(0x5109C5, 122, 1, true)
            memory.write(0x5231A6, 117, 1, true)
            memory.write(0x52322D, 117, 1, true)
            memory.write(0x5233BA, 117, 1, true)
        end
		if GG_NoReload.v then
        	Bs = raknetNewBitStream()
            raknetBitStreamWriteInt32(Bs, getCurrentCharWeapon(PLAYER_PED))
            raknetBitStreamWriteInt32(Bs, 0)
            raknetEmulRpcReceiveBitStream(22, Bs)
            raknetDeleteBitStream(Bs)
        end
		if GG_NoSpread.v then
    		memory.setfloat(0x8D2E64, 0)
		--writeMemory(0x8D6114, 4, 20, true)
    	elseif not GG_NoSpread.v then
    		memory.setfloat(0x8D2E64, pSpreadValue)
    	end
		if GG_SensFix.v then
            writeMemory(0xB6EC18, 4, pFloatX, false)
        elseif not GG_SensFix.v then
            writeMemory(0xB6EC18, 4, pFloatY, false)
        end
		if GG_damager.v then
            local data = samp_create_sync_data('bullet')
            data.targetType = 1
            data.targetId = getClosestPlayerId()
            data.origin.x, data.origin.y, data.origin.z = getActiveCameraCoordinates()
            data.weaponId = getCurrentCharWeapon(PLAYER_PED)
            data.send()
        end	
		if GG_cdamage.v then 
            local data = samp_create_sync_data('bullet')
            data.targetType = 1
            data.targetId = getClosestPlayerId()
            data.origin.x, data.origin.y, data.origin.z = getActiveCameraCoordinates()
            data.weaponId = 38
            data.send()
        end	
		if GG_Rapid.v then
			for k,v in pairs(pGunsAnimations) do
                setCharAnimSpeed(PLAYER_PED, v, script.RapidSpeed.v)
            end
		elseif not GG_Rapid.v then
			for k,v in pairs(pGunsAnimations) do
                setCharAnimSpeed(PLAYER_PED, v, 1.0)
            end
		end
        if GG_SkeletalWallHack.v then
            for i = 0, sampGetMaxPlayerId() do
                if sampIsPlayerConnected(i) then
                    local result, cped = sampGetCharHandleBySampPlayerId(i)
                    local wh_color = sampGetPlayerColor(i)
                    local aa, rr, gg, bb = explode_argb(wh_color)
                    local wh_color = join_argb(255, rr, gg, bb)
                    if result then
                        if doesCharExist(cped) and isCharOnScreen(cped) then
                        local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
							for v = 1, #t do
								pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
								pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 2, wh_color)
							end
							for v = 4, 5 do
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 2, wh_color)
							end
							local t = {53, 43, 24, 34, 6}
							for v = 1, #t do
								posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
								pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
							end
                        end
                    end
                end
            end	
        end
		if GG_espbox.v then
			for k,v in ipairs(getAllChars()) do 
                if v ~= playerPed then
                    if isCharOnScreen(v) then
						local pos = {getCharCoordinates(v)}
						local pos_1 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] - 0.3, pos[3] - 1)}
						local pos_2 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] + 0.3, pos[3] - 1)}
						renderDrawLine(pos_2[1], pos_2[2], pos_1[1], pos_1[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_3 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] + 0.3, pos[3] + 1)}
						renderDrawLine(pos_2[1], pos_2[2], pos_3[1], pos_3[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_4 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] - 0.3, pos[3] + 1)}
						renderDrawLine(pos_3[1], pos_3[2], pos_4[1], pos_4[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_5 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] - 0.3, pos[3] - 1)}
						renderDrawLine(pos_4[1], pos_4[2], pos_5[1], pos_5[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))	
						local pos_1 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] - 0.3, pos[3] - 1)}
						local pos_2 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] - 0.3, pos[3] - 1)}
						renderDrawLine(pos_2[1], pos_2[2], pos_1[1], pos_1[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_3 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] + 0.3, pos[3] - 1)}
						local pos_4 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] + 0.3, pos[3] - 1)}
						renderDrawLine(pos_3[1], pos_3[2], pos_4[1], pos_4[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_5 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] + 0.3, pos[3] + 1)}						
						local pos_6 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] + 0.3, pos[3] + 1)}
						renderDrawLine(pos_5[1], pos_5[2], pos_6[1], pos_6[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))		
						local pos_5 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] - 0.3, pos[3] + 1)}
						local pos_6 = {convert3DCoordsToScreen(pos[1] + 0.3, pos[2] - 0.3, pos[3] + 1)}
						renderDrawLine(pos_5[1], pos_5[2], pos_6[1], pos_6[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))				
						local pos_1 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] - 0.3, pos[3] - 1)}
						local pos_2 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] + 0.3, pos[3] - 1)}
						renderDrawLine(pos_2[1], pos_2[2], pos_1[1], pos_1[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))		
						local pos_3 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] + 0.3, pos[3] + 1)}
						renderDrawLine(pos_2[1], pos_2[2], pos_3[1], pos_3[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))		
						local pos_4 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] - 0.3, pos[3] + 1)}
						renderDrawLine(pos_3[1], pos_3[2], pos_4[1], pos_4[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
						local pos_5 = {convert3DCoordsToScreen(pos[1] - 0.3, pos[2] - 0.3, pos[3] - 1)}
						renderDrawLine(pos_4[1], pos_4[2], pos_5[1], pos_5[2], 2, sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(v))))
                    end
                end
            end
		end
		if GG_esplines.v then
			local my_pos = {getCharCoordinates(playerPed)}
            for k,v in ipairs(getAllChars()) do
                local result, id = sampGetPlayerIdByCharHandle(v)
                if result then
                    if v ~= playerPed then
                        if isCharOnScreen(v) then
                            local other_pos = {getCharCoordinates(v)}
                            local resultm, mposX, mposY, mposZ, mposW, mposH = convert3DCoordsToScreenEx(my_pos[1], my_pos[2], my_pos[3], true, true)
                            local resulto, oposX, oposY, oposZ, oposW, oposH = convert3DCoordsToScreenEx(other_pos[1], other_pos[2], other_pos[3], true, true)
                            if resultm and resulto then
                                renderDrawLine(mposX, mposY, oposX, oposY, (1 == 0 and 1 or 1 + 1), sampGetPlayerColor(id))
                            end
                        end
                    end
                end
            end
		end
		if GG_DisableChangeColorUnderWater.v then
		    DisableChangeColorUnderWater(true)
		elseif not GG_DisableChangeColorUnderWater.v then
		    DisableChangeColorUnderWater(false)
		end
		if GG_DisableUnderWaterEffects.v then
		    DisableUnderWaterEffects(true)
		elseif not GG_DisableUnderWaterEffects.v then
		    DisableUnderWaterEffects(false)
		end
		if GG_DisableWater.v then
		    DisableWater(true)
		elseif not GG_DisableWater.v then
		    DisableWater(false)
		end
		
		if teleporter.quick_teleport.v == true then
			if isKeyDown(keys.quick_teleport1) and isKeyDown(keys.quick_teleport2) then
				while isKeyDown(keys.quick_teleport1) and isKeyDown(keys.quick_teleport2) do
					wait(0)
				end
				Teleport()
			end
		end
		if GG_objectwallhack.v then
			for _, v in pairs(getAllObjects()) do
				local asd
				if sampGetObjectSampIdByHandle(v) ~= -1 then
					asd = sampGetObjectSampIdByHandle(v)
				end
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					if GG_objectwallhack.v then
						for _, v2 in ipairs(ObjectFinder_Table) do
							if v2[1].v == model then
								if v2[1].v == 1212 then
									MODEL_TEXT = ("{FF5656}< {04e800}Money\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 1276 then
									MODEL_TEXT = ("{FF5656}< {9f00e8}Package\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 1240 then
									MODEL_TEXT = ("{FF5656}< {e80000}Health\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 1241 then
									MODEL_TEXT = ("{FF5656}< {e80000}Adrenaline\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 11736 then
									MODEL_TEXT = ("{FF5656}< {e80000}Medical Satchel\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 11738 then
									MODEL_TEXT = ("{FF5656}< {e80000}Medic Case\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 19941 then
									MODEL_TEXT = ("{FF5656}< {ffc800}Gold Bar\n{ffffff}distance: {FF5656}"..distance)
								elseif v2[1].v == 1247 then
									MODEL_TEXT = ("{FF5656}< {fc9803}Bribe\n{ffffff}distance: {FF5656}"..distance)
								else
									MODEL_TEXT = ("{FF5656}< {ffffff}model = {FF5656}"..model.."\n{ffffff}distance: {FF5656}"..distance)
								end
								renderFontDrawText(font, MODEL_TEXT, x1, y1, -1)
								if GG_objtraser.v then
									renderDrawLine(x10, y10, x1, y1, 1.0, -1)
								end
							end
						end
					end
				end
			end
		end
		if GG_SUN.v then
		    Sun()
    	end
		if GG_WetRoads.v then
			memory.fill(0x72BB9F, 0x90, 12, true)
			memory.fill(0x72BBAB, 0x90, 20, true)
			memory.fill(0x72BBCB, 0x90, 12, true)
			memory.fill(0x72B940, 0x90, 5, true)
			memory.fill(0x72B92B, 0x90, 5, true)
			memory.fill(0x72B959, 0x90, 5, true)
		end
		if GG_SandParticle.v then
			memory.fill(0x6AA8CF, 0x90, 53, true)
		end
		if GG_BladeCollision.v then
			memory.fill(0x6C5107, 0x90, 59, true)
		end
		if GG_SpeedLimit.v then
			memory.fill(0x544CF0, 0x90, 14, true)
		end
		if GG_RailsResistance.v then
			memory.setfloat(0x8D34AC, 0.0, true) 
		end
		if GG_SpawnFix.v then
			memory.fill(0x4217F4, 0x90, 21, true)
			memory.fill(0x4218D8, 0x90, 17, true)
			memory.fill(0x5F80C0, 0x90, 10, true)
			memory.fill(0x5FBA47, 0x90, 10, true)
		end
		if GG_PauseMenuFix.v then
			local oldProtect = memory.unprotect(0x748063, 5)
			memory.hex2bin('E8F83BDFFF', 0x748063, 5)
			memory.protect(0x748063, 5, oldProtect)
		end
		if GG_HydraSniper.v then
			if isPlayerPlaying(PLAYER_HANDLE) then
                local player = {getCharCoordinates(PLAYER_PED)}
                local result, vehicle = findAllRandomVehiclesInSphere(player[1], player[2], player[3], 10.0, true, true)
                if result then
                    local carModel = getCarModel(vehicle)
                    if carModel == 520 or carModel == 425 then
                        if getPadState(PLAYER_HANDLE, 15) == 255 then
                            setCurrentCharWeapon(PLAYER_PED, 0)
                        end
                    end
                end
            end
		end
		if GG_ClickMap.v and id == 119 then
			local posX, posY, posZ = raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs)
			requestCollision(posX, posY)
			loadScene(posX, posY, posZ)
			local res, x, y, z = getTargetBlipCoordinates()
			if res then
				local new_bs = raknetNewBitStream()
				raknetBitStreamWriteFloat(new_bs, x)
				raknetBitStreamWriteFloat(new_bs, y)
				raknetBitStreamWriteFloat(new_bs, z + 0.5)
				raknetSendRpcEx(119, new_bs, priority, reliability, channel, shiftTimestamp)
				raknetDeleteBitStream(new_bs)
			end
			return false
		end
		if GG_AirCraftExplosionFix.v then
			memory.setuint32(0x736F88, 0, true)
		end
		if GG_FPS.v then
		    memory.write(sampGetBase() + 0x9D9D0, 0x5051FF15, 4, true)
            memory.write(0xBAB318, 0, 1, true)
            memory.write(0x53E94C, 0, 1, true)
    	end	
		if GG_blur.v then
		    writeMemory(0x704E8A, 1, 0xE8, true)
			writeMemory(0x704E8B, 1, 0x11, true)
			writeMemory(0x704E8C, 1, 0xE2, true)
			writeMemory(0x704E8D, 1, 0xFF, true)
			writeMemory(0x704E8E, 1, 0xFF, true)
		end
		if GG_fpsboost.v then
		    memory.write(7358318, 2866, 4, false)--postfx off
            memory.write(7358314, -380152237, 4, false)--postfx off
		elseif not GG_fpsboost.v then
		    memory.write(7358318, 1448280247, 4, false)--postfx on
            memory.write(7358314, -988281383, 4, false)--postfx on
		end
		if GG_fixwater.v then
		    memory.setfloat(13101856, 0.0, false)
            memory.write(7249056, 13101856, 4, false)
            memory.write(7249115, 13101856, 4, false)
            memory.write(7249175, 13101856, 4, false)
            memory.write(7249235, 13101856, 4, false)
		elseif not GG_fixwater.v then
		    memory.write(7249056, 8752012, 4, false)
            memory.write(7249115, 8752012, 4, false)
            memory.write(7249175, 8752012, 4, false)
            memory.write(7249235, 8752012, 4, false)
		end
		if GG_anticrasher.v then
		    memory.write(sampGetBase() + 0x5CF2C, 0x90909090, 4, true)
            memory.write(sampGetBase() + 0x5CF2C + 4, 0x90, 1, true)
            memory.write(sampGetBase() + 0x5CF2C + 4 + 9, 0x90909090, 4, true)
            memory.write(sampGetBase() + 0x5CF2C + 4 + 9 + 4, 0x90, 1, true)
		elseif not GG_anticrasher.v then
		    memory.write(sampGetBase() + 0x5CF2C, 7729128, 4, true)
            memory.write(sampGetBase() + 0x5CF2C + 4, 0, 1, true)
            memory.write(sampGetBase() + 0x5CF2C + 4 + 9, 2097870979, 4, true)
            memory.write(sampGetBase() + 0x5CF2C + 4 + 9 + 4, 14, 1, true)
		end
		if GG_fmoney.v then
		    memory.write(5707667, 137, 1, false)
		elseif not GG_fmoney.v then
		    memory.write(5707667, 139, 1, false)
		end
		if GG_lmap.v then
		    memory.write(6359759, 144, 1, false)-- вкл
            memory.write(6359760, 144, 1, false)-- вкл
            memory.write(6359761, 144, 1, false)-- вкл
            memory.write(6359762, 144, 1, false)-- вкл
            memory.write(6359763, 144, 1, false)-- вкл
            memory.write(6359764, 144, 1, false)-- вкл
            memory.write(6359778, 144, 1, false)-- вкл
            memory.write(6359779, 144, 1, false)-- вкл
            memory.write(6359780, 144, 1, false)-- вкл
            memory.write(6359781, 144, 1, false)-- вкл
            memory.write(6359782, 144, 1, false)-- вкл
            memory.write(6359783, 144, 1, false)-- вкл
            memory.write(6359784, 144, 1, false)-- вкл
            memory.write(6359785, 144, 1, false)-- вкл
            memory.write(6359786, 144, 1, false)-- вкл
            memory.write(6359787, 144, 1, false)-- вкл
            memory.write(5637016, 12044024, 4, false)-- вкл
            memory.write(5637032, 12044024, 4, false)-- вкл
            memory.write(5637048, 12044024, 4, false)-- вкл
            memory.write(5636920, 12044048, 4, false)-- вкл
            memory.write(5636936, 12044072, 4, false)-- вкл
            memory.write(5636952, 12044096, 4, false)-- вкл
			
			memory.setfloat(9228384, 0.800, false)
            memory.setfloat(12044024, 0.800, false)
            memory.setfloat(12044048, 0.800, false)
            memory.setfloat(12044072, 0.800, false)
            memory.setfloat(12044096, 0.800, false)
		elseif not GG_lmap.v then
		    memory.write(6359759, 217, 1, false)-- выкл
            memory.write(6359760, 21, 1, false)-- выкл
            memory.write(6359761, 96, 1, false)-- выкл
            memory.write(6359762, 208, 1, false)-- выкл
            memory.write(6359763, 140, 1, false)-- выкл
            memory.write(6359764, 0, 1, false)-- выкл
            memory.write(6359778, 199, 1, false)-- выкл
            memory.write(6359779, 5, 1, false)-- выкл
            memory.write(6359780, 96, 1, false)-- выкл
            memory.write(6359781, 208, 1, false)-- выкл
            memory.write(6359782, 140, 1, false)-- выкл
            memory.write(6359783, 0, 1, false)-- выкл
            memory.write(6359784, 0, 1, false)-- выкл
            memory.write(6359785, 0, 1, false)-- выкл
            memory.write(6359786, 128, 1, false)-- выкл
            memory.write(6359787, 63, 1, false)-- выкл
            memory.write(5637016, 12043448, 4, false)-- выкл
            memory.write(5637032, 12043452, 4, false)-- выкл
            memory.write(5637048, 12043456, 4, false)-- выкл
            memory.write(5636920, 12043424, 4, false)-- выкл
            memory.write(5636936, 12043428, 4, false)-- выкл
            memory.write(5636952, 12043432, 4, false)-- выкл
		end
		if GG_MEMORY.v then
		    writeMemory(9067136, 4, (script.pMemory.v * 1048576), true)
    	elseif not GG_MEMORY.v then
		    writeMemory(9067136, 4, 536870912, true)
    	end
		if GG_CMEM.v then
            if tonumber(get_memory()) > tonumber(script.pMemSize.v) then
                CleanMemory()
            end
        end
		if GG_DrawDist.v then
	        memory.setfloat(12044272, script.pDrawEdit.v, true)
		elseif not GG_DrawDist.v then
		    memory.setfloat(12044272, 800, true)
		end
		if GG_FogDist.v then
            memory.setfloat(13210352, script.pFogEdit.v, true)
		elseif not GG_FogDist.v then
            memory.setfloat(13210352, 200, true)
    	end
		if GG_LogDist.v then
			memory.setfloat(0x858FD8, script.pLogEdit.v, false)  
		elseif not GG_LogDist.v then
            memory.setfloat(0x858FD8, 500, false)
    	end
		if GG_Time.v then
			memory.setint8(0xB70153, tonumber(script.pTime.v), true)
    	end
		if GG_Weather.v then
			memory.setint8(0xC81320, tonumber(script.pWeather.v), true)
    	end
		if GG_Fovedit.v then
            cameraSetLerpFov(script.pFovedit.v, script.pFovedit.v, 999988888, true)
    	end
		if GG_camshake.v then
			shakeCam(script.pCamshake.v)
		else
			--shakeCam(0)
		end
		if GG_trigger.v then
			if isKeyDown(VK_RBUTTON) then
				local cam_x, cam_y, cam_z = getActiveCameraCoordinates()
				local width, heigth = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
				local aim_x, aim_y, aim_z = convertScreenCoordsToWorld3D(width, heigth, 50.0)
				local result, colPoint = processLineOfSight(cam_x, cam_y, cam_z, aim_x, aim_y, aim_z, false, false, true, false, false, false, false) 
				if result then
					if isLineOfSightClear(cam_x, cam_y, cam_z, colPoint.pos[1], colPoint.pos[2], colPoint.pos[3], true, true, false, true, true) then
						if colPoint.entityType == 3 then
							if getCharPointerHandle(colPoint.entity) ~= playerPed then
								if os.clock() - trigger_osclock > 0.0 then
									trigger_osclock = os.clock()
									writeMemory(0xB7347A, 4, 255, 0)
								end
							end
						end
					end
				end
			end
		end
		if GG_gtavaim.v then
			local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
			if not isCharSittingInAnyCar(PLAYER_PED) then
				if not isCharInAnyTrain(PLAYER_PED) then
					if not isCharSwimming(PLAYER_PED) then
						if isKeyDown(VK_RBUTTON) then
							wp = getCurrentCharWeapon(playerPed)
							if wp == 22 or wp == 23  or wp == 24  or wp == 25  or wp == 26  or wp == 27  or wp == 28  or wp == 29  or wp == 32  or wp == 30  or wp == 31  or wp == 33  or wp == 38 then
								result, ped = getCharPlayerIsTargeting(playerHandle)
								if result then
									changeCrosshairColor(join_argb(0, 0, 0, 0))
									renderDrawBoxWithBorder(crosshairPos[1]-1.5, crosshairPos[2]-1.5, 3, 3, 0xFFFF0000, 0, 0xFFFF0000)
								else
									changeCrosshairColor(join_argb(0, 0, 0, 0))
									renderDrawBoxWithBorder(crosshairPos[1]-1.5, crosshairPos[2]-1.5, 3, 3, 0xFFFFFFFF, 0, 0xFFFFFFFF)
								end
							end
						end
					end
				end
			end
		else
			changeCrosshairColor(join_argb(255, 255, 255, 255))
		end
		if GG_AimBot.v then
			if script.aimbot_type.v == 0 then
				local result, ped = getCharPlayerIsTargeting(playerHandle)
				if result then
					local trush_true, trager_id = sampGetPlayerIdByCharHandle(ped)
					local myPos = {getActiveCameraCoordinates()}
					local enPos = {getCharCoordinates(ped)}
					local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
					if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
					local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
					local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
					local difference = {angle[1] - view[1], angle[2] - view[2]}
					local smooth = {difference[1] / 1.0, difference[2] / 1.0}
					if aimbot.team_ignore.v then
						local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
						local ABtarget_color = (''..(string.gsub(("%X"):format(sampGetPlayerColor(trager_id)), "..(......)", "%1"))..'')
						local ABmy_color = (''..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1"))..'')
						if ABtarget_color == ABmy_color then
						
						else
							setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
						end
					else
						setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
					end
				end
			elseif script.aimbot_type.v == 1 then
				if getCurrentCharWeapon(playerPed) ~= 0 then
					if isKeyDown(VK_RBUTTON) then
						local playerID = GetNearestPed()
						if playerID ~= -1 then
							local result, v = sampGetCharHandleBySampPlayerId(playerID)
							if result then
								if doesCharExist(v) then
									if not isCharInAnyCar(v) then
										if (aimbot.proSkipDead.v and not isCharDead(v)) or (true) then
											if v ~= playerPed then
												local my_pos = {getCharCoordinates(playerPed)}
												local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
												local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
												local heading = getCharHeading(playerPed)
												local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
												setCharCoordinates(v, (my_pos[1] + math.sin(-math.rad(angle)) * 1.1) + (math.sin(-math.rad(angle)) / 2) - (0.3 * math.sin(-math.rad(angle + 90))), (my_pos[2] + math.cos(-math.rad(angle)) * 1.1) + (math.cos(-math.rad(angle)) / 2) - (0.3 * math.cos(-math.rad(angle + 90))), my_pos[3] - 0.6)
												setCharHeading(v, heading)
											end
										end
									end
								end
							end
						end
					end
				end
			else
			
				if isKeyDown(VK_RBUTTON) then
					local playerID = GetNearestPed()
					if playerID ~= -1 then
						if (aimbot.disabledOnAnim.v and animationPlaying() or true) then
							local result, my_id = sampGetPlayerIdByCharHandle(playerPed)
							if result then
								local myColor = sampGetPlayerColor(my_id)
								local plColor = sampGetPlayerColor(playerID)
								if (aimbot.disabledIfFriend.v and (sampGetPlayerColor(my_id) == sampGetPlayerColor(playerID) and false or true) or true) then
									local pedID = sampGetPlayerIdByCharHandle(playerPed)
									local result, handle = sampGetCharHandleBySampPlayerId(playerID)
									local myPos = {getActiveCameraCoordinates()}
									if result then
										if (aimbot.skipDead.v and isCharDead(handle) or (true)) then
											if (aimbot.disabledOnAFk.v and ( not sampIsPlayerPaused(playerID) ) or true ) then
												local enPos = {getBodyPartCoordinates(GetNearestBone(handle), handle)}
												if isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true) then
													local pedWeapon = getCurrentCharWeapon(playerPed)
													if pedWeapon ~= 0 then
														if (pedWeapon >= 22 and pedWeapon <= 29) or pedWeapon == 32 then
															coefficent = 0.04253
														elseif pedWeapon == 30 or pedWeapon == 31 then
															coefficent = 0.028
														elseif pedWeapon == 33 then
															coefficent = 0.01897
														end
														local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2]}
														local angle = math.acos(vector[1] / math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2))))
														local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
														if (vector[1] <= 0.0 and vector[2] >= 0.0) or (vector[1] >= 0.0 and vector[2] >= 0.0) then
															dif = (angle + coefficent) - view[1]
														end
														if (vector[1] >= 0.0 and vector[2] <= 0.0) or (vector[1] <= 0.0 and vector[2] <= 0.0) then
															dif = (-angle + coefficent) - view[1]
														end
														local smooth = dif / ((aimbot.smoothSpeed.v * 5) * aimbot.addSmoothSpeed.v)
														if smooth > 0.0 then
															if smooth < lastsmooth then
																smooth = smooth * (lastsmooth / smooth)
															end
														else 
															if -smooth < -lastsmooth then
																smooth = smooth * (-lastsmooth / -smooth)
															end
														end
														lastsmooth = smooth
														if smooth > -1.0 and smooth < 0.5 and dif > -2.0 and dif < 2.0 then
															view[1] = view[1] + smooth
															setCameraPositionUnfixed(view[2], view[1])
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			
			end
		
		end
		if GG_WaterX.v then
		    if GG_rWater.v then
			    local r, g, b, a = rainbow(script.pWaterSpeed.v, 1, 120)
			    --editVehicleLightsColor(join_argb(a, b, g, r))
				changeWaterColorRGB(r, g, b, a)
		    end
		end
		if not GG_rWater.v then
		    if GG_WaterX.v then
		        changeWaterColorRGB(WATER_RPG.v[1] * 255, WATER_RPG.v[2] * 255, WATER_RPG.v[3] * 255, WATER_RPG.v[4] * 255)
		    end
		end 
		if not GG_WaterX.v then
		    changeWaterColorRGB(0, 194, 255)
		end	
		
		if GG_ObjectCollision.v then
			local pObjectFoundResult, pFindedObject = findAllRandomObjectsInSphere(pPlayerPosX, pPlayerPosY, pPlayerPosZ, 10, 1)
    		if pObjectFoundResult then
    			if pFindedObject > 0 then
    				setObjectCollision(pFindedObject, false)
    			end
    		end
		end
		
		if GG_BlockDrugsAnimation.v then
			for k,v in pairs(pOverdoseAnimations) do
                if isCharPlayingAnim(PLAYER_PED, v) then
                    clearCharTasksImmediately(PLAYER_PED)
                end
            end
		end
		
		if GG_OVERHP.v then
			memory.setfloat(0xB793E0, 910.4)
        elseif not GG_OVERHP.v then
            memory.setfloat(0xB793E0, 569.0)
        end
		
		if GG_RPName.v then
			nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
			if nickname:match("%w+_%w+") then
				sampSetLocalPlayerName(nickname:gsub("_", " "))
			end
		end
		
		if script.injectortype.v == 0 then
			injectfiletype = '.dll'
		else
			injectfiletype = '.asi'
		end
		
		wait(0)
		if script.activekey.v == 0 then
			if wasKeyPressed(key.VK_INSERT) then 
				DrawTheMenu()
			end
		elseif script.activekey.v == 1 then
			if wasKeyPressed(key.VK_DELETE) then 
				DrawTheMenu()
			end
		elseif script.activekey.v == 2 then
			if wasKeyPressed(key.VK_HOME) then 
				DrawTheMenu()
			end
		else
			if wasKeyPressed(key.VK_END) then 
				DrawTheMenu()
			end
		end
		imgui.Process = script.window.v or script.iHUD.v or script.vHUD.v or script.cHUD.v or script.StaminaHUD.v or script.sms_window.v or script.admin_panel.v
    end
end

function fix(angle)
	while angle > math.pi do
		angle = angle - (math.pi*2)
	end
	while angle < -math.pi do
		angle = angle + (math.pi*2)
	end
	return angle
end

function animationPlaying()
	for k, v in pairs(packet_animation) do
		if isCharPlayingAnim(playerPed, v) then
			return false
		end
	end
	return true
end

function getBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

function GetNearestPed()
    local maxDistance = nil
    maxDistance = 20000
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
                    local enPos = {getBodyPartCoordinates(GetNearestBone(handle), handle)}
                    local bonePos = {convert3DCoordsToScreen(enPos[1], enPos[2], enPos[3])}
                    local distance = math.sqrt((math.pow((bonePos[1] - crosshairPos[1]), 2) + math.pow((bonePos[2] - crosshairPos[2]), 2)))
                    if distance < aimbot.safeZone.v or distance > aimbot.jobRadius.v then check = true else check = false end
                    if not check then
                        local myPos = {getCharCoordinates(playerPed)}
                        local enPos = {getCharCoordinates(handle)}
                        local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                        if (distance < maxDistance) then
                            nearestPED = i
                            maxDistance = distance
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function GetNearestBone(handle)
    local maxDist = 20000    
    local nearestBone = -1
    bone = {42, 52, 23, 33, 3, 22, 32, 8}
    for n = 1, 8 do
        local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
        local bonePos = {getBodyPartCoordinates(bone[n], handle)}
        local enPos = {convert3DCoordsToScreen(bonePos[1], bonePos[2], bonePos[3])}
        local distance = math.sqrt((math.pow((enPos[1] - crosshairPos[1]), 2) + math.pow((enPos[2] - crosshairPos[2]), 2)))
        if (distance < maxDist) then
            nearestBone = bone[n]
            maxDist = distance
        end 
    end
    return nearestBone
end

function getCarNamebyModel(model)
    local names = {
		[400] = 'Landstalker',
		[401] = 'Bravura',
		[402] = 'Buffalo',
		[403] = 'Linerunner',
		[404] = 'Perennial',
		[405] = 'Sentinel',
		[406] = 'Dumper',
		[407] = 'Firetruck',
		[408] = 'Trashmaster',
		[409] = 'Stretch',
		[410] = 'Manana',
		[411] = 'Infernus',
		[412] = 'Voodoo',
		[413] = 'Pony',
		[414] = 'Mule',
		[415] = 'Cheetah',
		[416] = 'Ambulance',
		[417] = 'Leviathan',
		[418] = 'Moonbeam',
		[419] = 'Esperanto',
		[420] = 'Taxi',
		[421] = 'Washington',
		[422] = 'Bobcat',
		[423] = 'Mr. Whoopee',
		[424] = 'BF Injection',
		[425] = 'Hunter',
		[426] = 'Premier',
		[427] = 'Enforcer',
		[428] = 'Securicar',
		[429] = 'Banshee',
		[430] = 'Predator',
		[431] = 'Bus',
		[432] = 'Rhino',
		[433] = 'Barracks',
		[434] = 'Hotknife',
		[435] = 'Article Trailer',
		[436] = 'Previon',
		[437] = 'Coach',
		[438] = 'Cabbie',
		[439] = 'Stallion',
		[440] = 'Rumpo',
		[441] = 'RC Bandit',
		[442] = 'Romero',
		[443] = 'Packer',
		[444] = 'Monster',
		[445] = 'Admiral',
		[446] = 'Squallo',
		[447] = 'Seaspamrow',
		[448] = 'Pizzaboy',
		[449] = 'Tram',
		[450] = 'Article Trailer 2',
		[451] = 'Turismo',
		[452] = 'Speeder',
		[453] = 'Reefer',
		[454] = 'Tropic',
		[455] = 'Flatbed',
		[456] = 'Yankee',
		[457] = 'Caddy',
		[458] = 'Solair',
		[459] = 'Topfun Van',
		[460] = 'Skimmer',
		[461] = 'PCJ-600',
		[462] = 'Faggio',
		[463] = 'Freeway',
		[464] = 'RC Baron',
		[465] = 'RC Raider',
		[466] = 'Glendale',
		[467] = 'Oceanic',
		[468] = 'Sanchez',
		[469] = 'Spamrow',
		[470] = 'Patriot',
		[471] = 'Quad',
		[472] = 'Coastguard',
		[473] = 'Dinghy',
		[474] = 'Hermes',
		[475] = 'Sabre',
		[476] = 'Rustler',
		[477] = 'ZR-350',
		[478] = 'Walton',
		[479] = 'Regina',
		[480] = 'Comet',
		[481] = 'BMX',
		[482] = 'Burrito',
		[483] = 'Camper',
		[484] = 'Marquis',
		[485] = 'Baggage',
		[486] = 'Dozer',
		[487] = 'Maverick',
		[488] = 'News Maverick',
		[489] = 'Rancher',
		[490] = 'FBI Rancher',
		[491] = 'Virgo',
		[492] = 'Greenwood',
		[493] = 'Jetmax',
		[494] = 'Hotring Racer',
		[495] = 'Sandking',
		[496] = 'Blista Compact',
		[497] = 'Police Maverick',
		[498] = 'Boxville',
		[499] = 'Benson',
		[500] = 'Mesa',
		[501] = 'RC Goblin',
		[502] = 'Hotring Racer A',
		[503] = 'Hotring Racer B',
		[504] = 'Bloodring Banger',
		[505] = 'Rancher',
		[506] = 'Super GT',
		[507] = 'Elegant',
		[508] = 'Journey',
		[509] = 'Bike',
		[510] = 'Mountain Bike',
		[511] = 'Beagle',
		[512] = 'Cropduster',
		[513] = 'Stuntplane',
		[514] = 'Tanker',
		[515] = 'Roadtrain',
		[516] = 'Nebula',
		[517] = 'Majestic',
		[518] = 'Buccaneer',
		[519] = 'Shamal',
		[520] = 'Hydra',
		[521] = 'FCR-900',
		[522] = 'NRG-500',
		[523] = 'HPV1000',
		[524] = 'Cement Truck',
		[525] = 'Towtruck',
		[526] = 'Fortune',
		[527] = 'Cadrona',
		[528] = 'FBI Truck',
		[529] = 'Willard',
		[530] = 'Forklift',
		[531] = 'Tractor',
		[532] = 'Combine',
		[533] = 'Feltzer',
		[534] = 'Remington',
		[535] = 'Slamvan',
		[536] = 'Blade',
		[537] = 'Train',
		[538] = 'Train',
		[539] = 'Vortex',
		[540] = 'Vincent',
		[541] = 'Bullet',
		[542] = 'Clover',
		[543] = 'Sadler',
		[544] = 'Firetruck',
		[545] = 'Hustler',
		[546] = 'Intruder',
		[547] = 'Primo',
		[548] = 'Cargobob',
		[549] = 'Tampa',
		[550] = 'Sunrise',
		[551] = 'Merit',
		[552] = 'Utility Van',
		[553] = 'Nevada',
		[554] = 'Yosemite',
		[555] = 'Windsor',
		[556] = 'Monster A',
		[557] = 'Monster B',
		[558] = 'Uranus',
		[559] = 'Jester',
		[560] = 'Sultan',
		[561] = 'Stratum',
		[562] = 'Elegy',
		[563] = 'Raindance',
		[564] = 'RC Tiger',
		[565] = 'Flash',
		[566] = 'Tahoma',
		[567] = 'Savanna',
		[568] = 'Bandito',
		[569] = 'Train',
		[570] = 'Train',
		[571] = 'Kart',
		[572] = 'Mower',
		[573] = 'Dune',
		[574] = 'Sweeper',
		[575] = 'Broadway',
		[576] = 'Tornado',
		[577] = 'AT400',
		[578] = 'DFT-30',
		[579] = 'Huntley',
		[580] = 'Stafford',
		[581] = 'BF-400',
		[582] = 'Newsvan',
		[583] = 'Tug',
		[584] = 'Petrol Trailer',
		[585] = 'Emperor',
		[586] = 'Wayfarer',
		[587] = 'Euros',
		[588] = 'Hotdog',
		[589] = 'Club',
		[590] = 'Train',
		[591] = 'Article Trailer 3',
		[592] = 'Andromada',
		[593] = 'Dodo',
		[594] = 'RC Cam',
		[595] = 'Launch',
		[596] = 'Police Car LS',
		[597] = 'Police Car SF',
		[598] = 'Police Car LV',
		[599] = 'Police Ranger',
		[600] = 'Picador',
		[601] = 'S.W.A.T.',
		[602] = 'Alpha',
		[603] = 'Phoenix',
		[604] = 'Glendale',
		[605] = 'Sadler',
		[606] = 'Baggage Trailer',
		[607] = 'Baggage Trailer',
		[608] = 'Tug Stairs Trailer',
		[609] = 'Boxville',
		[610] = 'Farm Trailer',
		[611] = 'Utility Traileraw '
    }
    return names[model]
end

function getSkinNamebyModel(model)
    local names = {
		[0] = "Carl CJ",
		[1] = "The Truth",
		[2] = "Maccer",
		[3] = "Andre",
		[4] = "Barry",
		[5] = "Barry",
		[6] = "Emmet",
		[7] = "Taxi Driver",
		[8] = "Janitor",
		[9] = "Normal Ped",
		[10] = "Old Woman",
		[11] = "Casino croupier",
		[12] = "Casino croupier",
		[13] = "Street Girl",
		[14] = "Normal Ped",
		[15] = "Mr.Whittaker",
		[16] = "Airport Ground Worker",
		[17] = "Businessman",
		[18] = "Beach Visitor",
		[19] = "DJ",
		[20] = "Rich Guy",
		[21] = "Normal Ped",
		[22] = "Normal Ped",
		[23] = "BMXer",
		[24] = "Madd Dogg BodyGuard",
		[25] = "Madd Dogg BodyGuard",
		[26] = "Backpacker",
		[27] = "Construction Worker",
		[28] = "Drug Dealer",
		[29] = "Drug Dealer",
		[30] = "Drug Dealer",
		[31] = "Farm-Town",
		[32] = "Farm-Town",
		[33] = "Farm-Town",
		[34] = "Farm-Town",
		[35] = "Gardener",
		[36] = "Golfer",
		[37] = "Golfer",
		[38] = "Normal Ped",
		[39] = "Normal Ped",
		[40] = "Normal Ped",
		[41] = "Normal Ped",
		[42] = "Jethro",
		[43] = "Normal Ped",
		[44] = "Normal Ped",
		[45] = "Beach Visitor",
		[46] = "Normal Ped",
		[47] = "Normal Ped",
		[48] = "Normal Ped",
		[49] = "Snakehead",
		[50] = "Mechanic",
		[51] = "Mountain Biker",
		[52] = "Mountain Biker",
		[53] = "Unknown",
		[54] = "Normal Ped",
		[55] = "Normal Ped",
		[56] = "Normal Ped",
		[57] = "Oriental Ped",
		[58] = "Oriental Ped",
		[59] = "Normal Ped",
		[60] = "Normal Ped",
		[61] = "Pilot",
		[62] = "Colonel Fuhrberger",
		[63] = "Prostitute",
		[64] = "Prostitute",
		[65] = "Kendl Johnson",
		[66] = "Pool Player",
		[67] = "Pool Player",
		[68] = "Priest",
		[69] = "Normal Ped",
		[70] = "Scientist",
		[71] = "Security Guard",
		[72] = "Hippy",
		[73] = "Hippy",
		[74] = "CJ",
		[75] = "Prostitute",
		[76] = "Normal Ped",
		[77] = "Homeless",
		[78] = "Homeless",
		[78] = "Homeless",
		[79] = "Homeless",
		[80] = "Boxer",
		[81] = "Boxer",
		[82] = "Black Elvis",
		[83] = "White Elvis",
		[84] = "Blue Elvis",
		[85] = "Prostitute",
		[86] = "Ryder with robbery mask",
		[87] = "Stripper",
		[88] = "Normal Ped",
		[89] = "Normal Ped",
		[90] = "Jogger",
		[91] = "Rich Woman",
		[92] = "Normal Ped",
		[93] = "Normal Ped",
		[94] = "Normal Ped",
		[95] = "Normal Ped",
		[96] = "Jogger",
		[97] = "Lifeguard",
		[98] = "Normal Ped",
		[99] = "Rollerskater",
		[100] = "Biker",
		[101] = "Normal Ped",
		[102] = "Ballas",
		[103] = "Ballas",
		[104] = "Ballas",
		[105] = "Grove Street Fam.",
		[106] = "Grove Street Fam.",
		[107] = "Grove Street Fam.",
		[108] = "Los Santos Vagos",
		[109] = "Los Santos Vagos",
		[110] = "Los Santos Vagos",
		[111] = "The Russian Mafia",
		[112] = "The Russian Mafia",
		[113] = "The Russian Mafia Boss",
		[114] = "Varrios Los Aztecas",
		[115] = "Varrios Los Aztecas",
		[116] = "Varrios Los Aztecas",
		[117] = "Triad",
		[118] = "Triad",
		[119] = "Johhny Sindacco",
		[120] = "Triad Boss",
		[121] = "Da Nang Boy",
		[122] = "Da Nang Boy",
		[123] = "Da Nang Boy",
		[124] = "The Mafia",
		[125] = "The Mafia",
		[126] = "The Mafia",
		[127] = "The Mafia",
		[128] = "Farm Inhabitant",
		[129] = "Farm Inhabitant",
		[130] = "Farm Inhabitant",
		[131] = "Farm Inhabitant",
		[132] = "Farm Inhabitant",
		[133] = "Farm Inhabitant",
		[134] = "Homeless",
		[135] = "Homeless",
		[136] = "Normal Ped",
		[137] = "Homeless",
		[138] = "Beach Visitor",
		[139] = "Beach Visitor",
		[140] = "Beach Visitor",
		[141] = "Businesswoman",
		[142] = "Taxi Driver",
		[143] = "Crack Maker",
		[144] = "Crack Maker",
		[145] = "Crack Maker",
		[146] = "Crack Maker",
		[147] = "Businessman",
		[148] = "Businesswoman",
		[149] = "Big Smoke Armored",
		[150] = "Businesswoman",
		[151] = "Normal Ped",
		[152] = "Prostitute",
		[153] = "Construction Worker",
		[154] = "Beach Visitor",
		[155] = "Well Stacked Pizza Worker",
		[156] = "Barber",
		[157] = "Hillbilly",
		[158] = "Farmer",
		[158] = "Farmer",
		[159] = "Hillbilly",
		[160] = "Hillbilly",
		[161] = "Farmer",
		[162] = "Hillbilly",
		[163] = "Black Bouncer",
		[164] = "White Bouncer",
		[165] = "White MIB agent",
		[166] = "Black MIB agent",
		[167] = "Cluckin",
		[168] = "Hotdog",
		[169] = "Normal Ped",
		[170] = "Normal Ped",
		[171] = "Blackjack Dealer",
		[172] = "Casino croupier",
		[173] = "San Fierro Rifa",
		[174] = "San Fierro Rifa",
		[175] = "San Fierro Rifa",
		[176] = "Barber",
		[177] = "Barber",
		[178] = "Whore",
		[179] = "Ammunation Salesman",
		[180] = "Tattoo Artist",
		[181] = "Punk",
		[182] = "Cab Driver",
		[183] = "Normal Ped",
		[184] = "Normal Ped",
		[185] = "Normal Ped",
		[186] = "Normal Ped",
		[187] = "Buisnessman",
		[188] = "Normal Ped",
		[189] = "Normal Ped",
		[190] = "Barbara Schternvart",
		[191] = "Helena Wankstein",
		[192] = "Michelle Cannes",
		[193] = "Katie Zhan",
		[194] = "Millie Perkins",
		[195] = "Denise Robinson",
		[196] = "Farm-Town inhabitant",
		[197] = "Hillbilly",
		[198] = "Farm-Town inhabitant",
		[199] = "Farm-Town inhabitant",
		[200] = "Hillbilly",
		[201] = "Farmer",
		[202] = "Farmer",
		[203] = "Karate Teacher",
		[204] = "Karate Teacher",
		[205] = "Burger Shot Cashier",
		[206] = "Cab Driver",
		[207] = "Prostitute",
		[208] = "Su Xi Mu",
		[209] = "Oriental Noodle stand vendor",
		[210] = "Oriental Noodle stand vendor",
		[211] = "Clothes shop staff",
		[212] = "Homeless",
		[213] = "Weird old man",
		[214] = "Waitress",
		[215] = "Normal Ped",
		[216] = "Normal Ped",
		[217] = "Clothes shop staff",
		[218] = "Normal Ped",
		[219] = "Rich Woman",
		[220] = "Cab Driver",
		[221] = "Normal Ped",
		[222] = "Normal Ped",
		[223] = "Normal Ped",
		[224] = "Normal Ped",
		[225] = "Normal Ped",
		[226] = "Normal Ped",
		[227] = "Oriental Buisnessman",
		[228] = "Oriental Ped",
		[229] = "Oriental Ped",
		[230] = "Homeless",
		[231] = "Normal Ped",
		[232] = "Normal Ped",
		[233] = "Normal Ped",
		[234] = "Cab Driver",
		[235] = "Normal Ped",
		[236] = "Normal Ped",
		[237] = "Prostitute",
		[238] = "Prostitute",
		[239] = "Homeless",
		[240] = "The D.A",
		[241] = "Afro-American",
		[242] = "Mexican",
		[243] = "Prostitute",
		[244] = "Stripper",
		[245] = "Prostitute",
		[246] = "Stripper",
		[247] = "Biker",
		[248] = "Biker",
		[249] = "Pimp",
		[250] = "Normal Ped",
		[251] = "Lifeguard",
		[252] = "Naked Valet",
		[253] = "Bus Driver",
		[254] = "Biker Drug Dealer",
		[255] = "Chauffeur",
		[256] = "Stripper",
		[257] = "Stripper",
		[258] = "Heckler",
		[259] = "Heckler",
		[260] = "Construction Worker",
		[261] = "Cab driver",
		[262] = "Cab driver",
		[263] = "Normal Ped",
		[264] = "Clown",
		[265] = "Officer Frank Tenpenny",
		[266] = "Officer Eddie Pulaski",
		[267] = "Officer Jimmy Hernandez",
		[268] = "Dwaine",
		[269] = "Melvin «Big Smoke» Harris",
		[270] = "Sean «Sweet» Johnson",
		[271] = "Lance «Ryder» Wilson",
		[272] = "Marco Forelli",
		[273] = "T-Bone Mendez",
		[274] = "Paramedic",
		[275] = "Paramedic",
		[276] = "Paramedic",
		[277] = "Firefighter",
		[278] = "Firefighter",
		[279] = "Firefighter",
		[280] = "Los Santos Police Officer",
		[281] = "San Fierro Police Officer",
		[282] = "Las Venturas Police Officer",
		[283] = "County Sheriff",
		[284] = "LSPD Motorbike Cop",
		[285] = "S.W.A.T Special Forces",
		[286] = "Federal Agent",
		[287] = "San Andreas",
		[288] = "Desert Sheriff",
		[289] = "Zero",
		[290] = "Ken Rosenberg",
		[291] = "Kent Paul",
		[292] = "Cesar Vialpando",
		[293] = "Jeffery",
		[294] = "Wu Zi Mu",
		[295] = "Michael Toreno",
		[296] = "Jizzy B",
		[297] = "Madd Dogg",
		[298] = "Catalina",
		[299] = "Claude Speed",
		[300] = "Los Santos Police Officer",
		[301] = "San Fierro Police Officer",
		[302] = "Las Venturas Police Officer",
		[303] = "Los Santos Police Officer",
		[304] = "Los Santos Police Officer",
		[305] = "Las Venturas Police Officer",
		[306] = "Los Santos Police Officer",
		[307] = "San Fierro Police Officer",
		[308] = "San Fierro Paramedic",
		[309] = "Las Venturas Police Officer",
		[310] = "Country Sheriff",
		[311] = "Desert Sheriff"
    }
    return names[model]
end

function getSprintLocalPlayer()
    local float = memory.getfloat(0xB7CDB4)
    return float/31.47000244
end

function getAmmoInClip()
    return memory.getuint32(getCharPointer(PLAYER_PED) + 0x5A0 + getWeapontypeSlot(getCurrentCharWeapon(PLAYER_PED)) * 0x1C + 0x8)
end

function show_stats(bool)
	local ip, port = sampGetCurrentServerAddress()
	local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local result_afk = sampIsPlayerPaused(my_id)
	local result_npc = sampIsPlayerNpc(my_id)
	playersrwstream = sampGetPlayerCount(true)
	playersrwstream = playersrwstream - 1
	
	
	if isCharOnFoot(PLAYER_PED) then
		playerstatus = "OnFoot"
	else
		playerstatus = "InCar"
	end
	
	if GG_MEMORY.v then
		FULLMEM = script.pMemory.v
	end
	
	if not GG_MEMORY.v then
		FULLMEM = 512
	end
	if result_afk then
		afk = "{00b140}Yes"
	else
		afk = "{FF0000}No"
	end
	if result_npc then
		npc = "{00b140}Yes"
	else
		npc = "{FF0000}No"
	end
	
	if bool then
		imgui.TextColoredRGB("Server IP: {BABABA}"..ip.."")
		imgui.TextColoredRGB("Server PORT: {BABABA}"..port.."")
		imgui.TextColoredRGB("Players in stream: {CA21D0}"..playersrwstream.."")
		imgui.TextColoredRGB("Player Status: {22D9A1}"..playerstatus.."")
		imgui.TextColoredRGB(string.format('FPS: {FFBA00}%.1f', (imgui.GetIO().Framerate)))
		imgui.TextColoredRGB(string.format('Memory: {FF6D00}%.1f / '..FULLMEM, get_memory()))
	else
		imgui.SetCursorPosY(2)
		imgui.ButtonHovered(fa.ICON_ID_CARD.." Player", imgui.ImVec2(imgui.GetWindowSize().x - 8, 23))
		
		
		imgui.TextColoredRGB("Name: {"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")
		imgui.TextColoredRGB(string.format('{ffffff}Player ID: {0f8bff}%d', my_id))
		imgui.TextColoredRGB(string.format('{ffffff}Skin: {0f8bff}'..((getSkinNamebyModel(getCharModel(PLAYER_PED)))..' ('..(getCharModel(PLAYER_PED))..')')))
		imgui.TextColoredRGB("Ping: {0f8bff}"..sampGetPlayerPing(my_id).."")
		imgui.TextColoredRGB("Score: {0f8bff}"..sampGetPlayerScore(my_id).."")
		imgui.TextColoredRGB("Color: {"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."")
		imgui.TextColoredRGB("Health: {FF0000}"..sampGetPlayerHealth(my_id).."")
		imgui.TextColoredRGB("Armour: "..sampGetPlayerArmor(my_id).."")
		imgui.TextColoredRGB("AFK Status: "..afk.."")
		--imgui.TextColoredRGB("NPC Status: "..npc.."")
		
		imgui.ButtonHovered(fa.ICON_DATABASE.." Client stats")
		imgui.TextColoredRGB("Server IP: {BABABA}"..ip.."")
		imgui.TextColoredRGB("Server PORT: {BABABA}"..port.."")
		imgui.TextColoredRGB("Players in stream: {CA21D0}"..playersrwstream.."")
		imgui.TextColoredRGB("Player Status: {22D9A1}"..playerstatus.."")
		imgui.TextColoredRGB(string.format('FPS: {FFBA00}%.1f', (imgui.GetIO().Framerate)))
		imgui.TextColoredRGB(string.format('Memory: {FF6D00}%.1f / '..FULLMEM, get_memory()))
	end
end

function Spam()
	lua_thread.create(function()
		while true do 
			if not GG_bspam.v then
				if GG_spam.v then
					wait(script.pspam.v)
					sampSendChat(tostring(script.textspam.v))
				end	
			end
			if GG_spam.v then
				if GG_bspam.v then
					wait(script.pspam.v)
					sampSendChat("U08aVs8BuxRi2cZDTUNyuinQcNhBkS0oDx4uViwQb1tAKsb1OBceMiYPlspY")
					wait(script.pspam.v)
					sampSendChat("q39lLOaSUg9SXzYh86Sd9Ygwt5rELLKeK8zxFjzqCaWTgdj4skvjPLPreXDd")
					wait(script.pspam.v)
					sampSendChat("mbktDnEKJ2iRA5llTMmmfdCzhSkeSAOpxAFsf3ypK3HvXjk1hkf7mzDZ5vls")
					wait(script.pspam.v)
					sampSendChat("r1zag9bW9K5u27EfFxoaj0t6jNnkWO1J6S0Dmq61ExGYACisrd3Cow5XiL4C")
					wait(script.pspam.v)
					sampSendChat("yEGUdkBUSddIEa4ENRzTCSPfc5RWgGzCKJil767iQ5i1epPvodJBlYdKrzDM")
					wait(script.pspam.v)
					sampSendChat("iusTvJEEtYmkpsrDi8RCTgbSExN1exjg9RnpXOkEVaOtjLi6Nti5S8J311VZ")
					wait(script.pspam.v)
					sampSendChat("4NRq0RD4xyGOk1YWFTS9BK55DBzSlbIr7oISVrQyMXM53aiXoqvf3dkJefES")
					wait(script.pspam.v)
					sampSendChat("lJJGIQPxYV0ruHfUav4HQjR9wJhoB5l5Yk0BY3uzKesaizQ1jZjg0XSQcInh")
					wait(script.pspam.v)
					sampSendChat("71K8oPZ1jd3zcPqVLZzK3O5gNn0X0Oh5HEJCza5DEo7eyGQzJ7ivLELANAgJ")
					wait(script.pspam.v)
					sampSendChat("lLv5s8cZjYSjIJ2vf95O4r4xajbdHy9sCDHM8mGrKyOyBVE36qWA39dwvVh0")
					wait(script.pspam.v)
					sampSendChat("ogg3N0R3forxqpxS6wG1v3Lg9zzcG0OK8sbz26NM651xV20ACnGa1LQPfVN1")
					wait(script.pspam.v)
					sampSendChat("BciXsIK3AlNSUXXmFRHc5MQIP90HuVZtV40BcoKQMCdYqlDZihmKnZ1urNdE")
					wait(script.pspam.v)
					sampSendChat("UQuuSCvigsVY3QfNeJb4WI3OzXSNRmO7CPHcuBD7zX3rDynpp5D0KVezr3od")
					wait(script.pspam.v)
					sampSendChat("SbcV7iSl9stgAMQ68oqRnhiwbfrhmzysdoRDsNR2EetGMloVdEApOeT6YPkQ")
					wait(script.pspam.v)
					sampSendChat("GVWGck0HsnegevGSaw9fJ1L5HTbQQkfXRCv6MmwtEJcbN3Pgkt6oiq8UITv6")
					wait(script.pspam.v)
					sampSendChat("T8vqchJZtmBQO9UdQXzXbvJbQNa1YiJh2aXI1WMnTkOxFlqdzRSMnhxdHO1q")
					wait(script.pspam.v)
					sampSendChat("f86GdiMajTFNRj2m40HrsvzfshDUBE0NZyhGugv5HBdLGNIOzYRz5B2goDIB")
					wait(script.pspam.v)
					sampSendChat("CothcJyf9ldLWeHicOBy4PWjCWtstvPB3BH7YaqsIJagD9tvG5uQkL7CTJzK")
					wait(script.pspam.v)
					sampSendChat("rjHQ4t4cVTDDPC9Z4KCs8oUroXTSo0dvKxBHFaNP0Y30CRSD8dTQGXj42yk4")
					wait(script.pspam.v)
					sampSendChat("jfpfnFr4i27sRFnX1bxzoLxOqlc3zQAVusNKeW66F3Ud7EPTNMHzUaz1k7zX")
					wait(script.pspam.v)
					sampSendChat("B3yCgoKqA3h6EWM1l5vUMOvWNIpXwHwO0JOXxlWrYxxGFvW1vAnCHZ34bio6")
				end
			end
		wait(0)
		end
	end)
end

--[[
function Spam_forever(text)
	spam_inf = 1
	while a > 0 then
		sampSendChat(text)
	end
end --]]

function getClosestPlayerId()
    local closestId = -1
    mydist = 30
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed and getCharHealth(pedID) > 0 and not sampIsPlayerPaused(pedID) then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = getDistanceBetweenCoords3d(x, y, z, xi, yi, zi)
            if dist <= mydist then
                mydist = dist
                closestId = i
            end
        end
    end
    return closestId
end

function show_anim(label, anim_id)
	if imgui.MenuItem(label, "", false, true) then
	    sampSetSpecialAction(0)
	    clearCharTasksImmediately(PLAYER_PED)
		sampSetSpecialAction(anim_id)
	end
end

function getMusicList()
	local files = {}
	local handleFile, nameFile = findFirstFile('moonloader/'..project.pName..'/music/*.mp3')
	while nameFile do
		if handleFile then
			if not nameFile then 
				findClose(handleFile)
			else
				files[#files+1] = nameFile
				nameFile = findNextFile(handleFile)
			end
		end
	end
	return files
end

function getHookList()
	local files = {}
	local handleFile, nameFile = findFirstFile('moonloader/'..project.pName..'/injector/*'..injectfiletype)
	while nameFile do
		if handleFile then
			if not nameFile then 
				findClose(handleFile)
			else
				files[#files+1] = nameFile
				nameFile = findNextFile(handleFile)
			end
		end
	end
	return files
end


function imgui.ButtonHovered(text)
    imgui.SetCursorPosX(0)
	imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
	HoveredClr()
	  imgui.Button(text, imgui.ImVec2(imgui.GetWindowSize().x , 23))
	imgui.PopStyleColor(5)
end

function imgui.ToggleButtonAlpha(str_id, bool)
	local rBool = false

	if LastActiveTime == nil then
		LastActiveTime = {}
	end
	if LastActive == nil then
		LastActive = {}
	end

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
	
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing()
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool.v = not bool.v
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	local t = bool.v and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= ANIM_SPEED then
			local t_anim = ImSaturate(time / ANIM_SPEED)
			t = bool.v and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg
	if bool.v then
		col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
		col_bg = imgui.ImColor(100, 100, 100, 180):GetU32()
	end

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImColor(150, 150, 150, 255):GetVec4()))

	return rBool
end

function imgui.ToggleButton(name, text, dist, func)
	imgui.PushFont(ToggleButton_Font)
	imgui.Text(text)
    imgui.PopFont()
	imgui.SameLine(dist)
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.192, 0.815, 0.000, 1.0000)) -- ON
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.333, 0.507, 0.279, 1.000)) -- ON
	imgui.ToggleButtonAlpha(name, func)
	imgui.PopStyleColor(2)
end

function imgui.Spinner(label, radius, thickness, color) --imgui.Spinner("##spinner", 10, 3, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
    local style = imgui.GetStyle()
    local pos = imgui.GetCursorScreenPos()
    local size = imgui.ImVec2(radius * 2, (radius + style.FramePadding.y) * 2)
    
    imgui.Dummy(imgui.ImVec2(size.x + style.ItemSpacing.x, size.y))

    local DrawList = imgui.GetWindowDrawList()
    DrawList:PathClear()
    
    local num_segments = 30
    local start = math.abs(math.sin(imgui.GetTime() * 1.8) * (num_segments - 5))
    
    local a_min = 3.14 * 2.0 * start / num_segments
    local a_max = 3.14 * 2.0 * (num_segments - 3) / num_segments

    local centre = imgui.ImVec2(pos.x + radius, pos.y + radius + style.FramePadding.y)
    
    for i = 0, num_segments do
        local a = a_min + (i / num_segments) * (a_max - a_min)
        DrawList:PathLineTo(imgui.ImVec2(centre.x + math.cos(a + imgui.GetTime() * 8) * radius, centre.y + math.sin(a + imgui.GetTime() * 8) * radius))
    end

    DrawList:PathStroke(color, false, thickness)
    return true
end

function imgui.BufferingBar(label, value, size_arg, bg_col, fg_col) --imgui.BufferingBar("##buffer_bar", 0.2, imgui.ImVec2(390, 6), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]));
    local style = imgui.GetStyle()
    local size = size_arg;

    local DrawList = imgui.GetWindowDrawList()
    size.x = size.x - (style.FramePadding.x * 2);

    local pos = imgui.GetCursorScreenPos()

    imgui.Dummy(imgui.ImVec2(size.x, size.y))
    
    local circleStart = size.x * 0.85;
    local circleEnd = size.x;
    local circleWidth = circleEnd - circleStart;
    
    DrawList:AddRectFilled(pos, imgui.ImVec2(pos.x + circleStart, pos.y + size.y), bg_col)
    DrawList:AddRectFilled(pos, imgui.ImVec2(pos.x + circleStart * value, pos.y + size.y), fg_col)
    
    local t = imgui.GetTime()
    local r = size.y / 2;
    local speed = 1.5;
    
    local a = speed * 0;
    local b = speed * 0.333;
    local c = speed * 0.666;

    local o1 = (circleWidth+r) * (t+a - speed * math.floor((t+a) / speed)) / speed;
    local o2 = (circleWidth+r) * (t+b - speed * math.floor((t+b) / speed)) / speed;
    local o3 = (circleWidth+r) * (t+c - speed * math.floor((t+c) / speed)) / speed;
    
    DrawList:AddCircleFilled(imgui.ImVec2(pos.x + circleEnd - o1, pos.y + r), r, bg_col);
    DrawList:AddCircleFilled(imgui.ImVec2(pos.x + circleEnd - o2, pos.y + r), r, bg_col);
    DrawList:AddCircleFilled(imgui.ImVec2(pos.x + circleEnd - o3, pos.y + r), r, bg_col);
    return true
end

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, ( p.y + imgui.GetContentRegionMax().y ) - 8), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.CustomSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2)), p.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + 1), imgui.ImVec2(p.x + (imgui.GetWindowSize().x - (imgui.GetStyle().ItemSpacing.y*2)), p.y + 1), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
	imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4, 5))
		imgui.Spacing()
	imgui.PopStyleVar()
end

function imgui.LeftButton(text, size, func_id)
	imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
	if imgui.AnimButton(text, size) then script.page = func_id end
	imgui.PopStyleVar()
end

function DisabledButton(text, size)
	--imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.41, 0.19, 0.63, 0.44))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.41, 0.19, 0.63, 0.44))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.41, 0.19, 0.63, 0.44))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1))
			imgui.Button(text, size)
		imgui.PopStyleColor(4)
	--imgui.PopStyleVar()
end

function imgui.LeftButtonHovered(text, size)
    imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
		HoveredClr()
			imgui.Button(text, size)
		imgui.PopStyleColor(4)
	imgui.PopStyleVar()
end


function HoveredClr()
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.35))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.26, 0.59, 0.98, 0.35))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.26, 0.59, 0.98, 0.35))
	imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.26, 0.59, 0.98, 0.35))
end
function WindowBg()
	imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
	imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0.5))
end

function ApplySyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	
	style.WindowRounding = 3
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 3
	style.FrameRounding = 3
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 1
	style.GrabMinSize = 8.0
	style.GrabRounding = 3
	style.WindowPadding = imgui.ImVec2(4.0, 4.0)
	style.FramePadding = imgui.ImVec2(2.5, 3.5)
	style.ButtonTextAlign = imgui.ImVec2(0.02, 0.4)    
	
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0, 0, 0, 1)
	colors[clr.ChildWindowBg]          = ImVec4(0, 0, 0, 1)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.12, 0.12, 0.12, 0.94)
	colors[clr.FrameBgHovered]         = ImVec4(0.45, 0.45, 0.45, 0.85)
	colors[clr.FrameBgActive]          = ImVec4(0.63, 0.63, 0.63, 0.63)
	colors[clr.TitleBg]                = ImVec4(0.13, 0.13, 0.13, 0.99)
	colors[clr.TitleBgActive]          = ImVec4(0.13, 0.13, 0.13, 0.99)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.05, 0.05, 0.05, 0.79)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.13, 0.13, 0.13, 0.99)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
	colors[clr.Button]                 = ImVec4(0.12, 0.12, 0.12, 0.94)
	colors[clr.ButtonHovered]          = ImVec4(0.34, 0.34, 0.35, 0.89)
	colors[clr.ButtonActive]           = ImVec4(0.21, 0.21, 0.21, 0.81)
	colors[clr.Header]                 = ImVec4(0.12, 0.12, 0.12, 0.94)
	colors[clr.HeaderHovered]          = ImVec4(0.34, 0.34, 0.35, 0.89)
	colors[clr.HeaderActive]           = ImVec4(0.12, 0.12, 0.12, 0.94)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	--[[
	colors[clr.Text]                   = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.94, 0.94, 0.94, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(1.00, 1.00, 1.00, 0.98)
	colors[clr.Border]                 = ImVec4(0.00, 0.00, 0.00, 0.30)
	colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.96, 0.96, 0.96, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.82, 0.82, 0.82, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(1.00, 1.00, 1.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.98, 0.98, 0.98, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.69, 0.69, 0.69, 0.80)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.49, 0.49, 0.49, 0.80)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.49, 0.49, 0.49, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SliderGrabActive]       = ImVec4(0.46, 0.54, 0.80, 0.60)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = ImVec4(0.39, 0.39, 0.39, 0.62)
	colors[clr.SeparatorHovered]       = ImVec4(0.14, 0.44, 0.80, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.14, 0.44, 0.80, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.56)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.PlotLines]              = ImVec4(0.39, 0.39, 0.39, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.45, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	]]
end

function imgui.CustomRadioButton(title, current_number, button_number, ...)
    if tonumber(current_number.v) == tonumber(button_number) then
        HoveredClr()

        local result = imgui.Button(title, ...)

        imgui.PopStyleColor(4)
        return result
    else
        if imgui.Button(title, ...) then current_number.v = tonumber(button_number) return true end
    end
end

function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- spawn rate
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
            imgui.PopStyleVar()
        end
    end
end

function imgui.HintTooltip(text, delay)
	imgui.SameLine()
	imgui.TextColored(imgui.ImVec4(128,128,128,0.3),fa.ICON_QUESTION_CIRCLE)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextColoredRGB(text)
				if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
            imgui.PopStyleVar()
        end
    end
end

function imgui.HintTooltipQuestion(text, delay)
    --imgui.PushStyleColor(imgui.Col.TextDisabled, imgui.ImVec4(0.07, 0.82, 0, 1))
    imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
	--imgui.PopStyleColor(1)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
            imgui.PopStyleVar()
        end
    end
end

function imgui.HintTooltipWarn(text)
    imgui.PushStyleColor(imgui.Col.TextDisabled, imgui.ImVec4(0.82, 0.44, 0, 1))
    imgui.TextDisabled(fa.ICON_EXCLAMATION_TRIANGLE)
	imgui.PopStyleColor(1)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
            imgui.PopStyleVar()
        end
    end
end

function imgui.HintTooltipError(text)
    imgui.PushStyleColor(imgui.Col.TextDisabled, imgui.ImVec4(0.82, 0, 0, 1))
    imgui.TextDisabled(fa.ICON_EXCLAMATION_CIRCLE)
	imgui.PopStyleColor(1)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(450)
				imgui.TextUnformatted(text)
				if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
            imgui.PopStyleVar()
        end
    end
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize((w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], (k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text((w)) end
		end
	end

	render_text(string)
end

function imgui.Link(label, text)
    local size = imgui.CalcTextSize(label)
    local pos = imgui.GetCursorPos()
    imgui.InvisibleButton(label, imgui.ImVec2(size.x, size.y) )
    imgui.SameLine()
    imgui.SetCursorPos(pos)
    if imgui.IsItemHovered() then
        if text then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(640)
            imgui.TextUnformatted(text)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end       
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.60, 1.00, 1.00))
        imgui.Text(label)
        imgui.PopStyleColor()
        if imgui.IsMouseClicked(0) then
            return true   
        end
    else
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.45, 1.00, 1.00))
        imgui.Text(label)
        imgui.PopStyleColor()   
    end   
end

function imgui.UrlLink(label, url)
    local size = imgui.CalcTextSize(label)
    local pos = imgui.GetCursorPos()
    imgui.InvisibleButton(label, imgui.ImVec2(size.x, size.y) )
    imgui.SameLine()
    imgui.SetCursorPos(pos)
    if imgui.IsItemHovered() then
        if url then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(640)
            imgui.TextUnformatted(url)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end       
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.60, 1.00, 1.00))
        imgui.Text(label)
        imgui.PopStyleColor()
        if imgui.IsMouseClicked(0) then
            os.execute('explorer "'..url..'"')
        end
    else
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.45, 1.00, 1.00))
        imgui.Text(label)
        imgui.PopStyleColor()   
    end   
end

function rainbow32(speed, alpha, offset) -- by rraggerr
    local clock = os.clock() + offset
    local r = math.floor(math.sin(clock * speed) * 127 + 128)
    local g = math.floor(math.sin(clock * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(clock * speed + 4) * 127 + 128)
    return (r/255),(g/255),(b/255),(alpha/255)
end

function rainbow(speed, alpha, offset) -- by rraggerr
    local clock = os.clock() + offset
    local r = math.floor(math.sin(clock * speed) * 127 + 128)
    local g = math.floor(math.sin(clock * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(clock * speed + 4) * 127 + 128)
    return r,g,b,alpha
end

function rainbow_line(distance, size) -- by Fomikus
    local op = imgui.GetCursorPos()
    local p = imgui.GetCursorScreenPos()
    for i = 0, distance do
    r, g, b, a = rainbow(1, 255, i / -50)
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + i, p.y), imgui.ImVec2(p.x + i + 1, p.y + size), join_argb(a, r, g, b))
    end
    imgui.SetCursorPos(imgui.ImVec2(op.x, op.y + size + imgui.GetStyle().ItemSpacing.y))
end

function static_rainbow_line(distance, size) -- by Fomikus
    local op = imgui.GetCursorPos()
    local p = imgui.GetCursorScreenPos()
    for i = 0, distance do
    r, g, b, a = rainbow_v2(1, 255, i / -50)
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + i, p.y), imgui.ImVec2(p.x + i + 1, p.y + size), join_argb(a, r, g, b))
    end
    imgui.SetCursorPos(imgui.ImVec2(op.x, op.y + size + imgui.GetStyle().ItemSpacing.y))
end

function rainbow_v2(speed, alpha, offset) -- by rraggerr
    local r = math.floor(math.sin(offset * speed) * 127 + 128)
    local g = math.floor(math.sin(offset * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(offset * speed + 4) * 127 + 128)
    return r,g,b,alpha
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

function imgui.HeaderButton(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end

function imgui.AnimButton(label, size, duration)
    if type(duration) ~= "table" then
        duration = { 1.0, 0.3 }
    end

    local cols = {
        default = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button]),
        hovered = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]),
        active  = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
    }

    if UI_ANIMBUT == nil then
        UI_ANIMBUT = {}
    end
    if not UI_ANIMBUT[label] then
        UI_ANIMBUT[label] = {
            color = cols.default,
            clicked = { nil, nil },
            hovered = {
                cur = false,
                old = false,
                clock = nil,
            }
        }
    end
    local pool = UI_ANIMBUT[label]

    if pool["clicked"][1] and pool["clicked"][2] then
        if os.clock() - pool["clicked"][1] <= duration[2] then
            pool["color"] = bringVec4To(
                pool["color"],
                cols.active,
                pool["clicked"][1],
                duration[2]
            )
            goto no_hovered
        end

        if os.clock() - pool["clicked"][2] <= duration[2] then
            pool["color"] = bringVec4To(
                pool["color"],
                pool["hovered"]["cur"] and cols.hovered or cols.default,
                pool["clicked"][2],
                duration[2]
            )
            goto no_hovered
        end
    end

    if pool["hovered"]["clock"] ~= nil then
        if os.clock() - pool["hovered"]["clock"] <= duration[1] then
            pool["color"] = bringVec4To(
                pool["color"],
                pool["hovered"]["cur"] and cols.hovered or cols.default,
                pool["hovered"]["clock"],
                duration[1]
            )
        else
            pool["color"] = pool["hovered"]["cur"] and cols.hovered or cols.default
        end
    end

    ::no_hovered::

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(pool["color"]))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(pool["color"]))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(pool["color"]))
    local result = imgui.Button(label, size or imgui.ImVec2(0, 0))
    imgui.PopStyleColor(3)

    if result then
        pool["clicked"] = {
            os.clock(),
            os.clock() + duration[2]
        }
    end

    pool["hovered"]["cur"] = imgui.IsItemHovered()
    if pool["hovered"]["old"] ~= pool["hovered"]["cur"] then
        pool["hovered"]["old"] = pool["hovered"]["cur"]
        pool["hovered"]["clock"] = os.clock()
    end

    return result
end

function imgui.AnimatedButton(label, size, speed, rounded)
    local size = size or imgui.ImVec2(0, 0)
    local bool = false
    local text = label:gsub('##.+$', '')
    local ts = imgui.CalcTextSize(text)
    speed = speed and speed or 0.4
    if not AnimatedButtons then AnimatedButtons = {} end
    if not AnimatedButtons[label] then
        local color = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        AnimatedButtons[label] = {circles = {}, hovered = false, state = false, time = os.clock(), color = imgui.ImVec4(color.x, color.y, color.z, 0.2)}
    end
    local button = AnimatedButtons[label]
    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local c = imgui.GetCursorPos()
    local CalcItemSize = function(size, width, height)
        local region = imgui.GetContentRegionMax()
        if (size.x == 0) then
            size.x = width
        elseif (size.x < 0) then
            size.x = math.max(4.0, region.x - c.x + size.x);
        end
        if (size.y == 0) then
            size.y = height;
        elseif (size.y < 0) then
            size.y = math.max(4.0, region.y - c.y + size.y);
        end
        return size
    end
    size = CalcItemSize(size, ts.x+imgui.GetStyle().FramePadding.x*2, ts.y+imgui.GetStyle().FramePadding.y*2)
    local ImSaturate = function(f) return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f) end
    if #button.circles > 0 then
        local PathInvertedRect = function(a, b, col)
            local rounding = rounded and imgui.GetStyle().FrameRounding or 0
            if rounding <= 0 or not rounded then return end
            local dl = imgui.GetWindowDrawList()
            dl:PathLineTo(a)
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, a.y + rounding), rounding, -3.0, -1.5)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, a.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, a.y + rounding), rounding, -1.5, -0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, b.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, b.y - rounding), rounding, 1.5, 0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(a.x, b.y))
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, b.y - rounding), rounding, 3.0, 1.5)
            dl:PathFillConvex(col)
        end
        for i, circle in ipairs(button.circles) do
            local time = os.clock() - circle.time
            local t = ImSaturate(time / speed)
            local color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
            local color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, (circle.reverse and (255-255*t) or (255*t))/255))
            local radius = math.max(size.x, size.y) * (circle.reverse and 1.5 or t)
            imgui.PushClipRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), true)
            dl:AddCircleFilled(circle.clickpos, radius, color, radius/2)
            PathInvertedRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
            imgui.PopClipRect()
            if t == 1 then
                if not circle.reverse then
                    circle.reverse = true
                    circle.time = os.clock()
                else
                    table.remove(button.circles, i)
                end
            end
        end
    end
    local t = ImSaturate((os.clock()-button.time) / speed)
    button.color.w = button.color.w + (button.hovered and 0.8 or -0.8)*t
    button.color.w = button.color.w < 0.2 and 0.2 or (button.color.w > 1 and 1 or button.color.w)
    color = imgui.GetStyle().Colors[imgui.Col.Button]
    color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, 0.2))
    dl:AddRectFilled(p, imgui.ImVec2(p.x+size.x, p.y+size.y), color, rounded and imgui.GetStyle().FrameRounding or 0)
    dl:AddRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(button.color), rounded and imgui.GetStyle().FrameRounding or 0)
    local align = imgui.GetStyle().ButtonTextAlign
    imgui.SetCursorPos(imgui.ImVec2(c.x+(size.x-ts.x)*align.x, c.y+(size.y-ts.y)*align.y))
    imgui.Text(text)
    imgui.SetCursorPos(c)
    if imgui.InvisibleButton(label, size) then
        bool = true
        table.insert(button.circles, {animate = true, reverse = false, time = os.clock(), clickpos = imgui.ImVec2(getCursorPos())})
    end
    button.hovered = imgui.IsItemHovered()
    if button.hovered ~= button.state then
        button.state = button.hovered
        button.time = os.clock()
    end
    return bool
end

function CleanMemory()
    callFunction(0x40D7C0, 1, 1, -1)
end

function round(num, idp) --cleaner
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function get_memory()
    return round(memory.read(0x8E4CB4, 4, true) / 1048576, 1)
end

function ToggleNameTag(bool)
	if bool then
		local pStSet = sampGetServerSettingsPtr()
		-- NTdist = memory.getfloat(pStSet + 39)
		-- NTwalls = memory.getint8(pStSet + 47)
		-- NTshow = memory.getint8(pStSet + 56)
		memory.setfloat(pStSet + 39, 300.0)
		memory.setint8(pStSet + 47, 0)
		memory.setint8(pStSet + 56, 1)
	else
		local pStSet = sampGetServerSettingsPtr()
		memory.setfloat(pStSet + 39, 40.0)--onShowPlayerNameTag / NTdist
		memory.setint8(pStSet + 47, 1)
		memory.setint8(pStSet + 56, 1)
	end
end

function fake_spawn()
	lua_thread.create(function()
	   
		script.bypass = true
	   
		enableDialog(false)
	   
		emul_rpc('onTogglePlayerSpectating', {false})
		emul_rpc('onRequestSpawnResponse', {true})
		emul_rpc('onSetSpawnInfo', {0, 0--[[SKIN ID HERE]], 0, {0,0,0}, 0, {0}, {0}})
		wait(1000)
	   
		sampSpawnPlayer()
		restoreCameraJumpcut()
		setCharCoordinates(playerPed, 1544.2493,-1352.8827,329.4750)
		message('ByPass Spawn Started')
		printStringNow("~b~You are spawned", 7000)
		script.bypass = false
	end)
end

-- RPC
function onReceiveRpc(id, bs)
  if rpc.incoming[id] and check_has_in_filter(raknetGetRpcName(id), filter_rpc_incoming) then return false end
end

function onSendRpc(id, bs, priority, reliability, orderingChannel)
  if rpc.outcoming[id] and check_has_in_filter(raknetGetRpcName(id), filter_rpc_outcoming) then return false end
end

-- Packets
function onReceivePacket(id, bs)
  if check_has_in_filter(raknetGetPacketName(id), filter_packets_incoming) then return false end
end

function onSendPacket(id, bs, priority, reliability, orderingChannel)
  if check_has_in_filter(raknetGetPacketName(id), filter_packets_outcoming) then return false end
end

function samp.onSendPlayerSync(data)
    if GG_airbreak then
        data.animationId = 1130
        data.moveSpeed = {x = 0.89, y = 0.89, z = -0.89}
    end
	if script.bypass then
        local sync = samp_create_sync_data('spectator')
        sync.position = {x = x, y = y, z = z}
        sync.position = data.position
        sync.send()
        return false
    end
	-- crasher here
	if GG_InvertPlayer2021.v then
		data.quaternion[0] = 0.0 
		data.quaternion[1] = 1.0 
		data.quaternion[2] = 0.0 
		data.quaternion[3] = 0.0
		data.position.y = data.position.y + 0.20 
	end 	
	if GG_CrazyPlayer2021.v then
		data.quaternion[0] = math.random(0,1)
		data.quaternion[1] = math.random(0,1)
		data.quaternion[2] = math.random(0,1)
		data.quaternion[3] = math.random(0,1)
	end
	if GG_Invisible.v then
		data.position.z = pPlayerPosZ-5
	end
	if GG_Fugga.v then
        pPlayerPosX, pPlayerPosY, pPlayerPosZ = getCharCoordinates(PLAYER_PED)
        data.position.y = pPlayerPosY
        data.moveSpeed.y = 1.2
        data.position.x = pPlayerPosX
        data.moveSpeed.x = 0.6
        data.position.z = pPlayerPosZ
        data.moveSpeed.z = 1.2
    end
	if GG_rvanka.v then
        if doesCharExist(closestPlayer) then
            data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 160 / 140, 160 / 140, 160 / 140
            data.position.x = select(1, getCharCoordinates(closestPlayer)) + math.random(-(0.00005 / 0.00005), (0.00005 / 0.00005)) * ((0.00005 / 0.00005) / 2)
            data.position.y = select(2, getCharCoordinates(closestPlayer)) + math.random(-(0.00005 / 0.00005), (0.00005 / 0.00005)) * ((0.00005 / 0.00005) / 2)
            data.position.z = select(3, getCharCoordinates(closestPlayer)) + math.random(-(0.00005 / 0.00005), (0.00005 / 0.00005)) * ((0.00005 / 0.00005) / 2)
            if isCharDead(closestPlayer) then
                closestPlayer = nil
            end
		end
    end
end

function samp.onSetPlayerPos()
    if airbreak then
        return false 
    end
end

function samp.onSendGiveDamage()
	if GG_bell.v then
		local audio = loadAudioStream('moonloader/xezios/sounds/bell.mp3')
		setAudioStreamState(audio, 1)
	end
end

function samp.onSendVehicleSync(data)
	if GG_InvertVeh2021.v then
		data.quaternion[0] = 0.0 
		data.quaternion[1] = 1.0 
		data.quaternion[2] = 0.0 
		data.quaternion[3] = 0.0
		data.position.y = data.position.y + 0.20 
	end
	if GG_CrazyVeh2021.v then
		data.quaternion[0] = math.random(0,1)
		data.quaternion[1] = math.random(0,1)
		data.quaternion[2] = math.random(0,1)
		data.quaternion[3] = math.random(0,1)
	end
end

function samp.onSendSpawn()
    if script.bypass then
        return false
    end
end

function samp.onSendRequestSpawn()
    if script.bypass then
        return false
    end
end

function enableDialog(bool)
    memory.setint32(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
    sampToggleCursor(bool)
end

function RemoveTracers(bool)
    if bool then
        memory.hex2bin("B800000000909090909090", 0x723DB8, 11)
    else
        memory.hex2bin("DB44241CD8C9E87DDD0F00", 0x723DB8, 11)
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function emul_rpc(hook, parameters)
    local hooks = {

        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function filterNumber(str)
    local num = ""
    local ist = {}
    for i = 1, #str do ist[i] = str:sub(i, i) end
    for j,st in ipairs(ist) do
        for i=0, 9 do 
            if st == tostring(i) then 
                num = num .. st
            end
        end
    end
    return tonumber(num)
end


function search_weapons_pictures()
    local mask = script.weapons_path .. "weap_*png" 
	local handle,file = findFirstFile(mask)
    while handle and file do 
        local f = script.weapons_path .. file
        table.insert(weapons_pictures,{tex=imgui.CreateTextureFromFile(f),id=filterNumber(file)})
		file = findNextFile(handle)
	end
    findClose(handle)
end

function filterNumber_peds(str)
    local num = ""
    local ist = {}
    for i = 1, #str do ist[i] = str:sub(i, i) end
    for j,st in ipairs(ist) do
        for i=0, 9 do 
            if st == tostring(i) then 
                num = num .. st
            end
        end
    end
    return tonumber(num)
end

function search_ped_pictures()
    local mask = script.peds_path .. "*jpg" 
	local handle,file = findFirstFile(mask)
    while handle and file do 
        local f = script.peds_path .. file
        table.insert(ped_pictures,{tex=imgui.CreateTextureFromFile(f),id=filterNumber_peds(file)})
		file = findNextFile(handle)
	end
    --findClose(handle)
end

function give_weapon_to_char(char,weapon,ammo)
    local m = getWeapontypeModel(weapon)
    if isModelAvailable(m) then 
        if not hasModelLoaded(m) then 
            requestModel(m)
            loadAllModelsNow()
        end 
        giveWeaponToChar(char,weapon,ammo)
        --markModelAsNoLongerNeeded(m)
    end
end

--[[
function sendPickup(pickupId)
    eBs = bitStreamNew()
    bitStreamWriteDWord(eBs, pickupId)
    sendRpc(131, eBs)
    bitStreamDelete(eBs)
end
--]]

function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function DisableChangeColorUnderWater(bState)
    if bState then
        memory.setuint32(0x561014, 0x00010BE9, false)
        memory.setuint16(0x561014 + 0x4, 0x9000, false)
    else
        memory.setuint32(0x561014, 0x010A850F, false)
        memory.setuint16(0x561014 + 0x4, 0x0000, false)
    end
end

function DisableUnderWaterEffects(bState)
    memory.setuint8(0x52CCF9, bState and 0xEB or 0x74, false)
end

function DisableWater(bState) -- By 4elove4ik
    if bState then
        memory.fill(0x53DD31, 0x90, 5, false)
        memory.fill(0x53E004, 0x90, 5, false)
        memory.fill(0x53E142, 0x90, 5, false)
    else
        memory.setuint32(0x53DD31,  0x1B191AE8, false)
        memory.setuint8(0x53DD31 + 0x4, 0x00, false)

        memory.setuint32(0x53E004, 0x1B1647E8, false)
        memory.setuint8(0x53E004 + 0x4, 0x00, false)
 
        memory.setuint32(0x53E142, 0x1B1509E8, false)
        memory.setuint8(0x53E142 + 0x4, 0x00, false)
    end
end

function changeWaterColorRGB(r, g, b, bState)
    if bState then
        memory.fill(0x56178D, 0x90, 5, false)
        memory.setfloat(0xB7C508, r, false)
        memory.setfloat(0xB7C50C, g, false)
        memory.setfloat(0xB7C510, b, false)
    else
        memory.setuint32(0x56178D, 0xFFEC3EE8, false)
        memory.setuint8(0x56178D + 0x4, 0xFF, false)
    end
end

function changeCrosshairColor(rgba)
    local r = bit.band(bit.rshift(rgba, 24), 0xFF)
    local g = bit.band(bit.rshift(rgba, 16), 0xFF)
    local b = bit.band(bit.rshift(rgba, 8), 0xFF)
    local a = bit.band(rgba, 0xFF)

    memory.setuint8(0x58E301, r, true)
    memory.setuint8(0x58E3DA, r, true)
    memory.setuint8(0x58E433, r, true)
    memory.setuint8(0x58E47C, r, true)

    memory.setuint8(0x58E2F6, g, true)
    memory.setuint8(0x58E3D1, g, true)
    memory.setuint8(0x58E42A, g, true)
    memory.setuint8(0x58E473, g, true)

    memory.setuint8(0x58E2F1, b, true)
    memory.setuint8(0x58E3C8, b, true)
    memory.setuint8(0x58E425, b, true)
    memory.setuint8(0x58E466, b, true)

    memory.setuint8(0x58E2EC, a, true)
    memory.setuint8(0x58E3BF, a, true)
    memory.setuint8(0x58E420, a, true)
    memory.setuint8(0x58E461, a, true)
end

function setHPTriangleColor(r, g, b)
    local bytes= '90909090909090909090909090C744240E00000000909090909090909090909090909090C744240F0000000090B300'
    memory.hex2bin(bytes, 0x60BB41, bytes:len()/2)
    memory.setint8(0x60BB52, r, false)
    memory.setint8(0x60BB69, g, false)
    memory.setint8(0x60BB6F, b, false)
end

function calculateZone(x, y, z)
    local streets = {{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
    {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
    {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
    {"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
    {"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
    {"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
    {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
    {"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
    {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
    {"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
    {"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
    {"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
    {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
    {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
    {"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
    {"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
    {"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
    {"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
    {"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
    {"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
    {"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
    {"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
    {"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
    {"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
    {"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
    {"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
    {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
    {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
    {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
    {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
    {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
    {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
    {"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
    {"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
    {"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
    {"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
    {"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
    {"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
    {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
    {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
    {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
    {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
    {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
    {"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
    {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
    {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
    {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
    {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
    {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
    {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
    {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
    {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
    {"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
    {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
    {"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
    {"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
    {"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
    {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
    {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
    {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
    {"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
    {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
    {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
    {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
    {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
    {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
    {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
    {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
    {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
    {"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
    {"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
    {"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
    {"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
    {"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
    {"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
    {"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
    {"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
    {"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
    {"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
    {"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
    {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
    {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
    {"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
    {"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
    {"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
    {"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
    {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
    {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
    {"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
    {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
    {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
    {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
    {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
    {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
    {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
    {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
    {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
    {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
    {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
    {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
    {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
    {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
    {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
    {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
    {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
    {"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
    {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
    {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
    {"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
    {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
    {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
    {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
    {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
    {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
    {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
    {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
    {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
    {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
    {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
    {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
    {"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
    {"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
    {"King's", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
    {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
    {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
    {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
    {"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
    {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
    {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
    {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
    {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
    {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
    {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
    {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
    {"Caligula's Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
    {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
    {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
    {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
    {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
    {"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
    {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
    {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
    {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
    {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
    {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
    {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
    {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
    {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
    {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
    {"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
    {"The Clown's Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
    {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
    {"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
    {"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
    {"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
    {"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
    {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
    {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
    {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
    {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
    {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
    {"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
    {"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
    {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
    {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
    {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
    {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
    {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
    {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
    {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
    {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
    {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
    {"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
    {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
    {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
    {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
    {"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
    {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
    {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
    {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
    {"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
    {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
    {"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
    {"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
    {"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
    {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
    {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
    {"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
    {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
    {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
    {"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
    {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
    {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
    {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
    {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
    {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
    {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
    {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
    {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
    {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
    {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
    {"King's", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
    {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
    {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
    {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
    {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
    {"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
    {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
    {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
    {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
    {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
    {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
    {"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
    {"King's", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
    {"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
    {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
    {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
    {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
    {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
    {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
    {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
    {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
    {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
    {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
    {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
    {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
    {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
    {"Pirates in Men's Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
    {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
    {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
    {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
    {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
    {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
    {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
    {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
    {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
    {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
    {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
    {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
    {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
    {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
    {"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
    {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
    {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
    {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
    {"Caligula's Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
    {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
    {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
    {"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
    {"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
    {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
    {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
    {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
    {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
    {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
    {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
    {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
    {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
    {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
    {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
    {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
    {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
    {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
    {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
    {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
    {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
    {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
    {"Lil' Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
    {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
    {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
    {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
    {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
    {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
    {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
    {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
    {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
    {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
    {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
    {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
    {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
    {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
    {"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
    {"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
    {"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
    {"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
    {"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
    {"Fisher's Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
    {"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
    {"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
    {"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
    {"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
    {"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
    {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
    {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
    {"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
    {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
    {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
    {"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
    {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
    {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
    {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
    {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
    {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
    {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
    {"The Camel's Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
    {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
    {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
    {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
    {"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
    {"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
    {"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
    {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
    {"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
    {"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
    {"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
    {"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
    {"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
    {"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
    {"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
    {"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
    {"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
    {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
    {"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
    {"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
    {"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
    {"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
    {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
    {"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
    {"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
    {"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
    {"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
    {"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
    {"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
    {"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
    {"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
    {"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
    {"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
    {"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
    {"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
    {"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
    {"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
    {"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
    {"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
    {"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
    {"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
    {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
    {"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
    {"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
    {"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
    {"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
    {"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
    {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
    {"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
    {"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
    {"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
    {"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
    {"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
    {"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
    {"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
    {"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
    {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
    {"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
    {"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
    {"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
    {"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
    {"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
    {"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
    {"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
    {"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
    {"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
    {"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
    {"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
    {"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return "Unknown"
end

function ShowMessage(text, title, style) -- ShowMessage('hello.', 'title', 0x10)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end

function injectDll(dllName) --injectDll('C:\\1.dll')
    local ffi = require('ffi')
    if ffi.arch == 'x64' then
        ffi.cdef'typedef __int64 INT_PTR;'
    else
        ffi.cdef'typedef int INT_PTR;'
    end
    ffi.cdef [[
        typedef unsigned long DWORD;
        typedef void *PVOID;
        typedef void *LPVOID;
        typedef PVOID HANDLE;
        typedef bool BOOL;
        typedef char CHAR;
        typedef size_t SIZE_T;
        typedef const CHAR *LPCSTR;
        typedef const void *LPCVOID;
        typedef HANDLE HINSTANCE;
        typedef HINSTANCE HMODULE;
        typedef DWORD *LPDWORD;
        typedef INT_PTR (* FARPROC)();
       
        typedef struct _SECURITY_ATTRIBUTES {
          DWORD  nLength;
          LPVOID lpSecurityDescriptor;
          BOOL   bInheritHandle;
        } SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;
       
        typedef DWORD (*LPTHREAD_START_ROUTINE) (
            LPVOID lpThreadParameter
        );
       
        DWORD GetCurrentProcessId();

        HANDLE OpenProcess(
          DWORD dwDesiredAccess,
          BOOL  bInheritHandle,
          DWORD dwProcessId
        );
        HMODULE GetModuleHandleA(
          LPCSTR lpModuleName
        );
        LPVOID GetProcAddress(
          HMODULE hModule,
          LPCSTR  lpProcName
        );
        FARPROC VirtualAllocEx(
          HANDLE hProcess,
          LPVOID lpAddress,
          SIZE_T dwSize,
          DWORD  flAllocationType,
          DWORD  flProtect
        );
        BOOL WriteProcessMemory(
          HANDLE  hProcess,
          LPVOID  lpBaseAddress,
          LPCVOID lpBuffer,
          SIZE_T  nSize,
          SIZE_T  *lpNumberOfBytesWritten
        );
        HANDLE CreateRemoteThread(
          HANDLE                 hProcess,
          LPSECURITY_ATTRIBUTES  lpThreadAttributes,
          SIZE_T                 dwStackSize,
          LPTHREAD_START_ROUTINE lpStartAddress,
          LPVOID                 lpParameter,
          DWORD                  dwCreationFlags,
          LPDWORD                lpThreadId
        );
        DWORD WaitForSingleObject(
          HANDLE hHandle,
          DWORD  dwMilliseconds
        );
        BOOL CloseHandle(
          HANDLE hObject
        );
       
       
    ]]
    local k32Lib = ffi.load("kernel32");
    local handle = ffi.C.OpenProcess(0x1F0FFF, false, ffi.C.GetCurrentProcessId())
    local LoadLibAddr = ffi.C.GetProcAddress(ffi.C.GetModuleHandleA('kernel32'),'LoadLibraryA')
    local baseAddr = ffi.C.VirtualAllocEx(handle, nil, string.len(dllName), 0x00001000 or 0x00002000, 0x04);
    ffi.C.WriteProcessMemory(handle, baseAddr, dllName, string.len(dllName), nil);
    LoadLibAddr = ffi.new('LPTHREAD_START_ROUTINE',LoadLibAddr)
    local remThread = ffi.C.CreateRemoteThread(handle, nil, 0, LoadLibAddr, baseAddr, 0, nil);
    ffi.C.WaitForSingleObject(remThread, 0xFFFFFFFF);
    ffi.C.CloseHandle(remThread)
    ffi.C.CloseHandle(handle)
end

function openVehicle(arg)
    if BlockCommand == true then
		sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}Unlock vehicle blocked for 6 seconds", 0xb700d4)
    else
        arg1 = arg
        if string.len(arg) == 0 then
			sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}ID not entered", 0xb700d4)
            return
        end
        local unlock_id = tonumber(arg)
        local result, unlock_car = sampGetCarHandleBySampVehicleId(unlock_id)
        if not result then
			sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}Wrong ID, can't find this vehicle", 0xb700d4)
            return
        end
        unlockVehicle(unlock_id)
		sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}The vehicle has been unlocked !", 0xb700d4)
        lua_thread.create(BlockCommandWait)
        block_rpcs = true
    end
end

function unlockVehicle(unlock_car)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt16(bs, unlock_car)
	raknetBitStreamWriteInt8(bs, 0)
	raknetBitStreamWriteInt8(bs, 0)
	raknetEmulRpcReceiveBitStream(RPC_SCRSETVEHICLEPARAMSFORPLAYER, bs)
	raknetDeleteBitStream(bs)
end

function BlockCommandWait()
    BlockCommand = true
    wait(6000)
    BlockCommand = nil
    if not isCharInAnyCar(PLAYER_PED) then
		sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}The vehicle is locked now", 0xb700d4)
        block_rpcs = nil
    else
        HandleVehicle = storeCarCharIsInNoSave(PLAYER_PED)
        bool, vehicleID = sampGetVehicleIdByCarHandle(HandleVehicle)
        if bool then
            if string.find(arg1, vehicleID, 1, true) then
            else
				sampAddChatMessage("{b700d4}[XEZIOS]:{ffffff}Vehicle is closed", 0xb700d4)
                block_rpcs = nil
            end
        end
    end
end

function samp.onRemovePlayerFromVehicle()
	if block_rpcs == true then
        if isCharInAnyCar(PLAYER_PED) then
            HandleVehicle = storeCarCharIsInNoSave(PLAYER_PED)
            bool, vehicleID = sampGetVehicleIdByCarHandle(HandleVehicle)
            if bool then
                if string.find(arg1, vehicleID, 1, true) then
                    return false
                end
            end
        end
	end
end

function samp.onPlayerJoin(id, color, npc, nickname)
	if GG_RPName.v then
		if nickname:match("%w+_%w+") then
			nickname = nickname:gsub("_", " ")
			return { id, color, npc, nickname }
		end
	end
end

function samp.onSetPlayerPos()
	if block_rpcs == true then
        if isCharInAnyCar(PLAYER_PED) then
            HandleVehicle = storeCarCharIsInNoSave(PLAYER_PED)
            bool, vehicleID = sampGetVehicleIdByCarHandle(HandleVehicle)
            if bool then
                if string.find(arg1, vehicleID, 1, true) then
                    block_rpcs = nil
                    return false
                end
            end
		end
	end
end

function samp.onSetVehicleParams(vehicleId, objective, doorsLocked)
    if block_rpcs == true and doorsLocked == true and string.find(arg1, vehicleId, 1, true) then
        return false
    end
end

function WarpToVehicle(ID)
	if isCharInAnyCar(PLAYER_PED) then
		sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}You must not be driving!", 0xb700d4) 
	else
		local result, warp_handle = sampGetCarHandleBySampVehicleId(ID)
		if not select(1, sampGetCarHandleBySampVehicleId(ID)) then
			sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}There is no car under this ID in the stream zone!", 0xb700d4)    
		else
			warpCharIntoCar(PLAYER_PED, warp_handle)
		end
	end
end

function ExplodeVehicle(ID)
	if isCharInAnyCar(PLAYER_PED) then
		sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}You must not be driving!", 0xb700d4) 
	else
		local warp_x, warp_y, warp_z = getCharCoordinates(PLAYER_PED)
		local result, explode_handle = sampGetCarHandleBySampVehicleId(ID)
		if not select(1, sampGetCarHandleBySampVehicleId(ID)) then
			sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}There is no car under this ID in the stream zone!", 0xb700d4)    
		else
			warpCharIntoCar(PLAYER_PED, explode_handle)
			setCarHealth(explode_handle, 1)
			warpCharFromCarToCoord(PLAYER_PED, warp_x, warp_y, warp_z)
		end
	end
end

function GetVehicle(ID)
	if ID == "" then
        sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}You didn't enter a vehicle ID!", -1)
    else
        if not tonumber(ID) then
            sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}Incorrectly entered machine ID! (remove letters from ID)", -1)
        else
            local getveh_x, getveh_y, getveh_z = getCharCoordinates(PLAYER_PED)
            local getveh_result, getveh_handle = sampGetCarHandleBySampVehicleId(ID)
            if not select(1, sampGetCarHandleBySampVehicleId(ID)) then
                sampAddChatMessage("{b700d4}[XEZIOS]: {ffffff}There is no car under this ID in the stream zone!", -1)
            else
                warpCharIntoCar(PLAYER_PED, getveh_handle)
                setCharCoordinates(PLAYER_PED, getveh_x, getveh_y, getveh_z)
            end
        end
    end
end

--[[
function LoadChatScript()
	local sms_file = ('sms')
    local sms_script_path = getWorkingDirectory()..'\\test\\'..sms_file..'.lua'
    if doesFileExist(sms_script_path) then
        thisScript().load(sms_script_path)
    else
        sampAddChatMessage('{b700d4}[XEZIOS]: {B9C9BF}Error: {ffffff}'..sms_file..'.lua {B9C9BF}is missing', 0xb700d4)
    end
end 
--]]

-- SMS

local RECEIVED_MESSAGES = {}
local HISTORY_LOG = {}
 
function AddMessage(text)
    table.insert(RECEIVED_MESSAGES, text)
end
 
function DrawMessages()
	imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.02, 0.02, 0.02, 1))
	imgui.BeginChild('##messages', imgui.ImVec2(0, 193), true, imgui.WindowFlags.HorizontalScrollbar)
		for index, text in ipairs(RECEIVED_MESSAGES) do
			imgui.TextColoredRGB(text)
		end
	imgui.EndChild()
	imgui.PopStyleColor(1)
end

function AddHistory(text)
    table.insert(HISTORY_LOG, text)
end

function DrawHistory()
	imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.02, 0.02, 0.02, 1))
	imgui.BeginChild('##history', imgui.ImVec2(0, 0), true)
		for index, text in ipairs(HISTORY_LOG) do
			imgui.TextColoredRGB(text)
		end
	imgui.EndChild()
	imgui.PopStyleColor(1)
end

function CleanMessages()
	RECEIVED_MESSAGES = {}
end

function ConnectToHandle(handle)
	broadcaster_handle = handle
	broadcaster.registerHandler(handle, broadcaster_callback)
	script.handle_input.v = ''
	SendOnline()
end

function SendOnline()
    lua_thread.create(function()
		local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		broadcaster_send(("{"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")..' ('..my_id..') {00b140}[Connected]')
    end)
end

function DisconnectDromHandle(handle)
	lua_thread.create(function()
		AddHistory('[LOG]: You have disconnected from: '..handle)
		local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		broadcaster_send(("{"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")..' ('..my_id..'): {ff0000}[Disconnected]')
		broadcaster.unregisterHandler(handle)
		script.readdy = false
		sampAddChatMessage((("{"..(string.gsub(("%X"):format(sampGetPlayerColor(my_id)), "..(......)", "%1")).."}"..sampGetPlayerNickname(my_id).."")..' ('..my_id..'): {ff0000}[Disconnected]'), 0xB9C9BF)
	end)
end

function broadcaster_send(text)
    broadcaster.sendMessage(text, broadcaster_handle)	
end

function broadcaster_callback(message)
	if script.readdy == true then
		if not script.sms_window.v then
			if script.sms_in_chat.v then
				sampAddChatMessage('{9808cc}[SMS]: {ffffff}'..(u8:decode(message)), -1)
			end
			if script.receive_sound.v then
				setAudioStreamState(loadAudioStream('moonloader/xezios/sounds/bell.mp3'), 1)
			end
		end
		AddMessage(u8:decode(message))
	end
end

function onScriptTerminate(scr)
    if scr == thisScript() then
        broadcaster.unregisterHandler(broadcaster_handle)
		sampAddChatMessage("{b700d4}[XEZIOS]:{B9C9BF} crashed", 0xFFFFFF)
    end
end

--[[
function checkKey()
	license_response = requests.get("https://xezios-db.000webhostapp.com/auth.php?code=86779110459625530932")
	license_result = license_response.text:match("<license>(.*)</license>")
	
	if license_result:find('work') then
		imgui.TextWrapped('work')
	elseif license_result:find('not_w0rk') then
		imgui.TextWrapped('not work')
	else
		imgui.TextWrapped('error')
	end
end
--]]

function ShowWindowsMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end

--imgui.KnobFloat('Knob', script.RapidSpeed, 1, 15)

function imgui.KnobFloat(label, p_value, v_min, v_max)
    local p_value = p_value.v
	
	local style = imgui.GetStyle()
    local io = imgui.GetIO()
	
    local radius_outer = 20.0
    local pos = imgui.GetCursorScreenPos()
    local center = imgui.ImVec2(pos.x + radius_outer, pos.y + radius_outer)
    local line_height = imgui.GetTextLineHeight()
    local draw_list = imgui.GetWindowDrawList()

    local ANGLE_MIN = 3.141592 * 0.75
    local ANGLE_MAX = 3.141592 * 2.25

    imgui.InvisibleButton(label, imgui.ImVec2(radius_outer * 2, radius_outer * 2 + line_height + style.ItemInnerSpacing.y))
    local value_changed = false
    local is_active = imgui.IsItemActive()
    local is_hovered = imgui.IsItemActive()
    if is_active and not io.MouseDelta.x == 0.0 then
        local step = (v_max - v_min) / 200.0
        p_value = p_value + io.MouseDelta.x * step
        if (p_value < v_min) then p_value = v_min end
        if (p_value > v_max) then p_value = v_max end
        value_changed = true
    end
	
	if is_active then
		col = imgui.GetStyle().Colors[imgui.Col.FrameBgActive]
	else
		col = imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]
	end

    local t = (p_value - v_min) / (v_max - v_min)
    local angle = ANGLE_MIN + (ANGLE_MAX - ANGLE_MIN) * t
    local angle_cos = math.cos(angle)
	local angle_sin = math.sin(angle)
    local radius_inner = radius_outer * 0.40
    draw_list:AddCircleFilled(center, radius_outer, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg]), 16)
    draw_list:AddLine(imgui.ImVec2(center.x + angle_cos * radius_inner, center.y + angle_sin * radius_inner), imgui.ImVec2(center.x + angle_cos * (radius_outer - 2), center.y + angle_sin * (radius_outer - 2)), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]), 2.0)
    draw_list:AddCircleFilled(center, radius_inner, imgui.GetColorU32(col), 16)
    draw_list:AddText(imgui.ImVec2(pos.x, pos.y + radius_outer * 2 + style.ItemInnerSpacing.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Text]), label)

    if (is_active or is_hovered) then
        imgui.SetNextWindowPos(imgui.ImVec2(pos.x - style.WindowPadding.x, pos.y - line_height - style.ItemInnerSpacing.y - style.WindowPadding.y))
        imgui.BeginTooltip()
        imgui.Text(string.format('%.3f', (p_value)))
        imgui.EndTooltip()
    end

    return value_changed
end

--[[ function onScriptTerminate(LuaScript, quitGame) then 
    if LuaScript == thisScript() then
		sampAddChatMessage("The project crashed", 0xFFFFFF)
    end
end --]]

--print(var or 'ERROR') -- Anti crasher !


--[[
-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
	if not file_exists(file) then return {"error"} end
	local lines = {}
	for line in io.lines(file) do 
		lines[#lines + 1] = line
	end
	return lines
end

-- tests the functions above
local file = getWorkingDirectory()..'/xezios.lua'
local lines = lines_from(file)

-- print all line numbers and their contents
for k,v in pairs(lines) do
	print(v)
end

--]]
--[[
function GetCurrentLuaFile()
    local source = debug.getinfo(2, "S").source
    if source:sub(1,1) == "@" then
        return source:sub(2)
    else
        error("Caller was not defined in a file", 2)
    end
end

print(getWorkingDirectory()..'\\')
print(GetCurrentLuaFile())
print((GetCurrentLuaFile()):gsub(tostring(getWorkingDirectory()..'\\'), ''))
--]]

--[[
for i=0,35 do 
	print(i) 
end
--]]

--[[
function range(to)
    return function (_,last)
		if last >= to-1 then 
			return nil
		else 
			return last+1
		end
	end , nil , -1
end

for var in range(36) do
	print (var)
end
--]]