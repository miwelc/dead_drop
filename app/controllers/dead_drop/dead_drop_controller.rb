module DeadDrop
  class DeadDropController < ApplicationController
    before_filter :check_head_request

    def index
      token = params[:token]

      res = DeadDrop.pick(token, ignore_limit: request.head? && !DeadDrop.head_requests_count)

      render nothing: true, status: :not_found and return unless res

      filename = params[:filename] || res[:filename] || ""

      if filename.blank? == false
        mime_extension = res[:mime_type].is_a?(Mime::Type) ? res[:mime_type].symbol.to_s : nil
        extension = params[:format] || mime_extension || res[:filename].match(/\.\w+$/).to_s.sub(/\./,'')
        mime = Mime::Type.lookup_by_extension(extension.downcase) || 'application/octet-stream'

        extension = "."+extension unless extension.blank?
        filename.sub!(/\.\w+$/, '')

        send_data res[:resource], type: mime, filename: filename+extension
      else
        respond_to do |format|
          format.html { render html: res[:resource].html_safe }
          format.xml  { render xml: res[:resource] }
          format.json { render json: res[:resource] }
          format.all  { render plain: res[:resource] }
        end
      end

    end

    private

    def check_head_request
      return unless request.head?

      if DeadDrop.ignore_head_requests
        render nothing: true, status: 200
      elsif DeadDrop.exists?(params[:token])
        render nothing: true, status: 200
      else
        render nothing: true, status: :not_found
      end

    end

  end
end
