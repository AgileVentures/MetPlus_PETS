# Module that will render the stars
# Usage Include the module in the helper
# Inside the help call it using
# render_stars(1)
# This will render 1 star
module StarsRenderer
  def render_stars(rating)
    @rating = rating
    content_tag :div, class: 'stars' do
      star_images.map { |star| concat(star) }
    end
  end

  private

  def star_images
    stars = []
    (0...5).map do |position|
      stars << star_image((@rating - position).round(1))
    end
    stars
  end

  def star_image(value)
    content_tag('i', nil,
                class: ['fa', star_type(value)], 'aria-hidden': 'true')
  end

  def star_type(value)
    if value <= 0.3
      'fa-star-o'
    elsif value > 0.3 && value < 0.9
      'fa-star-half-o'
    else
      'fa-star'
    end
  end
end
