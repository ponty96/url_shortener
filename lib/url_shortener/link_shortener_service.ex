defmodule UrlShortener.LinkShortenerService do
  require Logger
  @slug_length 10
  alias UrlShortener.LinkHitService
  alias UrlShortener.ShortUrl
  alias UrlShortener.ShortUrlService

  use Appsignal.Instrumentation.Decorators

  @five_retries [0, 0, 0, 0]

  @decorate transaction_event()
  @spec shorten_link(Ecto.UUID.t(), String.t()) :: {:ok, String.t()} | {:error, Atom.t()}
  def shorten_link(user_id, long_url) do
    with_retries(@five_retries, fn ->
      with {:ok, slug} <- generate_slug(long_url),
           {:ok, %ShortUrl{} = short_url} <-
             ShortUrlService.insert_short_url(user_id, long_url, slug) do
        {:ok, short_url}
      else
        {:error, :existing} ->
          Appsignal.increment_counter("generate_short_link_failed", 1, %{
            reason: :existing
          })

          {:retry, {:error, :existing}}

        {:error, error} ->
          Logger.error("failed to shortened url. reason: #{inspect(error)}")

          Appsignal.increment_counter("generate_short_link_failed", 1, %{
            reason: error
          })

          {:error, error}
      end
    end)
  end

  @decorate transaction_event()
  @spec lookup(String.t()) :: {:ok, String.t()} | {:error, Atom.t()}
  def lookup(slug) do
    {:ok, sup} = Task.Supervisor.start_link()

    case ShortUrlService.find_long_url(slug) do
      {:ok, short_url} ->
        # counter for link hit here
        Task.Supervisor.async_nolink(sup, LinkHitService, :record_link_hit, [short_url])
        {:ok, short_url}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec generate_slug(String.t()) :: {:ok, String.t()} | {:error, :invalid_link}
  def generate_slug(url) do
    case URI.parse(url) do
      %URI{authority: nil} ->
        {:error, :invalid_link}

      _ ->
        slug = generate()
        {:ok, slug}
    end
  end

  @spec generate() :: String.t()
  defp generate do
    @slug_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> String.replace(~r/[\_\.,:;\?¿¡\!&@$%\^]/u, "")
    |> binary_part(0, @slug_length)
  end

  defp with_retries(retries, func) do
    case func.() do
      {:retry, original_error} ->
        {_, message} = original_error

        if Enum.empty?(retries) do
          Logger.warn("#{inspect(message)}. All retries failed. 0 retries left.")
          {:error, message}
        else
          Appsignal.increment_counter("generate_slug_retries")

          Logger.warn(
            "#{inspect(message)}. Attempting retry to generate a unique slug #{length(retries)} retries left."
          )

          [sleep_time | retries] = retries
          Process.sleep(sleep_time)
          with_retries(retries, func)
        end

      valid_response ->
        valid_response
    end
  end
end
