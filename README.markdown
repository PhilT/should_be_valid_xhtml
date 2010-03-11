should be_valid_xhtml
---------------------

should be_valid_xhtml is a plugin for RSpec that allows you to validate your (X)HTML templates using the W3C Validator (http://validator.w3.org) SOAP web service. It uses RSpec view tests to enable validation of XHTML fragments. In other words, the template without a layout. Validator response is parsed using Nokogiri XML parser. Responses from the validator are cached so if the template hasn't changed the W3C web service will not be called.

Motivation
----------

* An RSpec validator did not seem to exist
* Some of the assert* validators seemed to be broken due to changes in the W3C validator service
* My team does not do view testing. We rely on integration tests so it seemed a good way to utilize view tests
* It validates just the template for that specific view test
* I wanted to separate validation from other types of tests

Usage
-----

It's simply a matter of setting up any assigns in the view, calling render then checking the response body. Any templating language will work such as HAML (my preference), ERB, etc:

    (In spec/views/users/index.html.haml_spec.rb)
    describe 'users/index.html.haml' do
      it do
        assigns[:users] = [mock_model(User, :name => 'Joe')]
        render
        response.body.should be_valid_xhtml
      end
    end

Two methods exist for checking XHTML 1.0 Strict and HTML 4.01 Transitional:
    be_valid_xhtml(fragment = true)
    be_valid_html(fragment = true)

Both accept a parameter for telling the validator whether the content is a fragment or full document. The default is a fragment but to check your layouts you may want some views to validate the whole document. It can be done like this:

    (In spec/views/users/index.html.erb_spec.rb)
    describe 'users/index.html.erb' do
      it do
        assigns[:users] = [mock_model(User, :name => 'Joe')]
        render 'users/index.html.erb', :layout => 'application'
        response.body.should be_valid_xhtml(false)
      end
    end

Improvements
------------
I am looking for feedback on this. Perhaps creating a separate example group for validation tests would be more useful as well as having the option to not run them as part of the main rspec tests.


Credits
-------

Thanks to Scott Raymond's original assert_valid_markup and CodeMonkeySteve's assert-valid-asset and the various forks on github.

