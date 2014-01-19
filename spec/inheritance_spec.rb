require 'spec_helper'

describe NYNY::App do
  describe 'inheritance' do
    class Parent < NYNY::App
      helpers do
        def parent_helper; :parent; end
      end

      before do
        headers['parent before'] = 'true'
      end

      after do
        headers['parent after'] = 'true'
      end

      get '/helpers' do
        parent_helper.should == :parent
      end

      get '/parent' do
        'parent'
      end
    end

    class Child < Parent
      helpers do
        def child_helper; :child; end
      end

      before do
        headers['child before'] = 'true'
      end

      after do
        headers['child after'] = 'true'
      end

      get '/helpers' do
        parent_helper.should == :parent
        child_helper.should == :child
      end

      get '/child' do
        'child'
      end
    end

    let (:parent) { Rack::MockRequest.new Parent.new }
    let (:child) { Rack::MockRequest.new Child.new }

    it 'works correctly for routes' do
      parent.get('/parent').body.should == 'parent'
      parent.get('/child').status.should == 404
      child.get('/parent').body.should == 'parent'
      child.get('/child').body.should == 'child'
    end

    it 'works correctly for before filters' do
      parent.get('/parent').headers['child before'].should be_nil
      child.get('/parent').headers['child before'].should_not be_nil
      child.get('/parent').headers['parent before'].should_not be_nil
    end

    it 'works correctly for after filters' do
      parent.get('/parent').headers['child after'].should be_nil
      child.get('/parent').headers['child after'].should_not be_nil
      child.get('/parent').headers['parent after'].should_not be_nil
    end

    it 'works correctly for helpers' do
      parent.get('/helpers')
      child.get('/helpers')
    end
  end
end