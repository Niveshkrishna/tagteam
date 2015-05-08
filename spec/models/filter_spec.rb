require 'rails_helper'

shared_context "User owns a hub with a feed and items" do
  before(:each) do
    @user = create(:confirmed_user)
    @hub = create(:hub, :with_feed, :owned, owner: @user)
    @hub_feed = @hub.hub_feeds.first
    @feed_items = @hub_feed.feed_items
  end
end

shared_examples "a tag filter" do |filter_type|
  include_context "User owns a hub with a feed and items"

  it "rolls back its changes when removed" do
    tag_lists = tag_lists_for(@feed_items, @hub.tagging_key, true)

    filter = add_filter
    filter.destroy

    new_tag_lists = tag_lists_for(@feed_items.reload, @hub.tagging_key, true)

    expect(new_tag_lists).to eq tag_lists
  end

  it "cannot conflict with other filters in a scope", wip: true do
  end

  context "The filter exists" do
    before(:each) do
      @filter = add_filter
    end

    it "loses precedence to more recent filters" do
      @hub.hub_tag_filters << create(:hub_tag_filter)

      expect(filter_list.first).to_not eq @filter
    end

    it "cannot be duplicated in a hub", wip: true do
    end

    context "it's older than another filter" do
      it "regains precedence when renewed" do
        @hub.hub_tag_filters << create(:hub_tag_filter)
        @filter.renew
        expect(filter_list.first).to eq @filter
      end
    end

    context "other hubs exist and filter is scoped to a hub" do
      it "doesn't affect other hubs", wip: true do
      end
    end

    context "other feeds exist and filter is scoped to a feed" do
      it "doesn't affect other feeds", wip: true do
      end
    end

    context "other items exists and filter is scoped to an item" do
      it "doesn't affect other items", wip: true do
      end
    end
  end


  context "A hub-level filter exists that adds a tag" do
    before(:each) do
    end

    it "takes precedence over the existing filter", wip: true do
    end
  end
end

describe AddTagFilter, "scoped to a hub" do
  def add_filter(tag_name = 'add-test')
    new_tag = create(:tag, name: tag_name)
    filter = create(:hub_tag_filter, type: :add, tag: new_tag)
    @hub.hub_tag_filters << filter
    filter
  end

  def filter_list
    @hub.hub_tag_filters
  end

  context "User owns a hub with a feed and items" do
    include_context "User owns a hub with a feed and items"

    it "adds tags" do
      new_tag = 'add-test'
      add_filter(new_tag)
      tag_lists = tag_lists_for(@feed_items, @hub.tagging_key)
      expect(tag_lists).to all( include new_tag )
    end
  end

  it_behaves_like "a tag filter", :add
end

describe ModifyTagFilter, "scoped to a hub" do
  def add_filter(old_tag = 'social', new_tag = 'not-social')
    filter = create(
      :hub_tag_filter,
      type: :modify,
      tag: ActsAsTaggableOn::Tag.find_by_name(old_tag),
      new_tag: create(:tag, name: new_tag)
    )
    @hub.hub_tag_filters << filter
    filter
  end

  def filter_list
    @hub.hub_tag_filters
  end

  context "User owns a hub with a feed and items" do
    include_context "User owns a hub with a feed and items"

    it "modifies tags" do
      old_tag = 'social'
      new_tag = 'not-social'
      old_tag_lists = tag_lists_for(@feed_items, @hub.tagging_key)

      add_filter(old_tag, new_tag)

      new_tag_lists = tag_lists_for(@feed_items.reload, @hub.tagging_key, true)

      correct_tag_lists = old_tag_lists.map do |list|
        list.map{ |tag| tag == old_tag ? new_tag : tag }.sort
      end

      expect(new_tag_lists).to eq correct_tag_lists.sort
    end
  end

  it_behaves_like "a tag filter", :modify
end

describe DeleteTagFilter, "scoped to a hub" do
  def add_filter(old_tag = 'social')
    filter = create(:hub_tag_filter, type: :delete,
                    tag: ActsAsTaggableOn::Tag.find_by_name(old_tag))
    @hub.hub_tag_filters << filter
    filter
  end

  def filter_list
    @hub.hub_tag_filters
  end

  context "User owns a hub with a feed and items" do
    include_context "User owns a hub with a feed and items"

    it "removes tags" do
      deleted_tag = 'social'

      add_filter(deleted_tag)

      tag_lists = tag_lists_for(@feed_items, @hub.tagging_key)
      expect(tag_lists).to all( not_contain deleted_tag )
    end
  end

  it_behaves_like "a tag filter", :delete
end