from django.shortcuts import render
import requests
import urllib.parse

IMGBB_API_KEY = "918766e3c5ed309a74613cedc23ba946"

def abuse_detector_view(request):
    uploaded_image_url = None
    tineye_url = None
    status_message = None
    takedown_message = None
    takedown_subject = None
    takedown_body = None

    # --- Image upload handling ---
    if request.method == 'POST' and 'image' in request.FILES:
        image = request.FILES['image']
        response = requests.post(
            f"https://api.imgbb.com/1/upload?key={IMGBB_API_KEY}",
            files={'image': image}
        )
        data = response.json()
        if response.status_code == 200 and data.get('data'):
            uploaded_image_url = data['data']['url']
            tineye_url = f"https://tineye.com/search?url={uploaded_image_url}"
            status_message = "✅ Image uploaded successfully."
        else:
            status_message = "❌ Failed to upload image."

    # --- Takedown email generation ---
    if request.method == 'POST' and 'found_link' in request.POST:
        link = request.POST.get('found_link', '').strip()
        platform_email = request.POST.get('platform_email', '').strip()
        custom_email = request.POST.get('custom_email', '').strip()

        recipient = custom_email if custom_email else platform_email
        if recipient and link:
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

    return render(request, 'abuse_detector/abuse_detector.html', {
        'uploaded_image_url': uploaded_image_url,
        'tineye_url': tineye_url,
        'status_message': status_message,
        'takedown_message': takedown_message,
        'takedown_subject': takedown_subject,
        'takedown_body': takedown_body,
    })

