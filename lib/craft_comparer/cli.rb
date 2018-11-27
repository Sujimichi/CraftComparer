require 'thor'
require 'craft_comparer'
require 'craft_comparer/directory_actions'

class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
         stdout.puts message
       end
    end
  end
end

module CraftComparer
  class CLI < Thor
    default_task :craft

    def self.exit_on_failure?
      true
    end

    desc "CRAFT", "compare given craft name/path/index with other craft. run compare_craft help craft for more info"
    long_desc <<-LONGDESC 
    Craft Comparer can be given the name of a file in the current directory, the path to a craft file 
    or the index of a craft in the current directory (run compare_craft --list, to get a list with index numbers).

    If no other arguments are given it will compare the given craft file with all other craft files in the current directory.  
      compare_craft my_test_craft.craft
      compare_craft /path/to/my_test_craft.craft   
      compare_craft 6

    To compare a craft to one or more specific craft you can use the --with option:      
      compare_craft my_test_craft.craft --with another.craft some_other.craft

    To compare each craft in the current directory against each other use the --all option      
      compare_craft --all
    
    LONGDESC
    method_option "with", :type => :array, :desc => "provide 1 or more references to craft files"
    def craft craft_ref = nil
      return invoke :help if craft_ref.nil?
      
      @dir = DirectoryActions.new 
      this = @dir.select_craft craft_ref
      unless options[:with].nil? || options[:with].empty?
        those = options[:with].map{|craft_ref| @dir.select_craft craft_ref}
      else
        those = @dir.files.map{|craft_ref| @dir.select_craft craft_ref}
      end
      those.each do |that|        
        compare this, :with => that
      end
    end

    map %w[--all] => :all
    desc "--all", "compare all craft in current directory against each other"
    def all
      @dir = DirectoryActions.new 
      these = @dir.files.map{|craft_ref| @dir.select_craft craft_ref}
      those = @dir.files.map{|craft_ref| @dir.select_craft craft_ref}
      these.each do |this|
        those.each do |that|
          compare this, :with => that
        end
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



    private

    def compare this, args = {}
      that = args[:with]
      raise Thor::Error, "craft file not found".red unless this && that     
      return if this.path == that.path              

      result = this.compare_with that
      code = result <= 20 ? :green : (result < 50 ? :amber : :red)
      puts "Compared #{this.craft_name} against #{that.craft_name}\n  #{result}% similar".send(code)

    end

  end
end

class String
  # colorization
  def colorize color_code
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def amber
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end
