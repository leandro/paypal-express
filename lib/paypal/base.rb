module Paypal
  class Base
    include TrackableAttributes
    include AttrRequired, AttrOptional, Util

    def initialize(attributes = {})
      if attributes.is_a?(Hash)
        (required_attributes + optional_attributes).each do |key|
          value = if numeric_attribute?(key)
            Util.to_numeric(attributes[key])
          else
            attributes[key]
          end
          self.send "#{key}=", value
        end
      end
      attr_missing!
    end

    def to_h
      readable_attributes.inject({}) do |attrs, attr|
        value = send(attr)
        attrs.update(attr => value.kind_of?(::Paypal::Base) ? value.to_h : value)
      end
    end

    def inspect
      pretty_attributes = readable_attributes.map do |attr|
        value = send(attr)

        if value.kind_of?(::Paypal::Base)
          inspect_output = value.inspect.split("\n").join("\n\t")
        else
          inspect_output = value.respond_to?(:inspect) ? value.inspect : value
        end

        "\t:%s => %s" % [attr, inspect_output]
      end.join("\n")

      "#<%s readable_attributes=\n%s>" % [self.class.name, pretty_attributes]
    end
  end
end
