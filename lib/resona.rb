require "resona/version"

module Resona
  autoload :Formula, "resona/formula"
  autoload :Resolver, "resona/resolver"

  class << self
    def print_formula(gemfile_path, **options)
      gems = Resolver.run(gemfile_path, options)
      Formula.print(gems)
    end
  end
end
