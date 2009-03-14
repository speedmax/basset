require File.dirname(__FILE__) + '/../spec_helper'

describe Array, "with Basset extensions" do
  
  it "should give the tail of an array like FP lists" do
    [1,2,3].rest.should == [2,3]
  end
  
  it "should not choke when giving the tail of an empty list" do
    [].rest.should == []
  end
  
  it "should return a random element" do
    srand(123456)
    [1,2,3,4].pick_random.should == 2
  end
  
  it "should randomly rearrange itself" do
    srand(123456)
    [1,2,3,4].randomize.should == [1,3,4,2]
  end
  
  it "should sum itself" do
    [1,2,3,4].sum.should == 10
  end
  
end

describe Float, "with Basset extensions" do
  it "should convert itself to a string with variable precsion" do
    1.23456.to_s_decimal_places(3).should == "1.234"
  end
end