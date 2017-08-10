require 'test_helper'

class RecordBroadcastJobTest < ActiveJob::TestCase
  test "format include" do
    input = ['any', 'thing', {'here'=>'one'}, {'doge'=>['such', 'wow']}, {'nest'=>{'more'=>'data'}}, {'nest_array'=>{'do'=>['keep', 'going']}}]
    expected = {"any"=>{}, "thing"=>{}, "here"=>{:include=>{"one"=>{}}}, "doge"=>{:include=>{"such"=>{}, "wow"=>{}}}, "nest"=>{:include=>{"more"=>{:include=>{"data"=>{}}}}}, "nest_array"=>{:include=>{"do"=>{:include=>{"keep"=>{}, "going"=>{}}}}}}
    output = RecordBroadcastJob.new.send :format_include, input
    assert_equal output, expected, "Format associaions include did not output expected Hash"
  end
end
