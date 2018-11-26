require 'thor'
require 'craft_comparer'
require 'directory_actions'

module CraftComparer
  class CLI < Thor
    default_task :info

    desc "info", "basic overview"
    def info
      puts "I am a fish"
    end

    desc "list", "list the craft files in the current directory"
    def list
      DirectoryActions.list_craft
    end

    desc "compare", "test"
    def compare *args
      raise [args, options].inspect
    end

  end
end

