require "bundler"
require "cgi"
require "net/http"
require "uri"
require "yaml"

module Resona
  module Resolver
    DEFAULT_URI = "https://rubygems.org"

    class << self
      def run(gemfile_path, **options)
        check_group_conflicts(options[:with], options[:without])
        Bundler.settings.with = options.fetch(:with, [])
        Bundler.settings.without = options.fetch(:without, [])

        # Resolve gem dependencies using Bundler.
        definition = Bundler::Definition.build(gemfile_path, nil, nil)
        definition.resolve_remotely!

        # For each gem, extract necessary info.
        gems = definition.specs.inject({}) do |acc, spec|
          next acc unless spec.is_a? Bundler::EndpointSpecification

          name = spec.name
          version = spec.version.to_s
          checksum = spec.checksum # quite a few is empty
          platform = spec.platform
          remote_uri = spec.remote.anonymized_uri || DEFAULT_URI

          if checksum.nil? || checksum.empty?
            checksum = query_checksum(spec, remote_uri)
          end

          acc[name] = { version: version, checksum: checksum,
                        remote_uri: remote_uri, platform: platform }
          acc
        end

        gems
      end


      private

      def query_checksum(spec, remote_uri)
        uri = URI(remote_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        response = http.get("/api/v1/versions/#{CGI.escape(spec.name)}.yaml")
        response.value unless response.is_a? Net::HTTPSuccess

        gem_versions = YAML.load(response.body)
        matching = gem_versions.find do |v|
          next false unless v["number"] == spec.version.to_s
          platform = Gem::Platform.new(v["platform"])
          spec.match_platform(platform)
        end
        if matching.nil? || matching["sha"].nil? || matching["sha"].empty?
          raise ChecksumNotFound.new(name, version)
        end

        matching["sha"]
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
