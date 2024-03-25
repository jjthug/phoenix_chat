defmodule PasetoTokenVerifier do
  @moduledoc """
  Provides functionality to verify PASETO tokens.
  """

  alias Paseto.Payload

  @spec verify_token(String.t(), binary()) :: {:ok, Payload.t()} | {:error, term()}
  def verify_token(token, symmetric_key) do
    with {:ok, payload} <- Paseto.decrypt(token, symmetric_key),
         :ok <- validate_payload(payload) do
      {:ok, payload}
    else
      {:error, _} = error -> error
      _ -> {:error, :invalid_token}
    end
  end

  defp validate_payload(payload) do
    # Add your validation logic here. For example:
    # Check the payload expiry, issuer, subject, etc.
    # This is a placeholder and should be replaced with actual validation logic.
    #
    # if valid, return :ok, otherwise return {:error, :invalid_payload}

    :ok
  end
end
