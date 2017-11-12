require 'parser/current'
require_relative 'ruby_class.rb'
require_relative 'node_wrapper.rb'
require_relative 'const_definition_finder.rb'


class ClassRelationProcessor < Parser::AST::Processor
  CLASS_OR_MODULE = %i(class module)

  attr_accessor :klasses

  def initialize(*)
    super
    @klasses = []
    @nesting = []
    @current_scope = [RubyClass.global_scope]
  end

  def process(node)
    @nesting.push(node)
    super
    node = @nesting.pop
    @current_scope.pop if CLASS_OR_MODULE.include?(node&.type)
  end

  def on_class(node)
    wrapped_node = NodeWrapper.new(node, @nesting)
    scope = @current_scope.last
    @current_scope.push(find_existed_class(wrapped_node.current_namespace_name, scope))
    super
  end

  def on_module(node)
    wrapped_node = NodeWrapper.new(node, @nesting)
    scope = @current_scope.last
    @current_scope.push(find_existed_class(wrapped_node.current_namespace_name, scope))
    super
  end

  def on_const(node)
    scope = @current_scope.last
    wrapped_node = NodeWrapper.new(node, @nesting)
    return if wrapped_node.class_definition?

    ruby_class = find_or_declare_class(wrapped_node.node_value, scope)
    scope.dependencies = (scope.dependencies << ruby_class).uniq

    super
  end

  private

  def find_existed_class(name, scope)
    existed_class = scope.constants.find { |klass| klass.name == name }
    existed_class || RubyClass.global_scope.constants.find { |klass| klass.external && (klass.name == name) }
  end

  def find_or_declare_class(name, scope)
    return unless name
    klass = ConstDefinitionFinder.new(name, scope).call
    return klass if klass

    RubyClass.build_external(name, RubyClass.global_scope).tap do |klass|
      RubyClass.global_scope.constants = (RubyClass.global_scope.constants << klass).uniq
    end
  end
end
