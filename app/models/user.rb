# encoding:utf-8
class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :full_name_foo, use: [:slugged, :history]

  def full_name_foo
    "#{full_name}"
  end

  def normalize_friendly_id(string)
    sep = "-"
    parameterized_string = string
    parameterized_string.gsub!(/[^\w\-اآبپتثجچحخدذرزژسشصضطظعغفقکگلمنوهیءئؤيإأةك۱۲۳۴۵۶۷۸۹۰ٔ‌]+/i, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end
    parameterized_string.downcase
  end

  attr_accessible :email, :full_name, :website, :password, :password_confirmation,
    :role_ids, :created_at, :favorite_tags

  has_secure_password

  has_and_belongs_to_many :roles
  has_many :stories
  has_many :comments
  has_many :rating_logs, dependent: :destroy
  has_many :votes
  has_many :identities
  has_many :sent_messages, class_name: Message, foreign_key: :sender_id
  has_many :received_messages, class_name: Message, foreign_key: :receiver_id

  validates_presence_of :full_name, :email
  validates :password, confirmation: true, presence: true, on: :create
  validates :email, email_format: true
  validates_uniqueness_of :email, case_sensitive: false
  validates_length_of :full_name, maximum: 30, minimum: 7

  accepts_nested_attributes_for :roles

  before_save :set_new_user_role

  searchable do
    text :full_name, as: :full_name_textp
    text :id
    text :email
    time :created_at
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def role?(role)
    defined_roles.include? role.to_s
  end

  def defined_roles
    roles.map do |role|
      role.name
    end
  end

  def count_unread_messages
    self.received_messages.where(unread: true).count
  end

  def favorite_tags_array
    unless self.favorite_tags.blank?
      self.favorite_tags.split(%r{[,|،]\s*})
    end
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def set_new_user_role
    if self.roles.empty?
      self.roles << (Role.find_by_name("new_user") or Role.create(name: "new_user"))
    end
  end
end
