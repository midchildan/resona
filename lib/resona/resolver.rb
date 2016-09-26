require "bundler"
require "cgi"
require "net/http"
require "uri"
require "yaml"

module Resona
  module Resolver
    REMOTE_URI = "https://rubygems.org"

    class << self
      def run(gemfile_path, **options)
        check_group_conflicts(options[:with], options[:without])
        Bundler.settings.with = options.fetch(:with, [])
        Bundler.settings.without = options.fetch(:without, [])

        # Resolve gem dependencies using Bundler.
        definition = Bundler::Definition.build(gemfile_path, nil, nil)
        definition.resolve_remotely!

        # For each gem, get a list of available versions.
        gem_versions = {}
        uri = URI(REMOTE_URI)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.start do |h|
          definition.specs.each do |spec|
            gem_versions[spec.name] = query_gem_versions(h, spec.name)
          end
        end

        # For each gem, find the matching version and its checksum.
        gems = definition.specs.inject({}) do |acc, spec|
          name = spec.name
          version = spec.version.to_s
          matching = gem_versions[name].find { |v| v["number"] == version }
          raise ChecksumNotFound.new(name, version) if matching.nil?
          checksum = matching["sha"]

          acc[name] = { version: version, checksum: checksum }
          acc
        end

        gems
      end


      private

      def query_gem_versions(remote_http, name)
        response = remote_http.get("/api/v1/versions/#{CGI.escape(name)}.yaml")
        response.value unless response.is_a? Net::HTTPSuccess

        YAML.load(response.body)
      end

      def check_group_conflicts(with, without)
        if with && without
          conflicting = with & without
          raise GroupConflict.new(conflicting) unless conflicting.empty?
        end
      end
    end

    class ChecksumNotFound < StandardError
      def initialize(gem_name, gem_version)
        super("Failed to obtain checksum for #{gem_name}-#{gem_version}.")
      end
    end

    class GroupConflict < StandardError
      def initialize(groups)
        super("Cannot both include and exclude: #{groups}.")
      end
    end
  end
end
