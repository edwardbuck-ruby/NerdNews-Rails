# encoding: UTF-8
require 'spec_helper'

describe "Tags" do
  before do
    admin = FactoryGirl.create(:admin_user)
    login admin
  end
  it "should make a new tag" do
    visit tags_url
    click_on "جدید"
    current_path.should eq(new_tag_path)
    fill_in 'نام', with: "tag"
    click_button "ایجاد"
  end
  it "should edit a tag" do
    tag = FactoryGirl.create(:tag)
    visit tags_url
    click_on "ویرایش"
    fill_in 'نام', with: 'edited'
    click_button 'تگ'
    tag.reload.name.should == 'edited'
    page.should have_content 'موفقیت'
  end
end
