require 'open-uri'

def download_binary(lib_root_path, lib_name)
  file_name = Class.new.extend(Cobhan).library_file_name(lib_name)
  lib_path = File.join(lib_root_path, file_name)
  unless File.exists?(lib_path)
    URI.open(lib_path, 'wb') do |file|
      puts "Downloading #{file_name}..."
      file << URI.open("https://github.com/jgowdy/cobhan/releases/download/current/#{file_name}").read
    end
  end
end

