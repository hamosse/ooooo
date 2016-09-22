local chanlist = "data/channels.json"
local filename= "data/autosend.lua"
local cronned = load_from_file(filename)
local function on_getting_dialogs(cb_extra, success, result)
  -- body
end

get_dialog_list(on_getting_dialogs, false)

local function on_resolve_username(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local channel = cb_extra.channel
  local get_cmd = cb_extra.get_cmd
  if success == 1 then
    if get_cmd == "join" then
      channel_join("@"..channel, ok_cb, false)
      send_large_msg(receiver, "Trying to join channel @"..channel)
    end
    if get_cmd == "leave" then
      channel_leave("@"..channel, ok_cb, false)
      send_large_msg(receiver, "Trying to leave from channel @"..channel)
    end
  else
    send_large_msg(receiver, "Invalid channel username")
  end
end

local function on_channel_get_admins(cb_extra, success, result)
  --vardump(result)
  if success ~= 1 then
    return false
  end

  for k,v in pairs(result) do
    if v.peer_id == our_id then
      return admined
    end
  end
  return false
end

local function save_cron(msg, text, list_number, date)
  --local origin = get_receiver(msg)
  if not cronned[date] then
    cronned[date] = {}
  end
  local arr = { list_number,  text } ;
  table.insert(cronned[date], arr)
  serialize_to_file(cronned, filename)
  return 'Saved!'
end

local function delete_cron(date)
  for k,v in pairs(cronned) do
    if k == date then
	  cronned[k]=nil
    end
  end
  serialize_to_file(cronned, filename)
end

local function cron()
  for date, values in pairs(cronned) do
    if date < os.time() then --time's up
      local data = load_data(chanlist)
      local hash =  'lastlist:'
      redis:set(hash, values[1][1])
  	  for k,v in pairs(data[values[1][1]]) do
  	    post_msg(v, values[1][2], ok_cb, false)
  	  end
	  	--send_msg(values[1][1], "Time's up:\n"..values[1][2], ok_cb, false)
  		delete_cron(date) --TODO: Maybe check for something else? Like user
  	end
  end
end

local function actually_run(msg, delay, list_number, text)
  if (not delay or not text or not list_number) then
  	return "Usage: /autopost [delay: 2h3m1s] [list number] text"
  end
  save_cron(msg, text, list_number, delay)
  return "📑✔️ سيتم ارسال اللسته 📑✔️ رقم 📌"
end

local function to_delete(list_number, channel_id, msg_id)
  local hash =  'todelete:'..list_number..':'..channel_id
  redis:set(hash, msg_id)
end

local function pre_process(msg)
  --vardump(msg)
  if msg.from.flags == 196609 and msg.out == false then -- check if there any new post from channels
    local admin_group_id = redis:get("chanadminID:")
    if not admin_group_id then
      return nil
    end
    print(admin_group_id)
    local hash =  'channel:notification'
    local notified = redis:get(hash)
    if notified then
      print('notify')
      fwd_msg("chat#id"..admin_group_id, msg.id, ok_cb, false)
    end
    return msg
  end
  if msg.from.flags == 196609 and msg.out == true then -- check if bot send any post in channel
    local hash =  'lastlist:'
    local list_number = redis:get(hash)
    to_delete(list_number, msg.to.id, msg.id)
    return nil
  end
  return msg
end

function run (msg, matches)
  if matches[1] == "setgroup" then
    if msg.to.type == "chat" then
      local hash = "chanadminID:"
      redis:set(hash, msg.to.id)
      return "Done!"
    elseif msg.to.type == "channel" then
      return "Only works in regular group."
    end
  end
  local admin_group_id = redis:get("chanadminID:")
  if not admin_group_id then
    return nil
  end
  if msg.to.id ~= tonumber(admin_group_id) then
    return nil
  end
  if not is_admin(msg) then
    return nil
  end
  local receiver = get_receiver(msg)
  local data = load_data(chanlist)
  if matches[1] == "add" then
    local chan_name = matches[2]
    local list_number = matches[3]
    if not data[list_number] then
      data[list_number]={
        [chan_name] = chan_name
        }
      save_data(chanlist, data)
      return send_large_msg(receiver, "☑️تم اضافه القناة للسته 📋☑️")
    end
    if data[list_number][chan_name] then
      return "Channel "..chan_name.." is already in the list."
    end
    data[list_number][chan_name] = chan_name
    save_data(chanlist, data)
    return send_large_msg(receiver, "☑️تم اضافه القناة للسته 📋☑️")
  end
  if matches[1] == "delete" then
    local chan_name = matches[2]
    local list_number = matches[3]
    if not data[list_number] then
      return "☑️تم حذف القناة من السته 📋☑️"
    end
    if data[list_number][chan_name] then
      data[list_number][chan_name] = nil
      save_data(chanlist, data)
      return "Channel "..chan_name.." has been deleted from list : "..list_number
    end
    return send_large_msg(receiver, "Channel "..chan_name.." isn't in list : "..list_number)
  end
  if matches[1] == "listall" then
    local chantext = ""
    for k,v in pairs(data) do
      chantext = chantext.." اللسته 📋 رقم 📌 "..k.." :\n"
      cn = 1
      for sk, sv in pairs(v) do
        chantext = chantext..cn..". "..sv.."\n"
        cn = cn+1
      end
      chantext = chantext.."\n"
    end
    return chantext
  end
  if matches[1] == "send list" then
    local list_number = matches[2]
    if not data[list_number] then
      return "List isn't available."
    end
    local hash =  'lastlist:'
    redis:set(hash, list_number)
    for k,v in pairs(data[list_number]) do
      post_msg(v, matches[3], ok_cb, false)
    end
    return "📌📨 لقد قمت برسال اللسته في جميع قنوات الموجوده في اللسته المختاره 📨📌 "..list_number
  end
  if matches[1] == "delsend list" then
    local list_number = matches[2]
    if not data[list_number] then
      return "List isn't available."
    end
    local hash =  'todelete:'..list_number..':*'
    local chatlist = redis:keys(hash)
    if next(chatlist) == nil then
      print('no list')
      return "Nothing to delete"
    else
      for k,v in pairs (chatlist) do
        local msg_id = redis:get(v)
        delete_msg(msg_id, ok_cb, false)
        redis:del(v)
      end
    end
    return "Done deleting last channel post in list "..list_number
  end
  if matches[1] == "post" then
    chanadmin = ""
    for k,v in pairs(data) do
      for sk, sv in pairs(v) do
        post_msg(sv, matches[2], ok_cb, false)
      end
    end
    return "📤تم ارسال الرسالة لجميع القنوات.📤✔️"
  end
  if matches[1] == "srun" then
    local hash =  'channel:notification'
    redis:set(hash, true)
    return "☑️تم تفعيل الاشعارات 📢☑️"
  end
  if matches[1] == "crun" then
    local hash =  'channel:notification'
    redis:del(hash)
    return "☑️تم تعطيل الاشعارات 🔕☑️"
  end
  -- if matches[1] == "reload" then
  --   chanadmin = "Channel i manage:\n"
  --   for k,v in pairs(data) do
  --     for sk, sv in pairs(v) do
  --       local admined = channel_get_admins(sv, on_channel_get_admins, {receiver=receiver, chan_name = sv})
  --       print(sv, admined)
  --       -- if string.find(tostring(admined), "true") then
  --       --   admined = "✔"
  --       -- else
  --       --   admined = "❌"
  --       -- end
  --       chanadmin = chanadmin..sv.." "..tostring(admined).."\n"
  --     end
  --   end
  --   return chanadmin
  -- end
  if matches[1] == "autosend" then
    local sum = 0
    for i = 2, #matches-2 do
      print(#matches-2)
      local b,_ = string.gsub(matches[i],"[a-zA-Z]","")
      if string.find(matches[i], "s") then
        sum=sum+b
      end
      if string.find(matches[i], "m") then
        sum=sum+b*60
      end
      if string.find(matches[i], "h") then
        sum=sum+b*3600
      end
    end
    local date=sum+os.time()
    local list_number = matches[#matches-1]
    local text = matches[#matches]
    local text = actually_run(msg, date, list_number, text)
    return text
  end
  if matches[1] == "join" then
    local channel = string.gsub(matches[2], "@", "")
    resolve_username(channel, on_resolve_username, {receiver=get_receiver(msg), channel=channel, get_cmd=matches[1]})
  end
  if matches[1] == "leave" then
    local channel = string.gsub(matches[2], "@", "")
    resolve_username(channel, on_resolve_username, {receiver=get_receiver(msg), channel=channel, get_cmd=matches[1]})
  end
end

return {
  description = "", 
  usage = {
      user = {
          "-",
          },
      moderator = {
          "-",

          },
      },
  patterns = {
    "^/(add) (.+) (%d)$",
    "^/(delete) (.+) (%d)$",
    "^/(listall)$",
    "^/(send list) (%d) (.+)$",
    "^/(delsend list) (%d)$",
    "^/(post) (.+)$",
    "^/(srun)$",
    "^/(crun)$",
    --"^/(reload)$",
    "^/(autosend) ([0-9]+[hmsdHMSD]) (%d) (.+)$",
    "^/(autosend) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (%d) (.+)$",
    "^/(autosend) ([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD])([0-9]+[hmsdHMSD]) (%d) (.+)$",
    "^/(join) (.+)$",
    "^/(leave) (.+)$",
    "^/(setgroup)$",
  }, 
  run = run,
  pre_process = pre_process,
  cron = cron
}