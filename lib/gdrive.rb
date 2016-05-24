require "gdrive/version"

module Gdrive
  class API
    include HTTParty
    base_uri 'https://www.googleapis.com'

    def initialize(client_id, access_token)
      @access_token = access_token
      @client_id = client_id
      @auth = {:key => @access_token}
    end

    def get_file(file_id)
      options = {query: {fileId:"#{file_id}"}.merge!(@auth) }
      self.class.get("/drive/v3/files", options)
    end

    def list_files(file_id)
      options = {query: {q:"#{file_id} in parents"}.merge!(@auth) }
      self.class.get("drive/v3/files", options)
    end

    def upload_html(file_name, html, parent_id)
      metadata = {
                "mimeType"=> "application/vnd.google-apps.document",
                "name"=> "#{file_name}",
                "parents"=> ["#{parent_id}"]
              }.to_json

      #Compose multipart body
      @boundary = SecureRandom.hex(21)
      post_body = []
      post_body << "--#{@boundary}\r\n"
      post_body << "Content-Type: application/json"
      post_body << "\r\n\r\n"
      post_body << metadata
      post_body << "\r\n--#{@boundary}\r\n"
      post_body << "Content-Type: text/html"
      post_body << "\r\n\r\n"
      post_body << html
      post_body << "\r\n--#{@boundary}--\r\n"
      body = post_body.join

      self.class.post(
                    '/upload/drive/v3/files?uploadType=multipart',
                    :body => body,
                    :headers => {
                            "Authorization" => "Bearer #{@access_token}",
                            "Content-Type" => "multipart/related; boundary=#{@boundary}"
                    }
                 )
    end

    def export_file(file_id)
      options = {query: @auth}
      self.class.get("https://docs.google.com/feeds/download/documents/export/Export?id=#{file_id}&exportFormat=html", options)
    end

    def token_expired?

    end

    def refresh_token!

    end

  end #End class
end
