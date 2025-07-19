from django import forms

class AbuseDetectorForm(forms.Form):
    image = forms.ImageField(required=False)
    url = forms.URLField(required=False)
    platform_email = forms.ChoiceField(
        choices=[
            ('support@facebook.com', 'Facebook'),
            ('support@instagram.com', 'Instagram'),
            ('legal@twitter.com', 'Twitter'),
            ('support@tiktok.com', 'TikTok'),
            ('report@onlyfans.com', 'OnlyFans'),
        ],
        required=False
    )
    custom_email = forms.EmailField(required=False)
