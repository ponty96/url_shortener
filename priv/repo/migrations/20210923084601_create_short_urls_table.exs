defmodule UrlShortener.Repo.Migrations.CreateShortUrlsTable do
  use Ecto.Migration

  def change do
    create table(:short_urls, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :binary_id
      add :slug, :string, size: 10
      # maximum url length is ideally 2,083.
      add :long_url, :binary

      timestamps()
    end

    create index(:short_urls, [:user_id, :long_url], unique: true)
    create index(:short_urls, :slug, unique: true)
  end
end
