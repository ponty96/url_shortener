defmodule UrlShortener.Errors.LinkShortenerError do
  @moduledoc false

  defexception message: "Failed to shorten url", reason: nil

  @type t :: %__MODULE__{}

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(opts) do
    reason = Keyword.fetch!(opts, :reason)
    %__MODULE__{message: "Failed to shortened url due to: #{reason}", reason: reason}
  end
end
