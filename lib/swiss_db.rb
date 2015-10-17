# -*- coding: utf-8 -*-
# SwissDB by jsilverMDX

if defined?(Motion) && defined?(Motion::Project::Config)
  lib_dir_path = File.dirname(File.expand_path(__FILE__))
  Motion::Project::App.setup do |app|
    # unless platform_name == "android"
    #   raise "Sorry, the platform #{platform_name} is not supported by SwissDB"
    # end

    # scans app.files until it finds app/ (the default)
    # if found, it inserts just before those files, otherwise it will insert to
    # the end of the list
    insert_point = app.files.find_index { |file| file =~ /^(?:\.\/)?app\// } || 0

    # change to "swiss_db" for just swiss_db
    Dir.glob(File.join(lib_dir_path, "**/*.rb")).each do |file|
      app.files.insert(insert_point, file)
    end

    # load their schemas folder
    app.files += Dir.glob("schemas/*.rb")

    # puts "APP FILES: #{app.files.inspect}"

  end
end
