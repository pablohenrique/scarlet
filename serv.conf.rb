require 'json'

# Load a JSON configuration file and use it to manage the server
if File.exist?('conf.json')
	file = File.read('conf.json')
	SERV_CONFIG = JSON.parse(file)
	puts "conf.json loaded successfully"
else
	SERV_CONFIG = {
		'domain'   => 'localhost',
		'port'     => '8888',
		'root_page'=> 'index.html',
		# Files will be served from this directory
		'web_root' => './public',
		# Treat as binary data if content type cannot be found
		'default_content_type' => 'application/octet-stream',
		# Map extensions to their content type
		'content_type_mapping' => {
			'html' => 'text/html',
			'txt'  => 'text/plain',
			'png'  => 'image/png',
			'jpg'  => 'image/jpeg'
		}
	}
	puts "Default configurations in use."
end