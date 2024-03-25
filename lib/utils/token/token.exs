defmodule Token do
  @moduledoc """
  A utility module for handling various operations, including PASETO token decryption.
  """

  @doc """
  Decrypts a PASETO token using the given symmetric key.

  ## Parameters
  - token: The PASETO token to be decrypted.
  - symmetric_key: The symmetric key used for decryption.

  ## Returns
  - {:ok, payload} on successful decryption.
  - {:error, reason} on failure.
  """
  def decrypt_paseto_token(token, symmetric_key) do
    Paseto.decrypt(token, symmetric_key)
    |> handle_decryption_result()
  end

  defp handle_decryption_result({:ok, payload}), do: {:ok, payload}
  defp handle_decryption_result({:error, _} = error), do: error
end
