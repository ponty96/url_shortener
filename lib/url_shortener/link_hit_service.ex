defmodule UrlShortener.LinkHitService do
  alias UrlShortener.LinkHit
  alias UrlShortener.ShortUrl
  alias UrlShortener.Repo

  import Ecto.Query

  @spec record_link_hit(ShortUrl.t()) :: {:ok, LinkHit.t()} | {:error, Ecto.Changeset.t()}
  def record_link_hit(short_url) do
    short_url_id = short_url.id

    params = %{
      short_url_id: short_url_id,
      user_id: short_url.user_id,
      hits: 1
    }

    changeset = LinkHit.changeset(params)
    update_attributes = Map.to_list(changeset.changes)

    Repo.insert(
      changeset,
      conflict_target: :short_url_id,
      returning: true,
      on_conflict:
        from(entity in LinkHit,
          where: entity.short_url_id == ^short_url_id,
          update: [set: [hits: entity.hits + 1]]
        )
    )
  end
end
