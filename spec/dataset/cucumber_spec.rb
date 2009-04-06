require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

$:.unshift(File.dirname(__FILE__) + '/../stubs')
require "mini_rails"

require 'cucumber/rails/world'
require 'cucumber/rails/rspec'
Cucumber::Rails::World.class_eval do
  include Dataset
end

describe Cucumber::Rails::World do
  # include SandboxedOptions
  
  it 'should have a dataset method' do
    world = Class.new(Cucumber::Rails::World)
    world.should respond_to(:dataset)
  end
  
  it 'should load the dataset when the feature is run' do
    load_count = 0
    my_dataset = Class.new(Dataset::Base) do
      define_method(:load) do
        load_count += 1
      end
    end
    
    Cucumber::Rails::World.class_eval do
      dataset(my_dataset)
    end
    
    step_mother = Object.new
    step_mother.extend(Cucumber::StepMother)
    $x = $y = nil
    step_mother.Given /y is (\d+)/ do |n|
      $y = n.to_i
    end
    visitor = Cucumber::Ast::Visitor.new(step_mother)
    visitor.options = {}
    
    scenario = Cucumber::Ast::Scenario.new(
      background=nil,
      comment=Cucumber::Ast::Comment.new(""),
      tags=Cucumber::Ast::Tags.new(98, []), 
      line=99,
      keyword="",
      name="", 
      steps=[
        Cucumber::Ast::Step.new(8, "Given", "y is 5")
      ])
    visitor.visit_feature_element(scenario)
    
    load_count.should be(1)
  end
end