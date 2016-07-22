require 'rails5/spec_converter/text_transformer'
require 'rails5/spec_converter/version'
require 'optparse'

module Rails5
  module SpecConverter
    class CLI
      def initialize
        @options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: rails5-spec-converter [options] [files]"

          opts.on("--version", "Print version number") do |q|
            puts Rails5::SpecConverter::VERSION
            exit
          end

          opts.on("-q", "--quiet", "Run quietly") do |q|
            @options[:quiet] = q
          end

          opts.on("-i", "--indent INDENT", "Use specified string for indentation (default is two spaces)") do |indent|
            @options[:indent] = indent.gsub("\\t", "\t")
          end
        end.parse!

        @files = ARGV
      end

      def run
        paths = @files.length > 0 ? @files : ["spec/**/*_spec.rb"]

        paths.each do |path|
          Dir.glob(path) do |file_path|
            log "Processing: #{file_path}"

            original_content = File.read(file_path)
            transformed_content = Rails5::SpecConverter::TextTransformer.new(original_content, @options).transform
            File.write(file_path, transformed_content)
          end
        end
      end

      def log(str)
        return if @options[:quiet]

        puts str
      end
    end
  end
end