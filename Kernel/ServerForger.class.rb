require 'json'

class ServerForger
  private
    @default_folder
    @default_json
    @server_config = {}

  public
    def initialize(address = 'localhost', port = nil)
      @default_folder = '../app/'
      @default_json = 'conf.json'
      load_server(address, port)
    end


    def get_server
      return @server_config
    end

    def load_server(address = 'localhost', port = nil)
      set_server(address, port)
      set_server_defaults
    end

    def set_server (address = 'localhost', port = nil)
      if !File.directory?(@default_json) && File.exist?(@default_json)
        @server_config = JSON.parse( File.read(@default_json) )

      elsif File.directory?(@default_folder) && port
        @server_config = {
            'domain'   => address,
            'port'     => port,
            # Files will be served from this directory
            'root_folder' => @default_folder
        }
      end
    end


    def content_type(path)
      ext = File.extname(path).split('.').last
      self.get_server['content_type_mapping'].fetch(ext, @server_config['default_content_type'])
    end



    # This helper function parses the Request-Line and
    # generates a path to a file on the server.
    def requested_file(request_line)
      request_uri  = request_line.split(' ')[1]
      path         = URI.unescape(URI(request_uri).path)

      clean = []

      # Split the path into components
      parts = path.split('/')

      parts.each do |part|
        # skip any empty or current directory (".") path components
        next if part.empty? || part == '.'
        # If the path component goes up one directory level (".."),
        # remove the last clean component.
        # Otherwise, add the component to the Array of clean components
        part == '..' ? clean.pop : clean << part
      end

      # return the web root joined to the clean path
      File.join(self.get_server['root_folder'], *clean)
    end

  private
    def set_server_defaults
      ( File.directory?(self.get_server['root_folder']) && File.exist?(self.get_server['root_folder'] + '/index.html') ) ?
          self.get_server['root_page'] = 'index.html' :
          self.get_server['root_page'] =
              '<html>' +
              '<head>' +
              '  <title>Scarlet</title>' +
              '</head>' +
              '<body>' +
              '  <h1>Scarlet: 200 OK </h1>' +
              '  <h2>Scarlet is running smoothly. Good job, mate. </h2>' +
              '</body>' +
              '</html>'

      if self.get_server['default_content_type'] == nil
        #Treat as binary data if content type cannot be found
        self.get_server['default_content_type'] = 'application/octet-stream'
      end
      if self.get_server['content_type_mapping'] == nil
        #Map extensions to their content type
        self.get_server['content_type_mapping'] = {
            'html' => 'text/html',
            'txt'  => 'text/plain',
            'png'  => 'image/png',
            'jpg'  => 'image/jpeg'
        }
      end
      if self.get_server['default_error_page'] == nil
        self.get_server['default_error_page'] =
            '<html>' +
                '<head>' +
                '  <title>404 Not Found </title>' +
                '</head>' +
                '<body>' +
                '  <h1>Scarlet: 404 Not Found </h1>' +
                '  <h2> ' +
                '    Could you please try to access that file again later? <br/>' +
                '    Our minions are fixing the issue. No worries. <br/>' +
                '    Soon everything is gonna be fine.' +
                '  </h2>' +
                '  <h6> ~Whisper~ <b>Scarlet</b>: <i> "Minions, block this IP..." </i></h6>' +
                '</body>' +
                '</html>'
      end
    end

end