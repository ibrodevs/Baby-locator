from django.urls import path

from .views import ChildrenView, LoginView, MeView, RegisterParentView

urlpatterns = [
    path("register/", RegisterParentView.as_view()),
    path("login/", LoginView.as_view()),
    path("me/", MeView.as_view()),
    path("children/", ChildrenView.as_view()),
]
