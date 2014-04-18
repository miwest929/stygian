oauth_config = YAML.load_file("#{Rails.root}/config/oauth.yml")[Rails.env]
GITHUB = Octokit::Client.new(access_token: oauth_config['access_token'])

stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
