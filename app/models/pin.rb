require 'open-uri'
require 'timeout'

class Pin < ActiveRecord::Base
  attr_accessor :image_url
  attr_accessible :description, :image, :image_remote_url, :image_url

  # Validations
  before_validation :download_remote_image, :if => lambda { |pin| pin.image_url.present? }

  validates_attachment :image, presence: true,
                   content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']},
                   size: { less_than: 5.megabytes }
  validates :description, presence: true
  validates :user_id, presence: true

  #Relationships
  belongs_to :user
  has_attached_file :image, :styles => { :medium => "320x240>", :thumb => "100x100>" }
  has_attached_file :image_remote_url, :styles => { :medium => "320x240>", :thumb => "100x100>" }
  #has_attached_file :image, styles: { medium: "320x240>" }

  # Need for remote image uploading

  private
  
    def image_url_provided?
      !self.image_url.blank?
    end
    
    def download_remote_image
    return if self.image.present?
    begin
      Timeout::timeout(2) do
        self.image = URI.parse(image_url)
        self.image_remote_url = image_url
      end
    rescue Exception => e
      Rails.logger.error "Failed to download image from \"#{image_url}\": #{e.message}"
    end
  end

end
