class Story < ActiveRecord::Base
  attr_accessible :content, :publish_date, :title, :tag_names, :view_counter

  has_many :comments, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, :through => :taggings,
                  :after_add => :calculate_count,
                  :after_remove => :calculate_count
  belongs_to :user

  scope :not_approved, where(:publish_date => nil)
  scope :approved, where("publish_date", present?)

  validates_length_of :title, maximum: 100, minimum: 10
  validates_length_of :content, minimum: 20, maximum: 1000
  validates  :title, :content, presence: true

  attr_reader :tag_names

  searchable do
    text :title, boost: 5
    text :content
    text :comments do
      comments.map(&:content)
    end
    time :publish_date
    text :user do
      user.full_name if user.present?
    end
  end

  def tag_names=(tokens)
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def mark_as_published
    self.update_attributes publish_date: Time.now
  end

  private

    def calculate_count(tag)
      tag.update_attribute :stories_count, tag.stories.count
    end
end
