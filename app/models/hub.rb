class Hub < ActiveRecord::Base
  include AuthUtilities
  include ModelExtensions

  before_validation do
    auto_sanitize_html(:description)
  end

  attr_accessible :title, :description, :tag_prefix
  acts_as_authorization_object
  has_many :hub_feeds, :dependent => :destroy
  has_many :hub_tag_filters, :dependent => :destroy, :order => :position
  has_many :republished_feeds, :dependent => :destroy, :order => 'created_at desc'
  has_many :feeds, :through => :hub_feeds

  # TODO - make a scope to find all feed items in a hub.

  def display_title
    self.title
  end

  alias :to_s :display_title

  def tagging_key
    "hub_#{self.id}".to_sym
  end

end
