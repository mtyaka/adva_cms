require File.dirname(__FILE__) + '/../spec_helper'

describe "Forum views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    Thread.current[:site] = stub_site

    assigns[:site] = @site = stub_site
    assigns[:section] = @forum = stub_forum
    assigns[:topics] = @topics = [@topic = stub_topic]
    @board = stub_board

    Section.stub!(:find).and_return @forum

    template.stub!(:link_to_topic).and_return 'link_to_topic'
    template.stub!(:link_to_last_post).and_return 'link_to_last_post'
    template.stub!(:will_paginate).and_return 'will_paginate'
    template.stub!(:datetime_with_microformat).and_return 'Once upon a time ...'

    template.stub!(:render).with hash_including(:partial => 'forum/topic')
  end

  # describe "the show view" do
  #   it "with a current board assigned renders the board partial" do
  #     assigns[:board] = @board
  #     template.should_receive(:render).with hash_including(:partial => 'board')
  #     render "forum/show"
  #   end
  # 
  #   it "with a forum that has boards renders the boards partial" do
  #     template.should_receive(:render).with hash_including(:partial => 'boards')
  #     render "forum/show"
  #   end
  # 
  #   it "with a boardless forum assigned renders the forum partial" do
  #     @forum.stub!(:boards).and_return []
  #     template.should_receive(:render).with hash_including(:partial => 'forum')
  #     render "forum/show"
  #   end
  # end
  # 
  describe "the boards partial" do
    before :each do
      @board.stub!(:topics_count).and_return(5)
      @board.stub!(:comments_count).and_return(5)
    end
    
    it "renders a list of boards" do
      render "forum/_boards"
      response.should have_tag('table[id=?][class=?]', 'boards', 'list')
    end
  end
  
  # describe "the board partial" do
  #   describe 'with an empty topics collection assigned' do
  #     before :each do
  #       assigns[:board] = @board
  #       @forum.stub!(:topics_count).and_return 0
  #     end
  # 
  #     it 'shows a notice that no topics are present' do
  #       render "forum/_board"
  #       response.body.should =~ /there are no topics/i
  #     end
  # 
  #     it 'shows a link to new_topic_path' do
  #       template.should_receive(:new_board_topic_path).with(@forum, @board).and_return 'new_board_topic_path'
  #       render "forum/_board"
  #     end
  #   end
  # 
  #   describe 'with a non-empty topics collection assigned' do
  #     it "renders the topics partial" do
  #       @forum.stub!(:topics_count).and_return 2
  #       template.should_receive(:render).with hash_including(:partial => 'topics')
  #       render "forum/_board"
  #     end
  #   end
  # end
  # 
  # describe "the forum partial" do
  #   describe 'with an empty topics collection assigned' do
  #     before :each do
  #       @forum.stub!(:topics_count).and_return 0
  #     end
  # 
  #     it 'shows a notice that no topics are present' do
  #       render "forum/_forum"
  #       response.body.should =~ /there are no topics/i
  #     end
  # 
  #     it 'shows a link to new_topic_path' do
  #       template.should_receive(:new_topic_path).and_return 'new_topic_path'
  #       render "forum/_forum"
  #     end
  #   end
  # 
  #   describe 'with a non-empty topics collection assigned' do
  #     it "renders the topics partial" do
  #       @forum.stub!(:topics_count).and_return 2
  #       template.should_receive(:render).with hash_including(:partial => 'topics')
  #       render "forum/_forum"
  #     end
  #   end
  # end
  # 
  # describe "the topic partial" do
  #   before :each do
  #     template.stub!(:topic).and_return @topic
  #   end
  #   
  #   it "displays a link to the topic" do
  #     template.should_receive(:link_to_topic).and_return 'link_to_topic'
  #     render "forum/_topic"
  #   end
  # 
  #   it "displays a link to the latest post" do
  #     template.should_receive(:link_to_last_post).and_return 'link_to_last_post'
  #     render "forum/_topic"
  #   end
  # 
  #   it "should display the topic's last_author_name" do
  #     @topic.should_receive(:last_author_name)
  #     render "forum/_topic"
  #   end
  # 
  #   it "should display the topic's comment_count" do # TODO really should use a counter for that!
  #     @topic.should_receive(:comments_count)
  #     render "forum/_topic"
  #   end
  # end
end