require 'flickraw'

module Fetcher
  class Flickr
    USER_ID = '33668819@N03'.freeze
    PHOTOSET_ID = 72157647560300303
    EXTERNAL_SERVICE_NAME = 'flickr'.freeze

    def initialize
      authenticate
      fetch_and_update
      binding.pry
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
      fetch_individual_photos # dont have to do this if we pass more `extras` options
      create_photos
    end

    def fetch_all_newer_photos(page = 1)
      response = get_photos(page: page)
      photos = response['photo']
      oldest_external_photo = photos.min_by { |photo| photo['dateupload'] }
      oldest_external_photo_date = epoch_timestamp_to_date(oldest_external_photo['dateupload'])
      binding.pry

      (new_photos << photos).flatten

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

    def get_photos(user_id: USER_ID, photoset_id: PHOTOSET_ID, per_page: 100, page: 1, extras: 'date_upload')
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

    def fetch_individual_photos
      @photos_to_be_created = []
      @new_photos.each do |photo|
        @photos_to_be_created << flickr.photos.getInfo(photo_id: photo['id'])
      end
    end

    def create_photos
      # @photos_to_be_created.each do |photo|
      #   Photo.create!(
      #     title: ,
      #     description: ,
      #     url_thumb: ,
      #     url_medium: ,
      #     url_large: ,
      #     url_original: ,
      #     external_service_id: ,
      #     external_date: ,
      #     external_service_name: EXTERNAL_SERVICE_NAME
      #   )
      # end
    end
  end
end
