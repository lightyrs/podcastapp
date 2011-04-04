require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '785ZIydpfGOllGyA8e0jCQ', 'ZQjzPjDAJ7dqFrsKms5BhCnqMKxcTgSvkWnov9U'
  provider :facebook, '168623136520386', '1da22ec4168394094d2b30b79b1b93eb', {:scope => 'publish_stream,offline_access,email'}
end