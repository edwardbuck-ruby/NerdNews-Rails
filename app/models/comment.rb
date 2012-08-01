class Comment < ActiveRecord::Base
  belongs_to :story, :counter_cache => true
  belongs_to :user

  attr_accessible :content, :name, :email, :user_id

  validates :name, :content, presence: true
  validates :email, email_format: true, presence: true
end
