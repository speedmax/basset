require File.dirname(__FILE__) + '/../spec_helper'

describe NaiveBayes::FeatureCount do
  
  it "should be equal to another feature count if the feature name and counts per class are equal" do
    NaiveBayes::FeatureCount.new("rspec", :sweet, 1).should == NaiveBayes::FeatureCount.new("rspec", :sweet, 1)
  end
  
  it "should give the sum of all occurrences of a feature for a given class" do
    fc = NaiveBayes::FeatureCount.new("rspec", :sweet, 1)
    fc.add_count_for_class(2, :sweet)
    fc.add_count_for_class(6, :super_sweet)
    fc.count_for_class(:sweet).should == 3
    fc.count_for_class(:super_sweet).should == 6
  end
  
end

describe NaiveBayes do
  
  before(:each) do
    @nbayes = NaiveBayes.new
    @doc = Document.new("here are some interesting words", :interesting)
    @feature_vectors = @doc.feature_vectors
    @other_vectors = Document.new("these words are interesting", :interesting).feature_vectors
    @test_vectors = Document.new("this word seems interesting", :interesting).feature_vectors
  end
  
  def feature_counts_for(classification, *feature_count_tuples)
    feature_counts = {}
    feature_count_tuples.each do |tuple| 
      feature_counts[tuple.first] = NaiveBayes::FeatureCount.new(tuple.first, classification, tuple.last)
    end
    feature_counts
  end
  
  def add_interesting_docs
    @nbayes.add_document(:interesting, @feature_vectors)
    @nbayes.add_document(:interesting, @other_vectors)
  end
  
  def add_boring_docs
    @nbayes.add_document(:boring, Document.new("yawn lets go flame").feature_vectors)
    @nbayes.add_document(:boring, Document.new("yawn lets flame and troll").feature_vectors)
  end
  
  it "should keep track of the total docs and total docs for class when adding new docs" do
    @nbayes.add_document(:interesting, @feature_vectors)
    @nbayes.total_docs.should == 1
    @nbayes.total_docs_in_class[:interesting].should == 1
  end
  
  it "should create a feature count for each feature with the # of occurances and class" do
    @nbayes.add_document(:interesting, @feature_vectors)
    expected = feature_counts_for(:interesting, ["here", 1], ["ar", 1],["some", 1],["interest", 1],["word", 1])
    @nbayes.feature_counts.should == expected
  end
  
  it "should sum the number of all occurances of all features for a given class" do
    @nbayes.add_document(:interesting, @feature_vectors)
    @nbayes.occurrences_of_all_features_in_class(:interesting).should == 5
    add_boring_docs
    @nbayes.occurrences_of_all_features_in_class(:interesting).should == 5
  end
  
  def sorted_array_of(items)
    items.map { |item| item.to_s }.sort
  end
  
  it "should give a list of classes it knows about" do
    @nbayes.add_document(:interesting, @feature_vectors)
    @nbayes.add_document(:kinda_interesting, @feature_vectors)
    sorted_array_of(@nbayes.classes).should == sorted_array_of([:kinda_interesting, :interesting])
  end
  
  it "should compute the probability that a given (singular) feature vector belongs to a given class" do
    @nbayes.add_document(:interesting, @feature_vectors)
    probablity = @nbayes.probability_of_vector_for_class(@test_vectors.first, :interesting)
    probablity.should be_a Float
    probablity.round.should == -1
  end
  
  it "should compute the probability that a given set of feature vectors belongs to a given class" do
    add_interesting_docs
    probability = @nbayes.probability_of_vectors_for_class(@test_vectors, :interesting)
    probability.should be_a(Float)
    probability.round.should == -5
  end
  
  it "should compute a probability of a class for a set of vectors normalized by the number of features" do
    add_interesting_docs
    probability = @nbayes.probability_of_vectors_for_class(@test_vectors, :interesting, :normalize => true)
    probability.should be_a Float
    probability.round.should == -1
  end
  
  it "should determine the most likely class of a set feature vectors" do
    add_interesting_docs
    add_boring_docs
    test_vectors = Document.new("some interesting words").feature_vectors
    classification = @nbayes.classify(test_vectors, :normalize_classes => false)
    classification.last.should == :interesting
    classification.first.should be_a Float
    classification.first.round.should == -2
  end
  
  it "should account for the relative probabilities of classes by default when classifying" do
    add_interesting_docs
    add_boring_docs
    vectors = Document.new("some interesting words").feature_vectors
    classification = @nbayes.classify(vectors)
    classification.last.should == :interesting
    classification.first.should be_a Float
    classification.first.round.should == -2
  end
  
end