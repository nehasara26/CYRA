from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import requests
import urllib.parse
import json

IMGBB_API_KEY = "918766e3c5ed309a74613cedc23ba946"

@csrf_exempt
def api_upload_image(request):
    if request.method != 'POST':
        return JsonResponse({"error": "Only POST requests are allowed"}, status=405)
    
    if 'image' not in request.FILES:
        return JsonResponse({"error": "No image file provided"}, status=400)
        
    image = request.FILES['image']
    try:
        response = requests.post(
            f"https://api.imgbb.com/1/upload?key={IMGBB_API_KEY}",
            files={'image': image}
        )
        data = response.json()
        if response.status_code == 200 and data.get('data'):
            uploaded_image_url = data['data']['url']
            tineye_url = f"https://tineye.com/search?url={uploaded_image_url}"
            return JsonResponse({
                "status": "success",
                "uploaded_image_url": uploaded_image_url,
                "tineye_url": tineye_url
            })
        else:
            return JsonResponse({"error": "Failed to upload image to remote host"}, status=500)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
def api_generate_takedown(request):
    if request.method != 'POST':
        return JsonResponse({"error": "Only POST requests are allowed"}, status=405)
    
    # Try parsing JSON first, fallback to POST data
    try:
        if request.content_type == 'application/json':
            data = json.loads(request.body.decode('utf-8'))
        else:
            data = request.POST
    except Exception:
        data = request.POST

    link = data.get('found_link', '').strip()
    platform_email = data.get('platform_email', '').strip()
    custom_email = data.get('custom_email', '').strip()
    
    recipient = custom_email if custom_email else platform_email
    if not recipient or not link:
        return JsonResponse({"error": "Link and email recipient are required"}, status=400)
        
    takedown_subject = "Urgent Takedown Request"
    takedown_body = f"""Hello Team,

I am writing to request the removal of abusive or unauthorized content involving me.

Details:
Link: {link}
Reason: Violation of my rights and privacy.

This request is made in accordance with applicable laws and your platform policies.

Please confirm removal or advise further steps.

Thank you,
[Your Name]"""

    takedown_message = (
        f"mailto:{recipient}?subject={urllib.parse.quote(takedown_subject)}&body={urllib.parse.quote(takedown_body)}"
    )
    
    return JsonResponse({
        "status": "success",
        "takedown_subject": takedown_subject,
        "takedown_body": takedown_body,
        "takedown_mailto": takedown_message
    })
