defmodule UrlShortener.ShortUrl do
  use UrlShortener.Schema

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          slug: String.t(),
          long_url: binary(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "short_urls" do
    field :user_id, Ecto.UUID
    field :slug, :string
    field :long_url, :binary

    timestamps()
  end

  @required_attrs [:user_id, :slug, :long_url]

  @spec changeset(map()) :: Ecto.Changeset.t(t())
  def changeset(params) do
    cast_params = __MODULE__.__schema__(:fields)

    %__MODULE__{}
    |> cast(params, cast_params)
    |> validate_required(@required_attrs)
    |> validate_length(:slug, max: 10)
    |> unique_constraint(:slug)
    |> unique_constraint([:user_id, :long_url], message: "duplicate long_url")
  end
end
