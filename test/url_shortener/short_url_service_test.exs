defmodule UrlShortener.ShortUrlServiceTest do
  use UrlShortener.DataCase
  alias UrlShortener.ShortUrl
  alias UrlShortener.ShortUrlService
  alias UrlShortener.Repo
  alias UrlShortener.Factory

  # insert_short_url(user_id, long_url, slug)
  describe "insert_short_url/3" do
    test "success: it insert the data when the slug is unique" do
      params = Factory.params_for(:short_url)

      assert {:ok, returned_short_url} =
               ShortUrlService.insert_short_url(params.user_id, params.long_url, params.slug)

      assert returned_short_url.slug == params.slug
      assert returned_short_url.long_url == params.long_url
      assert returned_short_url.user_id == params.user_id

      short_url_from_db = Repo.get(ShortUrl, returned_short_url.id)

      assert short_url_from_db.id == returned_short_url.id
      assert short_url_from_db.slug == returned_short_url.slug
      assert short_url_from_db.long_url == returned_short_url.long_url
      assert short_url_from_db.user_id == returned_short_url.user_id
    end

    test "failure: it returns an error when the slug is more than 10 characters" do
      # TODO: Generate random 10 characters here
      params = Factory.params_for(:short_url, slug: "12345678910")

      assert {:error, %Ecto.Changeset{}} =
               ShortUrlService.insert_short_url(params.user_id, params.long_url, params.slug)
    end

    # this is the catch all duplicate slug test
    test "failure: it return an {:error, :existing} when we attempt to insert record with a matching slug with a different long url in the datastorage ignoring the user_id with duplicating the record" do
      existing_slug = "existing"
      long_url_1 = "https://google.com"
      long_url_2 = "https://stord.com"
      user_id = Ecto.UUID.generate()

      Factory.insert(:short_url, slug: existing_slug, long_url: long_url_1)

      assert {:error, :existing} =
               ShortUrlService.insert_short_url(user_id, long_url_2, existing_slug)

      # assert that Repo.get_by returns a schema
      # it would break if there was more than one record
      assert %ShortUrl{} = Repo.get_by(ShortUrl, slug: existing_slug)
    end

    test "failure: it returns {:error, :duplicate} when we attempt to insert duplicate long_url for the same user" do
      existing_long_url = "https://google.com"
      user_id = Ecto.UUID.generate()
      slug = "ayomide"

      Factory.insert(:short_url, user_id: user_id, long_url: existing_long_url)

      assert {:error, :duplicate} =
               ShortUrlService.insert_short_url(user_id, existing_long_url, slug)

      # assert that Repo.get_by returns a schema
      # it would break if there was more than one record
      assert %ShortUrl{} = Repo.get_by(ShortUrl, long_url: existing_long_url, user_id: user_id)
    end
  end

  describe "find_long_url/1" do
    test "success: it returns the long_url of a matching slug" do
      inserted_short_url = Factory.insert(:short_url)

      _decoy_short_url = Factory.insert(:short_url)

      assert {:ok, %ShortUrl{} = returned_short_url} =
               ShortUrlService.find_long_url(inserted_short_url.slug)

      assert returned_short_url.id == inserted_short_url.id
      assert returned_short_url.long_url == inserted_short_url.long_url
      assert returned_short_url.slug == inserted_short_url.slug
      assert returned_short_url.user_id == inserted_short_url.user_id
    end

    test "failure: it returns a resource not found error when a matching slug is not found" do
      non_existing_slug = "ayomide"
      _decoy_short_url = Factory.insert(:short_url)

      assert {:error, :resource_not_found} = ShortUrlService.find_long_url(non_existing_slug)
    end
  end
end
