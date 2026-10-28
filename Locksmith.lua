-- Lightweight bootstrap: wait for a supported class or profession.
local boot=CreateFrame('Frame')
local started=false
local loggedIn=false
local function eligible()
  local _,class=UnitClass('player')
  if class=='ROGUE' then return true end
  local smith,engineer=GetSpellInfo(2018),GetSpellInfo(4036)
  for i=1,1000 do
    local name=GetSpellName(i,BOOKTYPE_SPELL)
    if not name then break end
    if (smith and name==smith) or (engineer and name==engineer) then return true end
  end
  return false
end
local function activate()
-- Locksmith 1.0.0, for the 3.3.5a client.
local tooltipTranslations = {
  enUS = {"Lockpicking skill too low.", "Click to use instead:", "Open with", "Unable to unlock", "Unable to determine lock requirement.", "Unable to determine Lockpicking skill.", "Lockpicking skill too low. No suitable key or charge available.", "No suitable key or charge available.", "Click, then click the locked item, door, or chest.", "Opens locks up to %d skill.", "Left-click: toggle unlock panel", "Right-click: options", "Drag to move around the minimap", "Unlock", "Try right-clicking without a modifier to open Locksmith."},
  deDE = {"Schlossknacken-Fertigkeit zu niedrig.", "Stattdessen klicken für:", "Öffnen mit", "Öffnen nicht möglich", "Schlossanforderung konnte nicht ermittelt werden.", "Schlossknacken-Fertigkeit konnte nicht ermittelt werden.", "Schlossknacken-Fertigkeit zu niedrig. Kein passender Schlüssel oder Sprengsatz verfügbar.", "Kein passender Schlüssel oder Sprengsatz verfügbar.", "Klicken und dann den verschlossenen Gegenstand, die Tür oder die Truhe anklicken.", "Öffnet Schlösser bis Fertigkeit %d.", "Linksklick: Fenster ein- oder ausblenden", "Rechtsklick: Optionen", "Ziehen: um die Minikarte verschieben", "Öffnen", "Versuche einen Rechtsklick ohne Zusatztaste, um Locksmith zu öffnen."},
  frFR = {"Compétence en crochetage trop faible.", "Cliquer pour utiliser à la place :", "Ouvrir avec", "Impossible de déverrouiller", "Impossible de déterminer la compétence requise.", "Impossible de déterminer la compétence en crochetage.", "Compétence en crochetage trop faible. Aucune clé ou charge adaptée disponible.", "Aucune clé ou charge adaptée disponible.", "Cliquez, puis cliquez sur l’objet verrouillé, la porte ou le coffre.", "Ouvre les serrures jusqu’au niveau de compétence %d.", "Clic gauche : afficher ou masquer la fenêtre", "Clic droit : options", "Faire glisser autour de la minicarte", "Déverrouiller", "Essayez un clic droit sans touche modificatrice pour ouvrir Locksmith."},
  esES = {"Habilidad de abrir cerraduras demasiado baja.", "Haz clic para usar en su lugar:", "Abrir con", "No se puede abrir", "No se puede determinar el requisito de la cerradura.", "No se puede determinar la habilidad de abrir cerraduras.", "Habilidad de abrir cerraduras demasiado baja. No hay ninguna llave o carga adecuada disponible.", "No hay ninguna llave o carga adecuada disponible.", "Haz clic y luego en el objeto cerrado, la puerta o el cofre.", "Abre cerraduras de hasta %d de habilidad.", "Clic izquierdo: mostrar u ocultar la ventana", "Clic derecho: opciones", "Arrastrar para mover por el minimapa", "Abrir", "Prueba a hacer clic derecho sin modificadores para abrir Locksmith."},
  ruRU = {"Недостаточный навык взлома замков.", "Нажмите, чтобы использовать вместо этого:", "Открыть с помощью", "Не удалось открыть", "Не удалось определить требование замка.", "Не удалось определить навык взлома замков.", "Недостаточный навык взлома замков. Нет подходящего ключа или заряда.", "Нет подходящего ключа или заряда.", "Нажмите, затем выберите запертый предмет, дверь или сундук.", "Открывает замки до %d уровня навыка.", "Левая кнопка: показать или скрыть окно", "Правая кнопка: настройки", "Перетащите вокруг мини-карты", "Открыть", "Попробуйте нажать правой кнопкой без модификатора, чтобы открыть Locksmith."},
  koKR = {"자물쇠 숙련도가 부족합니다.", "대신 사용하려면 클릭:", "열기:", "열 수 없음", "자물쇠 요구 조건을 확인할 수 없습니다.", "자물쇠 숙련도를 확인할 수 없습니다.", "자물쇠 숙련도가 부족합니다. 적합한 열쇠나 폭탄이 없습니다.", "적합한 열쇠나 폭탄이 없습니다.", "클릭한 후 잠긴 물건, 문 또는 상자를 클릭하세요.", "숙련도 %d 이하의 자물쇠를 엽니다.", "왼쪽 클릭: 창 열기 또는 닫기", "오른쪽 클릭: 설정", "드래그하여 미니맵 주위로 이동", "열기", "보조 키 없이 우클릭하여 Locksmith를 열어 보세요."},
  zhCN = {"开锁技能不足。", "点击改用：", "使用以下物品开启", "无法解锁", "无法确定开锁要求。", "无法确定开锁技能。", "开锁技能不足，且没有合适的钥匙或炸药。", "没有合适的钥匙或炸药。", "点击后再点击上锁的物品、门或箱子。", "可开启技能要求不超过 %d 的锁。", "左键：显示或隐藏窗口", "右键：设置", "拖动以沿小地图移动", "解锁", "尝试不按修饰键直接右键点击，以打开 Locksmith。"},
  zhTW = {"開鎖技能不足。", "點擊改用：", "使用以下物品開啟", "無法解鎖", "無法確定開鎖需求。", "無法確定開鎖技能。", "開鎖技能不足，且沒有合適的鑰匙或炸藥。", "沒有合適的鑰匙或炸藥。", "點擊後再點擊上鎖的物品、門或箱子。", "可開啟技能需求不超過 %d 的鎖。", "左鍵：顯示或隱藏視窗", "右鍵：設定", "拖曳以沿小地圖移動", "解鎖", "試著不按輔助鍵直接右鍵點擊，以開啟 Locksmith。"},
  ptBR = {"Perícia de arrombamento insuficiente.", "Clique para usar em vez disso:", "Abrir com", "Não é possível abrir", "Não foi possível determinar o requisito da fechadura.", "Não foi possível determinar a perícia de arrombamento.", "Perícia de arrombamento insuficiente. Nenhuma chave ou carga adequada disponível.", "Nenhuma chave ou carga adequada disponível.", "Clique e depois no item trancado, na porta ou no baú.", "Abre fechaduras de até %d de perícia.", "Clique esquerdo: mostrar ou ocultar a janela", "Clique direito: opções", "Arraste ao redor do minimapa", "Abrir", "Tente clicar com o botão direito sem modificadores para abrir o Locksmith."},
  itIT = {"Abilità di scassinamento troppo bassa.", "Clicca per usare invece:", "Apri con", "Impossibile aprire", "Impossibile determinare il requisito della serratura.", "Impossibile determinare l’abilità di scassinamento.", "Abilità di scassinamento troppo bassa. Nessuna chiave o carica adatta disponibile.", "Nessuna chiave o carica adatta disponibile.", "Clicca, poi clicca sull’oggetto chiuso, sulla porta o sul forziere.", "Apre serrature fino a %d di abilità.", "Clic sinistro: mostra o nasconde la finestra", "Clic destro: opzioni", "Trascina intorno alla minimappa", "Apri", "Prova a fare clic destro senza modificatori per aprire Locksmith."},
}
tooltipTranslations.enGB=tooltipTranslations.enUS
tooltipTranslations.esMX=tooltipTranslations.esES
local T=tooltipTranslations[GetLocale()] or tooltipTranslations.enUS
local noItemsMessages={
  enUS='No charges or keys available', enGB='No charges or keys available',
  deDE='Keine Sprengladungen oder Schlüssel verfügbar',
  frFR='Aucune charge ni clé disponible',
  esES='No hay cargas ni llaves disponibles', esMX='No hay cargas ni llaves disponibles',
  ruRU='Нет доступных зарядов или ключей', koKR='사용 가능한 폭탄이나 열쇠가 없습니다',
  zhCN='没有可用的炸药或钥匙', zhTW='沒有可用的炸藥或鑰匙',
  ptBR='Nenhuma carga ou chave disponível', itIT='Nessuna carica o chiave disponibile',
}
local noItemsMessage=noItemsMessages[GetLocale()] or noItemsMessages.enUS
local driver = CreateFrame('Frame')
local _, class = UnitClass('player')
-- Ordered by maximum lock strength; equally strong keys precede charges.
local keys = {
  {15869,25,100,'Silver Skeleton Key','Blacksmithing'},
  {15870,125,150,'Golden Skeleton Key','Blacksmithing'},
  {4367,150,100,'Small Seaforium Charge','Engineering'},
  {15871,200,200,'Truesilver Skeleton Key','Blacksmithing'},
  {4398,250,200,'Large Seaforium Charge','Engineering'},
  {15872,300,275,'Arcanite Skeleton Key','Blacksmithing'},
  {18594,300,275,'Powerful Seaforium Charge','Engineering'},
  {23819,350,350,'Elemental Seaforium Charge','Engineering'},
  {43854,375,350,'Cobalt Skeleton Key','Blacksmithing'},
  {43853,400,430,'Titanium Skeleton Key','Blacksmithing'},
}
local function say(s) DEFAULT_CHAT_FRAME:AddMessage('|cff54c4ffLocksmith:|r '..s) end
local skillNames = {
  Lockpicking = GetSpellInfo(1809),
  Blacksmithing = GetSpellInfo(2018) or 'Blacksmithing',
  Engineering = GetSpellInfo(4036) or 'Engineering',
}
local function skill(name)
  name=skillNames[name] or name
  for i=1,GetNumSkillLines() do
    local n, header, _, rank = GetSkillLineInfo(i)
    if not header and n == name then return rank end
  end
