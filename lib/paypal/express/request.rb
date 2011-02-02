module Paypal
  module Express
    class Request < NVP::Request
      attr_required :return_url, :cancel_url

      def initialize(attributes = {})
        @return_url = attributes[:return_url]
        @cancel_url = attributes[:cancel_url]
        super
      end

      def setup(payment_requests)
        params = {
          :RETURNURL => self.return_url,
          :CANCELURL => self.cancel_url
        }
        Array(payment_requests).each_with_index do |payment_request, index|
          params.merge! payment_request.to_params(index)
        end
        response = self.request :SetExpressCheckout, params
        Response.new response
      end

      def details(token)
        response = self.request :GetExpressCheckoutDetails, {:TOKEN => token}
        Response.new response
      end

      def checkout(token, payer_id, payment_requests)
        params = {
          :TOKEN => token,
          :PAYERID => payer_id
        }
        Array(payment_requests).each_with_index do |payment_request, index|
          params.merge! payment_request.to_params(index)
        end
        response = self.request :DoExpressCheckoutPayment, params
        Response.new response
      end

    end
  end
end