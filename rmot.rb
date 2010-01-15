#!/usr/bin/env ruby
=begin

    rmot is a motivator generator written in ruby with rmagick.

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
IMG_WITDH    = 800
IMG_HEIGHT   = 600
THUMB_WIDTH  = 600
THUMB_HEIGHT = 400
TITLE_YOFFSET =  THUMB_HEIGHT / 2 + 10
TITLE_PSIZE  = 69
MOTIVATOR_PSIZE = 42 / 2


# user provided options
Params = Struct.new(:src, :title, :motivator, :output).new

# parse ARGV
opts = OptionParser.new do |o|
    o.banner = "usage: #{__FILE__} [options] image"

    o.on('-h', '--help', 'show this help') do
        puts o
        exit
    end

    o.on('-t', '--title TITLE', String, 'set the title') do |t|
        Params.title = t
    end

    o.on('-m', '--motivator SENTENCE', String, 'set the motivator') do |m|
        Params.motivator = m
    end

    o.on('-o', '--output FILENAME', String, 'output file') do |f|
        Params.output = f
    end
end
opts.parse!

if ARGV.size != 1
    puts opts
    exit
else
    Params.src = ARGV.first
end

# create black caneva
img  = Magick::Image.new(IMG_WITDH, IMG_HEIGHT) do
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
    text.annotate(img, 0, 0, 0, TITLE_YOFFSET, Params.title) do
        self.fill = 'white'
    end
end

# add motivator
text.pointsize = MOTIVATOR_PSIZE
text.font_family = 'roman'
if Params.motivator
    text.annotate(img, 0, 0, 0, TITLE_YOFFSET + 42, Params.motivator) do
        self.fill = 'white'
    end
end

# load src
isrc = Magick::Image.read(Params.src).first
thumb = isrc.resize_to_fill(THUMB_WIDTH, THUMB_HEIGHT)
thumb.border!(BORDER_WIDTH, BORDER_WIDTH, 'black')
thumb.border!(BORDER_WIDTH, BORDER_WIDTH, 'white')

motivator = img.composite(thumb, Magick::CenterGravity, 0, -35, Magick::OverCompositeOp)

# show or save the result
if Params.output
    motivator.write(Params.output)
else
    motivator.display
end
