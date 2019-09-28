# bdf_parser

A quick and dirty parser for the Glyph Bitmap Distribution Format (BDF).

## Usage

```ruby
require_relative "./bdf_parser"
require "pp"

font = nil
File.open(File.expand_path("~/unifont.bdf"), "r") do |file|
  font = BDF::Parser.new(file).parse
end

p font.name
# "-gnu-Unifont-Medium-R-Normal-Sans-16-160-75-75-c-80-iso10646-1"

pp font.properties
# {:copyright=>
#   "Copyright (C) 1998-2019 Roman Czyborra, Paul Hardy,  Qianqian Fang, Andrew Miller, Johnnie Weaver, David Corbett, et al.  License GPLv2+: GNU GPL version 2 or later <http://gnu.org/licenses/gpl.html>  with the GNU Font Embedding Exception.",
#  :font_version=>"12.1.03",
#  :font_type=>"Bitmap",
#  :foundry=>"GNU",
#  :family_name=>"Unifont",
#  :weight_name=>"Medium",
#  :slant=>"R",
#  :setwidth_name=>"Normal",
#  :add_style_name=>"Sans Serif",
#  :pixel_size=>16,
#  :point_size=>160,
#  :resolution_x=>75,
#  :resolution_y=>75,
#  :spacing=>"C",
#  :average_width=>80,
#  :charset_registry=>"ISO10646",
#  :charset_encoding=>"1",
#  :underline_position=>-2,
#  :underline_thickness=>1,
#  :cap_height=>10,
#  :x_height=>8,
#  :font_ascent=>14,
#  :font_descent=>2,
#  :default_char=>65533}

pp font.chars["U+0045"]
# #<struct BDF::Char
#  encoding=69,
#  swidth=#<struct BDF::Offset x=500, y=0>,
#  dwidth=#<struct BDF::Offset x=8, y=0>,
#  bbx=#<struct BDF::BoundingBox width=8, height=16, x=0, y=-2>,
#  bitmap=[0, 0, 0, 0, 126, 64, 64, 64, 124, 64, 64, 64, 64, 126, 0, 0]>
```
