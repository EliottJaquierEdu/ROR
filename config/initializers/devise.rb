# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = Rails.application.credentials.secret_key_base

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # Configure which authentication keys should be case-insensitive.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  config.strip_whitespace_keys = [:email]

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  config.skip_session_storage = [:http_auth]

  # ==> Configuration for :database_authenticatable
  config.stretches = Rails.env.test? ? 1 : 12

  # ==> Configuration for :rememberable
  config.remember_for = 2.weeks
  config.expire_all_remember_me_on_sign_out = true

  # ==> Navigation configuration
  config.sign_out_via = :delete

  # ==> Scoped views
  config.scoped_views = true
end
