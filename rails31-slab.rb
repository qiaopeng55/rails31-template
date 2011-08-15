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

# Download HTML5 Boilerplate & 960gs stylesheets
get "https://raw.github.com/paulirish/html5-boilerplate/master/css/style.css", "vendor/assets/stylesheets/style.css"
get "http://grids.heroku.com/fluid_grid.css?column_width=60&column_amount=12&gutter_width=20", "vendor/assets/stylesheets/960gs.css"

gsub_file 'vendor/assets/stylesheets/style.css', / \* ==\|== normalize ==========================================================/, ' *'
gsub_file 'app/assets/stylesheets/application.css', / \*= require_self/, " *= require 960gs\n *= require style\n *= require_self\n"

# Get the plugins.js file.
get "https://github.com/paulirish/html5-boilerplate/raw/master/js/plugins.js", "vendor/assets/javascripts/plugins.js"

gsub_file 'app/assets/javascripts/application.js', /\/\/= require_tree \./, "//= require plugins\n//= require_tree .\n"

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
  "<%= stylesheet_link_tag \"application\" %>"
end

gsub_file 'app/views/layouts/application.html.erb', /<script src="js\/libs\/modernizr-2.0.6.min.js"><\/script>/, '<%= javascript_include_tag "modernizr" %>'
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

# gems
if yes?("Would you like to install Devise?")
  gem "devise"
  gem "cancan"

  # Need to run here to get rid of error messages during 'generate
  # "devise:install"' below.
  run "bundle install --without production"

  model_name = ask("What would you like your user model be be named? [user]: ")
  model_name = "user" if model_name.blank?

  # authentication and authorization setup
  generate "devise:install"
  generate "devise", model_name
  generate "devise:views"
  generate "cancan:ability"
end

gem 'modernizr-rails'

gem "rspec-rails", :group => [:development, :test]
# We're pulling this until this issue gets worked out:
# https://github.com/ctran/annotate_models/issues/28
# gem "annotate", :group => [:development]
gem "ffaker", :group => [:development]
gem "simplecov", :group => [:development, :test]
gem "rspec-rails", :group => [:development, :test]
gem "webrat", :group => [:test]
gem "spork", :group => [:test]
gem "factory_girl_rails", :group => [:test]

if yes?("Will you deploy to Heroku (http://www.heroku.com/) [y/n]?")
  append_to_file 'Gemfile', "\n# Gems for deploying to Heroku.\n"
  gem 'therubyracer-heroku', :group => [:production]
  gem 'pg', :group => [:production]
  append_to_file 'Gemfile', "\n"
end

# Run again now to make sure everything's installed for the rake tasks to
# follow.
run "bundle install --without production"

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
