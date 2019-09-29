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
end
