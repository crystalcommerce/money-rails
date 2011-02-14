### Money v3 Rails plugin

Money v3 supports rails via `composed_of`, which is what you'll want to use if you just have a couple money fields (see the Money gem's README).

If you have a lot of money fields, it gets very un-DRY (WET?). This plugin helps with that. It doesn't really need to be a plugin, even, it's just nice to document and package things as a unit sometimes.

### Usage

Basic:

    class Widget
      money :price
    end

Slightly more custom:

    class Widget
      money :price, :subunit_column  => 'price_subunit',
                    :currency_column => 'price_currency_string'
    end

Slightly more custom, but all over:

    Money::Rails.config.subunit_column_ext  = 'subunit'
    Money::Rails.config.currency_column_ext = 'currency_string'

    # database values are 'price_subunit' and 'price_currency_string'
    class Widget
      money :price
    end

In all cases:

    w = Widget.new(:price => "5.00")
    w.price # => Money.new(500, 'USD')

If you want to allow nil (see rails' composed_of docs for more info):

    class Widget
      money :price, :allow_nil => true
    end
