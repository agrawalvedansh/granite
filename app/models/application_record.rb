# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  after_create :log_task_details

  primary_abstract_class

  def errors_to_sentence
    errors.full_messages.to_sentence
  end

  def log_task_details
    TaskLoggerJob.perform_async(self.id)
  end
end
