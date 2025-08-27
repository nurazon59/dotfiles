return {
  text = "0xProto Nerd Font", -- Used for text
  numbers = "0xProto Nerd Font Mono", -- Used for numbers

  -- Unified font style map
  style_map = {
    ["Regular"] = "Regular",
    ["Semibold"] = "Regular",  -- 0xProtoにはSemiboldがないのでRegularにマッピング
    ["Bold"] = "Bold",
    ["Heavy"] = "Bold",  -- 0xProtoにはHeavyがないのでBoldにマッピング
    ["Black"] = "Bold",  -- 0xProtoにはBlackがないのでBoldにマッピング
  }
}
