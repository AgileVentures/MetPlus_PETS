require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the MainHelper. For example:
#
# describe MainHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe StarsRenderer, type: :helper do
  describe '#render_stars' do
    it 'rating 0' do
      expect(render_stars(0)).to eq '<div class="stars">
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  </div>'.split("\n").map(&:strip).join
    end
    it 'rating 5' do
      expect(render_stars(5)).to eq '<div class="stars">
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  </div>'.split("\n").map(&:strip).join
    end
    it 'rating 2.5' do
      expect(render_stars(2.5)).to eq '<div class="stars">
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star-half-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  </div>'.split("\n").map(&:strip).join
    end
    it 'rating 1.4' do
      expect(render_stars(1.4)).to eq '<div class="stars">
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  </div>'.split("\n").map(&:strip).join
    end
    it 'rating 3.6' do
      expect(render_stars(3.6)).to eq '<div class="stars">
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star" aria-hidden="true"></i>
                  <i class="fa fa-star-half-o" aria-hidden="true"></i>
                  <i class="fa fa-star-o" aria-hidden="true"></i>
                  </div>'.split("\n").map(&:strip).join
    end
  end
end
