module TrackableAttributes
  extend ActiveSupport::Concern

  included do
    define_singleton_method(:attr_reader) do |*params|
      @attr_readers ||= []
      @attr_readers.concat(params).uniq!
      super(*params)
    end

    define_singleton_method(:attr_writer) do |*params|
      @attr_writers ||= []
      @attr_writers.concat(params).uniq!
      super(*params)
    end

    define_singleton_method(:attr_accessor) do |*params|
      @attr_accessors ||= []
      @attr_accessors.concat(params).uniq!
      super(*params)
    end
  end

  def readable_attributes
    attr_accessors + attr_readers
  end

  def attr_readers
    self.class.instance_variable_get('@attr_readers') || []
  end

  def attr_writers
    self.class.instance_variable_get('@attr_writers') || []
  end

  def attr_accessors
    self.class.instance_variable_get('@attr_accessors') || []
  end
end
