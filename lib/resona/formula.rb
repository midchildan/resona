require "uri"

module Resona
  module Formula
    class << self
      def print(gems)
        gems.each do |name, info|
          puts resource_stanza(Resolver::REMOTE_URI, 
                               name, info[:version], info[:checksum])
        end

        puts
        puts "def install"
        gems.each_key { |name| puts install_command(name) }
        puts "end"
      end


      private

      def resource_stanza(remote_uri, name, version, checksum)
        uri = URI.join(remote_uri, "/gems/#{name}-#{version}.gem")

        stanza = <<-EOS
resource "#{name}" do
  url "#{uri}"
  sha256 "#{checksum}"
end
        EOS

        stanza
      end

      def install_command(name)
        command =  <<-EOS
def install
  resources.each do |r|
    system("gem", "install", r.cached_download, "--no-document",
      "--install-dir", "\#{libexec}/vendor")
  end
end
        EOS

        command
      end
    end
  end
end
