require 'craft_comparer'

class DirectoryActions
  attr_accessor :files

  def initialize
    @files = Dir.glob("*.craft")
  end

  def show
    if @files.empty?
      puts "no .craft files found in current directory"
    else
      spacer = @files.count.to_s.length
      @files.each_with_index do |filename, index|
        puts "#{index}#{Array.new(spacer-index.to_s.length){" "}.join} - #{filename}"
      end
    end
  end

  def select_craft craft_name_or_index
    if @files.include?(craft_name_or_index) || File.exists?(craft_name_or_index)
      craft_file = File.open(craft_name_or_index, "r"){|f| f.readlines}
      path = File.expand_path(craft_name_or_index)
    elsif craft_name_or_index.to_i.to_s.eql?(craft_name_or_index) #test if string is an integer
      if @files[craft_name_or_index.to_i] != nil
        craft_file = File.open(@files[craft_name_or_index.to_i], "r"){|f| f.readlines}        
        path = File.expand_path(@files[craft_name_or_index.to_i])
      end
    end
    if craft_file
      craft = CraftComparer::Craft.new(craft_file)
      craft.path = path
    end
    craft
  end

end

