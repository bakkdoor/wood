describe String do
  it "returns a snake-cased version of self" do
    "FooBar".snake_cased.should == "foo_bar"
    "Foobar".snake_cased.should == "foobar"
    "fooBar".snake_cased.should == "foo_bar"
    "HelloWorld-Yo".snake_cased.should == "hello_world_yo"
  end

  it "returns a camel-cased version of self" do
    "foo_bar".camel_cased.should == "FooBar"
    "foo_bar_baz".camel_cased.should == "FooBarBaz"
    "foo_Bar".camel_cased.should == "FooBar"
  end

  it "returns true if it is capitalized" do
    "".capitalized?.should be_falsey
    "foo".capitalized?.should be_falsey
    "fFoo".capitalized?.should be_falsey

    "_".capitalized?.should be_truthy
    "F".capitalized?.should be_truthy
    "Foo".capitalized?.should be_truthy
    "FFoo".capitalized?.should be_truthy
  end
end
