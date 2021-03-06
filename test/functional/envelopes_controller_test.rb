require 'test_helper'

class EnvelopesControllerTest < ActionController::TestCase
  setup do
    @user = login
  end

  test "should require a user to be logged in" do
    logout

    envelope = create :income_envelope, user: @user

    get :index
    assert_redirected_to controller: 'sessions', action: 'new'

    get :show, id: envelope.to_param
    assert_redirected_to controller: 'sessions', action: 'new'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organized_envelopes)

    assert_select 'section#dashboard' do
      tags = css_select('.name').map {|tag| tag.to_s}.join
      Envelope.owned_by(@user.id).each do |envelope|
        assert tags.include?(ERB::Util.html_escape(envelope.name)), "The envelope named \"#{envelope.name}\" is missing"
      end
    end
  end

  test "should show an envelope" do
    envelope = create :income_envelope, user: @user
    get :show, id: envelope.to_param
    assert_response :success

    assert_not_nil assigns(:all_envelopes)
    assert_not_nil assigns(:organized_envelopes)
    assert_not_nil assigns(:envelope)
    assert_not_nil assigns(:envelope_options_for_select)
    assert_equal Date.today - 1.month, assigns(:start_date)
    assert_equal Date.today, assigns(:end_date)
    assert_nil assigns(:show_transfers)
    assert_not_nil assigns(:transactions)
  end

  test "should create an envelope" do
    new_envelope_name = 'brand new envelope'

    assert_difference("Envelope.count", 1) do
      post :create, { envelope: {
        name: new_envelope_name,
        user_id: @user.id,
        expense: {
          amount: 3.45,
          occurs_on_day: 3,
          frequency: :monthly
        }
      }}
    end

    new_envelope = Envelope.where(name: new_envelope_name).first

    assert_not_nil new_envelope
    assert_equal @user.id, new_envelope.user_id
    assert_not_nil new_envelope.expense
    assert_equal 3.45, new_envelope.expense.amount
  end

  test "should update an envelope" do
    fuel = create :envelope, name: 'Fuel', user: @user, expense: nil

    put :update, {
      id: fuel.id,
      envelope: {
        name: 'Fuel!',
        expense: {
          amount: '120.5'
        }
      },
      format: :js
    }

    assert_response :success

    fuel = Envelope.find(fuel.id)

    assert_equal 120.5, fuel.expense.amount
    assert_equal 'Fuel!', fuel.name
  end

  test "formatted envelope expense amount should update correctly" do
    fuel = create :envelope, name: 'Fuel', user: @user, expense: nil

    put :update, {
      id: fuel.id,
      envelope: {
        name: 'Fuel!',
        expense: {
          amount: '$121.50'
        }
      },
      format: :js
    }

    assert_response :success

    fuel = Envelope.find(fuel.id)

    assert_equal 121.5, fuel.expense.amount
  end

  test "should show envelopes to fill" do
    create :envelope, user: @user
    create :income_envelope, user: @user

    get :fill
    assert_response :success

    assert_not_nil assigns(:organized_envelopes)
    assert_not_nil assigns(:available_cash_envelope)
  end

  test "should fill the envelopes with money" do
    create :income_envelope, user: @user
    auto = create :envelope, name: 'Auto', user: @user, expense: nil
    food = create :envelope, name: 'Food', user: @user, expense: nil
    
    assert_difference("Transaction.count", 4) do
      post :perform_fill, {
        "fill_envelope_#{auto.id}" => '$1.23',
        "fill_envelope_#{food.id}" => '$2.34'
      }
    end

    assert_redirected_to controller: 'envelopes', action: 'index'
  end

end
