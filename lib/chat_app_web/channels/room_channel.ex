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

  def handle_in("change_msg", %{"chatmsg" => ""}, socket) do
    IO.puts("updating presence typing to false")
    Presence.update(socket, socket.assigns.user_id, %{typing: false})
    {:noreply, socket}
  end

  def handle_in("change_msg", %{"chatmsg" => _text}, socket) do
    IO.puts("updating presence typing to true")
    Presence.update(socket, socket.assigns.user_id, %{typing: true})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{isTyping: false})

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def assert_joined!(_roomid) do
    :ok
  end
end
