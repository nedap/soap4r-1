# encoding: UTF-8
require 'helper'
require 'testutil'
require 'soap/marshal'
require 'rbconfig'


module WSDL; module SOAP


class TestSection < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))
  RUBY = RbConfig::CONFIG['RUBY_INSTALL_NAME']

  def setup
    system("cd #{DIR} && #{RUBY} #{pathname("../../../../../bin/xsd2ruby.rb")} --xsd #{pathname("section.xsd")} --classdef --force --quiet")
  end

  def teardown
    unless $DEBUG
      File.unlink(pathname("mysample.rb")) if File.file?(pathname('mysample.rb'))
    end
  end

  def test_classdef
    compare("expectedClassdef.rb", "mysample.rb")
  end

  def test_marshal
    # avoid name crash (<item> => an Item when a class Item is defined)
    item = ::Object.constants.detect { |c| c.to_s == "Item" }
      ::Object.instance_eval { remove_const(item) } if item    

    TestUtil.require(DIR, 'mysample.rb')
    s1 = Section.new(1, "section1", "section 1", 1001, Question.new("q1"))
    s2 = Section.new(2, "section2", "section 2", 1002, Question.new("q2"))
    org = SectionArray[s1, s2]
    obj = ::SOAP::Marshal.unmarshal(::SOAP::Marshal.marshal(org))
    assert_equal(SectionArray, obj.class)
    assert_equal(Section, obj[0].class)
    assert_equal(Question, obj[0].firstQuestion.class)
  end

private

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end
end


end; end
