# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_invoices_session',
  :secret      => 'cf2d20d2f4522998c93a37ecb036244c41f7a849ef52c37c2e89892254bf047611c6c2bba04886eb00841b12a56efed24d2fdbb4072e0c3dc874ad8a3d842728'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
