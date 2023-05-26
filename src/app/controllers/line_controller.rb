require 'line/bot'

class LineController < ApplicationController
  protect_from_forgery except: [:webhook]

  def webhook
    body = request.body.read

    # ここでブレイクポイントを打っておく
    # リクエストの中の変数を確認
    # httpの内容をのぞく
    # 登録時にユーザーIDがあればそれを使う
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          handle_text_message(event)
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def handle_text_message(event)
    message = {
      type: 'text',
      text: event.message['text']
    }

    response = client.reply_message(event['replyToken'], message)
    p response
  end
end
