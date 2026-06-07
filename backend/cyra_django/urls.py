from django.contrib import admin
from django.urls import path, include  # ⬅️ You must import 'include'

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('abuse_detector.urls')),  # ⬅️ This line connects your app
    path('api/', include('privacytoolkit.urls')),
]
