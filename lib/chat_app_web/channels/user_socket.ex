defmodule ChatAppWeb.UserSocket do
  use Phoenix.Socket

  # Define channels and their topics
  channel "room:*", ChatAppWeb.RoomChannel

  # Optional: Customize the socket's behavior
  def connect(%{"room_id" => room_id, "user_id" => user_id}, socket, _connect_info) do
    topic = room_id
    {:ok, assign(socket, room_id: room_id, topic: topic, user_id: user_id)}
  end

  def id(_socket), do: nil
end
