class Bot
  def self.run(token)
    new.run(token)
  end

  def run(token)
    Telegram::Bot::Client.run(token) do |bot|
      @bot = bot
      @conversations = {}

      bot.listen do |message|
        if @conversations[message.chat.id]
          handle_message(message)
        else
          case message.text
          when '/help'
            bot.api.send_message(chat_id: message.chat.id, text: 'Use /new to create new session')
          when '/new'
            @conversations[message.chat.id] = Conversation.new(bot, message)
          end
        end
      end
    end
  end

  private

  def handle_message(message)
    @conversations[message.chat.id].handle(message)
  rescue ConversationError => e
    @conversations.delete(message.chat.id)
  end
end
