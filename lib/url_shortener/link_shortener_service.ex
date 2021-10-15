defmodule UrlShortener.LinkShortenerService do
  require Logger
  @slug_length 10
  alias UrlShortener.Errors.LinkShortenerError
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
        {:error, %LinkShortenerError{reason: :existing}} ->
          Appsignal.increment_counter("generate_short_link_failed", 1, %{
            reason: :existing
          })

          {:retry, {:error, :existing}}

        {:error, error} ->
          log_error(error)
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

  @spec generate_slug(String.t()) :: {:ok, String.t()} | {:error, LinkShortenerError.t()}
  def generate_slug(url) do
    case URI.parse(url) do
      %URI{authority: nil} ->
        {:error, LinkShortenerError.exception([reason: :invalid])}

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

  defp log_error(exception) do
    Logger.error("#{inspect(exception.message)}")

    try do
      raise exception
    catch
      kind, reason ->
        Appsignal.send_error(kind, reason, __STACKTRACE__)
    end
  end
end
