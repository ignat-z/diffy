class G
end

module F; end

module H
  extend F
end

module A
  module B::D
    class C < OuterClass
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



module D1
  F1 = 45
end

module A1
  include D1
  class B1
    K1 = 123
  end
end

module C1
  include A1

  B1::K1
  F1
  def call
    B1::K1
    F1
  end

  class E1 < A1::B1
    
  end
end

# module Inc
  
# end


# module A
#   class B
#   end
# end

# module A
#   class C
#     include Inc

#     def call
#       B.new
#     end
#   end
# end
