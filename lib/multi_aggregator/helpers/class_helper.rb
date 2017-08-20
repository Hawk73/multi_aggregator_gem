# frozen_string_literal: true

module MultiAggregator
  module ClassHelper
    def class_from_string(str)
      str.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    end

    def camelize(str)
      str.to_s.split('_').collect(&:capitalize).join
    end
  end
end
