defmodule ChatAppWeb.RoomChannel do
  use Phoenix.Channel
  alias ChatApp.Messages

  def join("room:" <> _room_id, _message, socket) do
    IO.puts("user topic =>#{socket.assigns.topic}")
    {:ok, socket}
  end

  def handle_in("new_msg", %{"chatmsg" =>text}, socket) do
    new_message = Messages.insert_message(text, socket.assigns.user_id)
    IO.puts("topic=>#{socket.assigns.topic}")
    IO.puts("text=>#{text}")

    broadcast(socket, "new_msg", new_message)
    {:noreply, socket}
  end

  def assert_joined!(_roomid) do
    :ok
  end
end
