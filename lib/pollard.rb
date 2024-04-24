require 'csv'
require 'json'
require 'fileutils'

TOKEN_FILE  = './.token.json'
SECRETS     = JSON.parse File.read('./.secrets.json')
OUTPUT_DIR  = "./data/out/#{DateTime.now.strftime("%Y-%m-%d")}"

FileUtils.mkdir_p OUTPUT_DIR


