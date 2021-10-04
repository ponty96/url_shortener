defmodule UrlShortenerWeb.ChangesetView do
  @moduledoc false

  use UrlShortenerWeb, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `UrlShortenerWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    errors = changeset |> translate_errors |> error_list
    %{errors: errors}
  end

  @doc """
  Translates the nested maps and lists output of `Ecto.Changeset.traverse_errors/2` into
  a list of maps with `field` and `message` keys.
  """

  def error_list(errors) when is_map(errors) do
    Enum.reduce(errors, [], fn
      {field, errors}, acc when is_list(errors) ->
        Enum.map(errors, fn error -> %{field: to_string(field), message: error} end) ++ acc

      {field, nested_errors}, acc when is_map(errors) ->
        error_list(
          Enum.into(nested_errors, %{}, fn {nested_field, errors} ->
            {"#{field}.#{nested_field}", errors}
          end)
        ) ++
          acc
    end)
  end
end
