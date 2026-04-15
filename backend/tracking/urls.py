from django.urls import path

from .views import (
    ChildLatestLocationView,
    ChildLocationHistoryView,
    ShareLocationView,
)

urlpatterns = [
    path("locations/", ShareLocationView.as_view()),
    path("children/<int:child_id>/location/", ChildLatestLocationView.as_view()),
    path("children/<int:child_id>/history/", ChildLocationHistoryView.as_view()),
]
