module Api
  module V1
    class JobRequestsController < ApiController
      def execute
        model = show
        job_class_name = model_class.name.gsub(/Request$/, 'Job')
        raise "Cannot execute job because job class \"#{job_class_name}\" cannot be found" unless self.class.class_exists?(job_class_name)
        job_class = job_class_name.constantize
        job = job_class.perform_later(
            foreman_resource: YAML.dump(@foreman_resource),
            request: model
        )
        @data = {
            job_id: job.job_id
        }
      end

      def reset
        raise NotImplementedError
      end

      private

      def self.class_exists?(class_name)
        Module.const_get(class_name).is_a?(Class)
      rescue NameError
        false
      end
    end
  end
end