describe Enumerable do
  it "calls a block in between calling another block for each object via in_between" do
    s = ""
    [1,2,3].in_between{ s << "," }.each do |x|
      s << x.to_s
    end

    s.should == "1,2,3"
  end

  it "allows calling each twice" do
    s = ""
    enum = [1,2,3].in_between{ s << "," }
    enum.each do |x|
      s << x.to_s
    end
    s.should == "1,2,3"
    s << "-"
    enum.each do |x|
      s << (x * 10).to_s
    end
    s.should == "1,2,3-10,20,30"
  end

  it "maps with an index parameter" do
    [1,2,3].map_with_index do |x, i|
      if i % 2 == 0
        :even
      else
        x * 2
      end
    end.should == [:even, 4, :even]
  end
end