end
local function knowsPick()
  if class ~= 'ROGUE' then return false end
  local wanted = GetSpellInfo(1804)
  if not wanted then return false end
  for i=1,1000 do
    local name = GetSpellName(i, BOOKTYPE_SPELL)
    if not name then break end
    if name == wanted then return wanted end
  end
end
local function findKeys()
  local found = {}
  for bag=-2,4 do
    if bag == -2 or bag >= 0 then
      for slot=1,GetContainerNumSlots(bag) or 0 do
        local link = GetContainerItemLink(bag,slot)
        local id = link and tonumber(link:match('item:(%d+)'))
        if id then
          local _,count=GetContainerItemInfo(bag,slot)
          if not found[id] then found[id] = {bag,slot,0} end
          found[id][3]=found[id][3]+(count or 0)
        end
      end
    end
  end
  return found
end
local scan = CreateFrame('GameTooltip','LocksmithScanTooltip',UIParent,'GameTooltipTemplate')
local function requirement(bag,slot)
  scan:SetOwner(UIParent,'ANCHOR_NONE')
  scan:ClearLines()
  scan:SetBagItem(bag,slot)
  local required
  for i=1,scan:NumLines() do
    local line = _G['LocksmithScanTooltipTextLeft'..i]
    local text = line and line:GetText()
    if text then
      local skillText=skillNames.Lockpicking
      if skillText then
        -- Construct the client's own localized requirement, including its word order.
        if ITEM_MIN_SKILL then
          local ok,sample=pcall(string.format,ITEM_MIN_SKILL,skillText,987654321)
          if ok then
            local pattern=sample:gsub('([^%w])','%%%1'):gsub('987654321','(%%d+)')
            required=tonumber(text:match('^'..pattern..'$'))
          end
        end
        if not required then
          local start,finish=text:find(skillText,1,true)
          if start then required=tonumber(text:sub(finish+1):match('^%s*%((%d+)%)')) end
        end
      end
      if required then break end
    end
  end
  scan:Hide()
  return required
end
local function isLockedBagItem(bag,slot)
  scan:SetOwner(UIParent,'ANCHOR_NONE'); scan:ClearLines(); scan:SetBagItem(bag,slot)
  local locked=false
  for i=1,scan:NumLines() do
    local line=_G['LocksmithScanTooltipTextLeft'..i]
    local text=line and line:GetText()
    if text and (text == (LOCKED or 'Locked') or (skillNames.Lockpicking and text:find(skillNames.Lockpicking,1,true) and text:match('%(%d+%)'))) then
      locked=true; break
    end
  end
  scan:Hide()
  return locked
end
local function method(required)
  if not required then return end -- Never guess when a key could be consumed.
  local spell = knowsPick()
  local lp = skill('Lockpicking')
  if spell and not lp then return end -- Skill is unknown: never spend a key automatically.
  if spell and lp and lp >= required then return 'spell',spell end
  local found=findKeys()
  local ranks={Blacksmithing=skill('Blacksmithing'), Engineering=skill('Engineering')}
  for _,k in ipairs(keys) do
    local loc,rank=found[k[1]],ranks[k[5]]
    if loc and rank and rank >= k[3] and required <= k[2] then
      return 'item',GetContainerItemLink(loc[1],loc[2]),GetItemInfo(k[1]) or k[4],loc[3]
    end
  end
end
local overlay = CreateFrame('Button','LocksmithInventoryButton',UIParent,'SecureActionButtonTemplate,SecureHandlerStateTemplate')
overlay:RegisterForClicks('LeftButtonUp','RightButtonUp')
overlay:SetFrameStrata('TOOLTIP')
-- Keep the underlying item visible, with a clear modifier-ready indicator.
local readyHighlight=overlay:CreateTexture(nil,'OVERLAY')
readyHighlight:SetAllPoints(overlay)
readyHighlight:SetTexture('Interface\\Buttons\\UI-Common-MouseHilight')
readyHighlight:SetBlendMode('ADD'); readyHighlight:SetVertexColor(1,0.82,0.2,0.8)
local readyKey=overlay:CreateTexture(nil,'OVERLAY')
readyKey:SetWidth(13); readyKey:SetHeight(13)
readyKey:SetPoint('TOPRIGHT',overlay,'TOPRIGHT',1,1)
readyKey:SetTexture('Interface\\Icons\\INV_Misc_Key_03')
readyKey:SetTexCoord(0.07,0.93,0.07,0.93)
overlay:SetAttribute('_onstate-combat', 'if newstate == "1" then self:Hide() end')
RegisterStateDriver(overlay,'combat','[combat] 1; 0')
overlay:Hide()
-- Secure confirmation: the follow-up click is the only action that uses a key.
local confirm=CreateFrame('Frame','LocksmithKeyConfirm',UIParent,'SecureHandlerStateTemplate')
confirm:SetWidth(210); confirm:SetHeight(136); confirm:SetFrameStrata('TOOLTIP'); confirm:SetFrameLevel(150)
confirm:SetClampedToScreen(true); confirm:EnableMouse(true)
confirm:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',tile=true,tileSize=32,edgeSize=16,
  insets={left=4,right=4,top=4,bottom=4}})
