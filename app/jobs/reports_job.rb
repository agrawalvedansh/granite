# frozen_string_literal: true

# app/jobs/reports_job.rb
class ReportsJob
  include Sidekiq::Job
  sidekiq_options retry: 0 # Disable retries temporarily for debugging

  def perform(user_id)
    begin
      ActionCable.server.broadcast(user_id, { message: I18n.t("report.render"), progress: 25 })

      # Debug logging
      Rails.logger.info "Fetching tasks for user #{user_id}"
      tasks = Task.accessible_to(user_id)
      Rails.logger.info "Found #{tasks.count} tasks"

      # Check if template exists
      template_path = "tasks/report/download"
      unless lookup_context.template_exists?(template_path)
        raise "Template not found: #{template_path}"
      end

      # Render with explicit options
      html_report = ApplicationController.render(
        template: template_path,
        layout: "pdf",
        locals: {
          tasks: tasks,
          user: User.find(user_id)
        },
        assigns: {
          tasks: tasks,
          user: User.find(user_id)
        }
      )

      Rails.logger.info "HTML report generated successfully"
      ActionCable.server.broadcast(user_id, { message: I18n.t("report.generate"), progress: 50 })

      pdf_report = WickedPdf.new.pdf_from_string(html_report)
      Rails.logger.info "PDF generated successfully"

      current_user = User.find(user_id)
      ActionCable.server.broadcast(user_id, { message: I18n.t("report.upload"), progress: 75 })

      if current_user.report.attached?
        current_user.report.purge_later
      end

      current_user.report.attach(
        io: StringIO.new(pdf_report),
        filename: "report.pdf",
        content_type: "application/pdf"
      )

      current_user.save!
      Rails.logger.info "Report attached successfully"
      ActionCable.server.broadcast(user_id, { message: I18n.t("report.attach"), progress: 100 })
    rescue => e
      Rails.logger.error "ReportsJob failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      ActionCable.server.broadcast(
        user_id, {
          message: "Error generating report: #{e.message}",
          progress: 0
        })
      raise e
    end
  end

  private

    def lookup_context
      ActionView::LookupContext.new(ActionController::Base.view_paths)
    end
end
