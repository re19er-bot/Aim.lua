local Obfuscator = {}

function Obfuscator:ObfuscateCode(code)
    local obfuscated = code
    
    -- 1. Remove comentários (mais seguro)
    obfuscated = self:RemoveComments(obfuscated)
    
    -- 2. Ofusca strings com XOR (mais forte)
    obfuscated = obfuscated:gsub('"([^"]*)"', function(str)
        return '"' .. self:EncodeStringXOR(str) .. '"'
    end)
    
    -- 3. Ofusca nomes de variáveis e funções
    obfuscated = self:ObfuscateVariables(obfuscated)
    
    -- 4. Injeta código dummy (confunde análise)
    obfuscated = self:InjectDummyCode(obfuscated)
    
    -- 5. Minifica
    obfuscated = self:MinifyCode(obfuscated)
    
    return obfuscated
end

-- Remove comentários com segurança
function Obfuscator:RemoveComments(code)
    local result = ""
    local inString = false
    local stringChar = nil
    local i = 1
    
    while i <= #code do
        local char = code:sub(i, i)
        local nextChar = code:sub(i + 1, i + 1)
        
        -- Detecta strings
        if (char == '"' or char == "'") and (i == 1 or code:sub(i-1, i-1) ~= "\\") then
            inString = not inString
            stringChar = char
            result = result .. char
        elseif not inString and char == "-" and nextChar == "-" then
            -- Pula comentário até o fim da linha
            while i <= #code and code:sub(i, i) ~= "\n" do
                i = i + 1
            end
            if i <= #code then
                result = result .. "\n"
            end
        else
            result = result .. char
        end
        
        i = i + 1
    end
    
    return result
end

-- XOR Encoding (muito mais forte que +5)
function Obfuscator:EncodeStringXOR(str)
    local encoded = ""
    local key = 0xAB -- Chave fixa (pode ser aleatória também)
    
    for i = 1, #str do
        local byte = string.byte(str, i)
        encoded = encoded .. string.char(bit.bxor(byte, key))
    end
    
    return encoded
end

-- Ofusca nomes de variáveis
function Obfuscator:ObfuscateVariables(code)
    -- Cria mapa de variáveis
    local varMap = {}
    local counter = 0
    
    -- Encontra todas as variáveis locais
    for varName in code:gmatch("local%s+([%w_]+)") do
        if not varMap[varName] then
            varMap[varName] = self:RandomName()
            counter = counter + 1
        end
    end
    
    -- Substitui variáveis
    for old, new in pairs(varMap) do
        code = code:gsub("%f[%w_]" .. old .. "%f[%W_]", new)
    end
    
    return code
end

-- Injeta código dummy para confundir análise
function Obfuscator:InjectDummyCode(code)
    local dummySnippets = {
        "local _dummy_" .. math.random(1, 10000) .. " = math.random(1, 100)",
        "local _x_" .. math.random(1, 10000) .. " = {1, 2, 3, 4, 5}",
        "if " .. math.random(1, 100) .. " > " .. math.random(101, 200) .. " then return end",
    }
    
    -- Injeta alguns snippets aleatoriamente
    for i = 1, math.random(1, 3) do
        local randomPos = math.random(1, #code)
        code = code:sub(1, randomPos) .. "\n" .. dummySnippets[math.random(1, #dummySnippets)] .. "\n" .. code:sub(randomPos + 1)
    end
    
    return code
end

-- Nome aleatório CORRIGIDO
function Obfuscator:RandomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    local name = ""
    
    for i = 1, math.random(8, 16) do
        -- FIX: Pega um caractere por vez, não um range
        name = name .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    
    return name
end

-- Minify
function Obfuscator:MinifyCode(code)
    code = code:gsub('%s+', ' ')
    code = code:gsub(',%s+', ',')
    code = code:gsub('=%s+', '=')
    code = code:gsub('%(%s+', '(')
    code = code:gsub('%s+%)', ')')
    code = code:gsub('\n', '')
    return code
end

return Obfuscator
