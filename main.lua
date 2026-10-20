-- ============================================================
--  SERVER HOP - UI cinza simples + funções do Safyra Hopper
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ============================================================
--  HTTP
-- ============================================================
local function httpGet(url)
    if game and game.HttpGet then
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and result and #result > 0 then return true, result end
    end
    local ok2, result2 = pcall(function() return HttpService:GetAsync(url, true) end)
    if ok2 and result2 and #result2 > 0 then return true, result2 end
    return false, "HTTP falhou."
end

-- ============================================================
--  UI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerHopPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 220)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = ScreenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hop"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Botão FILTRO (substitui a antiga caixa de texto)
local btnFiltro = Instance.new("TextButton")
btnFiltro.Size = UDim2.new(1, -20, 0, 24)
btnFiltro.Position = UDim2.new(0, 10, 0, 31)
btnFiltro.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
btnFiltro.BorderSizePixel = 0
btnFiltro.Text = "Filtro: TODOS"
btnFiltro.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFiltro.Font = Enum.Font.SourceSans
btnFiltro.TextSize = 13
btnFiltro.Parent = mainFrame
Instance.new("UICorner", btnFiltro).CornerRadius = UDim.new(0, 6)

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, 58)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Pronto."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Botão ENTRAR NO MELHOR
local btnEnter = Instance.new("TextButton")
btnEnter.Size = UDim2.new(1, -20, 0, 26)
btnEnter.Position = UDim2.new(0, 10, 0, 78)
btnEnter.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
btnEnter.BorderSizePixel = 0
btnEnter.Text = "Entrar no Melhor"
btnEnter.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEnter.Font = Enum.Font.SourceSansBold
btnEnter.TextSize = 13
btnEnter.Parent = mainFrame
Instance.new("UICorner", btnEnter).CornerRadius = UDim.new(0, 6)

-- Botão VER LISTA
local btnLista = Instance.new("TextButton")
btnLista.Size = UDim2.new(1, -20, 0, 26)
btnLista.Position = UDim2.new(0, 10, 0, 108)
btnLista.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
btnLista.BorderSizePixel = 0
btnLista.Text = "Ver Lista de Servidores"
btnLista.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLista.Font = Enum.Font.SourceSans
btnLista.TextSize = 12
btnLista.Parent = mainFrame
Instance.new("UICorner", btnLista).CornerRadius = UDim.new(0, 6)

-- Scroll da lista
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 68)
scrollFrame.Position = UDim2.new(0, 10, 0, 140)
scrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- ============================================================
--  ESTADO
-- ============================================================
local currentServers = {}
local listItems = {}

local filtroOpts = {
    { label = "TODOS",       max = 999 },
    { label = "0-1 PLAYER",  max = 1 },
    { label = "0-3 PLAYERS", max = 3 },
    { label = "0-5 PLAYERS", max = 5 },
    { label = "0-10 PLAYERS",max = 10 },
}
local filtroIdx = 1

-- ============================================================
--  HELPERS
-- ============================================================
local function clearList()
    for _, item in ipairs(listItems) do item:Destroy() end
    listItems = {}
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function addMsg(msg, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = scrollFrame
    table.insert(listItems, lbl)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #listItems * 25)
end

local function setStatus(txt, color)
    statusLabel.Text = txt
    statusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 180)
end

-- ============================================================
--  FETCH
-- ============================================================
local function fetchServers()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, raw = httpGet(url)
    if not ok or not raw or raw == "" then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data then return nil end
    local currentId = tostring(game.JobId)
    local lista = {}
    for _, s in ipairs(data.data) do
        if s.id and tostring(s.id) ~= currentId and s.playing < s.maxPlayers then
            table.insert(lista, {
                id = tostring(s.id),
                playing = s.playing or 0,
                maxPlayers = s.maxPlayers or 0,
                ping = s.ping or 0,
            })
        end
    end
    table.sort(lista, function(a, b) return a.playing < b.playing end)
    return lista
end

local function verificarVaga(serverId)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, raw = httpGet(url)
    if not ok or not raw then return false, nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data then return false, nil end
    for _, s in ipairs(data.data) do
        if tostring(s.id) == tostring(serverId) then
            return (s.playing or 0) < (s.maxPlayers or 0), {
                id = tostring(s.id), playing = s.playing or 0, maxPlayers = s.maxPlayers or 0
            }
        end
    end
    return false, nil
end

