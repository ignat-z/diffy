require_relative 'class_definition_processor.rb'
require_relative 'class_relation_processor.rb'

class GraphBuilder
  def initialize(path)
    @filepaths = path =~ /.rb$/ ? [path] : Dir["#{path}/**/*.rb"]
  end

  def call
    # Graph.new(*graph_nodes(DefinitionsInformation.new(*definitions)))
    classes
    # calls
  end

  private

  def classes
    filepaths.inject([]) do |result, filepath|
      processor = ClassDefinitionProcessor.new
      processor.process(codefile_ast(filepath))
      result + processor.klasses
    end
  end

  def calls
    result_classes = classes
    filepaths.inject([]) do |result, filepath|
      processor = ClassRelationProcessor.new.populate(result_classes)
      processor.process(codefile_ast(filepath))
      # result + processor.klasses
    end
  end

  attr_reader :filepaths

  def definitions # first pass
    filepaths.inject([[], [], {}]) do |summary, filepath|
      klass_definitions, konst_definitions, klass_ancestors = *summary
      processor = ClassDefinitionsProcessor.new
      processor.process(codefile_ast(filepath))
      [
        klass_definitions + processor.klass_definitions,
        konst_definitions + processor.konst_definitions,
        klass_ancestors.merge(processor.klass_ancestors)
      ]
    end
  end

  def graph_nodes(definitions) # second pass
    filepaths.inject([{}, {}]) do |(dependents, klass_ancestors), filepath|
      processor = KlassRelationsProcessor.new.populate(definitions)
      processor.process(codefile_ast(filepath))
      [
        dependents.merge(processor.classes),
        klass_ancestors.merge(processor.klass_ancestors)
      ]
    end
  end

  def codefile_ast(filepath)
    source_code = File.read(filepath)
    Parser::CurrentRuby.parse(source_code)
  end
end
