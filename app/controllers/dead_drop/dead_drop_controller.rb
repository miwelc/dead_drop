module DeadDrop
  class DeadDropController < ApplicationController

    def index
      token = params[:token]

      res = DeadDrop.pick(token, ignore_limit: request.head?)

      render nothing: true, status: :not_found and return unless res

      filename = params[:filename] || res[:filename] || ""

      if filename.blank? == false
        mime_extension = res[:mime_type].is_a?(Mime::Type) ? res[:mime_type].symbol.to_s : ""
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
          format.all  { render text: res[:resource] }
        end
      end

    end

  end
end
