defmodule UrlShortenerWeb.Validators.URLShortenerParams do
  @moduledoc false
  use UrlShortener.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:long_url, :string)
    field(:user_id, Ecto.UUID)
  end

  def cast_and_validate(params) do
    %__MODULE__{}
    |> cast(params, [:long_url, :user_id])
    |> validate_required([:long_url, :user_id])
    |> validate_url()
    |> apply_changes_if_valid()
  end

  defp validate_url(changeset) do
    long_url = get_change(changeset, :long_url)

    case long_url && URI.parse(long_url) do
      %URI{authority: nil} ->
        add_error(changeset, :long_url, "URL is invalid")

      _ ->
        changeset
    end
  end
end
