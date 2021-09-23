defmodule UrlShortener.LinkHitTest do
  use UrlShortener.DataCase
  alias UrlShortener.LinkHit
  alias UrlShortener.Repo
  alias UrlShortener.Factory

  describe "changeset" do
    test "success: returns a valid changeset when passed valid params" do
      params = Factory.params_for(:link_hit)

      changeset = LinkHit.changeset(params)

      assert changeset.valid?
    end

    test "failure: it returns an invalid changeset when passed params with invalid types" do
      user_id = short_url_id = _not_a_uuid = "something"
      hits = _lesser_than_1 = 0

      params = %{
        user_id: user_id,
        short_url_id: short_url_id,
        hits: hits
      }

      changeset = LinkHit.changeset(params)

      refute changeset.valid?

      errors = errors_on(changeset)

      for field <- [:user_id, :short_url_id] do
        assert Map.fetch!(errors, field) == ["is invalid"]
      end

      assert Map.fetch!(errors, :hits) == ["must be greater than 0"]
    end

    test "failure: it returns an invalid changeset when required fields are empty" do
      params = %{
        user_id: "",
        short_url_id: "",
        hits: nil
      }

      changeset = LinkHit.changeset(params)

      # Verify
      refute changeset.valid?

      errors = errors_on(changeset)

      for {field, _} <- Map.to_list(params) do
        assert Map.fetch!(errors, field) == ["can't be blank"]
      end
    end

    test "failure: it returns an error when we attempt to insert duplicate short_url_id" do
      short_url_id = Ecto.UUID.generate()

      _link_hit = Factory.insert(:link_hit, short_url_id: short_url_id)

      params = Factory.params_for(:link_hit, short_url_id: short_url_id)

      changeset = LinkHit.changeset(params)

      assert {:error, changeset} = Repo.insert(changeset)

      errors = errors_on(changeset)

      assert Map.fetch!(errors, :short_url_id) == ["has already been taken"]
    end
  end
end
