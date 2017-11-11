require 'parser/current'
require_relative 'ruby_class.rb'
require_relative 'node_wrapper.rb'
require_relative 'const_definition_finder.rb'


class ClassDefinitionProcessor < Parser::AST::Processor
  attr_reader :klasses, :klass_dependencies

  def initialize(*)
    super
    @klasses = []
    @nesting = []
  end

  def process(node)
    @nesting.push(node)
    super
    @nesting.pop
  end

  def on_class(node)
    declare_info(NodeWrapper.new(node, @nesting))
    super
  end

  def on_module(node)
    declare_info(NodeWrapper.new(node, @nesting))
    super
  end

  def declare_info(wrapped_node)
    ruby_class = find_in_klasses(wrapped_node) || RubyClass.new
    scope = wrapped_node.global_scope? ? RubyClass.global_scope : find_scope_declaration(wrapped_node)
    parent = ConstDefinitionFinder.new(wrapped_node.this_class_parent_name, scope).call
    ruby_class.build_by_ast_node(wrapped_node, scope, parent)

    return if find_in_klasses(wrapped_node)

    @klasses << ruby_class
    scope.constants << ruby_class

    # TODO: check for redefining
    # parent.constants << ruby_class
  end

  def find_scope_declaration(wrapped_node)

    # TODO: check not only module, but also a classes
    *namespaces, scope = wrapped_node.module_hierarchy
    find_in_klasses_by_name_and_namespaces(scope.join("::"), namespaces)
  end

  def on_const(node)
    wrapped_node = NodeWrapper.new(node, @nesting)

    unless %i[class const].include?(wrapped_node.parent.type)
      if wrapped_node.current_namespace_node
        if wrapped_node.parent.type == :send && wrapped_node.parent.to_a[1] == :include
          klass = find_in_klasses(wrapped_node)
          # klass.includes << find_declaration(wrapped_node, klass)
        end
        if wrapped_node.parent.type == :send && wrapped_node.parent.to_a[1] == :extend
          klass = find_in_klasses(wrapped_node)
          # klass.extends << find_declaration(wrapped_node, klass)
        end
      end
    end
    super
  end

  def source_for(node)
    node.loc.expression.source
  end

  def find_in_klasses(wrapped_node)
    name = wrapped_node.current_namespace_name
    namespaces = wrapped_node.module_hierarchy
    find_in_klasses_by_name_and_namespaces(name, namespaces)
  end

  def find_in_klasses_by_name_and_namespaces(name, namespaces)
    @klasses.find { |x| x.name == name && x.namespaces == namespaces }
  end

  def find_declaration(wrapped_node, current_ruby_class)
    ConstDefinitionFinder.new(wrapped_node.node_value, current_ruby_class).call
  end
end
