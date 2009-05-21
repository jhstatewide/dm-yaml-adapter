require 'rubygems'
require 'dm-core'
require 'yaml'
require 'dm-core/adapters/abstract_adapter'

module DataMapper::Adapters

  class YamlAdapter < AbstractAdapter      

    def initialize(name, options)
      super

      @options = Hash.new
      
      @options[:directory] = options[:directory]
      
      @options[:directory] ||= './db'         

    end
    
    def destroy_model_storage(repository, model)
	    FileUtils.rm_rf(classname_to_dir(model.to_s))
    end
    
    def create_model_storage(repository, model)
	    FileUtils.mkdir_p(classname_to_dir(model.to_s))
    end
   
    def create(resources) 
       resources.each do |resource|
	       model = resource.model
	       id = find_free_id_for(resource.class.to_s)
	       # find name of key attribute
	       key = model.key.first.name
	       resource.attributes[key] = id
	       resource.instance_variable_set("@" + key.to_s, id)
	       save(resource)
       end
       return resources.size
    end
    
    def delete(query)
	    resultset = yaml_query(query)
	    resultset.each do |result|
		    yaml_destroy(result)
	    end
	    return resultset.size
    end
    
    def read_one(query)
	    return(filter_result_set(get_all(query.model), query).first)
    end
    
    def update(attributes, query)
	    # ok, for each object found we have to update the attribs we found
	    # first thing is figure out what class we are dealing with
	    clazz = query.model
	    # next, get all the matching objects
	    objs = filter_result_set(clazz.all, query)
	    # iterate over every object in this set and set the given attributes
	    objs.each do |obj|
		    attributes.each do |attrib|
			    # attrib is an array
			    # first member is Property object
			    # second member is the value
			    obj.instance_variable_set("@" + attrib[0].name.to_s, attrib[1])
		    end
		    save(obj)
	    end
    end
   
    def read_many(query)
	    return filter_result_set(get_all(query.model), query)
    end

  
  private
  
  	def yaml_destroy(resource)
		# take an objects class and ID and figure
		# out what file it's in
		# and then remove that file
		class_name = resource.class.to_s
		id = resource.key.first
		file = class_name_to_file(class_name, id)
		File.unlink(file)
	end
	
	def yaml_query(query)
		# in this method, we want to take each condition and figure out
		# what we should return
		
		# first is figuring out our class
		model = query.model
		# if we just want all the objects...
		if (query.conditions.empty?)
			return get_all(model)
		end
		
		# otherwise we have to filter on some conditions...
		all_objs = get_all(model)
		# for each object, check all the conditions
		filter_result_set(all_objs, query)
	end
	
	def filter_result_set(objects, query)
		result_set = objects.clone
		objects.each do |obj|
			query.conditions.each do |operator, property, value|
				case operator
					# handle eql
					when :eql, :like
						if ! (obj.instance_variable_get("@" + property.field) == value)
							# remove from teh result set...
							result_set.delete(obj)
						end
					# handle :not
					when :not
						if (obj.instance_variable_get("@" + property.field) == value)
							result_set.delete(obj)
						end
				end
			end
		end
		return result_set
	end
  	
  	def get_all(clazz)
		objects = Array.new
		directory = classname_to_dir(clazz.to_s)
		if ! File.exists?(directory)
			return objects
		end
		Dir.entries(directory).grep(/\.yaml$/).each do |entry|
			objects << file_to_object(File.join(directory, entry))
		end
		return objects
	end
	
	def file_to_object(file)
		new_obj =  YAML.load_file(file)
		new_obj.instance_variable_set("@new_record", false)
		return new_obj
	end
  	
   	def find_free_id_for(class_name)
		# if there are no entries in the directory, or the directory doesn't exist
		# we need to create it...
		
		if ! File.exists?(classname_to_dir(class_name))
			# default ID
			return 1
		end
		directory = classname_to_dir(class_name)
		if directory.entries.size == 0
			return 1
		end
		free_id = -1
		id = 1
		until free_id != -1 do
			id += 1
			if ! File.exists?(File.join(directory, id.to_s + ".yaml"))
				return id
			end
		end
	end
  	
        def save(resource)
		file = File.join(class_name_to_file(resource.class.to_s, resource.id))
		# see if the directory exists, if it doesn't, we need to create it
		if ! File.exists?(classname_to_dir(resource.class.to_s))
			FileUtils.mkdir_p(classname_to_dir(resource.class.to_s))
		end
		yamlfile = File.new(class_name_to_file(resource.class.to_s, resource.id), "w")
		yamlfile.puts resource.to_yaml
		yamlfile.close
	end

	def classname_to_dir(class_name)
		return File.join(@options[:directory], class_name.gsub("/", "_"))
	end
	
	def class_name_to_file(class_name, id)
		return File.join(classname_to_dir(class_name), id.to_s + ".yaml")
	end
	
    end
end

