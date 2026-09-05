# frozen_string_literal: true

# Defines an anonymous class for use in a single example, avoiding
# constants leaking into the global namespace across the spec suite.
# Pass `base` to build on a superclass (e.g. a Struct).
#
#   book_class = define_comma_class(Struct.new(:title)) do
#     comma { title }
#   end
def define_comma_class(base = Object, &block)
  Class.new(base, &block)
end
