require "uri"

module Resona
  module Formula
    class << self
      def print(gems)
        puts generate_resource_stanzas(gems)
        puts
        puts install_method
      end

      def generate_resource_stanzas(gems)
        stanzas = gems.sort.map do |name, info|
          resource_stanza(name, info[:version], info[:platform],
                          info[:checksum], info[:remote_uri])
        end

        stanzas.join("\n\n")
      end


      private

      def resource_stanza(name, version, platform, checksum, remote_uri)
        uri = if platform.nil? || platform.empty?
                URI.join(remote_uri, "/gems/#{name}-#{version}.gem")
              else
                URI.join(remote_uri, "/gems/#{name}-#{version}-#{platform}.gem")
              end

        <<-EOL
resource "#{name}" do
  url "#{uri}"
  sha256 "#{checksum}"
end
        EOL
      end

      def install_method
        <<-EOL
def install
  resources.each do |r|
    r.verify_download_integrity(r.fetch)
    system("gem", "install", r.cached_download, "--no-document",
      "--install-dir", "\#{libexec}/vendor")
  end

  mkpath bin
  (bin/"__YOUR_FORMULA_SCRIPT__").write <<-EOS.undent
  #!/bin/bash
  export GEM_HOME="\#{libexec}/vendor"
  exec ruby __TARGET__ "$@"
  EOS

  # TODO: Continue installation
end
        EOL
      end
    end
  end
end