-- A solid background keeps the dialog readable over bag icons and UI skins.
local confirmBackground=confirm:CreateTexture(nil,'BACKGROUND')
confirmBackground:SetPoint('TOPLEFT',confirm,'TOPLEFT',4,-4)
confirmBackground:SetPoint('BOTTOMRIGHT',confirm,'BOTTOMRIGHT',-4,4)
confirmBackground:SetTexture(0.035,0.035,0.035,1)
confirm:SetAttribute('_onstate-combat','if newstate == "1" then self:Hide() end')
RegisterStateDriver(confirm,'combat','[combat] 1; 0')
table.insert(UISpecialFrames,'LocksmithKeyConfirm')
local confirmText=confirm:CreateFontString(nil,'OVERLAY','GameFontHighlight')
confirmText:SetPoint('TOPLEFT',confirm,'TOPLEFT',12,-12)
confirmText:SetPoint('TOPRIGHT',confirm,'TOPRIGHT',-12,-12)
confirmText:SetHeight(64); confirmText:SetJustifyH('CENTER'); confirmText:SetJustifyV('TOP')
if confirmText.SetWordWrap then confirmText:SetWordWrap(true) end
confirmText:SetText(T[1])
local confirmItem=confirm:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
confirmItem:SetPoint('TOPLEFT',confirmText,'BOTTOMLEFT',0,-3)
confirmItem:SetPoint('TOPRIGHT',confirmText,'BOTTOMRIGHT',0,-3)
confirmItem:SetHeight(72); confirmItem:SetJustifyH('CENTER'); confirmItem:SetJustifyV('TOP')
if confirmItem.SetWordWrap then confirmItem:SetWordWrap(true) end
local yes=CreateFrame('Button','LocksmithConfirmUseKey',confirm,'SecureActionButtonTemplate,UIPanelButtonTemplate')
yes:SetWidth(82); yes:SetHeight(22); yes:SetPoint('BOTTOMLEFT',confirm,'BOTTOMLEFT',15,10)
yes:SetFrameStrata('TOOLTIP'); yes:SetFrameLevel(160)
yes:SetText('Use'); yes:RegisterForClicks('LeftButtonUp'); yes:Show()
yes:HookScript('OnClick',function() if not InCombatLockdown() then confirm:Hide() end end)
local no=CreateFrame('Button',nil,confirm,'UIPanelButtonTemplate')
no:SetWidth(82); no:SetHeight(22); no:SetPoint('BOTTOMRIGHT',confirm,'BOTTOMRIGHT',-15,10); no:SetText('Cancel')
no:SetFrameStrata('TOOLTIP'); no:SetFrameLevel(160); no:Show()
no:SetScript('OnClick',function() if not InCombatLockdown() then confirm:Hide() end end)
confirm:Hide()
local confirmPending=false
local pendingLink,pendingBag,pendingSlot
local function resizeConfirm()
  -- Measure the wrapped text so longer item names and translations get room.
  confirmText:SetHeight(64); confirmItem:SetHeight(72)
  local titleHeight=math.max(14,math.ceil(confirmText:GetStringHeight() or 0))
  local itemHeight=math.max(14,math.ceil(confirmItem:GetStringHeight() or 0))
  confirmText:SetHeight(titleHeight); confirmItem:SetHeight(itemHeight)
  confirm:SetHeight(12+titleHeight+3+itemHeight+8+22+10)
end
local function skinConfirmButtons()
  if confirm.elvButtonsSkinned or not IsAddOnLoaded('ElvUI') then return end
  local E=type(_G.ElvUI)=='table' and _G.ElvUI[1]
  if type(E)~='table' or type(E.GetModule)~='function' then return end
  local ok,skins=pcall(E.GetModule,E,'Skins',true)
  if not ok or type(skins)~='table' or type(skins.HandleButton)~='function' then return end
  ok=pcall(function() skins:HandleButton(yes); skins:HandleButton(no) end)
  if ok then confirm.elvButtonsSkinned=true end
end
local function showConfirm()
  if InCombatLockdown() or not confirmPending or not pendingLink then return end
  local current=GetContainerItemLink(pendingBag,pendingSlot)
  if not current or current~=confirm.targetLink then return end
  skinConfirmButtons()
  resizeConfirm()
  local x,y=GetCursorPosition(); local scale=UIParent:GetEffectiveScale()
  confirm:ClearAllPoints(); confirm:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',x/scale+12,y/scale-12)
  yes:Show(); no:Show()
  confirm:Show()
end
overlay:HookScript('OnClick',function(_,button)
  if (button=='RightButton' or button=='LeftButton') and confirmPending then showConfirm() end
end)
-- Route left clicks through the same secure action branch as working right clicks.
SecureHandlerWrapScript(overlay,'OnClick',overlay,[[
  if button == 'LeftButton' then return 'RightButton' end
]])
local tracked, trackedBag, trackedSlot
local readyName,readyCount,readyNeedsConfirm,tooltipSignature
local function updateReadyTooltip()
  if not trackedBag or not trackedSlot or not readyName then return end
  GameTooltip:SetOwner(overlay,'ANCHOR_RIGHT')
  GameTooltip:ClearLines()
  GameTooltip:SetBagItem(trackedBag,trackedSlot)
  if readyNeedsConfirm then
    GameTooltip:AddLine(T[1],1,0.82,0,true)
    GameTooltip:AddLine(T[2],1,0.82,0,true)
    GameTooltip:AddLine(readyName..' ('..readyCount..')',1,0.82,0,true)
  elseif class=='ROGUE' and readyName==GetSpellInfo(1804) then
    GameTooltip:AddLine(readyName,0.3,1,0.4,true)
  else
    GameTooltip:AddLine(T[3],0.3,1,0.4,true)
    GameTooltip:AddLine(readyName..' ('..readyCount..')',0.3,1,0.4,true)
  end
  GameTooltip:Show()
  tooltipSignature=tostring(trackedBag)..':'..tostring(trackedSlot)..':'..readyName..':'..tostring(readyCount)..':'..tostring(readyNeedsConfirm)
end
overlay:SetScript('OnEnter',updateReadyTooltip)
overlay:SetScript('OnLeave',function(self)
  tooltipSignature=nil
  if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end)
