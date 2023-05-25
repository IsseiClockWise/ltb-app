require 'line/bot'

class LinebotController < ApplicationController
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      user_id = event['source']['userId']
      user = User.where(uid: user_id)[0]
      if event.message['text'].include?("お買い物リスト")
        message = shopping_list(send_limit_item(user))
      elsif event.message['text'].include?("自動購入機能テスト")
        message = test_selenium(user)
      end

      case event
      # メッセージが送信された場合
      when Line::Bot::Event::Message
        case event.type
        # メッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end

  private

  def send_limit_item(user)
    limit_seven_days = Date.today..Time.now.end_of_day + (7.days)
    limit_items =  ExpendableItem.where(user_id: user.id).where(deadline_on: limit_seven_days)
    if limit_items != []
      names = limit_items.map {|item| item.name } 
      response = "1週間以内に以下の消耗品が無くなります。\n早めの買い足しをオススメします。\n\n#{names.join("\n")}"
    else
      response = "1週間以内に無くなる消耗品はありません。"
    end
  end

  def shopping_list(response) ##メッセージの形式を作成
    {
      type: 'flex',
      altText: 'お買い物リスト',
      contents: {
        type: 'bubble',
        header:{
          type: 'box',
          layout: 'horizontal',
          contents:[
            {
              type: 'text',
              text: 'お買い物リスト',
              wrap: true,
              size: 'md',
            }
          ]
        },
        body: {
          type: 'box',
          layout: 'horizontal',
          contents: [
            {
              type: 'text',
              text: response,
              wrap: true,
              size: 'sm',
            }
          ]
        }
      }
    }
  end

  ...省略
end
