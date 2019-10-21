module ApplicationHelper
  def datepicker_input form, field, st
    content_tag :td, :data => {:provide => 'datepicker', 'date-format' => 'yyyy-mm-dd', 'date-autoclose' => 'true'} do
      form.text_field field, class: 'form-control', placeholder: 'YYYY-MM-DD', value: st
    end
  end
  
  def static_map polyline
    base = "https://maps.googleapis.com/maps/api/staticmap?size=150x100&path=weight:3%7Ccolor:red%7Cenc:"

    url = base + polyline
    if ENV["GOOGLE_API_KEY"]
      puts "Found google static map key in environment"
      url += "&key="
      url += ENV["GOOGLE_API_KEY"]
    end
    return image_tag url
  end
  
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
  
  def profile_for(user, options = { medium: true, size: 100})
    size = options['size'].to_s
    if options[:medium] == true
      profile_url = user.profile_medium
    else
      profile_url = user.profile
    end
    image_tag(profile_url, :size => "#{size}x#{size}",
                          class: "gravatar")
  end
  
end
