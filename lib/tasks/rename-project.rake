
DEFAULT_NAME = 'Rails31Template'
FILES_WITH_NAME = %w{config/application.rb
                     config/environment.rb
                     config/environments/development.rb
                     config/environments/production.rb
                     config/environments/test.rb
                     config/initializers/secret_token.rb
                     config/initializers/session_store.rb
                     config/initializers/session_store.rb
                     config/routes.rb
                     Rakefile}

namespace :template do

  desc %(Set the name of the project in the template's files. This expects the
         new name to be given with the name command-line parameter.)
  task :name do
    name = ENV['name']
    raise "Please supply a name parameter." if name.nil?

    puts "Renaming '#{DEFAULT_NAME}' => '#{name}'"
    re = /#{DEFAULT_NAME}/
    FILES_WITH_NAME.each do |filename|
      lines = File.open(filename, 'r') do |f|
        f.readlines
      end
      File.open(filename, 'w') do |f|
        lines.each do |line|
          f << line.gsub(re, name)
        end
      end
    end
  end

end

