# CraftComparer
CraftComparer.rb is based on the original idea by servo270 written in Python (https://github.com/servo270/PYTHON/blob/master/CraftComparer) but re-written as a Ruby gem.

## Install
##### For command line use
    git clone https://github.com/Sujimichi/CraftComparer.git
    cd CraftComparer
    rake install #(or use `gem build craft_comparer.gemspec` then `gem install craft_comparer`)

##### As a dependency
add this to your Gemfile:

    gem 'craft_comparer', :git => "https://github.com/Sujimichi/CraftComparer.git"
and then 
    
    bundle install
    
    
### Command line usage
After installing the gem you'll be able to run `compare_craft` in a terminal.  run with no args to display help

    compare_craft --all
compares each craft in directory with every other craft in the directory.  

    compare_craft my_craft.craft
compares specified craft against all other craft in the working directory.

    compare_craft my_craft.craft --with another.craft yet_another.craft
compares the first craft against 1 or more other craft (space separated).

Add the `-r` option to the above two commands to run the comparison in both directions (ie: A vs B and then B vs A).
(adding -r when using the --all option won't change anything).

Craft can be specified using their relative file name, full path or an index.  To see a list of the craft, in the current directory, with their index values run `compare_craft --list`
Then you can run 

    compare_craft 3 --with 4
which would compare the 3rd craft with the 4th craft in the directory.

add `--no-summary` if you don't want the summary of results at the end.  
use `--threshold` or `-t` to change the threshold for what difference is considered a match (default is 20, ie everything 20% or more similar is considered a match).


### Direct usage
CraftComparer provides the class CraftComparer::Craft which can be initialised with a craft file (array of strings) and then compared with another instance of CraftComparer::Craft.

```ruby
require 'craft_comparer'
craft_file = File.open("my_craft.craft", "r"){|f| f.readlines}
craft_1 = CraftComparer::Craft.new(craft_file)
craft_2 = CraftComparer::Craft.new(File.open("another.craft", "r"){|f| f.readlines})

similarity = craft_1.compare_with craft_2
```
compare_with returns a float between 0 and 100 as the percent similarity between the craft


Released under The MIT License
