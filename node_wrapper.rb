class NodeWrapper
  CLASS_NODES = %i(module class)

  attr_reader :node, :nesting

  def initialize(node, nesting)
    @node = node
    @nesting = nesting
  end

  def parent
    nesting.last(2).first
  end

  def global_scope?
    nesting.size <= 2
  end

  def current_namespace_node(deep_level = 1)
    nesting.reverse.select { |x| x.type == :class || x.type == :module }.first(deep_level).last
  end

  def current_namespace_name
    this_class_name(current_namespace_node)
  end

  # will work only if node is class
  def this_class_name(this_node = node)
    klass_konst, _, _ = *this_node
    source_for(klass_konst)
  end

  def this_class_parent_name
    (node.type == :class && node.to_a[1]) ? source_for(node.to_a[1]) : nil
  end

  def node_value
    node.loc.expression.source.sub(/\A::/, '')
  end

  def class_definition?
    %i[class module const].include?(parent.type)
  end

  private

  def source_for(node)
    node.loc.expression.source
  end
end
