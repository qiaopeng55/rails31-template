# Application Generator Template
# Modifies Rails to use Devise with RSpec with the HTML5 Boilerplate and 960gs
#
# Base on application template recipes by
#
#
#
#  ______          __             __                       _   _____            _
#.' ____ \        [  |           [  |                     | | |_   _|          [  |
#| (___ \_| .---.  | |--.   .--.  | |  ,--.   _ .--.  .--.\_|   | |      ,--.   | |.--.
# _.____`. / /'`\] | .-. |/ .'`\ \| | `'_\ : [ `/'`\]( (`\]     | |   _ `'_\ :  | '/'`\ \
#| \____) || \__.  | | | || \__. || | // | |, | |     `'.'.    _| |__/ |// | |, |  \__/ |
# \______.''.___.'[___]|__]'.__.'[___]\'-;__/[___]   [\__) )  |________|\'-;__/[__;.__.'
#

# Download Modernizr JS libraries
get "https://raw.github.com/paulirish/html5-boilerplate/master/js/libs/modernizr-2.0.6.min.js", "vendor/assets/javascripts/modernizr.min.js"

# Download HTML5 Boilerplate & 960gs stylesheets
get "https://raw.github.com/paulirish/html5-boilerplate/master/css/style.css", "vendor/assets/stylesheets/style.css"
get "http://grids.heroku.com/grid.css?column_width=60&column_amount=12&gutter_width=20", "vendor/assets/stylesheets/960gs.css"

gsub_file 'vendor/assets/stylesheets/style.css', / \* ==\|== normalize ==========================================================/, ' *'

# TODO: scholarslab icons; 114x114, 57x57, 72x72

# Boilerplate assets
get "https://raw.github.com/paulirish/html5-boilerplate/master/.htaccess", "public/.htaccess"
get "https://raw.github.com/paulirish/html5-boilerplate/master/crossdomain.xml", "public/crossdomain.xml"
get "https://raw.github.com/paulirish/html5-boilerplate/master/humans.txt", "public/humans.txt"

append_to_file 'public/humans.txt' do
  %q{


  ______          __             __                       _   _____            _
.' ____ \        [  |           [  |                     | | |_   _|          [  |
| (___ \_| .---.  | |--.   .--.  | |  ,--.   _ .--.  .--.\_|   | |      ,--.   | |.--.
 _.____`. / /'`\] | .-. |/ .'`\ \| | `'_\ : [ `/'`\]( (`\]     | |   _ `'_\ :  | '/'`\ \
| \____) || \__.  | | | || \__. || | // | |, | |     `'.'.    _| |__/ |// | |, |  \__/ |
 \______.''.___.'[___]|__]'.__.'[___]\'-;__/[___]   [\__) )  |________|\'-;__/[__;.__.'

}
end

# Update application.html.erb with HTML Boilerplate index.html content
inside('app/views/layouts') do
  FileUtils.rm_rf 'application.html.erb'
end

get "https://raw.github.com/paulirish/html5-boilerplate/master/index.html", "app/views/layouts/application.html.erb"
add_file "app/views/layouts/_header.html.erb"
add_file "app/views/layouts/_footer.html.erb"

# rewrite stylesheet inclusion
gsub_file 'app/views/layouts/application.html.erb', /<link rel="stylesheet" href="css\/style.css">/ do
  "<%= stylesheet_link_tag \"style\", \"960gs\", \"application\" %>"
end

gsub_file 'app/views/layouts/application.html.erb', /<script src="js\/libs\/modernizr-2.0.6.min.js"><\/script>/, '<%= javascript_include_tag "modernizr.min", :cache => "modernizr" %>'
gsub_file 'app/views/layouts/application.html.erb', /<meta charset="utf-8">/ do
  "<meta charset=\"utf-8\">
  <%= csrf_meta_tag %>"
end

gsub_file 'app/views/layouts/application.html.erb', /<div id="container">[\s\S]*<\/div>/ do
  %q{<div id="container">
     <header>
      <%= render 'layouts/header' %>
     </header>

     <div id="main" role="main">
      <%= yield %>
     </div>

     <footer>
      <%= render 'layouts/footer' %>
     </footer>
    </div>}
end
gsub_file 'app/views/layouts/application.html.erb', /<!-- Grab Google CDN's jQuery[\s\S]*end scripts-->/, '<%= javascript_include_tag "application" %>'

# use rvm
create_file ".rvmrc", "rvm use 1.9.2"

# Need to run here to get rid of error messages during 'generate
# "devise:install"' below.
run "bundle install"

# gems
if yes?("Would you like to install Devise?")
  gem "devise"
  gem "cancan"
  model_name = ask("What would you like your user model be be named? [user]: ")
  model_name = "user" if model_name.blank?

  # authentication and authorization setup
  generate "devise:install"
  generate "devise", model_name
  generate "devise:views"
  generate "cancan:ability"
end

gem "rspec-rails", :group => [:development, :test]
gem "annotate", :group => [:development]
gem "ffaker", :group => [:development]
gem "simplecov", :group => [:development, :test]
gem "rspec-rails", :group => [:development, :test]
gem "webrat", :group => [:test]
gem "spork", :group => [:test]
gem "factory_girl_rails", :group => [:test]

# Run again now to make sure everything's installed for the rake tasks to
# follow.
run "bundle install"

# set up the database
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'
rake "db:migrate"

# Set up testing environment
generate 'rspec:install'


# clean up rails defaults
remove_file "public/index.html"
remove_file "public/images/rails.png"

run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

# git
git :init
git :add => "."
git :commit => "-am 'create initial application'"
say <<-eos
===============================================================================
  Your new Rails application is ready.

  Don't forget to scroll up for important messages from the generators.
eos
