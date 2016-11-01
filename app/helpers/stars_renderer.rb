module StarsRenderer
  def render_stars(rating, template)
    @rating = rating
    @template = template
    content_tag :div, :class => 'stars' do
      star_images.collect {|star| concat(star)}
    end
  end

  private

  def star_images
    stars = []
    (0...5).map do |position|
      stars << star_image(((@rating-position)*2).floor)
    end
    stars
  end

  def star_image(value)
    tag("i", :class => "fa #{star_type(value)}", "aria-hidden" => "true")
  end

  def star_type(value)
    if value <= 0
      'fa-star-o'
    elsif value == 1
      'fa-star-half-o'
    else
      'fa-star'
    end
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end
