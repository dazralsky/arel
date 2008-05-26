require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Expression do
    before do
      @relation = Table.new(:users)
      @attribute = @relation[:id]
    end

    describe Expression::Transformations do
      before do
        @expression = Count.new(@attribute)
      end

      describe '#bind' do
        it "manufactures an attribute with a rebound relation and self as the ancestor" do
          derived_relation = @relation.where(@relation[:id].eq(1))
          @expression.bind(derived_relation).should == Count.new(@attribute.bind(derived_relation), nil, @expression)
        end

        it "returns self if the substituting to the same relation" do
          @expression.bind(@relation).should == @expression
        end
      end

      describe '#as' do
        it "manufactures an aliased expression" do
          @expression.as(:alias).should == Expression.new(@attribute, :alias, @expression)
        end
      end

      describe '#to_attribute' do
        it "manufactures an attribute with the expression as an ancestor" do
          @expression.to_attribute.should == Attribute.new(@expression.relation, @expression.alias, :ancestor => @expression)
        end
      end
    end

    describe '#to_sql' do
      it "manufactures sql with the expression and alias" do
        sql = Count.new(@attribute, :alias).to_sql

        adapter_is :mysql do
          sql.should be_like(%Q{COUNT(`users`.`id`) AS `alias`})
        end

        adapter_is_not :mysql do
          sql.should be_like(%Q{COUNT("users"."id") AS "alias"})
        end
      end
    end
  end
end