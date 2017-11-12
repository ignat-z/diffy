ruby_class_attributes = [
  :name,
  :constants,
  # :namespaces,
  :includes,
  :extends,
  :inherited_from,
  :type,
  :scope,
  :dependencies
]

# TODO: think about merge [:includes, :extends :prepend] into :inherited_from

class RubyClass < Struct.new(*ruby_class_attributes)
  attr_accessor :external

  def initialize(*)
    super
    self.includes ||= []
    self.extends ||= []
    self.constants ||= []
    self.dependencies ||= []
    self.inherited_from ||= []
    self.external = false
  end

  def self.global_scope
    @@global_scope ||= RubyClass.new.tap do |klass|
      klass.name = "main"
      # klass.namespaces = :no_namespace
      klass.type = :no_type
      klass.scope = :end_of_scope
    end
  end

  def self.build_external(name, scope)
    RubyClass.new.tap do |klass|
      klass.name = name
      klass.scope = scope
      # klass.constants = :external
      # klass.namespaces = scope_hierarchy
      # klass.includes = :external
      # klass.extends = :external
      # klass.inherited_from = :external
      klass.type = :external
      klass.external = true
    end
  end

  def set_by_ast_node(wrapped_node, scope, parent)
    self.name = wrapped_node.this_class_name
    # self.namespaces = wrapped_node.scope_hierarchy
    self.inherited_from = [parent]
    self.type = wrapped_node.node.type
    self.scope = scope
  end
end
