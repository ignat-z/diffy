require_relative './class_definition_processor'
require_relative './class_relation_processor'

class GraphBuilder
  def initialize(ast_objects)
    RubyClass.rebuid_global_scope # TODO: remove this and make global scope non-class-variable
    @ast_objects = ast_objects
  end

  def call
    definitions.tap do |klasses|
      calls(klasses)
    end
  end

  private

  attr_reader :ast_objects

  def definitions
    ast_objects.inject([]) do |result, ast|
      processor = ClassDefinitionProcessor.new
      processor.klasses = result
      processor.process(ast)
      processor.klasses
    end
  end

  def calls(klasses)
    ast_objects.each do |ast|
      processor = ClassRelationProcessor.new
      processor.klasses = klasses
      processor.process(ast)
    end
  end
end
