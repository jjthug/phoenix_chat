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
      Presence.track(self(), topic, user, %{typing: false} )
    end

    online_users=
      topic
      |> Presence.list()
      |> Map.keys()
      |> IO.inspect(label: "online_users")

    # messages=[Messages.insert_message("#{user} joined the chat", "system")]
    {:ok, assign(socket, room: room_id, user: user, topic: topic, online_users: online_users, typing_users: [],
    messages: [Messages.insert_message("#{user} joined", "system")]), temporary_assigns: [messages: []]}
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

      <.simple_form :let={f} for={%{}} as={:message} phx-submit="save_message" phx-change="change_message">
        <.input field={{f, :text}} name="chatmsg" value="" placeholder="Enter chat message" />
      </.simple_form>
      <.typing_users_message users={@typing_users}/>
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
  def typing_users_message(%{users: []} = assigns) do
    ~H"""
    <div></div>
    """
  end

  def typing_users_message(%{users: users} = assigns) do
    ~H"""
    <div><%= Enum.join(users,", ") %> is typing</div>
    """
  end


  def handle_event("save_message",%{"chatmsg" =>text}, socket) do
    new_message = Messages.insert_message(text, socket.assigns.user)

    Presence.update(self(), socket.assigns.topic, socket.assigns.user, %{typing: false})
    Endpoint.broadcast(socket.assigns.topic, "new_message", new_message)

    messages = [new_message]
    {:noreply,assign(socket, messages: messages)}
  end

  def handle_event("change_message", %{"chatmsg" => ""}, socket) do
    Presence.update(self(), socket.assigns.topic, socket.assigns.user, %{typing: false})
    {:noreply,socket}
  end

  def handle_event("change_message", %{"chatmsg" => _text}, socket) do
    Presence.update(self(), socket.assigns.topic, socket.assigns.user, %{typing: true})
    {:noreply,socket}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}}, socket) do

    orig_online_user=socket.assigns.online_users
    current_online_users=socket.assigns.topic
    |> Presence.list()

    current_typing_usernames=current_online_users
    |> Enum.filter(fn {_username, %{metas: [%{typing: typing}]}} -> typing end)
    |> Enum.into(%{})
    |> Map.keys()

    current_online_usernames=Map.keys(current_online_users)

    leaves_users = orig_online_user -- current_online_usernames
    joins_users = current_online_usernames -- orig_online_user

    join_messages =
      joins_users
      |> Enum.map(fn user -> Messages.insert_message("#{user} joined", "system") end)

    leave_messages =
      leaves_users
      |> Enum.map(fn user -> Messages.insert_message("#{user} left", "system") end)

    {:noreply,assign(socket, messages: join_messages ++ leave_messages,
     online_users: current_online_usernames,
     typing_users: current_typing_usernames)}
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    # IO.inspect(msg)

    {:noreply, assign(socket, messages: [message])}
  end
end