local function tentarTeleport(lista, maxTentativas)
    maxTentativas = maxTentativas or 5
    local t = 0
    for _, s in ipairs(lista) do
        if t >= maxTentativas then break end
        t = t + 1
        local temVaga, dados = verificarVaga(s.id)
        if temVaga and dados then
            setStatus("Tentando " .. t .. ": " .. dados.playing .. "/" .. dados.maxPlayers, Color3.fromRGB(120, 180, 255))
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, dados.id, LocalPlayer)
            end)
            if ok then return true, dados end
            task.wait(0.6)
        end
    end
    return false, nil
end

local function aplicarFiltro(lista)
    local opt = filtroOpts[filtroIdx]
    local out = {}
    for _, s in ipairs(lista) do
        if s.playing <= opt.max then table.insert(out, s) end
    end
    return out
end

-- ============================================================
--  RENDER
-- ============================================================
local function renderServers(lista)
    clearList()
    if not lista or #lista == 0 then
        addMsg("Nenhum servidor com vaga.", Color3.fromRGB(230, 150, 150))
        return
    end
    for i, s in ipairs(lista) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 22)
        row.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        row.BorderSizePixel = 0
        row.Parent = scrollFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -50, 1, 0)
        info.Position = UDim2.new(0, 6, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = string.format("%d/%d jogadores", s.playing, s.maxPlayers)
        info.TextColor3 = Color3.fromRGB(230, 230, 230)
        info.Font = Enum.Font.SourceSans
        info.TextSize = 11
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Parent = row

        local joinBtn = Instance.new("TextButton")
        joinBtn.Size = UDim2.new(0, 44, 0, 18)
        joinBtn.Position = UDim2.new(1, -48, 0.5, -9)
        joinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        joinBtn.BorderSizePixel = 0
        joinBtn.Text = "JOIN"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.TextSize = 10
        joinBtn.Parent = row
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)

        joinBtn.MouseButton1Click:Connect(function()
            joinBtn.Text = "..."
            local temVaga, dados = verificarVaga(s.id)
            if not temVaga then
                joinBtn.Text = "CHEIO"
                setStatus("Server cheio.", Color3.fromRGB(255, 100, 100))
                task.wait(1.5)
                joinBtn.Text = "JOIN"
                return
            end
            setStatus("Entrando...", Color3.fromRGB(120, 180, 255))
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, dados.id, LocalPlayer)
            end)
            if not ok then
                joinBtn.Text = "ERRO"
                task.wait(1.5)
                joinBtn.Text = "JOIN"
            end
        end)

        table.insert(listItems, row)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #lista * 25)
end

-- ============================================================
--  EVENTOS
-- ============================================================
btnFiltro.MouseButton1Click:Connect(function()
    filtroIdx = filtroIdx + 1
    if filtroIdx > #filtroOpts then filtroIdx = 1 end
    btnFiltro.Text = "Filtro: " .. filtroOpts[filtroIdx].label
    if #currentServers > 0 then renderServers(aplicarFiltro(currentServers)) end
end)

btnEnter.MouseButton1Click:Connect(function()
    btnEnter.Text = "Procurando..."
    setStatus("Buscando o mais vazio...", Color3.fromRGB(255, 200, 50))
    task.wait(0.1)
    local lista = fetchServers()
    if not lista or #lista == 0 then
        setStatus("Nenhum server com vaga.", Color3.fromRGB(255, 100, 100))
        btnEnter.Text = "Entrar no Melhor"
        return
    end
    local filtrada = aplicarFiltro(lista)
    if #filtrada == 0 then filtrada = lista end
    setStatus("Teleportando (top 5)...", Color3.fromRGB(120, 180, 255))
    local sucesso, dados = tentarTeleport(filtrada, 5)
    if sucesso then
        setStatus("Entrando em " .. dados.playing .. "/" .. dados.maxPlayers, Color3.fromRGB(100, 255, 150))
    else
        setStatus("Falha em todos os 5.", Color3.fromRGB(255, 100, 100))
    end
    btnEnter.Text = "Entrar no Melhor"
end)

btnLista.MouseButton1Click:Connect(function()
    btnLista.Text = "Buscando..."
    setStatus("Buscando servidores...", Color3.fromRGB(255, 200, 50))
    task.wait(0.1)
    local lista = fetchServers()
    if not lista or #lista == 0 then
        setStatus("Nenhum server com vaga.", Color3.fromRGB(255, 100, 100))
        btnLista.Text = "Ver Lista de Servidores"
        return
    end
    currentServers = lista
    local filtrada = aplicarFiltro(lista)
    setStatus(#filtrada .. " servers. Clica JOIN.", Color3.fromRGB(100, 255, 150))
    btnLista.Text = "Ver Lista de Servidores"
    renderServers(filtrada)
end)

print("[ServerHop] Carregado. PlaceId:", PlaceId)
