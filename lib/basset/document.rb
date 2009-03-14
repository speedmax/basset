require 'uri'

module Basset

  # A class for representing a document as a vector of features. It takes the text 
  # of the document and the classification. The vector of features representation is 
  # just a basic bag of words approach.
  class Document
    attr_reader :text, :classification
    
    # 
    # initialize the object with document text.  Set an explicit classification
    # to use the document as training data
    def initialize(text, classification = nil)
      @text, @classification = text, classification
      @tokens = stemmed_words
    end
    
    #
    # returns an array of feature (token) vectors, which are instances Feature
    def vector_of_features
      @feature_vector ||= vector_of_features_from_terms_hash( terms_hash_from_words_array( @tokens ) )
    end
    
    #
    # Alias for #vector_of_features
    def feature_vectors
      vector_of_features
    end
  
  private

    # returns a hash with each word as a key and the value is the number of times
    # the word appears in the passed in words array
    def terms_hash_from_words_array(words)
      terms = Hash.new(0)
      words.each do |term|
        terms[term] += 1
      end
      return terms
    end
  
    def vector_of_features_from_terms_hash(terms)
      terms.collect do |term, frequency|
        Feature.new(term, frequency)
      end
    end
  
    def stemmed_words
      words.map { |w| w.stem.downcase }
    end
  
    def words
      clean_text.split(" ")
    end

    # Remove punctuation, numbers and symbols
    def clean_text
      text.tr("'@_", '').gsub(/\W/, ' ').gsub(/[0-9]/, '')
#      text.tr( ',?.!;:"#$%^&*()_=+[]{}\|<>/`~', " " ) .tr( "@'\-", "")
    end
    
  end
  
  #
  # Subclass of Document intended to be used to classify URIs
  class URIDocument < Document
    
    def initialize(uri, classification=nil)
      @text, @classification = uri, classification
      @tokens = uri_tokens
    end
    
    def vector_of_features
      @feature_vector ||= vector_of_features_from_terms_hash(terms_hash_from_words_array(@tokens))
    end
    
    def uri_tokens
      URI.decode(@text).gsub(/(\&|\?|\\|\/|\=|\[|\]|\.\.|\.)/) { |char| " " + char + " " }.split
    end
    
  end
  
end