require File.dirname(__FILE__) + '/../spec_helper'

describe Svm do
  
  before(:each) do
    @svm = Svm.new
    @doc = Document.new("here are some interesting words", :interesting)
    @feature_vectors = @doc.feature_vectors
    @negative_doc = Document.new("let's eat some spamiagra", :uninteresting)
    @negative_fvs = @negative_doc.feature_vectors
  end
  
  def add_simple_docs_to_svm
    @svm.add_document(:interesting, @feature_vectors)
    @svm.add_document(:uninteresting, @negative_fvs)
  end
  
  it "should list document classes it knows about" do
    add_simple_docs_to_svm
    @svm.classes.sort_to_s.should == [:interesting, :uninteresting].sort_to_s
  end
  
  it "should express classes as SVM friendly unit integer labels"do
    add_simple_docs_to_svm
    spam_doc = Document.new("make your junk repulsive to women with free v14gra")
    @svm.add_document(:uninteresting, spam_doc.feature_vectors)
    @svm.class_labels.should == {:interesting => 0, :uninteresting => 1}
  end
  
  it "should create a feature dictionary based on training docs" do
    add_simple_docs_to_svm
    expected = (@feature_vectors + @negative_fvs).map { |fv| fv.name }.uniq
    @svm.feature_dictionary.should == expected
  end
  
  it "should express documents as SVM friendly vectors using the binary method" do
    # for a brief but usable description of binary, frequency, tf-idf, and 
    # Hadamard vector representations of documents, see section 2.1 (2nd page) of:
    # http://jmlr.csail.mit.edu/papers/volume2/manevitz01a/manevitz01a.pdf
    add_simple_docs_to_svm
    @svm.vectorized_docs(:interesting).first.should == [1,1,1,1,1,0,0,0]
    @svm.vectorized_docs(:uninteresting).first.should == [0,0,0,0,1,1,1,1]
  end
  
  it "should set SVM parameters to reasonable defaults and allow access via a block" do
    @svm.parameters do |params|
      params.C.should == 100
      params.svm_type.should == NU_SVC
      params.degree.should == 1
      params.coef0.should == 0
      params.eps.should == 0.001
      params.kernel_type.should == RBF
    end
  end
  
  it "should construct the list of labels and document feature vectors" do
    add_simple_docs_to_svm
    result = @svm.labels_and_document_vectors
    result[:labels].sort.should == [0,1]
    result[:features].sort.should == [[0,0,0,0,1,1,1,1], [1,1,1,1,1,0,0,0]]
    # can't count on consistent Hash#each ordering, hence this:
    expected_result_with_hash_ordering_workaround = {1 => [0,0,0,0,1,1,1,1], 0 => [1,1,1,1,1,0,0,0]}
    stabilized_actual_result = {result[:labels].first => result[:features].first, 
      result[:labels].last => result[:features].last}
    stabilized_actual_result.should == expected_result_with_hash_ordering_workaround
  end
  
  it "should classify unlabeled documents" do
    # examples from http://www.igvita.com/2008/01/07/support-vector-machines-svm-in-ruby/
    non_spam_texts = ["Peter and Stewie are hilarious", "New episode rocks, Peter and Stewie are hilarious",
      "Peter is my fav!"]
    spam_texts = ["FREE NATIONAL TREASURE", "FREE TV for EVERY visitor", "AS SEEN ON NATIONAL TV",
      "FREE drugs"]
    non_spam_texts.each { |t| @svm.add_document(:nonspam, Document.new(t, :nonspam).feature_vectors) }
    spam_texts.each { |t| @svm.add_document(:spam, Document.new(t, :spam).feature_vectors) }
    test_non_spams = ["Stewie is hilarious", "Poor Peter is hilarious"]
    test_spam = "FREE lotterry for the NATIONAL TREASURE !!!"
    @svm.classify(Document.new(test_non_spams.first).feature_vectors).should == :nonspam
    @svm.classify(Document.new(test_non_spams.last).feature_vectors).should == :nonspam
    @svm.classify(Document.new(test_spam).feature_vectors).should == :spam
  end
  
end