require 'spec_helper'

ActiveRecord::Schema.define do
  create_table :products, :force => true do |t|
    t.integer :price_cents
    t.string :price_currency
  end

  create_table :custom_products, :force => true do |t|
    t.integer :price_subunit
    t.string :price_currency_string
  end

  create_table :global_default_products, :force => true do |t|
    t.integer :price_subunit
    t.string :price_currency_string
  end
end

class Product < ActiveRecord::Base
  money :price
end

class ProductAllowingNil < Product
  money :price, :allow_nil => true
end

class CustomProduct < ActiveRecord::Base
  money :price, :subunit_column  => 'price_subunit',
                :currency_column => 'price_currency_string'
end

class GlobalDefaultProduct < ActiveRecord::Base
  money :price
end

describe "Money::Rails' method" do
  subject { Product.create(:price => Money.new(1000, "USD")) }

  describe 'setter' do
    it "sets the subunit attribute" do
      subject.price_cents.should == 1000
    end

    it "sets the currency attribute" do
      subject.price_currency.should == "USD"
    end

    it "accepts a money object" do
      subject = Product.new(:price => Money.new(1000, 'SEK'))
      subject.price.should == Money.new(1000, 'SEK')
    end

    it "accepts a string" do
      subject = Product.new(:price => "5.00")
      subject.price.should == Money.new(500, 'USD')
    end

    it 'does not accept nil by default' do
      lambda { subject.price = nil }.should raise_error
    end

    it 'accepts nil if allowed' do
      subject = ProductAllowingNil.new(:price => Money.new(1000, 'USD'))
      lambda { subject.price = nil }.should_not raise_error
    end
  end

  context "after loading from the db" do
    before { subject.reload }

    it "returns a money object" do
      subject.price.should be_instance_of(Money)
    end
  end

  context "when using custom column options" do
    subject { CustomProduct.create(:price => "5.00") }

    it "uses :subunit_column and :currency_column instead of the defaults" do
      subject.reload
      subject.price.should == Money.new(500)
    end
  end

  context "when using custom column defaults (via Money::Rails.config)" do
    before(:all) do
      Money::Rails.config.subunit_column_ext = 'subunit'
      Money::Rails.config.currency_column_ext = 'currency_string'
    end

    after(:all) do
      Money::Rails.config.subunit_column_ext = nil
      Money::Rails.config.currency_column_ext = nil
    end

    subject { GlobalDefaultProduct.create(:price => "5.00") }

    it "uses config#subunit_column and config#currency_column instead of the defaults" do
      subject.reload
      subject.price.should == Money.new(500)
    end
  end
end