local bankOpen=false
local bankState=CreateFrame('Frame')
bankState:RegisterEvent('BANKFRAME_OPENED'); bankState:RegisterEvent('BANKFRAME_CLOSED')
bankState:SetScript('OnEvent',function(_,event) bankOpen=(event=='BANKFRAME_OPENED') end)
local function resolve(frame)
  if not frame or not frame.GetID then return end
  local slot=frame:GetID()
  if not slot or slot < 1 then return end
  local name=frame:GetName() or ''
  local bag
  if name:match('^BankFrameItem%d+$') then
    if not bankOpen then return end
    bag=-1
  elseif name:match('^AdiBagsItemButton%d+$') then
    local parent=frame:GetParent()
    if not parent or not frame.container then return end
    if (parent.isBank or frame.container.isBank) and not bankOpen then return end
    if tonumber(frame.slot) ~= slot or tonumber(frame.bag) ~= parent:GetID() then return end
    bag=frame.bag
  elseif name:match('^OmniItemButton%d+$') then
    local info=frame.itemInfo
    if not info or info.__offline or info.__empty or tonumber(info.slotID) ~= slot then return end
    if tonumber(frame.slotID) ~= slot or tonumber(frame.bagID) ~= tonumber(info.bagID) then return end
    bag=info.bagID
  elseif name:match('^BagnonItemSlot%d+$') or (name:match('^ContainerFrame%d+Item%d+$') and type(frame.GetBag)=='function') then
    if type(frame.IsCached)=='function' and frame:IsCached() then return end
    if type(frame.GetBag)=='function' then bag=frame:GetBag() end
  elseif name:match('^ContainerFrame%d+Item%d+$') or name:match('^ElvUI_ContainerFrameBag%-?%d+Slot%d+$') then
    local parent=frame:GetParent(); bag=parent and parent:GetID()
    if name:match('^ElvUI_ContainerFrameBag%-?%d+Slot%d+$') then
      local namedBag,namedSlot=name:match('^ElvUI_ContainerFrameBag(%-?%d+)Slot(%d+)$')
      if tonumber(namedBag) ~= bag or tonumber(namedSlot) ~= slot then return end
    end
  elseif type(frame.GetBagID)=='function' and type(frame.GetClassName)=='function' and frame:GetClassName()=='BagnonContainerItem' then
    bag=frame:GetBagID()
  end
  bag=tonumber(bag)
  if bag and ((bag>=0 and bag<=4) or (bankOpen and (bag==-1 or (bag>=5 and bag<=11))))
      and slot <= (GetContainerNumSlots(bag) or 0) then return bag,slot end
end
-- Bag clicks at a merchant sell items; leave those interactions to the vendor.
local function tradingWindowOpen()
  return (MerchantFrame and MerchantFrame:IsShown()) or (AuctionFrame and AuctionFrame:IsShown())
end
local function modifierDown()
  local selected = (LocksmithDB and LocksmithDB.modifier) or 'alt'
  local shift, ctrl, alt = IsShiftKeyDown(), IsControlKeyDown(), IsAltKeyDown()
  if selected == 'shift' then return shift and not ctrl and not alt end
  if selected == 'ctrl' then return ctrl and not shift and not alt end
  return alt and not shift and not ctrl
end
-- Add unavailable explanations to the existing bag tooltip without covering the item.
-- That leaves its normal click behavior untouched.
local passiveFrame,passiveBag,passiveSlot,passiveMessage
local function clearPassiveTooltip()
  if passiveFrame and GameTooltip:IsOwned(passiveFrame) then
    if GetMouseFocus()==passiveFrame and GetContainerItemLink(passiveBag,passiveSlot) then
      GameTooltip:SetBagItem(passiveBag,passiveSlot)
      GameTooltip:Show()
    else
      GameTooltip:Hide()
    end
  end
  passiveFrame,passiveBag,passiveSlot,passiveMessage=nil,nil,nil,nil
end
local function showUnavailableTooltip(frame,bag,slot,required)
  if not GameTooltip:IsOwned(frame) or not GameTooltip:IsShown() then return end
  local spell=knowsPick()
  local lp=spell and skill('Lockpicking')
  local message
  if not required then
    message=T[5]
  elseif spell and not lp then
    message=T[6]
  elseif spell and lp < required then
    message=T[7]
  else
    message=T[8]
  end
  if passiveFrame and (passiveFrame~=frame or passiveBag~=bag or passiveSlot~=slot or passiveMessage~=message) then
    clearPassiveTooltip()
    if not GameTooltip:IsOwned(frame) then return end
  end
  -- Other addons may refresh their tooltip while it remains open.
  local present=false
  for i=1,GameTooltip:NumLines() do
    local line=_G['GameTooltipTextLeft'..i]
    if line and line:GetText()==message then present=true; break end
  end
  if not present then
    GameTooltip:AddLine(T[4],1,0.3,0.3,true)
    GameTooltip:AddLine(message,1,0.82,0,true)
    GameTooltip:Show()
  end
  passiveFrame,passiveBag,passiveSlot,passiveMessage=frame,bag,slot,message
end
local elapsed = 0
driver:SetScript('OnUpdate',function(_,dt)
  elapsed = elapsed + dt
  if elapsed < 0.08 then return end
  elapsed = 0
  if InCombatLockdown() then return end
  if (LocksmithDB and LocksmithDB.bagDetection == false) or not modifierDown() or tradingWindowOpen() then
    clearPassiveTooltip(); overlay:Hide(); tracked = nil; return
  end
  local focus = GetMouseFocus()
  if focus == overlay then focus = tracked end
  local bag,slot = resolve(focus)
  if not bag or not focus:IsVisible() then clearPassiveTooltip(); overlay:Hide(); tracked=nil; return end
  local req = requirement(bag,slot)
  local kind,value,keyName,keyCount = method(req)
  if not kind then
    overlay:Hide(); tracked=nil
    if isLockedBagItem(bag,slot) then
      showUnavailableTooltip(focus,bag,slot,req)
    else
      clearPassiveTooltip()
    end
    return
  end
  clearPassiveTooltip()
  local indicator
  if kind == 'spell' then
    local _,_,texture=GetSpellInfo(value)
    indicator=texture
  elseif kind == 'item' then
    indicator=GetItemIcon(value)
  end
  readyKey:SetTexture(indicator or 'Interface\\Icons\\INV_Misc_Key_03')
  local left,bottom,width,height = focus:GetLeft(),focus:GetBottom(),focus:GetWidth(),focus:GetHeight()
  if not left or not bottom or not width or not height then overlay:Hide(); tracked=nil; return end
  local scale = focus:GetEffectiveScale() / UIParent:GetEffectiveScale()
  overlay:ClearAllPoints()
  overlay:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',left*scale,bottom*scale)
  overlay:SetWidth(width*scale); overlay:SetHeight(height*scale)
  local mod = (LocksmithDB and LocksmithDB.modifier) or 'alt'
  local lp = class == 'ROGUE' and skill('Lockpicking')
  local needsConfirm = class == 'ROGUE' and knowsPick() and lp and req and lp < req and kind == 'item'
  confirmPending = not not needsConfirm
  if needsConfirm and not confirm:IsShown() then
    pendingLink,pendingBag,pendingSlot=value,bag,slot
    confirm.targetLink=GetContainerItemLink(bag,slot)
    confirmText:SetText(T[1])
    confirmItem:SetText(T[3]..'\n'..(keyName or value)..' ('..keyCount..')?')
    yes:SetAttribute('*type1','item'); yes:SetAttribute('*item1',value)
    yes:SetAttribute('target-bag',bag); yes:SetAttribute('target-slot',slot)
  end
  for _,prefix in ipairs({'alt','ctrl','shift'}) do
    for _,button in ipairs({'1','2'}) do
      overlay:SetAttribute(prefix..'-type'..button,prefix == mod and not needsConfirm and kind or nil)
      overlay:SetAttribute(prefix..'-spell'..button,prefix == mod and kind == 'spell' and value or nil)
      overlay:SetAttribute(prefix..'-item'..button,prefix == mod and kind == 'item' and value or nil)
    end
  end
  overlay:SetAttribute('target-bag',bag)
  overlay:SetAttribute('target-slot',slot)
  tracked,trackedBag,trackedSlot = focus,bag,slot
  readyName=(kind=='spell' and value) or keyName or (kind=='item' and GetItemInfo(value)) or 'selected item'
  readyCount=keyCount
  readyNeedsConfirm=not not needsConfirm
  local signature=tostring(bag)..':'..tostring(slot)..':'..readyName..':'..tostring(readyCount)..':'..tostring(readyNeedsConfirm)
  if overlay:IsShown() and GameTooltip:IsOwned(overlay) and tooltipSignature ~= signature then updateReadyTooltip() end
  overlay:Show()
end)

