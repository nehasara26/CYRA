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
        {"app": "UnknownCam", "permissions": ["Camera", "Microphone"]},
        {"app": "MsgSpy", "permissions": ["SMS", "Contacts"]}
    ]
    return JsonResponse({"apps": dangerous_apps})

def social_privacy_tips(request):
    tips = [
        "Your Facebook posts are public. Change to Friends only.",
        "Your Instagram has geotagged posts. Remove them for safety."
    ]
    return JsonResponse({"tips": tips})

def flag_stalkerware(request):
    known_stalkerware = {"FlexiSPY", "mSpy", "Spyzie", "Hoverwatch", "XNSPY"}
    installed_apps = ["WhatsApp", "Facebook", "FlexiSPY", "Instagram"]
    detected = [app for app in installed_apps if app in known_stalkerware]
    return JsonResponse({
        "installed_apps": installed_apps,
        "stalkerware_detected": detected,
        "message": "Potential stalkerware found." if detected else "No stalkerware detected."
    })
def health_check(request):
    return JsonResponse({"status": "ok"})
