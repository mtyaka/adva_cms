class Test::Unit::TestCase
  def grant(user, role, context)
    user.roles.clear
    user.roles << Rbac::Role.build(role, :context => context)
  end

  share :is_superuser do
    before { grant @controller.current_user, :superuser, @site }
  end

  share :is_admin do
    before { grant @controller.current_user, :admin, @site }
  end

  share :is_moderator do
    before { grant @controller.current_user, :moderator, @section || @site }
  end

  share :is_user do
    before { @controller.current_user.roles.clear }
  end

  share :is_anonymous do
    before { @controller.current_user.roles.clear; stub(@controller.current_user).anonymous?(true) }
  end
end