-- World lock requirements are not reliably exposed. Offer an explicit choice.
local panel = CreateFrame('Frame','LocksmithWorldPanel',UIParent,'SecureHandlerStateTemplate')
panel:SetAttribute('_onstate-combat', 'if newstate == "1" then self:Hide() end')
RegisterStateDriver(panel,'combat','[combat] 1; 0')
panel:SetPoint('CENTER',UIParent,'CENTER',0,-100)
table.insert(UISpecialFrames, 'LocksmithWorldPanel')
panel:SetFrameStrata('FULLSCREEN_DIALOG')
panel:SetFrameLevel(100)
panel:EnableMouse(true)
panel:SetMovable(true)
panel:SetClampedToScreen(true)
panel:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',tile=true,tileSize=32,edgeSize=16,
  insets={left=4,right=4,top=4,bottom=4}})
local title=panel:CreateFontString(nil,'OVERLAY','GameFontNormal')
title:SetPoint('TOPLEFT',panel,'TOPLEFT',9,-10); title:SetText('Locksmith')
local dragHandle=CreateFrame('Frame',nil,panel)
dragHandle:SetPoint('TOPLEFT',panel,'TOPLEFT',4,-3)
dragHandle:SetPoint('TOPRIGHT',panel,'TOPRIGHT',-24,-3)
dragHandle:SetHeight(22); dragHandle:EnableMouse(true); dragHandle:RegisterForDrag('LeftButton')
dragHandle:SetScript('OnDragStart',function() if not InCombatLockdown() then panel:StartMoving() end end)
dragHandle:SetScript('OnDragStop',function()
  if InCombatLockdown() then return end
  panel:StopMovingOrSizing()
  local x,y=panel:GetCenter()
  local ux,uy=UIParent:GetCenter()
  if x and y and ux and uy then
    LocksmithDB=LocksmithDB or {}
    LocksmithDB.windowX=x-ux; LocksmithDB.windowY=y-uy
    panel:ClearAllPoints(); panel:SetPoint('CENTER',UIParent,'CENTER',LocksmithDB.windowX,LocksmithDB.windowY)
  end
end)
local close=CreateFrame('Button',nil,panel,'UIPanelCloseButton')
close:SetWidth(20); close:SetHeight(20); close:SetPoint('TOPRIGHT',panel,'TOPRIGHT',-3,-3)
close:SetScript('OnClick',function() if not InCombatLockdown() then panel:Hide() end end)
local buttons={}
local pendingPanelSpell
for i=1,#keys+1 do
  local b=CreateFrame('Button','LocksmithWorldMethod'..i,panel,'SecureActionButtonTemplate')
  b:SetWidth(36); b:SetHeight(36); b:RegisterForClicks('LeftButtonUp','RightButtonUp')
  b.icon=b:CreateTexture(nil,'ARTWORK'); b.icon:SetAllPoints(b)
  b.icon:SetTexCoord(0.07,0.93,0.07,0.93)
  -- Keep the default border inside each button so adjacent icons never overlap.
  b.defaultBorder={}
  for edgeIndex=1,4 do
    local edge=b:CreateTexture(nil,'OVERLAY')
    edge:SetTexture(0.4,0.4,0.4,1)
    b.defaultBorder[edgeIndex]=edge
  end
  b.defaultBorder[1]:SetPoint('TOPLEFT',b,'TOPLEFT',0,0); b.defaultBorder[1]:SetPoint('TOPRIGHT',b,'TOPRIGHT',0,0); b.defaultBorder[1]:SetHeight(1)
  b.defaultBorder[2]:SetPoint('BOTTOMLEFT',b,'BOTTOMLEFT',0,0); b.defaultBorder[2]:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0); b.defaultBorder[2]:SetHeight(1)
  b.defaultBorder[3]:SetPoint('TOPLEFT',b,'TOPLEFT',0,0); b.defaultBorder[3]:SetPoint('BOTTOMLEFT',b,'BOTTOMLEFT',0,0); b.defaultBorder[3]:SetWidth(1)
  b.defaultBorder[4]:SetPoint('TOPRIGHT',b,'TOPRIGHT',0,0); b.defaultBorder[4]:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0); b.defaultBorder[4]:SetWidth(1)
  b.count=b:CreateFontString(nil,'OVERLAY','NumberFontNormal')
  b.count:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',-2,2)
  b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
  b:SetScript('OnEnter',function(self)
    GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
    GameTooltip:SetText(self.tipTitle or T[14])
    if self.tipDetail then GameTooltip:AddLine(self.tipDetail,1,1,1) end
    GameTooltip:AddLine(T[9],0.8,0.8,0.8,true)
    GameTooltip:Show()
  end)
  b:SetScript('OnLeave',function() GameTooltip:Hide() end)
  b:HookScript('OnClick',function(self) pendingPanelSpell=self.castName end)
  buttons[i]=b
