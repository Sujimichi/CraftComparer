require 'thor'
require 'craft_comparer'


module CraftComparer
  class CLI < Thor
    default_task :info

    desc "info", "basic overview"
    def info
      puts "I am a fish"
    end

  end
end
