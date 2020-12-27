# frozen_string_literal: true
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end
client = Slack::RealTime::Client.new
client.on :hello do
  puts(
    "Successfully connected, welcome '#{client.self.name}' to " \
    "the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  )
end

client.on :message do |data|
#  p data
  client.typing channel: data.channel

  case data.text
  when /@XXXXXXXXXXX/ #mention to @helper_bot
    #how to : @bot cmd vmstat / @bot cmd uptime
    str = data.text.to_s.gsub("<@XXXXXXXXXXX> cmd ", "")
    case str
    when 'vmstat'
      cmd = `vmstat -t -n 1 2 | tail -n 1`
      client.message channel: data.channel, text: "#{cmd}"
    when 'uptime'
      cmd = `uptime`
      client.message channel: data.channel, text: "#{cmd}"
    else
      if str.index("hi")
        client.message channel: data.channel, text: "Hi <@#{data.user}>!" 
      end
    end
  when 'hi bot'
      client.message channel: data.channel, text: "Hi <@#{data.user}>!"
  end
end

client.on :close do |_data|
  puts 'Connection closing, exiting.'
end
client.on :closed do |_data|
  puts 'Connection has been disconnected.'
end
client.start!