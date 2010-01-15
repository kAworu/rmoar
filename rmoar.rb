#!/usr/bin/env ruby
=begin

    RMOAR is a motivator generator written in ruby with rmagick.

    Copyright (c) 2008-2009, Alexandre Perrin <kaworu@kaworu.ch>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
    4. Neither the name of the author nor the names of its contributors
       may be used to endorse or promote products derived from this software
       without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.

=end

require 'optparse'
require 'RMagick'


# contants
BORDER_WIDTH = 2
TITLE_PSIZE  = 69
MOTIVATOR_PSIZE = 42 / 2

# user provided options
Params = Struct.new(:src, :title, :motivator, :output, :width, :height, :crop).new

# parse ARGV
opts = OptionParser.new do |o|
    o.banner = "usage: #{__FILE__} [options] image"
    o.on('-h', '--help',                        'show this help')              { puts o; exit }
    o.on('-t', '--title TITLE',        String,  'set the title')               { |t| Params.title     = t }
    o.on('-m', '--motivator SENTENCE', String,  'set the motivator')           { |m| Params.motivator = m }
    o.on('-o', '--output FILENAME',    String,  'output file')                 { |f| Params.output    = f }
    o.on('-c', '--crop',                        'crop src image while resize') {     Params.crop      = true }
    o.on('-d', '--dimensions WxH',     String,  'resize src (ex: 800x600)')   do |d|
        w, h = d.split('x').map { |e| e.to_i }
        if w == 0 or h == 0
            raise ArgumentError.new("bad dimensions argument: #{d}")
        end
        Params.width  = w
        Params.height = h
    end
end
opts.parse!

if ARGV.size != 1
    puts opts
    exit
else
    Params.src = ARGV.first
end

# load src
img = Magick::Image.read(Params.src).first
if Params.width and Params.height
    if Params.crop
        img.resize_to_fill!(Params.width, Params.height)
    else
        img.resize_to_fit!(Params.width, Params.height)
    end
end
img.border!(BORDER_WIDTH, BORDER_WIDTH, 'black')
img.border!(BORDER_WIDTH, BORDER_WIDTH, 'white')

THUMB_WIDTH  = img.columns
THUMB_HEIGHT = img.rows
IMG_WITDH    = THUMB_WIDTH + 100
IMG_HEIGHT   = THUMB_HEIGHT + 200
TITLE_YOFFSET =  THUMB_HEIGHT / 2 - 20

# create black caneva
background  = Magick::Image.new(IMG_WITDH, IMG_HEIGHT) do
    self.background_color = 'black'
end

text = Magick::Draw.new
text.font_family = 'times'
text.font_style  = Magick::NormalStyle
text.font_weight = Magick::NormalWeight
text.pointsize   = TITLE_PSIZE
text.gravity     = Magick::CenterGravity

# add title
if Params.title
    text.annotate(background, 0, 0, 0, TITLE_YOFFSET, Params.title) do
        self.fill = 'white'
    end
end

# add motivator
text.pointsize = MOTIVATOR_PSIZE
text.font_family = 'roman'
if Params.motivator
    text.annotate(background, 0, 0, 0, TITLE_YOFFSET + 42, Params.motivator) do
        self.fill = 'white'
    end
end

moar = background.composite(img, Magick::CenterGravity, 0, -60, Magick::OverCompositeOp)

# show or save the result
if Params.output
    moar.write(Params.output)
else
    moar.display
end
