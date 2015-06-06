#!/usr/bin/env ruby

require 'json'

puts 'read settings...'

settings = JSON.parse(STDIN.read)
p settings

cmd = ""
if settings['home'] == '0' # 外出中
  cmd = "\\x41\\x00\\x55" # 消灯
else # 在宅中
  if settings['sleep'] == '0' # 寝てない
    cmd = "\\x42\\x00\\x55" # 点灯
  else # 寝てる
    cmd = "\\x41\\x00\\x55" # 消灯
  end
end

exit unless cmd
p cmd
p `bash -c 'echo -ne "#{cmd}" > /dev/udp/192.168.10.16/8899'`
p $?
