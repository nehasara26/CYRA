from django.urls import path
from . import views

urlpatterns = [
    path('generate-password/', views.generate_password),
    path('get-permissions/', views.get_permissions),
    path('social-tips/', views.social_privacy_tips),
    path('flag-stalkerware/', views.flag_stalkerware),
    # path('summarize-privacy/', views.summarize_privacy_risks),  # ✂️ Removed since not used
    path('health/', views.health_check),

]
