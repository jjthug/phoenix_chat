defmodule ChatApp.Messages do
  alias ChatApp.Message

  def insert_message(text, user) do
    %Message{id: UUID.uuid4(), text: text, user: user}
  end
end
