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

  # def handle_info(:after_join, socket) do
  #   # Assuming you have a way to identify users, e.g., via assigned user_id
  #   user_id = socket.assigns.user_id

  #   # Track user presence
  #   Presence.track(socket, user_id, %{online_at: System.system_time(:seconds)})

  #   # Broadcast the current state to the client
  #   push(socket, "presence_state", Presence.list(socket))

  #   # Listen for presence diffs and broadcast them
  #   Presence.track(socket, to_string(user_id), %{metas: [%{online_at: System.system_time(:seconds)}]})
  #   {:noreply, socket}
  # end

  # # This function is called whenever there's a diff in presence information
  # def handle_info(%{event: "presence_diff", payload: diff}, socket) do
  #   push(socket, "presence_diff", diff)
  #   {:noreply, socket}
  # end

  def assert_joined!(_roomid) do
    :ok
  end
end
