defmodule UrlShortenerWeb.URLShortenerControllerTest do
  use UrlShortenerWeb.ConnCase

  alias UrlShortener.Repo
  alias UrlShortener.ShortUrl
  alias UrlShortener.Factory

  describe "POST  /api/shorten_url" do
    test "success: it shortens a valid url", %{conn: conn} do
      user_id = Ecto.UUID.generate()
      long_url = Faker.Internet.url()

      response =
        conn
        |> post("/api/shorten_url", %{
          "user_id" => user_id,
          "long_url" => long_url
        })
        |> json_response(200)

      short_url_from_db = Repo.get_by(ShortUrl, user_id: user_id, long_url: long_url)

      assert response["data"]["url"] ==
               "#{UrlShortenerWeb.Endpoint.url()}/#{short_url_from_db.slug}"
    end

    test "error: faillback controller handles error as expected", %{conn: conn} do
      user_id = Ecto.UUID.generate()
      long_url = ""

      response =
        conn
        |> post("/api/shorten_url", %{
          "user_id" => user_id,
          "long_url" => long_url
        })
        |> json_response(422)

      assert %{"errors" => [%{"field" => "long_url", "message" => "can't be blank"}]} == response
    end
  end

  describe "GET  /:slug" do
    test "success: it redirects to long_url matching the slug", %{conn: conn} do
      %{slug: slug} = short_url = Factory.insert(:short_url)

      assert short_url.long_url =~
               conn
               |> get("/#{slug}")
               |> Phoenix.ConnTest.redirected_to(301)
    end

    test "error: returns a 404 content when a short_url record matching the slug is not found", %{conn: conn} do
      slug = "bad_slug"

      response =
        conn
        |> get("/#{slug}")
        |> html_response(404)

      assert String.contains?(response, ["404"])
    end
  end
end
