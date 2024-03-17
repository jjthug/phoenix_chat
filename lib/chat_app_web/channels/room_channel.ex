defmodule ChatAppWeb.RoomChannel do
  use Phoenix.Channel
  alias ChatApp.Messages
  alias ChatAppWeb.Presence

  def join("room:" <> _room_id, _message, socket) do
    IO.puts("user topic =>#{socket.assigns.topic}")
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_in("new_msg", %{"chatmsg" =>text}, socket) do
    new_message = Messages.insert_message(text, socket.assigns.user_id)
    broadcast!(socket, "new_msg", new_message)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{})

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_info("presence_diff", socket) do
    IO.puts("presence_diff called internally")
    {:noreply, socket}
  end

  def assert_joined!(_roomid) do
    :ok
  end
end
