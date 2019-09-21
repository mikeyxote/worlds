module EventsHelper
  
  def show_trophy points
    images = ['https://bucketroyal.s3.amazonaws.com/JerseyTracker/bronze_trophy.png',
    'https://bucketroyal.s3.amazonaws.com/JerseyTracker/silver_trophy.png',
    'https://bucketroyal.s3.amazonaws.com/JerseyTracker/gold_trophy.png']
    image_tag(images[points-1], options: {height: 15, width: 15})
  end
  
end
