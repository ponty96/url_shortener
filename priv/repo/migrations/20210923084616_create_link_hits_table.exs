defmodule UrlShortener.Repo.Migrations.CreateLinkHitsTable do
  use Ecto.Migration

  def change do
    create table(:link_hits, primary_key: false) do
      add :short_url_id, :binary_id, primary_key: true
      add :user_id, :binary_id
      add :hits, :integer

      timestamps()
    end

    create index(:link_hits, :user_id)
  end
end
