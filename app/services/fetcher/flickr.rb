require 'flickraw'

module Fetcher
  class Flickr
    USER_ID = '33668819@N03'.freeze
    PHOTOSET_ID = 72157647560300303
    EXTERNAL_SERVICE_NAME = 'flickr'.freeze
    DEFAULT_EXTRAS = 'date_upload,media,url_t,url_s,url_m,url_o'.freeze

    def initialize
      authenticate
      fetch_and_update
    end

    private

    def authenticate
      FlickRaw.api_key = ENV['FLICKR_API_KEY']
      FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET']
      flickr.access_token = ENV['FLICKR_ACCESS_TOKEN']
      flickr.access_secret = ENV['FLICKR_ACCESS_SECRET']
      ensure_authenticated
    end

    def ensure_authenticated
      begin
        flickr.test.login
      rescue FlickRaw::FailedResponse => e
        puts "Authentication failed : #{e.msg}"
        raise e
      end
    end

    def flickr
      @flickr ||= FlickRaw::Flickr.new
    end

    # fetch photos from photoset, save into ivar
    # if oldest photo is newer than Photo.newest_from('flickr') scope
    # get the next page, and repeat
    # once we fetch all photos, iterate through and invoke PhotoCreator with them
    def fetch_and_update
      fetch_all_newer_photos
      # fetch_individual_photos # dont have to do this if we pass more `extras` options
      create_photos
    end

    def fetch_all_newer_photos(page = 1)
      response = get_photos(page: page)
      photos = response['photo']

      oldest_external_photo = photos.min_by { |photo| photo['dateupload'] }
      oldest_external_photo_date = epoch_timestamp_to_date(oldest_external_photo['dateupload'])

      new_photos << photos
      new_photos.flatten!

      if newest_photo.external_date < oldest_external_photo_date
        fetch_all_newer_photos(page + 1)
      end
    end

    def new_photos
      @new_photos ||= []
    end

    def newest_photo
      @newest_photo ||= Photo.newest_from_external_service(EXTERNAL_SERVICE_NAME)
    end

    def get_photos(user_id: USER_ID, photoset_id: PHOTOSET_ID, per_page: 100, page: 1, extras: DEFAULT_EXTRAS)
      photosets.getPhotos(
        user_id: user_id,
        photoset_id: photoset_id,
        per_page: per_page,
        page: page,
        extras: extras
      )
    end

    def photosets
      @photosets ||= flickr.photosets
    end

    def epoch_timestamp_to_date(timestamp)
      DateTime.strptime(timestamp, '%s')
    end

    # {
    #   "id"=>"16074806432",
    #   "secret"=>"da7251e039",
    #   "server"=>"8594",
    #   "farm"=>9,
    #   "title"=>"IMG_6601",
    #   "isprimary"=>"0",
    #   "ispublic"=>1,
    #   "isfriend"=>0,
    #   "isfamily"=>0,
    #   "dateupload"=>"1419208624",
    #   "media"=>"photo",
    #   "media_status"=>"ready",
    #   "url_t"=>"https://farm9.staticflickr.com/8594/16074806432_da7251e039_t.jpg",
    #   "height_t"=>"100",
    #   "width_t"=>"67",
    #   "url_s"=>"https://farm9.staticflickr.com/8594/16074806432_da7251e039_m.jpg",
    #   "height_s"=>"240",
    #   "width_s"=>"160",
    #   "url_m"=>"https://farm9.staticflickr.com/8594/16074806432_da7251e039.jpg",
    #   "height_m"=>"500",
    #   "width_m"=>"333",
    #   "url_o"=>"https://farm9.staticflickr.com/8594/16074806432_a0ef38ca00_o.jpg",
    #   "height_o"=>"5184",
    #   "width_o"=>"3456"
    # }
    def create_photos
      new_photos.each do |photo|
        Photo.create!(
          title: photo['title'],
          # description: ,
          url_thumb: photo['url_t'],
          url_medium: photo['url_m'],
          url_large: photo['url_s'],
          url_original: photo['url_o'],
          external_service_id: photo['id'],
          external_date: epoch_timestamp_to_date(photo['dateupload']),
          external_service_name: EXTERNAL_SERVICE_NAME
        )
      end
    end
  end
end
