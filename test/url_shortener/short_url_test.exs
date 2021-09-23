defmodule UrlShortener.ShortUrlTest do
  use UrlShortener.DataCase
  alias UrlShortener.ShortUrl
  alias UrlShortener.Repo
  alias UrlShortener.Factory

  describe "changeset" do
    test "success: returns a valid changeset when passed valid params" do
      params = Factory.params_for(:short_url)

      changeset = ShortUrl.changeset(params)

      assert changeset.valid?
    end

    test "failure: it returns an invalid changeset when passed params with invalid types" do
      user_id = _not_a_uuid = "something"
      long_url = _not_a_binary = %{}
      slug = _longer_than_10_characters = Ecto.UUID.generate()

      params = %{
        user_id: user_id,
        long_url: long_url,
        slug: slug
      }

      changeset = ShortUrl.changeset(params)

      refute changeset.valid?

      errors = errors_on(changeset)

      for field <- [:user_id, :long_url] do
        assert Map.fetch!(errors, field) == ["is invalid"]
      end

      assert Map.fetch!(errors, :slug) == ["should be at most 10 character(s)"]
    end

    test "failure: it returns an invalid changeset when required fields are empty" do
      params = %{
        user_id: "",
        long_url: "",
        slug: ""
      }

      changeset = ShortUrl.changeset(params)

      # Verify
      refute changeset.valid?

      errors = errors_on(changeset)

      for {field, _} <- Map.to_list(params) do
        assert Map.fetch!(errors, field) == ["can't be blank"]
      end
    end

    test "failure: it returns an error when we attempt to insert duplicate slug" do
      slug = "njcdergd"

      _short_url = Factory.insert(:short_url, slug: slug)

      params = Factory.params_for(:short_url, slug: slug)

      changeset = ShortUrl.changeset(params)

      assert {:error, changeset} = Repo.insert(changeset)

      errors = errors_on(changeset)

      assert Map.fetch!(errors, :slug) == ["has already been taken"]
    end

    test "failure: it returns an error when we attempt to insert duplicate long url per user" do
      %{user_id: user_id, long_url: long_url} = Factory.insert(:short_url)

      params = Factory.params_for(:short_url, user_id: user_id, long_url: long_url)

      changeset = ShortUrl.changeset(params)

      assert {:error, changeset} = Repo.insert(changeset)

      errors = errors_on(changeset)

      assert Map.fetch!(errors, :user_id) == ["duplicate long_url"]
    end

    test "success: it succeeds when we attempt to insert duplicate long url for different users" do
      %{long_url: long_url} = Factory.insert(:short_url)

      params = Factory.params_for(:short_url, long_url: long_url)

      changeset = ShortUrl.changeset(params)

      assert {:ok, _client_settings} = Repo.insert(changeset)
    end
  end
end
