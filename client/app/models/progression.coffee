Backbone = require 'backbone'

# ProgressionModel
# Backbone wrapper for Onboarding's progression object
# This object is returned by the method onboarding.getProgression
# It contains three properties
# current (int), total (int) and labels (array)
module.exports = class ProgressionModel extends Backbone.Model
