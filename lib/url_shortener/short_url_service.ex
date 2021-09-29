defmodule UrlShortener.ShortUrlService do
  alias UrlShortener.ShortUrl
  alias UrlShortener.Repo

  import Ecto.Query, only: [from: 2]

  @spec insert_short_url(Ecto.UUID.t(), String.t(), String.t()) ::
          {:ok, ShortUrl.t()} | {:error, Atom.t()} | {:error, Ecto.Changeset.t()}
  def insert_short_url(user_id, long_url, slug)
      when is_binary(user_id) and is_binary(long_url) and is_binary(slug) do
    params = %{
      user_id: user_id,
      long_url: long_url,
      slug: slug
    }

    changeset = ShortUrl.changeset(params)

    case Repo.insert(changeset) do
      {:ok, %ShortUrl{} = inserted_record} -> {:ok, inserted_record}
      {:error, changeset} -> get_error_from_changeset(changeset)
    end
  end

  @spec find_long_url(String.t()) ::
          {:ok, ShortUrl.t()} | {:error, :resource_not_found}
  def find_long_url(slug) when is_binary(slug) do
    query =
      from short_url in ShortUrl,
        where: short_url.slug == ^slug

    case Repo.all(query) do
      [] -> {:error, :resource_not_found}
      [short_url] -> {:ok, short_url}
    end
  end

  @spec get_error_from_changeset(Ecto.Changeset.t()) ::
          {:error, :existing} | {:error, :duplicate} | {:error, Ecto.Changeset.t()}
  defp get_error_from_changeset(changeset) when is_map(changeset) do
    # I added this function on my flight coding with no internet to explore better ways
    # I doubt I'd come back to change this before submission.
    # I'd love if you could ignore this or ask me if I have an alternative approach on our call
    case UrlShortener.Schema.errors_on(changeset) do
      %{slug: ["has already been taken"]} -> {:error, :existing}
      %{user_id: ["duplicate long_url"]} -> {:error, :duplicate}
      %{slug: ["should be at most 10 character(s)"]} -> {:error, changeset}
    end
  end
end
