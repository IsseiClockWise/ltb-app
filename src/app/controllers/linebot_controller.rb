class LinebotController < ApplicationController  
  require 'line/bot'  # gem 'line-bot-api'  

  def client  
    @client ||= Line::Bot::Client.new { |config|  
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]  
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]  
    }  
  end  

  def push

      message={
          type: 'text',
          text: "hello"
         }
      user_id = 'isseitakeda0426'
      response = client.push_message(user_id, message)
  end

end  
