class Social::Clouds::Dropbox < Social::Cloud
  def human_name
    'Dropbox'
  end
  def gists_folder
    'SocialSync/gists'
  end
  def avatar_folder
    'SocialSync/avatar'
  end
  def avatar_file_name
    'avatar.jpg'
  end





  def get_avatar
    @client ||= auth
    @client.find(avatar_folder + '/' + avatar_file_name).download
  rescue Dropbox::API::Error::NotFound
    nil
  end

  def post_avatar(data)
    @client ||= auth
    begin
      @client.mkdir(avatar_folder)
    rescue Dropbox::API::Error::Forbidden
      nil
    end
    @client.upload(avatar_folder + '/' + avatar_file_name, data)
    {}
  end











  def get_gists
    @client ||= auth
    gists = {}

    gist_files = @client.ls gists_folder
    gist_files.each do |file|
      begin
        gist_data = JSON.parse(file.download, :symbolize_names => true)
        gists[gist_data[:id].to_s] = gist_data
      rescue JSON::ParserError
        nil
      end
    end

    gists
  rescue Dropbox::API::Error::NotFound
    {}
  end

  def put_gists(gists)
    @client ||= auth
    begin
      @client.mkdir gists_folder
    rescue Dropbox::API::Error::Forbidden
      nil
    end

    gists.each do |gist|
      gist_name = create_gist_name gist[:id]
      @client.upload(gists_folder + '/' + gist_name, gist.to_json)
    end
  end

  def delete_gists(ids)
    @client ||= auth

    ids.each do |id|
      begin
        file = @client.find gists_folder + '/' + create_gist_name(id)
        file.destroy
      rescue Dropbox::API::Error::NotFound
        nil
      end
    end
  end







  private

  def auth
    Dropbox::API::Client.new :token => token, :secret => secret
  end
end
