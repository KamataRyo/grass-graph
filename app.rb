# coding: utf-8
require 'sinatra'
require 'rsvg2'
require 'haml'

get '/' do
end

get '/graph/*' do |id|
  width  = params[:width]  ? params[:width].to_i : 710
  height = params[:height] ? params[:height].to_i : 110
  `curl https://github.com/#{id} | awk '/<svg/,/svg>/' | sed -e 's@<svg@<svg xmlns="http://www.w3.org/2000/svg"@' > ./tmp/grass.svg`

  svg_data = File.open('./tmp/grass.svg').read
  png_data = ImageConvert.svg_to_png(svg_data, width, height)

  content_type 'png'
  png_data
end

class ImageConvert
  def self.svg_to_png(svg, width, height)
    svg = RSVG::Handle.new_from_data(svg)

    b = StringIO.new
    Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, width, height) do |surface|
      context = Cairo::Context.new(surface)
      context.render_rsvg_handle(svg)
      context.rotate(2.to_f)
      surface.write_to_png(b)
      surface.finish
    end

    return b.string
  end
end