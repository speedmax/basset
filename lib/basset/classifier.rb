require "basset/yaml_serialization"

module Basset
  
  #
  # Classifier wraps up all of the operations spread between Document and friends,
  # FeatureExtractor, FeatureSelector, and specific classifiers such as 
  # NaiveBayes into one convenient interface.
  #
  class Classifier
    include YamlSerialization
    
    DEFAULTS = {:type => "naive_bayes", :doctype => "document"}
    
    attr_reader :engine, :doctype
    
    #
    # Create a new classifier object.  You can specify the type of classifier
    # and kind of documents with the options.  The defaults are 
    # :type => :naive_bayes, :doctype => :document; There is also a uri_document,ie.
    # opts: {:type => :naive_bayes, :doctype => :uri_document }
    def initialize(opts={})
      @engine = constanize_opt(opts[:type] || DEFAULTS[:type]).new
      @doctype = constanize_opt(opts[:doctype] || DEFAULTS[:doctype])
    end
    
    #
    # Trains the classifier with _texts_ of class _classification_.
    # _texts_ gets flattened, so you can pass in an array without breaking
    # anything.
    def train(classification, *texts)
      texts.flatten.each do |text| 
        train_with_features(classification, features_of(text, classification))
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
    
    # 
    # Classifies _text_ based on training
    def classify(text)
      classify_features(features_of(text)).last
    end
    
    #
    # Gives a numeric value for the similarity of _text_ to previously seen
    # texts of class _classification_.  For a Naive Bayes filter, this will
    # be the log10 of the probabilities of each token in _text_ occuring in
    # a text of class _classification_, normalized for the number of tokens.
    def similarity_score(classification, text)
      similarity_score_for_features(classification, features_of(text))
    end
    
    def ==(other)
      other.is_a?(self.class) && other.engine == engine && other.doctype == doctype
    end
    
    private
    
    def train_with_features(classification, features)
      @engine.add_document(classification, features)
    end
    
    def classify_features(features)
      @engine.classify(features)
    end
    
    def similarity_score_for_features(classification, features)
      @engine.probability_of_vectors_for_class(features, classification, :normalize => true)      
    end
    
    def features_of(text, classification=nil)
      @doctype.new(text, classification).feature_vectors
    end
    
    # poor man's version of Rails' String#classify.constantize
    def constanize_opt(option)
      class_name = option.to_s.split('_').map { |word| word.capitalize }.join('')
      Basset.class_eval class_name
    end
    
  end
  
  #
  # A class for anomaly detection.  
  #
  # The purpose of this is to enable a statistical machine learning approach
  # even when you can't/don't want to assume that "abnormal" documents will
  # have certain features or fit nicely into classes.
  # 
  # An example use case is an anomaly based IDS where you don't want to classify
  # different kinds of attacks but instead want to find all events that deviate
  # from an established baseline.
  # 
  # With the default NaiveBayes classification method, uses the log10 of the 
  # Bayesian probability of a document belonging to the normal behavior group 
  # as a distance measurement; any document with a distance measurement higher
  # than a given threshold is considered anomalous.
  class AnomalyDetector < Classifier
    include YamlSerialization
    
    def initialize(opts={})
      @training_features=[]
      @updated = true
      super(opts)
    end
    
    def classify(text)
      anomalous?(text) ? :anomalous : :normal
    end
    
    def anomalous?(text)
      minimum_acceptable_score > similarity_score(text)
    end
    
    def normal?(text)
      !anomalous?(text)
    end
    
    def train(*texts)
      texts.flatten.each do |text|
        features = features_of(text)
        @training_features << features
        train_with_features(:normal, features)
      end
      reset_memoized_values
    end
    
    def similarity_score(text)
      super(:normal, text)
    end
    
    # Gives the number of standard deviations from average 
    def anomaly_score(text)
      -1 * similarity_score(text) / stddev_of_scores_of_training_set
    end
    
    def scores_for_training_set
      unless @scores_for_training_set
        @scores_for_training_set = @training_features.map { |feature_set| similarity_score_for_features(:normal, feature_set)}
        stddev_of_scores_of_training_set
      end
      @scores_for_training_set
    end
    
    def avg_score_of_training_set
      scores_for_training_set.inject(0) { |sum, score| sum += score } / scores_for_training_set.length.to_f
    end
    
    def score_range_of_training_set
      scores_for_training_set.min .. scores_for_training_set.max
    end
    
    def stddev_of_scores_of_training_set
      unless @stddev_of_scores_of_training_set
        @stddev_of_scores_of_training_set = Math.stddev(scores_for_training_set)
      end
      @stddev_of_scores_of_training_set
    end
    
    def minimum_acceptable_score
      avg_score_of_training_set - (4 * stddev_of_scores_of_training_set)
    end
    
    def train_iterative(text)
      (1 .. 5).each do
        train(text)
        break if normal?(text)
      end
    end
    
    def reset_memoized_values
      @memoized_vals_stale = true
      @stddev_of_scores_of_training_set = nil
      @scores_for_training_set = nil
    end
    
  end
end