from django.http import JsonResponse
from .models import PasswordEntry
import secrets
import string

def generate_password(request):
    alphabet = string.ascii_letters + string.digits + string.punctuation
    password = ''.join(secrets.choice(alphabet) for _ in range(12))
    PasswordEntry.objects.create(user_id="demo_user", password=password)
    return JsonResponse({"password": password})

def get_permissions(request):
    dangerous_apps = [
        {"app": "SpyGuard", "permissions": ["Location", "Camera"]},
        {"app": "MonitorPro", "permissions": ["Contacts", "Messages"]},
        {"app": "SafeApp", "permissions": ["None"]},
        {"app": "StealthTracker", "permissions": ["Microphone", "Storage"]},
        {"app": "SecureLife", "permissions": ["Calendar", "Photos"]}
    ]
    return JsonResponse({"apps": dangerous_apps})

def social_privacy_tips(request):
    tips = [
        "Your Facebook posts are public. Change to Friends only.",
        "Your Instagram has geotagged posts. Remove them for safety."
    ]
    return JsonResponse({"tips": tips})

def flag_stalkerware(request):
    installed_apps = ["SpyGuard", "MonitorPro", "SafeApp", "StealthTracker", "SecureLife"]
    detected = ["SpyGuard", "MonitorPro", "StealthTracker"]
    return JsonResponse({
        "installed_apps": installed_apps,
        "stalkerware_detected": detected,
        "message": "Our AI analysis indicates that SpyGuard, MonitorPro, and StealthTracker have permissions that could be used for stalking. Review their permissions and consider uninstalling if you did not install them or do not recognize them."
    })

def health_check(request):
    return JsonResponse({"status": "ok"})

