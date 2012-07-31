#encoding: utf-8

class Tag < ActiveRecord::Base
  attr_accessible :name

  has_many :taggings, dependent: :destroy
  has_many :stories, :through => :taggings

 def count_all_tags
    Tagging.all.count
  end

  def count_specific_tag(tag)
    Tag.find(tag).stories.count
  end

  def percentage_of_tag
    percent = self.count_specific_tag(self.id).to_f / count_all_tags.to_f * 100.0
    percent.floor + 100
  end
    
  private

    def self.tokens(query)
      tags = where("name like ?", "%#{query}%")
      if tags.empty?
        [{id: "<<<#{query}>>>", name: "جدید: \"#{query}\""}]
      else
        tags
      end
    end

    def self.ids_from_tokens(tokens)
      tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
      tokens.split(',')
    end
end
