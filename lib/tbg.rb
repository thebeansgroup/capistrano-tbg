require "tbg/version"

module Capistrano
  module Tbg
    Dir["tasks/**/*.rake"].each { |ext| load ext } if defined?(Rake)
    # Your code goes here...
  end
end