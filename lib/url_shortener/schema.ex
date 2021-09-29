defmodule UrlShortener.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import UrlShortener.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts type: :utc_datetime_usec
    end
  end

  def apply_changes_if_valid(%{valid?: true} = changeset),
    do: {:ok, Ecto.Changeset.apply_changes(changeset)}

  def apply_changes_if_valid(changeset),
    do: {:error, changeset}

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
