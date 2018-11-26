module CraftComparer
  PartKeys = %w[part pos attPos attPos0 rot attRot attRot0 mir symMethod autostrutMode rigidAttachment istg link attN]
  Threshold = 60 #craft that are 80% similar are considered equal #todo tweak this value

  class Craft
    attr_accessor :string, :craft_name

    def initialize craft_file, args = {}
      raise "expected first argument to be an Array" unless craft_file.is_a?(Array)
      @args = {:sensitivity => 1, :trials => 10000, :output => false}.merge(args) #defaults can be overidden by supplying optional hash as 2nd argument
      @mode = :kat #change to :servo to use servo's cleaning style
      @craft_name = craft_file[0].split("=").last.strip #should prob be craft_file[craft_file.index{|l| l =~ /^ship/}].split("=").last.strip 
      @string = [get_header_from(craft_file), get_parts_from(craft_file)].flatten.compact.join
    end

    def compare_with craft
      raise "craft must be an instance of CraftComparer::Craft" unless craft.is_a?(CraftComparer::Craft)
      #generate an array of @args[:trials] in length and for each element test if the randomly selected section ('window') in the current craft (self)
      #occurs in the comparison craft and count the elements in which the test returns true.
      hits = @args[:trials].times.select{ craft.string.include?(self.string[*windex]) }.count
      result = (hits/@args[:trials].to_f * 100).round(2) #convert to percentage
      puts "Compared #{self.craft_name} against #{craft.craft_name} - #{result}% similar" if @args[:output]
      result #return result
    end

    def == craft
      self.compare_with(craft) >= CraftComparer::Threshold
    end
    alias :eql? :==

    protected

    #generate a random index for a 'window'; a randomly sized, randomly located region within the craft data string
    def windex    
      window = (rand*80 + 20).to_i * @args[:sensitivity] #random integer between 20 and 100 multipled by sensitivity
      start_index = (rand * @string.length).to_i - window #random integer between 0 and string length minus the window
      [start_index..start_index+window] #return the range.
    end

    #returns an Array of Strings from the first line of the craft file until the first PART
    def get_header_from craft_file
      header_range = [0..craft_file.index{|e| e =~ /^PART/}-1] #header is from first line to the line before the first occurance of PART
      header_range = [0..10] if @mode == :servo
      craft_file[*header_range]       
    end

    #returns an Array of Strings, one element per part in the craft file. Each element contains selected data for the part joined together as a single string
    def get_parts_from craft_file
      #get indexes of start and end lines for each PART
      start_indexes = craft_file.each_with_index.select{|l,ind| l =~ /^PART/}.map{|p| p[1]} #Parts start on lines with 'PART' at the start of a line
      end_indexes   = craft_file.each_with_index.select{|l,ind| l =~ /^}/}.map{|p| p[1]}    #Parts end on lines with '}' at the start of a line
      raise "PART/braket mismatch" unless start_indexes.count == end_indexes.count          #just incase
      part_indexes = start_indexes.zip(end_indexes) #combine start and end indexes into pairs [[start_ind, end_ind], [start_ind, end_ind]...]

      part_indexes.map do |start_index, end_index|
        part_data = craft_file[start_index..end_index] #get all lines for a PART
        if @mode == :servo
          significant_lines = part_data[2..14]
          significant_lines.join
        else
          significant_lines = part_data.select{|line| PartKeys.include?(line.split("=")[0].strip) } #select the lines with required keys  
          #discard any data following an underscore (ID references), remove leading/trailing whitespace, new-line/tab chars, and join lines together.      
          significant_lines.map{|line| line.split("_")[0].strip }.join 
        end

      end
    end
  end
end

