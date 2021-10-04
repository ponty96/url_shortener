defmodule UrlShortener.LinkShortenerServiceTest do
  use UrlShortener.DataCase

  alias UrlShortener.Factory
  alias UrlShortener.LinkHit
  alias UrlShortener.Repo
  alias UrlShortener.LinkShortenerService
  import ExUnit.CaptureLog

  describe "shorten_link/2" do
    test "success: it generates a slug and insert a record with a unique slug" do
      valid_url = Faker.Internet.url()
      user_id = Ecto.UUID.generate()

      assert {:ok, short_url} = LinkShortenerService.shorten_link(user_id, valid_url)

      assert short_url.long_url == valid_url
      assert short_url.user_id == user_id
      assert String.length(short_url.slug) <= 10

      refute String.match?(short_url.slug, ~r/[\_\.,:;\?¿¡\!&@$%\^]/u)
    end

    test "failure: it returns an error when the long_url for the user isn't unique" do
      existing_long_url = Faker.Internet.url()
      user_id = Ecto.UUID.generate()

      Factory.insert(:short_url, long_url: existing_long_url, user_id: user_id)

      logs =
        capture_log(fn ->
          assert {:error, :duplicate} =
                   LinkShortenerService.shorten_link(user_id, existing_long_url)
        end)

      assert String.contains?(logs, "failed to shortened url. reason: :duplicate")
    end

    for invalid_link <- ["ayo.aregbede@gmail.com", "text here", ""] do
      test "failure: it rejects when the long url is invalid like #{invalid_link}" do
        invalid_link = unquote(invalid_link)
        user_id = Ecto.UUID.generate()

        logs =
          capture_log(fn ->
            assert {:error, :invalid_link} =
                     LinkShortenerService.shorten_link(user_id, invalid_link)
          end)

        assert String.contains?(logs, "failed to shortened url. reason: :invalid")
      end
    end
  end

  describe "generate_slug/1" do
    # Urls are validated against the https://tools.ietf.org/html/rfc3986#appendix-B standard
    test "success: it returns a valid slug of <= 10 characters when passed a valid link based on OWASP" do
      valid_url = Faker.Internet.url()

      assert {:ok, slug} = LinkShortenerService.generate_slug(valid_url)

      assert String.length(slug) <= 10

      refute String.match?(slug, ~r/[\_\.,:;\?¿¡\!&@$%\^]/u)
    end

    # use email address
    # use a normal text
    # use a url with double .com
    for invalid_link <- ["ayo.aregbede@gmail.com", "text here", ""] do
      test "failure: it returns an error when passed an invalid url like #{invalid_link}" do
        invalid_link = unquote(invalid_link)
        assert {:error, :invalid_link} = LinkShortenerService.generate_slug(invalid_link)
      end
    end
  end

  describe "lookup/1" do
    test "success: it returns the matching long_url and adds the link hit record for the initial hit" do
      short_url = Factory.insert(:short_url)

      assert {:ok, returned_short_url} = LinkShortenerService.lookup(short_url.slug)

      # verify returned_short_url same
      assert returned_short_url.id == short_url.id
      assert returned_short_url.long_url == short_url.long_url
      assert returned_short_url.slug == short_url.slug
      assert returned_short_url.user_id == short_url.user_id

      # Wait for async operation
      Process.sleep(500)

      # verify link hit
      link_hit = Repo.get_by(LinkHit, short_url_id: short_url.id)

      assert link_hit.hits == 1
      assert link_hit.user_id == returned_short_url.user_id
    end

    test "success: it returns the matching long_url and increases the link hit when its not the initial lookup" do
      short_url = Factory.insert(:short_url)

      initial_link_hit =
        Factory.insert(:link_hit, short_url_id: short_url.id, user_id: short_url.user_id)

      number_of_lookups = Enum.random(2..99)

      for _lookup <- 1..number_of_lookups do
        assert {:ok, returned_short_url} = LinkShortenerService.lookup(short_url.slug)

        # verify returned_short_url same
        assert returned_short_url.id == short_url.id
        assert returned_short_url.long_url == short_url.long_url
        assert returned_short_url.slug == short_url.slug
        assert returned_short_url.user_id == short_url.user_id
      end

      # Wait for async operation
      Process.sleep(1000)

      # verify link hit
      link_hit = Repo.get_by(LinkHit, short_url_id: short_url.id)

      assert link_hit.hits == initial_link_hit.hits + number_of_lookups
      assert link_hit.user_id == short_url.user_id
    end
  end
end
