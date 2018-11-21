
PartKeys = %w[pos attPos attPos0 rot attRot attRot0 mir symMethod autostrutMode rigidAttachment istg link attN]

class CraftContainer
  attr_accessor :header, :parts, :string

  def initialize craft_file
    @sensitivity = 1
    @trials = 100

    raise "craft file is not an Array" unless craft_file.is_a?(Array)
    get_parts_from craft_file
    get_header_from craft_file
    @string = self.to_string
  end

  #returns a string containing craft header and significant data from all parts
  def to_string
    [@header, @parts].flatten.compact.join
  end

  def compare_with craft
    raise "craft must be an instance of CraftContainer" unless craft.is_a?(CraftContainer)
    hits = @trials.times.select{ craft.string.include?(@string[*windex]) }.count
    hits/@trials.to_f    
  end


  protected
  
  def windex    
    window = (@sensitivity * ((rand*80).round + 20)).to_i
    a = rand * @string.length - window    
    [a..a+window]
  end

  def get_parts_from craft_file
    #get indexes of start and end lines for each PART
    start_indexes = craft_file.each_with_index.select{|l,ind| l =~ /^PART/}.map{|p| p[1]}  #Parts start on lines that start with PART
    end_indexes   = craft_file.each_with_index.select{|l,ind| l =~ /^}/}.map{|p| p[1]}     #Parts end on lines that start with }
    raise "PART/braket mismatch" unless start_indexes.count == end_indexes.count
    
    part_indexes = start_indexes.zip(end_indexes) #combine start and end indexes into pairs [[start_ind, end_ind], [start_ind, end_ind]...]

    @parts = part_indexes.map do |start_index, end_index|
      part_data = craft_file[start_index..end_index] #get all lines for a PART
      significant_lines = part_data.select{|line| PartKeys.include?(line.split("=")[0].strip) } #select the lines with required keys
      #discard any data following an underscore (ID references), remove leading/trailing whitespace and new line/tab chars and join lines together.
      significant_lines.map{|line| line.split("_")[0].strip }.join 
    end
  end

  def get_header_from craft_file
    header_range = [0..craft_file.index{|e| e =~ /^PART/}-1] #header is from first line to the line before the first occurance of PART
    @header = craft_file[*header_range]
  end

end

class CraftComparer

  def compare index_1, index_2
    craft = []
    craft << CraftContainer.new(load_by_index(index_1))
    craft << CraftContainer.new(load_by_index(index_2))
    
    exact_parts_match = craft[0].parts.select{|part| craft[1].parts.include?(part)}.count
    puts "exact parts match: #{exact_parts_match} out of #{craft[0].parts.count} parts"
    puts exact_parts_match/craft[0].parts.count.to_f   


    craft[0].compare_with(craft[1])
    


  end


  #dev method to quickly fetch a craft file from current dir
  def load_by_index index
    files = Dir.glob("*.craft")
    File.open(files[index], "r"){|f| f.readlines}
  end

  #dev method to list craft in dir
  def list_craft
    files = Dir.glob("*.craft")
    files.each_with_index do |filename, index|
      puts "#{index} - #{filename}"
    end
    return nil
  end


end

