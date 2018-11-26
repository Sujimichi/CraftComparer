
class DirectoryActions

  def self.list_craft
    files = Dir.glob("*.craft")
    if files.empty?
      puts "no .craft files found in current directory"
    else
      spacer = files.count.to_s.length
      files.each_with_index do |filename, index|
        puts "#{index}#{Array.new(spacer-index.to_s.length){" "}.join} - #{filename}"
      end
    end
  end

end

