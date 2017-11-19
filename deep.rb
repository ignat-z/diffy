class GraphTraverse
  def initialize(graph)
    @graph = graph
  end

  def traverse(nodes:, nesting: 3)
    nesting_level_nodes = nodes

    # do not need to store all relation, because we are only interested in
    # all connections of this node and will receive it from whole graph
    related_nodes = []

    while nesting > 0 do
      new_level_nodes = []
      nesting -= 1
      @graph.each do |(k ,v)|
        if nesting_level_nodes.include?(k)
          related_nodes   << k  # how we are here (by key)
          related_nodes   << v  # key -> value, going right (to value)
          new_level_nodes << v  # where we need to watch next iteration
        end
        if nesting_level_nodes.include?(v)
          related_nodes   << v  # how we are here (by value)
          related_nodes   << k  # key -> value, going left  (to key)
          new_level_nodes << k  # where we need to watch next iteration
        end
      end
      nesting_level_nodes = new_level_nodes
    end
    related_nodes = related_nodes.uniq.sort
    @graph.select { |k,_v| related_nodes.include?(k) }
  end
end

# require "minitest/autorun"
# require "minitest/pride"

# describe GraphTraverse do
#   subject { GraphTraverse.new(graph) }

#   let(:graph) do
#     [
#       %i[a c],
#       %i[a b],
#         %i[b d],
#         %i[b e],
#                  %i[d e], %i[d j],
#                    %i[e m],
#                    %i[e f],
#                      %i[f g],
#                        %i[g h],

#       %i[x1 x2],
#          %i[x2 l], %i[x2 x3],
#             %i[l k],
#     ]
#   end

#   let(:graph_v2) do
#     {
#       'a'  => ['c', 'b'],
#       'b'  => ['d', 'e'],
#       'c'  => [],
#       'd'  => ['e', 'j'],
#       'e'  => ['m', 'f'],
#       'f'  => ['g'],
#       'g'  => ['h'],
#       'x1' => ['x2'],
#       'x2' => ['l', 'x3'],
#       'l'  => ['l', 'k']
#     }
#   end
# #       x3
# #        ^
# # x1 -> x2 -> [l] -> k
# #

# #
# #   -> c
# #  /
# # a -> b ->[d] -> j
# #       \   v
# #        -->e -> f -> g -> h
# #           v
# #           m

#   let(:one_level_nesting) do
#     [[:b, :d], [:b, :e], [:d, :e], [:d, :j], [:e, :f], [:e, :m], [:l, :k], [:x2, :l], [:x2, :x3]]
#   end
#   let(:two_levels_nesting) do
#     [[:a, :b], [:a, :c], [:b, :d], [:b, :e], [:d, :e], [:d, :j], [:e, :f], [:e, :m], [:f, :g], [:l, :k], [:x1, :x2], [:x2, :l], [:x2, :x3]]
#   end
#   let(:isolated_nesting) do
#     [[:l, :k], [:x1, :x2], [:x2, :l], [:x2, :x3]]
#   end

#   it 'returns all nodes by one level backward and forward' do
#     assert_equal(one_level_nesting.sort,
#       subject.traverse(nodes: [:d, :l], nesting: 1).uniq.sort)
#   end

#   it 'returns all nodes by two levels backward and forward' do
#     assert_equal(two_levels_nesting.sort,
#       subject.traverse(nodes: [:d, :l], nesting: 2).uniq.sort)
#   end

#   it 'returns all nodes by two levels backward and forward in isolated part' do
#     assert_equal(isolated_nesting.sort,
#       subject.traverse(nodes: [:l, :k], nesting: 2).uniq.sort)
#   end
# end
