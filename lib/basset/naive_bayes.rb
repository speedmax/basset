require File.join(File.dirname(__FILE__), "yaml_serialization")

module Basset

  # A class for running Naive Bayes classification.
  # Documents are added to the classifier. Once they are added
  # it can be used to classify new documents.
  class NaiveBayes
    include YamlSerialization
    
    attr_reader :total_docs, :total_docs_in_class, :feature_counts

    def initialize
      @total_docs = 0
      @total_docs_in_class = Hash.new(0)
      @feature_counts = {}
      @occurrences_of_all_features_in_class = {}
    end
  
    # takes a classification which can be a string and
    # a vector of features.
    def add_document(classification, feature_vector)
      reset_cached_probabilities
    
      @total_docs_in_class[classification] += 1
      @total_docs += 1
      
      feature_vector.each do |feature|
        @feature_counts[feature.name] ||= FeatureCount.new(feature.name)
        @feature_counts[feature.name].add_count_for_class(feature.value, classification)
      end
    end
    
    def classes
      @total_docs_in_class.keys
    end
  
    # returns the most likely class given a vector of features
    def classify(feature_vectors, opts={:normalize_classes=>true})
      class_probabilities = []
      
      classes.each do |classification|
        class_probability = 0
        class_probability += Math.log10(probability_of_class(classification)) if opts[:normalize_classes]
        class_probability += probability_of_vectors_for_class(feature_vectors, classification)
        class_probabilities << [class_probability, classification]
      end
      
      # this next bit picks a random item first
      # this covers the case that all the class probabilities are equal and we need to randomly select a class
      max = class_probabilities.pick_random
      class_probabilities.each do |cp|
        max = cp if cp.first > max.first
      end
      max
    end
    
    #
    # Gives a score for probability of _feature_vector_ being in 
    # class _classification_.  
    # 
    # This score can be normalized to the number of feature vectors by passing
    # :normalize => true for the third argument.
    #
    # Score is not normalized for the relatives probabilities of each class. 
    def probability_of_vectors_for_class(feature_vectors, classification, opts={:normalize=>false})
      probability = 0
      feature_vectors.each do |feature_vector|
        probability += probability_of_vector_for_class(feature_vector, classification)
      end
      if opts[:normalize]
        probability / feature_vectors.count.to_f
      else
        probability
      end
    end
    
    # returns the probability of a feature given the class
    def probability_of_vector_for_class(feature_vector, classification)
      # the reason the rescue 0 is in there is tricky
      # because of the removal of redundant unigrams, it's possible that one of the features is never used/initialized
      decimal_probability = (((@feature_counts[feature_vector.name].count_for_class(classification) rescue 0) + 0.1)/ occurrences_of_all_features_in_class(classification).to_f) * feature_vector.value
      Math.log10(decimal_probability)
    end
    
    # The sum total of times all features occurs for a given class.
    def occurrences_of_all_features_in_class(classification)
      # return the cached value, if there is one
      return @occurrences_of_all_features_in_class[classification] if @occurrences_of_all_features_in_class[classification]

      @feature_counts.each_value do |feature_count|
        @occurrences_of_all_features_in_class[classification] ||= 0
        @occurrences_of_all_features_in_class[classification] += feature_count.count_for_class(classification)
      end
      @occurrences_of_all_features_in_class[classification]
    end

  private
  
    # probabilities are cached when the classification is run. This method resets
    # the cached probabities.
    def reset_cached_probabilities
      @occurrences_of_all_features_in_class.clear
    end

    # returns the probability of a given class
    def probability_of_class(classification)
      @total_docs_in_class[classification] / @total_docs.to_f
    end
  
    # A class to store feature counts
    class FeatureCount
      attr_reader :classes, :name
      
      def initialize(feature_name=nil, classification=nil, count=0)
        @name, @classes = feature_name, {}
        add_count_for_class(count, classification) if classification
      end

      def add_count_for_class(count, classification)
        @classes[classification] ||= 0
        @classes[classification] += count
      end

      def count_for_class(classification)
        #@classes[classification] || 1 um, what?
        @classes[classification] || 0
      end

      def count
        @classes.values.sum
      end
      
      def ==(other)
        other.kind_of?(FeatureCount) && other.classes == @classes && other.name == @name
      end
      
      def inspect(opts={:verbose=>false})
        return super if opts[:verbose]
        "#<FeatureCount for ``" + @name.to_s + "''" + " --> " + @classes.inspect + " > "
      end
      
    end

  end
end