module Montrose
  module Refinements
    module ArrayConcat
      refine Object do
        def array_concat(other)
          Array(self) + other
        end
      end
    end
  end
end
