defmodule UrlShortenerWeb.Validators.URLShortenerParamsTest do
  use UrlShortener.DataCase

  alias UrlShortenerWeb.Validators.URLShortenerParams

  describe "cast_and_validate/1" do
    test "success: it returns a valid %URLShortenerParams{} when passed valid params" do
      params = %{
        "user_id" => Ecto.UUID.generate(),
        "long_url" => Faker.Internet.url()
      }

      assert {:ok, validated_params} = URLShortenerParams.cast_and_validate(params)

      assert validated_params.__struct__ == URLShortenerParams

      assert validated_params.user_id == params["user_id"]
      assert validated_params.long_url == params["long_url"]
    end

    test "error: it returns an invalid EctoChangeset when passed blank params" do
      params = %{
        "user_id" => "",
        "long_url" => ""
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               URLShortenerParams.cast_and_validate(params)

      refute changeset.valid?

      assert %{long_url: ["can't be blank"], user_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "error: it returns an invalid EctoChangeset when passed wrong value types" do
      not_a_uuid = 1
      not_a_url = "dude@example.com"

      params = %{
        "long_url" => not_a_url,
        "user_id" => not_a_uuid
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               URLShortenerParams.cast_and_validate(params)

      refute changeset.valid?

      assert %{long_url: ["URL is invalid"], user_id: ["is invalid"]} == errors_on(changeset)
    end
  end
end
