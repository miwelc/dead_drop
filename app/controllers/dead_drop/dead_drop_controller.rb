module DeadDrop
  class DeadDropController < ApplicationController

    def index
      token = params[:token]

      res = DeadDrop.pick(token, ignore_limit: request.head?)

      if res[:filename].blank? == false
        send_data res[:resource], type: res[:mime_type], disposition: "attachment; filename=#{res[:filename]}"
      else
        respond_to do |format|
          format.html {render html: res[:resource]}
          format.xml  {render xml: res[:resource]}
          format.json {render json: res[:resource]}
          format.all  {render text: res[:resource]}
        end
      end

    end

  end
end
