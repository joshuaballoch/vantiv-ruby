require 'erb'
require 'webrick'
require 'vantiv-ruby'

module Vantiv
  class TestPaypageServer
    def initialize(threaded: true)
      @threaded = threaded
      @template = "#{Vantiv.root}/spec/support/e-protect/index.html.erb"
      @static_file_dir = "#{Vantiv.root}/tmp/e-protect"
    end

    def start
      if threaded
        @server_thread = Thread.new { start_server }
      else
        start_server
      end
    end

    def root_path
      "http://localhost:#{port}"
    end

    def stop
      threaded ? Thread.kill(server_thread) : stop_server
    end

    private

    attr_accessor :server, :server_thread, :threaded

    def document_root
      File.expand_path "#{static_file_dir}"
    end

    def port
      8000
    end

    def start_server
      compile_template
      server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => document_root
      trap('INT') { server.shutdown }
      server.start
    end

    def stop_server
      server.shutdown
    end

    def static_file_dir
      unless File.directory?(@static_file_dir)
        FileUtils.mkdir_p(@static_file_dir)
      end
      @static_file_dir
    end

    def compile_template
      template = File.open(@template)
      File.open("#{static_file_dir}/index.html", "w") do |f|
        renderer = ERB.new(template.read)
        f << renderer.result()
      end
    end
  end
end

