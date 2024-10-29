# frozen_string_literal: true

# Uses GitHub API to render markdown files in root directory
#   Note: Not bothering to use fixed github api key, which means there's a low ratelimit
#     so results are cached indefinitely by markdown filename/mtime
class MarkdownRenderer
  POOL_SIZE = 2 # adjustable if higher load expected
  # TODO: Maybe it would be better to do `git remote get-url origin`?
  #   Definitely overengineered for our purposes though (and no guaranteeing use of the name `origin`)
  GITHUB_CONTEXT = 'mvastola-samples/weather-forecast'

  class << self
    def render(path)
      path = Pathname.new File.expand_path(path, Rails.root)
      # Ensure we only ever consider `.md` files directly in Rails.root
      unless path.exist? && path.parent == Rails.root && path.extname == '.md'
        raise ArgumentError, "Invalid markdown path: #{path}"
      end
      pool.with { |renderer| renderer.render(path) }
    end

    # Used for debugging (if we were to test this)
    def cache = @cache ||= Rails.cache
    attr_writer :cache
    def with_cache(temp_cache, &block)
      old_cache, @cache = @cache, temp_cache
      begin
        yield
      ensure
        @cache = old_cache
      end
    end

    def without_cache(&block) = with_cache(ActiveSupport::Cache::NullStore.new, &block)

  protected
    def pool = @pool ||= ConnectionPool.new(size: POOL_SIZE) { MarkdownRenderer.send(:new) }
    private :new
  end

  attr_reader :client
  def initialize
    @client = Faraday.new('https://api.github.com') do |f|
      f.request :json, encoder: Oj
      f.response :json

      f.request :retry, max: 3
      f.response :logger, Rails.logger, { headers: false, bodies: !Rails.env.production?, errors: true }
      f.response :raise_error
      # If load justified it, we'd use an adapter supporting persistent connections
    end
  end

  # API Documentation: https://docs.github.com/en/rest/markdown/markdown?apiVersion=2022-11-28#render-a-markdown-document
  def render(path)
    timestamp = path.mtime
    cache.fetch("markdown/#{path.basename.to_s}/#{timestamp.rfc3339}") do
      source = path.read
      payload = { mode: 'gfm', context: GITHUB_CONTEXT, text: source }
      resp = @client.post('/markdown', payload) do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Accept"] = "application/vnd.github+json"
        req.headers["X-GitHub-Api-Version"] = "2022-11-28"
      end
      resp.body
    end
  end

  delegate :cache, to: :class
end
