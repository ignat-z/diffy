# require 'parser/current'



# module HierarchyConstructible
#   include AST::Sexp

#   private

#   def with_nesting(node)
#     @nesting ||= []
#     @nesting.push(node)
#     yield
#     @nesting.pop
#   end

#   # module A::B; module C; module D; end; end; end
#   # @return: 'A::B::C::D'
#   def constract_klass(node)
#     (module_hierarchy + construct_hierarchy(node)).flatten.join('::')
#   end

#   # module A::B; module C; module D; end; end; end # <- first nesting level
#   #              module C; module D; end; end;     # <- second nesting level
#   #                        module D; end;          # <- third nesting level
#   #
#   # @return: [[:A, :B], [:C], [:D]]
#   def module_hierarchy
#     @nesting
#       .select { |node| node.type == :module }
#       .map { |subnode| construct_hierarchy(subnode) }
#   end

#   # Source code: module A::B; end
#   # AST: s(:module, s(:const, s(:const, nil, :A), :B), nil)
#   # @return: [:A, :B]
#   def construct_hierarchy(node)
#     konstants, _body = *node
#     hierarchy = []
#     current_node = konstants
#     loop do
#       submodule, konst = *current_node
#       hierarchy << konst
#       break if submodule.nil?
#       current_node = submodule
#     end
#     hierarchy.reverse
#   end
# end







# class ClassRelationProcessor < Parser::AST::Processor
#   include HierarchyConstructible

#   BLACK_LIST = %w[
#     Rails Date OpenStruct Roo::Excelx JobSpawner ActiveRecord::Base
#   ].freeze

#   attr_accessor :classes, :all_klasses, :all_konsts, :klass_ancestors
#   def initialize(*)
#     super
#     @classes = {}
#     @current_klass = nil
#   end

#   def populate(classes)
#     binding.pry
#     @classes = classes
#     self
#   end

#   # def populate(definitions)
#   #   @all_klasses = definitions.klass_definitions
#   #   @all_konsts = definitions.konst_definitions
#   #   # @klass_ancestors = definitions.klass_ancestors
#   #   self
#   # end

#   def process(node)
#     with_nesting(node) { super }
#   end

#   # def on_class(node)
#   #   _klass, ancestor, _body = *node
#   #   @current_klass = constract_klass(node)

#   #   if ancestor
#   #     ancestor_klass = ancestor.loc.expression.source
#   #     @klass_ancestors[@current_klass] =
#   #       resolve_with_namespace(ancestor_klass) || ancestor_klass
#   #   end
#   #   super
#   # end

#   def on_const(node)
#     klass = node.loc.expression.source.sub(/\A::/, '')
#     return if klass_definition? || whitelisted_klass?(klass)
#     binding.pry
#     # unless klass_definition? || whitelisted_klass?(klass) || @current_klass.nil?
#     #   resolve_const = resolve_with_namespace(klass, from: all_konsts)
#     #   if resolve_const.nil? # do not want to show simple constants
#     #     result_klass = resolve_with_namespace(klass) || klass
#     #     (@classes[@current_klass] ||= []) << result_klass
#     #   end
#     # end
#     super
#   end

#   private

#   def whitelisted_klass?(klass)
#     BLACK_LIST.include?(klass) || Object.const_defined?(klass)
#   end

#   # class A; end      #=> s(`:class`, s(:const, nil, :A), nil, nil)
#   # module A; end     #=> s(`:module`, s(:const, nil, :A), nil)
#   # module A::B; end  #=> s(:module, s(`:const`, s(:const, nil, :A), :B), nil)
#   # s(:const, nil, :A) <-- current node
#   def klass_definition?
#     %i[class module const].include?(parent.type)
#   end

#   # module A  # <- parent node, pre last in nesting
#   #   class B # <- current mode, last in nesting
#   #   end
#   # end
#   def parent
#     @nesting.last(2).first
#   end

#   # Trying to find constant/class with all possible namespaces in already
#   # defined constants/classes
#   # Will return class full path or nil
#   def resolve_with_namespace(klass, from: all_klasses)
#     build_potential_ancestors
#       .map { |namespace| [namespace, klass].compact.join('::') }
#       .find { |pottential_klass| from.include?(pottential_klass) }
#   end

#   # module Out
#   #   module B::C
#   #     class D
#   #       def call
#   #         E.new
#   #       end
#   #     end
#   #   end
#   # end
#   # Potential ancestors: B::C, B::C::D, none of them
#   # Ignores inheritance, classes aliases and modules including
#   def build_potential_ancestors
#     module_hierarchy.inject([]) do |result, current|
#       result + [[result.last, current].compact.join('::')]
#     end.reverse + ['']
#   end
# end
