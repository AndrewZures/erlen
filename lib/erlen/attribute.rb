require_relative 'core'
require_relative 'errors'

module Erlen
  class Attribute
    attr_accessor :name, :type, :options, :validation
    def initialize(name, type, options={}, &validation)
      self.name = name.to_s
      self.type = type
      self.options = options
      self.validation = validation # proc object
    end

    # attribute specific validation
    def validate(value)
      if options[:required] && value.is_a?(Undefined)
        raise ValidationError.new("#{name} is required.")
      elsif value.is_a?(Undefined)
        # then fine
      elsif type == Boolean
        if (value != true && value != false)
          raise ValidationError.new("#{name}: #{value} is not Boolean")
        end
      elsif type <= BaseSchema && !value.valid?
        # uhh.. this can be better. not tested.
        raise ValidationError.new(value.errors.map {|e| "#{name}: #{e.message}" }.join("\n"))
      elsif !value.is_a? type
        raise ValidationError.new("#{name}: #{value} is not #{type.name}")
      end
      if !validation.nil? && !validation.call(value)
        file, line = validation.source_location if !validation.nil?
        raise ValidationError.new("Custom validation failed: #{file}:#{line}")
      end
    end
  end
end
