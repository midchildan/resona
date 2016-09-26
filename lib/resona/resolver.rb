require "bundler"

module Resona
  module Resolver
    class << self
      def run(gemfile_path, **options)
        check_group_conflicts(options[:with], options[:without])
        Bundler.settings.with = options.fetch(:with, [])
        Bundler.settings.without = options.fetch(:without, [])

        # Resolve gem dependencies using Bundler.
        definition = Bundler::Definition.build(gemfile_path, nil, nil)
        definition.resolve_remotely!

        # For each gem, extract the necessary version and its checksum.
        gems = definition.specs.inject({}) do |acc, spec|
          next acc unless spec.is_a? Bundler::EndpointSpecification

          name = spec.name
          version = spec.version.to_s
          checksum = spec.checksum
          remote_uri = spec.remote.anonymized_uri

          acc[name] = { version: version, checksum: checksum,
                        remote_uri: remote_uri }
          acc
        end

        gems
      end


      private

      def check_group_conflicts(with, without)
        if with && without
          conflicting = with & without
          raise GroupConflict.new(conflicting) unless conflicting.empty?
        end
      end
    end

    class GroupConflict < StandardError
      def initialize(groups)
        super("Cannot both include and exclude: #{groups}.")
      end
    end
  end
end
