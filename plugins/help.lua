local function run(msg, matches)
  if is_chat_msg(msg) then
    local text = [[🔖💡بوت ادارة اللستات💡🔖
                   ~~~~~~~~~~
/help : للمساعده في استخدام البوت 🔧⚙
~~~~~~
/add @channelname 1 : لاضافه قناه الى اللسته الاولى ويمكن تغير رقم لسته حسب الرغبه لاضافه  🗳 القناه الى لسته معينه 
~~~~~~~
/delete @channelname 1 : لحذف قناه معينه من السته الاولى ويمكن تغير رقم لسته 📇
~~~~~~
/send list : مثال </send list 1 رسالة اللسته > 
لارسال اعلان لسته في لسته الاولى
📋
~~~~~~
/listall : اظهار جميع القنوات في جميع اللستات 🗂
~~~~~~
/run : تشغيل الاشعارات في مجموعة الادارة 🖌
~~~~~~
/crun : ايقاف الاشعارات في مجموعة.الادارة 
~~~~~~
/mod @username : اضافه مشرف للتحكم في بوت من مجموعة الادارة 🔰
~~~~~~
/delmod @username : لازالة مشرف في مجموعة الادارة 
~~~~~~
/post <الرسالة>  : 
لارسال رساله لجميع القنوات 📑
~~~~~~
/autosend [time] [number list] msg : نشر بوقت محدد للستات 
/setgroup : لوضع مجموعه الادمن (control room)
~~~~~~
💡برمجه مصطفى فليكس 🇮🇶
https://telegram.me/joinchat/Cjp6HD0qHmCKJsgfyf7khw 📊]]
    return text
  end
  if is_channel_msg(msg) then
    local text = [[🔖💡بوت ادارة اللستات💡🔖
                   ~~~~~~~~~~
/help : للمساعده في استخدام البوت 🔧⚙
~~~~~~
/add @channelname 1 : لاضافه قناه الى اللسته الاولى ويمكن تغير رقم لسته حسب الرغبه لاضافه  🗳 القناه الى لسته معينه 
~~~~~~~
/delete @channelname 1 : لحذف قناه معينه من السته الاولى ويمكن تغير رقم لسته 📇
~~~~~~
/send list : مثال </send list 1 رسالة اللسته > 
لارسال اعلان لسته في لسته الاولى
📋
~~~~~~
/listall : اظهار جميع القنوات في جميع اللستات 🗂
~~~~~~
/run : تشغيل الاشعارات في مجموعة الادارة 🖌
~~~~~~
/crun : ايقاف الاشعارات في مجموعة.الادارة 
~~~~~~
/mod @username : اضافه مشرف للتحكم في بوت من مجموعة الادارة 🔰
~~~~~~
/delmod @username : لازالة مشرف في مجموعة الادارة 
~~~~~~
/post <الرسالة>  : 
لارسال رساله لجميع القنوات 📑
~~~~~~
/autosend [time] [number list] msg : نشر بوقت محدد للستات 
/setgroup : لوضع مجموعه الادمن (control room)
~~~~~~
💡برمجه مصطفى فليكس 🇮🇶
https://telegram.me/joinchat/Cjp6HD0qHmCKJsgfyf7khw 📊
]]
    return text
  else
    local text = [[aaa]]
    --return text
  end
end

return {
  description = "Help plugin. Get info from other plugins.  ", 
  usage = {
    "!help: Show list of plugins.",
  },
  patterns = {
    "^/(help)$",
  }, 
  run = run,
}