end
local function tryElvSkin()
  if panel.elvSkinned or not IsAddOnLoaded('ElvUI') then return end
  local E=type(_G.ElvUI)=='table' and _G.ElvUI[1]
  if type(E)~='table' or type(E.GetModule)~='function' or not E.media or not E.private or
     type(E.db)~='table' or type(E.db.general)~='table' then return end
  if type(panel.SetTemplate)~='function' or type(panel.StripTextures)~='function' then return end
  local ok,skins=pcall(E.GetModule,E,'Skins',true)
  if not ok or type(skins)~='table' or type(skins.HandleCloseButton)~='function' then return end
  ok=pcall(function()
    panel:StripTextures(); panel:SetTemplate('Transparent')
    skins:HandleCloseButton(close)
  end)
  if ok then
    panel.elvSkinned=true
    for _,b in ipairs(buttons) do
      -- Use the approved ElvUI border styling.
      for _,edge in ipairs(b.defaultBorder) do edge:Hide() end
      if not b.elvBorder then
        b.elvBorder={}
        for i=1,4 do
          local edge=b:CreateTexture(nil,'OVERLAY')
          edge:SetTexture(0.25,0.25,0.25,1)
          b.elvBorder[i]=edge
        end
        b.elvBorder[1]:SetPoint('TOPLEFT',b,'TOPLEFT',0,0); b.elvBorder[1]:SetPoint('TOPRIGHT',b,'TOPRIGHT',0,0); b.elvBorder[1]:SetHeight(1)
        b.elvBorder[2]:SetPoint('BOTTOMLEFT',b,'BOTTOMLEFT',0,0); b.elvBorder[2]:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0); b.elvBorder[2]:SetHeight(1)
        b.elvBorder[3]:SetPoint('TOPLEFT',b,'TOPLEFT',0,0); b.elvBorder[3]:SetPoint('BOTTOMLEFT',b,'BOTTOMLEFT',0,0); b.elvBorder[3]:SetWidth(1)
        b.elvBorder[4]:SetPoint('TOPRIGHT',b,'TOPRIGHT',0,0); b.elvBorder[4]:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0); b.elvBorder[4]:SetWidth(1)
      end
    end
  end
