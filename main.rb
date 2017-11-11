require_relative 'graph_renderer.rb'
require 'parser/current'

RubyClass = Class.new(
  Struct.new(
    :name,
    :namespaces,
    :includes,
    :extends,
    :inherited_from,
    :type
  )
)

class RubyClassDefinitionsProcessor < Parser::AST::Processor
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
    declare_info(node)
    super
  end

  def on_module(node)
    declare_info(node)
    super
  end

  def declare_info(node)
    ruby_class = find_in_klasses(node) || RubyClass.new
    ruby_class.name = klass_name_for(node)
    ruby_class.namespaces = module_hierarchy
    ruby_class.inherited_from = source_for(node.to_a[1]) if node.type == :class && node.to_a[1]
    ruby_class.type = node.type
    @klasses << ruby_class unless find_in_klasses(node)
  end

  def on_const(node)
    unless %i[class const].include?(parent.type)
      konst_name = source_for(node)
      if context_klass
        if parent.type == :send && parent.to_a[1] == :include
          klass = find_in_klasses(node)
          klass.includes ||= []
          klass.includes << source_for(node)
        end
        if parent.type == :send && parent.to_a[1] == :extend
          klass = find_in_klasses(node)
          klass.extends ||= []
          klass.extends << source_for(node)
        end
      end
    end
    super
  end

  def parent
    @nesting.last(2).first
  end

  def context_klass
    @nesting.reverse.select { |x| x.type == :class || x.type == :module }.first
  end

  def klass_name_for(node)
    klass_konst, _, _ = *node
    source_for(klass_konst)
  end

  def source_for(node)
    node.loc.expression.source
  end


  def find_in_klasses(node)
    name = klass_name_for(context_klass)
    namespaces = module_hierarchy
    @klasses.find { |x| x.name == name && x.namespaces == namespaces }
  end


  # module A::B; module C; module D; end; end; end # <- first nesting level
  #              module C; module D; end; end;     # <- second nesting level
  #                        module D; end;          # <- third nesting level
  #
  # @return: [[:A, :B], [:C], [:D]]
  def module_hierarchy
    (@nesting - [context_klass])
      .select { |node| node.type == :module }
      .map { |subnode| construct_hierarchy(subnode) }
  end

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
    hierarchy.reverse
  end
end

source_code = <<RUBY
class G
end

module F; end

module H
  extend F
end

module A
  module B::D
    class C
      J = 27
      include F
      include H
    end
  end
end

module A
  class D
    def call
      B::C.new
    end
  end
end

class E < G
  def call
    A::B::C.new
  end
end
RUBY

ast = Parser::CurrentRuby.parse(source_code)
processor = RubyClassDefinitionsProcessor.new
processor.process(ast)
processor.klasses.sort_by(&:name).each do |ruby_class|
  puts [
                ruby_class.type.to_s.center(6),
                ruby_class.namespaces.to_s.center(50),
                ruby_class.name.center(20),
    '<',       (ruby_class.inherited_from || '""').to_s.center(20),
    'include', (ruby_class.includes       || '[]').to_s.center(10),
    'extend',  (ruby_class.extends        || '[]').to_s.center(10)
  ].join
end

# puts GraphRenderer.new(processor.klass_dependencies, processor.klasses).call
