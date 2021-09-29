defmodule UrlShortener.LinkHitServiceTest do
  use UrlShortener.DataCase
  alias UrlShortener.LinkHit
  alias UrlShortener.LinkHitService
  alias UrlShortener.Repo
  alias UrlShortener.Factory

  describe "record_link_hit/1" do
    test "success: it adds a new record when none matching the short_url_id is found" do
      short_url = Factory.insert(:short_url)

      assert {:ok, link_hit} = LinkHitService.record_link_hit(short_url)

      assert link_hit.hits == 1
      assert link_hit.user_id == short_url.user_id
      assert link_hit.short_url_id == short_url.id

      link_hit_from_db = Repo.get_by(LinkHit, short_url_id: short_url.id)

      assert link_hit_from_db.short_url_id == link_hit.short_url_id
      assert link_hit_from_db.hits == 1
      assert link_hit_from_db.user_id == link_hit.user_id
    end

    test "success: it increments the hits of a link_hit matching the short_url" do
      hits = Enum.random(0..999)
      expected_hits = hits + 1

      short_url = Factory.insert(:short_url)

      link_hit =
        Factory.insert(:link_hit,
          hits: hits,
          short_url_id: short_url.id,
          user_id: short_url.user_id
        )

      assert {:ok, returned_link_hit} = LinkHitService.record_link_hit(short_url)

      assert returned_link_hit.hits == expected_hits
      assert returned_link_hit.short_url_id == link_hit.short_url_id
      assert returned_link_hit.short_url_id == link_hit.short_url_id

      link_hit_from_db = Repo.get_by(LinkHit, short_url_id: short_url.id)

      assert link_hit_from_db.short_url_id == link_hit.short_url_id
      assert link_hit_from_db.hits == expected_hits
      assert link_hit_from_db.user_id == link_hit.user_id
    end
  end
end
