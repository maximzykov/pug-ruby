# encoding: UTF-8
# frozen_string_literal: true

module Jade
  #
  # Defines Jade compiler configuration.
  #
  # The documentation for Jade compiler can be found here:
  # - {http://web.archive.org/web/20160404025722/http://jade-lang.com/api/}
  # - {https://github.com/pugjs/pug/blob/v1.x.x/bin/jade.js}
  #
  class Config < JadePug::Config
    def initialize
      super
      @filename      = nil
      @doctype       = nil
      @pretty        = false
      @self          = false
      @compile_debug = false
      @globals       = []
      @name          = "template"
    end
  end
end
