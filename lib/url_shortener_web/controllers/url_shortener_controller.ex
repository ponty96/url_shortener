defmodule UrlShortenerWeb.URLShortenerController do
  use UrlShortenerWeb, :controller

  use Appsignal.Instrumentation.Decorators

  alias UrlShortenerWeb.Validators.URLShortenerParams
  alias UrlShortener.LinkShortenerService

  action_fallback UrlShortenerWeb.FallbackController

  def create(conn, params) do
    with {:ok, validated_params} <- URLShortenerParams.cast_and_validate(params),
         {:ok, short_url} <-
           LinkShortenerService.shorten_link(validated_params.user_id, validated_params.long_url) do
      json(conn, %{
        data: %{
          url: "#{UrlShortenerWeb.Endpoint.url()}/#{short_url.slug}"
        }
      })
    end
  end

  def show(conn, %{"slug" => slug}) do
    case LinkShortenerService.lookup(slug) do
      {:ok, short_url} ->
        conn
        |> put_status(301)
        |> redirect(external: short_url.long_url)

      {:error, :resource_not_found} ->
        conn
        |> put_status(404)
        |> render("404.html")
    end
  end
end
