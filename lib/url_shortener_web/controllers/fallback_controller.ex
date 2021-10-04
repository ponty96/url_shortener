defmodule UrlShortenerWeb.FallbackController do
  @moduledoc false

  use Phoenix.Controller

  def call(conn, {:error, %{__exception__: true} = error}) do
    conn
    |> put_status(Plug.Exception.status(error))
    |> put_view(UrlShortenerWeb.ErrorView)
    |> render("error_from_exception.json", error: error)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> put_view(UrlShortenerWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(422)
    |> put_view(UrlShortenerWeb.ErrorView)
    |> render("message_error.json", %{message: "#{inspect(error)}"})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(UrlShortenerWeb.ErrorView)
    |> render("message_error.json", %{message: "Could not perform operation"})
  end

  def call(conn, _) do
    conn
    |> put_status(500)
    |> put_view(UrlShortenerWeb.ErrorView)
    |> render("message_error.json", %{message: "Could not perform operation"})
  end
end
