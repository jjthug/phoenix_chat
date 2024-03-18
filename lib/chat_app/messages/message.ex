defmodule ChatApp.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:room, :text, :username]}
  schema "messages" do
    field :username, :string
    field :room, :string
    field :text, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:username, :room, :text])
    |> validate_required([:username, :room, :text])
  end
end
