module HasPublicId
  module ActiveRecord
    module InstanceMethods
      def to_param
        self.send(public_id_attr)
      end
      def public_id_attr
        self.class.public_id_attr
      end
      def initialize_public_id
        read_attribute(public_id_attr) or
        write_attribute(public_id_attr, self.class.new_public_id)
      end
    end
    module Mixin
      extend ActiveSupport::Concern
      included do
      end
      module ClassMethods
        def has_public_id(attribute_name, *args)
          return if respond_to?(:public_id_attribute)
          options = args.extract_options!

          class_attribute :public_id_attr, :public_id_options

          class << self

            def initialize_public_ids!
              self.where(self.public_id_attr => nil).find_each do |obj|
                obj.update_attribute(self.public_id_attr, self.new_public_id)
              end
            end

            def find_by_public_id(public_id)
              where(self.public_id_attr => public_id).first
            end

            def find_by_public_id!(public_id)
              where(self.public_id_attr => public_id).first!
            end

            def new_public_id
              while(true)
                new_id = ::HasPublicId::Util.new_public_id(self, self.public_id_options)
                break unless where(self.public_id_attr => new_id).exists?
              end
              return new_id
            end
          end
          self.public_id_attr     = attribute_name
          self.public_id_options  = options
          include ::HasPublicId::ActiveRecord::InstanceMethods
          after_initialize :initialize_public_id
        end
      end
    end
  end
end
