defmodule UrlShortener.Errors.ResourceNotFoundError do
  @moduledoc false

  defexception message: "Resource not found", plug_status: 404

  @type t :: %__MODULE__{}

  def exception(opts) do
    resource = Keyword.fetch!(opts, :resource)
    id = Keyword.fetch!(opts, :id)
    %__MODULE__{message: "#{resource} not found for #{id}"}
  end
end
