from django.urls import path
from .views import abuse_detector_view
from .views_api import api_upload_image, api_generate_takedown

urlpatterns = [
    path('', abuse_detector_view, name='abuse_detector'),
    path('api/upload/', api_upload_image, name='api_upload_image'),
    path('api/takedown/', api_generate_takedown, name='api_generate_takedown'),
]
