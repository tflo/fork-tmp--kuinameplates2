--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
local folder,ns=...
local kui = LibStub('Kui-1.0')
local kc = LibStub('KuiConfig-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local addon = KuiNameplates
local core = KuiNameplatesCore
-- add media to LSM ############################################################
LSM:Register(LSM.MediaType.FONT,'Yanone Kaffesatz Bold',kui.m.f.yanone)
LSM:Register(LSM.MediaType.FONT,'FrancoisOne',kui.m.f.francois)

LSM:Register(LSM.MediaType.STATUSBAR, 'Kui status bar', kui.m.t.bar)
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui shaded bar', kui.m.t.oldbar)

local locale = GetLocale()
local latin  = (locale ~= 'zhCN' and locale ~= 'zhTW' and locale ~= 'koKR' and locale ~= 'ruRU')

local DEFAULT_FONT = latin and 'FrancoisOne' or LSM:GetDefault(LSM.MediaType.FONT)
local DEFAULT_BAR = 'Kui status bar'
-- default configuration #######################################################
local default_config = {
    bar_texture = DEFAULT_BAR,
    nameonly = true,
    glow_as_shadow = true,
    target_glow = true,
    target_glow_colour = { .3, .7, 1, 1 },

    font_face = DEFAULT_FONT,
    font_style = 2,
    hide_names = true,
    font_size_normal = 11,
    font_size_small = 9,

    frame_width = 132,
    frame_height = 13,
    frame_width_minus = 72,
    frame_height_minus = 9,

    castbar_enable = true,
    castbar_showpersonal = false,
    castbar_showall = true,
    castbar_showfriend = true,
    castbar_showenemy = true,

    tank_mode = true,
    threat_brackets = false,
}
-- config changed functions ####################################################
local configChanged = {}
function configChanged.tank_mode(v)
    if v then
        addon:GetPlugin('TankMode'):Enable()
    else
        addon:GetPlugin('TankMode'):Disable()
    end
end

function configChanged.castbar_enable(v)
    if v then
        addon:GetPlugin('CastBar'):Enable()
    else
        addon:GetPlugin('CastBar'):Disable()
    end
end

function configChanged.bar_texture()
    core:configChangedBarTexture()
end

function configChanged.target_glow_colour()
    core:SetTargetGlowLocals()
end

local function configChangedFrameSize()
    -- TODO auras frame size needs to be updated
    core:SetFrameSizeLocals()
end
configChanged.frame_width = configChangedFrameSize
configChanged.frame_height = configChangedFrameSize
configChanged.frame_width_minus = configChangedFrameSize
configChanged.frame_height_minus = configChangedFrameSize

local function configChangedFontOption()
    core:configChangedFontOption()
end
configChanged.font_face = configChangedFontOption
configChanged.font_size_normal = configChangedFontOption
configChanged.font_size_small = configChangedFontOption
-- config loaded functions #####################################################
local configLoaded = {}
function configLoaded.tank_mode(v)
    configChanged.tank_mode(v)
end
function configLoaded.castbar_enable(v)
    configChanged.castbar_enable(v)
end
-- init config #################################################################
function core:InitialiseConfig()
    self.config = kc:Initialise('KuiNameplatesCore',default_config)
    self.profile = self.config:GetConfig()

    self.config:RegisterConfigChanged(function(self,k,v)
        core.profile = self:GetConfig()

        if k then
            -- call affected listener
            if configChanged[k] then
                configChanged[k](v)
            end
        else
            -- profile changed; call all listeners
            for k,f in pairs(configChanged) do
                f(core.profile[k])
            end
        end

        for i,f in addon:Frames() do
            -- hide and re-show frames
            if f:IsShown() then
                f.handler:OnHide()
                f.handler:OnUnitAdded(f.parent.namePlateUnitToken)
            end
        end
    end)

    -- run config loaded functions
    for k,f in pairs(configLoaded) do
        f(self.profile[k])
    end

    -- inform config addon that the config table is available if it's loaded
    if KuiNameplatesCoreConfig then
        KuiNameplatesCoreConfig:LayoutLoaded()
    end
end
