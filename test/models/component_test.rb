require 'test_helper'

class ComponentTest < ActiveSupport::TestCase
  test 'Components have parent-child relationship' do
    c1 = Component.create(identifier: 'c1')
    c2 = Component.create(identifier: 'c2', parent: c1)
    assert c2.parent == c1
    assert c1.children.find(c2.id)
  end
end
