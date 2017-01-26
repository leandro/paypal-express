module TrackableAttributes
  extend ActiveSupport::Concern

  class_methods do
    def attr_reader(*params)
      @attr_readers ||= []
      @attr_readers.concat(params).uniq!
      super(*params)
    end

    def attr_writer(*params)
      @attr_writers ||= []
      @attr_writers.concat(params).uniq!
      super(*params)
    end

    def attr_accessor(*params)
      @attr_accessors ||= []
      @attr_accessors.concat(params).uniq!
      super(*params)
    end

    def readable_attributes
      attr_accessors + attr_readers
    end

    def attr_readers
      attributes_of_self_and_ancestors_for(__method__)
    end

    def attr_writers
      attributes_of_self_and_ancestors_for(__method__)
    end

    def attr_accessors
      attributes_of_self_and_ancestors_for(__method__)
    end

    private

    def attributes_of_self_and_ancestors_for(method)
      if instance_variable_defined?("@#{method}")
        class_attributes = instance_variable_get("@#{method}")
      else
        class_attributes = []
      end

      ancestors_attributes = []
      superklass = self

      while (superklass = superklass.superclass).respond_to?(method)
        if superklass.instance_variable_defined?("@#{method}")
          ancestors_attributes.concat(superklass.instance_variable_get("@#{method}"))
        end
      end

      (ancestors_attributes + class_attributes).uniq
    end
  end
end
