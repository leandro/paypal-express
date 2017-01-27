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

    def as_json
      self.class.readable_attributes.inject({}) do |attrs, attr|
        value = send(attr)
        value = value.is_a?(Array) ? value.map(&method(:json_value)) : json_value(value)
        attrs.update(attr => value)
      end
    end

    def inspect
      pretty_attributes = self.class.readable_attributes.map do |attr|
        value = send(attr)

        if value.kind_of?(::Paypal::Base)
          inspect_output = value.inspect.split("\n").join("\n\t")
        else
          begin
            inspect_output = value.respond_to?(:inspect) ? value.inspect : value
          rescue NoMethodError
            # Sometimes RestClient::Response#inspect can't reach `code`
            # attribute because `net_http_res` is nil in this gem usage,
            # thererefore as nil, it doesn't have `code` method
            inspect_output = value.respond_to?(:body) ? value.body : value
          end
        end

        "\t:%s => %s" % [attr, inspect_output]
      end.join("\n")

      pretty_attributes.insert(0, ?\n) unless pretty_attributes.empty?

      "#<%s readable_attributes=%s>" % [self.class.name, pretty_attributes]
    end

    private

    def json_value(value)
      case value
      when ::Paypal::Base then value.as_json
      when ::RestClient::Response then value.body
      else value
      end
    end
  end
end
