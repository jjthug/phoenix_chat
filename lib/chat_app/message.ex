defmodule ChatApp.Message do
  @derive {Jason.Encoder, only: [:id, :text, :user]}
  defstruct id: nil, text: nil, user: nil
end
