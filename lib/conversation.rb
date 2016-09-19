class ConversationError < StandardError
end

class Conversation
  attr_reader :id

  def initialize(bot, message)
    @id = Time.now.to_i
    @bot = bot
    @chat_id = message.chat.id

    @user = User.find_or_create_by(uid: message.from.id)

    send_message "Open session #{@id}"

    ask
  end

  def handle(message)
    case message.text
    when '/help'
      send_message "Use /stop to close session"
    when '/stop'
      send_message "Close session #{@id}"

      fail ConversationError
    else
      unless @user.name
        @user.name = message.text
        @user.save

        send_message "Your name is updated to #{@user.name}"

        fail ConversationError
      else
        send_message "Nothing to do"
      end
    end
  end

  private

  def ask
    if @user.name
      send_message "Hello, #{@user.name}!"
    else
      names = User.first(10).map(&:name).reject(&:nil?)

      keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: names,
        one_time_keyboard: true
      )

      send_message "Hello, what is your name?", reply_markup: keyboard
    end
  end

  def send_message(message, extra = {})
    keyboard = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
    data = { chat_id: @chat_id, text: message, reply_markup: keyboard }.merge(extra)
    @bot.api.send_message(data)
  end
end
