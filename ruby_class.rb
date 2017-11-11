ruby_class_attributes = [
  :name,
  :constants,
  :namespaces,
  :includes,
  :extends,
  :inherited_from,
  :type,
  :scope,
]

# TODO: think about merge [:includes, :extends :prepend] into :inherited_from

class RubyClass < Struct.new(*ruby_class_attributes)
  def self.build_global_scope
    scope = RubyClass.new("main", [], :no_namespace, [], [], [], :no_type, :end_of_scope)
    # scope.scope = scope
  end

  def self.global_scope
    @@global_scope ||= build_global_scope
  end

  def self.build_external(name, scope)
    RubyClass.new(name, :external, :external, :external, :external, :external, :external, scope)
  end

  def build_by_ast_node(wrapped_node, scope, parent)
    self.name = wrapped_node.this_class_name
    self.namespaces = wrapped_node.module_hierarchy
    self.inherited_from = [parent]
    self.type = wrapped_node.node.type
    self.scope = scope

    self.includes ||= []
    self.extends ||= []
    self.constants ||= []
  end
end
