require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'oauth2'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Codelife
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/github)
  end
end
