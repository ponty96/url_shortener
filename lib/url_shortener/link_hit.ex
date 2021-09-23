defmodule UrlShortener.LinkHit do
  use UrlShortener.Schema

  @type t :: %__MODULE__{
          short_url_id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          hits: Integer.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:short_url_id, Ecto.UUID, autogenerate: false}
  schema "link_hits" do
    field :user_id, Ecto.UUID
    field :hits, :integer

    timestamps()
  end

  @required_attrs [:user_id, :hits, :short_url_id]

  @spec changeset(map()) :: Ecto.Changeset.t(t())
  def changeset(params) do
    cast_params = __MODULE__.__schema__(:fields)

    %__MODULE__{}
    |> cast(params, cast_params)
    |> validate_required(@required_attrs)
    |> validate_number(:hits, greater_than: 0)
    |> unique_constraint(:short_url_id, name: :link_hits_pkey)
  end
end
