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
  
end