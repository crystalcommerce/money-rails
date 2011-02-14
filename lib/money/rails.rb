class Money
  module Rails
    def self.config
      @config ||= Struct.new(:subunit_column_ext, :currency_column_ext).new
    end

    module ClassMethods
      def money(method_name, options = {})
        defaluts = {
          :allow_nil       => false,
          :subunit_column  =>
            "#{method_name}_#{Money::Rails.config.subunit_column_ext || 'cents'}",
          :currency_column =>
            "#{method_name}_#{Money::Rails.config.currency_column_ext || 'currency'}" }
        options = defaluts.merge(options)

        composed_of(method_name,
          :class_name => "Money",
          :allow_nil => options[:allow_nil],
          :mapping => [ [options[:subunit_column],  "cents"],
                        [options[:currency_column], "currency_as_string"] ],
          :constructor => Proc.new { |cents, currency|
            Money.new(cents || 0, currency || Money.default_currency)
          },
          :converter => Proc.new { |value|
            if value.respond_to?(:to_money)
              value.to_money
            else
              raise(ArgumentError, "Can't convert #{value.class} to Money")
            end
          })
      end
    end
  end
end

ActiveRecord::Base.extend(Money::Rails::ClassMethods)
