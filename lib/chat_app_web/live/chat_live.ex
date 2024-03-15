defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view
  alias ChatApp.Messages
  alias ChatAppWeb.Endpoint

  def mount(%{"room_id" => room_id}, _session, socket) do
    topic = "room:#{room_id}"
    if connected?(socket) do
      Endpoint.subscribe(topic)
    end

    user= MnemonicSlugs.generate_slug(2)
    # messages=["A chat message", "a second message", "a third message"]
    messages=[Messages.insert_message("#{user} joined the chat", "system")]
    {:ok, assign(socket, room: room_id, user: user, topic: topic, messages: messages), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2> you are chatting in <code class="bg-slate-200 p-2"> <%= @room %></code> as <code class="bg-slate-200 p-2"><%= @user %> </code></h2>

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

  def handle_info(%{event: "new_message", payload: message}, socket) do
    # IO.inspect(msg)

    {:noreply, assign(socket, messages: [message])}
  end
end
