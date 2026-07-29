local buyerID = tostring(getDiscordID())

local buyerList = {
  ["636196321232945152"] = "Author",
  ["1517903098587123902"] = "@Poull12"
}

function cekMember(playerID)
  if buyerList[playerID] then
    return true, buyerList[playerID] -- return true + nama
  else
    return false, nil
  end
end

if not cekMember(buyerID) then
  sendNotification("Skrip ini hanya untuk @Poull12")
  return false
end  

sendNotification("Req001 added")

addCategory("HsnGL", "FileOpen")

local Hsnreq001 = [[
{
  "sub_name": "Request001",
  "description": "Request by @Poull12",
  "icon": "Verified",
  "menu": [
      {
          "type": "label",
          "text": "WL: N/A",
          "alias": "hsnreq001_wl"
      },
      {
          "type": "label",
          "text": "DL: N/A",
          "alias": "hsnreq001_dl"
      },
      {
          "type": "label",
          "text": "BGL: N/A",
          "alias": "hsnreq001_bgl"
      },
      {
          "type": "label",
          "text": "Total: N/A",
          "alias": "hsnreq001_total"
      },
      {
          "type": "tooltip",
          "icon": "TipsAndUpdates",
          "text": "Cara Cek Gems",
          "support_text": "Pasang Hospital Wall ke Gems yang akan di cek!"
      },
      {
          "type": "divider"
      },
      {
          "type": "toggle_button",
          "text": "Cek Gems",
          "alias": "hsnreq001_cekGems",
          "default": false
      },
      {
          "type": "divider"
      },
      {
          "type": "button",
          "text": "WL to BGL",
          "alias": "hsnreq001_cv"
      },
      {
          "type": "divider"
      }
  ]
}]]
addIntoModule(Hsnreq001, "HsnGL")
      
function cek(id)
   return growtopia.checkInventoryCount(id)
end

local cekGems = false

runThread(function()
while true do
   local wl, dl, bgl = cek(242), cek(1796), cek(7188)
   local total = wl + (dl * 100) + (bgl * 10000)
   
   editValue("hsnreq001_wl", "WL: "..wl)
   editValue("hsnreq001_dl", "DL: "..dl)
   editValue("hsnreq001_bgl", "BGL: "..bgl)
   editValue("hsnreq001_total", "Total: "..total)
   Sleep(1000)
end
end)

function floatbubble(x, y, text)
    local netids = math.random(50000, 100000)

    sendVariant({
        v1 = "OnSpawn",
        v2 = "spawn|avatar\nnetID|"..netids.."\nuserID|-1\ncolrect|0|0|20|30\nposXY|"..((x+0.2)*32).."|"..((y+0.5)*32).."\nname|server\ninvis|1\nmstate|1\nsmstate|2"
    })

    sendVariant({
        v1 = "OnTalkBubble",
        v2 = netids,
        v3 = text,
        v4 = 1
    }, -1)

    sendVariant({
        v1 = "OnRemove",
        v2 = "netID|"..netids,
        v3 = "pId|-1"
    })
end

function float(x, y, id)
   local count = 0
   
   for _, obj in pairs(GetObjectList()) do
      if obj.itemid == id then
         local obx = math.floor(obj.posX/32)
         local oby = math.floor(obj.posY/32)
         
         if obx == x and oby == y then
            count = count + obj.amount
         end  
      end
   end 
   return count     
end

addHook(function(type, name, value)
   if name == "hsnreq001_cv" then
      local wl, dl, bgl = cek(242), cek(1796), cek(7188)
      local total = wl + (dl * 100) + (bgl * 10000)
      if total > 10000 then
         bank(10000, 1)
         Sleep(100)
         bank(10000, -1)
         growtopia.notify("Converted  to BGL")
      else
         growtopia.notify("Gak cukup!")
      end   
   elseif name == "hsnreq001_cekGems" then
      cekGems = value
   end   
end, "OnValue")

addHook(function(packet)
if packet.type == 3 and packet.value == 1290 and cekGems then
   local pkx, pky = packet.px, packet.py
   
   runThread(function()
      floatbubble(pkx, pky, "Gems: "..float(pkx, pky, 112))
   end)
   return true
end
end, "OnSendPacketRaw")
