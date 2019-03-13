require 'test_helper'

class ComponentLinkTest < ActiveSupport::TestCase
  setup do
    @component1 = Component.create!(label: 'nic_port_one')
    @component2 = Component.create!(label: 'nic_port_two')
  end

  test 'components are unlinked' do
    assert_empty @component1.linked_components
    assert_empty @component2.linked_components
  end

  test 'component link created both ways' do
    assert_not @component1.linked_components.include?(@component2), 'Component should not already be linked'
    assert_not @component2.linked_components.include?(@component1), 'Component should not already be linked bidirectionally'
    @component1.linked_components << @component2
    assert @component1.save, 'Component should have saved'
    assert @component1.linked_components.include?(@component2), 'Component link not established'
    assert @component2.linked_components.include?(@component1), 'Component link not established bidirectionally'
  end

  test 'component link deleted both ways' do
    @component1.linked_components << @component2
    assert @component2.linked_components.include?(@component1), 'Component link not established bidirectionally'
    @component1.linked_components.destroy(@component2)
    assert_not @component1.linked_components.include?(@component2), 'Component should not be linked anymore'
    assert_not @component2.linked_components.include?(@component1), 'Component should not be linked back anymore'
  end
end
