require File.dirname(__FILE__) + '/../spec_helper'

describe Classifier do
  
  before(:each) do
    @classifier = Classifier.new
  end
  
  it "should automagically determine the ruby class of the classifier engine a la rails' constantize" do
    Classifier.new(:type => :naive_bayes).engine.class.should == NaiveBayes
  end
  
  it "should automagically determine the ruby class of the document type" do
    Classifier.new(:type => :naive_bayes, :doctype => :document).doctype.should == Document
  end
  
  it "should default to NaiveBayes engine and Document doctype" do
    classifier = Classifier.new()
    classifier.engine.class.should == NaiveBayes
    classifier.doctype.should == Document
  end
  
  
  it "should accept training docs as plain strings, extracting features automatically" do
    @classifier.train(:hip, "that hipster has an asymmetrical haircut")
    @classifier.train(:unhip, "that dude is a frat boy")
    @classifier.engine.classes.should == [:hip, :unhip]
    @classifier.engine.occurrences_of_all_features_in_class(:unhip).should == 6
  end
  
  it "should classify documents" do
    @classifier.train(:hip, "that hipster has an asymmetrical haircut")
    @classifier.train(:unhip, "that dude is a frat boy")
    @classifier.classify("hipsters").should == :hip
  end
  
  it "should train iteratively for speed learning" do
    @classifier.train(:hip, "turntables", "techno music", "DJs with turntables", "techno DJs")
    @classifier.train(:unhip, "rock music", "guitar bass drums", "guitar rock", "guitar players")
    @classifier.classify("guitar music").should == :unhip
    # now everyone likes rock music again! retrain fast! cf LCD Soundsystem
    @classifier.train_iterative(:hip, "guitars") # takes 3 iterations
    @classifier.classify("guitars").should == :hip
  end
  
  it "should give document scores for a class" do
    @classifier.train(:hip, "turntables", "techno music", "DJs with turntables", "techno DJs")
    @classifier.train(:unhip, "rock music", "guitar bass drums", "guitar rock", "guitar players")
    @classifier.similarity_score(:hip, "guitars").should be_a Float
  end
  
end


describe AnomalyDetector do
  
  before(:each) do
    @detector = AnomalyDetector.new
  end
  
  def train_detector_on_code_love
    @detector.train("coding all night and loving it", "coding and drinking jolt")
  end
  
  it "should train on the normal set only" do
    @detector.train("coding all night", "coding and drinking jolt")
    @detector.engine.classes.should == [:normal]
    @detector.engine.occurrences_of_all_features_in_class(:normal).should == 7
  end
  
  it "should give a score for the probability of a document to be in the ``normal'' set" do
    train_detector_on_code_love
    score = @detector.similarity_score("I love coding and jolt")
    score.should be_a Float
    score.should be_close(-1, 2)
  end
  
  it "should give a list of the probability scores for the training set" do
    train_detector_on_code_love
    @detector.scores_for_training_set.should have(2).items
    @detector.scores_for_training_set.each do |score|
      score.should be_close(-1, 1)
    end
  end
  
  it "should compute the average probability score for training set" do
    train_detector_on_code_love
    @detector.avg_score_of_training_set.should be_close(-0.841, 0.001)
  end
  
  it "should give the range of probability scores for the training set" do
    train_detector_on_code_love
    @detector.score_range_of_training_set.should be_a Range
    @detector.score_range_of_training_set.first.should be_close(-0.864, 0.001)
    @detector.score_range_of_training_set.last.should be_close(-0.818, 0.001)
  end
  
  it "should give the standard deviation of probability scores for the training set" do
    train_detector_on_code_love
    @detector.stddev_of_scores_of_training_set.should be_close(0.0234, 0.001) #0.0234
  end
  
  it "should use the average minus 4 times the stddev as the lower bound for normal" do
    train_detector_on_code_love
    expected = -0.841 - (4 * 0.0234)
    @detector.minimum_acceptable_score.should be_close(expected, 0.001)
  end
  
  it "should say if text is anomalous or not" do
    train_detector_on_code_love
    @detector.should be_anomalous("watching tv")
    @detector.should_not be_anomalous("code and jolt")
  end
  
  it "should classify text as anomalous or normal" do
    train_detector_on_code_love
    @detector.classify("watching tv").should == :anomalous
    @detector.classify("code and jolt").should == :normal
  end
  
  it "should give an anomaly score based on the std deviations from mean" do
    train_detector_on_code_love
    @detector.anomaly_score("watching_tv").should be_close( 80, 10)
  end
  
  it "should train iteratively" do
    train_detector_on_code_love
    50.times {@detector.train("coding drinking jolt")}
    @detector.train_iterative("watching tv")
    @detector.should be_normal("watching tv")
  end
  
  it "should reset memoized values to nil after retraining" do
    train_detector_on_code_love
    @detector.score_range_of_training_set
    @detector.scores_for_training_set.should_not be_nil
    train_detector_on_code_love
    @detector.instance_variable_get(:@scores_for_training_set).should be_nil
  end
    
end