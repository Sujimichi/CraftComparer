require 'thor'
require 'craft_comparer'
require 'craft_comparer/directory_actions'

module CraftComparer
  class CLI < Thor
    default_task :main

    desc "CRAFT", "compare given craft name/path/index with all other craft in the current directory"    
    method_option "with", :type => :array
    def main craft = nil
      return invoke :help if craft.nil?
      @dir = DirectoryActions.new 

      this = @dir.select_craft craft
      unless options[:with].nil? || options[:with].empty?
        those = options[:with].map{|craft| @dir.select_craft craft}
      else
        those = @dir.files.map{|craft| @dir.select_craft craft}
      end

      those.each do |that|
        this.compare_with that
      end

    end

    map %w[--list] => :list
    desc "--list", "list all craft files in current directory"
    def list
      DirectoryActions.new.show
    end

    map %w[--version -v] => :version
    desc "--version, -v", "Print the version"
    def version
      puts "CarftComparer #{CraftComparer::VERSION}"
    end    

  end
end

