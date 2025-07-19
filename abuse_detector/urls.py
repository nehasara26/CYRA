from django.urls import path
from .views import abuse_detector_view

urlpatterns = [
    path('', abuse_detector_view, name='abuse_detector'),
]
