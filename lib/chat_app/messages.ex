defmodule ChatApp.Messages do
  alias ChatApp.Message

  def insert_message(text, user) do
    %Message{id: UUID.uuid4(), text: text, user: user}
  end

  alias ChatApp.Messages.Message
  alias ChatApp.Repo
  import Ecto.Query

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages(room) do
    from(msg in Message, where: msg.room == ^room)
    |> Repo.all()
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
