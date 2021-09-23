defmodule UrlShortener.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: UrlShortener.Repo

  alias UrlShortener.ShortUrl
  alias UrlShortener.LinkHit

  def short_url_factory do
    slug = Faker.Internet.slug() |> String.slice(0..4)

    %ShortUrl{
      user_id: Ecto.UUID.generate(),
      slug: slug,
      long_url: Faker.Internet.url()
    }
  end

  def link_hit_factory do
    %LinkHit{
      user_id: Ecto.UUID.generate(),
      short_url_id: Ecto.UUID.generate(),
      hits: 1
    }
  end
end
