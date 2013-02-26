require 'open-uri'

class Pin < ActiveRecord::Base
  attr_accessible :description, :image, :image_url
  # Validations
  validates :description, presence: true
  validates :user_id, presence: true
  validates_attachment :image, presence: true,
  							   content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']},
  							   size: { less_than: 5.megabytes }
  #Relationships
  belongs_to :user
  has_attached_file :image, :styles => { :medium => "320x240>", :thumb => "100x100>" }
  #has_attached_file :image, styles: { medium: "320x240>" }

  # Need for remote image uploading
  attr_accessor :image_url

  before_validation :download_remote_image, :if => :image_url_provided?

  validates_presence_of :image_remote_url, :if => :image_url_provided?, :message => 'is invalid or inaccessible'

  private
  
    def image_url_provided?
      !self.image_url.blank?
    end
    
    def download_remote_image
      self.image = do_download_remote_image
      self.image_remote_url = image_url
    end
    
    def do_download_remote_image
      io = open(URI.parse(image_url))
      def io.original_filename; base_uri.path.split('/').last; end
      io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)

    end

end
