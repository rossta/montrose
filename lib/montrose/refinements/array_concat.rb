# frozen_string_literal: true
module Montrose
  module Refinements
    module ArrayConcat
      refine Object do
        def array_concat(other)
          Array(self) + other
        end
      end

      refine Hash do
        # array concat for Hash not supported
        # so we just return self
        def array_concat(_other)
          self
        end
      end
    end
  end
end
