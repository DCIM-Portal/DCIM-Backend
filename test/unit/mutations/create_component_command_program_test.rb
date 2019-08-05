require 'test_helper'

module Mutations
  class CreateComponentCommandProgramTest < ActiveSupport::TestCase
    test 'interpret component command program' do
      mutation = CreateComponentCommandProgram.new(object: nil, context: nil)
      input_program = [
        {
          'componentId' => 'my component id',
          'step' => '2',
          'command' => 'power_on'
        },
        {
          componentId: 'my component id',
          step: 1,
          command: 'power_off'
        },
        {
          componentId: 'my component id 2',
          step: 2,
          command: 'power_reset'
        }
      ]
      expected = {
        1 => [
          {
            'componentId' => 'my component id',
            'command' => 'power_off'
          }
        ].to_set,
        2 => [
          {
            'componentId' => 'my component id',
            'command' => 'power_on'
          },
          {
            'componentId' => 'my component id 2',
            'command' => 'power_reset'
          }
        ].to_set
      }

      result = mutation.interpret_program(input_program)

      assert_equal(1, result[1].size)
      assert_equal(2, result[2].size)
      assert_equal(expected, result)
    end
  end
end