end
panel:Hide()
local bagSource,tradePanel
panel:HookScript('OnHide',function() bagSource=nil; tradePanel=nil; pendingPanelSpell=nil end)
local bagMonitor=CreateFrame('Frame')
local bagMonitorElapsed=0
bagMonitor:SetScript('OnUpdate',function(_,dt)
  if not bagSource or not panel:IsShown() then return end
  bagMonitorElapsed=bagMonitorElapsed+dt
  if bagMonitorElapsed < 0.15 then return end
  bagMonitorElapsed=0
  if not InCombatLockdown() and not bagSource:IsVisible() then panel:Hide() end
end)
local function showPanel(source,silent,tradeContext)
  if InCombatLockdown() then say('Open the unlock panel outside combat.'); return end
  if tradeContext and not knowsPick() then return end
  if source then bagSource=source:GetParent() or source end
  tradePanel=not not tradeContext
  tryElvSkin()
  -- Keys and charges cannot enchant another player's item in a trade.
  local found = tradePanel and {} or findKeys()
  local ranks={Blacksmithing=skill('Blacksmithing'), Engineering=skill('Engineering')}
  local pickSpell=tradePanel and knowsPick()
  local countTotal=pickSpell and 1 or 0
  for _,k in ipairs(keys) do
    if found[k[1]] and ranks[k[5]] and ranks[k[5]] >= k[3] then countTotal=countTotal+1 end
  end
  if countTotal==0 then
    if panel:IsShown() then panel:Hide() end
    if not silent then UIErrorsFrame:AddMessage(noItemsMessage,1,0.1,0.1,1) end
    return
  end
  local count=0
  local function place(b)
    local column=count%4
    local row=math.floor(count/4)
    b:ClearAllPoints()
    if countTotal == 1 then
      b:SetPoint('BOTTOM',panel,'BOTTOM',0,8)
    else
      b:SetPoint('BOTTOMRIGHT',panel,'BOTTOMRIGHT',-6-column*40,8+row*40)
    end
    count=count+1; b:Show()
  end
  local pick=buttons[#keys+1]
  if pickSpell then
    local _,_,texture=GetSpellInfo(1804)
    pick.icon:SetTexture(texture or 'Interface\\Icons\\Spell_Nature_MoonKey')
    pick.castName=pickSpell; pick.count:SetText('')
    pick.tipTitle=pickSpell; pick.tipDetail=nil
    pick:SetAttribute('*type1','spell'); pick:SetAttribute('*spell1',pickSpell)
    pick:SetAttribute('*type2','spell'); pick:SetAttribute('*spell2',pickSpell)
    place(pick)
  else pick:Hide() end
  for i=#keys,1,-1 do
    local k=keys[i]
    local b,loc=buttons[i],found[k[1]]
    if loc and ranks[k[5]] and ranks[k[5]] >= k[3] then
      b.icon:SetTexture(GetItemIcon(k[1]) or 'Interface\\Icons\\INV_Misc_Key_03')
      b.castName=GetItemSpell(k[1])
      b.count:SetText(loc[3] >= 100 and '*' or tostring(loc[3]))
      b.tipTitle=(GetItemInfo(k[1]) or k[4])..' ('..loc[3]..')'; b.tipDetail=string.format(T[10],k[2])
      b:SetAttribute('*type1','item'); b:SetAttribute('*item1',GetContainerItemLink(loc[1],loc[2])); b:SetAttribute('*type2','item'); b:SetAttribute('*item2',GetContainerItemLink(loc[1],loc[2])); place(b)
    else b:Hide() end
  end
  local columns=math.min(count,4)
  local rows=math.ceil(count/4)
  panel:SetWidth(math.max(90,12+columns*36+math.max(0,columns-1)*4))
  panel:SetHeight(count > 0 and (29+rows*36+(rows-1)*4+8) or 58)
  -- Reposition only on a fresh open, unless the player chose a saved position.
  if not panel:IsShown() and not (LocksmithDB and type(LocksmithDB.windowX)=='number' and type(LocksmithDB.windowY)=='number') then
    local x,y=GetCursorPosition()
    local scale=UIParent:GetEffectiveScale()
    x,y=x/scale,y/scale
    local w,h=panel:GetWidth(),panel:GetHeight()
    local screenW,screenH=UIParent:GetWidth(),UIParent:GetHeight()
    local function bounds(frame)
      if not frame or not frame:IsShown() then return end
      local l,b,r,t=frame:GetLeft(),frame:GetBottom(),frame:GetRight(),frame:GetTop()
      if not l or not b or not r or not t then return end
      local factor=frame:GetEffectiveScale()/scale
      return {l*factor,b*factor,r*factor,t*factor}
    end
    local tip=bounds(GameTooltip)
    local focus=GetMouseFocus()
    if focus==overlay then focus=tracked end
    local itemFrame=(focus ~= WorldFrame and resolve(focus)) and bounds(focus) or nil
    local function overlap(left,bottom,rect)
      if not rect then return 0 end
      local ow=math.max(0,math.min(left+w,rect[3])-math.max(left,rect[1]))
      local oh=math.max(0,math.min(bottom+h,rect[4])-math.max(bottom,rect[2]))
      return ow*oh
    end
    local gap=12
    local candidates={{x-gap-w,y+gap},{x+gap,y+gap},{x-gap-w,y-gap-h},{x+gap,y-gap-h}}
    local bestX,bestY,bestScore
    for i,pos in ipairs(candidates) do
      local left=math.max(0,math.min(pos[1],math.max(0,screenW-w)))
      local bottom=math.max(0,math.min(pos[2],math.max(0,screenH-h)))
      local score=overlap(left,bottom,tip)*10+overlap(left,bottom,itemFrame)*10
      if x>=left and x<=left+w and y>=bottom and y<=bottom+h then score=score+1000000 end
      score=score+math.abs(left-pos[1])+math.abs(bottom-pos[2])+i*0.01
      if not bestScore or score<bestScore then bestX,bestY,bestScore=left,bottom,score end
    end
    panel:ClearAllPoints()
    panel:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',bestX,bestY)
  end
  panel:Show()
end
driver:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
driver:RegisterEvent('UNIT_SPELLCAST_FAILED')
driver:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
driver:RegisterEvent('BAG_UPDATE')
driver:RegisterEvent('PLAYER_REGEN_DISABLED')
driver:SetScript('OnEvent',function(_,event,unit,spellName)
  if (event=='UNIT_SPELLCAST_SUCCEEDED' or event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED') and unit=='player' and pendingPanelSpell then
    local matches=spellName==pendingPanelSpell
    pendingPanelSpell=nil
    if matches and event=='UNIT_SPELLCAST_SUCCEEDED' and panel:IsShown() and not InCombatLockdown() then panel:Hide() end
  end
  if event == 'PLAYER_REGEN_DISABLED' then clearPassiveTooltip() end
  if event == 'BAG_UPDATE' and not InCombatLockdown() then
    if confirm:IsShown() then confirm:Hide() end
    if panel:IsShown() then showPanel(nil,true,tradePanel) end
  end
end)
local options
local inspectTimer
local inspector=CreateFrame('Frame')
inspector:SetScript('OnUpdate',function(_,dt)
  if not inspectTimer then return end
  inspectTimer=inspectTimer-dt
  if inspectTimer>0 then return end
  inspectTimer=nil
  local f=GetMouseFocus()
  if f == overlay then f=tracked end
  local bag,slot=resolve(f)
  say('Focus: '..tostring(f and f:GetName() or '(unnamed)')..'; bag: '..tostring(bag)..'; slot: '..tostring(slot)..'.')
  if bag then
    say('Item: '..tostring(GetContainerItemLink(bag,slot) or 'none')..'; required: '..tostring(requirement(bag,slot) or 'not found')..'; locked tooltip: '..tostring(isLockedBagItem(bag,slot))..'.')
    local req=requirement(bag,slot); local kind=method(req)
    say('Detected method: '..tostring(kind or 'none')..'; Blacksmithing: '..tostring(skill('Blacksmithing') or 'unknown')..'; Engineering: '..tostring(skill('Engineering') or 'unknown')..'.')
  end
end)
SLASH_LOCKSMITH1='/locksmith'; SLASH_LOCKSMITH2='/su'; SLASH_LOCKSMITH3='/ls'
SlashCmdList.LOCKSMITH=function(msg)
  if msg == 'hide' then
    if not InCombatLockdown() then panel:Hide() else say('Close the panel outside combat.') end
  elseif msg == 'inspect' then
    inspectTimer=5; say('Move your cursor over the lockbox and keep it there for five seconds.')
  elseif msg == 'reset' then
    LocksmithDB=LocksmithDB or {}; LocksmithDB.windowX=nil; LocksmithDB.windowY=nil
    say('Window position reset. It will open near the cursor next time.')
  elseif msg == 'config' then
    InterfaceOptionsFrame_OpenToCategory(options)
    InterfaceOptionsFrame_OpenToCategory(options)
  elseif msg == 'status' then
    say('Lockpicking: '..tostring(skill('Lockpicking') or 'unknown')..'; Blacksmithing: '..tostring(skill('Blacksmithing') or 'unknown')..'; Engineering: '..tostring(skill('Engineering') or 'unknown')..'.')
  else showPanel() end
end

-- A recently clicked world object can report the error after focus moves.
local lastWorldClick
WorldFrame:HookScript('OnMouseUp',function(_,button)
  if button=='RightButton' then lastWorldClick=GetTime() end
end)
local lockEvents = CreateFrame('Frame')
lockEvents:RegisterEvent('UI_ERROR_MESSAGE')
lockEvents:RegisterEvent('UI_INFO_MESSAGE')
lockEvents:SetScript('OnEvent',function(self,event,...)
  if InCombatLockdown() or panel:IsShown() then return end
  if tradingWindowOpen() then return end
  local msg
  for i=1,select('#',...) do
    local value=select(i,...)
    if type(value)=='string' then msg=value; break end
  end
  if not msg then return end
  local focus=GetMouseFocus()
  local isWorldFocus=focus==WorldFrame
  local f=focus
  while f and not isWorldFocus and f.GetParent do
    f=f:GetParent()
    if f==WorldFrame then isWorldFocus=true end
  end
  local recentWorldClick=lastWorldClick and GetTime()-lastWorldClick<0.75 and not resolve(focus)
    and not (TradeFrame and TradeFrame:IsShown())
  if isWorldFocus or recentWorldClick then
    if LocksmithDB and LocksmithDB.worldDetection == false then return end
    local lowerMessage=string.lower(msg)
    local localizedLocked=type(LOCKED)=='string' and string.lower(LOCKED)
    if (ERR_USE_LOCKED and msg == ERR_USE_LOCKED) or (ERR_ITEM_LOCKED and msg == ERR_ITEM_LOCKED)
        or (ERR_DOOR_LOCKED and msg == ERR_DOOR_LOCKED)
        or lowerMessage:find('locked',1,true)
        or (localizedLocked and localizedLocked~='' and lowerMessage:find(localizedLocked,1,true)) then
      lastWorldClick=nil
      showPanel()
    end
    return
  end
end)


-- Only the recipient's service slot can be targeted for an unlock in a trade.
local tradeWatcher=CreateFrame('Frame')
local tradeHooked=false
tradeWatcher:RegisterEvent('TRADE_SHOW')
tradeWatcher:RegisterEvent('TRADE_CLOSED')
tradeWatcher:SetScript('OnEvent',function(_,event)
  if event=='TRADE_CLOSED' then
    if tradePanel and panel:IsShown() and not InCombatLockdown() then panel:Hide() end
    return
  end
  local button=_G.TradeRecipientItem7ItemButton
  if tradeHooked or not button then return end
  tradeHooked=true
  button:HookScript('OnMouseUp',function(_,mouseButton)
    if mouseButton~='RightButton' or InCombatLockdown() or SpellIsTargeting()
        or panel:IsShown() or tradingWindowOpen() then return end
    if not knowsPick() then return end
    if not TradeFrame or not TradeFrame:IsShown() or not GetTradeTargetItemLink(7) then return end
    scan:SetOwner(UIParent,'ANCHOR_NONE'); scan:ClearLines(); scan:SetTradeTargetItem(7)
    local locked=false
    for i=1,scan:NumLines() do
      local line=_G['LocksmithScanTooltipTextLeft'..i]
      local text=line and line:GetText()
      if text and (text==(LOCKED or 'Locked') or
          (skillNames.Lockpicking and text:find(skillNames.Lockpicking,1,true) and text:match('%(%d+%)'))) then
        locked=true; break
      end
    end
    scan:Hide()
    if locked then showPanel(nil,false,true) end
  end)
end)

local minimapButton = CreateFrame('Button','LocksmithMinimapButton',Minimap)
minimapButton:SetWidth(31); minimapButton:SetHeight(31)
minimapButton:SetFrameStrata('MEDIUM'); minimapButton:SetFrameLevel(Minimap:GetFrameLevel()+8)
minimapButton:RegisterForClicks('LeftButtonUp','RightButtonUp')
minimapButton:RegisterForDrag('LeftButton')
minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
local icon=minimapButton:CreateTexture(nil,'BACKGROUND')
icon:SetTexture('Interface\\Icons\\INV_Misc_Key_03')
icon:SetPoint('CENTER',0,0); icon:SetWidth(20); icon:SetHeight(20)
icon:SetTexCoord(0.07,0.93,0.07,0.93)
local ring=minimapButton:CreateTexture(nil,'OVERLAY')
ring:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
ring:SetWidth(53); ring:SetHeight(53); ring:SetPoint('TOPLEFT')
local dragging=false
local function positionMinimap()
  local angle=math.rad((LocksmithDB and LocksmithDB.minimapAngle) or 225)
  minimapButton:ClearAllPoints()
  minimapButton:SetPoint('CENTER',Minimap,'CENTER',math.cos(angle)*80,math.sin(angle)*80)
end
minimapButton:SetScript('OnDragStart',function(self) dragging=true end)
minimapButton:SetScript('OnDragStop',function(self) dragging=false end)
minimapButton:SetScript('OnUpdate',function(self)
  if not dragging then return end
  local x,y=GetCursorPosition()
  local scale=Minimap:GetEffectiveScale()
  local cx,cy=Minimap:GetCenter()
  if not cx or not cy then return end
  LocksmithDB=LocksmithDB or {}
  LocksmithDB.minimapAngle=math.deg(math.atan2(y/scale-cy,x/scale-cx))
  positionMinimap()
end)
minimapButton:SetScript('OnClick',function(_,button)
  if button=='RightButton' then
    InterfaceOptionsFrame_OpenToCategory(options)
    InterfaceOptionsFrame_OpenToCategory(options)
    return
  end
  if InCombatLockdown() then say('Open or close the unlock panel outside combat.'); return end
  if panel:IsShown() then panel:Hide() else showPanel() end
end)
minimapButton:SetScript('OnEnter',function(self)
  GameTooltip:SetOwner(self,'ANCHOR_LEFT')
  GameTooltip:SetText('Locksmith')
  GameTooltip:AddLine(T[11],1,1,1)
  GameTooltip:AddLine(T[12],1,1,1)
  GameTooltip:AddLine(T[13],1,1,1)
  GameTooltip:Show()
end)
minimapButton:SetScript('OnLeave',function() GameTooltip:Hide() end)
positionMinimap()

-- Blizzard Interface > AddOns settings (3.3.5a).
options = CreateFrame('Frame','LocksmithOptionsPanel',InterfaceOptionsFramePanelContainer)
options.name = 'Locksmith'
local heading = options:CreateFontString(nil,'ARTWORK','GameFontNormalLarge')
heading:SetPoint('TOPLEFT',16,-16); heading:SetText('Locksmith')
local label = options:CreateFontString(nil,'ARTWORK','GameFontHighlight')
label:SetPoint('TOPLEFT',heading,'BOTTOMLEFT',0,-25); label:SetText('Lockbox shortcut modifier')
local dropdown = CreateFrame('Frame','LocksmithModifierDropdown',options,'UIDropDownMenuTemplate')
dropdown:SetPoint('TOPLEFT',label,'BOTTOMLEFT',-16,-5)
UIDropDownMenu_SetWidth(dropdown,140)
local names = {alt='Alt', shift='Shift', ctrl='Ctrl'}
local function refreshOptions()
  local value = (LocksmithDB and LocksmithDB.modifier) or 'alt'
  UIDropDownMenu_SetSelectedValue(dropdown,value)
  UIDropDownMenu_SetText(dropdown,names[value])
end
UIDropDownMenu_Initialize(dropdown,function(self,level)
  for _,value in ipairs({'alt','shift','ctrl'}) do
    local v=value
    local info=UIDropDownMenu_CreateInfo()
    info.text=names[v]; info.value=v
    info.checked = LocksmithDB and LocksmithDB.modifier == v
    info.func=function()
      LocksmithDB = LocksmithDB or {}
      LocksmithDB.modifier=v
      refreshOptions()
      if not InCombatLockdown() then overlay:Hide(); tracked=nil end
    end
    UIDropDownMenu_AddButton(info,level)
  end
end)
local note = options:CreateFontString(nil,'ARTWORK','GameFontHighlightSmall')
note:SetPoint('TOPLEFT',dropdown,'BOTTOMLEFT',16,-8)
note:SetWidth(420); note:SetJustifyH('LEFT')
note:SetText('Hold the selected modifier and right-click a supported locked item. Disabled at the Auction House and during combat.')
local checks={}
local function addCheck(key,text,y)
  local b=CreateFrame('CheckButton','LocksmithOption'..key,options,'InterfaceOptionsCheckButtonTemplate')
  b:SetPoint('TOPLEFT',dropdown,'BOTTOMLEFT',12,y)
  _G[b:GetName()..'Text']:SetText(text)
  b:SetScript('OnClick',function(self)
    LocksmithDB=LocksmithDB or {}; LocksmithDB[key]=self:GetChecked() and true or false
    if key == 'bagDetection' and not InCombatLockdown() then overlay:Hide(); tracked=nil end
    if key == 'minimapVisible' then
      if LocksmithDB.minimapVisible then minimapButton:Show() else minimapButton:Hide() end
    end
  end)
  checks[key]=b
end
note:SetText('Hold the selected modifier and left-click or right-click a supported lockbox in your carried bags.')
addCheck('bagDetection','Enable bag lockbox detection and shortcut',-45)
addCheck('worldDetection','Automatically show the world unlock window',-72)
addCheck('minimapVisible','Show minimap button',-99)
options:SetScript('OnShow',function()
  refreshOptions()
  for key,button in pairs(checks) do button:SetChecked(not LocksmithDB or LocksmithDB[key] ~= false) end
end)
InterfaceOptions_AddCategory(options)
driver:RegisterEvent('ADDON_LOADED')
local previousEvent = driver:GetScript('OnEvent')
driver:SetScript('OnEvent',function(self,event,...)
  if event == 'ADDON_LOADED' and ... == 'Locksmith' then
    if type(LocksmithDB) ~= 'table' then LocksmithDB = {} end
    if not names[LocksmithDB.modifier] then LocksmithDB.modifier = 'alt' end
    refreshOptions()
    if type(LocksmithDB.windowX)=='number' and type(LocksmithDB.windowY)=='number' then
      panel:ClearAllPoints(); panel:SetPoint('CENTER',UIParent,'CENTER',LocksmithDB.windowX,LocksmithDB.windowY)
    end
    positionMinimap()
    if LocksmithDB.minimapVisible == false then minimapButton:Hide() else minimapButton:Show() end
    self:UnregisterEvent('ADDON_LOADED')
  elseif previousEvent then previousEvent(self,event,...) end
end)

-- Activation occurs after ADDON_LOADED, so initialize saved settings explicitly.
driver:GetScript('OnEvent')(driver,'ADDON_LOADED','Locksmith')
end
local function tryActivate()
  if not loggedIn or started or InCombatLockdown() or not eligible() then return end
  started=true
  boot:UnregisterAllEvents()
  activate()
end
boot:RegisterEvent('PLAYER_LOGIN')
boot:RegisterEvent('SPELLS_CHANGED')
boot:RegisterEvent('SKILL_LINES_CHANGED')
boot:RegisterEvent('PLAYER_REGEN_ENABLED')
boot:SetScript('OnEvent',function(_,event)
  if event == 'PLAYER_LOGIN' then loggedIn=true end
  tryActivate()
end)
