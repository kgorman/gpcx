module Jekyll
  module ReadFileFilter
    def read_file(input)
      return "" if input.nil? || input.empty?
      
      # Handle both absolute and relative paths
      file_path = if input.start_with?('/')
        File.join(@context.registers[:site].source, input)
      else
        File.join(@context.registers[:site].source, input)
      end
      
      if File.exist?(file_path) && File.file?(file_path)
        File.read(file_path).strip
      else
        ""
      end
    rescue => e
      ""
    end
  end
end

Liquid::Template.register_filter(Jekyll::ReadFileFilter)
