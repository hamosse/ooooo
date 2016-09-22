do local _ = {
  disabled_channels = {},
  enabled_plugins = {
    "plugins",
    "moderation",
    "help",
    "channelcontrol"
  },
  moderation = {
    data = "data/moderation.json"
  },
  sudo_users = {
    164717230,
    171604508
  }
}
return _
end
