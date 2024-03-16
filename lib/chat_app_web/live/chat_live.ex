defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view
  alias ChatApp.Messages
  alias ChatAppWeb.Endpoint
  alias ChatAppWeb.Presence
  def mount(%{"room_id" => room_id}, _session, socket) do
    topic = "room:#{room_id}"
    user= MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      Endpoint.subscribe(topic)
      Presence.track(self(), topic, user, %{} )
    end

    online_users=
      topic
      |> Presence.list()
      |> Map.keys()
      |> IO.inspect(label: "online_users")

    # messages=[Messages.insert_message("#{user} joined the chat", "system")]
    {:ok, assign(socket, room: room_id, user: user, topic: topic, online_users: online_users, messages: []), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    ~H"""
      <h2> you are chatting in <code class="bg-slate-200 p-2"> <%= @room %></code> as <code class="bg-slate-200 p-2"><%= @user %> </code></h2>
    <div class="flex space-x-2">
      <div class="w-2/3">
      <div class="mt-4 border-2 p-4" phx-update="append" id="message list">
        <%!-- <%= for message <- @messages do %>
          <div> <%= message %></div>
        <% end %> --%>

        <div :for={message <- @messages} id={"message-#{message.id}"}>
          <.message_line message={message}/>
        </div>
      </div>

      <.simple_form :let={f} for={%{}} as={:message} phx-submit="save_message">
        <.input field={{f, :text}} name="chatmsg" value="" placeholder="Enter chat message" />
      </.simple_form>
      </div>

      <div>
       <h2> Currently connected </h2>
       <ul>
        <li :for={user <- @online_users} id={"online_user-#{user}"} class="text-xs"> <%= user %> </li>
       </ul>
      </div>
    </div>
    """
  end

  def message_line(%{message: %{user: "system"}} = assigns) do
    ~H"""
    <em class="text-slate-400"><%= @message.text %></em>
    """
  end

  def message_line(assigns) do
    ~H"""
    <span class="font-bold"><%= @message.user %></span> : <%= @message.text %>
    """
  end


  def handle_event("save_message",%{"chatmsg" =>text}, socket) do
    new_message = Messages.insert_message(text, socket.assigns.user)

    Endpoint.broadcast(socket.assigns.topic, "new_message", new_message)

    messages = [new_message]
    {:noreply,assign(socket, messages: messages)}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},socket) do
    # IO.inspect(payload, label: "payload")
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn user -> Messages.insert_message("#{user} joined", "system") end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn user -> Messages.insert_message("#{user} left", "system") end)

    online_users =
      socket.assigns.topic
      |> Presence.list()
      |> Map.keys()

    {:noreply,assign(socket, messages: join_messages ++ leave_messages, online_users: online_users)}
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    # IO.inspect(msg)

    {:noreply, assign(socket, messages: [message])}
  end
end
