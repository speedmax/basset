require "yaml"

module YamlSerialization
  
  def self.included(base)
    base.extend ClassMethods
  end
  
    
  module ClassMethods  
    def load_from_file(file_name)
      YAML.load_file(file_name)
    end
  end
  
  def save_to_file(file_name)
    File.open(file_name, 'w') do |file|
      YAML.dump(self, file)
    end
  end
  
end

class ::Class
  yaml_as "tag:ruby.yaml.org,2002:class"
  
  def Class.yaml_new( klass, tag, val )
    if String === val
      val.split(/::/).inject(Object) {|m, n| m.const_get(n)}
    else
      raise YAML::TypeError, "Invalid Class: " + val.inspect
    end
  end
  
  def to_yaml( opts = {} )
    YAML::quick_emit( nil, opts ) { |out|
      out.scalar( "tag:ruby.yaml.org,2002:class", self.name, :plain )
    }
  end
  
end
