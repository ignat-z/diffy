require_relative 'class_definition_processor.rb'
require_relative 'class_relation_processor.rb'

class GraphBuilder
  def initialize(path)
    @filepaths = path =~ /.rb$/ ? [path] : Dir["#{path}/**/*.rb"]
  end

  def call
    definitions.tap do |klasses|
      calls(klasses)
    end
  end

  private

  attr_reader :filepaths

  def definitions
    filepaths.inject([]) do |result, filepath|
      processor = ClassDefinitionProcessor.new
      processor.klasses = result
      processor.process(codefile_ast(filepath))
      processor.klasses
    end
  end

  def calls(klasses)
    filepaths.each do |filepath|
      processor = ClassRelationProcessor.new
      processor.klasses = klasses
      processor.process(codefile_ast(filepath))
    end
  end

  def codefile_ast(filepath)
    source_code = File.read(filepath)
    Parser::CurrentRuby.parse(source_code)
  end
end
