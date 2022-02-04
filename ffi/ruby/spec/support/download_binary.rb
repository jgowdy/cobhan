require 'open-uri'

GITHUB_URL = 'https://github.com/jgowdy/cobhan'

def download_binary(lib_root_path, lib_name)
  file_name = Class.new.extend(Cobhan).library_file_name(lib_name)
  lib_path = File.join(lib_root_path, file_name)
  unless File.exist?(lib_path)
    Dir.mkdir(lib_root_path) unless File.exists?(lib_root_path)
    URI.open(lib_path, 'wb') do |file|
      puts "Downloading #{file_name}..."
      file << URI.open("#{GITHUB_URL}/releases/download/current/#{file_name}").read
    end
  end
end

