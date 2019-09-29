module EventsHelper
  
  def show_trophy points
    images = ['https://bucketroyal.s3.amazonaws.com/JerseyTracker/gold_trophy.png',
    'https://bucketroyal.s3.amazonaws.com/JerseyTracker/silver_trophy.png',
    'https://bucketroyal.s3.amazonaws.com/JerseyTracker/bronze_trophy.png',
    ''
    ]
    if points > 3
      points = 3
    end
    image_tag(images[points-1], options: {height: 15, width: 15})
  end
  
  def cat_icon cat
    icons = {'sprint' => 'https://bucketroyal.s3.amazonaws.com/JerseyTracker/small_sprint.png',
            'kom' => 'https://bucketroyal.s3.amazonaws.com/JerseyTracker/small_kom.png'}
    return icons[cat]
  end
  
end
