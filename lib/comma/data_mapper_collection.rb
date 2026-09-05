# frozen_string_literal: true

if defined?(DataMapper)
  module DataMapper
    class Collection
      include Comma::CollectionExport
    end
  end
end
