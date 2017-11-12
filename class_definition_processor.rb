require 'parser/current'
require_relative 'ruby_class.rb'
require_relative 'node_wrapper.rb'
require_relative 'const_definition_finder.rb'


class ClassDefinitionProcessor < Parser::AST::Processor
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
    declare_info(NodeWrapper.new(node, @nesting))
    super
  end

  def on_module(node)
    declare_info(NodeWrapper.new(node, @nesting))
    super
  end

  def on_const(node)
    scope = @current_scope.last
    wrapped_node = NodeWrapper.new(node, @nesting)

    unless %i[class const].include?(wrapped_node.parent.type)
      if wrapped_node.current_namespace_node
        if wrapped_node.parent.type == :send && wrapped_node.parent.to_a[1] == :include
          scope.includes << find_or_declare_class(wrapped_node.node_value, scope)
        end
        if wrapped_node.parent.type == :send && wrapped_node.parent.to_a[1] == :extend
          scope.extends << find_or_declare_class(wrapped_node.node_value, scope)
        end
      end
    end
    super
  end

  private

  def declare_info(wrapped_node)
    scope = @current_scope.last
    existed_class = find_existed_class(wrapped_node.current_namespace_name, scope)
    ruby_class = existed_class || RubyClass.new
    parent = find_or_declare_class(wrapped_node.this_class_parent_name, scope)
    ruby_class.set_by_ast_node(wrapped_node, scope, parent)

    scope.constants = (scope.constants << ruby_class).uniq
    parent.constants = (parent.constants << ruby_class).uniq if parent

    @current_scope.push(ruby_class)
    return if existed_class
    @klasses << ruby_class
  end

  def find_or_declare_class(name, scope)
    return unless name
    klass = ConstDefinitionFinder.new(name, scope).call
    return klass if klass

    RubyClass.build_external(name, RubyClass.global_scope).tap do |klass|
      scope.constants = (scope.constants << klass).uniq
      @klasses << klass
    end
  end

  def find_existed_class(name, scope)
    existed_class = scope.constants.find { |klass| klass.name == name }
    existed_class || RubyClass.global_scope.constants.find { |klass| klass.external && (klass.name == name) }
  end
end
