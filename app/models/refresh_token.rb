class RefreshToken < ApplicationRecord
  default_scope -> { where('expire_at IS NULL OR expire_at > ?', Time.now) }
  after_initialize :set_defaults

  def self.destroy_all_expired
    unscoped.where('expire_at <= ?', Time.now).destroy_all
  end

  def user
    User.new(**decoded_data)
  end

  def decoded_data
    JSON.parse(data).symbolize_keys
  end

  protected

  def set_defaults
    self.token ||= SecureRandom.uuid
    self.expire_at ||= Time.now + 1.month
  end
end
