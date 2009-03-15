require "basset/yaml_serialization"

module Basset
  
  #
  # Classifier wraps up all of the operations spread between Document and friends,
  # FeatureExtractor, FeatureSelector, and specific classifiers such as 
  # NaiveBayes into one convenient interface.
  #
  class Classifier
    DEFAULTS = {:type => "naive_bayes", :doctype => "document"}
    
    attr_reader :engine, :doctype
    
    #
    # Create a new classifier object.  You can specify the type of classifier
    # and kind of documents with the options.  The defaults are 
    # :type => :naive_bayes, :doctype => :document; There is also a uri_document
    def initialize(opts={})
      # opts: {:type => :naive_bayes, :doctype => :uri_document }
      @engine = constanize_opt(opts[:type] || DEFAULTS[:type]).new
      @doctype = constanize_opt(opts[:doctype] || DEFAULTS[:doctype])
    end
    
    #
    # Trains the classifier with _texts_ of class _classification_.
    # _texts_ gets flattened, so you can pass in an array without breaking
    # anything.
    def train(classification, *texts)
      texts.flatten.each do |text| 
        @engine.add_document(classification, features_of(text, classification))
      end
    end
    
    # 
    # Trains the classifier on a text repeatedly until the classifier recognizes
    # it as being in class _classification_ (up to a maximum of 5 retrainings).
    # Handy for training the classifier quickly or when it has been mistrained.
    def train_iterative(classification, text)
      (1 .. 5).each do |i|
        train(classification, text)
        break if classify(text) == classification
      end
    end
    
    def classify(text)
      @engine.classify(features_of(text)).last
    end
    
    def similarity_score(classification, text)
      @engine.probability_of_vectors_for_class(features_of(text), classification, :normalize => true)
    end
    
    private
    
    def features_of(text, classification=nil)
      @doctype.new(text, classification).feature_vectors
    end
    
    # poor man's version of Rails' String#classify.constantize
    def constanize_opt(option)
      class_name = option.to_s.split('_').map { |word| word.capitalize }.join('')
      Basset.class_eval class_name
    end
    
  end
end