class NodeWrapper
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

  # TODO: move to private
  def source_for(node)
    node.loc.expression.source
  end

  # module A::B; module C; module D; end; end; end # <- first nesting level
  #              module C; module D; end; end;     # <- second nesting level
  #                        module D; end;          # <- third nesting level
  #
  # @return: [[:A, :B], [:C], [:D]]
  def module_hierarchy
    (nesting - [current_namespace_node])
      .select { |node| node.type == :module }
      .map { |subnode| construct_hierarchy(subnode) }
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

  private

  # Source code: module A::B; end
  # AST: s(:module, s(:const, s(:const, nil, :A), :B), nil)
  # @return: [:A, :B]
  def construct_hierarchy(node)
    konstants, _body = *node
    hierarchy = []
    current_node = konstants
    loop do
      submodule, _konst = *current_node
      hierarchy << source_for(current_node)
      break if submodule.nil?
      current_node = submodule
    end
    # hierarchy.reverse
    # HOTFIX
    hierarchy.reverse.last(1)
  end
end
