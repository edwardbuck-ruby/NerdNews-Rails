#encoding: utf-8
# == Schema Information
#
# Table name: tags
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stories_count          :integer          default(1)
#  thumbnail_file_name    :string(255)
#  thumbnail_content_type :string(255)
#  thumbnail_file_size    :integer
#  thumbnail_updated_at   :datetime
#


class Tag < ActiveRecord::Base
  has_attached_file :thumbnail, :styles => { thumb: "64x64#" }, :default_url => "missing_64.png"

  has_many :taggings, dependent: :destroy
  has_many :stories, :through => :taggings

  validates :name, uniqueness: true, presence: true
  # We can't validate presence of thumbnail, because regular users
  # who posts stories can't assgine thumbnail for it
  validates_attachment :thumbnail,
    :content_type => {:content_type => ['image/jpeg', 'image/jpg', 'image/png']},
    :size => { :in => 0..100.kilobytes }

  searchable do
    text :name, as: "name_textp"
    text :id
    time :created_at
  end

  # private

  #   def self.tokens(query)
  #     tags = where("name like ?", "%#{query}%").select(:id, :name)
  #   end

  #   def self.ids_from_tokens(tokens)
  #     tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
  #     tokens.split(',')
  #   end
end
