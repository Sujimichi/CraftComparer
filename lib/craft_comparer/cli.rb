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
    attr_accessor :comparison_track, :summary, :threshold

    default_task :craft
    class_option "reverse",   :type => :string,   :default => false,:aliases => "r"
    class_option "summary",   :type => :boolean,  :default => true, :aliases => "s"
    class_option "threshold", :type => :numeric,  :default => 20,   :aliases => "t"

    def self.exit_on_failure?
      true
    end
    

    desc "CRAFT", "compare given craft with other craft. run `compare_craft help craft` for more"
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

    When doing any comparison you can add the -r or --reverse option. This will run the initial comparison of A against B, and then run it again as B against A.
    
    LONGDESC
    method_option "with", :type => :array, :desc => "provide 1 or more references to craft files", :aliases => "w"
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
      show_summary
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
      show_summary
    end

    map %w[--list -l] => :list
    desc "--list, -l", "list all craft files in current directory"
    def list
      DirectoryActions.new.show
    end

    map %w[--version -v] => :version
    desc "--version, -v", "Print the version"
    def version
      puts "CarftComparer #{CraftComparer::VERSION}"
    end    



    private

    def prepare
      @threshold ||= options[:threshold] || 20 
      @summary ||= {:count => 0, :close_matches => [], :paths => []}
    end

    def compare this, args = {}
      that = args[:with]
      raise Thor::Error, "craft file not found".red unless this && that     
      return if this.path == that.path
      prepare
      
      comp = [[this, that]]
      comp << comp[0].reverse if options[:reverse]
      comp.each do |this, that|
        path_string = "#{this.path}:#{that.path}"
        next if (@comparison_track || []).include?(path_string)
        result = this.compare_with that
        
        @summary[:count] += 1
        @summary[:paths] << this.path
        @summary[:paths] << that.path
        @summary[:close_matches] << {:this => this, :that => that, :score => result} if score_to_color(result) != :green

        puts "Compared #{this.craft_name} against #{that.craft_name}\n  #{result}% similar".send(score_to_color(result))
        @comparison_track ||= []
        @comparison_track << path_string
      end
    end

    def show_summary
      return unless options[:summary]
      puts "\n~~Craft Comparer #{CraftComparer::VERSION}~~"      
      print "#{@threshold}% or below - OK (green), ".green
      print "between #{@threshold}% and #{amber_cut_off}% - possible match (amber), ".amber
      puts  "#{amber_cut_off}% and higher - close match (red)".red      
      puts "Performed #{@summary[:count]} comparisons over #{@summary[:paths].uniq.count} craft"
      puts "Found #{@summary[:close_matches].count} similar craft"
      @summary[:close_matches].each do |data|
        puts "#{data[:this].craft_name} was #{data[:score]}% similar to #{data[:that].craft_name}".send(score_to_color(data[:score]))
      end
    end

    def score_to_color score
      score <= @threshold ? :green : (score < amber_cut_off ? :amber : :red) #set which color to print result in. 
    end

    def amber_cut_off
      ((100-@threshold)*0.3) + @threshold
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
