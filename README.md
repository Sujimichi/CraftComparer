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
