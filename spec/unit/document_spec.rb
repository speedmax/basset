require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Document do
  it "should remove punctuation from words" do
    Document.new("abc.").vector_of_features.should == [Feature.new("abc", 1)]
  end
  
  it "should remove numbers from words" do
    Document.new("abc1").vector_of_features.should == [Feature.new("abc", 1)]
  end
  
  it "should remove symbols from words" do
    Document.new("abc%").vector_of_features.should == [Feature.new("abc", 1)]
  end
  
  it "should lowercase text" do
    Document.new("ABC").vector_of_features.should == [Feature.new("abc", 1)]
  end
  
  it "should stem words" do
    Document.new("testing").vector_of_features.should == [Feature.new("test", 1)]
  end
  
  it "should count feature occurances" do
    Document.new("test doc test", :test).vector_of_features.should == 
      [Feature.new("doc", 1), Feature.new("test", 2)]
  end
end

describe URIDocument do
  
  def single_features(*uris)
    uris.flatten.map { |uri| Feature.new(uri.to_s, 1) }
  end
  
  it "should extract URI token separators &, ?, \\, /, =, [, ], and . separately" do
    expected_features = [:a,:b,:c,:d,:e,:f,:g,:h, :i, '&', '?', "\\", '/', '=', '[', ']', '.']
    expected = single_features(expected_features).sort
    URIDocument.new('a&b?c\d/e=f[g]h.i').feature_vectors.sort.should == expected
  end
  
  it "should extract two dots as a single feature instead of two dots" do
    URIDocument.new('..').feature_vectors.should == [Feature.new("..", 1)]
  end
  
  it "should not stem words" do
    URIDocument.new("testing").feature_vectors.should == [Feature.new("testing", 1)]
  end
  
  it "should URI decode encoded strings" do
    URIDocument.new("%23%25").feature_vectors.should == [Feature.new("#%", 1)]
  end
  
end