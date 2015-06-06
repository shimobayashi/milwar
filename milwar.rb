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

p cmd
if cmd
  p `bash -c 'echo -ne "#{cmd}" > /dev/udp/192.168.10.16/8899'`
  p $?
end

# Send to mackerel
epoch = Time.now.to_i
api_key = ENV['MACKEREL_API_KEY']
json = [
  {
    name: 'myself.sleep',
    time: epoch,
    value: settings['sleep'].to_i,
  },
  {
    name: 'myself.home',
    time: epoch,
    value: settings['home'].to_i,
  },
].to_json
`curl https://mackerel.io/api/v0/services/My-Room/tsdb -H 'X-Api-Key: #{api_key}' -H 'Content-Type: application/json' -X POST -d '#{json}'`
