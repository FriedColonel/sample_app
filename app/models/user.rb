class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.validate.email.regex

  before_save{self.email = email.downcase}
  validates :name, presence: true,
                   length: {maximum: Settings.validate.name.max_length}
  validates :email, presence: true,
                    length: {maximum: Settings.validate.email.max_length},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
  validates :password, presence: true,
                       length: {minimum: Settings.validate.password.min_length}

  has_secure_password
end
