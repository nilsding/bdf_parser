# bdf_parser.rb -- quick and dirty pure ruby glyph bitmap distribution format (BDF) parser
# frozen_string_literal: true

module BDF
  class Font
    attr_accessor :name, :version, :properties, :chars

    def initialize
      @name = ""
      @version = ""
      @properties = {}
      @chars = {}
    end
  end

  Char = Struct.new(:encoding, :swidth, :dwidth, :bbx, :bitmap)
  Offset = Struct.new(:x, :y)
  BoundingBox = Struct.new(:width, :height, :x, :y)

  class Parser
    def initialize(io)
      @io = io
    end

    def parse
      io.each_line(&method(:parse_line))
      raise "invalid BDF" unless font.frozen?
      font
    end

    private

    attr_reader :io, :font

    def parse_line(line)
      keyword, args = line.chomp.split(" ", 2)

      return parse_property_line(keyword, args) if @in_properties
      return parse_char_line(keyword, args) if @in_char

      parse_global_line(keyword, args)
    end

    def parse_property_line(keyword, args)
      if keyword == "ENDPROPERTIES"
        unless @remaining_properties.zero?
          raise "remaining properties should be 0, got #{@remaining_properties}"
        end

        @in_properties = false
        return
      end

      font.properties[keyword.downcase.to_sym] =
        args[0] == '"' ? args.gsub(/^"|"$/, "") : args.to_i
      @remaining_properties -= 1
    end

    def parse_char_line(keyword, args)
      if keyword == "ENDCHAR"
        @in_char = false
        @in_bitmap = false
        font.chars[@char_data[:identifier]] =
          Char.new(
            *@char_data.slice(:encoding, :swidth, :dwidth, :bbx, :bitmap)
               .values
          )
        return
      end

      if keyword == "BITMAP"
        @in_bitmap = true
        return
      end

      if @in_bitmap
        @char_data[:bitmap] << keyword.to_i(16)
        return
      end

      if %w[ENCODING SWIDTH DWIDTH BBX].include?(keyword)
        num_args = args.split(" ").map(&:to_i)
        @char_data[keyword.downcase.to_sym] =
          case num_args.count
          when 1
            num_args.first
          when 2
            Offset.new(*num_args)
          when 4
            BoundingBox.new(*num_args)
          end
      end
    end

    def parse_global_line(keyword, args)
      case keyword
      when "STARTFONT"
        @in_properties = false
        @in_char = false
        @font = Font.new

        font.version = args
      when "ENDFONT"
        font.chars.freeze
        font.properties.freeze
        font.freeze
      when "FONT"
        font.name = args
      when "STARTPROPERTIES"
        @in_properties = true
        @remaining_properties = args.to_i
      when "STARTCHAR"
        @in_char = true
        @char_data = { identifier: args, bitmap: [] }
      end
    end
  end
end
